import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'logic/staff_earning_engine.dart';

final staffEarningEngineProvider = Provider<StaffEarningEngine>((ref) {
  return const StaffEarningEngine();
});
