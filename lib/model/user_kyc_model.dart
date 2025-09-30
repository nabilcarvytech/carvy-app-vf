
class UserKYC {
  int? status;
  String? message;
  Data? data;
  String? error;

  UserKYC({this.status, this.message, this.data, this.error});

  factory UserKYC.fromJson(Map<String, dynamic> json) {
    return UserKYC(
      status: json['status'] as int?,
      message: json['message'] as String?,
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
      error: json['error']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data?.toJson(),
        'error': error,
      };
}

class Data {
  final KycImages kycImages;
  final KycReferenceData? kycReferenceData;
  final String kycStatus;

  Data({
    required this.kycImages,
    required this.kycReferenceData,
    required this.kycStatus,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      kycImages: KycImages.fromJson(json['kyc_images'] ?? {}),
      kycReferenceData: json['kyc_reference_data'] != null
          ? KycReferenceData.fromJson(json['kyc_reference_data'])
          : null,
      kycStatus: json['kyc_status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'kyc_images': kycImages.toJson(),
        'kyc_reference_data': kycReferenceData?.toJson(),
        'kyc_status': kycStatus,
      };
}

class KycImages {
  String? aadharFrontImage;
  String? aadharBackImage;
  String? otherIdentityFrontImage;
  String? otherIdentityBackImage;

  KycImages({
    this.aadharFrontImage,
    this.aadharBackImage,
    this.otherIdentityFrontImage,
    this.otherIdentityBackImage,
  });

  factory KycImages.fromJson(Map<String, dynamic> json) {
    return KycImages(
      aadharFrontImage: json['driver_license_front_image'] as String?,
      aadharBackImage: json['driver_license_back_image'] as String?,
      otherIdentityFrontImage: json['other_identity_front_image'] as String?,
      otherIdentityBackImage: json['other_identity_back_image'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'driver_license_front_image': aadharFrontImage,
        'driver_license_back_image': aadharBackImage,
        'other_identity_front_image': otherIdentityFrontImage,
        'other_identity_back_image': otherIdentityBackImage,
      };
}
class KycReferenceData {
  String? _referencePrimaryMobileNo;
  String? _referencePrimaryCountryCode;
  String? _referencePrimaryCountryShortCode;
  String? _referenceSecondaryMobileNo;
  String? _referenceSecondaryCountryCode;
  String? _referenceSecondaryCountryShortCode;

  KycReferenceData({
    String? referencePrimaryMobileNo,
    String? referencePrimaryCountryCode,
    String? referencePrimaryCountryShortCode,
    String? referenceSecondaryMobileNo,
    String? referenceSecondaryCountryCode,
    String? referenceSecondaryCountryShortCode,
  }) {
    _referencePrimaryMobileNo = referencePrimaryMobileNo;
    _referencePrimaryCountryCode = referencePrimaryCountryCode ?? "+91";
    _referencePrimaryCountryShortCode = referencePrimaryCountryShortCode ?? "IN";
    _referenceSecondaryMobileNo = referenceSecondaryMobileNo;
    _referenceSecondaryCountryCode = referenceSecondaryCountryCode ?? "+91";
    _referenceSecondaryCountryShortCode = referenceSecondaryCountryShortCode ?? "IN";
  }

  // Getters with Default Values
  String get referencePrimaryMobileNo => _referencePrimaryMobileNo ?? "";
  String get referencePrimaryCountryCode => _referencePrimaryCountryCode ?? "+91";
  String get referencePrimaryCountryShortCode => _referencePrimaryCountryShortCode ?? "IN";

  String get referenceSecondaryMobileNo => _referenceSecondaryMobileNo ?? "";
  String get referenceSecondaryCountryCode => _referenceSecondaryCountryCode ?? "+91";
  String get referenceSecondaryCountryShortCode => _referenceSecondaryCountryShortCode ?? "IN";

  // Setters (Optional: If you want to allow updates)
  set referencePrimaryMobileNo(String value) => _referencePrimaryMobileNo = value;
  set referencePrimaryCountryCode(String value) => _referencePrimaryCountryCode = value;
  set referencePrimaryCountryShortCode(String value) => _referencePrimaryCountryShortCode = value;

  set referenceSecondaryMobileNo(String value) => _referenceSecondaryMobileNo = value;
  set referenceSecondaryCountryCode(String value) => _referenceSecondaryCountryCode = value;
  set referenceSecondaryCountryShortCode(String value) => _referenceSecondaryCountryShortCode = value;

  factory KycReferenceData.fromJson(Map<String, dynamic> json) {
    return KycReferenceData(
      referencePrimaryMobileNo: json['reference_primary_mobile_no'] as String?,
      referencePrimaryCountryCode: json['reference_primary_country_code'] as String?,
      referencePrimaryCountryShortCode: json['reference_primary_country_short_code'] as String?,
      referenceSecondaryMobileNo: json['reference_secondary_mobile_no'] as String?,
      referenceSecondaryCountryCode: json['reference_secondary_country_code'] as String?,
      referenceSecondaryCountryShortCode: json['reference_secondary_country_short_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'reference_primary_mobile_no': _referencePrimaryMobileNo,
        'reference_primary_country_code': _referencePrimaryCountryCode,
        'reference_primary_country_short_code': _referencePrimaryCountryShortCode,
        'reference_secondary_mobile_no': _referenceSecondaryMobileNo,
        'reference_secondary_country_code': _referenceSecondaryCountryCode,
        'reference_secondary_country_short_code': _referenceSecondaryCountryShortCode,
      };
}