/// Données passées au tunnel de paiement standard pour une prolongation.
class ExtensionPaymentContext {
  final String bookingId;
  final String newEndDateIso;
  final double additionalAmount;
  final String currency;
  final int extraDays;
  final String oldEndLabel;
  final String newEndLabel;
  final String? startLabel;
  final String? paymentUrl;

  const ExtensionPaymentContext({
    required this.bookingId,
    required this.newEndDateIso,
    required this.additionalAmount,
    required this.currency,
    required this.extraDays,
    required this.oldEndLabel,
    required this.newEndLabel,
    this.startLabel,
    this.paymentUrl,
  });
}

/// Résultat détaillé de extend-confirm (succès, URL de paiement, message).
class ReservationExtendConfirmResult {
  final bool success;
  final String? paymentUrl;
  final String? message;

  const ReservationExtendConfirmResult({
    required this.success,
    this.paymentUrl,
    this.message,
  });
}
