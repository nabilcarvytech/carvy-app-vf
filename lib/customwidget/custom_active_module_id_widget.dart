import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/controller/auth_controller.dart';
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
    // ========== MOCK DATA - OLD API CALL COMMENTED ==========
    // var responce = await httpPost(Config.getHostStatus, {});

    // MOCK: Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // MOCK: Static host status data (approved so user sees host features)
    var responce = {
      "status": 200,
      "message": "Host status retrieved successfully",
      "error": "",
      "data": {
        "host_status": "1" // "1" = approved, "0" = not applied, "2" = pending
      }
    };
    // ========== END MOCK DATA ==========
    if (responce != null && responce["status"] == 200) {
      if (responce["status"] == 200) {
        closeLoading();
        final data = responce["data"] as Map<String, dynamic>?;
        var hostStatus = data?["host_status"] ?? "0";
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
  AuthController authController = Get.find();
  
  return Obx(
    () {
      // Déterminer le rôle actuel basé sur isHostMode
      // Si isHostMode == true, l'utilisateur est vendor, sinon user
      String currentRole = isHostMode.value ? 'vendor' : 'user';
      
      // Déterminer le texte du bouton selon le rôle
      String buttonText = currentRole == 'vendor' 
          ? "Become a User".tr  // "Devenir locataire" si vendor
          : "Become a Host".tr;  // "Devenir propriétaire" si user
      
      return generalController.hasGeneralData.value == true
          ? const SizedBox()
          : SizedBox(
              width: 290,
              child: ElevatedButton(
                onPressed: () async {
                  // Appeler la fonction switchRole() au lieu de tobecomeHost()
                  await authController.switchRole(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: getColorBasedOnActiveModuleid(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    )),
                child: Text(
                  buttonText,
                  style: heading3(context).copyWith(color: whiteColor),
                ),
              ),
            );
    },
  );
}
