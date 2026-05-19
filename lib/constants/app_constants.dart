/// Constantes globales de l'application (feature flags, etc.).
class AppConstants {
  AppConstants._();

  /// Active l'obligation KYC avant réservation et les éléments UI associés.
  /// Passer à `true` pour réactiver le flux de vérification d'identité.
  static const bool isKycEnabled = false;
}
