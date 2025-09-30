import 'package:flutter/material.dart';
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
      json['Bookings'].forEach((v) {
        _bookings?.add(Bookings.fromJson(v));
      });
    }
    _offset = json['offset'];
    _limit = json['limit'];
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
    num? id,
    String? itemid,
    String? userid,
    String? hostId,
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
    String? dropOtp,
    String? doorStepAddress,
        dynamic iteriorImage,
                dynamic singnatureImage
  }) {
    _id = id;
    _itemid = itemid;
    _userid = userid;
    _hostId = hostId;
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
    _dropOtp = dropOtp;
    _doorStepAddress = doorStepAddress;


        _iteriorImage = iteriorImage;

              _singnatureImage = singnatureImage;
  }

  Bookings.fromJson(dynamic json) {
    _id = json['id'];
    _itemid = json['itemid'];
    _userid = json['userid'];
    _hostId = json['host_id'];
    _checkIn = json['check_in'];
    _checkOut = json['check_out'];
    _status = json['status'];
    _totalNight = json['total_day'];
    _perNight = json['per_day'];
    _bookFor = json['book_for'];
    _basePrice = json['base_price'];
    _cleaningCharge = json['cleaning_charge'];
    _guestCharge = json['guest_charge'];
    _serviceCharge = json['service_charge'];
    _securityMoney = json['security_money'];
    _ivaTax = json['iva_tax'];
    _totalGuest = json['total_guest'];
    _doorStepPrice = json["doorstep_price"];
    _total = json['total'];
    _adminCommission = json['admin_commission'];
    _vendorCommision = json['vendor_commision'];
    _currencyCode = json['currency_code'];
    _cancellationReasion = json['cancellation_reasion'];
    _cancelledCharge = json['cancelled_charge'];
    _transaction = json['transaction'];
    _paymentMethod = json['payment_method'];
    _paymentStatus = json['payment_status'];
    _propImg = json['image'];
    _propTitle = json['item_title'];
    _itemData = json['item_data'];
    _wallAmt = json['wall_amt'];
    _note = json['note'];
    _rating = json['rating'];
    _cancelledBy = json['cancelled_by'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _reviewStatus = json['review_status'];
    _reviewRating = json['review_rating'];
    _review = json['review'];
    _hostName = json['host_name'];
    _hostNumber = json['host_number'];
    _hostEmail = json['host_email'];
    _hostPhoneCountry = json['host_phone_country'];
    _userName = json['user_name'];
    _userNumber = json['user_number'];
    _userPhoneCountry = json['user_phone_country'];
    _userEmail = json['user_email'];

    _module = json['module'];
    _token = json['token'];
    _startTime = json['start_time'];
    _endTime = json['end_time'];
    _bookingMeta = json['booking_meta'];
    _isItemDelivered = json['is_item_delivered'];
    _isItemReceived = json['is_item_received'];
    _isItemReturned = json['is_item_returned'];
    _isItemDeliveredButton = json['is_item_delivered_button'];
    _isItemReturnedButton = json['is_item_returned_button'];
    _isItemRecivedButton = json['is_received_button'];

    _pickOtp = json['pick_otp'];
    _dropOtp = json['drop_otp'];

    _doorStepAddress = json['doorStep_address'];

     _iteriorImage = json['booking_vehicle_images'];
         _singnatureImage = json['signature_image'];
  }
  num? _id;
  String? _itemid;
  String? _userid;
  String? _hostId;
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

  num? get id => _id;
  String? get itemid => _itemid;
  String? get userid => _userid;
  String? get hostId => _hostId;
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
  String? get pickOtp => _pickOtp;
  String? get dropOtp => _dropOtp;
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
    map['drop_otp'] = _dropOtp;
    map['doorStep_address'] = _doorStepAddress;
    
        map['booking_vehicle_images'] = _iteriorImage;
            map['signature_image'] = _singnatureImage;
    return map;
  }
}
