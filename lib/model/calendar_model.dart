class CalendarItemId {
  int? status;
  String? message;
  Data? data;
  String? error;

  CalendarItemId({int? status, String? message, Data? data, String? error}) {
    if (status != null) {
      this.status = status;
    }
    if (message != null) {
      this.message = message;
    }
    if (data != null) {
      this.data = data;
    }
    if (error != null) {
      this.error = error;
    }
  }

  CalendarItemId.fromJson(Map<String, dynamic> json) {
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
  ItemDates? itemDates;

  Data({ItemDates? itemDates}) {
    if (itemDates != null) {
      this.itemDates = itemDates;
    }
  }

  Data.fromJson(Map<String, dynamic> json) {
    itemDates = json['ItemDates'] != null
        ? ItemDates.fromJson(json['ItemDates'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (itemDates != null) {
      data['ItemDates'] = itemDates!.toJson();
    }
    return data;
  }
}

class ItemDates {
  String? price;
  List<AvailableDates>? availableDates;
  List<NotAvailableDates>? notAvailableDates;
  List<BookedDates>? bookedDates;

  ItemDates({
    String? price,
    List<AvailableDates>? availableDates,
    List<NotAvailableDates>? notAvailableDates,
    List<BookedDates>? bookedDates,
  }) {
    if (price != null) {
      this.price = price;
    }
    if (availableDates != null) {
      this.availableDates = availableDates;
    }
    if (notAvailableDates != null) {
      this.notAvailableDates = notAvailableDates;
    }
    if (bookedDates != null) {
      this.bookedDates = bookedDates;
    }
  }

  ItemDates.fromJson(Map<String, dynamic> json) {
    price = json['price'];
    if (json['available_dates'] != null) {
      availableDates = <AvailableDates>[];
      json['available_dates'].forEach((v) {
        availableDates!.add(AvailableDates.fromJson(v));
      });
    }
    if (json['not_available_dates'] != null) {
      notAvailableDates = <NotAvailableDates>[];
      json['not_available_dates'].forEach((v) {
        notAvailableDates!.add(NotAvailableDates.fromJson(v));
      });
    }
    if (json['booked_dates'] != null) {
      bookedDates = <BookedDates>[];
      json['booked_dates'].forEach((v) {
        bookedDates!.add(BookedDates.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['price'] = price;
    if (availableDates != null) {
      data['available_dates'] = availableDates!.map((v) => v.toJson()).toList();
    }
    if (notAvailableDates != null) {
      data['not_available_dates'] =
          notAvailableDates!.map((v) => v.toJson()).toList();
    }
    if (bookedDates != null) {
      data['booked_dates'] = bookedDates!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AvailableDates {
  String? date;
  dynamic price;

  AvailableDates({String? date, String? price}) {
    if (date != null) {
      this.date = date;
    }
    if (price != null) {
      this.price = price;
    }
  }

  AvailableDates.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['price'] = price;
    return data;
  }
}

class BookedDates {
  String? date;
  String? price;

  BookedDates({String? date, String? price}) {
    if (date != null) {
      this.date = date;
    }
    if (price != null) {
      this.price = price;
    }
  }

  BookedDates.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['price'] = price;
    return data;
  }
}

class NotAvailableDates {
  String? date;

  NotAvailableDates({String? date}) {
    if (date != null) {
      this.date = date;
    }
  }

  NotAvailableDates.fromJson(Map<String, dynamic> json) {
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    return data;
  }
}
