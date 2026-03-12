class MyItemsModel {
  MyItemsModel({
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

  MyItemsModel.fromJson(dynamic json) {
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
    List<Items>? items,
    Items? itemsInfo,
    num? offset,
    String? limit,
    dynamic hoststatus,
  }) {
   _items = items;
    _offset = offset;
    _limit = limit;
    _hoststatus = hoststatus;
    _itemsInfo = itemsInfo;
  }

  Data.fromJson(dynamic json) {
    if (json['items'] != null) {
      _items = [];
      json['items'].forEach((v) {
        _items?.add(Items.fromJson(v));
      });
    }

    _offset = json['offset'];
    _limit = json['limit'];
    _hoststatus = json['host_status'];
  }
  List<Items>? _items;
  num? _offset;
  dynamic _limit;
  dynamic _hoststatus;
  Items? _itemsInfo;

  Items? get itemsInfo => _itemsInfo;
  List<Items>? get items => _items;

  num? get offset => _offset;
  dynamic get limit => _limit;
  dynamic get hoststatus => _hoststatus;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_items != null) {
      map['items'] = _items?.map((v) => v.toJson()).toList();
    }
    if (_itemsInfo != null) {
      map['items'] = _itemsInfo?.toJson();
    }
    map['offset'] = _offset;
    map['limit'] = _limit;
    map['host_status'] = _hoststatus;
    return map;
  }
}

class Items {
  Items({
    String? id,
    String? title,
    String? description,
    // String? bedrooms,
    // String? beds,
    // String? bathroom,
    // String? itemSqft,
    String? itemRating,
    String? mobile,
    String? status,
    String? personAllowed,
    String? price,
    String? address,
    String? stateRegion,
    String? zipPostalCode,
    String? city,
    String? country,
    String? latitude,
    String? longitude,
    String? weeklyDiscount,
    String? weeklyDiscountType,
    String? monthlyDiscount,
    String? monthlyDiscountType,
    String? itemTypeId,
    String? amenitiesId,
    String? placeId,
    int? bookingPoliciesId,
    String? itemType,
    FrontImage? frontImage,
    FrontImageDoc? frontImageDocs,
    List<Gallery>? gallery,
    String? availableDates,
    dynamic notAvailableDates,
    List<BookedDates>? bookedDates,
    String? metaData,
    String? itemInfo,

  }) {
    _id = id;
    _title = title;
    _description = description;
    // _bedrooms = bedrooms;

    // _beds = beds;
    // _bathroom = bathroom;
    // _itemSqft = itemSqft;
    _itemRating = itemRating;
    _mobile = mobile;
    _status = status;
    _personAllowed = personAllowed;
    _price = price;
    _address = address;
    _stateRegion = stateRegion;
    _zipPostalCode = zipPostalCode;
    _city = city;
    _country = country;
    _latitude = latitude;
    _longitude = longitude;
    _weeklyDiscount = weeklyDiscount;
    _weeklyDiscountType = weeklyDiscountType;
    _monthlyDiscount = monthlyDiscount;
    _monthlyDiscountType = monthlyDiscountType;
    _itemTypeId = itemTypeId;
    _amenitiesId = amenitiesId;
    _placeId = placeId;
    _bookingPoliciesId = bookingPoliciesId;
    _itemType = itemType;
    _frontImage = frontImage;
    _frontImageDoc = frontImageDoc;
    _gallery = gallery;
    _availableDates = availableDates;
    _notAvailableDates = notAvailableDates;
    _bookedDates = bookedDates;
    _metaData = metaData;
    _itemInfo = itemInfo;

  }

  Items.fromJson(dynamic json) {
    // FIX DU PARSING : Rendre tous les champs optionnels pour éviter les crashes si un champ est null
    // Gérer à la fois 'id' et '_id' (MongoDB utilise '_id' par défaut)
    // Priorité: _id (MongoDB) > id (standard) > chaîne vide
    _id = json['_id']?.toString() ?? json['id']?.toString() ?? "";
    _title = json['title']?.toString();
    _description = json['description']?.toString();
    // _bedrooms = json['bedrooms']?.toString();
    // _beds = json['beds']?.toString();
    // _bathroom = json['bathroom']?.toString();
    // _itemSqft = json['item_sqft']?.toString();
    _itemRating = json['item_rating']?.toString();
    _mobile = json['mobile']?.toString();
    _status = json['status']?.toString();
    _personAllowed = json['person_allowed']?.toString();
    _price = json['price']?.toString();
    _address = json['address']?.toString();
    _stateRegion = json['state_region']?.toString();
    _zipPostalCode = json['zip_postal_code']?.toString();
    _city = json['city_name']?.toString();
    _country = json['country']?.toString();
    _latitude = json['latitude']?.toString();
    _longitude = json['longitude']?.toString();
    _weeklyDiscount = json['weekly_discount']?.toString();
    _weeklyDiscountType = json['weekly_discount_type']?.toString();
    _monthlyDiscount = json['monthly_discount']?.toString();
    _monthlyDiscountType = json['monthly_discount_type']?.toString();
    _itemTypeId = json['item_type_id']?.toString();
    _amenitiesId = json['features_id']?.toString();
    _placeId = json['place_id']?.toString();
    _itemInfo = json['item_info']?.toString();

    _bookingPoliciesId = json['booking_policies_id'] is num ? json['booking_policies_id'] : null;
    _itemType = json['item_type']?.toString();
    _frontImage = json['front_image'] != null
        ? FrontImage.fromJson(json['front_image'])
        : null;
    _frontImageDoc = json['front_image_doc'] != null
        ? FrontImageDoc.fromJson(json['front_image_doc'])
        : null;

    if (json['gallery'] != null && json['gallery'] is List) {
      _gallery = [];
      json['gallery'].forEach((v) {
        try {
          _gallery?.add(Gallery.fromJson(v));
        } catch (e) {
          // Ignorer les éléments de galerie invalides
        }
      });
    } else {
      _gallery = null;
    }
    _availableDates = json['available_dates']?.toString();

    _notAvailableDates = json['not_available_dates'];

    if (json['booked_dates'] != null && json['booked_dates'] is List) {
      _bookedDates = [];
      json['booked_dates'].forEach((v) {
        try {
          _bookedDates?.add(BookedDates.fromJson(v));
        } catch (e) {
          // Ignorer les dates réservées invalides
        }
      });
    } else {
      _bookedDates = null;
    }
    _metaData = json['metaData'] is String ? json['metaData'] : null;
  }
  String? _id;
  String? _title;
  String? _description;
  // String? _bedrooms;
  // String? _beds;
  // String? _bathroom;
  // String? _itemSqft;
  String? _itemRating;
  String? _mobile;
  String? _status;
  String? _personAllowed;
  String? _price;
  String? _address;
  String? _stateRegion;
  String? _city;
  String? _zipPostalCode;
  String? _country;
  String? _latitude;
  String? _longitude;
  String? _weeklyDiscount;
  String? _weeklyDiscountType;
  String? _monthlyDiscount;
  String? _itemInfo;
  String? _monthlyDiscountType;
  String? _itemTypeId;
  String? _amenitiesId;
  String? _placeId;
  int? _bookingPoliciesId;
  String? _itemType;
  FrontImage? _frontImage;
  FrontImageDoc? _frontImageDoc;
  List<Gallery>? _gallery;
  String? _availableDates;
  dynamic _notAvailableDates;
  List<BookedDates>? _bookedDates;
  String? _metaData;

  String? get id => _id;
  String? get title => _title;
  String? get description => _description;
  // String? get bedrooms => _bedrooms;
  // String? get beds => _beds;
  // String? get bathroom => _bathroom;
  // String? get itemSqft => _itemSqft;
  String? get itemRating => _itemRating;
  String? get mobile => _mobile;
  String? get status => _status;
  set status(String? value) {
    _status = value;
  }

  String? get personAllowed => _personAllowed;
  String? get price => _price;
  String? get address => _address;
  String? get stateRegion => _stateRegion;
  String? get zipPostalCode => _zipPostalCode;
  String? get city => _city;
  String? get country => _country;
  String? get latitude => _latitude;
  String? get longitude => _longitude;
  String? get weeklyDiscount => _weeklyDiscount;
  String? get weeklyDiscountType => _weeklyDiscountType;
  String? get monthlyDiscount => _monthlyDiscount;
  String? get monthlyDiscountType => _monthlyDiscountType;
  String? get itemInfo => _itemInfo;
  String? get itemTypeId => _itemTypeId;
  String? get amenitiesId => _amenitiesId;
  String? get placeId => _placeId;
  int? get bookingPoliciesId => _bookingPoliciesId;
  String? get itemType => _itemType;
  FrontImage? get frontImage => _frontImage;
  FrontImageDoc? get frontImageDoc => _frontImageDoc;
  List<Gallery>? get gallery => _gallery;
  String? get availableDates => _availableDates;
  dynamic get notAvailableDates => _notAvailableDates;
  List<BookedDates>? get bookedDates => _bookedDates;
  String? get metaData => _metaData;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['title'] = _title;
    map['description'] = _description;
    // map['bedrooms'] = _bedrooms;
    // map['beds'] = _beds;
    // map['bathroom'] = _bathroom;
    // map['item_sqft'] = _itemSqft;
    map['item_rating'] = _itemRating;
    map['mobile'] = _mobile;
    map['status'] = _status;
    map['person_allowed'] = _personAllowed;
    map['price'] = _price;
    map['address'] = _address;
    map['state_region'] = _stateRegion;
    map['zip_postal_code'] = _zipPostalCode;
    map['city_name'] = _city;
    map['country'] = _country;
    map['latitude'] = _latitude;
    map['longitude'] = _longitude;
    map['weekly_discount'] = _weeklyDiscount;
    map['weekly_discount_type'] = _weeklyDiscountType;
    map['monthly_discount'] = _monthlyDiscount;
    map['monthly_discount_type'] = _monthlyDiscountType;
    map['item_type_id'] = _itemTypeId;
    map['features_id'] = _amenitiesId;
    map['place_id'] = _placeId;
    map['booking_policies_id'] = _bookingPoliciesId;
    map['item_type'] = _itemType;
    map['item_info'] = _itemInfo;
    if (_frontImage != null) {
      map['front_image'] = _frontImage?.toJson();
    }

    if (_frontImageDoc != null) {
      map['front_image_doc'] = _frontImageDoc?.toJson();
    }
    if (_gallery != null) {
      map['gallery'] = _gallery?.map((v) => v.toJson()).toList();
    }
    map['available_dates'] = _availableDates;
    map['not_available_dates'] = _notAvailableDates;
    if (_bookedDates != null) {
      map['booked_dates'] = _bookedDates?.map((v) => v.toJson()).toList();
    }
    if (_metaData != null) {
      map['metaData'] = _metaData;
    }

    return map;
  }
}







class Gallery {
  Gallery({
    String? id,
    String? modelType,
    // num? modelId,
    dynamic modelId,
    String? uuid,
    String? collectionName,
    String? name,
    String? fileName,
    String? mimeType,
    String? disk,
    String? conversionsDisk,
    dynamic size,
    dynamic orderColumn,
    String? createdAt,
    String? updatedAt,
    String? url,
    String? thumbnail,
    String? preview,
    String? originalUrl,
    String? previewUrl,
  }) {
    _id = id;
    _modelType = modelType;
    _modelId = modelId;
    _uuid = uuid;
    _collectionName = collectionName;
    _name = name;
    _fileName = fileName;
    _mimeType = mimeType;
    _disk = disk;
    _conversionsDisk = conversionsDisk;
    _size = size;
    _orderColumn = orderColumn;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _url = url;
    _thumbnail = thumbnail;
    _preview = preview;
    _originalUrl = originalUrl;
    _previewUrl = previewUrl;
  }

  Gallery.fromJson(dynamic json) {
    // Gérer à la fois 'id' et '_id' (MongoDB utilise '_id' par défaut)
    _id = json['id']?.toString() ?? json['_id']?.toString();
    _modelType = json['model_type'];
    _modelId = json['model_id'];
    _uuid = json['uuid'];
    _collectionName = json['collection_name'];
    _name = json['name'];
    _fileName = json['file_name'];
    _mimeType = json['mime_type'];
    _disk = json['disk'];
    _conversionsDisk = json['conversions_disk'];
    _size = json['size'];
    _orderColumn = json['order_column'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _url = json['url'];
    _thumbnail = json['thumbnail'];
    _preview = json['preview'];
    _originalUrl = json['original_url'];
    _previewUrl = json['preview_url'];
  }
  String? _id;
  String? _modelType;
  dynamic _modelId;
  String? _uuid;
  String? _collectionName;
  String? _name;
  String? _fileName;
  String? _mimeType;
  String? _disk;
  String? _conversionsDisk;
  dynamic _size;
  List<dynamic>? _manipulations;
  List<dynamic>? _customitems;
  List<dynamic>? _responsiveImages;
  dynamic _orderColumn;
  String? _createdAt;
  String? _updatedAt;
  String? _url;
  String? _thumbnail;
  String? _preview;
  String? _originalUrl;
  String? _previewUrl;

  String? get id => _id;
  String? get modelType => _modelType;
  dynamic get modelId => _modelId;
  String? get uuid => _uuid;
  String? get collectionName => _collectionName;
  String? get name => _name;
  String? get fileName => _fileName;
  String? get mimeType => _mimeType;
  String? get disk => _disk;
  String? get conversionsDisk => _conversionsDisk;
  dynamic get size => _size;
  List<dynamic>? get manipulations => _manipulations;
  List<dynamic>? get customitems => _customitems;
  List<dynamic>? get responsiveImages => _responsiveImages;

  dynamic get orderColumn => _orderColumn;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  String? get url => _url;
  String? get thumbnail => _thumbnail;

  String? get preview => _preview;
  String? get originalUrl => _originalUrl;
  String? get previewUrl => _previewUrl;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['model_type'] = _modelType;
    map['model_id'] = _modelId;
    map['uuid'] = _uuid;
    map['collection_name'] = _collectionName;
    map['name'] = _name;
    map['file_name'] = _fileName;
    map['mime_type'] = _mimeType;
    map['disk'] = _disk;
    map['conversions_disk'] = _conversionsDisk;
    map['size'] = _size;
    if (_manipulations != null) {
      map['manipulations'] = _manipulations?.map((v) => v.toJson()).toList();
    }
    if (_customitems != null) {
      map['custom_items'] =
          _customitems?.map((v) => v.toJson()).toList();
    }
    if (_responsiveImages != null) {
      map['responsive_images'] =
          _responsiveImages?.map((v) => v.toJson()).toList();
    }
    map['order_column'] = _orderColumn;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    map['url'] = _url;
    map['thumbnail'] = _thumbnail;
    map['preview'] = _preview;
    map['original_url'] = _originalUrl;
    map['preview_url'] = _previewUrl;
    return map;
  }
}

class FrontImage {
  FrontImage({
    String? id,
    dynamic modelType,
    // num? modelId,
    dynamic modelId,
    String? uuid,
    String? collectionName,
    String? name,
    String? fileName,
    String? mimeType,
    String? disk,
    String? conversionsDisk,
    // num? size,
    dynamic size,
    List<dynamic>? manipulations,
    List<dynamic>? customitems,
    List<dynamic>? responsiveImages,
    // num? orderColumn,
    dynamic orderColumn,
    String? createdAt,
    String? updatedAt,
    String? url,
    String? thumbnail,
    // num? thumbnail,
    String? preview,
    String? originalUrl,
    String? previewUrl,
  }) {
    _id = id;
    _modelType = modelType;
    _modelId = modelId;
    _uuid = uuid;
    _collectionName = collectionName;
    _name = name;
    _fileName = fileName;
    _mimeType = mimeType;
    _disk = disk;
    _conversionsDisk = conversionsDisk;
    _size = size;
    _manipulations = manipulations;
    _customitems = customitems;
    _responsiveImages = responsiveImages;
    _orderColumn = orderColumn;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _url = url;
    _thumbnail = thumbnail;
    _preview = preview;
    _originalUrl = originalUrl;
    _previewUrl = previewUrl;
  }

  FrontImage.fromJson(dynamic json) {
    // Gérer à la fois 'id' et '_id' (MongoDB utilise '_id' par défaut)
    _id = json['id']?.toString() ?? json['_id']?.toString();
    _modelType = json['model_type'].toString();
    _modelId = json['model_id'].toString();
    _uuid = json['uuid'];
    _collectionName = json['collection_name'];
    _name = json['name'];
    _fileName = json['file_name'];
    _mimeType = json['mime_type'];
    _disk = json['disk'];
    _conversionsDisk = json['conversions_disk'];
    _size = json['size'].toString();
    _orderColumn = json['order_column'].toString();
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _url = json['url'];
    _thumbnail = json['thumbnail'];
    _preview = json['preview'];
    _originalUrl = json['original_url'];
    _previewUrl = json['preview_url'];
  }
  String? _id;
  dynamic _modelType;
  // num? _modelId;
  dynamic _modelId;
  String? _uuid;
  String? _collectionName;
  String? _name;
  String? _fileName;
  String? _mimeType;
  String? _disk;
  String? _conversionsDisk;
  // num? _size;
  dynamic _size;
  List<dynamic>? _manipulations;
  List<dynamic>? _customitems;
  List<dynamic>? _responsiveImages;
  // num? _orderColumn;
  dynamic _orderColumn;
  String? _createdAt;
  String? _updatedAt;
  String? _url;
  String? _thumbnail;
  // num? _thumbnail;
  String? _preview;
  String? _originalUrl;
  String? _previewUrl;

  String? get id => _id;
  dynamic get modelType => _modelType;

  dynamic get modelId => _modelId;
  String? get uuid => _uuid;
  String? get collectionName => _collectionName;
  String? get name => _name;
  String? get fileName => _fileName;
  String? get mimeType => _mimeType;
  String? get disk => _disk;
  String? get conversionsDisk => _conversionsDisk;
  dynamic get size => _size;
  List<dynamic>? get manipulations => _manipulations;
  List<dynamic>? get customitems => _customitems;
  List<dynamic>? get responsiveImages => _responsiveImages;
  dynamic get orderColumn => _orderColumn;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  String? get url => _url;
  String? get thumbnail => _thumbnail;
  String? get preview => _preview;
  String? get originalUrl => _originalUrl;
  String? get previewUrl => _previewUrl;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['model_type'] = _modelType;
    map['model_id'] = _modelId;
    map['uuid'] = _uuid;
    map['collection_name'] = _collectionName;
    map['name'] = _name;
    map['file_name'] = _fileName;
    map['mime_type'] = _mimeType;
    map['disk'] = _disk;
    map['conversions_disk'] = _conversionsDisk;
    map['size'] = _size;
    if (_manipulations != null) {
      map['manipulations'] = _manipulations?.map((v) => v.toJson()).toList();
    }
    if (_customitems != null) {
      map['custom_items'] =
          _customitems?.map((v) => v.toJson()).toList();
    }
    if (_responsiveImages != null) {
      map['responsive_images'] =
          _responsiveImages?.map((v) => v.toJson()).toList();
    }
    map['order_column'] = _orderColumn;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    map['url'] = _url;
    map['thumbnail'] = _thumbnail;
    map['preview'] = _preview;
    map['original_url'] = _originalUrl;
    map['preview_url'] = _previewUrl;
    return map;
  }
}

class FrontImageDoc {
  FrontImageDoc({
    String? id,
    dynamic modelType,
    // num? modelId,
    dynamic modelId,
    String? uuid,
    String? collectionName,
    String? name,
    String? fileName,
    String? mimeType,
    String? disk,
    String? conversionsDisk,
    // num? size,
    dynamic size,
    List<dynamic>? manipulations,
    List<dynamic>? customitems,
    List<dynamic>? responsiveImages,
    // num? orderColumn,
    dynamic orderColumn,
    String? createdAt,
    String? updatedAt,
    String? url,
    String? thumbnail,
    // num? thumbnail,
    String? preview,
    String? originalUrl,
    String? previewUrl,
  }) {
    _id = id;
    _modelType = modelType;
    _modelId = modelId;
    _uuid = uuid;
    _collectionName = collectionName;
    _name = name;
    _fileName = fileName;
    _mimeType = mimeType;
    _disk = disk;
    _conversionsDisk = conversionsDisk;
    _size = size;
    _manipulations = manipulations;
    _customitems = customitems;
    _responsiveImages = responsiveImages;
    _orderColumn = orderColumn;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _url = url;
    _thumbnail = thumbnail;
    _preview = preview;
    _originalUrl = originalUrl;
    _previewUrl = previewUrl;
  }

  FrontImageDoc.fromJson(dynamic json) {
    // Gérer à la fois 'id' et '_id' (MongoDB utilise '_id' par défaut)
    _id = json['id']?.toString() ?? json['_id']?.toString();
    _modelType = json['model_type'].toString();
    _modelId = json['model_id'].toString();
    _uuid = json['uuid'];
    _collectionName = json['collection_name'];
    _name = json['name'];
    _fileName = json['file_name'];
    _mimeType = json['mime_type'];
    _disk = json['disk'];
    _conversionsDisk = json['conversions_disk'];
    _size = json['size'].toString();
    _orderColumn = json['order_column'].toString();
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _url = json['url'];
    _thumbnail = json['thumbnail'];
    _preview = json['preview'];
    _originalUrl = json['original_url'];
    _previewUrl = json['preview_url'];
  }
  String? _id;
  dynamic _modelType;
  // num? _modelId;
  dynamic _modelId;
  String? _uuid;
  String? _collectionName;
  String? _name;
  String? _fileName;
  String? _mimeType;
  String? _disk;
  String? _conversionsDisk;
  // num? _size;
  dynamic _size;
  List<dynamic>? _manipulations;
  List<dynamic>? _customitems;
  List<dynamic>? _responsiveImages;
  // num? _orderColumn;
  dynamic _orderColumn;
  String? _createdAt;
  String? _updatedAt;
  String? _url;
  String? _thumbnail;
  // num? _thumbnail;
  String? _preview;
  String? _originalUrl;
  String? _previewUrl;

  String? get id => _id;
  dynamic get modelType => _modelType;

  dynamic get modelId => _modelId;
  String? get uuid => _uuid;
  String? get collectionName => _collectionName;
  String? get name => _name;
  String? get fileName => _fileName;
  String? get mimeType => _mimeType;
  String? get disk => _disk;
  String? get conversionsDisk => _conversionsDisk;
  dynamic get size => _size;
  List<dynamic>? get manipulations => _manipulations;
  List<dynamic>? get customitems => _customitems;
  List<dynamic>? get responsiveImages => _responsiveImages;
  dynamic get orderColumn => _orderColumn;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  String? get url => _url;
  String? get thumbnail => _thumbnail;
  String? get preview => _preview;
  String? get originalUrl => _originalUrl;
  String? get previewUrl => _previewUrl;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['model_type'] = _modelType;
    map['model_id'] = _modelId;
    map['uuid'] = _uuid;
    map['collection_name'] = _collectionName;
    map['name'] = _name;
    map['file_name'] = _fileName;
    map['mime_type'] = _mimeType;
    map['disk'] = _disk;
    map['conversions_disk'] = _conversionsDisk;
    map['size'] = _size;
    if (_manipulations != null) {
      map['manipulations'] = _manipulations?.map((v) => v.toJson()).toList();
    }
    if (_customitems != null) {
      map['custom_items'] =
          _customitems?.map((v) => v.toJson()).toList();
    }
    if (_responsiveImages != null) {
      map['responsive_images'] =
          _responsiveImages?.map((v) => v.toJson()).toList();
    }
    map['order_column'] = _orderColumn;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    map['url'] = _url;
    map['thumbnail'] = _thumbnail;
    map['preview'] = _preview;
    map['original_url'] = _originalUrl;
    map['preview_url'] = _previewUrl;
    return map;
  }
}

class NotAvailableDates {
  NotAvailableDates({
    String? date,
    String? price,
  }) {
    _date = date;
    _price = price;
  }

  NotAvailableDates.fromJson(dynamic json) {
    _date = json['date'];
    _price = json['price'];
  }
  String? _date;
  String? _price;
  NotAvailableDates copyWith({
    String? date,
    String? price,
  }) =>
      NotAvailableDates(
        date: date ?? _date,
        price: price ?? _price,
      );
  String? get date => _date;
  String? get price => _price;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['date'] = _date;
    map['price'] = _price;
    return map;
  }
}

class BookedDates {
  BookedDates({
    String? date,
    String? price,
  }) {
    _date = date;
    _price = price;
  }

  BookedDates.fromJson(dynamic json) {
    _date = json['date'];
    _price = json['price'];
  }
  String? _date;
  String? _price;
  BookedDates copyWith({
    String? date,
    String? price,
  }) =>
      BookedDates(
        date: date ?? _date,
        price: price ?? _price,
      );
  String? get date => _date;
  String? get price => _price;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['date'] = _date;
    map['price'] = _price;
    return map;
  }
}
