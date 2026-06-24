import 'package:flutter/foundation.dart';

/// Logs de traçage du flux paiement → « Voir mes réservations » (debug uniquement).
void paymentFlowLog(String step, [Object? detail]) {
  if (!kDebugMode) return;
  final extra = detail != null ? ' | $detail' : '';
  debugPrint('🧭 [PAYMENT_FLOW] $step$extra');
}
