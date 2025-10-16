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
    var response = await httpPost(Config.conversations, postData);
    return response;
  }

  latestmessage(conversationId, offset) async {
    Map<String, String> postData = {
      "conversation_id": conversationId,
      "offset": '$offset'
    };
    var response = await httpPost(Config.latestmessage, postData);
    PostDataModel postDataModel = PostDataModel.fromJson(response);
    return postDataModel;
  }

  socialLogin(String displayName, String email, String id, String profileImage,
      String loginType, String identityToken, String authorizationCode) async {
    Map<String, String> postData = {
      "displayName": displayName,
      "email": email,
      "id": id,
      "profile_image": profileImage,
      "login_type": loginType,
      "identityToken": identityToken,
      "authorizationCode": authorizationCode
    };
    var response = await httpPost(Config.socialLogin, postData);

    if (response != null && response['status'] == 200) {
      try {
        LoginModel socialLoginModel = LoginModel.fromJson(response);
        return socialLoginModel;
      } catch (e) {
        closeLoading();
      }
    } else {
      showErrorToastMessage("${response["error"]}");
      closeLoading();
    }
  }
}
