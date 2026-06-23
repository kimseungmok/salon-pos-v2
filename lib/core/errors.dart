/// 앱 전체 공통 예외 타입.
///
/// 모든 사용자 노출 메시지는 일본어로 작성한다(현지화 필수 원칙,
/// design/spec/v3/00_overview.md §3 참조). [message]는 화면에 그대로
/// 표시되는 문구이므로 항상 일본어로 작성하고, [debugInfo]는 로그용
/// (한국어/영어 섞어도 무방, 사용자에게는 노출하지 않음).
sealed class AppException implements Exception {
  const AppException(this.message, {this.debugInfo});

  /// 사용자에게 그대로 보여줄 일본어 메시지.
  final String message;

  /// 개발자 디버깅용 부가정보(사용자 비노출).
  final String? debugInfo;

  @override
  String toString() => 'AppException: $message'
      '${debugInfo != null ? ' (debug: $debugInfo)' : ''}';
}

/// 필수 입력값 누락, 형식 오류 등 — 사용자가 즉시 고칠 수 있는 입력 오류.
class ValidationException extends AppException {
  const ValidationException(super.message, {super.debugInfo});
}

/// 중복 등록(예: 동일 이름의 카테고리/상품) 등 비즈니스 규칙 위반.
class BusinessRuleException extends AppException {
  const BusinessRuleException(super.message, {super.debugInfo});
}

/// 조회 대상이 존재하지 않음(이미 삭제된 항목 등).
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.debugInfo});
}

/// 로컬 DB(SQLite/Drift) 읽기/쓰기 실패. 오프라인 우선 정책상 네트워크
/// 예외는 별도로 두지 않고, DB 예외만 잡아서 일본어로 재포장한다.
class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.debugInfo});

  factory DatabaseException.writeFailed([String? debugInfo]) =>
      DatabaseException('データの保存に失敗しました。もう一度お試しください。',
          debugInfo: debugInfo);

  factory DatabaseException.readFailed([String? debugInfo]) =>
      DatabaseException('データの読み込みに失敗しました。もう一度お試しください。',
          debugInfo: debugInfo);
}

/// 예상치 못한 예외를 잡아 일본어 메시지로 감싸는 헬퍼.
/// UI 레이어(화면)에서 try/catch 시 항상 이걸 거쳐 SnackBar 등에 표시한다.
AppException wrapUnknown(Object error, [StackTrace? stack]) {
  if (error is AppException) return error;
  return DatabaseException(
    '予期しないエラーが発生しました。もう一度お試しください。',
    debugInfo: '$error',
  );
}
