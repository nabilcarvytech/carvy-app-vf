import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../api/config.dart';
import '../customwidget/miscellaneous_project_elements.dart';
import '../helper/http_service.dart';
import '../model/login_model.dart';
import '../model/post_data_model.dart';

class GlobalScopeController extends GetxController {
  RxBool isUploadingImage = false.obs;
  DateRangePickerController dateRangePickerController =
      DateRangePickerController();
  DateRangePickerController dateRangePickerControllerCustom =
      DateRangePickerController();
  TextEditingController textEditingControllerCity = TextEditingController();
  TextEditingController searchLead = TextEditingController();
  RxInt numberOfGuest = 1.obs;
  RxString startDate = "".obs;
  RxString endDate = "".obs;
  RxString startDateCustomDate = "".obs;
  RxString endDateCustomDate = "".obs;
  RxString homeSearchLocation = ''.obs;
  String? citySelected;
  String slat = "";
  String sLong = "";
  static int selectedRadio = -1.obs;
  RxDouble selectedRatingValue = 0.0.obs;
  var buttondisable = false.obs;

  conversations(propertyId, bookingId) async {
    Map<String, String> postData = {
      "property_id": propertyId,
      "booking_id": bookingId
    };
    // ========== MOCK DATA - OLD API CALL COMMENTED ==========
    // var response = await httpPost(Config.conversations, postData);

    // MOCK: Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // MOCK: Static conversations data
    var response = {
      "status": 200,
      "message": "Conversations retrieved successfully",
      "error": "",
      "data": {
        "conversations": [
          {
            "id": "1",
            "conversation_id": "conv_123",
            "property_id": propertyId,
            "booking_id": bookingId,
            "user_id": "1",
            "host_id": "1001",
            "last_message": "Hello, I have a question about the vehicle",
            "last_message_time": DateTime.now()
                .subtract(const Duration(hours: 2))
                .toIso8601String(),
            "unread_count": "2",
            "created_at": DateTime.now()
                .subtract(const Duration(days: 5))
                .toIso8601String()
          }
        ]
      }
    };
    // ========== END MOCK DATA ==========
    return response;
  }

  latestmessage(conversationId, offset) async {
    Map<String, String> postData = {
      "conversation_id": conversationId,
      "offset": '$offset'
    };
    // ========== MOCK DATA - OLD API CALL COMMENTED ==========
    // var response = await httpPost(Config.latestmessage, postData);

    // MOCK: Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // MOCK: Static latest messages data
    num currentOffset = int.tryParse(postData['offset'] ?? '0') ?? 0;
    var response = {
      "status": 200,
      "message": "Latest messages retrieved successfully",
      "error": "",
      "data": {
        "latest_message": [
          {
            "Name": "John Doe",
            "Message": "Hello, I have a question about the vehicle",
            "senderid": "1001",
            "frontImage": "https://example.com/profile.jpg"
          },
          {
            "Name": "User Test",
            "Message": "Hi, what would you like to know?",
            "senderid": "1",
            "frontImage": "https://example.com/user.jpg"
          },
          {
            "Name": "John Doe",
            "Message": "Is the vehicle available for pickup tomorrow?",
            "senderid": "1001",
            "frontImage": "https://example.com/profile.jpg"
          }
        ],
        "offset": currentOffset + 10
      }
    };
    // ========== END MOCK DATA ==========
    PostDataModel postDataModel = PostDataModel.fromJson(response);
    return postDataModel;
  }

  socialLogin(String displayName, String email, String id, String profileImage,
      String loginType, String identityToken, String authorizationCode) async {
    // Map data to EXACT JSON keys expected by Backend's socialLogin controller
    // Order: email, id, login_type, displayName, profile_image (as specified)
    Map<String, String> postData = {
      "email": email,                    // googleUser.email
      "id": id,                          // googleUser.id (Social ID - crucial)
      "login_type": loginType,           // "google"
      "displayName": displayName,        // googleUser.displayName
      "profile_image": profileImage,     // googleUser.photoUrl
      "identityToken": identityToken,     // Optional: for backend verification
      "authorizationCode": authorizationCode // Optional: for backend verification
    };

    print('🔵 [Google Login] Sending to Backend: $postData');
    var response = await httpPost(Config.socialLogin, postData);

    if (response != null && response['status'] == 200) {
      try {
        LoginModel socialLoginModel = LoginModel.fromJson(response);
        return socialLoginModel;
      } catch (e) {
        closeLoading();
        throw Exception('Failed to parse social login response: $e');
      }
    } else {
      String errorMessage =
          response?["error"]?.toString() ?? "Unknown error occurred";
      showErrorToastMessage(errorMessage);
      closeLoading();
      throw Exception('Social login failed: $errorMessage');
    }
  }
}
