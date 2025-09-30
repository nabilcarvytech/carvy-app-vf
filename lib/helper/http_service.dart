import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carvy/api/config.dart';
import 'package:carvy/controller/general_controller.dart';
import 'package:carvy/controller/search_controller.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/utils/common_widget.dart';
import '../work_space.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

bool printHeaders = false;

Future<dynamic> httpGet(String path, Map<String, dynamic> data) async {
  SearchControllerHome filterController = Get.find();
  connectionLost = false;
  Map<String, dynamic>? responseData;

  try {
    String apiBaseUrl = Config.baseurl;
    var url = apiBaseUrl + path;

    if (bearerToken.isEmpty) {
      bearerToken = await generateToken() ?? "";
      if (bearerToken.isEmpty) {
        return {"error": "Token generation failed"};
      }
    }

    // Set headers
    var headers = {
      'Content-Type': 'application/json',
      'x-auth-token': token,
      'Authorization': "Bearer $bearerToken",
    };
    data['token'] = token;
    data['module_id'] = '2';
    data['default_currency_code'] =
        generalDataModel?.data?.metaData?.generalDefaultCurrency ?? '';
    data['selected_currency_code'] = currency;
    data['item_type'] = filterController.globalItemType.value;
    data['latitude'] = latitudeGlobal;
    data['longitude'] = longitudeGlobal;
    data['time_zone'] = timeZoneOffset;
    data['lang'] = globallanguage.toString().substring(0, 2);

    String queryString = Uri(
      queryParameters:
          data.map((key, value) => MapEntry(key, value.toString())),
    ).query;
    var fullUrl = '$url?$queryString';

    final response = await http.get(Uri.parse(fullUrl), headers: headers);

    responseData = jsonDecode(response.body);

    if (responseData!['ResponseCode'] == 419) {
      loginExpireAlertoexitfromappt();
      Future.delayed(const Duration(seconds: 3), () {
        logout();
      });
      return responseData;
    }

    // Handle token expiration (498)
    if (response.statusCode == 498) {
      final newToken = await generateToken();
      if (newToken != null && newToken.isNotEmpty) {
        bearerToken = newToken;
        headers['Authorization'] = 'Bearer $newToken';

        // Retry the GET request
        final retryResponse =
            await http.get(Uri.parse(fullUrl), headers: headers);
        responseData = jsonDecode(retryResponse.body);
      } else {
        return {'error': 'Token regeneration failed'};
      }
    }

    // Log the response
  } catch (err) {
    if (err is http.ClientException ||
        err is TimeoutException ||
        err is SocketException) {
      connectionLost = true;
    } else if (err is FormatException) {
      connectionLost = true;
    } else {}
    return {'error': err.toString()};
  }

  return responseData;
}

bool shouldLogout = false;
Future<dynamic> httpPost(path, data) async {
  SearchControllerHome filterController = Get.find();
  connectionLost = false;
  try {
    String apiBaseUrl = Config.baseurl;
    var url = apiBaseUrl + path;

    if (bearerToken.isEmpty) {
      bearerToken = await generateToken() ?? "";
    }
    var headers = {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $bearerToken",
    };

    data['token'] = token;
    data['module_id'] = "2";
    data['default_currency_code'] =
        generalDataModel?.data?.metaData?.generalDefaultCurrency ?? "";
    data['selected_currency_code'] = currency;
    data['item_type'] = "${filterController.globalItemType.value}";
    data['latitude'] = latitudeGlobal;
    data['longitude'] = longitudeGlobal;
    data['time_zone'] = timeZoneOffset;
    data['lang'] = globallanguage.toString().substring(0, 2);

    var result = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(data),
    );

    var responseData = json.decode(const Utf8Codec().decode(result.bodyBytes));

    if (responseData['ResponseCode'] == 419) {
      loginExpireAlertoexitfromappt();
      Future.delayed(const Duration(seconds: 3), () {
        logout();
      });
    }
    if (responseData['ResponseCode'] == 498) {
      final newToken = await generateToken();
      if (newToken != null) {
        bearerToken = newToken;

        headers["Authorization"] = "Bearer $newToken";
        var retryResult = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(data), // ✅ also encode here
        );

        responseData =
            json.decode(const Utf8Codec().decode(retryResult.bodyBytes));
      } else {
        return {"error": "Token regeneration failed"};
      }
    }
    if (responseData['ResponseMsg'] == "The selected token is invalid.") {
      loginExpireAlertoexitfromappt();
      Future.delayed(const Duration(seconds: 3), () {
        logout();
      });
    }

    return responseData;
  } catch (err) {
    print("❌ Error: $err");
    if (err is FormatException) {
      connectionLost = true;
    }
  }
}

Future<String?>? _tokenFuture;
Future<String?> generateToken() async {
  if (_tokenFuture != null) {
    return _tokenFuture;
  }

  final completer = Completer<String?>();
  _tokenFuture = completer.future;

  try {
    const String url = '${Config.baseurlForBearer}${Config.generateToken}';
    const Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    Map<String, dynamic> body = {
      "secret": Config.secretKey,
      "user_token": token
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      final token = data['data']["token"].toString();
      bearerToken = token;

      GetStorage().write("bearerToken", token);

      completer.complete(token);
    } else if (response.statusCode == 419) {
      showErrorToastMessage("Session expired. Please log in again.");
      loginExpireAlertoexitfromappt();
      Future.delayed(const Duration(seconds: 3), () {
        logout();
      });
    } else {
      completer.complete(null);
    }
  } catch (e) {
    completer.complete(null);
  } finally {
    _tokenFuture = null;
  }

  return await completer.future;
}
