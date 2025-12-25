

class ItemDetailsModel {
  ItemDetailsModel({
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

  ItemDetailsModel.fromJson(dynamic json) {
    // status peut être num ou String, parsing sécurisé
    _status = json['status'] is num 
        ? json['status'] 
        : (json['status'] != null ? num.tryParse(json['status'].toString()) : null);
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
    ItemDetails? itemDetails,
  }) {
    _itemDetails = itemDetails;
  }

  Data.fromJson(dynamic json) {
    _itemDetails = json['ItemDetails'] != null
        ? ItemDetails.fromJson(json['ItemDetails'])
        : null;
  }
  ItemDetails? _itemDetails;

  ItemDetails? get itemDetails => _itemDetails;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_itemDetails != null) {
      map['ItemDetails'] = _itemDetails?.toJson();
    }
    return map;
  }
}

class ItemDetails {
  ItemDetails(
      {String? itemId,
      String? title,
      String? price,
      String? description,
      String? bedrooms,
      String? beds,
      String? bathroom,
      String? itemqft,
      String? itemRating,
      String? mobile,
      String? status,
      String? personAllowed,
      String? address,
      String? stateRegion,
      String? zipPostalCode,
      String? latitude,
      String? longitude,
      String? isVerified,
      String? isFeatured,
      String? weeklyDiscount,
      String? weeklyDiscountType,
      String? monthlyDiscount,
      String? monthlyDiscountType,
      String? itemType,
      dynamic cancellationReason,
      String? bedType,
      String? city,
      List<Amenities>? amenities,
      List<AvailableDates>? availableDates,
      String? hostId,
      String? hostPlayerId,
      String? hostFirstName,
      String? hostLastName,
      String? hostEmail,
      String? hostPhone,
      String? hostProfileImage,
      String? frontImageUrl,
      List<String>? galleryImageUrls,
      List<Reviews>? reviews,
      num? totalReviews,
      String? itemData,
      String? itemInfo,
      bool? isInWishlist,
      List<String>? vehicleRules,
      List<String>? cancellationRules,
      String? depositValue,
      String? depositManager}) {
    _itemId = itemId;
    _title = title;
    _price = price;
    _description = description;
    _bedrooms = bedrooms;
    _beds = beds;
    _bathroom = bathroom;
    _itemqft = itemqft;
    _itemRating = itemRating;
    _mobile = mobile;
    _status = status;
    _personAllowed = personAllowed;
    _address = address;
    _stateRegion = stateRegion;
    _zipPostalCode = zipPostalCode;
    _latitude = latitude;
    _longitude = longitude;
    _isVerified = isVerified;
    _isFeatured = isFeatured;
    _weeklyDiscount = weeklyDiscount;
    _weeklyDiscountType = weeklyDiscountType;
    _monthlyDiscount = monthlyDiscount;
    _monthlyDiscountType = monthlyDiscountType;
    _itemType = itemType;
    _cancellationReason = cancellationReason;
    _bedType = bedType;
    _city = city;
    _amenities = amenities;
    _availableDates = availableDates;
    _hostId = hostId;
    _hostPlayerId = hostPlayerId;
    _hostFirstName = hostFirstName;
    _hostLastName = hostLastName;
    _hostEmail = hostEmail;
    _hostPhone = hostPhone;
    _hostProfileImage = hostProfileImage;
    _frontImageUrl = frontImageUrl;
    _galleryImageUrls = galleryImageUrls;
    _reviews = reviews;
    _totalReviews = totalReviews;
    _itemData = itemData;
    _isInWishlist = isInWishlist;
    _vehicleRules = vehicleRules;
    _cancellationRules = cancellationRules;
    _depositValue = depositValue;
    _depositManager = depositManager;
  }

  ItemDetails.fromJson(dynamic json) {
    // Gestion des IDs : conversion sécurisée en String
    _itemId = json['item_id']?.toString();
    
    // Champs String (déjà gérés, mais on s'assure qu'ils sont bien des String)
    _title = json['title']?.toString();
    _price = json['price']?.toString();
    _description = json['description']?.toString();
    _bedrooms = json['bedrooms']?.toString();
    _beds = json['beds']?.toString();
    _bathroom = json['bathroom']?.toString();
    _itemqft = json['item_sqft']?.toString();
    _itemRating = json['item_rating']?.toString();
    _mobile = json['mobile']?.toString();
    _status = json['status']?.toString();
    _personAllowed = json['person_allowed']?.toString();
    _address = json['address']?.toString();
    _stateRegion = json['state_region']?.toString();
    _zipPostalCode = json['zip_postal_code']?.toString();
    _latitude = json['latitude']?.toString();
    _longitude = json['longitude']?.toString();
    _isVerified = json['is_verified']?.toString();
    _isFeatured = json['is_featured']?.toString();
    _weeklyDiscount = json['weekly_discount']?.toString();
    _weeklyDiscountType = json['weekly_discount_type']?.toString();
    _monthlyDiscount = json['monthly_discount']?.toString();
    _monthlyDiscountType = json['monthly_discount_type']?.toString();
    _itemType = json['item_type']?.toString();
    _cancellationReason = json['cancellation_reason'];
    _bedType = json['bed_type']?.toString();
    _city = json['city']?.toString();
    if (json['amenities'] != null) {
      _amenities = [];
      json['amenities'].forEach((v) {
        _amenities?.add(Amenities.fromJson(v));
      });
    }
    if (json['available_dates'] != null) {
      _availableDates = [];
      json['available_dates'].forEach((v) {
        _availableDates?.add(AvailableDates.fromJson(v));
      });
    }
    // IDs des hôtes : conversion sécurisée en String
    _hostId = json['host_id']?.toString();
    _hostPlayerId = json['host_player_id']?.toString();

    // Informations hôte (String)
    _hostFirstName = json['host_first_name']?.toString();
    _hostLastName = json['host_last_name']?.toString();
    _hostEmail = json['host_email']?.toString();
    _hostPhone = json['host_phone']?.toString();
    _hostProfileImage = json['host_profile_image']?.toString();
    _frontImageUrl = json['front_image_url']?.toString();
    _galleryImageUrls = json['gallery_image_urls'] != null
        ? json['gallery_image_urls'].cast<String>()
        : [];
    if (json['reviews'] != null) {
      _reviews = [];
      json['reviews'].forEach((v) {
        _reviews?.add(Reviews.fromJson(v));
      });
    }
    // totalReviews : parsing sécurisé (peut être num ou String)
    _totalReviews = json['total_reviews'] != null 
        ? (json['total_reviews'] is num 
            ? json['total_reviews'] 
            : num.tryParse(json['total_reviews'].toString()))
        : null;
    
    _itemData = json['item_data']?.toString();
    _itemInfo = json['item_info'] is String ? json['item_info'] : null;
    _isInWishlist = json['is_in_wishlist'] is bool ? json['is_in_wishlist'] : (json['is_in_wishlist']?.toString().toLowerCase() == 'true');
    
    // Parsing vehicle_rules (peut être un tableau de strings ou un tableau d'objets)
    if (json['vehicle_rules'] != null && json['vehicle_rules'] is List) {
      _vehicleRules = (json['vehicle_rules'] as List).map<String>((rule) {
        // Si c'est une String, on la prend directement
        if (rule is String) {
          return rule;
        }
        // Si c'est un objet avec une propriété 'description' ou 'rule', on l'extrait
        else if (rule is Map) {
          return rule['description']?.toString() ?? 
                 rule['rule']?.toString() ?? 
                 rule.toString();
        }
        // Sinon, on convertit en String
        return rule.toString();
      }).toList();
    } else {
      _vehicleRules = [];
    }
    
    // Parsing cancellation_rules (tableau de strings simple, formaté par le backend)
    _cancellationRules = json['cancellation_rules'] != null && json['cancellation_rules'] is List
        ? List<String>.from(json['cancellation_rules'])
        : [];
    
    // Parsing deposit fields
    _depositValue = json['deposit_value']?.toString();
    _depositManager = json['deposit_manager']?.toString();
  }
  String? _itemId;
  String? _title;
  String? _price;
  String? _description;
  String? _bedrooms;
  String? _beds;
  String? _bathroom;
  String? _itemqft;
  String? _itemRating;
  String? _mobile;
  String? _status;
  String? _personAllowed;
  String? _address;
  String? _stateRegion;
  String? _zipPostalCode;
  String? _latitude;
  String? _longitude;
  String? _isVerified;
  String? _isFeatured;
  String? _weeklyDiscount;
  String? _weeklyDiscountType;
  String? _monthlyDiscount;
  String? _monthlyDiscountType;
  String? _itemType;
  dynamic _cancellationReason;
  String? _bedType;
  String? _city;
  List<Amenities>? _amenities;
  List<AvailableDates>? _availableDates;
  String? _hostId;
  String? _hostPlayerId;
  String? _hostFirstName;
  String? _hostLastName;
  String? _hostEmail;
  String? _hostPhone;
  String? _hostProfileImage;
  String? _frontImageUrl;
  List<String>? _galleryImageUrls;
  List<Reviews>? _reviews;
  num? _totalReviews;
  String? _itemData;
  String? _itemInfo;
  bool? _isInWishlist;
  List<String>? _vehicleRules;
  List<String>? _cancellationRules;
  String? _depositValue;
  String? _depositManager;

  String? get itemId => _itemId;
  String? get title => _title;
  String? get price => _price;
  String? get description => _description;
  String? get bedrooms => _bedrooms;
  String? get beds => _beds;
  String? get bathroom => _bathroom;
  String? get itemqft => _itemqft;
  String? get itemRating => _itemRating;
  String? get mobile => _mobile;
  String? get status => _status;
  String? get personAllowed => _personAllowed;
  String? get address => _address;
  String? get stateRegion => _stateRegion;
  String? get zipPostalCode => _zipPostalCode;
  String? get latitude => _latitude;
  String? get longitude => _longitude;
  String? get isVerified => _isVerified;
  String? get isFeatured => _isFeatured;
  String? get weeklyDiscount => _weeklyDiscount;
  String? get weeklyDiscountType => _weeklyDiscountType;
  String? get monthlyDiscount => _monthlyDiscount;
  String? get monthlyDiscountType => _monthlyDiscountType;
  String? get itemType => _itemType;
  dynamic get cancellationReason => _cancellationReason;
  String? get bedType => _bedType;
  String? get city => _city;
  List<Amenities>? get amenities => _amenities;
  List<AvailableDates>? get availableDates => _availableDates;
  String? get hostId => _hostId;
  String? get hostPlayerId => _hostPlayerId;
  String? get hostFirstName => _hostFirstName;
  String? get hostLastName => _hostLastName;
  String? get hostEmail => _hostEmail;
  String? get hostPhone => _hostPhone;
  String? get hostProfileImage => _hostProfileImage;
  String? get frontImageUrl => _frontImageUrl;
  List<String>? get galleryImageUrls => _galleryImageUrls;
  List<Reviews>? get reviews => _reviews;
  num? get totalReviews => _totalReviews;
  String? get itemData => _itemData;
  String? get itemInfo => _itemInfo;
  bool? get isInWishlist => _isInWishlist;
  List<String>? get vehicleRules => _vehicleRules;
  List<String>? get cancellationRules => _cancellationRules;
  String? get depositValue => _depositValue;
  String? get depositManager => _depositManager;

  set isInWishlist(bool? value) {
    _isInWishlist = value;
    // Assuming you have a method to notify listeners about changes
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['item_id'] = _itemId;
    map['title'] = _title;
    map['price'] = _price;
    map['description'] = _description;
    map['bedrooms'] = _bedrooms;
    map['beds'] = _beds;
    map['bathroom'] = _bathroom;
    map['item_sqft'] = _itemqft;
    map['item_rating'] = _itemRating;
    map['mobile'] = _mobile;
    map['status'] = _status;
    map['person_allowed'] = _personAllowed;
    map['address'] = _address;
    map['state_region'] = _stateRegion;
    map['zip_postal_code'] = _zipPostalCode;
    map['latitude'] = _latitude;
    map['longitude'] = _longitude;
    map['is_verified'] = _isVerified;
    map['is_featured'] = _isFeatured;
    map['weekly_discount'] = _weeklyDiscount;
    map['weekly_discount_type'] = _weeklyDiscountType;
    map['monthly_discount'] = _monthlyDiscount;
    map['monthly_discount_type'] = _monthlyDiscountType;
    map['item_type'] = _itemType;
    map['cancellation_reason'] = _cancellationReason;
    map['bed_type'] = _bedType;
    map['city'] = _city;
    if (_amenities != null) {
      map['amenities'] = _amenities?.map((v) => v.toJson()).toList();
    }
    if (_availableDates != null) {
      map['available_dates'] = _availableDates?.map((v) => v.toJson()).toList();
    }
    map['host_id'] = _hostId;
    map['host_player_id'] = _hostPlayerId;
    map['host_first_name'] = _hostFirstName;
    map['host_last_name'] = _hostLastName;
    map['host_email'] = _hostEmail;
    map['host_phone'] = _hostPhone;
    map['host_profile_image'] = _hostProfileImage;
    map['front_image_url'] = _frontImageUrl;
    map['gallery_image_urls'] = _galleryImageUrls;
    if (_reviews != null) {
      map['reviews'] = _reviews?.map((v) => v.toJson()).toList();
    }
    map['total_reviews'] = _totalReviews;
    map['item_data'] = _itemData;
    if (_itemInfo != null) {
      map['item_info'] = _itemInfo;
    }
    map['is_in_wishlist'] = _isInWishlist;
    if (_vehicleRules != null) {
      map['vehicle_rules'] = _vehicleRules;
    }
    if (_cancellationRules != null) {
      map['cancellation_rules'] = _cancellationRules;
    }
    map['deposit_value'] = _depositValue;
    map['deposit_manager'] = _depositManager;

    return map;
  }
}

class Reviews {
  Reviews({
    String? id,
    String? bookingId,
    String? guestId,
    String? guestName,
    String? guestProfileImage,
    String? rating,
    String? message,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _bookingId = bookingId;
    _guestId = guestId;
    _guestName = guestName;
    _guestProfileImage = guestProfileImage;
    _rating = rating;
    _message = message;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  Reviews.fromJson(dynamic json) {
    // IDs : conversion sécurisée en String
    _id = json['id']?.toString();
    _bookingId = json['booking_id']?.toString();
    _guestId = json['guest_id']?.toString();
    _guestName = json['guest_name']?.toString();
    _guestProfileImage = json['guest_profile_image']?.toString();
    _rating = json['rating']?.toString();
    _message = json['message']?.toString();
    _createdAt = json['created_at']?.toString();
    _updatedAt = json['updated_at']?.toString();
  }
  String? _id;
  String? _bookingId;
  String? _guestId;
  String? _guestName;
  String? _guestProfileImage;
  String? _rating;
  String? _message;
  String? _createdAt;
  String? _updatedAt;

  String? get id => _id;
  String? get bookingId => _bookingId;
  String? get guestId => _guestId;
  String? get guestName => _guestName;
  String? get guestProfileImage => _guestProfileImage;
  String? get rating => _rating;
  String? get message => _message;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['booking_id'] = _bookingId;
    map['guest_id'] = _guestId;
    map['guest_name'] = _guestName;
    map['guest_profile_image'] = _guestProfileImage;
    map['rating'] = _rating;
    map['message'] = _message;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }
}

class Amenities {
  Amenities({
    String? id,
    String? name,
    String? imageUrl,
  }) {
    _id = id;
    _name = name;
    _imageUrl = imageUrl;
  }

  Amenities.fromJson(dynamic json) {
    // ID : conversion sécurisée en String
    _id = json['id']?.toString();
    _name = json['name']?.toString();
    _imageUrl = json['image_url']?.toString();
  }
  String? _id;
  String? _name;
  String? _imageUrl;

  String? get id => _id;
  String? get name => _name;
  String? get imageUrl => _imageUrl;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['image_url'] = _imageUrl;
    return map;
  }
}

class AvailableDates {
  AvailableDates({
    String? date,
    String? price,
  }) {
    _date = date;
    _price = price;
  }

  AvailableDates.fromJson(dynamic json) {
    _date = json['date'];
    _price = json['price'];
  }
  String? _date;
  String? _price;

  String? get date => _date;
  String? get price => _price;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['date'] = _date;
    map['price'] = _price;
    return map;
  }
}
