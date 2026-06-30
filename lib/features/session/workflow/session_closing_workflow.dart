import 'package:drift/drift.dart';

import '../../../core/errors.dart';
import '../../../db/app_database.dart';
import '../../staff_earning/domain/earnable_item.dart';
import '../../staff_earning/logic/staff_earning_engine.dart';
import '../data/session_repository.dart' show PaymentMethodInput, SessionStatus, SessionStatusX;

/// A-14 Phase 1(Workflow Extraction). `SessionRepository.closeSession()`이
/// 수행하던 **Workflow Coordination 책임만** 그대로 옮긴 클래스다 —
/// 로직/순서/Transaction 범위는 A-13(ADR-007)과 한 글자도 다르지 않다.
///
/// 포함 범위(ADR-007에서 확정된 Transaction Scope 그대로):
/// Settlement(`payment_method_breakdowns`) 저장 → `StaffEarningEngine`
/// 호출 → `staff_earning_ledgers` 저장(조건부) → Session 상태 변경.
///
/// **Repository 책임과의 경계**: 이 클래스도 여전히 `AppDatabase`를 통해
/// Drift를 직접 호출한다 — `SessionRepository.closeSession()`의 트랜잭션
/// 본문을 그대로 들어낸 것이므로, "어떤 데이터를 어떻게 쓰는지"(CRUD
/// 로직)는 바뀌지 않았다. 이 클래스가 새로 갖는 것은 "그 절차를 어떤
/// 순서로 실행할지"(Coordination)뿐이다(`docs/A14_WORKFLOW_CONTRACT_VALIDATION.md`
/// PART6 — 이 경계를 어떻게 더 분리할지는 A-14 Phase 1 범위 밖).
class SessionClosingWorkflow {
  SessionClosingWorkflow(
    this._db, {
    StaffEarningEngine? staffEarningEngine,
  }) : _staffEarningEngine = staffEarningEngine ?? const StaffEarningEngine();

  final AppDatabase _db;
  final StaffEarningEngine _staffEarningEngine;

  /// `SessionRepository.closeSession()`의 검증(입력 형식/세션 상태/결제
  /// 합계 일치)이 전부 통과한 뒤에만 호출된다 — 이 메서드 자체는 그
  /// 검증을 다시 수행하지 않는다(중복 없음, 호출자 책임).
  Future<void> run({
    required int sessionId,
    required List<PaymentMethodInput> paymentMethods,
    required DateTime now,
  }) async {
    await _db.transaction(() async {
      await _db.batch((batch) {
        batch.insertAll(
          _db.paymentMethodBreakdowns,
          paymentMethods.map(
            (m) => PaymentMethodBreakdownsCompanion.insert(
              sessionId: sessionId,
              method: m.method,
              amount: m.amount,
              receivedAt: now,
            ),
          ),
        );
      });

      final sessionItems = await (_db.select(_db.paymentSessionItems)
            ..where((i) => i.sessionId.equals(sessionId)))
          .get();
      final earnableItems = sessionItems
          .map((i) => EarnableItem(
                id: i.id,
                itemType: i.itemType,
                staffId: i.staffId,
                amount: i.amount,
              ))
          .toList();
      final earnings = _staffEarningEngine.calcEarnings(items: earnableItems);
      if (earnings.isNotEmpty) {
        await _db.batch((batch) {
          batch.insertAll(
            _db.staffEarningLedgers,
            earnings.map(
              (r) => StaffEarningLedgersCompanion.insert(
                sessionId: sessionId,
                sessionItemId: Value(r.sessionItemId),
                staffId: r.staffId,
                earningType: 'staff_fee',
                amount: r.earningAmount,
                createdAt: now,
              ),
            ),
          );
        });
      }

      // A-18.3(ADR-007 범위 내 Minimal Change, docs/A18_2_MINIMAL_CHANGE_RESOLUTION_ANALYSIS.md):
      // `status.equals('open')` 조건을 추가해 이 UPDATE 문 자체를
      // "아직 open인 경우에만 닫는다"는 조건부 갱신으로 만든다. 두
      // 호출이 동시에 여기 도달해도 SQLite는 단일 UPDATE 문을
      // 원자적으로 처리하므로, 먼저 적용된 쪽만 영향 행 수 1을 받고
      // 나머지는 0을 받는다 — 0이면 이미 다른 호출이 닫았다는 뜻이라
      // 기존과 동일한 예외(BusinessRuleException)를 던져 트랜잭션
      // 전체(이 호출이 방금 쓴 Settlement/Ledger 포함)를 rollback한다.
      final updatedRows = await (_db.update(_db.paymentSessions)
            ..where((s) =>
                s.id.equals(sessionId) & s.status.equals(SessionStatus.open.value)))
          .write(PaymentSessionsCompanion(
        status: Value(SessionStatus.closed.value),
        endAt: Value(now),
        updatedAt: Value(now),
      ));
      if (updatedRows == 0) {
        throw const BusinessRuleException('既にクローズ・キャンセル済みのセッションです。');
      }
    });
  }
}
