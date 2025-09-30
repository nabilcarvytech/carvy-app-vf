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
          userId = loginModel.data!.id!;
          generalController.currentIndex.value = 0;
          update();
          shouldLogout = false;
          getFCMToken();
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
        Get.back();
        if (data != null) {
          LoginModel loginModel = LoginModel.fromJson(data);
          if (loginModel.status == 200) {
            GetStorage().write('Remember', true);
            GetStorage().write('Firstuser', true);

            getFCMToken();
            token = loginModel.data!.token!;
            userId = loginModel.data!.id!;
            database.child(userId.toString()).set({
              "userId": userId.toString(),
              "playerId": oneSiginalplayerid ?? "null",
            });

            if (webPlateForm) {
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
            showErrorToastMessage(loginModel.error);
          }
        } else {
          showErrorToastMessage("Something went wrong".tr);
        }
      }
    } catch (e) {
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
    final googleSignIn = GoogleSignIn.instance;
    showLoading();
    try {
      await googleSignIn.initialize();
      await googleSignIn.signOut();

      final GoogleSignInAccount googleUser = await googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      final authClient = googleSignIn.authorizationClient;
      final authorization =
          await authClient.authorizationForScopes(['email', 'profile']);
      if (authorization == null) {
        throw Exception('Failed to obtain authorization tokens');
      }

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: googleAuth.idToken,
      );

      try {
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        final User? firebaseUser = userCredential.user;

        if (firebaseUser != null) {
          final LoginModel socialLoginModel =
              await globalScopeController.socialLogin(
            googleUser.displayName ?? '',
            googleUser.email,
            googleUser.id,
            googleUser.photoUrl ?? '',
            "google",
            "",
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
          userId = socialLoginModel.data!.id!;
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
        } else {
          closeLoading();
        }
      } on FirebaseAuthException catch (e) {
        closeLoading();
      } catch (e) {
        closeLoading();
      }
    } on GoogleSignInException catch (e) {
      closeLoading();
    } catch (e) {
      closeLoading();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred')),
      );
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
  var selectresedinceType = "";
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
        "residency_type": selectresedinceType,
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
