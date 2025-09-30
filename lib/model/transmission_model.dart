class Transmission {
  int? status;
  String? message;
  Data? data;
  String? error;

  Transmission({ status,  message,  data,  error});

  Transmission.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ?   Data.fromJson(json['data']) : null;
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] =  status;
    data['message'] =  message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['error'] = error;
    return data;
  }
}

class Data {
  List<Options>? options;

  Data({this.options});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['options'] != null) {
      options = <Options>[];
      json['options'].forEach((v) {
        options!.add(  Options.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =   <String, dynamic>{};
    if (options != null) {
      data['options'] =  options!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Options {
  String? option;

  Options({this.option});

  Options.fromJson(Map<String, dynamic> json) {
    option = json['option'];
  }
  String? get name => option;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =   <String, dynamic>{};
    data['option'] = option;
    return data;
  }
}
