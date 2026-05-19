import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:carvy/controller/auth_controller.dart';
import 'package:carvy/controller/profile_controller.dart';
import 'package:carvy/controller/search_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/form_validation.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:get/get.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/myaccount/static_page_screen.dart';
import 'package:carvy/work_space.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  ProfileController profileController = Get.find();
  bool isChecked = false;
  final AuthController authController = Get.find();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return PopScope(
      canPop: false,
      onPopInvoked: (v) {
        backbuttonforWeb(context);
      },
      child: Scaffold(
        backgroundColor: notifires.getbgcolor,
        body: Stack(
          children: [
       
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: Dimensions.containerWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeLarge,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 140),
                            commonlyUserlogo(),
                            const SizedBox(
                              height: 10,
                            ),
                            Text("Get Started!".tr, style: heading1(context)),
                            Text("Create an account to continue.".tr,
                                style: regular2(context).copyWith(
                                    color: notifires.getGrey3Whitecolor)),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFieldRefs(
                              inputAlignment: TextAlign.start,
                              txt: "First Name".tr,
                              icons: Icon(
                                Icons.person_2_outlined,
                                color: acentColor,
                              ),
                              textEditingControllerCommon: authController
                                  .textEditingSignUpControllerFirstName,
                              inputType: TextInputType.name,
                              validator: (value) {
                                if (isValidName(value!)) {
                                  return null;
                                } else {
                                  return 'Name is invalid'.tr;
                                }
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFieldRefs(
                              inputAlignment: TextAlign.start,
                              txt: "Last Name".tr,
                              icons: Icon(
                                Icons.person_2_outlined,
                                color: acentColor,
                              ),
                              textEditingControllerCommon: authController
                                  .textEditingSingUpControllerlastName,
                              inputType: TextInputType.name,
                              validator: (value) {
                                if (isValidName(value!)) {
                                  return null;
                                } else {
                                  return 'Name is invalid'.tr;
                                }
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFieldRefs(
                              inputAlignment: TextAlign.start,
                              txt: 'Date of birth'.tr,
                              icons: Icon(
                                Icons.calendar_today,
                                color: acentColor,
                              ),
                              textEditingControllerCommon: authController
                                  .textEditingSingUpControllerDOB,
                              inputType: TextInputType.none,
                              readOnly: true,
                              onTap: () =>
                                  authController.pickSignUpBirthDate(context),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter Date of Birth'.tr;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFieldRefs(
                              inputAlignment: TextAlign.start,
                              txt: "Email Address".tr,
                              icons: Icon(
                                Icons.mail,
                                color: acentColor,
                              ),
                              textEditingControllerCommon: authController
                                  .textEditingSignUpControllerEmail,
                              inputType: TextInputType.emailAddress,
                              validator: (value) {
                                return validateEmail(value!);
                              },
                              onChange: (v) {
                                authController.registerWizardEmailError.value =
                                    '';
                                return null;
                              },
                            ),
                            Obx(() => authController
                                    .registerWizardEmailError.value.isEmpty
                                ? const SizedBox.shrink()
                                : Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      authController
                                          .registerWizardEmailError.value,
                                      style: regular3(context)
                                          .copyWith(color: redColor),
                                    ),
                                  )),
                            const SizedBox(height: 20),
                            Obx(() => Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    IntelPhoneFieldRefs(
                                      defultcountry: profileController
                                          .defaultCountry.value,
                                      textEditingControllerCommons:
                                          authController
                                              .textEditingSingUpControllerPhoneNumber,
                                      oncountryChanged: (number) {
                                        authController.phoneError.value = '';
                                        authController
                                            .textEditingSingUpControllerPhoneNumber
                                            .clear();
                                        profileController
                                                .selectedCountry.value =
                                            number.dialCode;
                                        profileController
                                                .defaultCountry.value =
                                            number.code;
                                      },
                                      onChanged: (value) {
                                        authController.phoneError.value = '';
                                        int expectedLength = phoneLengths[
                                                profileController
                                                    .defaultCountry.value] ??
                                            10;

                                        if (value!.number.length >
                                            expectedLength) {
                                          authController
                                                  .textEditingSingUpControllerPhoneNumber
                                                  .text =
                                              value.number.substring(
                                                  0, expectedLength);
                                          authController
                                                  .textEditingSingUpControllerPhoneNumber
                                                  .selection =
                                              TextSelection.fromPosition(
                                            TextPosition(
                                                offset: authController
                                                    .textEditingSingUpControllerPhoneNumber
                                                    .text
                                                    .length),
                                          );
                                        }
                                        return null;
                                      },
                                      validator: (phoneNumber) {
                                        if (phoneNumber == null ||
                                            phoneNumber.number.isEmpty) {
                                          return 'Please enter your phone number';
                                        }

                                        int expectedLength = phoneLengths[
                                                phoneNumber.countryISOCode] ??
                                            10;
                                        if (phoneNumber.number.length !=
                                            expectedLength) {
                                          return 'Phone number must be $expectedLength digits';
                                        }
                                        return null;
                                      },
                                    ),
                                    if (authController
                                        .phoneError.value.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        authController.phoneError.value,
                                        style: regular3(context)
                                            .copyWith(color: redColor),
                                      ),
                                    ],
                                  ],
                                )),
                            const SizedBox(height: 20),
                            CustomTextFields(
                                txt: 'Password'.tr,
                                textEditingControllerCommon: authController
                                    .textEditingSignUpControllerPassword,
                                validator: (value) {
                                  return validatesPassword(value!);
                                }),
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    constraints: const BoxConstraints.expand(
                                        width: 33, height: 40),
                                    color: Colors.transparent,
                                    padding: const EdgeInsets.only(right: 5),
                                    child: Transform.scale(
                                      scale: 1.2,
                                      child: Checkbox(
                                        activeColor: acentColor,
                                        focusColor: acentColor,
                                        value: isChecked,
                                        onChanged: (bool? newValue) {
                                          setState(() {
                                            isChecked = newValue!;
                                          });
                                        },
                                        checkColor: whiteColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall),
                                        ),
                                        side: BorderSide(
                                            color: notifires.getGrey3Whitecolor,
                                            width: 2.0),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        showModalBottomSheet(
                                          useRootNavigator: true,
                                          backgroundColor: notifires.getbgcolor,
                                          isScrollControlled: true,
                                          useSafeArea: true,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return StaticPage(
                                                data: "Terms and Condition".tr);
                                          },
                                        );
                                      },
                                      child: Text.rich(TextSpan(
                                          text:
                                              "By creating an account, you agree to our \n"
                                                  .tr,
                                          style: regular3(context)
                                              .copyWith(fontSize: 14),
                                          children: [
                                            TextSpan(
                                                text: 'Terms and Condition'.tr,
                                                style: regular(context)
                                                    .copyWith(
                                                        color: acentColor,
                                                        fontSize: 14))
                                          ])),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 35),
                            CustomsButtons(
                                onPressed: () {
                                  authController.signUp(
                                    context,
                                    _formKey,
                                    isChecked,
                                    profileController.selectedCountry.value,
                                    profileController.defaultCountry.value,
                                  );
                                },
                                text: 'Continue'.tr,
                                backgroundColor: acentColor),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    height: 2,
                                    width: Get.width * 0.08,
                                    color: notifires.getGrey4Whitecolor),
                                const SizedBox(width: 10),
                                Text(
                                  'or continue with'.tr,
                                  style: regular3(context),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                    height: 1.5,
                                    width: Get.width * 0.08,
                                    color: notifires.getGrey4Whitecolor),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusExtraLarge),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InkWell(
                                        onTap: () {
                                          authController
                                              .prefillSignUpFormFromGoogle(
                                                  context);
                                        },
                                        child: Container(
                                          height: 84,
                                          width: 84,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: strockcolor),
                                              borderRadius:
                                                  BorderRadius.circular(18)),
                                          child: SvgPicture.asset(
                                              "assets/images/google_icon.svg",
                                              height: 35),
                                        )),
                                    const SizedBox(width: 15),
                                    kIsWeb || Platform.isAndroid
                                        ? const SizedBox()
                                        : Container(
                                            height: 84,
                                            width: 84,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: strockcolor),
                                                borderRadius:
                                                    BorderRadius.circular(18)),
                                            child: InkWell(
                                                onTap: () async {
                                                  authController
                                                      .appleLogin(context);
                                                },
                                                child: Icon(
                                                  Icons.apple_outlined,
                                                  size: 45,
                                                  color: notifires
                                                      .getwhiteblackcolor,
                                                )),
                                          ),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Already have an account?".tr,
                                    style: regular3(context)),
                                const SizedBox(
                                  width: 5,
                                ),
                                InkWell(
                                  onTap: () {
                                    Get.toNamed(WebRoutes.loginScreen);
                                  },
                                  child: Text('Login'.tr,
                                      style: regular2(context).copyWith(
                                          color: acentColor, fontSize: 16)),
                                )
                              ],
                            ),
                            const SizedBox(height: 80)
                          ]),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
