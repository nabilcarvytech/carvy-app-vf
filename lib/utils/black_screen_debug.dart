import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:carvy/utils/navigation_guard.dart';

/// Logs ciblés pour diagnostiquer l'écran noir post-réservation
/// (collision navigation MyBooking ↔ notif OneSignal foreground).
void blackScreenLog(String step, [Object? detail]) {
  if (!kDebugMode) return;
  final extra = detail != null ? ' | $detail' : '';
  debugPrint('🖤 [BLACK_SCREEN] $step$extra');
}

/// Snapshot de l'état UI / navigation au moment d'un événement suspect.
Map<String, Object?> blackScreenSnapshot({
  String? source,
  Map<String, Object?>? extra,
}) {
  String? routeName;
  try {
    routeName = Get.currentRoute;
  } catch (_) {
    routeName = '<route_error>';
  }

  bool? overlayPresent;
  try {
    final ctx = Get.context;
    if (ctx == null) {
      overlayPresent = null;
    } else {
      overlayPresent = Overlay.maybeOf(ctx, rootOverlay: true) != null;
    }
  } catch (e) {
    overlayPresent = null;
    blackScreenLog('snapshot overlay probe failed', e);
  }

  final phase = SchedulerBinding.instance.schedulerPhase;
  final snap = <String, Object?>{
    'source': source,
    'isNavigating': NavigationGuard.isNavigating,
    'allowsReactiveUi': NavigationGuard.allowsReactiveUi(),
    'currentRoute': routeName,
    'getContextNull': Get.context == null,
    'overlayPresent': overlayPresent,
    'schedulerPhase': phase.toString(),
    'isSnackbarOpen': Get.isSnackbarOpen,
    'ts': DateTime.now().toIso8601String(),
    ...?extra,
  };

  blackScreenLog('SNAPSHOT', snap);
  return snap;
}

void blackScreenCatch(
  String step,
  Object error,
  StackTrace stack, {
  Map<String, Object?>? extra,
}) {
  if (!kDebugMode) return;
  blackScreenLog('CATCH@$step', error);
  blackScreenLog('STACK@$step', stack);
  blackScreenSnapshot(source: 'catch:$step', extra: extra);
}
