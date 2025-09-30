class ItemModel {
  num? _status;
  String? _message;
  Data? _data;
  String? _error;

  ItemModel({
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

  ItemModel.fromJson(dynamic json) {
    _status = json['status'];
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

class Data {
  List<Items>? _items;
  num? _offset;

  Data({
    List<Items>? items,
    num? offset,
  }) {
    _items = items;
    _offset = offset;
  }
  Data.fromJson(dynamic json) {
    if (json['items'] != null) {
      _items = [];

      if (json['items'] is List) {
        json['items'].forEach((v) {
          _items?.add(Items.fromJson(v));
        });
      } else if (json['items'] is Map<String, dynamic>) {
        json['items'].forEach((key, value) {
          _items?.add(Items.fromJson(value));
        });
      }
    }
    _offset = json['offset'];
  }

  List<Items>? get items => _items;
  num? get offset => _offset;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_items != null) {
      map['items'] = _items?.map((v) => v.toJson()).toList();
    }
    map['offset'] = _offset;
    return map;
  }
}

class Items {
  num? _id;
  String? _name;
  String? _itemRating;
  String? _mobile;
  String? _personAllowed;
  String? _address;
  String? _stateRegion;
  String? _city;
  String? _zipPostalCode;
  String? _price;
  String? _latitude;
  String? _longitude;
  String? _status;
  String? _itemTypeId;
  String? _image;
  String? _itemInfo;
  bool? _isInWishlist;
  String? _itemType;
  dynamic _distance;

  Items({
    num? id,
    String? name,
    String? itemRating,
    String? mobile,
    String? personAllowed,
    String? address,
    String? stateRegion,
    String? city,
    String? zipPostalCode,
    String? price,
    String? latitude,
    String? longitude,
    String? status,
    String? itemTypeId,
    String? image,
    String? itemInfo,
    bool? isInWishlist,
    String? itemType,
    dynamic distance,
  }) {
    _id = id;
    _name = name;
    _itemRating = itemRating;
    _mobile = mobile;
    _personAllowed = personAllowed;
    _address = address;
    _stateRegion = stateRegion;
    _city = city;
    _zipPostalCode = zipPostalCode;
    _price = price;
    _latitude = latitude;
    _longitude = longitude;
    _status = status;
    _itemTypeId = itemTypeId;
    _image = image;
    _itemInfo = itemInfo;
    _isInWishlist = isInWishlist;
    _itemType = itemType;
    _distance = distance;
  }

  Items.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _itemRating = json['item_rating'];
    _mobile = json['mobile'];
    _personAllowed = json['person_allowed'];
    _address = json['address'];
    _stateRegion = json['state_region'];
    _city = json['city'];
    _zipPostalCode = json['zip_postal_code'];
    _price = json['price'];
    _latitude = json['latitude'];
    _longitude = json['longitude'];
    _status = json['status'];
    _itemTypeId = json['item_type_id'];
    _image = json['image'];
    _itemInfo = json['item_info'];
    _isInWishlist = json['is_in_wishlist'];
    _itemType = json['item_type'];
    _distance = json['distance'];
  }

  num? get id => _id;
  String? get name => _name;
  String? get itemRating => _itemRating;
  String? get mobile => _mobile;
  String? get personAllowed => _personAllowed;
  String? get address => _address;
  String? get stateRegion => _stateRegion;
  String? get city => _city;
  String? get zipPostalCode => _zipPostalCode;
  String? get price => _price;
  String? get latitude => _latitude;
  String? get longitude => _longitude;
  String? get status => _status;
  String? get itemTypeId => _itemTypeId;
  String? get image => _image;
  String? get itemInfo => _itemInfo;
  bool? get isInWishlist => _isInWishlist;
  String? get itemType => _itemType;
  dynamic get distance => _distance;
  set wishlistSetter(bool value) {
    _isInWishlist = value;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['item_rating'] = _itemRating;
    map['mobile'] = _mobile;
    map['person_allowed'] = _personAllowed;
    map['address'] = _address;
    map['state_region'] = _stateRegion;
    map['city'] = _city;
    map['zip_postal_code'] = _zipPostalCode;
    map['price'] = _price;
    map['latitude'] = _latitude;
    map['longitude'] = _longitude;
    map['status'] = _status;
    map['item_type_id'] = _itemTypeId;
    map['image'] = _image;
    map['item_info'] = _itemInfo;
    map['is_in_wishlist'] = _isInWishlist;
    map['item_type'] = _itemType;
    map['distance'] = _distance;
    return map;
  }
}
