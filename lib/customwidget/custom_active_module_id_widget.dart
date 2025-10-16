import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/controller/kyc_controller.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/view/auth/request_admin_to_become_host.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import 'package:carvy/view/host/switch_splash_screen.dart';
import '../view/bottombar/home_main.dart';
import '../view/host/bottom_bar_host.dart';
import '../work_space.dart';
import 'package:carvy/utils/theme_style.dart';

RxInt activeModuleId = 2.obs;
RxBool isHostMode = RxBool(GetStorage().read('isHostMode') ?? false);
var shouldNavigatetoHost = false.obs;
RxBool switchonOff = RxBool(GetStorage().read('IsCarFilter') ?? false);
void switchphostFunmction(BuildContext context) {
  if (isHostMode.value == true) {
    isHostMode.value = false;
    GetStorage().write("isHostMode", false);
    generalController.currentIndex.value = 0;
    if (webPlateForm) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (builder) => const HomeMain(initialIndex: 0)));
    } else {
      Get.offAll(() => const HomeMain(
            initialIndex: 0,
          ));
    }
  } else {
    isHostMode.value = true;
    GetStorage().write("isHostMode", true);
    generalController.currentIndexHost.value = 0;
    if (webPlateForm) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (builder) => const BottomHost(initialIndex: 0)));
    } else {
      Get.offAll(() => const BottomHost(
            initialIndex: 0,
          ));
    }
  }
  generalController.update();
}

void tobecomeHost(BuildContext context) async {
  if (token.isEmpty) {
    loginAlert(context);
    return;
  }
  showLoading();
  try {
    var responce = await httpPost(Config.getHostStatus, {});
    if (responce != null && responce["status"] == 200) {
      if (responce["status"] == 200) {
        closeLoading();
        var hostStatus = responce["data"]["host_status"];
        if (hostStatus == "2") {
          showErrorToastMessage(
              "Your request to become a Lend is under review. Please wait for the admin to approve.");
        } else if (hostStatus == "0") {
          if (isHostMode.value == true) {
            Get.offAll(
              SwitchSplashScreen(
                isHostMode: isHostMode.value,
              ),
            );
          } else {
            if (loginModel!.data!.firstName != null) {
              if (loginModel!.data!.firstName == "") {
                handleBackonBooking = true;
                profileUpdate(context);
                return;
              }
            } else if ((loginModel!.data!.lastName != null)) {
              if (loginModel!.data!.lastName == "") {
                handleBackonBooking = true;
                profileUpdate(context);
                return;
              }
            }
            getUserDataLocallyToHandleTheState();
            if (webPlateForm) {
              Get.offAll(const RequestTobecomeHopst());
            } else {
              showPopUpScreen(context, const RequestTobecomeHopst());
            }
          }
        } else if (hostStatus == "1") {
          Get.to(
            SwitchSplashScreen(
              isHostMode: isHostMode.value,
            ),
          );
        }
      } else {
        closeLoading();
        showErrorToastMessage("SomeThing went wrong");
      }
    } else {
      closeLoading();
      if (responce["error"] == "user not found") {
        loginExpireAlert(context);
      } else {
        showErrorToastMessage(responce["error"]);
      }
    }
  } catch (e) {
    closeLoading();
  }
}

Widget switchToOwner(BuildContext context) {
  return Obx(
    () => generalController.hasGeneralData.value == true
        ? const SizedBox()
        : SizedBox(
            width: 290,
            child: ElevatedButton(
              onPressed: () async {
                tobecomeHost(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: getColorBasedOnActiveModuleid(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  )),
              child: Text(
                isHostMode.value ? "Become a Rent".tr : "Become a Lend".tr,
                style: heading3(context).copyWith(color: whiteColor),
              ),
            ),
          ),
  );
}
