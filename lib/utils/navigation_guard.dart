import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/booking_record_controller.dart';

/// Verrou global pendant les transitions [Get.offAll] / [Get.back] atomiques.
/// Bloque les mutations Rx et les handlers push pendant le démontage des routes.
class NavigationGuard {
  NavigationGuard._();

  static final RxBool _navigating = false.obs;

  /// Observable pour que les cellules puissent se mettre en silence pendant la transition.
  static RxBool get isNavigatingObs => _navigating;

  static bool get isNavigating => _navigating.value;

  static set isNavigating(bool value) {
    if (_navigating.value == value) return;
    _navigating.value = value;
  }

  static void begin() {
    isNavigating = true;
  }

  /// Réactive les fetchs / listeners après la frame suivante.
  static void endAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isNavigating = false;
    });
  }

  /// Exécute [action] dès que [isNavigating] repasse à false (retry post-paiement).
  static Future<void> runWhenIdle(
    Future<void> Function() action, {
    Duration pollInterval = const Duration(milliseconds: 100),
    int maxAttempts = 50,
  }) async {
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      if (!isNavigating) {
        await action();
        return;
      }
      await Future.delayed(pollInterval);
    }
    await action();
  }

  static void endImmediately() {
    isNavigating = false;
  }

  /// `true` seulement quand les Obx / rebuilds locaux peuvent s'exécuter en sécurité.
  static bool allowsReactiveUi() {
    if (isNavigating) return false;
    if (Get.isRegistered<BookingRecordController>()) {
      try {
        final c = Get.find<BookingRecordController>();
        if (c.isClosed || c.isNavigating) return false;
      } catch (_) {
        return false;
      }
    }
    return true;
  }
}
