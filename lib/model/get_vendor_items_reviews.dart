
class GetVendorItemsReviews {
  GetVendorItemsReviews({
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

  GetVendorItemsReviews.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
    _error = json['error'];
  }

  num? _status;
  String? _message;
  Data? _data;
  String? _error;

  GetVendorItemsReviews copyWith({
    num? status,
    String? message,
    Data? data,
    String? error,
  }) =>
      GetVendorItemsReviews(
        status: status ?? _status,
        message: message ?? _message,
        data: data ?? _data,
        error: error ?? _error,
      );

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
    List<Reviews>? reviews,
    num? offset,
  }) {
    _reviews = reviews;
    _offset = offset;
  }

  Data.fromJson(dynamic json) {
    if (json['reviews'] != null) {
      _reviews = [];
      json['reviews'].forEach((v) {
        _reviews?.add(Reviews.fromJson(v));
      });
    }
    _offset = json['offset'];
  }

  List<Reviews>? _reviews;
  num? _offset;

  Data copyWith({
    List<Reviews>? reviews,
    num? offset,
  }) =>
      Data(
        reviews: reviews ?? _reviews,
        offset: offset ?? _offset,
      );

  List<Reviews>? get reviews => _reviews;
  num? get offset => _offset;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_reviews != null) {
      map['reviews'] = _reviews?.map((v) => v.toJson()).toList();
    }
    map['offset'] = _offset;
    return map;
  }
}

class Reviews {
  Reviews({
    String? itemId,
    String? itemName,
    GuestResponse? guestResponse,
    HostResponse? hostResponse,
    String? createdAt,
  }) {
    _itemId = itemId;
    _itemName = itemName;
    _guestResponse = guestResponse;
    _hostResponse = hostResponse;
    _createdAt = createdAt;
  }

  Reviews.fromJson(dynamic json) {
    _itemId = json['item_id'];
    _itemName = json['item_name'];
    _guestResponse = json['guest_response'] != null
        ? GuestResponse.fromJson(json['guest_response'])
        : null;
    _hostResponse = json['host_response'] != null
        ? HostResponse.fromJson(json['host_response'])
        : null;
    _createdAt = json['created_at'];
  }

  String? _itemId;
  String? _itemName;
  GuestResponse? _guestResponse;
  HostResponse? _hostResponse;
  String? _createdAt;

  Reviews copyWith({
    String? itemId,
    String? itemName,
    GuestResponse? guestResponse,
    HostResponse? hostResponse,
    String? createdAt,
  }) =>
      Reviews(
        itemId: itemId ?? _itemId,
        itemName: itemName ?? _itemName,
        guestResponse: guestResponse ?? _guestResponse,
        hostResponse: hostResponse ?? _hostResponse,
        createdAt: createdAt ?? _createdAt,
      );

  String? get itemId => _itemId;
  String? get itemName => _itemName;
  GuestResponse? get guestResponse => _guestResponse;
  HostResponse? get hostResponse => _hostResponse;
  String? get createdAt => _createdAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['item_id'] = _itemId;
    map['item_name'] = _itemName;
    if (_guestResponse != null) {
      map['guest_response'] = _guestResponse?.toJson();
    }
    if (_hostResponse != null) {
      map['host_response'] = _hostResponse?.toJson();
    }
    map['created_at'] = _createdAt;
    return map;
  }
}

class HostResponse {
  HostResponse({
    dynamic hostName,
    String? hostRating,
    dynamic hostMessage,
    String? hostProfile,
    String? hostId,
  }) {
    _hostName = hostName;
    _hostRating = hostRating;
    _hostMessage = hostMessage;
    _hostProfile = hostProfile;
    _hostId = hostId;
  }

  HostResponse.fromJson(dynamic json) {
    _hostName = json['host_name'];
    _hostRating = json['host_rating'];
    _hostMessage = json['host_message'];
    _hostProfile = json['host_profile'];
    _hostId = json['host_id'];
  }

  dynamic _hostName;
  String? _hostRating;
  dynamic _hostMessage;
  String? _hostProfile;
  String? _hostId;

  HostResponse copyWith({
    dynamic hostName,
    String? hostRating,
    dynamic hostMessage,
    String? hostProfile,
    String? hostId,
  }) =>
      HostResponse(
        hostName: hostName ?? _hostName,
        hostRating: hostRating ?? _hostRating,
        hostMessage: hostMessage ?? _hostMessage,
        hostProfile: hostProfile ?? _hostProfile,
        hostId: hostId ?? _hostId,
      );

  dynamic get hostName => _hostName;
  String? get hostRating => _hostRating;
  dynamic get hostMessage => _hostMessage;
  String? get hostProfile => _hostProfile;
  String? get hostId => _hostId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['host_name'] = _hostName;
    map['host_rating'] = _hostRating;
    map['host_message'] = _hostMessage;
    map['host_profile'] = _hostProfile;
    map['host_id'] = _hostId;
    return map;
  }
}

class GuestResponse {
  GuestResponse({
    dynamic guestName,
    String? guestRating,
    String? guestMessage,
    String? guestProfile,
    String? guestId,
  }) {
    _guestName = guestName;
    _guestRating = guestRating;
    _guestMessage = guestMessage;
    _guestProfile = guestProfile;
    _guestId = guestId;
  }

  GuestResponse.fromJson(dynamic json) {
    _guestName = json['guest_name'];
    _guestRating = json['guest_rating'];
    _guestMessage = json['guest_message'];
    _guestProfile = json['guest_profile'];
    _guestId = json['guest_id'];
  }

  dynamic _guestName;
  String? _guestRating;
  String? _guestMessage;
  String? _guestProfile;
  String? _guestId;

  GuestResponse copyWith({
    dynamic guestName,
    String? guestRating,
    String? guestMessage,
    String? guestProfile,
    String? guestId,
  }) =>
      GuestResponse(
        guestName: guestName ?? _guestName,
        guestRating: guestRating ?? _guestRating,
        guestMessage: guestMessage ?? _guestMessage,
        guestProfile: guestProfile ?? _guestProfile,
        guestId: guestId ?? _guestId,
      );

  dynamic get guestName => _guestName;
  String? get guestRating => _guestRating;
  String? get guestMessage => _guestMessage;
  String? get guestProfile => _guestProfile;
  String? get guestId => _guestId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['guest_name'] = _guestName;
    map['guest_rating'] = _guestRating;
    map['guest_message'] = _guestMessage;
    map['guest_profile'] = _guestProfile;
    map['guest_id'] = _guestId;
    return map;
  }
}
