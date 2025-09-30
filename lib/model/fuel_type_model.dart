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
  final int id;
  final String name;

  FuelType({
    required this.id,
    required this.name,
  });

  factory FuelType.fromJson(Map<String, dynamic> json) {
    return FuelType(
      id: json['id'] ?? 0,
      name: json['fuel_type'] ?? '',
    );
  }
}
