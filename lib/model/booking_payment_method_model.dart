class BookingPaymentMethodModel {
  int? status;
  String? message;
  BookingPaymentMethodData? data;
  String? error;

  BookingPaymentMethodModel({this.status, this.message, this.data, this.error});

  BookingPaymentMethodModel.fromJson(Map<String, dynamic> json) {
    status = json['status'] as int?;
    message = json['message'] as String?;
    data = json['data'] != null
        ? BookingPaymentMethodData.fromJson(json['data'])
        : null;
    error = json['error'] as String?;
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
      'error': error,
    };
  }
}

class BookingPaymentMethodData {
  List<PaymentMethod>? paymentMethods;

  BookingPaymentMethodData({this.paymentMethods});

  BookingPaymentMethodData.fromJson(Map<String, dynamic> json) {
    if (json['payment_methods'] != null) {
      paymentMethods = (json['payment_methods'] as List)
          .map((v) => PaymentMethod.fromJson(v))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_methods':
          paymentMethods?.map((v) => v.toJson()).toList(),
    };
  }
}

class PaymentMethod {
  String? id;
  String? name;
  String? logoUrl;
  String? type;
  String? instructions;
  double? feePercentage;
  bool? status;

  PaymentMethod({
    this.id,
    this.name,
    this.logoUrl,
    this.type,
    this.instructions,
    this.feePercentage,
    this.status,
  });

  PaymentMethod.fromJson(Map<String, dynamic> json) {
    // Mapper _id (MongoDB) ou id (API standard) vers id (String)
    id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    
    name = json['name'] as String?;
    logoUrl = json['logo_url'] as String?;
    type = json['type'] as String?;
    instructions = json['instructions'] as String?;
    
    // Conversion robuste de fees en double
    // Priorité: fee_percentage > fees
    if (json['fee_percentage'] != null) {
      feePercentage = (json['fee_percentage'] as num?)?.toDouble() ?? 0.0;
    } else if (json['fees'] != null) {
      feePercentage = (json['fees'] as num?)?.toDouble() ?? 0.0;
    } else {
      feePercentage = 0.0;
    }
    
    status = json['status'] == true || json['status'] == 1 || json['status'] == "true";
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_url': logoUrl,
      'type': type,
      'instructions': instructions,
      'fee_percentage': feePercentage,
      'status': status,
    };
  }
}

