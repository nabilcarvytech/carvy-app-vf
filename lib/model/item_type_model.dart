
// class PropertyTypeModel {
//   PropertyTypeModel({
//       num? status, 
//       String? message, 
//       Data? data, 
//       String? error,}){
//     _status = status;
//     _message = message;
//     _data = data;
//     _error = error;
// }

//   PropertyTypeModel.fromJson(dynamic json) {
//     _status = json['status'];
//     _message = json['message'];
//     _data = json['data'] != null ? Data.fromJson(json['data']) : null;
//     _error = json['error'];
//   }
//   num? _status;
//   String? _message;
//   Data? _data;
//   String? _error;

//   num? get status => _status;
//   String? get message => _message;
//   Data? get data => _data;
//   String? get error => _error;

//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['status'] = _status;
//     map['message'] = _message;
//     if (_data != null) {
//       map['data'] = _data?.toJson();
//     }
//     map['error'] = _error;
//     return map;
//   }

// }

// class Data {
//   Data({
//       List<itemTypes>? itemTypes,}){
//     _itemTypes = itemTypes;
// }

//   Data.fromJson(dynamic json) {
//     if (json['itemTypes'] != null) {
//       _itemTypes = [];
//       json['itemTypes'].forEach((v) {
//         _itemTypes?.add(itemTypes.fromJson(v));
//       });
//     }
//   }
//   List<itemTypes>? _itemTypes;

//   List<itemTypes>? get itemTypes => _itemTypes;

//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     if (_propertyTypes != null) {
//       map['itemTypes'] = _propertyTypes?.map((v) => v.toJson()).toList();
//     }
//     return map;
//   }

// }


//   class itemTypes {
//     itemTypes({
//         num? id, 
//         String? name, 
//         String? description, 
//         dynamic? status, 
//         dynamic image,}){
//       _id = id;
//       _name = name;
//       _description = description;
//       _status = status;
//       _image = image;
//   }

//   itemTypes.fromJson(dynamic json) {
//     _id = json['id'];
//     _name = json['name'];
//     _description = json['description'];
//     _status = json['status'];
//     _image = json['image'];
//   }
//   num? _id;
//   String? _name;
//   String? _description;
//   dynamic? _status;
//   dynamic _image;

//   num? get id => _id;
//   String? get name => _name;
//   String? get description => _description;
//   dynamic? get status => _status;
//   dynamic get image => _image;

//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['id'] = _id;
//     map['name'] = _name;
//     map['description'] = _description;
//     map['status'] = _status;
//     map['image'] = _image;
//     return map;
//   }

// }
class ItemTypeModel {
  ItemTypeModel({
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

  ItemTypeModel.fromJson(dynamic json) {
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
    List<ItemTypes>? itemTypes,
  }) {
    _itemTypes = itemTypes;
  }

  Data.fromJson(dynamic json) {
    if (json['itemTypes'] != null) {
      _itemTypes = [];
      json['itemTypes'].forEach((v) {
        _itemTypes?.add(ItemTypes.fromJson(v));
      });
    }
  }

  List<ItemTypes>? _itemTypes;

  List<ItemTypes>? get itemTypes => _itemTypes;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_itemTypes != null) {
      map['itemTypes'] = _itemTypes?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class ItemTypes {
  ItemTypes({
    String? id,
    String? name,
    String? description,
    dynamic status,
    dynamic image,
  }) {
    _id = id;
    _name = name;
    _description = description;
    _status = status;
    _image = image;
  }

  ItemTypes.fromJson(dynamic json) {
    // Gérer MongoDB _id en priorité, puis id standard
    _id = json['_id']?.toString() ?? json['id']?.toString();
    _name = json['name'];
    _description = json['description'];
    _status = json['status'];
    _image = json['image'];
  }

  String? _id;
  String? _name;
  String? _description;
  dynamic _status;
  dynamic _image;

  String? get id => _id;
  String? get name => _name;
  String? get description => _description;
  dynamic get status => _status;
  dynamic get image => _image;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['description'] = _description;
    map['status'] = _status;
    map['image'] = _image;
    return map;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemTypes &&
          runtimeType == other.runtimeType &&
          _id == other._id;

  @override
  int get hashCode => _id?.hashCode ?? 0;
}
