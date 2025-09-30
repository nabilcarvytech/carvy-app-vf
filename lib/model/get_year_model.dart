class GetYearModel {
  int? status;
  String? message;
  GetYeardata? getYeardata; // Use the correct type for the 'data' field

  GetYearModel({this.status, this.message, this.getYeardata});

  GetYearModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    getYeardata =
        json['data'] != null ? GetYeardata.fromJson(json['data']) : null;
  }
}

class GetYeardata {
  List<dynamic>? getYear;

  GetYeardata({this.getYear});

  GetYeardata.fromJson(Map<String, dynamic> json) {
    getYear =
        json['getYear'] != null ? List<dynamic>.from(json['getYear']) : null;
  }
}
