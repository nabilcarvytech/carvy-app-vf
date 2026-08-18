class AddressHistoryModel {
  final String id;
  final String address;
  final String label;
  final double latitude;
  final double longitude;
  final DateTime? createdAt;

  const AddressHistoryModel({
    required this.id,
    required this.address,
    required this.label,
    required this.latitude,
    required this.longitude,
    this.createdAt,
  });

  static double _toDouble(dynamic value, {double fallback = 0}) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  factory AddressHistoryModel.fromJson(Map<String, dynamic> json) {
    return AddressHistoryModel(
      id: json['id']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      latitude: _toDouble(json['latitude'] ?? json['lat']),
      longitude: _toDouble(json['longitude'] ?? json['lng']),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'address': address,
        'label': label,
        'latitude': latitude,
        'longitude': longitude,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };
}
