class BookdDate {
  int? status;
  String? message;
  Data? data;
  String? error;

  BookdDate({this.status, this.message, this.data, this.error});

  BookdDate.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['error'] = error;
    return data;
  }
}

class Data {
  List<ItemBookingDate>? itemBookingDate;

  Data({this.itemBookingDate});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['itemBookingDate'] != null) {
      itemBookingDate = <ItemBookingDate>[];
      json['itemBookingDate'].forEach((v) {
        itemBookingDate!.add(ItemBookingDate.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (itemBookingDate != null) {
      data['itemBookingDate'] = itemBookingDate!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ItemBookingDate {
  String? checkIn;
  String? checkOut;

  ItemBookingDate({this.checkIn, this.checkOut});

  ItemBookingDate.fromJson(Map<String, dynamic> json) {
    checkIn = json['check_in'];
    checkOut = json['check_out'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['check_in'] = checkIn;
    data['check_out'] = checkOut;
    return data;
  }
}