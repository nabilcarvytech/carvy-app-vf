class SignatureDataResponse {
  final int success;
  final String message;
  final SignatureData data;

  SignatureDataResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SignatureDataResponse.fromJson(Map<String, dynamic> json) {
    return SignatureDataResponse(
      success: json['success'] as int,
      message: json['message'] as String,
      data: SignatureData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class SignatureData {
  final String bookingId;
  final int userSigned;
  final int vendorSigned;
  final SignatureUrl? userSignatureUrl; // Made nullable
  final SignatureUrl? vendorSignatureUrl; // Made nullable

  SignatureData({
    required this.bookingId,
    required this.userSigned,
    required this.vendorSigned,
    this.userSignatureUrl, // Nullable, no required
    this.vendorSignatureUrl, // Nullable, no required
  });

  factory SignatureData.fromJson(Map<String, dynamic> json) {
    return SignatureData(
      bookingId: json['booking_id'] as String,
      userSigned: json['user_signed'] as int,
      vendorSigned: json['vendor_signed'] as int,
      userSignatureUrl: json['user_signature_url'] is Map<String, dynamic>
          ? SignatureUrl.fromJson(json['user_signature_url'] as Map<String, dynamic>)
          : null, // Handle empty string or invalid data
      vendorSignatureUrl: json['vendor_signature_url'] is Map<String, dynamic>
          ? SignatureUrl.fromJson(json['vendor_signature_url'] as Map<String, dynamic>)
          : null, // Handle empty string or invalid data
    );
  }
}

class SignatureUrl {
  final String url;
  final String thumb;
  final String preview;

  SignatureUrl({
    required this.url,
    required this.thumb,
    required this.preview,
  });

  factory SignatureUrl.fromJson(Map<String, dynamic> json) {
    return SignatureUrl(
      url: json['url'] as String? ?? '', // Fallback to empty string if null
      thumb: json['thumb'] as String? ?? '', // Fallback to empty string if null
      preview: json['preview'] as String? ?? '', // Fallback to empty string if null
    );
  }
}