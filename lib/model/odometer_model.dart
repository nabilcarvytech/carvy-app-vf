class Odometer {
  num? _status;
  String? _message;
  Data? _data;
  String? _error;

  Odometer({
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

  Odometer.fromJson(dynamic json) {
    _status =
        json['status'] is int ? json['status'] : int.tryParse(json['status']);
    _message = json['message'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
    _error = json['error'];
  }

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

// Rest of your classes remain the same

class Data {
  Data({
    List<Getodometer>? odometerList,
  }) {
    _odometerList = odometerList;
  }

  Data.fromJson(dynamic json) {
    try {
      if (json['getodometer'] != null) {
        _odometerList = [];
        json['getodometer'].forEach((v) {
          try {
            _odometerList?.add(Getodometer.fromJson(v));
          } catch (e) {
//
          }
        });
      }
    } catch (e) {
//
    }
  }
  List<Getodometer>? _odometerList;
  List<Getodometer>? get odometerList => _odometerList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_odometerList != null) {
      map['getodometer'] = _odometerList?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Getodometer {
  Getodometer({
    String? id,
    String? odometerSpeed,
  }) {
    _id = id;
    _odometerSpeed = odometerSpeed;
  }

  Getodometer.fromJson(dynamic json) {
    // MongoDB peut envoyer _id en String (ObjectId), donc on force String.
    _id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    _odometerSpeed =
        json['odometer']?.toString() ??
        json['odometerSpeed']?.toString() ??
        json['name']?.toString() ??
        '';
  }

  String? _id;
  String? _odometerSpeed;

  String? get id => _id;
  String? get name => _odometerSpeed;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['odometer'] = _odometerSpeed;

    return map;
  }
}
