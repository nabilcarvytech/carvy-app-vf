import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Verrou global pendant les transitions [Get.offAll] / [Get.back] atomiques.
/// Bloque les mutations Rx et les handlers push pendant le démontage des routes.
class NavigationGuard {
  NavigationGuard._();

  static bool isNavigating = false;

  static void begin() {
    isNavigating = true;
  }

  /// Réactive les fetchs / listeners après la frame suivante.
  static void endAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isNavigating = false;
    });
  }

  static void endImmediately() {
    isNavigating = false;
  }
}
