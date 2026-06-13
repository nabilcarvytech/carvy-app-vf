import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/utils/common_widget.dart';

/// Géolocalisation (Geolocator) : GPS, permissions et position courante.
class LocationService {
  LocationService._();

  static const Duration defaultTimeLimit = Duration(seconds: 10);

  /// Vérifie que le service GPS est activé.
  static Future<bool> ensureLocationEnabled() async {
    if (await Geolocator.isLocationServiceEnabled()) {
      return true;
    }

    await Get.defaultDialog(
      title: 'GPS'.tr,
      middleText: 'location_required_for_address'.tr,
      textConfirm: 'open_location_settings'.tr,
      textCancel: 'Cancel'.tr,
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        Geolocator.openLocationSettings();
      },
      onCancel: () => Get.back(),
    );

    return Geolocator.isLocationServiceEnabled();
  }

  /// Vérifie et demande les permissions de localisation.
  static Future<bool> ensureLocationPermission([BuildContext? context]) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      showErrorToastMessage(
        'Location permission denied. Please go to settings and allow the location'
            .tr,
      );
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      final ctx = context ?? Get.context;
      if (ctx != null) {
        showOpenAppSettingsDialog(
          ctx,
          'Location permission denied. Please go to settings and allow the location'
              .tr,
        );
      }
      return false;
    }

    return true;
  }

  /// GPS activé + permissions OK + position [LocationAccuracy.best] (timeLimit 10 s).
  static Future<Position?> getCurrentPositionWithChecks(
    BuildContext? context, {
    Duration timeLimit = defaultTimeLimit,
  }) async {
    if (!await ensureLocationEnabled()) {
      return null;
    }

    if (!await ensureLocationPermission(context)) {
      return null;
    }

    final settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      timeLimit: timeLimit,
    );

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: settings,
      );
    } on TimeoutException {
      showErrorToastMessage(
        'Failed to get current location within the timeout please search manually'
            .tr,
      );
      return null;
    } catch (e) {
      debugPrint('LocationService.getCurrentPositionWithChecks: $e');
      showErrorToastMessage('Failed to get current location.'.tr);
      return null;
    }
  }

  /// Variante sans UI de chargement (démarrage app, etc.).
  static Future<Position?> getCurrentPositionSilent({
    Duration timeLimit = defaultTimeLimit,
  }) async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: timeLimit,
        ),
      );
    } catch (e) {
      debugPrint('LocationService.getCurrentPositionSilent: $e');
      return null;
    }
  }
}
