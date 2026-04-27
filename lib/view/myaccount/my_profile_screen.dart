import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/global_scope_controller.dart';
import 'package:carvy/controller/profile_controller.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/form_validation.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import 'package:carvy/view/host/bottom_bar_host.dart';
import 'package:carvy/work_space.dart';
import 'package:carvy/service/onesignal_service.dart';
import 'package:country_picker/country_picker.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  ProfileController profileController = Get.find();
  GlobalScopeController globalScopeController = Get.find();
  final _formKey = GlobalKey<FormState>();
  String? selectedCountryDrop = "Maroc"; // Pays par défaut : Maroc
  double spacingBeteenFeilds = 15;
  List listCountry = [];

  String? imageUrl;
  @override
  void initState() {
    super.initState();
    notifires = ColorNotifires();
    profileController.textEditingProfileControllerDescription.clear();
    getUserDataLocallyToHandleTheState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DefaultAssetBundle.of(context)
          .loadString("assets/json/countries.json")
          .then((value) {
        listCountry = jsonDecode(value);
        setState(() {});
      });
      profileController.setFirstNameFromLoginModel();

      // Initialiser le code pays par défaut à MA (Maroc) si vide
      if (profileController.defaultCountry.value.isEmpty) {
        profileController.defaultCountry.value = "MA";
      }
      // Initialiser le code téléphone par défaut à +212 (Maroc) si vide
      if (profileController.selectedCountry.value.isEmpty) {
        profileController.selectedCountry.value = "+212";
      }

      if (loginModel!.data!.country != null &&
          loginModel!.data!.country.toString().isNotEmpty) {
        selectedCountryDrop = loginModel!.data!.country;
      } else {
        // Définir le Maroc comme pays par défaut
        selectedCountryDrop = "Maroc";
      }
      if (loginModel != null &&
          loginModel!.data != null &&
          loginModel!.data!.identityImage != null) {
        var identityImage = loginModel!.data!.identityImage;
        imageUrl = identityImage!['url'];
        profileController.myNetworkImage(imageUrl!);
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (valo) {
        if (isHostMode.value == true) {
          if (generalController.currentIndexHost.value == 0) {
            generalController.currentIndexHost.value = 0;
            Get.to(const BottomHost(initialIndex: 0));
          } else {
            generalController.currentIndexHost.value = 4;
            Get.to(const BottomHost(initialIndex: 4));
          }
        } else {
          if (generalController.currentIndex.value == 0) {
            generalController.currentIndex.value = 0;
            Get.to(() => const HomeMain(initialIndex: 0));
          } else {
            generalController.currentIndex.value = 4;
            Get.to(() => const HomeMain(initialIndex: 4));
          }
        }
        // return false;
      },
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: Dimensions.containerWidth,
          child: Scaffold(
              backgroundColor: notifires.getbgcolor,
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                leading: GestureDetector(
                    onTap: () {
                      if (isHostMode.value == true) {
                        if (generalController.currentIndexHost.value == 0) {
                          generalController.currentIndexHost.value = 0;
                          Get.to(const BottomHost(initialIndex: 0));
                        } else {
                          generalController.currentIndexHost.value = 4;
                          Get.to(const BottomHost(initialIndex: 4));
                        }
                      } else {
                        if (generalController.currentIndex.value == 0) {
                          generalController.currentIndex.value = 0;
                          Get.to(const HomeMain(initialIndex: 0));
                        } else {
                          generalController.currentIndex.value = 4;
                          Get.to(const HomeMain(initialIndex: 4));
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20, top: 8, bottom: 8, right: 20),
                      child: PhysicalModel(
                        color: Colors.transparent,
                        shadowColor: notifires.getGrey4Whitecolor,
                        elevation: 5.0, // Adjust the elevation value as needed
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          alignment: Alignment.center,
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              color: notifires.getboxcolor,
                              borderRadius: BorderRadius.circular(8)),
                          child: Icon(Icons.arrow_back,
                              color: getColorBasedOnActiveModuleid()),
                        ),
                      ),
                    )),
                scrolledUnderElevation: 0,
                leadingWidth: 80,
              ),
              body: Padding(
                padding: const EdgeInsets.all(0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 270,
                              alignment: Alignment.topCenter,
                              child: GestureDetector(
                                onTap: () {
                                  profileController.identityMethod(
                                      context, _formKey,
                                      selectedCountryDrop: selectedCountryDrop,
                                      identityBase64: identityBase64);
                                },
                                child: Container(
                                    height: 208,
                                    width: double.maxFinite,
                                    decoration: BoxDecoration(color: grey5),
                                    child: Obx(
                                      () => profileController
                                                  .selectedIdentityImage
                                                  .value !=
                                              ""
                                          ? ClipRRect(
                                              child: Image.file(
                                                File(profileController
                                                    .selectedIdentityImage
                                                    .value),
                                                fit: BoxFit.fitHeight,
                                              ),
                                            )
                                          : (loginModel?.data?.identityImage !=
                                                      null &&
                                                  loginModel!
                                                      .data!
                                                      .identityImage!
                                                      .isNotEmpty)
                                              ? profileController
                                                  .myNetworkImage(
                                                      imageUrl ?? "")
                                              : Center(
                                                  child: InkWell(
                                                    onTap: () {
                                                      profileController.identityMethod(
                                                          context, _formKey,
                                                          selectedCountryDrop:
                                                              selectedCountryDrop,
                                                          identityBase64:
                                                              identityBase64);
                                                    },
                                                    child: SizedBox(
                                                      // height: 100,
                                                      // width: 100,
                                                      child: Image.asset(
                                                        "assets/images/add.png",
                                                        height: 40,
                                                        color: themeColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                    )),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 140,
                                    width: 140,
                                    decoration: BoxDecoration(
                                        color: whiteColor,
                                        borderRadius:
                                            BorderRadius.circular(70)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(3),
                                      child: SizedBox(
                                        height: 140,
                                        width: 140,
                                        child: Stack(
                                          children: [
                                            webPlateForm &&
                                                    profileController
                                                            .profileimageForWeb !=
                                                        null
                                                ? SizedBox(
                                                    height: 140,
                                                    width: 140,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              70),
                                                      child: profileController
                                                                  .myImage.value
                                                                  .toString() ==
                                                              ""
                                                          ? SizedBox(
                                                              height: 138,
                                                              width: 128,
                                                              child:
                                                                  CircleAvatar(
                                                                // backgroundColor: Colors.grey,
                                                                radius: 76,
                                                                child: Icon(
                                                                  Icons.person,
                                                                  size: 65,
                                                                  color:
                                                                      blackColor,
                                                                ),
                                                              ),
                                                            )
                                                          : Obx(
                                                              () =>
                                                                  buildAvatarImage(
                                                                profileController
                                                                    .myImage
                                                                    .value,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                    ),
                                                  )
                                                : Obx(() => SizedBox(
                                                      height: 140,
                                                      width: 140,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(70),
                                                        child: profileController
                                                                    .myImage
                                                                    .value
                                                                    .toString() ==
                                                                ""
                                                            ? SizedBox(
                                                                height: 138,
                                                                width: 128,
                                                                child:
                                                                    CircleAvatar(
                                                                  // backgroundColor: Colors.grey,
                                                                  radius: 76,
                                                                  child: Icon(
                                                                    Icons
                                                                        .person,
                                                                    size: 65,
                                                                    color:
                                                                        blackColor,
                                                                  ),
                                                                ),
                                                              )
                                                            : Obx(
                                                                () =>
                                                                    buildAvatarImage(
                                                                  profileController
                                                                      .myImage
                                                                      .value,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                      ),
                                                    )),
                                            Positioned(
                                              bottom: 5,
                                              right: 0,
                                              child: InkWell(
                                                onTap: () {
                                                  profileController
                                                      .selectImagePopup(
                                                          context);
                                                },
                                                child: profileController
                                                    .selectImagePopup(
                                                        context), // This might need to be replaced with the appropriate widget.
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 20,
                              bottom: 100,
                              child: (profileController
                                              .selectedIdentityImage.value !=
                                          "" ||
                                      (loginModel?.data?.identityImage !=
                                              null &&
                                          loginModel!
                                              .data!.identityImage!.isNotEmpty))
                                  ? InkWell(
                                      onTap: () {
                                        profileController.identityMethod(
                                            context, _formKey,
                                            selectedCountryDrop:
                                                selectedCountryDrop,
                                            identityBase64: identityBase64);
                                      },
                                      child: SvgPicture.asset(
                                          "assets/images/editlogo.svg"),
                                    )
                                  : const SizedBox(),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFieldRefs(
                                inputAlignment: TextAlign.start,
                                txt: 'First Name'.tr,
                                icons: Icon(
                                  Icons.person,
                                  color: getColorBasedOnActiveModuleid(),
                                ),
                                textEditingControllerCommon: profileController
                                    .textEditingProfileControllerFirstName,
                                inputType: TextInputType.text,
                                validator: (value) {
                                  if (isValidName(value!)) {
                                    return null;
                                  } else {
                                    return 'Name is invalid'.tr;
                                  }
                                },
                              ),
                              SizedBox(
                                height: spacingBeteenFeilds,
                              ),
                              TextFieldRefs(
                                inputAlignment: TextAlign.start,
                                txt: 'Last Name'.tr,
                                icons: Icon(Icons.person,
                                    color: getColorBasedOnActiveModuleid()),
                                textEditingControllerCommon: profileController
                                    .textEditingProfileControllerlastName,
                                inputType: TextInputType.text,
                                validator: (value) {
                                  if (isValidName(value!)) {
                                    return null;
                                  } else {
                                    return 'Name is invalid'.tr;
                                  }
                                },
                              ),
                              SizedBox(
                                height: spacingBeteenFeilds,
                              ),
                              Stack(
                                children: [
                                  Obx(
                                    () => AbsorbPointer(
                                      absorbing: true,
                                      child: IntelPhoneFieldRefs(
                                        defultcountry:
                                            loginModel?.data?.defaultCountry ??
                                                "MA",
                                        isenable: true,
                                        readOnly: true,
                                        textEditingControllerCommons:
                                            profileController
                                                .textEditingProfileControllerPhoneNumber,
                                        selectedcountry: profileController
                                            .selectedCountry.value,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      right: 10,
                                      top: 0,
                                      bottom: 0,
                                      child: InkWell(
                                          onTap: () {
                                            Get.toNamed(
                                                WebRoutes.phoneUpdateScreen,
                                                arguments: {
                                                  profileController
                                                      .selectedCountry.value,
                                                  profileController
                                                      .defaultCountry.value
                                                });
                                          },
                                          child: SvgPicture.asset(
                                              "assets/images/editIcon.svg")))
                                ],
                              ),
                              SizedBox(
                                height: spacingBeteenFeilds,
                              ),
                              Stack(
                                children: [
                                  TextFieldRefs(
                                      readOnly: true,
                                      inputAlignment: TextAlign.start,
                                      txt: 'Email'.tr,
                                      icons: Icon(
                                        Icons.email,
                                        color: getColorBasedOnActiveModuleid(),
                                      ),
                                      textEditingControllerCommon:
                                          profileController
                                              .textEditingProfileControllerEmail,
                                      inputType: TextInputType.emailAddress,
                                      validator: (value) {
                                        return validateEmail(value!);
                                      }),
                                  Positioned(
                                      right: 10,
                                      top: 0,
                                      bottom: 0,
                                      child: InkWell(
                                          onTap: () {
                                            Get.toNamed(
                                                WebRoutes.emailUpdateScreen);
                                          },
                                          child: SvgPicture.asset(
                                              "assets/images/editIcon.svg")))
                                ],
                              ),
                              SizedBox(
                                height: spacingBeteenFeilds,
                              ),
                              TextFieldRefs(
                                inputAlignment: TextAlign.start,
                                txt: 'Language'.tr,
                                icons: Icon(
                                  Icons.language,
                                  color: getColorBasedOnActiveModuleid(),
                                ),
                                textEditingControllerCommon: profileController
                                    .textEditingProfileControllerLangauge,
                                inputType: TextInputType.text,
                                validator: (value) {
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: spacingBeteenFeilds,
                              ),
                              Text(
                                "About".tr,
                                style: heading3(context).copyWith(
                                    color: notifires.getGrey3Whitecolor),
                              ),
                              SizedBox(
                                height: spacingBeteenFeilds,
                              ),
                              TextFormField(
                                textInputAction: TextInputAction.done,
                                minLines: 5,
                                controller: profileController
                                    .textEditingProfileControllerDescription,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                cursorColor: notifires.getwhiteblackcolor,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(10),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusDefault),
                                    borderSide: BorderSide(
                                        color: notifires.getBoxColor),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusDefault),
                                    borderSide: BorderSide(
                                        color: notifires.getBoxColor),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusDefault),
                                    borderSide: BorderSide(
                                        color: notifires.getBoxColor),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusDefault),
                                    borderSide: BorderSide(
                                        color: notifires.getBoxColor),
                                  ),
                                  filled: true,
                                  fillColor: notifires.getBoxColor,
                                  hintText: "Description".tr,
                                  hintStyle: regular2(context),
                                ),
                                style: regular2(context),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                "Live Country".tr,
                                style: heading3(context).copyWith(
                                    color: notifires.getGrey3Whitecolor),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              InkWell(
                                onTap: () {
                                  showCountryPicker(
                                    countryListTheme: CountryListThemeData(
                                        textStyle: TextStyle(
                                            fontSize: 16,
                                            fontFamily: "InterMedium",
                                            color: grey2),
                                        searchTextStyle: const TextStyle(
                                          fontSize: 14,
                                          fontFamily: "InterMedium",
                                        ),
                                        inputDecoration: InputDecoration(
                                            hintText: "Search here...",
                                            prefixIcon: const Icon(
                                                Icons.location_on_outlined),
                                            hintStyle: const TextStyle(
                                              fontSize: 14,
                                              fontFamily: "InterMedium",
                                            ),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                    color: whiteColor)),
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                    color: whiteColor)),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                    color: whiteColor)),
                                            filled: true,
                                            fillColor: grey5)),
                                    context: context,
                                    exclude: <String>[
                                      'EH'
                                    ], // Exclure Western Sahara
                                    onSelect: (country) {
                                      setState(() {
                                        selectedCountryDrop =
                                            country.name.toString();
                                      });
                                    },
                                  );
                                },
                                child: Container(
                                    width: double.maxFinite,
                                    height: 50,
                                    alignment: Alignment.center,
                                    // padding: EdgeInsets.only(left: 12, right: 16,top: 15),
                                    decoration: BoxDecoration(
                                        color: notifires.getBoxColor,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 16,
                                        ),
                                        Text(
                                          selectedCountryDrop ??
                                              "Select Country".tr,
                                          style: regular2(context),
                                        ),
                                        const Spacer(),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: grey4,
                                          size: 18,
                                        ),
                                        const SizedBox(
                                          width: 16,
                                        )
                                      ],
                                    )),
                              ),
                              SizedBox(
                                height: spacingBeteenFeilds,
                              ),
                              const SizedBox(
                                height: 48,
                              ),
                              CustomsButtons(
                                onPressed: () async {
                                  await OneSignalService.forceUpdatePlayerId();
                                  Get.snackbar(
                                    "OneSignal".tr,
                                    "OneSignal sync triggered".tr,
                                    snackPosition: SnackPosition.BOTTOM,
                                    duration: const Duration(seconds: 2),
                                  );
                                },
                                text: "Sync OneSignal ID (Temp)".tr,
                                backgroundColor: notifires.getboxcolor,
                                textColor: getColorBasedOnActiveModuleid(),
                                icon: Icons.notifications_active_outlined,
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              CustomsButtons(
                                onPressed: () {
                                  profileController.updateProfileData(
                                      context, _formKey,
                                      selectedCountryDrop: selectedCountryDrop,
                                      identityBase64: identityBase64);
                                },
                                text: "Update".tr,
                                backgroundColor:
                                    getColorBasedOnActiveModuleid(),
                                icon: Icons.update,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ),
      ),
    );
  }
}
