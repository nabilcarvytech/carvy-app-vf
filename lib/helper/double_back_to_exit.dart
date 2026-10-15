import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Double appui sur Retour pour quitter l'app **sans** déconnecter la session.
class DoubleBackToExit {
  DoubleBackToExit({this.interval = const Duration(seconds: 2)});

  final Duration interval;
  DateTime? _lastPressedAt;

  bool _isSecondPress() {
    final now = DateTime.now();
    if (_lastPressedAt != null &&
        now.difference(_lastPressedAt!) <= interval) {
      _lastPressedAt = null;
      return true;
    }
    _lastPressedAt = now;
    return false;
  }

  /// Ne supprime ni le JWT ni les données d'auth. N'appelle ni `logout`,
  /// ni `Get.offAll`, ni `Navigator.pop` (qui réafficheraient le login).
  /// `SystemNavigator.pop` met seulement l'activité Android en arrière-plan.
  void handle({
    required BuildContext context,
    required bool isOnRootTab,
    required VoidCallback goToRootTab,
    bool allowExit = true,
    ScaffoldMessengerState? messenger,
  }) {
    if (!isOnRootTab) {
      goToRootTab();
      return;
    }
    if (!allowExit) return;
    if (_isSecondPress()) {
      SystemNavigator.pop();
      return;
    }
    _showCenteredExitHint(context, messenger: messenger);
  }

  void _showCenteredExitHint(
    BuildContext context, {
    ScaffoldMessengerState? messenger,
  }) {
    final host = messenger ??
        ScaffoldMessenger.maybeOf(context) ??
        (Get.overlayContext != null
            ? ScaffoldMessenger.maybeOf(Get.overlayContext!)
            : null);
    if (host == null) return;
    host.hideCurrentSnackBar();
    host.showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
            'press_back_again_to_exit'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        duration: interval,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      ),
    );
  }
}
