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
