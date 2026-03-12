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


  // ========== MOCK DATA - get-digital-signature API ==========
  // TODO: REMOVE THIS MOCK AFTER NODE.JS BACKEND IMPLEMENTATION
  if (path == Config.getDigitalSingnature) {
    await Future.delayed(const Duration(seconds: 1));

    // Simule les URLs de signature numérique pour une réservation.
    Map<String, dynamic> mockResponse = {
      "success": 200,
      "message": "Digital signature data retrieved successfully",
      "data": {
        "booking_id": data["booking_id"]?.toString() ?? "1234567890",
        "user_signed": 1,
        "vendor_signed": 1,
        "user_signature_url": {
          "url": "https://example.com/signatures/user_signature.png",
          "thumb": "https://example.com/signatures/user_signature_thumb.png",
          "preview": "https://example.com/signatures/user_signature_preview.png"
        },
        "vendor_signature_url": {
          "url": "https://example.com/signatures/vendor_signature.png",
          "thumb": "https://example.com/signatures/vendor_signature_thumb.png",
          "preview":
              "https://example.com/signatures/vendor_signature_preview.png"
        }
      }
    };

    developer.log(
        "⚠️ MOCK MODE: Returning mock get-digital-signature data for booking_id: ${data['booking_id']}");
    return mockResponse;
  }
  // ========== END MOCK DATA ==========

  // ========== MOCK DATA - get-item-dates API ==========
  // TODO: REMOVE THIS MOCK AFTER NODE.JS BACKEND IMPLEMENTATION
  if (path == Config.getItemDates) {
    await Future.delayed(const Duration(seconds: 1));

    // This simulates calendar data for an item:
    // - available_dates: dates où l'item est disponible
    // - not_available_dates: dates bloquées (ex: maintenance)
    // - booked_dates: dates déjà réservées
    Map<String, dynamic> mockResponse = {
      "status":00,
      "message": "Item dates retrieved successfully",
      "error": "",
      "data": {
        "ItemDates": {
          "price": "50.00",
          "available_dates": [
            {"date": "2024-12-18", "price": "50.00"},
            {"date": "2024-12-19", "price": "50.00"},
            {"date": "2024-12-23", "price": "55.00"}
          ],
          "not_available_dates": [
            {"date": "2024-12-20", "price": "0.00"},
            {"date": "2024-12-21", "price": "0.00"}
          ],
          "booked_dates": [
            {"date": "2024-12-25", "price": "60.00"},
            {"date": "2024-12-26", "price": "60.00"}
          ]
        }
      }
    };

    developer.log(
        "⚠️ MOCK MODE: Returning mock get-item-dates data for item_id: ${data['item_id']}");
    return mockResponse;
  }
  // ========== END MOCK DATA ==========

  // ========== MOCK DATA - get-cancellation-policies API ==========
  // TODO: REMOVE THIS MOCK AFTER NODE.JS BACKEND IMPLEMENTATION
  if (path == Config.getCancellationPolicies) {
    await Future.delayed(const Duration(seconds: 1));

    Map<String, dynamic> mockResponse = {
      "status": 200,
      "message": "Cancellation policies retrieved successfully",
      "error": "",
      "data": {
        "cancellation_policies": [
          {
            "id": 1,
            "name": "Normal Policy",
            "description":
                "Standard cancellation policy with moderate refund terms",
            "type": "normal",
            "value": "50",
            "status": "1",
            "created_at": "2024-01-01T00:00:00.000Z",
            "updated_at": "2024-01-01T00:00:00.000Z"
          },
          {
            "id": 2,
            "name": "Super Policy",
            "description":
                "Premium cancellation policy with flexible refund terms",
            "type": "super",
            "value": "80",
            "status": "1",
            "created_at": "2024-01-01T00:00:00.000Z",
            "updated_at": "2024-01-01T00:00:00.000Z"
          },
          {
            "id": 3,
            "name": "Flexible Policy",
            "description":
                "Most flexible cancellation policy with full refund options",
            "type": "flexible",
            "value": "100",
            "status": "1",
            "created_at": "2024-01-01T00:00:00.000Z",
            "updated_at": "2024-01-01T00:00:00.000Z"
          }
        ]
      }
    };

    developer
        .log("⚠️ MOCK MODE: Returning mock get-cancellation-policies data");
    return mockResponse;
  }
  // ========== END MOCK DATA ==========

  // ========== MOCK DATA - get-item-rules API ==========
  // TODO: REMOVE THIS MOCK AFTER NODE.JS BACKEND IMPLEMENTATION
  if (path == Config.getItemRules) {
    await Future.delayed(const Duration(seconds: 1));

    Map<String, dynamic> mockResponse = {
      "status": 200,
      "message": "Item rules retrieved successfully",
      "error": "",
      "data": {
        "booking_rules": [
          {
            "id": 1,
            "rule_name":
                "It is forbidden to lend, rent, or sublease the car to a third party.",
            "status": "1",
            "created_at": "2024-01-01T00:00:00.000Z",
            "updated_at": "2024-01-01T00:00:00.000Z"
          },
          {
            "id": 2,
            "rule_name":
                "The vehicle must be returned with the same fuel level as at pickup.",
            "status": "1",
            "created_at": "2024-01-01T00:00:00.000Z",
            "updated_at": "2024-01-01T00:00:00.000Z"
          },
          {
            "id": 3,
            "rule_name": "Smoking and eating inside the car are not allowed.",
            "status": "1",
            "created_at": "2024-01-01T00:00:00.000Z",
            "updated_at": "2024-01-01T00:00:00.000Z"
          },
          {
            "id": 4,
            "rule_name":
                "The vehicle must be returned on the agreed date, time, and location.",
            "status": "1",
            "created_at": "2024-01-01T00:00:00.000Z",
            "updated_at": "2024-01-01T00:00:00.000Z"
          }
        ]
      }
    };

    developer.log("⚠️ MOCK MODE: Returning mock get-item-rules data");
    return mockResponse;
  }
  // ========== END MOCK DATA ==========

  // ========== MOCK DATA - your-locations API ==========
  // TODO: REMOVE THIS MOCK AFTER NODE.JS BACKEND IMPLEMENTATION
  if (path == Config.yourLocation) {
    await Future.delayed(const Duration(seconds: 1));

    Map<String, dynamic> mockResponse = {
      "status": 200,
      "message": "Locations retrieved successfully",
      "error": "",
      "data": {
        "locations": [
          {
            "id": 1,
            "city_name": "Rabat",
            "description": "Rabat, Morocco",
            "latitude": "34.020882",
            "longitude": "-6.841650",
            "country": "Morocco",
            "state_region": "Rabat-Salé-Kénitra"
          },
          {
            "id": 2,
            "city_name": "Casablanca",
            "description": "Casablanca, Morocco",
            "latitude": "33.573110",
            "longitude": "-7.589843",
            "country": "Morocco",
            "state_region": "Casablanca-Settat"
          },
          {
            "id": 3,
            "city_name": "Marrakesh",
            "description": "Marrakesh, Morocco",
            "latitude": "31.629473",
            "longitude": "-7.981084",
            "country": "Morocco",
            "state_region": "Marrakesh-Safi"
          }
        ]
      }
    };

    developer
        .log("⚠️ MOCK MODE: Returning mock your-locations data (host regions)");
    return mockResponse;
  }
  // ========== END MOCK DATA ==========

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

/// Version de httpGet pour les routes admin qui n'ajoute pas les paramètres automatiques
/// (token, module_id, latitude, longitude, etc.) dans l'URL
/// Le token passe uniquement dans le Header Authorization
/// Utilise adminBaseUrl (sans /v1) pour les routes admin
Future<dynamic> httpGetAdmin(String path, Map<String, dynamic> params) async {
  connectionLost = false;

  Map<String, dynamic>? responseData;
  try {
    // Utiliser adminBaseUrl (sans /v1) pour les routes admin
    String apiBaseUrl = Config.adminBaseUrl;
    var url = apiBaseUrl + path;
    
    // Générer le bearer token si nécessaire
    if (bearerToken.isEmpty) {
      bearerToken = await generateToken() ?? "";
      if (bearerToken.isEmpty) {
        developer.log("❌ Failed to generate bearer token");
        return {"error": "Token generation failed"};
      }
    }
    
    // Headers avec uniquement le token (pas de x-auth-token dans l'URL)
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer $bearerToken",
    };
    
    // Construire l'URL avec uniquement les params fournis (pas de params automatiques)
    String queryString = '';
    if (params.isNotEmpty) {
      queryString = Uri(
        queryParameters: params.map((key, value) => MapEntry(key, value.toString())),
      ).query;
    }
    
    var fullUrl = queryString.isNotEmpty ? '$url?$queryString' : url;

    developer.log('🌐 [ADMIN] Api-Url: $fullUrl');
    developer.log('📋 [ADMIN] Parameters: ${jsonEncode(params)}');
    developer.log('🔑 [ADMIN] Bearer Token: ${bearerToken.substring(0, 20)}...');

    final response = await http.get(Uri.parse(fullUrl), headers: headers);

    responseData = jsonDecode(response.body);

    if (response.statusCode == 498) {
      developer.log('❌ [ADMIN] Token expired (498) — regenerating...');

      final newToken = await generateToken();
      if (newToken != null && newToken.isNotEmpty) {
        bearerToken = newToken;
        headers['Authorization'] = 'Bearer $newToken';

        final retryResponse = await http.get(Uri.parse(fullUrl), headers: headers);
        responseData = jsonDecode(retryResponse.body);

        developer.log('🔁 [ADMIN] Retried Response: $responseData');
      } else {
        developer.log('❌ [ADMIN] Token regeneration failed');
        return {'error': 'Token regeneration failed'};
      }
    }

    developer.log('✅ [ADMIN] Response: $responseData');
  } catch (err, stackTrace) {
    if (err is http.ClientException ||
        err is TimeoutException ||
        err is SocketException) {
      connectionLost = true;
      developer.log('📡 [ADMIN] Connection error: $err', stackTrace: stackTrace);
    } else if (err is FormatException) {
      connectionLost = true;
      developer.log('📜 [ADMIN] Format error in response: $err',
          stackTrace: stackTrace);
    } else {
      developer.log('❗ [ADMIN] Unexpected error: $err', stackTrace: stackTrace);
    }
    return {'error': err.toString()};
  }

  return responseData;
}

bool shouldLogout = false;
Future<dynamic> httpPost(path, data) async {
  // ========== EMERGENCY DEBUG: Logs au tout début pour détecter les échecs silencieux ==========
  print("🚨 [STOP CHECK] ========================================");
  print("🚨 [STOP CHECK] 1. httpPost called for path: $path");
  print("🚨 [STOP CHECK] 1b. Full URL will be: ${Config.baseurl}$path");
  print("🚨 [STOP CHECK] 1c. Request data: $data");
  // ========== END EMERGENCY DEBUG ==========

  try {
    SearchControllerHome filterController = Get.find();
    print("🚨 [STOP CHECK] 1d. FilterController found successfully");
    connectionLost = false;
    print("🚨 [STOP CHECK] 1e. connectionLost reset to false");
  } catch (e) {
    print("🚨 [STOP CHECK] CRASH getting FilterController: $e");
    return {"error": "Failed to get FilterController: $e"};
  }

  // ========== MOCK DATA REMOVED - getItemDetails API now uses real backend ==========
  // Le code mock a été supprimé pour permettre la connexion au serveur Node.js réel

  // ========== MOCK DATA - cancel-booking-by-user API ==========
  // ✅ MOCK REMOVED - Now using real Node.js backend
  // The request will be sent to the actual backend at: ${Config.baseurl}${Config.cancelBookingByUser}
  if (path == Config.cancelBookingByUser) {
    print('🚀 [FLUTTER_DEBUG] httpPost: cancel-booking-by-user detected, sending to real backend');
    print('🚀 [FLUTTER_DEBUG] Backend URL: ${Config.baseurl}${Config.cancelBookingByUser}');
    print('🚀 [FLUTTER_DEBUG] Request data: $data');
  }
  // ========== END MOCK DATA ==========

  // ========== MOCK DATA REMOVED - booking-record API now uses real backend ==========
  // Le code mock a été supprimé pour permettre la connexion au serveur Node.js réel
  // Voir lib/controller/booking_record_controller.dart pour l'implémentation
  // ========== END MOCK DATA ==========

  // ========== MOCK DATA REMOVED - vendor-booking-record API now uses real backend ==========
  // Le bloc MOCK a été supprimé définitivement pour activer la connexion au serveur Node.js réel
  // Toutes les requêtes vendor-booking-record seront maintenant envoyées au serveur Node.js
  // ========== END MOCK DATA ==========

  // ========== MOCK DATA REMOVED - confirm-booking-by-host API now uses real backend ==========
  // Le mock a été supprimé pour permettre l'envoi réel au serveur Node.js
  // Toutes les requêtes confirm-booking-by-host seront maintenant envoyées au serveur Node.js
  // ========== END MOCK DATA ==========

  // ========== MOCK DATA REMOVED - cancel-booking-by-host API now uses real backend ==========
  // Le mock a été supprimé pour permettre l'envoi réel au serveur Node.js
  // Toutes les requêtes cancel-booking-by-host seront maintenant envoyées au serveur Node.js
  // ========== END MOCK DATA ==========

  // ========== MOCK DATA - update-item-received-status API ==========
  // TODO: REMOVE THIS MOCK AFTER NODE.JS BACKEND IMPLEMENTATION
  // ========== MOCK DATA REMOVED - update-item-received-status API ==========
  // Mock removed to use real Node.js backend
  // ========== END MOCK DATA ==========
  // ========== END MOCK DATA ==========

  // ========== MOCK DATA - update-item-returned-status API ==========
  // TODO: REMOVE THIS MOCK AFTER NODE.JS BACKEND IMPLEMENTATION
  // ========== MOCK DATA REMOVED - update-item-returned-status API ==========
  // Mock removed to use real Node.js backend
  // ========== END MOCK DATA ==========
  // ========== END MOCK DATA ==========

  // ========== MOCK DATA - booking-payment-success API ==========
  // TODO: REMOVE THIS MOCK AFTER NODE.JS BACKEND IMPLEMENTATION
  if (path == Config.bookingpaymentsuccess) {
    await Future.delayed(const Duration(seconds: 1));

    // Simule la vérification du statut de paiement pour une réservation.
    Map<String, dynamic> mockResponse = {
      "status": 200,
      "message": "Payment verified successfully",
      "error": "",
      "data": {
        "booking_id": data["booking_id"]?.toString() ?? "1234567890",
        "payment_status": "success",
        "booking_status": "confirmed"
      }
    };

    developer.log(
        "⚠️ MOCK MODE: Returning mock booking-payment-success for booking_id: ${data['booking_id']}");
    return mockResponse;
  }
  // ========== END MOCK DATA ==========

  // ========== MOCK DATA - upload-per-booking-images (addInteriorImage) API ==========
  // ✅ REMOVED: Now using real Node.js backend for addInteriorImage
  // The request will be sent to the actual backend at: ${Config.baseurl}${Config.addInteriorImage}
  // if (path == Config.addInteriorImage) {
  //   await Future.delayed(const Duration(seconds: 1));
  //
  //   // Simule l'upload des images intérieures (per booking images).
  //   // Le code Flutter vérifie uniquement 'success' == 200 et 'message'.
  //   Map<String, dynamic> mockResponse = {
  //     "success": 200,
  //     "message": "Images uploaded successfully",
  //     "error": "",
  //     "data": {
  //       "booking_id": data["booking_id"]?.toString() ?? "1234567890",
  //       "uploaded_images_count":
  //           (data["per_booking_images"]?.toString().isNotEmpty ?? false)
  //               ? data["per_booking_images"].toString().split("##").length
  //               : 0
  //     }
  //   };
  //
  //   developer.log(
  //       "⚠️ MOCK MODE: Returning mock upload-per-booking-images for booking_id: ${data['booking_id']}");
  //   return mockResponse;
  // }
  // ========== END MOCK DATA ==========


  // ========== MOCK DATA - deleteItem API ==========
  // TODO: REMOVE THIS MOCK AFTER NODE.JS BACKEND IMPLEMENTATION
  if (path == Config.deleteItem) {
    await Future.delayed(const Duration(seconds: 1));

    Map<String, dynamic> mockResponse = {
      "status": 200,
      "message": "Vehicle deleted successfully",
      "error": "",
      "data": {"id": data["id"]?.toString() ?? "0", "deleted": true}
    };

    developer.log(
        "⚠️ MOCK MODE: Returning mock deleteItem response for id: ${data['id']}");
    return mockResponse;
  }
  // ========== END MOCK DATA ==========

  // ========== MOCKS REMOVED: add-to-wishlist and remove-from-wishlist now use real API ==========

  try {
    print("🚨 [STOP CHECK] 2. Entering try block - preparing request");
    String apiBaseUrl = Config.baseurl;
    var url = apiBaseUrl + path;
    print("🚨 [STOP CHECK] 2b. Full URL constructed: $url");
    print('🌐 [REAL_NETWORK] Tentative d\'envoi vers : ' + url);

    // Check if we have the User Token
    print("🚨 [STOP CHECK] 2c. Checking User Token (global variable)...");
    if (token.isEmpty) {
      print(
          "🚨 [STOP CHECK] 2. ERROR: User Token (global variable) is EMPTY! Cannot generate bearer.");
      // We might try to load it here as a fallback
      String? storageToken = GetStorage().read("raw_user_token");
      if (storageToken != null && storageToken.isNotEmpty) {
        token = storageToken;
        print(
            "🚨 [STOP CHECK] 2b. Attempted reload from storage. Token is now: '${token.length > 10 ? token.substring(0, 10) : token}...' (length: ${token.length})");
      } else {
        print(
            "🚨 [STOP CHECK] 2c. No token in storage either. Will generate GUEST bearer token.");
      }
    } else {
      print(
          "🚨 [STOP CHECK] 2d. User Token is VALID: '${token.length > 10 ? token.substring(0, 10) : token}...' (length: ${token.length})");
    }

    // Bearer Token Logic
    print("🚨 [STOP CHECK] 3. Checking Bearer Token...");
    if (bearerToken.isEmpty) {
      print(
          "🚨 [STOP CHECK] 3. Bearer Token is empty. Calling generateToken()...");
      try {
        bearerToken = await generateToken() ?? "";
        if (bearerToken.isNotEmpty) {
          print(
              "🚨 [STOP CHECK] 4. generateToken returned: '${bearerToken.length > 10 ? bearerToken.substring(0, 10) : bearerToken}...' (length: ${bearerToken.length})");
        } else {
          print("🚨 [STOP CHECK] 4. generateToken returned EMPTY!");
        }
      } catch (e, stackTrace) {
        print("🚨 [STOP CHECK] CRASH inside generateToken: $e");
        print("🚨 [STOP CHECK] Stack Trace: $stackTrace");
        return {"error": "Token generation failed: $e"};
      }
    } else {
      print(
          "🚨 [STOP CHECK] 3. Using existing Bearer Token: '${bearerToken.length > 10 ? bearerToken.substring(0, 10) : bearerToken}...' (length: ${bearerToken.length})");
    }

    if (bearerToken.isEmpty) {
      print(
          "🚨 [STOP CHECK] FATAL: Could not get a bearer token. Aborting request.");
      return {"error": "Bearer token generation failed"};
    }

    // Construct Headers
    print("🚨 [STOP CHECK] 5. Constructing headers...");
    var headers = {
      'Content-Type': 'application/json',
      'x-auth-token': token,
      "Authorization": "Bearer $bearerToken",
    };
    print(
        "🚨 [STOP CHECK] 5b. Headers ready. Authorization: 'Bearer ${bearerToken.length > 20 ? bearerToken.substring(0, 20) : bearerToken}...'");
    print("🚨 [STOP CHECK] 5c. Preparing request body...");
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

    // Correction de l'URL : Print spécifique pour l'endpoint KYC
    if (path == Config.getKYCDetails) {
      print(
          '🔗 [DEBUG] Tentative d\'appel sur : ${Config.baseurl}${Config.getKYCDetails}');
      print('🔗 [DEBUG] URL complète construite dans httpPost : $url');
    }

    // ========== AUTO-RETRY LOGIC: Handle 401 Unauthorized with automatic token refresh ==========
    bool hasRetried = false;
    http.Response result;

    // Debug print for cancel-booking-by-user
    if (path == Config.cancelBookingByUser) {
      print('🚀 [FLUTTER_DEBUG] About to send POST request to: $url');
      print('🚀 [FLUTTER_DEBUG] Request body: ${jsonEncode(data)}');
      print('🚀 [FLUTTER_DEBUG] Headers: ${headers.keys.join(", ")}');
    }

    // Debug print for cancel-booking-by-host
    if (path == Config.cancelBookingByHost) {
      print('🚀 [FLUTTER_DEBUG] About to send POST request to: $url');
      print('🚀 [FLUTTER_DEBUG] Request body: ${jsonEncode(data)}');
      print('🚀 [FLUTTER_DEBUG] Headers: ${headers.keys.join(", ")}');
      print('🚀 [FLUTTER_DEBUG] Authorization header: Bearer ${bearerToken.length > 20 ? bearerToken.substring(0, 20) + "..." : bearerToken}');
    }

    // ========== APPEL RÉEL POUR confirm-booking-by-host ==========
    if (path == Config.confirmBookingByHost) {
      print('🌐 [REAL_CALL] Envoi réel au serveur Node.js');
      print('🌐 [REAL_CALL] URL complète: http://10.0.2.2:5000/api/v1/confirm-booking-by-host');
      print('🌐 [REAL_CALL] Body: ${jsonEncode(data)}');
      // Vérification que le body contient bien booking_id et non item_id
      if (data.containsKey('booking_id')) {
        print('✅ [REAL_CALL] Body contient booking_id: ${data['booking_id']}');
      } else {
        print('⚠️ [REAL_CALL] ATTENTION: Body ne contient pas booking_id!');
        print('⚠️ [REAL_CALL] Clés disponibles: ${data.keys.join(", ")}');
      }
    }
    // ========== END APPEL RÉEL ==========

    // ========== LOG DE SÉCURITÉ - Confirmation d'envoi réel au serveur ==========
    print('🌍 [NETWORK] >>> ENVOI RÉEL AU SERVEUR NODE.JS : $url');
    // ========== END LOG DE SÉCURITÉ ==========

    // ========== LOGS VERBEUX POUR DÉBOGAGE ==========
    print('🌐 [HTTP REQUEST] POST vers: $url');
    print('🔐 [HTTP HEADERS] Content-Type: ${headers['Content-Type']}');
    print('🔐 [HTTP HEADERS] x-auth-token: ${headers['x-auth-token'] != null ? (headers['x-auth-token']!.toString().length > 20 ? "${headers['x-auth-token']!.toString().substring(0, 20)}..." : headers['x-auth-token']) : "NULL"}');
    print('🔐 [HTTP HEADERS] Authorization: ${headers['Authorization'] != null ? (headers['Authorization']!.toString().length > 30 ? "${headers['Authorization']!.toString().substring(0, 30)}..." : headers['Authorization']) : "NULL"}');
    print('📝 [HTTP BODY] ${jsonEncode(data)}');
    // ========== END LOGS VERBEUX ==========

    // First attempt
    result = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(data),
    );
    
    // ========== LOGS DE RÉPONSE ==========
    print('📥 [HTTP RESPONSE] Status: ${result.statusCode}');
    print('📄 [HTTP RESPONSE BODY] ${result.body}');
    
    // Logs spécifiques pour fcmUpdate (OneSignal)
    if (path == Config.fcmUpdate) {
      print('📥 [FLUTTER RESPONSE] Status: ${result.statusCode}');
      print('📄 [FLUTTER RESPONSE BODY] ${result.body}');
    }
    
    if (result.statusCode >= 400) {
      print('❌ [HTTP ERROR] Erreur HTTP ${result.statusCode} détectée');
      print('❌ [HTTP ERROR] Headers de réponse: ${result.headers}');
      if (path == Config.fcmUpdate) {
        print('❌ [FLUTTER ERROR] Erreur lors de l\'envoi du Player ID: Status ${result.statusCode}');
      }
    }
    // ========== END LOGS DE RÉPONSE ==========
    
    // Debug print for response
    if (path == Config.cancelBookingByUser) {
      print('🚀 [FLUTTER_DEBUG] Response status code: ${result.statusCode}');
      print('🚀 [FLUTTER_DEBUG] Response body: ${result.body}');
    }

    // Debug print for cancel-booking-by-host response
    if (path == Config.cancelBookingByHost) {
      print('🚀 [FLUTTER_DEBUG] Response status code: ${result.statusCode}');
      print('🚀 [FLUTTER_DEBUG] Response body: ${result.body}');
      print('🚀 [FLUTTER_DEBUG] Response headers: ${result.headers}');
    }

    // Check for 401 Unauthorized
    if (result.statusCode == 401 && !hasRetried) {
      print("🚨 [Auto-Fix] ========================================");
      print("🚨 [Auto-Fix] 401 Error detected. Token might be stale/guest.");
      print("🚨 [Auto-Fix] Current bearerToken length: ${bearerToken.length}");
      print("🚨 [Auto-Fix] Current user token length: ${token.length}");

      // Clear the bad token
      bearerToken = "";
      GetStorage().remove("bearerToken");
      print("🚨 [Auto-Fix] Cleared stale bearerToken from memory and storage.");

      // Force regeneration using the valid global token
      print("🚨 [Auto-Fix] Regenerating bearer token with valid user token...");
      final newBearerToken = await generateToken();

      if (newBearerToken != null && newBearerToken.isNotEmpty) {
        bearerToken = newBearerToken;
        print(
            "🚨 [Auto-Fix] New bearerToken generated successfully (length: ${bearerToken.length})");

        // Update headers with new token
        headers["Authorization"] = "Bearer $bearerToken";
        hasRetried = true;

        // Retry the request
        print("🚨 [Auto-Fix] Retrying request with new bearer token...");
        print('🌐 [HTTP REQUEST] POST vers (RETRY): $url');
        print('🔐 [HTTP HEADERS] (RETRY) Authorization: ${headers['Authorization'] != null ? (headers['Authorization']!.toString().length > 30 ? "${headers['Authorization']!.toString().substring(0, 30)}..." : headers['Authorization']) : "NULL"}');
        print('📝 [HTTP BODY] (RETRY) ${jsonEncode(data)}');
        
        result = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(data),
        );

        print("🚨 [Auto-Fix] Retry response status: ${result.statusCode}");
        print('📥 [HTTP RESPONSE] (RETRY) Status: ${result.statusCode}');
        print('📄 [HTTP RESPONSE BODY] (RETRY) ${result.body}');
        
        // Logs spécifiques pour fcmUpdate (OneSignal) lors du retry
        if (path == Config.fcmUpdate) {
          print('📥 [FLUTTER RESPONSE] (RETRY) Status: ${result.statusCode}');
          print('📄 [FLUTTER RESPONSE BODY] (RETRY) ${result.body}');
        }
        
        print("🚨 [Auto-Fix] ========================================");
      } else {
        print("🚨 [Auto-Fix] ERROR: Failed to regenerate bearer token!");
        print("🚨 [Auto-Fix] ========================================");
      }
    }

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
        print('🌐 [HTTP REQUEST] POST vers (RETRY 498): $url');
        print('🔐 [HTTP HEADERS] (RETRY 498) Authorization: Bearer ${newToken.length > 30 ? "${newToken.substring(0, 30)}..." : newToken}');
        print('📝 [HTTP BODY] (RETRY 498) ${jsonEncode(data)}');
        
        var retryResult = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(data),
        );

        print('📥 [HTTP RESPONSE] (RETRY 498) Status: ${retryResult.statusCode}');
        print('📄 [HTTP RESPONSE BODY] (RETRY 498) ${retryResult.body}');
        
        // Logs spécifiques pour fcmUpdate (OneSignal) lors du retry 498
        if (path == Config.fcmUpdate) {
          print('📥 [FLUTTER RESPONSE] (RETRY 498) Status: ${retryResult.statusCode}');
          print('📄 [FLUTTER RESPONSE BODY] (RETRY 498) ${retryResult.body}');
        }
        
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
    print("❌ [httpPost] Error: $err");
    if (err is FormatException) {
      connectionLost = true;
    }
    return {"error": err.toString()};
  }
}

// ========== HTTP PUT METHOD ==========
Future<dynamic> httpPut(String path, Map<String, dynamic> data) async {
  try {
    SearchControllerHome filterController = Get.find();
    connectionLost = false;

    // Get token and bearer token (same logic as httpPost)
    String token = GetStorage().read("token") ?? "";
    String bearerToken = GetStorage().read("bearerToken") ?? "";

    if (bearerToken.isEmpty) {
      bearerToken = await generateToken() ?? "";
      if (bearerToken.isNotEmpty) {
        GetStorage().write("bearerToken", bearerToken);
      }
    }

    if (bearerToken.isEmpty) {
      return {"error": "Bearer token generation failed"};
    }

    // Construct URL
    String url = '${Config.baseurl}$path';
    
    // Construct Headers
    var headers = {
      'Content-Type': 'application/json',
      'x-auth-token': token,
      "Authorization": "Bearer $bearerToken",
    };

    // Add common data fields
    data['token'] = token;
    data['module_id'] = "2";
    data['default_currency_code'] = generalDataModel?.data?.metaData?.generalDefaultCurrency ?? "";
    data['selected_currency_code'] = currency;
    data['item_type'] = "${filterController.globalItemType.value}";
    data['latitude'] = latitudeGlobal;
    data['longitude'] = longitudeGlobal;
    data['time_zone'] = timeZoneOffset;
    data['lang'] = globallanguage.toString().substring(0, 2);

    log("Api-Url (PUT): $url");
    log("Request Body (PUT):\n${const JsonEncoder.withIndent('  ').convert(data)}");

    // Send PUT request
    var result = await http.put(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(data),
    );

    var responseData = json.decode(const Utf8Codec().decode(result.bodyBytes));

    // Handle token expiration (same logic as httpPost)
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
        var retryResult = await http.put(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(data),
        );
        responseData = json.decode(const Utf8Codec().decode(retryResult.bodyBytes));
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
    log("Response (PUT): $responseData");
    return responseData;
  } catch (err) {
    print("❌ [httpPut] Error: $err");
    if (err is FormatException) {
      connectionLost = true;
    }
    return {"error": err.toString()};
  }
}
// ========== END HTTP PUT METHOD ==========

// ========== HTTP DELETE METHOD ==========
Future<dynamic> httpDelete(String path) async {
  connectionLost = false;
  Map<String, dynamic>? responseData;
  
  try {
    // Vérification du préfixe : Si le path commence par 'vehicles', utiliser baseUrlWithoutV1
    // pour éviter le /v1/ dans l'URL finale
    String apiBaseUrl;
    if (path.startsWith('vehicles/')) {
      apiBaseUrl = Config.baseUrlWithoutV1;
      developer.log('🔧 [DELETE] Utilisation de baseUrlWithoutV1 pour la route vehicles');
    } else {
      apiBaseUrl = Config.baseurl;
    }
    var url = apiBaseUrl + path;
    
    // Générer le bearer token si nécessaire
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
    
    developer.log('🌐 [DELETE] Api-Url: $url');
    
    final response = await http.delete(Uri.parse(url), headers: headers);
    
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
        final retryResponse = await http.delete(Uri.parse(url), headers: headers);
        responseData = jsonDecode(retryResponse.body);
        developer.log('🔁 Retried Response: $responseData');
      } else {
        developer.log('❌ Token regeneration failed');
        return {'error': 'Token regeneration failed'};
      }
    }
    
    developer.log('✅ [DELETE] Response: $responseData');
  } catch (err, stackTrace) {
    if (err is http.ClientException ||
        err is TimeoutException ||
        err is SocketException) {
      connectionLost = true;
      developer.log('📡 [DELETE] Connection error: $err', stackTrace: stackTrace);
    } else if (err is FormatException) {
      connectionLost = true;
      developer.log('📜 [DELETE] Format error in response: $err', stackTrace: stackTrace);
    } else {
      developer.log('❗ [DELETE] Unexpected error: $err', stackTrace: stackTrace);
    }
    return {'error': err.toString()};
  }
  
  return responseData;
}
// ========== END HTTP DELETE METHOD ==========

Future<String?>? _tokenFuture;
Future<String?> generateToken() async {
  if (_tokenFuture != null) {
    print("🕵️ [AUDIT] generateToken() already in progress, waiting...");
    return _tokenFuture;
  }
  final completer = Completer<String?>();
  _tokenFuture = completer.future;

  // ========== AUDIT TRACE LOGS: Révéler l'état lors de la génération ==========
  print("🕵️ [AUDIT] ========================================");
  print("🕵️ [AUDIT] 4. Generating NEW Token...");
  print(
      "🕵️ [AUDIT] 5. Input user_token used for generation: '$token' (length: ${token.length})");
  if (token.isEmpty) {
    print(
        "🕵️ [AUDIT] ⚠️ CRITICAL: user_token is EMPTY - will generate GUEST token!");
  } else {
    print("🕵️ [AUDIT] ✅ user_token is VALID - will generate USER token");
  }
  // ========== END AUDIT TRACE LOGS ==========

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

      // ========== AUDIT TRACE LOGS: Confirmer le type de token généré ==========
      // Note: 'token' ici est la variable locale (le bearer token généré)
      // Pour vérifier si c'était un guest token, on doit vérifier la variable globale 'token' (user token)
      // Mais on ne peut pas y accéder directement ici car elle est dans work_space.dart
      // On va juste logger le bearer token généré
      print("🕵️ [AUDIT] 6. Bearer token generated successfully");
      print(
          "🕵️ [AUDIT] 7. Generated bearer token: '${token.length > 20 ? token.substring(0, 20) : token}...' (length: ${token.length})");
      print("🕵️ [AUDIT] ========================================");
      // ========== END AUDIT TRACE LOGS ==========

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

// ========== MOCK HELPER FUNCTION REMOVED - _generateMockBookings() ==========
// La fonction helper _generateMockBookings() a été supprimée définitivement
// pour libérer de la mémoire et éviter toute confusion future.
// Toutes les requêtes vendor-booking-record utilisent maintenant le serveur Node.js réel.
// ========== END MOCK HELPER FUNCTION ==========
