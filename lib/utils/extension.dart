extension BookingStatusExtension on String? {
  String toStandardStatus() {
    final value = this?.trim();
    if (value == null || value.isEmpty) {
      return 'UNKNOWN';
    }
    return value.toUpperCase();
  }

  bool get isConfirmed => toStandardStatus() == 'CONFIRMED';
  bool get isPending => toStandardStatus() == 'PENDING';
}
