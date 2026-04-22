import 'package:flutter/material.dart';

/// Focus pour l’étape Identité véhicule (marque → modèle → année).
/// Utilisé par [AddVehicleScreen] (`lib/view/vehicle/add_vehicle_screen.dart`).
class VehicleIdentityStepFocus {
  VehicleIdentityStepFocus() {
    brandFocus = FocusNode(debugLabel: 'vehicleIdentityBrand');
    modelFocus = FocusNode(debugLabel: 'vehicleIdentityModel');
    yearFocus = FocusNode(debugLabel: 'vehicleIdentityYear');
  }

  late final FocusNode brandFocus;
  late final FocusNode modelFocus;
  late final FocusNode yearFocus;

  void dispose() {
    brandFocus.dispose();
    modelFocus.dispose();
    yearFocus.dispose();
  }
}
