import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:carvy/api/config.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/user_kyc_model.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import 'package:carvy/view/kyc/user_kyc.dart';
import 'package:carvy/work_space.dart';

class KycController extends GetxController implements GetxService {
  TextEditingController referenceMobileNo1 = TextEditingController();
  TextEditingController referenceMobileNo2 = TextEditingController();
  String sourec = "";
  String defaultCountryCodePrimary = "";
  String countryShortNamePrimary = "";
  String defaultCountryCodeSecondary = "";
  String countryShortNameSecondary = "";
  RxString activeStatus = "".obs;
  String base64frontAddharFront = "";
  String base64addharBack = "";
  String base64OthertypeFront = "";
  String base64OthertypeBack = "";
  XFile? addharFrontImage;
  XFile? addharBackImage;
  XFile? otherimageFront;
  XFile? otherImageBack;
  int fileSizeThreshold = 500 * 1024;
  int goodQuality = 90;
  int badQuality = 70;
  int maxWidth = 800;
  int maxHeight = 800;

  UserKYC? userKycModel;
  var isdataLoading = false.obs;
  String getImageFormat(Uint8List bytes) {
    if (bytes.lengthInBytes < 8) return '';
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
      return 'jpg';
    } else if (bytes[0] == 0x89 && bytes[1] == 0x50) {
      return 'png';
    } else {
      return '';
    }
  }

  void clearAllValues() {
    referenceMobileNo1.clear();
    referenceMobileNo2.clear();
    defaultCountryCodePrimary = "+91";
    countryShortNamePrimary = "IN";
    defaultCountryCodeSecondary = "+91";
    countryShortNameSecondary = "IN";
    activeStatus.value = "";
    base64frontAddharFront = "";
    base64addharBack = "";
    base64OthertypeFront = "";
    base64OthertypeBack = "";
    addharFrontImage = null;
    addharBackImage = null;
    otherimageFront = null;
    otherImageBack = null;
    update();
  }

  void validateKycImages() {}

  Future<String?> convertUrlToBase64(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) {
        throw Exception('Image URL is empty');
      }

      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        String base64Image = base64Encode(bytes);

        String format = getImageFormat(bytes);
        String base64String = 'data:image/$format;base64,$base64Image';

        print("Base64 Encoded Image: $base64String");
        return base64String;
      } else {
        throw Exception(
            'Failed to load image from URL (Status: ${response.statusCode})');
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> getUserKycData() async {
    if (kycenable == "Active") {
      clearAllValues();
      isdataLoading.value = true;
      userKycModel = null;
      var storedata = GetStorage().read("kycdata");

      try {
        if (storedata == null) {
          var response = await httpPost(Config.getKYCDetails, {});

          if (response != null && response is Map<String, dynamic>) {
            userKycModel = UserKYC.fromJson(response);

            var referenceData = userKycModel?.data?.kycReferenceData;
            if (referenceData != null) {
              referenceMobileNo1.text = referenceData.referencePrimaryMobileNo;
              defaultCountryCodePrimary =
                  referenceData.referencePrimaryCountryCode == ""
                      ? "+91"
                      : referenceData.referencePrimaryCountryCode;
              countryShortNamePrimary =
                  referenceData.referencePrimaryCountryShortCode == ""
                      ? "IN"
                      : referenceData.referencePrimaryCountryShortCode;

              referenceMobileNo2.text =
                  referenceData.referenceSecondaryMobileNo;
              defaultCountryCodeSecondary =
                  referenceData.referenceSecondaryCountryCode == ""
                      ? "+91"
                      : referenceData.referenceSecondaryCountryCode;
              countryShortNameSecondary =
                  referenceData.referenceSecondaryCountryShortCode == ""
                      ? "IN"
                      : referenceData.referenceSecondaryCountryShortCode;
            }
            activeStatus.value = userKycModel?.data?.kycStatus ?? "";

            if (activeStatus.value == "yes") {
              GetStorage().write("kycdata", response);
            }
            var kycImages = userKycModel?.data?.kycImages;
            if (kycImages != null) {
              var base64Results = await Future.wait([
                convertUrlToBase64(kycImages.aadharFrontImage ?? ""),
                convertUrlToBase64(kycImages.aadharBackImage ?? ""),
                convertUrlToBase64(kycImages.otherIdentityFrontImage ?? ""),
                convertUrlToBase64(kycImages.otherIdentityBackImage ?? "")
              ]);

              base64frontAddharFront = base64Results[0] ?? "";
              base64addharBack = base64Results[1] ?? "";
              base64OthertypeFront = base64Results[2] ?? "";
              base64OthertypeBack = base64Results[3] ?? "";
            }
            update();
          } else {
            activeStatus.value = "";
          }
        } else {
          userKycModel = UserKYC.fromJson(storedata);
          var referenceData = userKycModel?.data?.kycReferenceData;
          if (referenceData != null) {
            referenceMobileNo1.text = referenceData.referencePrimaryMobileNo;
            defaultCountryCodePrimary =
                referenceData.referencePrimaryCountryCode == ""
                    ? "+91"
                    : referenceData.referencePrimaryCountryCode;
            countryShortNamePrimary =
                referenceData.referencePrimaryCountryShortCode == ""
                    ? "IN"
                    : referenceData.referencePrimaryCountryShortCode;

            referenceMobileNo2.text = referenceData.referenceSecondaryMobileNo;
            defaultCountryCodeSecondary =
                referenceData.referenceSecondaryCountryCode == ""
                    ? "+91"
                    : referenceData.referenceSecondaryCountryCode;
            countryShortNameSecondary =
                referenceData.referenceSecondaryCountryShortCode == ""
                    ? "IN"
                    : referenceData.referenceSecondaryCountryShortCode;
          }
          activeStatus.value = userKycModel?.data?.kycStatus ?? "";
          var kycImages = userKycModel?.data?.kycImages;
          if (kycImages != null) {
            var base64Results = await Future.wait([
              convertUrlToBase64(kycImages.aadharFrontImage ?? ""),
              convertUrlToBase64(kycImages.aadharBackImage ?? ""),
              convertUrlToBase64(kycImages.otherIdentityFrontImage ?? ""),
              convertUrlToBase64(kycImages.otherIdentityBackImage ?? "")
            ]);

            base64frontAddharFront = base64Results[0] ?? "";
            base64addharBack = base64Results[1] ?? "";
            base64OthertypeFront = base64Results[2] ?? "";
            base64OthertypeBack = base64Results[3] ?? "";
          }
        }
      } catch (e) {
        activeStatus.value = "";
      } finally {
        isdataLoading.value = false;
        update();
      }
    }
  }

  Future<void> uplaodImageAddharFront(
      ImageSource source, BuildContext context) async {
    String sourec = source == ImageSource.camera ? "Camera" : "Gallery";

    try {
      var image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      addharFrontImage = image;
      var imageFile = File(image.path);

      int imageSize = await imageFile.length();
      int quality = imageSize > fileSizeThreshold ? badQuality : goodQuality;

      var compressedImage = await FlutterImageCompress.compressWithFile(
        image.path,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
      );

      if (compressedImage == null || compressedImage.isEmpty) {
        throw Exception("Image compression failed.");
      }

      var base64Image = base64Encode(compressedImage);

      String format = '';
      if (compressedImage.length > 8) {
        if (compressedImage[0] == 0xFF && compressedImage[1] == 0xD8) {
          format = 'jpeg';
        } else if (compressedImage[0] == 0x89 && compressedImage[1] == 0x50) {
          format = 'png';
        }
      }

      base64frontAddharFront = "data:image/$format;base64,$base64Image";
    } on PlatformException {
      if (Platform.isIOS) {
        showOpenAppSettingsDialog(context,
            "$sourec permission denied. Please go to settings and allow the $sourec.");
      }
    } catch (e) {
      debugPrint("Error uploading Aadhar Front Image: $e");
    }
  }

  Future<void> uplaodImageAddharback(
      ImageSource source, BuildContext context) async {
    if (source == ImageSource.camera) {
      sourec = "Camera";
    } else {
      sourec = "Gallery";
    }
    try {
      var image = await ImagePicker().pickImage(source: source);

      if (image == null) {
        return;
      }
      addharBackImage = image;
      var imageFile = File(image.path);
      int imageSize = await imageFile.length();
      int quality = imageSize > fileSizeThreshold ? badQuality : goodQuality;
      var compressedImage = await FlutterImageCompress.compressWithFile(
        image.path,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
      );

      var base64Image = base64Encode(compressedImage!);

      String format = '';
      if (compressedImage.length > 8) {
        if (compressedImage[0] == 0xFF && compressedImage[1] == 0xD8) {
          format = 'jpeg';
        } else if (compressedImage[0] == 0x89 && compressedImage[1] == 0x50) {
          format = 'png';
        }
      }
      base64addharBack = "data:image/$format;base64,$base64Image";
      print(base64addharBack);
    } on PlatformException {
      if (Platform.isIOS) {
        showOpenAppSettingsDialog(context,
            "${sourec} permission denied. Please go to settings and allow the ${sourec}.");
      }
    }
  }

  Future<void> uploadotherIdentiotyFront(
      ImageSource source, BuildContext context) async {
    if (source == ImageSource.camera) {
      sourec = "Camera";
    } else {
      sourec = "Gallery";
    }
    try {
      var image = await ImagePicker().pickImage(source: source);

      if (image == null) {
        return;
      }
      otherimageFront = image;
      var imageFile = File(image.path);
      int imageSize = await imageFile.length();
      int quality = imageSize > fileSizeThreshold ? badQuality : goodQuality;
      var compressedImage = await FlutterImageCompress.compressWithFile(
        image.path,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
      );

      var base64Image = base64Encode(compressedImage!);

      String format = '';
      if (compressedImage.length > 8) {
        if (compressedImage[0] == 0xFF && compressedImage[1] == 0xD8) {
          format = 'jpeg';
        } else if (compressedImage[0] == 0x89 && compressedImage[1] == 0x50) {
          format = 'png';
        }
      }
      base64OthertypeFront = "data:image/$format;base64,$base64Image";
    } on PlatformException {
      if (Platform.isIOS) {
        showOpenAppSettingsDialog(context,
            "${sourec} permission denied. Please go to settings and allow the ${sourec}.");
      }
    }
  }

  Future<void> uploadotherIdentiotyBack(
      ImageSource source, BuildContext context) async {
    if (source == ImageSource.camera) {
      sourec = "Camera";
    } else {
      sourec = "Gallery";
    }
    try {
      var image = await ImagePicker().pickImage(source: source);

      if (image == null) {
        return;
      }

      otherImageBack = image;
      var imageFile = File(image.path);
      int imageSize = await imageFile.length();
      int quality = imageSize > fileSizeThreshold ? badQuality : goodQuality;
      var compressedImage = await FlutterImageCompress.compressWithFile(
        image.path,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
      );

      var base64Image = base64Encode(compressedImage!);

      String format = '';
      if (compressedImage.length > 8) {
        if (compressedImage[0] == 0xFF && compressedImage[1] == 0xD8) {
          format = 'jpeg';
        } else if (compressedImage[0] == 0x89 && compressedImage[1] == 0x50) {
          format = 'png';
        }
      }
      base64OthertypeBack = "data:image/$format;base64,$base64Image";
    } on PlatformException {
      if (Platform.isIOS) {
        showOpenAppSettingsDialog(context,
            "${sourec} permission denied. Please go to settings and allow the ${sourec}.");
      }
    }
  }

  Future<void> submit(BuildContext context) async {
    if (base64frontAddharFront == "") {
      showErrorToastMessage("Please select Driver license Front Image".tr);
      return;
    }
    if (base64addharBack == "") {
      showErrorToastMessage("Please select Driver license Back Image".tr);
      return;
    }

    if (base64OthertypeFront != "" && base64OthertypeBack == "") {
      showErrorToastMessage("Please select Other Identity Back Image".tr);
      return;
    }
    if (base64OthertypeBack != "" && base64OthertypeFront == "") {
      showErrorToastMessage("Please select Other Identity Front Image".tr);
      return;
    }
    if (referenceMobileNo1.text.isEmpty) {
      showErrorToastMessage("Please add Primary Reference MoB No".tr);
      return;
    }
    var map = {
      "driver_license_front_image": base64frontAddharFront,
      "driver_license_back_image": base64addharBack,
      "other_identity_front_image": base64OthertypeFront,
      "other_identity_back_image": base64OthertypeBack,
      "reference_primary_mobile_no": referenceMobileNo1.text,
      "reference_primary_country_code": defaultCountryCodePrimary,
      "reference_primary_country_short_code": countryShortNamePrimary,
      "reference_secondary_mobile_no": referenceMobileNo2.text,
      "reference_secondary_country_code": defaultCountryCodeSecondary,
      "reference_secondary_country_short_code": countryShortNameSecondary,
    };

    try {
      showLoading();
      var response = await httpPost(Config.addKycforCustomer, map);
      closeLoading();
      if (response != null && response["status"] == 200) {
        showToastMessage("${response["message"]}");
      } else {
        showErrorToastMessage("${response["error"]}");
      }
    } catch (e, stackTrace) {
      closeLoading();
      debugPrint("Error in submit: $e");
      debugPrint("StackTrace: $stackTrace");
      showErrorToastMessage("An error occurred. Please try again later.");
    }
  }

  Map<String, dynamic> getReviewStatus() {
    switch (activeStatus.value) {
      case "yes":
        return {"text": "Verified", "color": Colors.green};
      case "no":
      case "":
        return {"text": "", "color": null};
      case "review":
        return {"text": "Under Review", "color": Colors.orange};
      case "reject":
        return {"text": "Rejected", "color": Colors.red};
      default:
        return {"text": "", "color": null};
    }
  }

  Future<bool> kycStatus(var status, BuildContext context) async {
    if (kycenable == "Active") {
      if (status == null) {
        return false;
      }

      if (status.toString() == "review") {
        await showModalBottomSheet(
          backgroundColor: whiteColor,
          context: context,
          useSafeArea: true,
          builder: (context) {
            return _buildKycBottomSheet(
                context,
                "Your KYC request is under review. Please wait for the admin to approve.",
                "Review");
          },
        );
        return false;
      } else if (status.toString() == "reject") {
        await showModalBottomSheet(
          backgroundColor: whiteColor,
          context: context,
          useSafeArea: true,
          builder: (context) {
            return _buildKycBottomSheet(
                context, "Your request is rejected.", "Apply Again");
          },
        );
        return false;
      } else if (status.toString() == "no") {
        await showModalBottomSheet(
          backgroundColor: whiteColor,
          context: context,
          useSafeArea: true,
          builder: (context) {
            return _buildKycBottomSheet(
                context, "Please fill your KYC Form.", "Apply");
          },
        );
        return false;
      }
    }

    return true;
  }

  Widget _buildKycBottomSheet(
      BuildContext context, String message, String actionName) {
    return Container(
      height: 250,
      width: Get.width,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Icon(Icons.info, size: 51, color: acentColor),
            const SizedBox(height: 20),
            Text(
              message.tr,
              style: regular3(context).copyWith(color: blackColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                            margin: const EdgeInsets.only(left: 8, right: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: redColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                                child: Text(
                              "Back".tr,
                              style: TextStyle(
                                  color: whiteColor,
                                  fontWeight: FontWeight.bold),
                            ))))),
                actionName == "Review"
                    ? SizedBox()
                    : Expanded(
                        child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              Get.to(UserKyc());
                            },
                            child: Container(
                                margin:
                                    const EdgeInsets.only(left: 8, right: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    border: Border.all(color: themeColor),
                                    color: themeColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                    child: Text(
                                  "$actionName".tr,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ))))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
