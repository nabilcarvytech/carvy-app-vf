
class AmenitiesModel {
  AmenitiesModel({
      String? status, 
      String? message, 
      Data? data, 
      String? error,}){
    _status = status;
    _message = message;
    _data = data;
    _error = error;
}

  AmenitiesModel.fromJson(dynamic json) {
    _status = json['status']?.toString();
    _message = json['message']?.toString();
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
    _error = json['error']?.toString();
  }
  String? _status;
  String? _message;
  Data? _data;
  String? _error;

  String? get status => _status;
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
      List<Amenities>? amenities,}){
    _amenities = amenities;
}

  Data.fromJson(dynamic json) {
    if (json['amenities'] != null) {
      _amenities = [];
      json['amenities'].forEach((v) {
        _amenities?.add(Amenities.fromJson(v));
      });
    }
  }
  List<Amenities>? _amenities;

  List<Amenities>? get amenities => _amenities;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_amenities != null) {
      map['amenities'] = _amenities?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class Amenities {
  Amenities({
      String? id, 
      String? name, 
      String? image,}){
    _id = id;
    _name = name;
    _image = image;
}

  Amenities.fromJson(dynamic json) {
    _id = json['id']?.toString() ?? json['_id']?.toString() ?? '';
    _name = json['name']?.toString();
    _image = json['image']?.toString();
  }
  String? _id;
  String? _name;
  String? _image;

  String? get id => _id;
  String? get name => _name;
  String? get image => _image;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['image'] = _image;
    return map;
  }

}
