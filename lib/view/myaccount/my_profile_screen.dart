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
import 'package:carvy/work_space.dart';
import 'package:country_picker/country_picker.dart';
import 'package:intl/intl.dart';

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

  /// Photo de profil : édition réservée aux vendeurs / hôtes (aligné sur `loginModel.data.role`).
  bool get _canEditProfilePhoto {
    final r = (loginModel?.data?.role ?? '').toLowerCase();
    return r == 'vendor' || r == 'host';
  }

  Future<void> _pickBirthDate() async {
    DateTime initialDate = DateTime(2000, 1, 1);
    final raw = profileController.textEditingProfileControllerDOB.text.trim();
    if (raw.isNotEmpty) {
      try {
        initialDate = DateTime.parse(raw);
      } catch (_) {}
    }
    final now = DateTime.now();
    if (initialDate.isAfter(now)) {
      initialDate = now;
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: getColorBasedOnActiveModuleid(),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      profileController.textEditingProfileControllerDOB.text =
          DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    notifires = ColorNotifires();
    getUserDataLocallyToHandleTheState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DefaultAssetBundle.of(context)
          .loadString("assets/json/countries.json")
          .then((value) {
        listCountry = jsonDecode(value);
        setState(() {});
      });
      profileController.setFirstNameFromLoginModel();
      profileController.refreshProfileFromServer();

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

  void _popToPreviousScreen() {
    if (isHostMode.value) {
      if (generalController.currentIndexHost.value == 0) {
        generalController.currentIndexHost.value = 0;
      } else {
        generalController.currentIndexHost.value = 4;
      }
    } else {
      if (generalController.currentIndex.value == 0) {
        generalController.currentIndex.value = 0;
      } else {
        generalController.currentIndex.value = 4;
      }
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _popToPreviousScreen();
        }
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
                    onTap: _popToPreviousScreen,
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
                                            if (_canEditProfilePhoto)
                                              Positioned(
                                                bottom: 5,
                                                right: 0,
                                                child: profileController
                                                    .selectImagePopup(context),
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
                                readOnly: true,
                                inputAlignment: TextAlign.start,
                                txt: 'Date of birth'.tr,
                                icons: Icon(
                                  Icons.calendar_today,
                                  color: getColorBasedOnActiveModuleid(),
                                ),
                                textEditingControllerCommon: profileController
                                    .textEditingProfileControllerDOB,
                                inputType: TextInputType.none,
                                onTap: _pickBirthDate,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter Date of Birth'.tr;
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: spacingBeteenFeilds,
                              ),
                              Obx(
                                () {
                                  final languages =
                                      profileController.availableLanguages;
                                  final current =
                                      profileController.selectedLanguage.value;
                                  final dropdownValue = languages
                                          .contains(current)
                                      ? current
                                      : languages.first;
                                  return DropdownButtonFormField<String>(
                                    value: dropdownValue,
                                    decoration: InputDecoration(
                                      hintText: 'Language'.tr,
                                      hintStyle: regular3(context),
                                      prefixIcon: Icon(
                                        Icons.language,
                                        color:
                                            getColorBasedOnActiveModuleid(),
                                      ),
                                      filled: true,
                                      fillColor: notifires.getBoxColor,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: notifires.getBoxColor),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: notifires.getBoxColor),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: notifires.getBoxColor),
                                      ),
                                    ),
                                    items: languages
                                        .map(
                                          (lang) => DropdownMenuItem<String>(
                                            value: lang,
                                            child: Text(
                                              lang,
                                              style: regular2(context),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        profileController
                                            .selectedLanguage.value = newValue;
                                        profileController
                                                .textEditingProfileControllerLangauge
                                                .text =
                                            profileController.getLanguageCode(
                                                newValue);
                                      }
                                    },
                                  );
                                },
                              ),
                              SizedBox(
                                height: spacingBeteenFeilds,
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
                                height: spacingBeteenFeilds + 8,
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
                              const SizedBox(
                                height: 24,
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
