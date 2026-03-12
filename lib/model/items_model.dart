import 'dart:convert';

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

      try {
        final rawItems = json['items'];

        if (rawItems is List) {
          for (var item in rawItems) {
            try {
              _items!.add(Items.fromJson(item));
            } catch (e, stack) {
              // Ignorer les erreurs de parsing silencieusement
            }
          }
        } else if (rawItems is Map<String, dynamic>) {
          rawItems.forEach((key, value) {
            try {
              _items!.add(Items.fromJson(value));
            } catch (e, stack) {
              // Ignorer les erreurs de parsing silencieusement
            }
          });
        }
      } catch (e, stack) {
        // Ignorer les erreurs globales silencieusement
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
  String? _id;
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
  // Champs dérivés à partir de item_info
  String? _transmission;
  String? _fuel;
  String? _seats;

  Items({
    String? id,
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
    String? transmission,
    String? fuel,
    String? seats,
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
    _transmission = transmission;
    _fuel = fuel;
    _seats = seats;
  }

  Items.fromJson(dynamic json) {
    // DEBUG: suivre exactement ce qui arrive depuis le backend pour la localisation
    final dynamic vehicleLocation = json['vehicleLocation'];
    final dynamic legacyLocation = json['location'];

    // ID Mongo -> Toujours traité comme String
    // Gérer à la fois 'id' et '_id' (MongoDB utilise '_id' par défaut)
    // Priorité: _id (MongoDB) > id (standard) > chaîne vide
    _id = json['_id']?.toString() ?? json['id']?.toString() ?? "";

    // Nom / Titre du véhicule
    // Ancien backend: "name", Nouveau: "title"
    _name = (json['name'] ?? json['title'] ?? '').toString();

    // Note moyenne
    // Ancien: "item_rating" (string), Nouveau: "rating" (number)
    if (json['item_rating'] != null) {
      _itemRating = json['item_rating'].toString();
    } else if (json['rating'] != null) {
      _itemRating = json['rating'].toString();
    } else {
      _itemRating = '0';
    }

    _mobile = json['mobile']?.toString() ?? '';
    _personAllowed = json['person_allowed']?.toString() ?? '';

    // Adresse / ville : on lit d'abord les champs à la racine (nouvelle API),
    // puis on retombe sur les anciennes structures si nécessaire.
    final dynamic rawAddress = json['address'] ??
        (vehicleLocation is Map ? vehicleLocation['address'] : null) ??
        (legacyLocation is Map ? legacyLocation['address'] : null);
    _address = rawAddress?.toString() ?? '';

    _stateRegion = json['state_region']?.toString() ?? '';

    final dynamic rawCity = json['city'] ??
        (vehicleLocation is Map ? vehicleLocation['cityName'] : null) ??
        (legacyLocation is Map ? legacyLocation['city'] : null);
    _city = rawCity?.toString() ?? '';

    _zipPostalCode = json['zip_postal_code']?.toString() ?? '';

    // Prix
    _price = json['price']?.toString() ?? '0';

    // Coordonnées : racine d'abord, puis anciens formats
    final dynamic rawLat = json['latitude'] ??
        (vehicleLocation is Map ? vehicleLocation['latitude'] : null) ??
        (legacyLocation is Map && legacyLocation['coordinates'] is List
            ? (legacyLocation['coordinates'] as List).length > 1
                ? (legacyLocation['coordinates'] as List)[1]
                : null
            : null);
    final dynamic rawLng = json['longitude'] ??
        (vehicleLocation is Map ? vehicleLocation['longitude'] : null) ??
        (legacyLocation is Map && legacyLocation['coordinates'] is List
            ? (legacyLocation['coordinates'] as List).isNotEmpty
                ? (legacyLocation['coordinates'] as List)[0]
                : null
            : null);

    _latitude = rawLat?.toString() ?? '';
    _longitude = rawLng?.toString() ?? '';

    _status = json['status']?.toString() ?? '';
    _itemTypeId = json['item_type_id']?.toString() ?? '';

    // Image principale
    // Priorité: image > front_image.url > front_image.thumbnail > placeholder
    String? imageUrl;
    final rawImage = json['image']?.toString() ?? '';
    if (rawImage.isNotEmpty) {
      imageUrl = rawImage;
    } else if (json['front_image'] != null && json['front_image'] is Map) {
      // Le backend renvoie front_image avec {url, thumbnail, preview}
      final frontImage = json['front_image'] as Map;
      imageUrl = frontImage['url']?.toString() ?? 
                 frontImage['thumbnail']?.toString() ?? 
                 frontImage['preview']?.toString();
    }
    
    // Si toujours vide, utiliser un placeholder
    if (imageUrl == null || imageUrl.isEmpty) {
      _image = "https://placehold.co/600x400/png";
    } else {
      _image = imageUrl;
    }

    // Informations détaillées (item_info)
    // Peut être soit une String JSON, soit un objet Map
    final dynamic rawItemInfo = json['item_info'];
    if (rawItemInfo is String) {
      _itemInfo = rawItemInfo;
      try {
        final decoded = jsonDecode(rawItemInfo);
        _transmission = decoded['transmission']?.toString();
        _fuel = decoded['fuel_type']?.toString();
        _seats = (decoded['number_of_seats'] ?? decoded['seats'])?.toString();
      } catch (_) {
        // En cas d'échec du décodage, garder _itemInfo tel quel
      }
    } else if (rawItemInfo is Map<String, dynamic>) {
      // Extraire les specs à partir de l'objet
      _transmission = rawItemInfo['transmission']?.toString();
      _fuel = rawItemInfo['fuel_type']?.toString();
      _seats =
          (rawItemInfo['number_of_seats'] ?? rawItemInfo['seats'])?.toString();

      // Convertir en JSON string pour compatibilité avec ItemInfo.fromJson()
      try {
        _itemInfo = jsonEncode(rawItemInfo);
      } catch (_) {
        _itemInfo = '{}';
      }
    } else {
      _itemInfo = '{}';
    }

    // Wishlist / favoris
    if (json.containsKey('is_in_wishlist')) {
      _isInWishlist = json['is_in_wishlist'] == true;
    } else if (json.containsKey('is_favorite')) {
      _isInWishlist = json['is_favorite'] == true;
    } else {
      _isInWishlist = false;
    }

    _itemType = json['item_type']?.toString() ?? '';
    _distance = json['distance']?.toString() ?? '0';
  }

  String? get id => _id;
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
  String? get transmission => _transmission;
  String? get fuel => _fuel;
  String? get seats => _seats;
  set wishlistSetter(bool value) {
    _isInWishlist = value;
  }

  /// Setter pratique pour permettre `item.isInWishlist = true/false`
  /// depuis les widgets, en gardant la compatibilité avec le backend.
  set isInWishlist(bool? value) {
    _isInWishlist = value ?? false;
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
    map['transmission'] = _transmission;
    map['fuel_type'] = _fuel;
    map['number_of_seats'] = _seats;
    return map;
  }
}
