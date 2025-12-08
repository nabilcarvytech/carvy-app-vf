import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:carvy/controller/kyc_controller.dart';
import 'package:carvy/controller/profile_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/project_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import 'package:carvy/work_space.dart';

class UserKyc extends StatefulWidget {
  const UserKyc({super.key});

  @override
  State<UserKyc> createState() => _UserKycState();
}

class _UserKycState extends State<UserKyc> {
  ProfileController profileController = Get.find();
  KycController kycController = Get.find();

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      kycController.getUserKycData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      appBar: CustomAppBars(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(() => kycController.isdataLoading.value
                ? SizedBox.shrink()
                : Text(
                    kycController.getReviewStatus()["text"],
                    style: TextStyle(
                      color: kycController.getReviewStatus()["color"],
                      fontWeight: FontWeight.bold,
                    ),
                  )),
          ),
        ],
        backgroundColor: notifires.getbgcolor,
        title: 'KYC'.tr,
        titleColor: notifires.getwhiteblackcolor,
      ),
      body: Obx(
        () => kycController.isdataLoading.value == true
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(15.0),
                child: ListView(
                  children: [
                    Row(
                      children: [
                        Text(
                          "First driver license".tr,
                          style: heading2Grey1(context)
                              .copyWith(color: blackColor, fontSize: 15),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "*",
                          style: heading2Grey1(context).copyWith(
                              color: Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      child: Row(
                        children: [
                          Expanded(child: addharFrontImage("Change", context)),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(child: addharBack("", context)),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Primary reference mob no".tr,
                      style: heading2Grey1(context)
                          .copyWith(color: blackColor, fontSize: 15),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    AbsorbPointer(
                      absorbing: kycController.activeStatus.value == "yes"
                          ? true
                          : false,
                      child: IntelPhoneFieldRefs(
                        validator: (phoneNumber) {
                          if (phoneNumber == null ||
                              phoneNumber.number.isEmpty) {
                            return 'Please enter your phone number';
                          }

                          int expectedLength =
                              phoneLengths[phoneNumber.countryISOCode] ?? 10;
                          if (phoneNumber.number.length != expectedLength) {
                            return 'Phone number must be $expectedLength digits';
                          }
                          return null;
                        },
                        defultcountry: kycController.countryShortNamePrimary,
                        textEditingControllerCommons:
                            kycController.referenceMobileNo1,
                        selectedcountry:
                            kycController.defaultCountryCodePrimary,
                        oncountryChanged: (value) {
                          kycController.referenceMobileNo1.clear();
                          kycController.defaultCountryCodePrimary =
                              "+${value.dialCode}";
                          kycController.countryShortNamePrimary = value.code;
                        },
                        onChanged: (value) {
                          // Limit the input to the expected length
                          int expectedLength = phoneLengths[
                                  profileController.defaultCountry.value] ??
                              10;

                          if (value!.number.length > expectedLength) {
                            // Truncate the input to the expected length
                            kycController.referenceMobileNo1.text =
                                value.number.substring(0, expectedLength);
                            kycController.referenceMobileNo1.selection =
                                TextSelection.fromPosition(
                              TextPosition(
                                  offset: kycController
                                      .referenceMobileNo1.text.length),
                            );
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text("Second driver license".tr,
                        style: heading2Grey1(context)
                            .copyWith(color: blackColor, fontSize: 15)),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Expanded(child: dfFrontImage("", context)),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(child: dlBackImage("", context)),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Secondary reference mob no (Optional)".tr,
                      style: heading2Grey1(context)
                          .copyWith(color: blackColor, fontSize: 15),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    AbsorbPointer(
                      absorbing: kycController.activeStatus.value == "yes"
                          ? true
                          : false,
                      child: IntelPhoneFieldRefs(
                        validator: (phoneNumber) {
                          if (phoneNumber == null ||
                              phoneNumber.number.isEmpty) {
                            return 'Please enter your phone number';
                          }

                          int expectedLength =
                              phoneLengths[phoneNumber.countryISOCode] ?? 10;
                          if (phoneNumber.number.length != expectedLength) {
                            return 'Phone number must be $expectedLength digits';
                          }
                          return null;
                        },
                        defultcountry: kycController.countryShortNameSecondary,
                        textEditingControllerCommons:
                            kycController.referenceMobileNo2,
                        selectedcountry:
                            kycController.defaultCountryCodeSecondary,
                        oncountryChanged: (value) {
                          kycController.referenceMobileNo2.clear();
                          kycController.defaultCountryCodeSecondary =
                              "+${value.dialCode}";
                          kycController.countryShortNameSecondary = value.code;
                        },
                        onChanged: (value) {
                          // Limit the input to the expected length
                          int expectedLength = phoneLengths[
                                  profileController.defaultCountry.value] ??
                              10;

                          if (value!.number.length > expectedLength) {
                            // Truncate the input to the expected length
                            kycController.referenceMobileNo2.text =
                                value.number.substring(0, expectedLength);
                            kycController.referenceMobileNo2.selection =
                                TextSelection.fromPosition(
                              TextPosition(
                                  offset: kycController
                                      .referenceMobileNo2.text.length),
                            );
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    kycController.activeStatus.value == "yes" ||
                            kycController.activeStatus.value == "review"
                        ? SizedBox()
                        : CustomsButtons(
                            text: kycController.activeStatus.value == "yes"
                                ? "Verified"
                                : kycController.activeStatus.value == "review"
                                    ? "Under Review".tr
                                    : "Apply".tr,
                            backgroundColor: getColorBasedOnActiveModuleid(),
                            onPressed: () {
                              if (kycController.activeStatus.value == "yes") {
                                return;
                              }
                              if (kycController.activeStatus.value ==
                                  "review") {
                                return;
                              }

                              kycController.submit(context);
                            })
                  ],
                ),
              ),
      ),
    );
  }

  Widget addharFrontImage(String text, BuildContext context) {
    return IgnorePointer(
      ignoring: kycController.activeStatus.value == "yes",
      child: PopupMenuButton<int>(
        enabled: kycController.activeStatus.value != "yes",
        itemBuilder: (context) => [
          PopupMenuItem(
            onTap: () async {
              kycController
                  .uplaodImageAddharFront(ImageSource.camera, context)
                  .then((_) {
                setState(() {});
              });
            },
            child: Text(
              "Select with camera".tr,
              style: regular02.copyWith(color: grey1),
            ),
          ),
          PopupMenuItem(
            onTap: () async {
              kycController
                  .uplaodImageAddharFront(ImageSource.gallery, context)
                  .then((_) {
                setState(() {});
              });
            },
            child: Text(
              "Select with Gallery".tr,
              style: regular02.copyWith(color: grey1),
            ),
          ),
        ],
        offset: const Offset(1, 50),
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: notifires.getboxcolor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: notifires.getGrey3Whitecolor.withOpacity(0.1),
                spreadRadius: 3,
                blurRadius: 5,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: kycController.addharFrontImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(kycController.addharFrontImage!.path),
                          fit: BoxFit.cover,
                        ),
                      )
                    : kycController.userKycModel?.data?.kycImages
                                    .aadharFrontImage !=
                                null &&
                            kycController.userKycModel!.data!.kycImages
                                .aadharFrontImage!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              kycController.userKycModel!.data!.kycImages
                                  .aadharFrontImage!,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                    child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return getErrorImage();
                              },
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                color: getColorBasedOnActiveModuleid(),
                                size: 35,
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Front image",
                                style: regular2(context),
                              ),
                            ],
                          ),
              ),
              if (kycController.activeStatus.value != "yes")
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black54,
                    ),
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget addharBack(String text, BuildContext context) {
    return IgnorePointer(
      ignoring: kycController.activeStatus.value == "yes",
      child: PopupMenuButton<int>(
        enabled: kycController.activeStatus.value != "yes",
        itemBuilder: (context) => [
          PopupMenuItem(
            onTap: () async {
              if (kycController.activeStatus.value == "yes") {
                return;
              }
              kycController
                  .uplaodImageAddharback(ImageSource.camera, context)
                  .then((_) {
                setState(
                    () {}); // This ensures the UI updates after the image is uploaded
              });
            },
            child: Text(
              "Select with camera".tr,
              style: regular02.copyWith(color: grey1),
            ),
          ),
          PopupMenuItem(
            onTap: () async {
              if (kycController.activeStatus.value == "yes") {
                return;
              }
              kycController
                  .uplaodImageAddharback(ImageSource.gallery, context)
                  .then((_) {
                setState(
                    () {}); // This ensures the UI updates after the image is uploaded
              });
            },
            child: Text(
              "Select with Gallery".tr,
              style: regular02.copyWith(color: grey1),
            ),
          ),
        ],
        offset: const Offset(1, 50),
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: notifires.getboxcolor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: notifires.getGrey3Whitecolor.withOpacity(0.1),
                spreadRadius: 3,
                blurRadius: 5,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: kycController.addharBackImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(kycController.addharBackImage!.path),
                          fit: BoxFit.cover,
                        ),
                      )
                    : kycController.userKycModel?.data?.kycImages
                                    .aadharBackImage !=
                                null &&
                            kycController.userKycModel!.data!.kycImages
                                .aadharBackImage!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              kycController.userKycModel!.data!.kycImages
                                  .aadharBackImage!,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                    child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return getErrorImage();
                              },
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                color: getColorBasedOnActiveModuleid(),
                                size: 35,
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Back image",
                                style: regular2(context),
                              ),
                            ],
                          ),
              ),
              if (kycController.activeStatus.value != "yes")
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black54,
                    ),
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget dfFrontImage(String text, BuildContext context) {
    return IgnorePointer(
      ignoring: kycController.activeStatus.value == "yes",
      child: PopupMenuButton<int>(
        enabled: kycController.activeStatus.value != "yes",
        itemBuilder: (context) => [
          PopupMenuItem(
            onTap: () async {
              if (kycController.activeStatus.value == "yes") {
                return;
              }
              kycController
                  .uploadotherIdentiotyFront(ImageSource.camera, context)
                  .then((_) {
                setState(() {});
              });
            },
            child: Text(
              "Select with Camera".tr,
              style: regular02.copyWith(color: grey1),
            ),
          ),
          PopupMenuItem(
            onTap: () async {
              if (kycController.activeStatus.value == "yes") {
                return;
              }
              kycController
                  .uploadotherIdentiotyFront(ImageSource.gallery, context)
                  .then((_) {
                setState(() {});
              });
            },
            child: Text(
              "Select with Gallery".tr,
              style: regular02.copyWith(color: grey1),
            ),
          ),
        ],
        offset: const Offset(1, 50),
        child: Stack(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: notifires.getboxcolor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: notifires.getGrey3Whitecolor.withOpacity(0.1),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Center(
                child: kycController.otherimageFront != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(kycController.otherimageFront!.path),
                          fit: BoxFit.cover,
                        ),
                      )
                    : kycController.userKycModel?.data?.kycImages
                                    .otherIdentityFrontImage !=
                                null &&
                            kycController.userKycModel!.data!.kycImages
                                .otherIdentityFrontImage!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              kycController.userKycModel!.data!.kycImages
                                  .otherIdentityFrontImage!,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                    child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return getErrorImage();
                              },
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                color: getColorBasedOnActiveModuleid(),
                                size: 35,
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Front image",
                                style: regular2(context),
                              ),
                            ],
                          ),
              ),
            ),
            // Edit Icon
            if (kycController.activeStatus.value != "yes")
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black54,
                  ),
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget dlBackImage(String text, BuildContext context) {
    return IgnorePointer(
      ignoring: kycController.activeStatus.value == "yes",
      child: PopupMenuButton<int>(
        enabled: kycController.activeStatus.value != "yes",
        itemBuilder: (context) => [
          PopupMenuItem(
            onTap: () async {
              if (kycController.activeStatus.value == "yes") {
                return;
              }
              kycController
                  .uploadotherIdentiotyBack(ImageSource.camera, context)
                  .then((_) {
                setState(
                    () {}); // Ensures UI updates after the image is uploaded
              });
            },
            child: Text(
              "Select with Camera".tr,
              style: regular02.copyWith(color: grey1),
            ),
          ),
          PopupMenuItem(
            onTap: () async {
              kycController
                  .uploadotherIdentiotyBack(ImageSource.gallery, context)
                  .then((_) {
                setState(
                    () {}); // Ensures UI updates after the image is uploaded
              });
            },
            child: Text(
              "Select with Gallery".tr,
              style: regular02.copyWith(color: grey1),
            ),
          ),
        ],
        offset: const Offset(1, 50),
        child: Stack(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: notifires.getboxcolor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: notifires.getGrey3Whitecolor.withOpacity(0.1),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Center(
                child: kycController.otherImageBack != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(kycController.otherImageBack!.path),
                          fit: BoxFit.cover,
                        ),
                      )
                    : kycController.userKycModel?.data?.kycImages
                                    .otherIdentityBackImage !=
                                null &&
                            kycController.userKycModel!.data!.kycImages
                                .otherIdentityBackImage!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              kycController.userKycModel!.data!.kycImages
                                  .otherIdentityBackImage!,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                    child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return getErrorImage();
                              },
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                color: getColorBasedOnActiveModuleid(),
                                size: 35,
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Back image",
                                style: regular2(context),
                              ),
                            ],
                          ),
              ),
            ),
            // Edit Icon
            if (kycController.activeStatus.value != "yes")
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black54,
                  ),
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
