import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/booking_record_controller.dart';
import 'package:carvy/utils/black_screen_debug.dart';

/// Verrou global pendant les transitions [Get.offAll] / [Get.back] atomiques.
/// Bloque les mutations Rx et les handlers push pendant le démontage des routes.
class NavigationGuard {
  NavigationGuard._();

  static final RxBool _navigating = false.obs;

  /// Verrou dédié post-paiement : empêche [endImmediately] de réactiver trop tôt
  /// les rebuilds (écran noir / TabController disposed / Duplicate GlobalKeys).
  static bool _postPaymentLock = false;

  /// Observable pour que les cellules puissent se mettre en silence pendant la transition.
  static RxBool get isNavigatingObs => _navigating;

  static bool get isNavigating => _navigating.value || _postPaymentLock;

  static bool get isPostPaymentLocked => _postPaymentLock;

  static set isNavigating(bool value) {
    if (_navigating.value == value) return;
    _navigating.value = value;
    blackScreenLog(
      'NavigationGuard._navigating=$value postPaymentLock=$_postPaymentLock '
      'effectiveIsNavigating=$isNavigating',
    );
  }

  /// Début navigation post-paiement (Get.offAll MyBooking).
  static void beginPostPayment() {
    _postPaymentLock = true;
    _navigating.value = true;
    blackScreenLog('NavigationGuard.beginPostPayment');
    blackScreenSnapshot(source: 'NavigationGuard.beginPostPayment');
  }

  static void begin() {
    isNavigating = true;
    blackScreenSnapshot(source: 'NavigationGuard.begin');
  }

  /// Réactive les fetchs / listeners après la frame suivante.
  static void endAfterFrame() {
    blackScreenLog('NavigationGuard.endAfterFrame scheduled');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _postPaymentLock = false;
      _navigating.value = false;
      blackScreenSnapshot(source: 'NavigationGuard.endAfterFrame.fired');
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

  /// Ne casse PAS le verrou post-paiement (sinon écran noir).
  static void endImmediately() {
    if (_postPaymentLock) {
      blackScreenLog(
        'NavigationGuard.endImmediately IGNORED',
        'postPaymentLock=true',
      );
      return;
    }
    blackScreenLog('NavigationGuard.endImmediately');
    isNavigating = false;
  }

  /// Forcer la fin du verrou post-paiement (fin de navigate after payment).
  static void endPostPaymentAfterFrame() {
    blackScreenLog('NavigationGuard.endPostPaymentAfterFrame scheduled');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _postPaymentLock = false;
      _navigating.value = false;
      blackScreenLog('NavigationGuard.endPostPaymentAfterFrame fired');
      blackScreenSnapshot(source: 'NavigationGuard.endPostPaymentAfterFrame');
    });
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
