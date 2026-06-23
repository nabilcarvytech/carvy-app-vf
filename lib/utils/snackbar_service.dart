import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Affichage sécurisé de snackbars GetX — évite `No Overlay widget found`
/// après [Get.back], [Get.off] ou transitions de paiement.
class SnackbarService {
  SnackbarService._();

  static const Duration navigationSettleDelay = Duration(milliseconds: 300);

  static void show({
    required String title,
    String message = '',
    SnackPosition snackPosition = SnackPosition.BOTTOM,
    Color? backgroundColor,
    Color? colorText,
    Duration duration = const Duration(seconds: 3),
    SnackStyle snackStyle = SnackStyle.FLOATING,
    EdgeInsets margin = const EdgeInsets.all(12),
    double borderRadius = 8,
    Duration delay = navigationSettleDelay,
  }) {
    Future.delayed(delay, () {
      if (Get.context == null) {
        if (kDebugMode) {
          debugPrint('[SnackbarService] Ignoré (Get.context null): $title');
        }
        return;
      }

      final overlay = Overlay.maybeOf(Get.context!, rootOverlay: true);
      if (overlay == null) {
        if (kDebugMode) {
          debugPrint('[SnackbarService] Ignoré (pas d\'Overlay): $title');
        }
        return;
      }

      if (Get.isSnackbarOpen == true) {
        Get.closeAllSnackbars();
      }

      Get.showSnackbar(
        GetSnackBar(
          titleText: title.isNotEmpty
              ? Text(
                  title,
                  style: TextStyle(
                    color: colorText ?? Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                )
              : null,
          messageText: message.isNotEmpty
              ? Text(
                  message,
                  style: TextStyle(
                    color: colorText ?? Colors.white,
                    fontSize: 14,
                  ),
                )
              : null,
          snackPosition: snackPosition,
          snackStyle: snackStyle,
          backgroundColor: backgroundColor ?? const Color(0xFF323232),
          margin: margin,
          borderRadius: borderRadius,
          duration: duration,
          isDismissible: true,
          dismissDirection: DismissDirection.horizontal,
        ),
      );
    });
  }
}

/// Extension GetX — remplace [Get.snackbar] pour les flux post-navigation.
extension SafeSnackbarGet on GetInterface {
  void safeSnackbar(
    String title,
    String message, {
    SnackPosition snackPosition = SnackPosition.BOTTOM,
    Color? backgroundColor,
    Color? colorText,
    Duration? duration,
    SnackStyle snackStyle = SnackStyle.FLOATING,
    EdgeInsets? margin,
    double? borderRadius,
    Duration? delay,
  }) {
    SnackbarService.show(
      title: title,
      message: message,
      snackPosition: snackPosition,
      backgroundColor: backgroundColor,
      colorText: colorText,
      duration: duration ?? const Duration(seconds: 3),
      snackStyle: snackStyle,
      margin: margin ?? const EdgeInsets.all(12),
      borderRadius: borderRadius ?? 8,
      delay: delay ?? SnackbarService.navigationSettleDelay,
    );
  }
}
