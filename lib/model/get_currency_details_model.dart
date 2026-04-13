
class CurrencyModel {
  bool? success;
  List<Data>? data;

  CurrencyModel({ success,  data});

  CurrencyModel.fromJson(Map<String, dynamic> json) {
    success = json["success"];
    data = json["data"] == null ? null : (json["data"] as List).map((e) => Data.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> datas = <String, dynamic>{};
    datas["success"] = success;
    if(data != null) {
      datas["data"] = data?.map((e) => e.toJson()).toList();
    }
    return datas;
  }
}

class Data {
  dynamic id;
  dynamic currencyName;
  dynamic currencyCode;
  dynamic valueAgainstDefaultCurrency;
  dynamic currencySymbol;

  Data({ id,  currencyName,  currencyCode,  valueAgainstDefaultCurrency,  currencySymbol});

  Data.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    currencyName = json["currency_name"];
    currencyCode = json["currency_code"];
    valueAgainstDefaultCurrency = json["value_against_default_currency"];
    currencySymbol = json["currency_symbol"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["currency_name"] = currencyName;
    data["currency_code"] = currencyCode;
    data["value_against_default_currency"] = valueAgainstDefaultCurrency;
    data["currency_symbol"] = currencySymbol;
    return data;
  }
}
