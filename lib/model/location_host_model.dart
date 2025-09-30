

class LocationsHostModel {
  locationsModel({
    num? status,
    String? message,
    Data? data,
    String? error,
  }) {
    _status = status;
    _message = message;
    _data = data;
    _error = error;
  }

  LocationsHostModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
    _error = json['error'];
  }
  num? _status;
  String? _message;
  Data? _data;
  String? _error;

  num? get status => _status;
  String? get message => _message;
  Data? get data => _data;
  String? get error => _error;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    map['error'] = _error;
    return map;
  }
}

class Data {
  Data({
    List<LocationsHost>? locations,
  }) {
    _locations = locations;
  }

  Data.fromJson(dynamic json) {
    if (json['Locations'] != null) {
      _locations = [];
      json['Locations'].forEach((v) {
        _locations?.add(LocationsHost.fromJson(v));
      });
    }
  }
  List<LocationsHost>? _locations;
  List<LocationsHost>? get locations => _locations;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_locations != null) {
      map['Locations'] = _locations?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class LocationsHost {
  LocationsHost({
    num? id,
    String? cityName,
    String? description,
    String? image,
    String? latitude,
    String? countryCode,
    dynamic longitude,
  }) {
    _id = id;
    _cityName = cityName;
    _description = description;
    _image = image;
    _latitude = latitude;
    _longitude = longitude;
    _countryCode = countryCode;
  }

  LocationsHost.fromJson(dynamic json) {
    _id = json['id'];
    _cityName = json['city_name'];
    _description = json['description'];
    _image = json['image'];
    _latitude = json['latitude'];
    _longitude = json['longitude'];
    _countryCode = json['country_code'];
  }
  num? _id;
  String? _cityName;
  String? _description;
  String? _image;
  String? _latitude;
  dynamic _longitude;
  String? _countryCode;

  num? get id => _id;
  String? get name => _cityName;
  String? get description => _description;
  String? get image => _image;
  String? get latitude => _latitude;
  String? get countryCode => _countryCode;
  dynamic get longitude => _longitude;

  set citySetter(value) {
    _cityName = value;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['city_name'] = _cityName;
    map['description'] = _description;
    map['image'] = _image;
    map['latitude'] = _latitude;
    map['country_code'] = _countryCode;
    map['longitude'] = _longitude;
    return map;
  }
}
