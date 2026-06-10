import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class BookingModel {
  BookingModel({
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

  BookingModel.fromJson(dynamic json) {
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
    List<Bookings>? bookings,
    num? offset,
    num? limit,
  }) {
    _bookings = bookings;
    _offset = offset;
    _limit = limit;
  }

  Data.fromJson(dynamic json) {
    if (json['Bookings'] != null) {
      _bookings = [];
      debugPrint('📦 [Data.fromJson] Début parsing de ${json['Bookings'].length} réservations');
      
      int index = 0;
      json['Bookings'].forEach((v) {
        debugPrint('═══════════════════════════════════════════════════════');
        debugPrint('🔄 [Data.fromJson] Parsing Booking #$index');
        debugPrint('🔄 [Data.fromJson] JSON brut: ${v.toString().substring(0, v.toString().length > 200 ? 200 : v.toString().length)}...');
        
        // Log des clés importantes avant parsing
        if (v is Map) {
          debugPrint('🔄 [Data.fromJson] Clés disponibles: ${v.keys.toList()}');
          debugPrint('🔄 [Data.fromJson] _id présent: ${v.containsKey('_id')}, valeur: ${v['_id']}');
          debugPrint('🔄 [Data.fromJson] id présent: ${v.containsKey('id')}, valeur: ${v['id']}');
          debugPrint('🔄 [Data.fromJson] item_data présent: ${v.containsKey('item_data')}, type: ${v['item_data']?.runtimeType}');
        }
        
        try {
          var booking = Bookings.fromJson(v);
          _bookings?.add(booking);
          debugPrint('✅ [Data.fromJson] Booking #$index parsé avec succès - ID: ${booking.id}');
        } catch (e, stackTrace) {
          debugPrint('❌ [Data.fromJson] ERREUR lors du parsing du Booking #$index: $e');
          debugPrint('❌ [Data.fromJson] StackTrace: $stackTrace');
          // Continuer même si un booking échoue
        }
        
        index++;
      });
      
      debugPrint('✅ [Data.fromJson] ${_bookings?.length ?? 0} réservations parsées avec succès');
    } else {
      debugPrint('⚠️ [Data.fromJson] json["Bookings"] est null');
    }
    
    // Sécurisation des champs numériques offset et limit
    _offset = Bookings.safeToNum(json['offset']);
    _limit = Bookings.safeToNum(json['limit']);
  }
  List<Bookings>? _bookings;
  num? _offset;
  num? _limit;

  List<Bookings>? get bookings => _bookings;
  num? get offset => _offset;
  num? get limit => _limit;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_bookings != null) {
      map['Bookings'] = _bookings?.map((v) => v.toJson()).toList();
    }
    map['offset'] = _offset;
    map['limit'] = _limit;
    return map;
  }
}

class Bookings {
  Bookings({
    String? id,
    String? itemid,
    String? userid,
    String? hostId,
    String? hostAddress,
    double? hostLat,
    double? hostLng,
    String? checkIn,
    String? checkOut,
    String? status,
    String? totalNight,
    String? perNight,
    String? doorStepPrice,
    dynamic bookFor,
    String? basePrice,
    String? cleaningCharge,
    String? guestCharge,
    String? serviceCharge,
    String? securityMoney,
    String? ivaTax,
    String? totalGuest,
    String? total,
    String? adminCommission,
    String? vendorCommision,
    String? currencyCode,
    dynamic cancellationReasion,
    dynamic cancelledCharge,
    dynamic transaction,
    String? paymentMethod,
    String? paymentStatus,
    String? propImg,
    String? propTitle,
    dynamic itemData,
    String? wallAmt,
    dynamic note,
    String? rating,
    dynamic cancelledBy,
    String? createdAt,
    String? updatedAt,
    String? reviewStatus,
    String? reviewRating,
    String? review,
    String? isReviewed,
    String? vehicleId,
    String? hostName,
    String? hostNumber,
    String? hostEmail,
    String? hostPhoneCountry,
    String? userName,
    String? userNumber,
    String? userPhoneCountry,
    String? userEmail,
    String? module,
    String? token,
    String? startTime,
    String? endTime,
    String? bookingMeta,
    num? isItemDelivered,
    num? isItemReceived,
    num? isItemReturned,
    String? isItemDeliveredButton,
    String? isItemReturnedButton,
    String? isItemRecivedButton,
    String? pickOtp,
    String? pickupOtp,
    String? dropOtp,
    String? doorStepAddress,
        dynamic iteriorImage,
                dynamic singnatureImage
  }) {
    _id = id;
    _itemid = itemid;
    _userid = userid;
    _hostId = hostId;
    _hostAddress = hostAddress;
    _hostLat = hostLat;
    _hostLng = hostLng;
    _checkIn = checkIn;
    _checkOut = checkOut;
    _status = status;
    _doorStepPrice = doorStepPrice;
    _totalNight = totalNight;
    _perNight = perNight;
    _bookFor = bookFor;
    _basePrice = basePrice;
    _cleaningCharge = cleaningCharge;
    _guestCharge = guestCharge;
    _serviceCharge = serviceCharge;
    _securityMoney = securityMoney;
    _ivaTax = ivaTax;
    _totalGuest = totalGuest;
    _total = total;
    _adminCommission = adminCommission;
    _vendorCommision = vendorCommision;
    _currencyCode = currencyCode;
    _cancellationReasion = cancellationReasion;
    _cancelledCharge = cancelledCharge;
    _transaction = transaction;
    _paymentMethod = paymentMethod;
    _paymentStatus = paymentStatus;
    _propImg = propImg;
    _propTitle = propTitle;
    _itemData = itemData;
    _wallAmt = wallAmt;
    _note = note;
    _rating = rating;
    _cancelledBy = cancelledBy;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _reviewStatus = reviewStatus;
    _reviewRating = reviewRating;
    _review = review;
    _isReviewed = isReviewed;
    _vehicleId = vehicleId ?? itemid;

    _hostName = hostName;
    _hostNumber = hostNumber;
    _hostEmail = hostEmail;
    _hostPhoneCountry = hostPhoneCountry;
    _userName = userName;
    _userNumber = userNumber;
    _userPhoneCountry = userPhoneCountry;
    _userEmail = userEmail;
    _module = module;
    _token = token;
    _startTime = startTime;
    _endTime = endTime;
    _bookingMeta = bookingMeta;
    _isItemDelivered = isItemDelivered;
    _isItemReceived = isItemReceived;
    _isItemReturned = isItemReturned;
    _isItemDeliveredButton = isItemDeliveredButton;
    _isItemReturnedButton = isItemReturnedButton;
    _isItemRecivedButton = isItemRecivedButton;
    _pickOtp = pickOtp;
    _pickOtp ??= pickupOtp;
    _dropOtp = dropOtp;
    _doorStepAddress = doorStepAddress;


        _iteriorImage = iteriorImage;

              _singnatureImage = singnatureImage;
  }

  // ========== FONCTIONS HELPER POUR CONVERSION SÉCURISÉE ==========
  /// Convertit une valeur en num? de manière sécurisée
  /// Gère String, num, int, double, null
  static num? safeToNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) {
      if (value.isEmpty) return null;
      return num.tryParse(value);
    }
    // Essayer de convertir via toString puis parsing
    try {
      return num.tryParse(value.toString());
    } catch (e) {
      return null;
    }
  }

  /// Convertit une valeur en String? de manière sécurisée
  /// Gère String, num, int, double, null
  static String? safeToString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    return value.toString();
  }

  /// Extrait un identifiant MongoDB / API en [String] (évite `[object Object]`).
  static String? normalizeEntityId(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final t = value.trim();
      if (t.isEmpty ||
          t.toLowerCase() == 'null' ||
          t == '[object Object]') {
        return null;
      }
      return t;
    }
    if (value is Map) {
      for (final key in [
        r'$oid',
        'oid',
        '_id',
        'id',
        'sId',
        'item_id',
        'itemid',
        'vehicle_id',
        'vehicleId',
      ]) {
        if (value.containsKey(key)) {
          final nested = normalizeEntityId(value[key]);
          if (nested != null) return nested;
        }
      }
      return null;
    }
    if (value is List && value.isNotEmpty) {
      return normalizeEntityId(value.first);
    }
    if (value is num || value is bool) return value.toString();
    final s = value.toString().trim();
    if (s.isEmpty ||
        s.toLowerCase() == 'null' ||
        s.contains('[object Object]')) {
      return null;
    }
    return s;
  }

  static final RegExp _mongoObjectIdPattern = RegExp(r'^[a-fA-F0-9]{24}$');

  static bool isLikelyMongoObjectId(String? value) {
    if (value == null) return false;
    return _mongoObjectIdPattern.hasMatch(value.trim());
  }

  /// Extrait l'ID véhicule depuis [item_data] (priorité au `_id` MongoDB).
  static String? extractVehicleIdFromItemData(dynamic rawItemData) {
    if (rawItemData == null) return null;
    try {
      dynamic decoded = rawItemData;
      if (rawItemData is String && rawItemData.trim().isNotEmpty) {
        final t = rawItemData.trim();
        if (t.startsWith('[') || t.startsWith('{')) {
          decoded = jsonDecode(t);
        }
      }
      if (decoded is List && decoded.isNotEmpty) {
        decoded = decoded.first;
      }
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);
      final fromMap = normalizeEntityId(map['_id']) ??
          normalizeEntityId(map['vehicle_id']) ??
          normalizeEntityId(map['vehicleId']) ??
          normalizeEntityId(map['item_id']) ??
          normalizeEntityId(map['itemid']) ??
          normalizeEntityId(map['id']);
      if (fromMap != null) return fromMap;

      if (map.containsKey('item_info')) {
        try {
          dynamic rawInfo = map['item_info'];
          Map<String, dynamic>? infoMap;
          if (rawInfo is String && rawInfo.trim().isNotEmpty) {
            infoMap = Map<String, dynamic>.from(jsonDecode(rawInfo));
          } else if (rawInfo is Map) {
            infoMap = Map<String, dynamic>.from(rawInfo);
          }
          if (infoMap != null) {
            return normalizeEntityId(infoMap['vehicle_id']) ??
                normalizeEntityId(infoMap['vehicleId']) ??
                normalizeEntityId(infoMap['item_id']) ??
                normalizeEntityId(infoMap['itemid']) ??
                normalizeEntityId(infoMap['_id']) ??
                normalizeEntityId(infoMap['id']);
          }
        } catch (_) {}
      }
    } catch (_) {}
    return null;
  }

  /// ID véhicule pour [submit-review] — champs directs puis [item_data].
  static String? resolveVehicleIdForReview(Bookings booking) {
    booking.enrichVehicleFieldsLikeVendor();

    final candidates = <String?>[
      normalizeEntityId(booking.vehicleId),
      normalizeEntityId(booking.itemid),
      extractVehicleIdFromItemData(booking.itemData),
    ];

    for (final id in candidates) {
      if (id != null && isLikelyMongoObjectId(id)) return id;
    }
    for (final id in candidates) {
      if (id != null && id.isNotEmpty) return id;
    }
    return null;
  }

  /// Résout vehicle_id depuis une map notification / payload API.
  static String? resolveVehicleIdForReviewPayload(
    Map<String, dynamic> data, {
    Bookings? booking,
  }) {
    if (booking != null) {
      final fromBooking = resolveVehicleIdForReview(booking);
      if (fromBooking != null && fromBooking.isNotEmpty) {
        return fromBooking;
      }
    }
    return normalizeEntityId(data['vehicle_id']) ??
        normalizeEntityId(data['vehicleId']) ??
        normalizeEntityId(data['item_id']) ??
        normalizeEntityId(data['itemid']) ??
        extractVehicleIdFromItemData(data['item_data']);
  }

  static bool _isWeakVehicleTitle(String? title) {
    if (title == null) return true;
    final t = title.trim().toLowerCase();
    if (t.isEmpty || t == 'null' || t == 'n/a') return true;
    if (t.contains('véhicule sans titre') || t == 'véhicule') return true;
    return false;
  }

  static Map<String, dynamic>? _decodeFirstItemDataMap(dynamic rawItemData) {
    if (rawItemData == null) return null;
    try {
      dynamic decoded = rawItemData;
      if (rawItemData is String && rawItemData.trim().isNotEmpty) {
        final t = rawItemData.trim();
        if (t.startsWith('[') || t.startsWith('{')) {
          decoded = jsonDecode(t);
        } else {
          return null;
        }
      }
      if (decoded is List && decoded.isNotEmpty) {
        final first = decoded.first;
        if (first is Map) return Map<String, dynamic>.from(first);
      }
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return null;
  }

  static String? _titleFromItemInfoMap(Map<String, dynamic> itemInfo) {
    final make = safeToString(itemInfo['make_type'] ?? itemInfo['make']);
    final model = safeToString(itemInfo['model']);
    final year = safeToString(itemInfo['year']);
    final parts = [make, model, year].whereType<String>().toList();
    if (parts.isEmpty) return null;
    return parts.join(' ');
  }

  /// Aligne itemid, titre et item_data sur le format [vendor-booking-record].
  void enrichVehicleFieldsLikeVendor() {
    final first = _decodeFirstItemDataMap(_itemData);

    if (first != null) {
      final mongoId = normalizeEntityId(first['_id']);
      final itemIdFromData = normalizeEntityId(first['item_id']) ??
          normalizeEntityId(first['itemid']) ??
          mongoId;

      if (_itemid == null || _itemid!.isEmpty) {
        _itemid = itemIdFromData ?? mongoId;
      }
      if (_vehicleId == null || _vehicleId!.isEmpty) {
        _vehicleId = mongoId ?? itemIdFromData ?? _itemid;
      }

      final titleFromData = safeToString(first['title']) ??
          safeToString(first['name']) ??
          safeToString(first['item_title']);
      if (_isWeakVehicleTitle(_propTitle) && titleFromData != null) {
        _propTitle = titleFromData;
      }

      if (_isWeakVehicleTitle(_propTitle) && first.containsKey('item_info')) {
        try {
          dynamic rawInfo = first['item_info'];
          Map<String, dynamic>? infoMap;
          if (rawInfo is String) {
            infoMap = Map<String, dynamic>.from(jsonDecode(rawInfo));
          } else if (rawInfo is Map) {
            infoMap = Map<String, dynamic>.from(rawInfo);
          }
          final built = infoMap != null ? _titleFromItemInfoMap(infoMap) : null;
          if (built != null) _propTitle = built;
        } catch (_) {}
      }

      final img = safeToString(first['front_image_url']) ??
          safeToString(first['image']);
      if ((_propImg == null || _propImg!.isEmpty) && img != null) {
        _propImg = img;
      }

      final enrichedFirst = Map<String, dynamic>.from(first);
      if (mongoId != null) enrichedFirst['_id'] = mongoId;
      if (itemIdFromData != null) {
        enrichedFirst['item_id'] = itemIdFromData;
        enrichedFirst['itemid'] = itemIdFromData;
      }
      if (_propTitle != null && _propTitle!.isNotEmpty) {
        enrichedFirst['title'] ??= _propTitle;
        enrichedFirst['item_title'] ??= _propTitle;
      }
      if (_propImg != null && _propImg!.isNotEmpty) {
        enrichedFirst['image'] ??= _propImg;
        enrichedFirst['front_image_url'] ??= _propImg;
      }

      _itemData = jsonEncode([enrichedFirst]);
    } else if (_itemid != null ||
        _vehicleId != null ||
        (_propTitle != null && _propTitle!.isNotEmpty)) {
      final synthetic = <String, dynamic>{
        if (_vehicleId != null) '_id': _vehicleId,
        if (_itemid != null) ...{
          'item_id': _itemid,
          'itemid': _itemid,
        },
        if (_propTitle != null && _propTitle!.isNotEmpty) 'title': _propTitle,
        if (_propImg != null && _propImg!.isNotEmpty) 'image': _propImg,
      };
      if (synthetic.isNotEmpty) {
        _itemData = jsonEncode([synthetic]);
      }
    }

    if ((_itemid == null || _itemid!.isEmpty) && _vehicleId != null) {
      _itemid = _vehicleId;
    }
  }

  /// Décode [item_data] en liste pour l'UI (cartes réservation client).
  static List<dynamic>? decodeItemDataList(dynamic rawItemData) {
    if (rawItemData == null) return null;
    try {
      if (rawItemData is List) return rawItemData;
      if (rawItemData is String && rawItemData.trim().isNotEmpty) {
        final decoded = jsonDecode(rawItemData.trim());
        if (decoded is List) return decoded;
        if (decoded is Map) return [decoded];
      }
    } catch (_) {}
    return null;
  }

  Bookings.fromJson(dynamic json) {
    try {
      // ========== 1. INSPECTION DU DÉCODAGE - ID ==========
      _id = normalizeEntityId(json['_id'] ?? json['id']);

      // ========== CHAMPS IDENTIFIANTS (String) ==========
      _itemid = normalizeEntityId(
        json['itemid'] ?? json['item_id'] ?? json['vehicle_id'] ?? json['vehicleId'],
      );
      final vehicleObj = json['vehicle'];
      _vehicleId = normalizeEntityId(json['vehicle_id'] ?? json['vehicleId']) ??
          (vehicleObj is Map
              ? normalizeEntityId(vehicleObj['_id'] ?? vehicleObj['id'])
              : normalizeEntityId(vehicleObj)) ??
          _itemid;
      _userid = normalizeEntityId(json['userid'] ?? json['user_id']);
      _hostId = normalizeEntityId(
        json['host_id'] ??
            json['vendor_id'] ??
            json['vendorId'] ??
            (json['owner'] is Map ? (json['owner'] as Map)['_id'] : json['owner']),
      );
      
      // ========== CHAMPS DATES ET STATUS (String) ==========
      _checkIn = safeToString(json['check_in']);
      _checkOut = safeToString(json['check_out']);
      _status = safeToString(json['status']);
      
      // ========== CHAMPS NUMÉRIQUES FINANCIERS (String mais peuvent être num) ==========
      _totalNight = safeToString(json['total_day']);
      _perNight = safeToString(json['per_day']);
      _basePrice = safeToString(json['base_price']);
      _cleaningCharge = safeToString(json['cleaning_charge']);
      _guestCharge = safeToString(json['guest_charge']);
      _serviceCharge = safeToString(json['service_charge']);
      _securityMoney = safeToString(json['security_money']);
      _ivaTax = safeToString(json['iva_tax']);
      _totalGuest = safeToString(json['total_guest']);
      _doorStepPrice = safeToString(json["doorstep_price"]);
      
      // ========== TOTAL (String mais peut être num) ==========
      if (json['total'] != null) {
        _total = safeToString(json['total']);
      } else {
        _total = null;
      }
      
      // ========== AUTRES CHAMPS FINANCIERS (String) ==========
      _adminCommission = safeToString(json['admin_commission']);
      _vendorCommision = safeToString(json['vendor_commision']);
      _currencyCode = safeToString(json['currency_code']);
      _wallAmt = safeToString(json['wall_amt']);
      
      // ========== CHAMPS DIVERS ==========
      _bookFor = json['book_for'];
      _cancellationReasion = json['cancellation_reasion'];
      _cancelledCharge = json['cancelled_charge'];
      _transaction = safeToString(json['transaction']) ??
          safeToString(json['transaction_id']) ??
          safeToString(json['transactionId']) ??
          safeToString(json['payment_intent']) ??
          safeToString(json['paymentIntent']);
      _paymentMethod = safeToString(json['payment_method']);
      _paymentStatus = safeToString(json['payment_status']);
      _propImg = safeToString(json['image']);
      // ========== LOG CRITIQUE POUR DÉBOGUER L'URL D'IMAGE ==========
      if (_propImg != null && _propImg!.isNotEmpty) {
        print('🖼️ [DEBUG IMAGE] Raw URL: $_propImg');
        print('🖼️ [DEBUG IMAGE] URL Type: ${_propImg!.startsWith('http') ? "URL complète" : _propImg!.startsWith('/') ? "Chemin relatif (commence par /)" : "Chemin relatif ou nom de fichier"}');
      } else {
        print('🖼️ [DEBUG IMAGE] Raw URL: null ou vide');
      }
      _propTitle = safeToString(json['item_title'] ?? json['title']);
      if (_isWeakVehicleTitle(_propTitle)) {
        _propTitle = safeToString(json['title']);
      }
      _note = json['note'];
      _rating = safeToString(json['rating']);
      _cancelledBy = json['cancelled_by'];
      _createdAt = safeToString(json['created_at']);
      _updatedAt = safeToString(json['updated_at']);
      _reviewStatus = safeToString(json['review_status']);
      _reviewRating = safeToString(json['review_rating']);
      _review = safeToString(json['review']);
      final rawIsReviewed = json['is_reviewed'] ?? json['isReviewed'];
      if (rawIsReviewed is bool) {
        _isReviewed = rawIsReviewed ? '1' : '0';
      } else if (rawIsReviewed is num) {
        _isReviewed = rawIsReviewed == 1 ? '1' : '0';
      } else {
        _isReviewed = safeToString(rawIsReviewed);
      }

      // ========== INFORMATIONS HOST (String) ==========
      _hostName = safeToString(json['host_name']);
      _hostNumber = safeToString(json['host_number']);
      _hostEmail = safeToString(json['host_email']);
      _hostPhoneCountry = safeToString(json['host_phone_country']);
      
      // ========== INFORMATIONS USER (String) ==========
      _userName = safeToString(json['user_name']);
      _userNumber = safeToString(json['user_number']);
      _userPhoneCountry = safeToString(json['user_phone_country']);
      _userEmail = safeToString(json['user_email']);

      // ========== MÉTADONNÉES (String) ==========
      _module = safeToString(json['module']);
      _token = safeToString(json['token']) ??
          safeToString(json['booking_token']) ??
          safeToString(json['reservation_code']) ??
          safeToString(json['booking_code']);
      
      // ========== HOST ADDRESS & GEO (nouveaux champs) ==========
      _hostAddress = safeToString(json['host_address']);
      try {
        _hostLat = json['host_lat'] == null
            ? null
            : double.tryParse(json['host_lat'].toString());
      } catch (_) {
        _hostLat = null;
      }
      try {
        _hostLng = json['host_lng'] == null
            ? null
            : double.tryParse(json['host_lng'].toString());
      } catch (_) {
        _hostLng = null;
      }
      _startTime = safeToString(json['start_time']);
      _endTime = safeToString(json['end_time']);
      _bookingMeta = safeToString(json['booking_meta']);
      
      // ========== CHAMPS NUMÉRIQUES (num?) ==========
      _isItemDelivered = safeToNum(json['is_item_delivered']);
      _isItemReceived = safeToNum(json['is_item_received']);
      _isItemReturned = safeToNum(json['is_item_returned']);
      
      // ========== BOUTONS (String) ==========
      _isItemDeliveredButton = safeToString(json['is_item_delivered_button']);
      _isItemReturnedButton = safeToString(json['is_item_returned_button']);
      _isItemRecivedButton = safeToString(json['is_received_button']);

      // ========== OTP (String mais peuvent être num) ==========
      // Mapping avec fallback pour compatibilité avec différentes versions de l'API
      _pickOtp = json['pickOtp']?.toString() ??
          json['pick_otp']?.toString() ??
          json['pickup_otp']?.toString() ??
          json['otp']?.toString();
      _dropOtp = json['drop_otp']?.toString() ?? json['dropOtp']?.toString();

      // ========== ADRESSE (String) ==========
      _doorStepAddress = safeToString(json['doorStep_address']);

      // ========== IMAGES (dynamic) ==========
      _iteriorImage = json['booking_vehicle_images'];
      _singnatureImage = json['signature_image'];
      
      // ========== 2. PARSING DE item_data (Sièges et Type) ==========
      _itemData = json['item_data'];
      final vehicleFromItemData = extractVehicleIdFromItemData(_itemData);
      if (vehicleFromItemData != null) {
        if (!isLikelyMongoObjectId(_vehicleId)) {
          _vehicleId = vehicleFromItemData;
        }
        if (!isLikelyMongoObjectId(_itemid)) {
          _itemid = vehicleFromItemData;
        }
      }

      // Décodage spécifique de item_data avec try-catch
      if (_itemData != null && _itemData.toString().isNotEmpty) {
        try {
          // Si c'est déjà une String, la décoder
          dynamic itemDataToDecode = _itemData;
          if (_itemData is String) {
            itemDataToDecode = jsonDecode(_itemData);
          }
          
          if (itemDataToDecode is List && itemDataToDecode.isNotEmpty) {
            Map<String, dynamic> firstItem = itemDataToDecode[0];
            
            // Extraction de item_type depuis item_data[0]
            dynamic itemType = firstItem['item_type'];
            
            // Extraction de number_of_seats depuis item_info
            if (firstItem.containsKey('item_info')) {
              try {
                dynamic itemInfoRaw = firstItem['item_info'];
                Map<String, dynamic>? itemInfoMap;
                
                // item_info peut être une String JSON ou un Map
                if (itemInfoRaw is String) {
                  itemInfoMap = Map<String, dynamic>.from(jsonDecode(itemInfoRaw));
                } else if (itemInfoRaw is Map) {
                  itemInfoMap = Map<String, dynamic>.from(itemInfoRaw);
                }
                
                if (itemInfoMap != null) {
                  // Extraction de number_of_seats
                  dynamic numberOfSeats = itemInfoMap['number_of_seats'];
                  
                  // Extraction de transmission
                  dynamic transmission = itemInfoMap['transmission'] ?? itemInfoMap['transmission_type'];
                }
              } catch (e) {
                // Ignorer les erreurs de décodage silencieusement
              }
            }
          }
        } catch (e, stackTrace) {
          // Continuer même si le décodage échoue
        }
      }

      enrichVehicleFieldsLikeVendor();
      
    } catch (e, stackTrace) {
      debugPrint('❌ [Bookings.fromJson] ERREUR CRITIQUE lors du parsing: $e');
      debugPrint('❌ [Bookings.fromJson] StackTrace: $stackTrace');
      // Continuer avec des valeurs par défaut pour éviter un crash complet
      _id = null; // String? null est valide
      _itemid = null;
      _userid = null;
      _hostId = null;
    }
  }
  String? _id;
  String? _itemid;
  String? _vehicleId;
  String? _userid;
  String? _hostId;
  String? _hostAddress;
  double? _hostLat;
  double? _hostLng;
  String? _checkIn;
  String? _checkOut;
  String? _status;
  String? _totalNight;
  String? _perNight;
  String? _doorStepPrice;
  dynamic _bookFor;
  String? _basePrice;
  String? _cleaningCharge;
  String? _guestCharge;
  String? _serviceCharge;
  String? _securityMoney;
  String? _ivaTax;
  String? _totalGuest;
  String? _total;
  String? _adminCommission;
  String? _vendorCommision;
  String? _currencyCode;
  dynamic _cancellationReasion;
  dynamic _cancelledCharge;
  dynamic _transaction;
  String? _paymentMethod;
  String? _paymentStatus;
  String? _propImg;
  String? _propTitle;
  dynamic _itemData;
  String? _wallAmt;
  dynamic _note;
  String? _rating;
  dynamic _cancelledBy;
  String? _createdAt;
  String? _updatedAt;
  String? _reviewStatus;
  String? _reviewRating;
  String? _review;
  String? _isReviewed;

  String? _hostName;
  String? _hostNumber;
  String? _hostEmail;
  String? _hostPhoneCountry;
  String? _userName;
  String? _userNumber;
  String? _userPhoneCountry;
  String? _userEmail;

  String? _module;
  String? _token;
  String? _startTime;
  String? _endTime;
  String? _bookingMeta;
  num? _isItemDelivered;
  num? _isItemReceived;
  num? _isItemReturned;
  String? _isItemDeliveredButton;
  String? _isItemReturnedButton;
  String? _isItemRecivedButton;
  dynamic _pickOtp;
  dynamic _dropOtp;
  String? _doorStepAddress;
  dynamic       _singnatureImage;
    dynamic _iteriorImage;

  String? get id => _id;
  String? get itemid => _itemid;
  String? get vehicleId => _vehicleId ?? _itemid;
  String? get userid => _userid;
  String? get hostId => _hostId;
  String? get hostAddress => _hostAddress;
  double? get hostLat => _hostLat;
  double? get hostLng => _hostLng;
  String? get checkIn => _checkIn;
  String? get checkOut => _checkOut;
  String? get status => _status;
  String? get totalNight => _totalNight;
  String? get perNight => _perNight;
  dynamic get bookFor => _bookFor;
  String? get basePrice => _basePrice;
  String? get cleaningCharge => _cleaningCharge;
  String? get guestCharge => _guestCharge;
  String? get serviceCharge => _serviceCharge;
  String? get securityMoney => _securityMoney;
  String? get ivaTax => _ivaTax;
  String? get doorStepPrice => _doorStepPrice;
  String? get totalGuest => _totalGuest;
  String? get total => _total;
  String? get adminCommission => _adminCommission;
  String? get vendorCommision => _vendorCommision;
  String? get currencyCode => _currencyCode;
  dynamic get cancellationReasion => _cancellationReasion;
  dynamic get cancelledCharge => _cancelledCharge;
  dynamic get transaction => _transaction;
  String? get paymentMethod => _paymentMethod;
  String? get paymentStatus => _paymentStatus;
  String? get propImg => _propImg;
  String? get propTitle => _propTitle;
  dynamic get itemData => _itemData;
  String? get wallAmt => _wallAmt;
  dynamic get note => _note;
  String? get rating => _rating;
  dynamic get cancelledBy => _cancelledBy;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  String? get reviewStatus => _reviewStatus;
  String? get reviewRating => _reviewRating;
  String? get review => _review;
  String? get isReviewed => _isReviewed;
  num? get isItemDelivered => _isItemDelivered;
  num? get isItemReceived => _isItemReceived;
  num? get isItemReturned => _isItemReturned;

  String? get hostName => _hostName;
  String? get hostNumber => _hostNumber;
  String? get hostEmail => _hostEmail;
  String? get hostPhoneCountry => _hostPhoneCountry;
  String? get userName => _userName;
  String? get userNumber => _userNumber;
  String? get userPhoneCountry => _userPhoneCountry;
  String? get userEmail => _userEmail;

  String? get module => _module;
  String? get token => _token;
  String? get startTime => _startTime;
  String? get endTime => _endTime;
  String? get bookingMeta => _bookingMeta;
  String? get isItemDeliveredButton => _isItemDeliveredButton;
  String? get isItemReturnedButton => _isItemReturnedButton;
  String? get isItemRecivedButton => _isItemRecivedButton;
  String? get pickOtp => _pickOtp?.toString();
  String? get pickupOtp => _pickOtp?.toString();
  String? get dropOtp => _dropOtp?.toString();
  String? get doorStepAddress => _doorStepAddress;

    dynamic? get iteriorImage => _iteriorImage;

        dynamic? get singnatureImage => _singnatureImage;

  set statusSetter(String value) {
    _status = value;
  }

  set reviewStatusSetter(String value) {
    _reviewStatus = value;
  }

  set reviewRatingSetter(String value) {
    _reviewRating = value;
  }

  set reviewSetter(String value) {
    _review = value;
  }

  set isReviewedSetter(String value) {
    _isReviewed = value;
  }

  set itemidSetter(String value) {
    _itemid = value;
  }

  set vehicleIdSetter(String value) {
    _vehicleId = value;
  }

  set propTitleSetter(String value) {
    _propTitle = value;
  }

  set propImgSetter(String value) {
    _propImg = value;
  }

  set itemDataSetter(dynamic value) {
    _itemData = value;
  }

  set isItemDeliveredSetter(String value) {
    _isItemDeliveredButton = value;
  }

  set isItemReturnedSetter(String value) {
    _isItemReturnedButton = value;
  }

  set isItemReceivedSetter(String value) {
    _isItemRecivedButton = value;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['itemid'] = _itemid;
    map['vehicle_id'] = _vehicleId ?? _itemid;
    map['userid'] = _userid;
    map['host_id'] = _hostId;
    map['check_in'] = _checkIn;
    map['check_out'] = _checkOut;
    map['status'] = _status;
    map['total_day'] = _totalNight;
    map['per_day'] = _perNight;
    map['book_for'] = _bookFor;
    map['base_price'] = _basePrice;
    map['cleaning_charge'] = _cleaningCharge;
    map['guest_charge'] = _guestCharge;
    map['service_charge'] = _serviceCharge;
    map['security_money'] = _securityMoney;
    map['iva_tax'] = _ivaTax;
    map['total_guest'] = _totalGuest;
    map['total'] = _total;
    map['admin_commission'] = _adminCommission;
    map['vendor_commision'] = _vendorCommision;
    map['currency_code'] = _currencyCode;
    map['cancellation_reasion'] = _cancellationReasion;
    map['cancelled_charge'] = _cancelledCharge;
    map['transaction'] = _transaction;
    map['payment_method'] = _paymentMethod;
    map['payment_status'] = _paymentStatus;
    map['image'] = _propImg;
    map['item_title'] = _propTitle;
    map['item_data'] = _itemData;
    map['wall_amt'] = _wallAmt;
    map['note'] = _note;
    map['rating'] = _rating;
    map['cancelled_by'] = _cancelledBy;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    map['review_status'] = _reviewStatus;
    map['review_rating'] = _reviewRating;
    map['review'] = _review;
    map['is_reviewed'] = _isReviewed;
    map['doorstep_price'] = _doorStepPrice;
    map['host_name'] = _hostName;
    map['host_number'] = _hostNumber;
    map['host_email'] = _hostEmail;
    map['host_phone_country'] = _hostPhoneCountry;
    map['user_name'] = _userName;
    map['user_number'] = _userNumber;
    map['user_phone_country'] = _userPhoneCountry;
    map['user_email'] = _userEmail;
    map['module'] = _module;
    map['token'] = _token;
    map['host_address'] = _hostAddress;
    map['host_lat'] = _hostLat;
    map['host_lng'] = _hostLng;
    map['start_time'] = _startTime;
    map['end_time'] = _endTime;
    map['booking_meta'] = _bookingMeta;
    map['is_item_delivered'] = _isItemDelivered;
    map['is_item_received'] = _isItemReceived;
    map['is_item_returned'] = _isItemReturned;
    map['is_item_delivered_button'] = _isItemDeliveredButton;
    map['is_item_returned_button'] = _isItemReturnedButton;
    map['is_received_button'] = _isItemRecivedButton;
    map['pick_otp'] = _pickOtp;
    map['pickup_otp'] = _pickOtp;
    map['drop_otp'] = _dropOtp;
    map['doorStep_address'] = _doorStepAddress;
    
        map['booking_vehicle_images'] = _iteriorImage;
            map['signature_image'] = _singnatureImage;
    return map;
  }
}
