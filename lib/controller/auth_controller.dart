import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:location/location.dart';
import 'package:get/get.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/api/data_store.dart';
import 'package:carvy/controller/global_scope_controller.dart';
import 'package:carvy/controller/push_notifications.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/model/change_phone_model.dart';
import 'package:carvy/model/check_mobile_model.dart';
import 'package:carvy/model/forgot_pass_model.dart';
import 'package:carvy/model/login_model.dart';
import 'package:carvy/model/reset_pass_model.dart';
import 'package:carvy/view/auth/google_update_screen.dart';
import 'package:carvy/view/auth/otp_screen.dart';
import 'package:carvy/view/auth/success_change_password.dart';
import 'package:carvy/view/myaccount/my_profile_screen.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import 'package:carvy/work_space.dart';
import '../helper/http_service.dart';
import '../view/auth/reset_password_screen.dart';

class AuthController extends GetxController implements GetxService {
  late TextEditingController textEditingControllerEmail;
  late TextEditingController textEditingControllerPass;
  late TextEditingController textEditingSignUpControllerFirstName;
  late TextEditingController textEditingSignUpControllerEmail;
  late TextEditingController textEditingSignUpControllerPassword;
  late TextEditingController textEditingSingUpControllerPhoneNumber;
  late TextEditingController textEditingSingUpControllerlastName;
  late TextEditingController textEditingSingUpControllerDOB;
  late TextEditingController textEditingForgetPasswordControllerEmail;
  late TextEditingController textEditingOtpController;
  late TextEditingController textEditingControllerNewPassword;
  late TextEditingController textEditingResetControllerNewPassword;
  late TextEditingController textEditingResetControllerConfirmPassword;
  late TextEditingController textEditingControllerConfirmPassword;
  late TextEditingController textEditingControllerOldPassword;
  bool shouldLogout = false;
  AuthController() {
    textEditingControllerEmail = TextEditingController();
    textEditingControllerPass = TextEditingController();
    textEditingSignUpControllerEmail = TextEditingController();
    textEditingSignUpControllerFirstName = TextEditingController();
    textEditingSignUpControllerPassword = TextEditingController();
    textEditingSingUpControllerPhoneNumber = TextEditingController();
    textEditingSingUpControllerDOB = TextEditingController();
    textEditingSingUpControllerlastName = TextEditingController();
    textEditingForgetPasswordControllerEmail = TextEditingController();
    textEditingOtpController = TextEditingController();
    textEditingControllerNewPassword = TextEditingController();
    textEditingControllerConfirmPassword = TextEditingController();
    textEditingControllerOldPassword = TextEditingController();
    textEditingResetControllerNewPassword = TextEditingController();
    textEditingResetControllerConfirmPassword = TextEditingController();
  }

  RxBool isValidEmail = false.obs;
  RxBool isResendLoading = false.obs;
  RxString newpassword = ''.obs;

  verifyOtp(map) async {
    // DEBUG: Print the exact payload being sent
    print("🔵 [FLUTTER_OTP] Sending OTP verification payload:");
    print("🔵 [FLUTTER_OTP] Map keys: ${map.keys.toList()}");
    print("🔵 [FLUTTER_OTP] Full payload: $map");
    print("🔵 [FLUTTER_OTP] Phone: ${map['phone']}");
    print("🔵 [FLUTTER_OTP] Phone Country: ${map['phone_country']}");
    print("🔵 [FLUTTER_OTP] OTP Value: ${map['otp_value']}");
    print("🔵 [FLUTTER_OTP] Endpoint: ${Config.otpVerification}");

    return await httpPost(Config.otpVerification, map);
  }

  resendOtp(map) async {
    return await httpPost(Config.resendOtp, map);
  }

  resendToken(map) async {
    return await httpPost(Config.resendToken, map);
  }

  verifyResetToken(map) async {
    return await httpPost(Config.verifyResetToken, map);
  }

  checkMobileNumber(map) async {
    showLoading();
    var response = await httpPost(Config.checkMobileNumber, map);
    closeLoading();
    if (response['status'] != 200) {
      showErrorToastMessage(response['error']);
    }
    return CheckMobileModel.fromJson(response);
  }

  changeMobileNumber(map) async {
    var response = await httpPost(Config.changeMobileNumber, map);
    return ChangePhoneModel.fromJson(response);
  }

  void setLoginModel(LoginModel model) {
    loginModel = model;
  }

  LoginModel? getLoginModel() {
    return loginModel;
  }

  bool load = false;

  Future<void> loginMethod(
      BuildContext context, GlobalKey<FormState> formKey) async {
    try {
      if (formKey.currentState?.validate() ?? false) {
        buildShowDialog(context);
        var json = await httpPost(Config.userEmailLogin, {
          "email": textEditingControllerEmail.text,
          "password": textEditingControllerPass.text,
        });
        LoginModel loginModel = LoginModel.fromJson(json);
        Get.back();
        if (json["status"] == 200) {
          GetStorage().write('Remember', true);
          GetStorage().write('Firstuser', true);
          UserData userObj = UserData();
          userObj.saveLoginData("UserData", jsonEncode(json));
          token = loginModel.data!.token!;
          // --- FIX: FLUSH GUEST TOKEN ---
          // Clear the old Guest Bearer Token so http_service is forced to generate a new User Bearer Token.
          GetStorage().remove("bearerToken");
          bearerToken = ""; // Reset the global variable immediately
          print(
              "🧹 [Auth] Old Bearer Token flushed. Ready for User Token generation.");
          // ------------------------------
          userId = loginModel.data!.id!;
          generalController.currentIndex.value = 0;
          update();
          shouldLogout = false;
          getFCMToken();
          // Lier l'utilisateur à OneSignal avec External User ID
          try {
            print('🆔 [ONESIGNAL_DEBUG] Tentative de login pour l\'utilisateur : $userId');
            await OneSignal.login(userId.toString());
            String? pushToken = OneSignal.User.pushSubscription.id;
            print('🆔 [ONESIGNAL_DEBUG] ID de souscription actuel (PlayerID) : $pushToken');
            print('🔔 [OneSignal] ID lié pour l\'utilisateur : $userId');
          } catch (e) {
            print('❌ [OneSignal] Erreur lors de la liaison de l\'ID utilisateur : $e');
          }
          database.child(userId.toString()).set({
            "userId": userId.toString(),
            "playerId": oneSiginalplayerid ?? "null",
          });

          setLoginModel(loginModel);
          if (handlelogin == true) {
            await generalController.fetchGeneralSettings();
            Get.back();
            filterController.setDefaultDates(
              startDateCustomDate: generalScopeController.startDateCustomDate,
              endDateCustomDate: generalScopeController.endDateCustomDate,
              startDate: filterController.startDate,
              endDates: filterController.endDates,
            );

            handlelogin = false;
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const HomeMain(initialIndex: 0)),
            );
          }
        } else if (json["status"] == 403) {
          showErrorToastMessage("Please Complete the Verification process".tr);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (builder) => OtpScreen(
                        number: loginModel.data!.phone!,
                        countryCode: loginModel.data!.phoneCountry!,
                        otpValue: loginModel.data!.resetToken!,
                        email: "",
                      )));
        } else {
          showErrorToastMessage(json["message"]);
        }
      }
    } catch (e) {}
  }

  Future<void> signUp(
    BuildContext context,
    GlobalKey<FormState> formKey,
    isChecked,
    countryDialCode,
    countryIsoCode,
  ) async {
    if (textEditingSingUpControllerPhoneNumber.text.isEmpty) {
      showErrorToastMessage("Fill valid mobile number".tr);
      return;
    }
    if (isChecked == false) {
      showErrorToastMessage("Please select Terms and Condition".tr);
      return;
    }
    if (!countryDialCode.startsWith("+")) {
      countryDialCode = '+$countryDialCode';
    }

    try {
      if (formKey.currentState!.validate() && (isChecked == true)) {
        buildShowDialog(context);
        var data = await httpPost(Config.registerUser, {
          "phone": textEditingSingUpControllerPhoneNumber.text,
          "email": textEditingSignUpControllerEmail.text,
          "first_name": textEditingSignUpControllerFirstName.text,
          "password": textEditingSignUpControllerPassword.text,
          "phone_country": countryDialCode,
          "default_country": countryIsoCode,
          "last_name": textEditingSingUpControllerlastName.text,
          "birthdate": textEditingSingUpControllerDOB.text,
        });

        // DEBUG: Log raw response from backend
        print("DEBUG REGISTER RESPONSE: $data");

        Get.back();
        if (data != null) {
          LoginModel loginModel = LoginModel.fromJson(data);

          // DEBUG: Log parsed model status
          print("DEBUG: Parsed LoginModel status: ${loginModel.status}");
          print("DEBUG: LoginModel data: ${loginModel.data?.toJson()}");

          if (loginModel.status == 200) {
            print("DEBUG: Status is 200");

            // DEBUG: Check verification status
            print("DEBUG: Verified status: ${loginModel.data?.verified}");
            print("DEBUG: OTP Value: ${loginModel.data?.otpValue}");
            print("DEBUG: Token: ${loginModel.data?.token}");

            if (loginModel.data?.verified == '0' ||
                loginModel.data?.verified == null) {
              print("DEBUG: User NOT verified, should go to OTP");
            } else {
              print(
                  "DEBUG: User already verified (status: ${loginModel.data?.verified}), but still navigating to OTP screen");
            }
            GetStorage().write('Remember', true);
            GetStorage().write('Firstuser', true);

            getFCMToken();
            token = loginModel.data!.token!;
            // --- FIX: FLUSH GUEST TOKEN ---
            // Clear the old Guest Bearer Token so http_service is forced to generate a new User Bearer Token.
            GetStorage().remove("bearerToken");
            bearerToken = ""; // Reset the global variable immediately
            print(
                "🧹 [Auth] Old Bearer Token flushed. Ready for User Token generation.");
            // ------------------------------
            userId = loginModel.data!.id!;
          // Lier l'utilisateur à OneSignal avec External User ID
          try {
            print('🆔 [ONESIGNAL_DEBUG] Tentative de login pour l\'utilisateur : $userId');
            await OneSignal.login(userId.toString());
            String? pushToken = OneSignal.User.pushSubscription.id;
            print('🆔 [ONESIGNAL_DEBUG] ID de souscription actuel (PlayerID) : $pushToken');
            print('🔔 [OneSignal] ID lié pour l\'utilisateur : $userId');
          } catch (e) {
            print('❌ [OneSignal] Erreur lors de la liaison de l\'ID utilisateur : $e');
          }
            database.child(userId.toString()).set({
              "userId": userId.toString(),
              "playerId": oneSiginalplayerid ?? "null",
            });

            if (webPlateForm) {
              print("DEBUG: Navigating to OTP Screen (Web Platform)");
              Get.toNamed(
                WebRoutes.otpScreen,
                arguments: {
                  'number': textEditingSingUpControllerPhoneNumber.text,
                  'countryCode': "$countryDialCode",
                  'otpValue': loginModel.data!.otpValue,
                  'email': "",
                },
              );
            } else {
              print("DEBUG: Navigating to OTP Screen (Mobile Platform)");
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => OtpScreen(
                            number: textEditingSingUpControllerPhoneNumber.text,
                            countryCode: "$countryDialCode",
                            otpValue: loginModel.data!.otpValue!,
                            email: "",
                          )));
            }
          } else {
            print(
                "DEBUG: Status is NOT 200. Status: ${loginModel.status}, Error: ${loginModel.error}");
            print(
                "DEBUG: Navigating to Login/Home. Verified status is: ${loginModel.data?.verified}");
            showErrorToastMessage(loginModel.error);
          }
        } else {
          print("DEBUG: Response data is NULL - Something went wrong");
          showErrorToastMessage("Something went wrong".tr);
        }
      }
    } catch (e) {
      print("DEBUG: Exception caught in signUp: $e");
      print("DEBUG: Stack trace: ${StackTrace.current}");
      Get.back();
    }
  }

  Future<void> forgetPassword(
      BuildContext context, GlobalKey<FormState> formKey) async {
    try {
      if (formKey.currentState?.validate() ?? false) {
        buildShowDialog(context);
        var result = await httpPost(Config.forgotPassword, {
          "email": textEditingForgetPasswordControllerEmail.text,
        });
        Get.back();
        ForgotPassModel forgotPassModel = ForgotPassModel.fromJson(result);
        if (forgotPassModel.status == 200) {
          showToastMessage(forgotPassModel.message);
          if (webPlateForm) {
            Get.toNamed(
              WebRoutes.otpScreen,
              arguments: {
                'number': "",
                'countryCode': "",
                'otpValue': forgotPassModel.data!.resetToken!,
                'email': textEditingForgetPasswordControllerEmail.text,
              },
            );
          } else {
            Get.offAll(() => OtpScreen(
                  otpValue: forgotPassModel.data!.resetToken!,
                  countryCode: '',
                  number: '',
                  email: textEditingForgetPasswordControllerEmail.text,
                ));
          }
        } else {
          showToastMessage(forgotPassModel.error);
        }
      }
    } catch (e) {
      Get.back();
    }
  }

  verifyFunction(
    BuildContext context,
    GlobalKey<FormState> formKey, {
    otp,
    changeEmail,
    changeMobile,
    email,
    number,
    cuntryCode,
    defaultCountry,
  }) async {
    if (otp == "") {
      showErrorToastMessage("Please fill the Otp".tr);
      return;
    }
    try {
      if (changeEmail != null) {
        showLoading();
        var response = await httpPost(
            Config.changeEmail, {"email": email, "otp_value": otp});
        closeLoading();
        update();
        if (response != null) {
          LoginModel loginModel = LoginModel.fromJson(response);
          if (loginModel.status == 200) {
            showToastMessage(loginModel.message);
            UserData userObj = UserData();
            userObj.saveLoginData("UserData", jsonEncode(loginModel.toJson()));
            generalController.currentIndex.value = 0;
            setLoginModel(loginModel);
            if (webPlateForm) {
              Get.toNamed(WebRoutes.myprofile);
            } else {
              Get.offAll(() => const MyProfile());
            }
          } else {
            showErrorToastMessage(loginModel.error);
          }
        }
        return;
      } else if (changeMobile != null) {
        Map map = {
          "phone": number,
          "phone_country": cuntryCode,
          "otp_value": otp,
          "default_country": defaultCountry,
        };
        showLoading();
        var response = await httpPost(Config.changeMobileNumber, map);
        closeLoading();
        update();
        LoginModel loginModel = LoginModel.fromJson(response);
        if (loginModel.status == 200) {
          showToastMessage(loginModel.message);
          UserData userObj = UserData();
          userObj.saveLoginData("UserData", jsonEncode(response));
          generalController.currentIndex.value = 0;
          shouldLogout = false;
          setLoginModel(loginModel);
          if (profileController.loginWithSocialMedia.value == true) {
            generalController.currentIndex.value = 0;
            update();

            if (handlelogin == true) {
              Get.back();
              Get.back();
              await generalController.fetchGeneralSettings();
              filterController.setDefaultDates(
                startDateCustomDate: generalScopeController.startDateCustomDate,
                endDateCustomDate: generalScopeController.endDateCustomDate,
                startDate: filterController.startDate,
                endDates: filterController.endDates,
              );

              handlelogin = false;
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const HomeMain(initialIndex: 0)),
              );
            }
            profileController.loginWithSocialMedia.value = false;
          } else {
            if (webPlateForm) {
              Get.toNamed(WebRoutes.myprofile);
            } else {
              Get.offAll(() => const MyProfile());
            }
          }
        } else {
          showErrorToastMessage(loginModel.error);
        }

        return;
      } else if (email.isEmpty) {
        showLoading();
        var result = await verifyOtp(
            {"phone": number, "otp_value": otp, "phone_country": cuntryCode});
        closeLoading();
        update();
        if (result != null) {
          LoginModel loginModel = LoginModel.fromJson(result);
          if (loginModel.status == 200) {
            showToastMessage(loginModel.message);
            UserData userObj = UserData();
            userObj.saveLoginData("UserData", jsonEncode(result));
            token = loginModel.data!.token!;
            userId = loginModel.data!.id!;
          // Lier l'utilisateur à OneSignal avec External User ID
          try {
            print('🆔 [ONESIGNAL_DEBUG] Tentative de login pour l\'utilisateur : $userId');
            await OneSignal.login(userId.toString());
            String? pushToken = OneSignal.User.pushSubscription.id;
            print('🆔 [ONESIGNAL_DEBUG] ID de souscription actuel (PlayerID) : $pushToken');
            print('🔔 [OneSignal] ID lié pour l\'utilisateur : $userId');
          } catch (e) {
            print('❌ [OneSignal] Erreur lors de la liaison de l\'ID utilisateur : $e');
          }
            generalController.currentIndex.value = 0;
            shouldLogout = false;
            if (webPlateForm) {
              Get.toNamed(WebRoutes.homeMain);
            } else {
              Get.offAll(() => const HomeMain(initialIndex: 0));
            }
          } else {
            showErrorToastMessage(loginModel.error);
            textEditingOtpController.clear();
          }
        } else {
          showErrorToastMessage("Error: Null result received".tr);
        }
      } else {
        showLoading();
        var response =
            await verifyResetToken({"email": email, "reset_token": otp});
        closeLoading();
        update();
        if (response["status"] == 200) {
          ResetPassModel resetPassModel = ResetPassModel.fromJson(response);
          showToastMessage(resetPassModel.message);
          UserData userObj = UserData();
          userObj.saveLoginData("UserData", jsonEncode(response));
          shouldLogout = false;

          if (webPlateForm) {
            Get.toNamed(
              WebRoutes.resetPasswordScreen,
              arguments: {
                'email': email!,
                'resetToken': otp,
              },
            );
          } else {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (builder) => ResetPasswordScreen(
                          email: email,
                          resetToken: otp,
                        )));
          }
        } else {
          showErrorToastMessage(response["error"]);
          textEditingOtpController.clear();
        }
      }
    } catch (e) {
      closeLoading();
    }
  }

  Future<void> resendNewCodeFunction(
      BuildContext context, GlobalKey<FormState> formKey,
      {otp,
      changeEmail,
      changeMobile,
      email,
      number,
      cuntryCode,
      changeMobiles}) async {
    isResendLoading.value = true;
    showLoading();
    try {
      if (changeMobiles != null) {
        var response = await httpPost(Config.checkMobileNumber, {
          "phone": changeMobiles!['phone'],
          "phone_country": changeMobiles!['phone_country'],
          "email": changeMobiles!['email']
        });
        if (response != null) {
          closeLoading();
          CheckMobileModel model = CheckMobileModel.fromJson(response);
          textEditingOtpController.text = model.data!.otp!.toString();
          changeMobiles!['otp_value'] = textEditingOtpController.text;
        }
      } else if (changeEmail != null) {
        var resultToken = await httpPost(Config.resendTokenEmailChange,
            {"email": email, "type": "email_reset"});
        if (resultToken != null) {
          closeLoading();
          if (resultToken['status'] == 200) {
            showToastMessage(resultToken['message']);
            if (resultToken['data'] != null) {
              textEditingOtpController.text =
                  resultToken['data']['reset_token'];
            }
          } else {
            showToastMessage(resultToken['success']);
          }
        }
      } else if (email.isEmpty) {
        var result =
            await resendOtp({"phone": number, "phone_country": cuntryCode});
        if (result != null) {
          closeLoading();
          if (result['status'] == 200) {
            showToastMessage("${result['message']}");
            if (result['data'] != null) {
              textEditingOtpController.text = result['data']['otp_value'];
            }
          } else {
            showToastMessage(result['error']);
          }
        }
      } else {
        var resultToken = await resendToken({"email": email});
        if (resultToken != null) {
          closeLoading();
          if (resultToken['status'] == 200) {
            showToastMessage(resultToken['message']);
            if (resultToken['data'] != null) {
              textEditingOtpController.text =
                  resultToken['data']['reset_token'];
            }
          } else {
            showToastMessage(resultToken['success']);
          }
        }
      }
    } catch (e) {
      closeLoading();
    }
    isResendLoading.value = false;
  }

  Future<void> callChangePassApi(
      BuildContext context, GlobalKey<FormState> formKey,
      {otp, email}) async {
    try {
      if (formKey.currentState?.validate() ?? false) {
        buildShowDialog(context);
        Map map = {
          "email": email,
          "reset_token": otp,
          "password": textEditingResetControllerNewPassword.text,
          "confirm_password": textEditingResetControllerConfirmPassword.text
        };

        var json = await httpPost(Config.resetPassword, map);
        Get.back();

        if (json != null) {
          ResetPassModel resetPassModel = ResetPassModel.fromJson(json);
          if (resetPassModel.status == 200) {
            showToastMessage(resetPassModel.message);
            if (webPlateForm) {
              Get.toNamed(WebRoutes.successChangeScreen);
            } else {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => const SuccessChangePassword()));
            }
          } else {
            showErrorToastMessage(resetPassModel.error);
          }
        } else {
          showErrorToastMessage("Something went wrong".tr);
        }
      }
    } catch (e) {
      Get.back();
    }
  }

  updateThePassword(BuildContext context, GlobalKey<FormState> formKey,
      {otp, email}) async {
    try {
      showLoading();
      if (formKey.currentState?.validate() ?? false) {}
      Map<String, String> postData = {
        "old_password": textEditingControllerOldPassword.text,
        "new_password": textEditingControllerNewPassword.text,
        "conf_new_password": textEditingControllerConfirmPassword.text,
      };
      var response = await httpPost(Config.updatePassword, postData);
      if (response != null) {
        if (response['status'] == 200) {
          showToastMessage(response['message']);
          closeLoading();
          Get.back();
        } else {
          showErrorToastMessage(response['error']);
          closeLoading();
        }
      }
    } catch (e) {
      closeLoading();
    }
  }

  GlobalScopeController globalScopeController = Get.find();
  void clearSocialUpdateData() {
    if (loginModel!.data!.firstName != null) {
      profileController.firetnameControllerSocialMedialogin.text =
          loginModel!.data!.firstName!;
    }
    if (loginModel!.data!.lastName != null) {
      profileController.lastnameControllerSocialMedialogin.text =
          loginModel!.data!.lastName!;
    }
    if (loginModel!.data!.email != null) {
      profileController.emailControllerSocialMedialogin.text =
          loginModel!.data!.email!;
    }
  }

  Future<void> googleLogin(BuildContext context) async {
    // Use GoogleSignIn for native authentication (no FirebaseAuth needed)
    // GoogleSignIn 7.1.1 uses a singleton pattern with instance
    final googleSignIn = GoogleSignIn.instance;
    showLoading();
    try {
      // Initialize GoogleSignIn (must be called once before other methods)
      // On Android, clientId is auto-resolved via SHA-1
      // serverClientId is used to get the tokens (Web Client ID)
      await googleSignIn.initialize(
        serverClientId: "165062133214-vjalpnirifhehf3vm91ashd5f0mm19g1.apps.googleusercontent.com",
      );
      
      // Sign out any existing user first
      await googleSignIn.signOut();

      // Authenticate user natively on the device with scopes
      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate(
        scopeHint: <String>['email', 'profile'],
      );

      if (googleUser == null) {
        // User cancelled the sign-in
        closeLoading();
        return;
      }

      // Extract user details directly from googleUser (no FirebaseAuth needed)
      final String email = googleUser.email;
      final String id = googleUser.id; // This is the crucial Social ID
      final String displayName = googleUser.displayName ?? '';
      final String profileImage = googleUser.photoUrl ?? '';

      // Get authentication tokens (optional, for backend verification if needed)
      // Note: authentication is a getter, not a Future, so no await needed
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      // Call the backend API with the exact JSON keys expected
      final LoginModel socialLoginModel =
          await globalScopeController.socialLogin(
        displayName,
        email,
        id,
        profileImage,
        "google",
        idToken ?? "",
        "",
      );

      GetStorage().write('Remember', true);
      GetStorage().write('Firstuser', true);
      final UserData userObj = UserData();
      userObj.saveLoginData(
          "UserData", jsonEncode(socialLoginModel.toJson()));
      loginModel = LoginModel.fromJson(socialLoginModel.toJson());
      await getFCMToken();
      token = socialLoginModel.data!.token!;
      // --- FIX: FLUSH GUEST TOKEN ---
      // Clear the old Guest Bearer Token so http_service is forced to generate a new User Bearer Token.
      GetStorage().remove("bearerToken");
      bearerToken = ""; // Reset the global variable immediately
      print(
          "🧹 [Auth] Old Bearer Token flushed. Ready for User Token generation.");
      // ------------------------------
      userId = socialLoginModel.data!.id!;
          // Lier l'utilisateur à OneSignal avec External User ID
          try {
            print('🆔 [ONESIGNAL_DEBUG] Tentative de login pour l\'utilisateur : $userId');
            await OneSignal.login(userId.toString());
            String? pushToken = OneSignal.User.pushSubscription.id;
            print('🆔 [ONESIGNAL_DEBUG] ID de souscription actuel (PlayerID) : $pushToken');
            print('🔔 [OneSignal] ID lié pour l\'utilisateur : $userId');
          } catch (e) {
            print('❌ [OneSignal] Erreur lors de la liaison de l\'ID utilisateur : $e');
          }
      database.child(userId.toString()).set({
        "userId": userId.toString(),
        "playerId": oneSiginalplayerid ?? "null",
      });

      shouldLogout = false;
      closeLoading();
      if (socialLoginModel.data!.phone == null) {
        clearSocialUpdateData();
        if (webPlateForm) {
          Get.toNamed(WebRoutes.googleUpdateScreen);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GoogleUpdate()),
          );
        }
        return;
      }
      if (handlelogin == true) {
        Get.back();
        await generalController.fetchGeneralSettings();
        filterController.setDefaultDates(
          startDateCustomDate: generalScopeController.startDateCustomDate,
          endDateCustomDate: generalScopeController.endDateCustomDate,
          startDate: filterController.startDate,
          endDates: filterController.endDates,
        );

        handlelogin = false;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const HomeMain(initialIndex: 0)),
        );
      }

      generalController.currentIndex.value = 0;
      update();
    } on GoogleSignInException catch (e) {
      closeLoading();
      showErrorToastMessage("Erreur lors de la connexion Google: $e");
    } catch (e) {
      closeLoading();
      showErrorToastMessage("Une erreur inattendue s'est produite: $e");
    }
  }

  Future<void> appleLogin(BuildContext context) async {
    try {
      showLoading();
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      var name = credential.givenName ?? '';
      if (credential.familyName != null) {
        name += ' ${credential.familyName!}';
      }

      var email = credential.email ?? '';

      LoginModel socialLoginModel = await globalScopeController.socialLogin(
        name,
        email,
        credential.userIdentifier!,
        "",
        "apple",
        credential.identityToken!,
        credential.authorizationCode,
      );
      GetStorage().write('Remember', true);
      GetStorage().write('Firstuser', true);
      UserData userObj = UserData();
      userObj.saveLoginData("UserData", jsonEncode(socialLoginModel.toJson()));
      loginModel = LoginModel.fromJson(socialLoginModel.toJson());
      getFCMToken();
      token = socialLoginModel.data!.token!;
      // --- FIX: FLUSH GUEST TOKEN ---
      // Clear the old Guest Bearer Token so http_service is forced to generate a new User Bearer Token.
      GetStorage().remove("bearerToken");
      bearerToken = ""; // Reset the global variable immediately
      print(
          "🧹 [Auth] Old Bearer Token flushed. Ready for User Token generation.");
      // ------------------------------
      userId = socialLoginModel.data!.id!;
      database.child(userId.toString()).set({
        "userId": userId.toString(),
        "playerId": oneSiginalplayerid ?? "null",
      });

      shouldLogout = false;
      if (socialLoginModel.data!.phone == null) {
        clearSocialUpdateData();
        if (webPlateForm) {
          Get.toNamed(WebRoutes.googleUpdateScreen);
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const GoogleUpdate()));
        }

        return;
      }
      if (handlelogin == true) {
        Get.back();
        await generalController.fetchGeneralSettings();
        filterController.setDefaultDates(
          startDateCustomDate: generalScopeController.startDateCustomDate,
          endDateCustomDate: generalScopeController.endDateCustomDate,
          startDate: filterController.startDate,
          endDates: filterController.endDates,
        );

        handlelogin = false;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const HomeMain(initialIndex: 0)),
        );
      }

      generalController.currentIndex.value = 0;
    } catch (e) {
      closeLoading();
    } finally {
      closeLoading();
      update();
    }
  }

  Location location = Location();
  getUserLocation() async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      bool serviceEnabled;
      PermissionStatus permissionGranted;
      LocationData locationData;
      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }
      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      locationData = await location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        GetStorage().write('latitudeGlobal', locationData.latitude.toString());
        GetStorage()
            .write('longitudeGlobal', locationData.longitude.toString());
        latitudeGlobal = locationData.latitude.toString();
        longitudeGlobal = locationData.longitude.toString();
        update();
      } else {
        return;
      }
    } catch (e) {
      //
    }
  }

  TextEditingController becomeLeadFirstName = TextEditingController();
  TextEditingController becomeLeadLastname = TextEditingController();
  TextEditingController becomeLeadEmail = TextEditingController();
  TextEditingController becomeLeadPhoneNumber = TextEditingController();
  TextEditingController becomeLeadFulladdress = TextEditingController();
  TextEditingController companyName = TextEditingController();
  var selectedImag = "".obs;
  var selectedImagyoBecomeAhostbase64 = "";
  var selectlettobecomeHost = "";
  var selectlongTibecomeHost = "";
  var selectLegalForm = "";
  var selectIdentityType = "";
  int fileSizeThreshold = 1024 * 1024;
  int goodQuality = 85;
  int badQuality = 50;
  int maxWidth = 800;
  int maxHeight = 600;
  XFile? identityimageforWeb;
  Future<void> compressAndUploadImage(String imagePath, String source) async {
    selectedImag.value = imagePath;
    update();
    var imageFile = File(imagePath);
    int originalSize = await imageFile.length();
    int quality = originalSize > fileSizeThreshold ? badQuality : goodQuality;
    var compressedImage = await FlutterImageCompress.compressWithFile(
      imagePath,
      quality: quality,
      minWidth: maxWidth,
      minHeight: maxHeight,
    );

    int compressedSize = compressedImage!.length;
    var base64Image = base64Encode(compressedImage);
    String format = '';
    if (compressedSize > 8) {
      if (compressedImage[0] == 0xFF && compressedImage[1] == 0xD8) {
        format = 'jpeg';
      } else if (compressedImage[0] == 0x89 && compressedImage[1] == 0x50) {
        format = 'png';
      }
    }
    selectedImagyoBecomeAhostbase64 = "data:image/$format;base64,$base64Image";
  }

  sendrequesttobecomeHost(
    BuildContext context,
    String countryCode,
    GlobalKey<FormState> formKey,
    isChecked,
  ) async {
    if (formKey.currentState!.validate() && (isChecked == true)) {
      showLoading();
      Map<String, String> postData = {
        "host_status": "2",
        "first_name": becomeLeadFirstName.text,
        "last_name": becomeLeadLastname.text,
        "company_name": companyName.text.isEmpty ? "" : companyName.text,
        "email": becomeLeadEmail.text,
        "phone": becomeLeadPhoneNumber.text,
        "country_code": countryCode,
        "residency_type": selectLegalForm,
        "full_address": becomeLeadFulladdress.text,
        "identity_type": selectIdentityType,
        "identity_image": selectedImagyoBecomeAhostbase64,
      };
      try {
        var requestToBecomeHost =
            await httpPost(Config.putHostRequest, postData);
        if (requestToBecomeHost != null &&
            requestToBecomeHost["status"] == 200) {
          closeLoading();
          showToastMessage(requestToBecomeHost["message"]);
          Get.back();
        } else {
          closeLoading();
          showErrorToastMessage(requestToBecomeHost["error"]);
          Get.back();
        }
      } catch (e) {
        closeLoading();
        Get.back();
      }
    }
  }
}
