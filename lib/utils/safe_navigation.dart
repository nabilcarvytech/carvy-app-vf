import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Retour arrière sans déclencher le bug GetX Snackbar (LateInitializationError).
void safeGetBack({BuildContext? context, VoidCallback? then}) {
  void pop() {
    final ctx = context ?? Get.context;
    if (ctx != null && ctx.mounted && Navigator.of(ctx).canPop()) {
      Navigator.of(ctx).pop();
      then?.call();
      return;
    }
    try {
      if (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
        Get.back(closeOverlays: false);
      } else if (Get.key.currentState?.canPop() ?? false) {
        Get.back(closeOverlays: false);
      }
    } catch (_) {
      // Dernier recours silencieux si GetX n'est pas prêt.
    }
    then?.call();
  }

  if (Get.isSnackbarOpen) {
    try {
      Get.closeCurrentSnackbar();
    } catch (_) {}
    Future.delayed(const Duration(milliseconds: 100), pop);
  } else {
    pop();
  }
}

/// Ferme la route courante puis exécute [action] à la frame suivante.
///
/// Ce pattern évite de muter l'état ou de relancer une navigation pendant
/// la transition de fermeture d'une modal/bottom sheet, ce qui peut corrompre
/// l'arbre de rendu/semantics sur iOS et macOS.
void safePopAndAction(BuildContext context, VoidCallback action) {
  final navigator = Navigator.of(context);
  if (navigator.canPop()) {
    navigator.pop();
  } else if (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
    try {
      Get.back(closeOverlays: false);
    } catch (_) {
      // Repli silencieux si GetX n'est pas prêt.
    }
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    action();
  });
}
