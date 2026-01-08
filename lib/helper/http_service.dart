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
      "status": 200,
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

  // ========== MOCK DATA - vendor-booking-record API ==========
  // TODO: REMOVE THIS MOCK AFTER NODE.JS BACKEND IMPLEMENTATION
  if (path == Config.vendorbookingRecord) {
    await Future.delayed(const Duration(seconds: 1));
    String bookingType = data['type']?.toString() ?? 'upcoming';
    num offset = int.tryParse(data['offset']?.toString() ?? '0') ?? 0;

    // Normalize type: "Cancelled" -> "cancelled"
    String normalizedType = bookingType.toLowerCase();
    if (normalizedType == 'cancelled') {
      normalizedType = 'cancelled';
    }

    // Generate mock booking based on type
    Map<String, dynamic> mockResponse = {
      "status": 200,
      "message": "Vendor bookings retrieved successfully",
      "error": "",
      "data": {
        "Bookings": _generateMockBookings(normalizedType),
        "offset": offset + 10,
        "limit": 10
      }
    };

    developer.log(
        "⚠️ MOCK MODE: Returning mock vendor-booking-record data for type: $bookingType");
    return mockResponse;
  }
  // ========== END MOCK DATA ==========

  // ========== MOCK DATA - confirm-booking-by-host API ==========
  // TODO: REMOVE THIS MOCK AFTER NODE.JS BACKEND IMPLEMENTATION
  if (path == Config.confirmBookingByHost) {
    await Future.delayed(const Duration(seconds: 1));

    Map<String, dynamic> mockResponse = {
      "status": 200,
      "message": "Booking confirmed successfully",
      "error": "",
      "data": {
        "booking_id": data["booking_id"]?.toString() ?? "",
        "status": "Confirmed"
      }
    };

    developer.log(
        "⚠️ MOCK MODE: Returning mock confirm-booking-by-host for booking_id: ${data['booking_id']}");
    return mockResponse;
  }
  // ========== END MOCK DATA ==========

  // ========== MOCK DATA - cancel-booking-by-host API ==========
  // TODO: REMOVE THIS MOCK AFTER NODE.JS BACKEND IMPLEMENTATION
  if (path == Config.cancelBookingByHost) {
    await Future.delayed(const Duration(seconds: 1));

    Map<String, dynamic> mockResponse = {
      "status": 200,
      "message": "Booking cancelled successfully",
      "error": "",
      "data": {
        "booking_id": data["booking_id"]?.toString() ?? "",
        "status": "Declined",
        "cancellation_reason": data["cancellation_reasion"]?.toString() ?? ""
      }
    };

    developer.log(
        "⚠️ MOCK MODE: Returning mock cancel-booking-by-host for booking_id: ${data['booking_id']}");
    return mockResponse;
  }
  // ========== END MOCK DATA ==========

  // ========== MOCK DATA - update-item-received-status API ==========
  // TODO: REMOVE THIS MOCK AFTER NODE.JS BACKEND IMPLEMENTATION
  if (path == Config.updateItemReceivedStatus) {
    await Future.delayed(const Duration(seconds: 1));

    // Simule la mise à jour de l'état "item reçu" pour une réservation.
    Map<String, dynamic> mockResponse = {
      "status": 200,
      "message": "Item received status updated successfully",
      "error": "",
      "data": {
        "booking_extension": {
          "booking_id": data["booking_id"]?.toString() ?? "1234567890",
          "is_item_received": "1",
          "pick_otp": data["pick_otp"]?.toString() ?? "",
          "is_item_delivered": "1",
          "is_item_returned": "0"
        }
      }
    };

    developer.log(
        "⚠️ MOCK MODE: Returning mock update-item-received-status for booking_id: ${data['booking_id']}");
    return mockResponse;
  }
  // ========== END MOCK DATA ==========

  // ========== MOCK DATA - update-item-returned-status API ==========
  // TODO: REMOVE THIS MOCK AFTER NODE.JS BACKEND IMPLEMENTATION
  if (path == Config.updateItemReturnedStatus) {
    await Future.delayed(const Duration(seconds: 1));

    // Simule la mise à jour de l'état "item retourné" pour une réservation.
    Map<String, dynamic> mockResponse = {
      "status": 200,
      "message": "Item returned status updated successfully",
      "error": "",
      "data": {
        "booking_extension": {
          "booking_id": data["booking_id"]?.toString() ?? "1234567890",
          "is_item_returned": "1",
          "drop_otp": data["drop_otp"]?.toString() ?? "",
          // on garde delivered/received à 1 pour simuler un flow complet
          "is_item_delivered": "1",
          "is_item_received": "1"
        }
      }
    };

    developer.log(
        "⚠️ MOCK MODE: Returning mock update-item-returned-status for booking_id: ${data['booking_id']}");
    return mockResponse;
  }
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
  // TODO: REMOVE THIS MOCK AFTER NODE.JS BACKEND IMPLEMENTATION
  if (path == Config.addInteriorImage) {
    await Future.delayed(const Duration(seconds: 1));

    // Simule l'upload des images intérieures (per booking images).
    // Le code Flutter vérifie uniquement 'success' == 200 et 'message'.
    Map<String, dynamic> mockResponse = {
      "success": 200,
      "message": "Images uploaded successfully",
      "error": "",
      "data": {
        "booking_id": data["booking_id"]?.toString() ?? "1234567890",
        "uploaded_images_count":
            (data["per_booking_images"]?.toString().isNotEmpty ?? false)
                ? data["per_booking_images"].toString().split("##").length
                : 0
      }
    };

    developer.log(
        "⚠️ MOCK MODE: Returning mock upload-per-booking-images for booking_id: ${data['booking_id']}");
    return mockResponse;
  }
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

    // First attempt
    result = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(data),
    );
    
    // Debug print for response
    if (path == Config.cancelBookingByUser) {
      print('🚀 [FLUTTER_DEBUG] Response status code: ${result.statusCode}');
      print('🚀 [FLUTTER_DEBUG] Response body: ${result.body}');
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
        result = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(data),
        );

        print("🚨 [Auto-Fix] Retry response status: ${result.statusCode}");
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
    print("❌ [httpPost] Error: $err");
    if (err is FormatException) {
      connectionLost = true;
    }
    return {"error": err.toString()};
  }
}

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

// ========== MOCK HELPER FUNCTION - booking-record ==========
// TODO: REMOVE THIS FUNCTION AFTER NODE.JS BACKEND IMPLEMENTATION
List<Map<String, dynamic>> _generateMockBookings(String type) {
  // Base booking data structure
  String status;
  String checkIn;
  String checkOut;

  switch (type) {
    case 'upcoming':
      status = 'Pending';
      checkIn = '2025-12-16';
      checkOut = '2025-12-18';
      break;
    case 'ongoing':
      status = 'Ongoing';
      checkIn = DateTime.now()
          .subtract(const Duration(days: 1))
          .toString()
          .split(' ')[0];
      checkOut =
          DateTime.now().add(const Duration(days: 2)).toString().split(' ')[0];
      break;
    case 'previous':
      status = 'Completed';
      checkIn = DateTime.now()
          .subtract(const Duration(days: 10))
          .toString()
          .split(' ')[0];
      checkOut = DateTime.now()
          .subtract(const Duration(days: 8))
          .toString()
          .split(' ')[0];
      break;
    case 'cancelled':
    case 'Cancelled':
      status = 'Cancelled';
      checkIn =
          DateTime.now().add(const Duration(days: 5)).toString().split(' ')[0];
      checkOut =
          DateTime.now().add(const Duration(days: 7)).toString().split(' ')[0];
      break;
    default:
      status = 'Pending';
      checkIn = '2025-12-16';
      checkOut = '2025-12-18';
  }

  return [
    {
      "id": DateTime.now().millisecondsSinceEpoch,
      "itemid": "101",
      "userid": "1",
      "host_id": "1001",
      "check_in": checkIn,
      "check_out": checkOut,
      "status": status,
      "total_day": "2",
      "per_day": "50.00",
      "book_for": "",
      "base_price": "100.00",
      "cleaning_charge": "5.00",
      "guest_charge": "0.00",
      "service_charge": "10.00",
      "security_money": "100.00",
      "iva_tax": "12.50",
      "total_guest": "1",
      "doorstep_price": "0",
      "total": "127.50",
      "admin_commission": "10.00",
      "vendor_commision": "90.00",
      "currency_code": "MAD",
      "cancellation_reasion": "",
      "cancelled_charge": "",
      "transaction": "",
      "payment_method": "stripe",
      "payment_status": "Paid",
      "image": "https://example.com/camry.jpg",
      "item_title": "Toyota Camry 2023",
      "item_data": jsonEncode([
        {
          "item_id": 101,
          "title": "Toyota Camry 2023",
          "price": "50.00",
          "description": "",
          "bedrooms": "",
          "beds": "",
          "bathroom": "",
          "item_sqft": "",
          "item_rating": "4.5",
          "mobile": "+1234567890",
          "status": "1",
          "person_allowed": "5",
          "address": "123 Main Street, Los Angeles, CA 90001",
          "state_region": "California",
          "zip_postal_code": "90001",
          "latitude": "34.0522",
          "longitude": "-118.2437",
          "is_verified": "1",
          "is_featured": "1",
          "weekly_discount": "10",
          "weekly_discount_type": "percentage",
          "monthly_discount": "15",
          "monthly_discount_type": "percentage",
          "item_type": "Sedan",
          "cancellation_reason": "",
          "bed_type": "",
          "city": "Los Angeles",
          "amenities": [
            {
              "id": 1,
              "name": "GPS Navigation",
              "image_url": "https://example.com/gps.png"
            },
            {
              "id": 2,
              "name": "Bluetooth",
              "image_url": "https://example.com/bluetooth.png"
            }
          ],
          "available_dates": [],
          "host_id": "1001",
          "host_player_id": "player_12345",
          "host_first_name": "John",
          "host_last_name": "Doe",
          "host_email": "john.doe@example.com",
          "host_phone": "+1234567890",
          "host_profile_image": "https://example.com/profile.jpg",
          "front_image_url": "https://example.com/camry.jpg",
          "gallery_image_urls": [
            "https://example.com/camry-1.jpg",
            "https://example.com/camry-2.jpg"
          ],
          "reviews": [],
          "total_reviews": 0,
          "item_data": "",
          "item_info": jsonEncode({
            "host_id": "1001",
            "make_type": "Toyota",
            "model": "Camry",
            "year": "2023",
            "service_type": "booking"
          }),
          "is_in_wishlist": false
        }
      ]),
      "wall_amt": "0.00",
      "note": "",
      "rating": "4.5",
      "cancelled_by": "",
      "created_at": DateTime.now()
          .subtract(const Duration(days: 1))
          .toString()
          .split('.')[0],
      "updated_at": DateTime.now().toString().split('.')[0],
      "review_status": "0",
      "review_rating": "",
      "review": "",
      "host_name": "John Doe",
      "host_number": "+1234567890",
      "host_email": "john.doe@example.com",
      "host_phone_country": "+1",
      "user_name": "User Test",
      "user_number": "+212694492918",
      "user_phone_country": "+212",
      "user_email": "user@example.com",
      "module": "2",
      "token": "",
      "start_time": "00:00",
      "end_time": "11:30",
      "booking_meta": "",
      "is_item_delivered": 0,
      "is_item_received": 0,
      "is_item_returned": 0,
      "is_item_delivered_button": "",
      "is_item_returned_button": "",
      "is_received_button": "",
      "pick_otp": "",
      "drop_otp": "",
      "doorStep_address": "",
      "booking_vehicle_images": null,
      "signature_image": null
    }
  ];
}
// ========== END MOCK HELPER FUNCTION ==========
