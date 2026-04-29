import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/controller/auth_controller.dart';
import 'package:carvy/controller/global_scope_controller.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/model/check_email.dart';
import 'package:carvy/model/check_mobile_model.dart';
import 'package:carvy/model/login_model.dart' as logmod;
import 'package:carvy/model/login_model.dart';
import 'package:carvy/model/get_user_profile.dart';
import 'package:carvy/model/vendor_model.dart';
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
      final avatarMap = <String, dynamic>{
        'profile_image': loginModel!.data!.profileImage,
        'agency_logo': loginModel!.data!.agencyLogo,
      };
      final rawAvatar = Vendor.rawImageFromJson(avatarMap);
      final resolvedAvatar = Vendor.resolveImageUrl(rawAvatar);
      if (resolvedAvatar != null && resolvedAvatar.isNotEmpty) {
        print('📸 [DEBUG] URL Image Agence : $resolvedAvatar');
        myImage.value = resolvedAvatar;
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
    myImage.value = "";
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

      // ========== MOCK DATA - OLD API CALL COMMENTED ==========
      // var response = await httpPost(Config.editProfile, postData);

      // MOCK: Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // MOCK: Static success response for editing profile
      var response = {
        "status": 200,
        "message": "Profile updated successfully",
        "error": "",
        "data": {
          "user": {
            "id": loginModel?.data?.id ?? 1,
            "first_name": postData["first_name"],
            "middle": null,
            "last_name": postData["last_name"],
            "email": postData["email"],
            "phone": postData["phone"],
            "phone_country": postData["phone_country"],
            "default_country": postData["default_country"],
            "intro": postData["intro"],
            "langauge": postData["langauge"],
            "country": postData["country"],
            "wallet": null,
            "otp_value": "0",
            "token": token,
            "reset_token": null,
            "verified": "1",
            "phone_verify": "1",
            "email_verify": "1",
            "login_type": "email",
            "birthdate": postData["birthdate"],
            "social_id": null,
            "status": "1",
            "created_at": DateTime.now().toIso8601String(),
            "updated_at": DateTime.now().toIso8601String(),
            "deleted_at": null,
            "package_id": null,
            "fcm": null,
            "device_id": null,
            "identity_image": postData["identity_image"] != null &&
                    postData["identity_image"]!.isNotEmpty
                ? {"url": postData["identity_image"]}
                : null,
            "profile_image": null,
            "media": []
          }
        }
      };
      // ========== END MOCK DATA ==========
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
      // ========== MOCK DATA - OLD API CALL COMMENTED ==========
      // var response = await httpPost(Config.checkEmail,
      //     {"email": textEditingProfileControllerCheckEmail.text});

      // MOCK: Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // MOCK: Static success response for checking email
      var response = {
        "status": 200,
        "message": "OTP sent to email successfully",
        "error": "",
        "data": {
          "email": textEditingProfileControllerCheckEmail.text,
          "otp": "123456"
        }
      };
      // ========== END MOCK DATA ==========
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
    void Function(String otpValue, Map<String, dynamic> changeMobiles)?
        onOtpSentInline,
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
      final email = emailControllerSocialMedialogin.text.trim().isNotEmpty
          ? emailControllerSocialMedialogin.text.trim()
          : (loginModel?.data?.email?.trim() ?? '');
      if (email.isEmpty) {
        showErrorToastMessage(
            "Email utilisateur introuvable. Veuillez vous reconnecter.");
        return;
      }
      print("📧 Email injecté pour check: $email");
      Map map = {
        "phone": textEditingPhoneUpdateController.text,
        "phone_country": selectedCountries,
        "email": email,
        "default_country": selectedCountryIso,
      };

      CheckMobileModel model = await controller.checkMobileNumber(map);
      if (model.status == 200) {
        final Map<String, dynamic> mapx = {
          "phone": textEditingPhoneUpdateController.text,
          "phone_country": selectedCountries,
          "first_name": firetnameControllerSocialMedialogin.text,
          "last_name": lastnameControllerSocialMedialogin.text,
          "email": email,
          "default_country": selectedCountryIso,
        };
        if (onOtpSentInline != null) {
          onOtpSentInline("${model.data!.otp}", mapx);
        } else {
          Get.off(() => OtpScreen(
                number: textEditingPhoneUpdateController.text,
                countryCode: selectedCountries,
                otpValue: "${model.data!.otp}",
                defaultCountry: selectedCountryIso,
                email: "",
                changeMobile: true,
                changeMobiles: mapx,
              ));
        }
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

    String format = '';
    if (compressedSize > 8) {
      if (compressedImage[0] == 0xFF && compressedImage[1] == 0xD8) {
        format = 'jpeg';
      } else if (compressedImage[0] == 0x89 && compressedImage[1] == 0x50) {
        format = 'png';
      }
    }
    final ext = format == 'png' ? 'png' : 'jpeg';
    await uploadProfileBytes(compressedImage, 'avatar.$ext');
  }

  Widget myNetworkImage(String image) {
    return Container(
      color: grey4,
      child: buildAvatarImage(image, fit: BoxFit.fitHeight),
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

  String? _extractAvatarUrlFromResponse(Map<String, dynamic> json) {
    final d = json['data'];
    if (d is Map) {
      if (d['url'] != null) return d['url'].toString();
      final inner = d['data'];
      if (inner is Map && inner['url'] != null) {
        return inner['url'].toString();
      }
      final pi = d['profile_image'];
      if (pi is Map && pi['url'] != null) return pi['url'].toString();
    }
    if (json['url'] != null) return json['url'].toString();
    return null;
  }

  MediaType _mediaTypeForAvatar(String filename, Uint8List bytes) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    }
    if (bytes.length > 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50) {
      return MediaType('image', 'png');
    }
    return MediaType('image', 'jpeg');
  }

  String? _profileImageUrlFromGetUserResponse(Map<String, dynamic> response) {
    final d = response['data'];
    if (d is! Map) return null;
    final m = Map<String, dynamic>.from(d as Map);
    final raw = Vendor.rawImageFromJson(m);
    return Vendor.resolveImageUrl(raw);
  }

  Future<void> refreshUserProfileAfterAvatar() async {
    try {
      if (loginModel?.data?.id == null) return;
      final response = await httpGet(Config.getUserProfile, {
        "userid": loginModel!.data!.id,
      });
      if (response is! Map<String, dynamic>) return;
      final st = response['status'];
      if (st != 200 && st != '200') return;
      final vendorDiag = Vendor.fromJson(response['data']);
      print(
          '📸 [CRITICAL DEBUG] URL Image reçue du Backend : "${vendorDiag.image}"');
      String? img = _profileImageUrlFromGetUserResponse(response);
      if (img == null || img.isEmpty) {
        final gp = GetUserProfile.fromJson(response);
        img = gp.data?.profileImage;
      }
      img = Vendor.resolveImageUrl(img);
      if (img != null && img.isNotEmpty) {
        print('📸 [DEBUG] URL Image Agence : $img');
        loginModel!.data!.profileImageSetter = img;
        myImage.value = img;
        authController.setLoginModel(loginModel!);
        UserData userObj = UserData();
        userObj.saveLoginData("UserData", jsonEncode(loginModel!.toJson()));
        update();
      }
    } catch (_) {}
  }

  Future<void> uploadProfileBytes(Uint8List bytes, String filename) async {
    globalScopeController.isUploadingImage.value = true;
    showLoading();
    try {
      if (bearerToken.isEmpty) {
        showErrorToastMessage("Session expired. Please log in again.".tr);
        return;
      }
      if (loginModel?.data == null) {
        showErrorToastMessage("User data missing.".tr);
        return;
      }

      final uri = Uri.parse(
          '${Config.baseUrlWithoutV1}${Config.uploadAvatar}');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $bearerToken';
      if (token.isNotEmpty) {
        request.headers['x-auth-token'] = token;
      }

      final file = http.MultipartFile.fromBytes(
        'avatar',
        bytes,
        filename: filename,
        contentType: _mediaTypeForAvatar(filename, bytes),
      );
      request.files.add(file);

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode != 200) {
        String msg = 'Upload failed'.tr;
        try {
          final errJson = jsonDecode(response.body);
          if (errJson is Map &&
              (errJson['message'] != null || errJson['error'] != null)) {
            msg = (errJson['message'] ?? errJson['error']).toString();
          }
        } catch (_) {}
        showErrorToastMessage(msg);
        return;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        showErrorToastMessage('Invalid server response'.tr);
        return;
      }

      final st = decoded['status'];
      final ok = st == null ||
          st == 200 ||
          st == '200' ||
          st == true ||
          decoded['success'] == true;
      if (!ok) {
        showErrorToastMessage(
            (decoded['error'] ?? decoded['message'] ?? 'Upload failed')
                .toString());
        return;
      }

      final imageUrl = _extractAvatarUrlFromResponse(decoded);
      if (imageUrl == null || imageUrl.isEmpty) {
        showErrorToastMessage('No image URL in response'.tr);
        return;
      }

      loginModel!.data!.profileImageSetter = imageUrl;
      myImage.value = imageUrl;
      authController.setLoginModel(loginModel!);
      update();
      UserData userObj = UserData();
      userObj.saveLoginData("UserData", jsonEncode(loginModel!.toJson()));
      final okMsg = decoded['message']?.toString();
      showToastMessage(okMsg != null && okMsg.isNotEmpty
          ? okMsg
          : 'Profile image uploaded successfully'.tr);

      await refreshUserProfileAfterAvatar();
    } catch (e) {
      showErrorToastMessage(e.toString());
    } finally {
      globalScopeController.isUploadingImage.value = false;
      closeLoading();
      update();
    }
  }

  void selectImageForweb() async {
    profileimageForWeb = null;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      for (var file in result.files) {
        Uint8List fileBytes = file.bytes!;
        XFile xfile = XFile.fromData(fileBytes, name: file.name);

        profileimageForWeb = xfile;
        await uploadProfileBytes(fileBytes, file.name);
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
