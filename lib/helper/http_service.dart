import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:carvy/api/config.dart';
import 'package:carvy/controller/general_controller.dart';
import 'package:carvy/controller/search_controller.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../work_space.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'dart:developer' as developer;

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
        developer.log("❌ Failed to generate bearer token");
        return {"error": "Token generation failed"};
      }
    }
    var headers = {
      'Content-Type': 'application/json',
      'x-auth-token': token,
      'Authorization': "Bearer $bearerToken",
    };
    print("Bearer Token: $bearerToken");
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

    developer.log('🌐 Api-Url: $fullUrl');
    developer.log('📋 Parameters: ${jsonEncode(data)}');

    final response = await http.get(Uri.parse(fullUrl), headers: headers);

    responseData = jsonDecode(response.body);

    if (responseData!['ResponseCode'] == 419) {
      loginExpireAlertoexitfromappt();
      Future.delayed(const Duration(seconds: 3), () {
        logout();
      });
      return responseData;
    }

    if (response.statusCode == 498) {
      developer.log('❌ Token expired (498) — regenerating...');

      final newToken = await generateToken();
      if (newToken != null && newToken.isNotEmpty) {
        bearerToken = newToken;
        headers['Authorization'] = 'Bearer $newToken';

        final retryResponse =
            await http.get(Uri.parse(fullUrl), headers: headers);
        responseData = jsonDecode(retryResponse.body);

        developer.log('🔁 Retried Response: $responseData');
      } else {
        developer.log('❌ Token regeneration failed');
        return {'error': 'Token regeneration failed'};
      }
    }

    developer.log('✅ Response: $responseData');
  } catch (err, stackTrace) {
    if (err is http.ClientException ||
        err is TimeoutException ||
        err is SocketException) {
      connectionLost = true;
      developer.log('📡 Connection error: $err', stackTrace: stackTrace);
    } else if (err is FormatException) {
      connectionLost = true;
      developer.log('📜 Format error in response: $err',
          stackTrace: stackTrace);
    } else {
      developer.log('❗ Unexpected error: $err', stackTrace: stackTrace);
    }
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
    print("Bearer Token: $bearerToken");
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
    log("Api-Url: $url");
    log("Request Body:\n${const JsonEncoder.withIndent('  ').convert(data)}");

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
      log("❌ Token expired (498) — regenerating...");

      final newToken = await generateToken();
      if (newToken != null) {
        bearerToken = newToken;

        headers["Authorization"] = "Bearer $newToken";
        var retryResult = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(data),
        );

        responseData =
            json.decode(const Utf8Codec().decode(retryResult.bodyBytes));
        log("🔁 Retried Response: $responseData");
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
    log("Response: $responseData");
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
    print("url is $url");

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    print(response.body);

    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      final token = data['data']["token"].toString();
      bearerToken = token;
      log("✅ Generated Bearer Token: $token");
      GetStorage().write("bearerToken", token);

      completer.complete(token);
    } else if (response.statusCode == 419) {
      showErrorToastMessage("Session expired. Please log in again.");
      loginExpireAlertoexitfromappt();
      Future.delayed(const Duration(seconds: 3), () {
        logout();
      });
    } else {
      log("❌ Token generation failed: ${data.toString()}");
      completer.complete(null);
    }
  } catch (e) {
    log("❌ Token generation error: $e");
    completer.complete(null);
  } finally {
    _tokenFuture = null;
  }

  return await completer.future;
}
