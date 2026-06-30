/// `StaffEarningEngine.calcEarnings()`의 반환 원소 — **계산 결과만
/// 표현한다, Repository를 알지 않는다.** `sessionItemId`는 호출자
/// (`SessionRepository`)가 `StaffEarningLedger` 행을 쓸 때 필요한
/// 연결 정보라 포함하지만, 이 클래스 자체는 DB/Drift를 전혀 모른다.
class StaffEarningResult {
  const StaffEarningResult({
    required this.staffId,
    required this.sessionItemId,
    required this.totalAmount,
    required this.earningAmount,
    required this.earningRate,
  });

  final int staffId;
  final int sessionItemId;

  /// 할인 전 원래 품목 금액(ADR-006 — 할인 영향 없음).
  final int totalAmount;

  /// [totalAmount]에 [earningRate]를 적용한 최종 수익(음수 불가).
  final int earningAmount;

  final int earningRate;
}
