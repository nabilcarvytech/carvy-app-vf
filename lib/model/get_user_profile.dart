class GetUserProfile {
  GetUserProfile({
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

  GetUserProfile.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
    _error = json['error'];
  }

  num? _status;
  String? _message;
  Data? _data;
  String? _error;

  GetUserProfile copyWith({
    num? status,
    String? message,
    Data? data,
    String? error,
  }) =>
      GetUserProfile(
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
    String? name,
    String? profileImage,
    String? profileBackground,
    String? introText,
    num? totalReviewsOnItems,
    num? averageRatingOnItems,
    String? yearsOfHosting,
    String? languages,
    String? liveCity,
    String? age,
    String? joinIn,
    String? verifiedIdentity,
    String? verifiedEmail,
    String? verifiedPhone,
  }) {
    _name = name;
    _profileImage = profileImage;
    _profileBackground = profileBackground;
    _introText = introText;
    _totalReviewsOnItems = totalReviewsOnItems;
    _averageRatingOnItems = averageRatingOnItems;
    _yearsOfHosting = yearsOfHosting;
    _languages = languages;
    _liveCity = liveCity;
    _age = age;
    _joinIn = joinIn;
    _verifiedIdentity = verifiedIdentity;
    _verifiedEmail = verifiedEmail;
    _verifiedPhone = verifiedPhone;
  }

  Data.fromJson(dynamic json) {
    _name = json['name'];
    _profileImage = json['profile_image'];
    _profileBackground = json['profile_background'];
    _introText = json['intro_text'];
    _totalReviewsOnItems = json['total_reviews_on_items'];
    _averageRatingOnItems = json['average_rating_on_items'];
    _yearsOfHosting = json['years_of_hosting'];
    _languages = json['languages'];
    _liveCity = json['livecity'];
    _age = json['age'];
    _joinIn = json['join_in'];
    _verifiedIdentity = json['verified_identity'];
    _verifiedEmail = json['verified_email'];
    _verifiedPhone = json['verified_phone'];
  }

  String? _name;
  String? _profileImage;
  String? _profileBackground;
  String? _introText;
  num? _totalReviewsOnItems;
  num? _averageRatingOnItems;
  String? _yearsOfHosting;
  String? _languages;
  String? _liveCity;
  String? _age;
  String? _joinIn;
  String? _verifiedIdentity;
  String? _verifiedEmail;
  String? _verifiedPhone;

  Data copyWith({
    String? name,
    String? profileImage,
    String? profileBackground,
    String? introText,
    num? totalReviewsOnItems,
    num? averageRatingOnItems,
    String? yearsOfHosting,
    String? languages,
    String? liveCity,
    String? age,
    String? joinIn,
    String? verifiedIdentity,
    String? verifiedEmail,
    String? verifiedPhone,
  }) =>
      Data(
        name: name ?? _name,
        profileImage: profileImage ?? _profileImage,
        profileBackground: profileBackground ?? _profileBackground,
        introText: introText ?? _introText,
        totalReviewsOnItems: totalReviewsOnItems ?? _totalReviewsOnItems,
        averageRatingOnItems: averageRatingOnItems ?? _averageRatingOnItems,
        yearsOfHosting: yearsOfHosting ?? _yearsOfHosting,
        languages: languages ?? _languages,
        liveCity: liveCity ?? _liveCity,
        age: age ?? _age,
        joinIn: joinIn ?? _joinIn,
        verifiedIdentity: verifiedIdentity ?? _verifiedIdentity,
        verifiedEmail: verifiedEmail ?? _verifiedEmail,
        verifiedPhone: verifiedPhone ?? _verifiedPhone,
      );

  String? get name => _name;
  String? get profileImage => _profileImage;
  String? get profileBackground => _profileBackground;
  String? get introText => _introText;
  num? get totalReviewsOnItems => _totalReviewsOnItems;
  num? get averageRatingOnItems => _averageRatingOnItems;
  String? get yearsOfHosting => _yearsOfHosting;
  String? get languages => _languages;
  String? get liveCity => _liveCity;
  String? get age => _age;
  String? get joinIn => _joinIn;
  String? get verifiedIdentity => _verifiedIdentity;
  String? get verifiedEmail => _verifiedEmail;
  String? get verifiedPhone => _verifiedPhone;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['profile_image'] = _profileImage;
    map['profile_background'] = _profileBackground;
    map['intro_text'] = _introText;
    map['total_reviews_on_items'] = _totalReviewsOnItems;
    map['average_rating_on_items'] = _averageRatingOnItems;
    map['years_of_hosting'] = _yearsOfHosting;
    map['languages'] = _languages;
    map['livecity'] = _liveCity;
    map['age'] = _age;
    map['join_in'] = _joinIn;
    map['verified_identity'] = _verifiedIdentity;
    map['verified_email'] = _verifiedEmail;
    map['verified_phone'] = _verifiedPhone;
    return map;
  }
}
