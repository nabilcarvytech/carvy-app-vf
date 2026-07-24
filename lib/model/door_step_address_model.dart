class AddressResponse {
  int? status;
  String? message;
  AddressData? data;
  String? error;

  AddressResponse({this.status, this.message, this.data, this.error});

  factory AddressResponse.fromJson(Map<String, dynamic> json) {
    return AddressResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? AddressData.fromJson(json['data']) : null,
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
      'error': error,
    };
  }
}

class AddressData {
  DoorStepAddress? doorStepAddress;

  AddressData({this.doorStepAddress});

  factory AddressData.fromJson(Map<String, dynamic> json) {
    return AddressData(
      doorStepAddress: json['door_step_address'] != null
          ? DoorStepAddress.fromJson(json['door_step_address'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'door_step_address': doorStepAddress?.toJson(),
    };
  }
}

class DoorStepAddress {
  /// Libellé / type de lieu (Maison, Bureau, Aéroport…).
  dynamic addressLabel;
  dynamic fullAddress;
  dynamic city;
  dynamic state;
  dynamic country;
  dynamic postalCode;
  double? doorstepLatitude;
  double? doorstepLongitude;

  /// Champs legacy (lecture seule pour anciennes réponses API).
  dynamic houseFloorNumber;
  dynamic buildingBlockNumber;
  dynamic landmark;

  DoorStepAddress({
    this.addressLabel,
    this.fullAddress,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.doorstepLatitude,
    this.doorstepLongitude,
    this.houseFloorNumber,
    this.buildingBlockNumber,
    this.landmark,
  });

  factory DoorStepAddress.fromJson(Map<String, dynamic> json) {
    final label = json['address_label']?.toString() ??
        json['landmark']?.toString() ??
        json['house_floor_number']?.toString();
    return DoorStepAddress(
      addressLabel: label,
      fullAddress: json['full_address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postal_code'],
      doorstepLatitude: (json['doorstep_latitude'] != null)
          ? double.tryParse(json['doorstep_latitude'].toString())
          : null,
      doorstepLongitude: (json['doorstep_longitude'] != null)
          ? double.tryParse(json['doorstep_longitude'].toString())
          : null,
      houseFloorNumber: json['house_floor_number']?.toString(),
      buildingBlockNumber: json['building_block_number'],
      landmark: json['landmark'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address_label': addressLabel,
      'full_address': fullAddress,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'doorstep_latitude': doorstepLatitude,
      'doorstep_longitude': doorstepLongitude,
    };
  }
}
