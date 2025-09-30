class AddRulesModel {
  AddRulesModel({
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

  AddRulesModel.fromJson(dynamic json) {
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
  List<AddRules>? _addRules;
  List<AddRules>? get addRules => _addRules;
  Data({
    List<AddRules>? addRules,
  }) {
    _addRules = addRules;
  }

  Data.fromJson(dynamic json) {
    if (json['booking_rules'] != null) {
      _addRules = [];
      json['booking_rules'].forEach((v) {
        _addRules?.add(AddRules?.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_addRules != null) {
      map['booking_rules'] = _addRules?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class AddRules {
  AddRules({
    num? id,
    dynamic  name,
    dynamic status,
    dynamic createdAt,
    dynamic updatedAt,
  }) {
    _id = id;
    _name = name;

    _status = status;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  AddRules.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['rule_name'];

    _status = json['status'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }
  num? _id;
  dynamic _name;

  dynamic _status;
  dynamic _createdAt;
  dynamic _updatedAt;

  num? get id => _id;
  dynamic get name => _name;

  dynamic get status => _status;
  dynamic get createdAt => _createdAt;
  dynamic get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['rule_name'] = _name;
    map['status'] = _status;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }
}
