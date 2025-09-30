import 'dart:convert';
import 'package:get/get.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/api/data_store.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/work_space.dart';

class NotificationController extends GetxController implements GetxService {
  RxBool newPush = true.obs;
  RxBool newEmail = true.obs;
  RxBool newMessage = true.obs;

  initilizedValue() {
    if (loginModel != null) {
      if (loginModel!.data!.pushNotification == "0") {
        newPush.value = false;
      } else {
        newPush.value = true;
      }

      if (loginModel!.data!.smsNotification == "0") {
        newMessage.value = false;
      } else {
        newMessage.value = true;
      }

      if (loginModel!.data!.emailNotification == "0") {
        newEmail.value = false;
      } else {
        newEmail.value = true;
      }
    }
  }

  setPushNotification(value) async {
    showLoading();
    dynamic vv;
    if (value) {
      vv = 1;
    } else {
      vv = 0;
    }
    var response = await httpPost(
        Config.emailSmsNotification, {"type": "email", "value": vv.toString()});
    closeLoading();
    if (response != null) {
      if (response['status'] == 200) {
        newPush.value = value;

        if (value) {
          vv = 1;
        } else {
          vv = 0;
        }

        loginModel!.data!.pushNotiSetter = vv.toString();
        UserData userObj = UserData();
        userObj.saveLoginData("UserData", jsonEncode(loginModel!.toJson()));
      } else {
        showErrorToastMessage(response['error']);
      }
    }
  }

  setEmailNotification(value) async {
    showLoading();
    dynamic vv;
    if (value) {
      vv = 1;
    } else {
      vv = 0;
    }
    var response = await httpPost(
        Config.emailSmsNotification, {"type": "email", "value": vv.toString()});
    closeLoading();
    if (response != null) {
      if (response['status'] == 200) {
        newEmail.value = value;

        if (value) {
          vv = 1;
        } else {
          vv = 0;
        }

        loginModel!.data!.emailNotiSetter = vv.toString();
        UserData userObj = UserData();
        userObj.saveLoginData("UserData", jsonEncode(loginModel!.toJson()));
      } else {
        showErrorToastMessage(response['error']);
      }
    }
  }

  setSmsNotification(value) async {
    showLoading();
    dynamic vv;
    if (value) {
      vv = 1;
    } else {
      vv = 0;
    }
    var response = await httpPost(
        Config.emailSmsNotification, {"type": "sms", "value": vv.toString()});
    closeLoading();
    if (response != null) {
      if (response['status'] == 200) {
        newMessage.value = value;

        if (value) {
          vv = 1;
        } else {
          vv = 0;
        }

        loginModel!.data!.smsNotiSetter = vv.toString();
        UserData userObj = UserData();
        userObj.saveLoginData("UserData", jsonEncode(loginModel!.toJson()));
      } else {
        showErrorToastMessage(response['error']);
      }
    }
  }
}
