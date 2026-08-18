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

    final openSettings = await Get.dialog<bool>(
      AlertDialog(
        title: Text('GPS'.tr),
        content: Text('location_required_for_address'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('open_location_settings'.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (openSettings != true) {
      return false;
    }

    await Geolocator.openLocationSettings();
    // Une seule vérification au retour — pas de boucle d'attente.
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

  /// Contrôles GPS + permissions (sans indicateur de chargement).
  static Future<bool> ensureLocationReady([BuildContext? context]) async {
    if (!await ensureLocationEnabled()) {
      return false;
    }
    return ensureLocationPermission(context);
  }

  /// GPS activé + permissions OK + position [LocationAccuracy.best] (timeLimit 10 s).
  static Future<Position?> getCurrentPositionWithChecks(
    BuildContext? context, {
    Duration timeLimit = defaultTimeLimit,
  }) async {
    if (!await ensureLocationReady(context)) {
      return null;
    }

    return getCurrentPosition(
      timeLimit: timeLimit,
    );
  }

  /// Position courante (GPS et permissions déjà validés).
  static Future<Position?> getCurrentPosition({
    Duration timeLimit = defaultTimeLimit,
  }) async {
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
      debugPrint('LocationService.getCurrentPosition: $e');
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
