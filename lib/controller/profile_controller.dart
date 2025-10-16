import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/controller/auth_controller.dart';
import 'package:carvy/controller/global_scope_controller.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/model/check_email.dart';
import 'package:carvy/model/check_mobile_model.dart';
import 'package:carvy/model/login_model.dart' as logmod;
import 'package:carvy/model/login_model.dart';
import 'package:carvy/model/update_profile.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/view/auth/otp_screen.dart';
import 'package:carvy/work_space.dart';
import '../api/data_store.dart';
import '../customwidget/miscellaneous_project_elements.dart';
import '../helper/http_service.dart';

class ProfileController extends GetxController implements GetxService {
  RxString myName = "".obs;
  RxString myImage = "".obs;
  RxString selectedCountry = "".obs;
  RxString selectedCountryReset = "".obs;
  RxString defaultCountry = "".obs;
  RxString defaultCountryReset = "".obs;

  bool loading = false;
  TextEditingController firetnameControllerSocialMedialogin =
      TextEditingController();
  TextEditingController lastnameControllerSocialMedialogin =
      TextEditingController();
  TextEditingController emailControllerSocialMedialogin =
      TextEditingController();
  var loginWithSocialMedia = false.obs;
  AuthController authController = Get.find<AuthController>();
  GlobalScopeController globalScopeController = Get.find();
  late TextEditingController textEditingProfileControllerFirstName;
  late TextEditingController textEditingProfileControllerlastName;
  late TextEditingController textEditingProfileControllerPhoneNumber;
  late TextEditingController textEditingProfileControllerEmail;
  late TextEditingController textEditingProfileControllerDOB;
  late TextEditingController textEditingProfileControllerLangauge;
  late TextEditingController textEditingProfileControllerDescription;
  late TextEditingController textEditingProfileControllerPassword;
  late TextEditingController textEditingProfileControllerPhoneCountry;
  late TextEditingController textEditingProfileControllerCheckEmail;
  late TextEditingController textEditingPhoneUpdateController;
  late TextEditingController textEditingProfileControllerCountry;
  ProfileController() {
    textEditingProfileControllerFirstName = TextEditingController();
    textEditingProfileControllerlastName = TextEditingController();
    textEditingProfileControllerPhoneNumber = TextEditingController();
    textEditingProfileControllerEmail = TextEditingController();
    textEditingProfileControllerDOB = TextEditingController();
    textEditingProfileControllerLangauge = TextEditingController();
    textEditingProfileControllerPhoneCountry = TextEditingController();
    textEditingProfileControllerDescription = TextEditingController();
    textEditingProfileControllerPhoneCountry = TextEditingController();
    textEditingProfileControllerPassword = TextEditingController();
    textEditingProfileControllerCheckEmail = TextEditingController();
    textEditingPhoneUpdateController = TextEditingController();
  }

  Future<void> setFirstNameFromLoginModel() async {
    clear();
    if (loginModel != null) {
      if (loginModel!.data!.firstName != null) {
        textEditingProfileControllerFirstName.text =
            loginModel!.data!.firstName!;
      }
      if (loginModel!.data!.lastName != null) {
        textEditingProfileControllerlastName.text = loginModel!.data!.lastName!;
      }
      if (loginModel!.data!.email != null) {
        textEditingProfileControllerEmail.text = loginModel!.data!.email!;
      }
      if (loginModel!.data!.profileImage != null &&
          loginModel!.data!.profileImage!['url'] != null) {
        myImage.value = loginModel!.data!.profileImage!['url'];
      }
      if (loginModel!.data!.intro != null) {
        textEditingProfileControllerDescription.text = loginModel!.data!.intro;
      }
      if (loginModel!.data!.langauge != null) {
        textEditingProfileControllerLangauge.text = loginModel!.data!.langauge;
      }

      if (loginModel!.data!.phone != null) {
        textEditingProfileControllerPhoneNumber.text = loginModel!.data!.phone!;
      }
      if (loginModel!.data!.phone != null) {
        textEditingPhoneUpdateController.text = loginModel!.data!.phone!;
      }
      if (loginModel!.data!.birthdate != null) {
        print(loginModel!.data!.birthdate!);

        textEditingProfileControllerDOB.text = loginModel!.data!.birthdate!;
      }
      if (loginModel!.data!.langauge != null) {
        textEditingProfileControllerLangauge.text = loginModel!.data!.langauge!;
      }
      if (loginModel!.data!.intro != null) {
        textEditingProfileControllerDescription.text = loginModel!.data!.intro!;
      }
    }
  }

  clear() {
    if (loginModel!.data!.profileImage != null &&
        loginModel!.data!.profileImage!['url'] != null) {
      myImage.value = "";
    }
  }

  Future updateProfileData(
    context,
    GlobalKey<FormState> formKey, {
    selectedCountryDrop,
    identityBase64,
  }) async {
    try {
      if (textEditingProfileControllerFirstName.text.isEmpty) {
        showErrorToastMessage("Invalid First Name".tr);
        return;
      }
      if (textEditingProfileControllerlastName.text.isEmpty) {
        showErrorToastMessage("Invalid Last Name".tr);
        return;
      }
      showLoading();
      Map<String, String> postData = {
        "email": textEditingProfileControllerEmail.text,
        "first_name": textEditingProfileControllerFirstName.text,
        "last_name": textEditingProfileControllerlastName.text,
        "phone_country": selectedCountry.value,
        "phone": textEditingPhoneUpdateController.text,
        "birthdate": textEditingProfileControllerDOB.text,
        "intro": textEditingProfileControllerDescription.text,
        "langauge": textEditingProfileControllerLangauge.text,
        "country": selectedCountryDrop ?? "",
        "identity_image": identityBase64 ?? ""
      };

      var response = await httpPost(Config.editProfile, postData);
      closeLoading();
      if (response != null) {
        if (response['status'] == 200) {
          UpdateProfile updateProfile = UpdateProfile.fromJson(response);
          loginModel = LoginModel(
              data: logmod.Data.fromJson(updateProfile.data!.user!.toJson()));
          authController.setLoginModel(loginModel!);
          UserData userObj = UserData();
          userObj.saveLoginData("UserData", jsonEncode(loginModel!.toJson()));
          showToastMessage(response['message'].toString().tr);
          if (handleBackonBooking == true) {
            Get.back();
          }
        } else {
          showErrorToastMessage(response['error'].toString().tr);
        }
      } else {
        showErrorToastMessage(
            "Unexpected error occurred. Please try again.".tr);
      }
    } catch (e) {
      closeLoading();
    }
  }

  Future<void> checkEmailUpdate(
      BuildContext context, GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      showLoading();
      var response = await httpPost(Config.checkEmail,
          {"email": textEditingProfileControllerCheckEmail.text});
      closeLoading();
      if (response != null) {
        CheckEmail checkEmail = CheckEmail.fromJson(response);
        if (checkEmail.status == 200) {
          showToastMessage(checkEmail.message);
          Get.off(() => OtpScreen(
                number: "",
                countryCode: "",
                otpValue: checkEmail.data!.otp!,
                email: textEditingProfileControllerCheckEmail.text,
                changeEmail: true,
              ));
        } else {
          showErrorToastMessage(checkEmail.error);
        }
      }
    }
  }

  checkPhoneUpdate(
    BuildContext context,
    GlobalKey<FormState> formKey, {
    selectedCountries,
    selectedCountryIso,
  }) async {
    if (formKey.currentState!.validate()) {
      if (textEditingPhoneUpdateController.text.isEmpty) {
        showErrorToastMessage("Enter mobile number");
        return;
      }
      if (textEditingPhoneUpdateController.text.length < 8 ||
          textEditingPhoneUpdateController.text.length > 12) {
        showErrorToastMessage("Check mobile number");
        return;
      }
      AuthController controller = Get.find();
      Map map = {
        "phone": textEditingPhoneUpdateController.text,
        "phone_country": selectedCountries,
        "email": emailControllerSocialMedialogin.text,
        "default_country": selectedCountryIso,
      };

      CheckMobileModel model = await controller.checkMobileNumber(map);
      if (model.status == 200) {
        Map mapx = {
          "phone": textEditingPhoneUpdateController.text,
          "phone_country": selectedCountries,
          "first_name": firetnameControllerSocialMedialogin.text,
          "last_name": lastnameControllerSocialMedialogin.text,
          "email": emailControllerSocialMedialogin.text,
          "default_country": selectedCountryIso,
        };
        Get.off(() => OtpScreen(
              number: textEditingPhoneUpdateController.text,
              countryCode: selectedCountries,
              otpValue: "${model.data!.otp}",
              defaultCountry: selectedCountryIso,
              email: "",
              changeMobile: true,
              changeMobiles: mapx,
            ));
      } else {
        showErrorToastMessage(model.error);
      }
    }
  }

  RxString selectedIdentityImage = "".obs;
  XFile? profileimageForWeb;
  Widget selectImagePopup(BuildContext context) {
    return PopupMenuButton<int>(
      itemBuilder: (context) => [
        if (!webPlateForm)
          PopupMenuItem(
            onTap: () async {
              try {
                var image =
                    await ImagePicker().pickImage(source: ImageSource.camera);
                if (image == null) {
                  return;
                }
                await compressAndUploadImage(image.path);
              } on PlatformException {
                if (Platform.isIOS) {
                  showOpenAppSettingsDialog(context,
                      "Camera permission denied. Please go to settings and allow the Camera.");
                }
              }
            },
            child: Text(
              "Select with camera".tr,
              style: TextStyle(
                fontSize: 14,
                fontFamily: "InterMedium",
                color: grey2,
              ),
            ),
          ),
        PopupMenuItem(
          onTap: () async {
            if (webPlateForm) {
              selectImageForweb();
            } else {
              try {
                var image =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                if (image == null) {
                  return;
                }
                await compressAndUploadImage(image.path);
              } on PlatformException {
                if (Platform.isIOS) {
                  showOpenAppSettingsDialog(context,
                      "Photo permission denied. Please go to settings and allow the Photo.");
                }
              }
            }
          },
          child: Text(
            "Select with Gallery".tr,
            style: TextStyle(
              fontSize: 14,
              fontFamily: "InterMedium",
              color: grey2,
            ),
          ),
        ),
      ],
      offset: const Offset(50, 50),
      child: SvgPicture.asset("assets/images/editlogo.svg"),
    );
  }

  int fileSizeThreshold = 1024 * 1024;
  int goodQuality = 85;
  int badQuality = 50;
  int maxWidth = 800;
  int maxHeight = 600;

  Future<void> compressAndUploadImage(String imagePath) async {
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
    uploadProfileMethod("data:image/$format;base64,$base64Image");
  }

  myNetworkImage(String image) {
    return Container(
      color: grey4,
      child: Image.network(
        image,
        fit: BoxFit.fitHeight,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          } else {
            return Container(
              color: const Color.fromARGB(255, 250, 247, 247),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              ),
            );
          }
        },
        errorBuilder: (context, exception, stackTrace) {
          return Image.asset(
            "assets/images/ezgif.com-crop.gif",
            fit: BoxFit.fill,
          );
        },
      ),
    );
  }

  void identityMethod(
    context,
    GlobalKey<FormState> formKey, {
    selectedCountryDrop,
    identityBase64,
  }) async {
    update();
    try {
      final imagePicker = ImagePicker();
      final imageFile =
          await imagePicker.pickImage(source: ImageSource.gallery);

      if (imageFile != null) {
        selectedIdentityImage.value = imageFile.path;
        update();
        final bytes = await File(imageFile.path).readAsBytes();
        int quality =
            bytes.length > fileSizeThreshold ? badQuality : goodQuality;
        final compressedImage = await FlutterImageCompress.compressWithList(
          bytes,
          quality: quality,
          minWidth: maxWidth,
          minHeight: maxHeight,
        );

        final base64Image = base64Encode(compressedImage);

        String format = '';
        if (compressedImage.length > 8) {
          if (compressedImage[0] == 0xFF && compressedImage[1] == 0xD8) {
            format = 'jpeg';
          } else if (compressedImage[0] == 0x89 && compressedImage[1] == 0x50) {
            format = 'png';
          }
        }

        identityBase64 = "data:image/$format;base64,$base64Image";
        updateProfileData(context, formKey,
            selectedCountryDrop: selectedCountryDrop,
            identityBase64: identityBase64);
      }
    } on PlatformException {
      if (Platform.isIOS) {
        showOpenAppSettingsDialog(context,
            "Photo permission denied. Please go to settings and allow the Photo.");
      }
    }
  }

  uploadProfileMethod(image) async {
    globalScopeController.isUploadingImage.value = true;
    showLoading();
    var response =
        await httpPost(Config.uploadProfileImage, {"profile_image": image});
    globalScopeController.isUploadingImage.value = false;
    update();
    if (response != null) {
      if (response['status'] == 200) {
        closeLoading();
        loginModel!.data!.profileImageSetter =
            response['data']['profile_image_url'];
        myImage.value = response['data']['profile_image_url'];
        update();
        closeLoading();
        showToastMessage(response['message']);
        UserData userObj = UserData();
        userObj.saveLoginData("UserData", jsonEncode(loginModel!.toJson()));
      } else {
        showErrorToastMessage(response['error']);
        closeLoading();
      }
    }
  }

  void selectImageForweb() async {
    profileController.profileimageForWeb = null;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      for (var file in result.files) {
        Uint8List fileBytes = file.bytes!;
        String base64Image = base64Encode(fileBytes);
        String format = detectImageFormat(fileBytes);
        XFile xfile = XFile.fromData(fileBytes, name: file.name);

        profileController.profileimageForWeb = xfile;
        profileController
            .uploadProfileMethod("data:image/$format;base64,$base64Image");
      }
    }
  }

  String detectImageFormat(Uint8List bytes) {
    if (bytes.length > 4) {
      if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
        return 'jpeg';
      } else if (bytes[0] == 0x89 && bytes[1] == 0x50) {
        return 'png';
      }
    }
    return 'jpeg';
  }
}
