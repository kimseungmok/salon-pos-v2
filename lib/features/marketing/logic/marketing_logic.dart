import '../../../db/app_database.dart';

/// design/spec/v3/payment_pos/logic의 applyCouponDiscount()를 그대로
/// 재사용한다 — 동일한 쿠폰 할인 계산을 마케팅 모듈에서 중복
/// 구현하지 않는다(coupon/feature_spec.md F-MKT-01). 마케팅 화면에서
/// `import '.../marketing_logic.dart'` 한 번으로 두 함수 모두 쓸 수
/// 있게 export.
export 'package:salon_pos_v2/features/payment_pos/logic/payment_logic.dart'
    show applyCouponDiscount;

/// design/spec/v3/marketing/data_spec.md computeEarnedPoints() 그대로.
/// (CROSS_VALIDATION.md 수정2 — payment_pos의 결제완료 처리(F-PAY-03)
/// 에서 호출될 함수. 적립 대상 금액 필터링[earnScope]은 호출 측 책임.)
int computeEarnedPoints(int eligibleAmount, PointPolicyRow policy) {
  if (!policy.enabled) return 0;
  return (eligibleAmount * policy.earnRate / 100).floor();
}
