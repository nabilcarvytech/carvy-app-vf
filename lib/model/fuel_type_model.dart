class FuelTypeModel {
  final int status;
  final String message;
  final List<FuelType> fuelTypes;
  final String? error;

  FuelTypeModel({
    required this.status,
    required this.message,
    required this.fuelTypes,
    this.error,
  });

  factory FuelTypeModel.fromJson(Map<String, dynamic> json) {
    return FuelTypeModel(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      fuelTypes: (json['data']['fuel_types'] as List<dynamic>)
          .map((e) => FuelType.fromJson(e))
          .toList(),
      error: json['error'],
    );
  }
}

class FuelType {
  final String? id; // CHANGÉ : String? pour permettre null si l'ID n'est pas présent
  final String name;

  FuelType({
    this.id, // CHANGÉ : nullable
    required this.name,
  });

  factory FuelType.fromJson(Map<String, dynamic> json) {
    // PRIORITÉ à _id (MongoDB) et FORCER en String
    final idValue = json['_id'] ?? json['id'];
    String? parsedId;
    if (idValue == null) {
      parsedId = null; // null si absent
    } else {
      // FORCER la conversion en String (MongoDB ObjectId est une string)
      final trimmed = idValue.toString().trim();
      parsedId = trimmed.isNotEmpty ? trimmed : null;
    }
    
    return FuelType(
      id: parsedId,
      name: json['fuel_type'] ?? json['name'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FuelType &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id?.hashCode ?? 0; // CHANGÉ : gérer null
}
