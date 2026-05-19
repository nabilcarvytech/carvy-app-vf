/// Parsing des notes véhicule / agence (API séparées + rétrocompatibilité).
class ReviewRatings {
  ReviewRatings({
    required this.vehicleRating,
    required this.agencyRating,
  });

  final double vehicleRating;
  final double agencyRating;

  static double parseNumeric(dynamic value, {double fallback = 0.0}) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble().clamp(0.0, 5.0);
    final parsed = double.tryParse(value.toString().trim());
    if (parsed == null) return fallback;
    return parsed.clamp(0.0, 5.0);
  }

  /// Note véhicule : vehicle_rating puis anciens champs (rating, vehicle_condition_rating).
  static double vehicleRatingFromJson(Map<String, dynamic> json) {
    return parseNumeric(
      json['vehicle_rating'] ??
          json['vehicleRating'] ??
          json['vehicle_condition_rating'] ??
          json['rating'],
    );
  }

  /// Note agence : agency_rating puis anciens champs (communication_rating, average_rating).
  static double agencyRatingFromJson(Map<String, dynamic> json) {
    return parseNumeric(
      json['agency_rating'] ??
          json['agencyRating'] ??
          json['communication_rating'] ??
          json['average_rating'] ??
          json['rating'],
    );
  }

  factory ReviewRatings.fromJson(Map<String, dynamic> json) {
    return ReviewRatings(
      vehicleRating: vehicleRatingFromJson(json),
      agencyRating: agencyRatingFromJson(json),
    );
  }

  static Map<String, dynamic> asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return {};
  }
}
