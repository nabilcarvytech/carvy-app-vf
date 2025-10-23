import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:carvy/controller/auth_controller.dart';
import 'package:carvy/controller/global_scope_controller.dart';
import 'package:carvy/controller/profile_controller.dart';
import 'package:carvy/controller/search_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/form_validation.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'dart:io';
import 'package:carvy/work_space.dart';

class LoginScreen extends StatefulWidget implements PreferredSizeWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
  @override
  Size get preferredSize => throw UnimplementedError();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AuthController authController = Get.find();
  ProfileController profileController = Get.find();
  SearchControllerHome filterController = Get.find();
  void someMethodWhereYouCallLogin() {
    authController.loginMethod(context, _formKey);
  }

  void clearSignUpData() {
    profileController.myImage.value = "";
    authController.textEditingSignUpControllerFirstName.clear();
    authController.textEditingSingUpControllerlastName.clear();
    authController.textEditingSignUpControllerEmail.clear();
    authController.textEditingSingUpControllerPhoneNumber.clear();
    authController.textEditingSignUpControllerPassword.clear();
    authController.textEditingSingUpControllerDOB.clear();
  }

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      clearAllController();
    });
    super.initState();
  }

  GlobalScopeController globalScopeController =
      Get.put(GlobalScopeController());
  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return Scaffold(
        backgroundColor: notifires.getbgcolor,
        body: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              right: 0,
              child: SingleChildScrollView(
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: Dimensions.containerWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeLarge,
                          vertical: Dimensions.paddingSizeExtraLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: Dimensions.paddingSizeExtraSmall),
                                child: Container(
                                  height: Get.height * 0.045,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: greyColor2, width: 1.5),
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radiusExtraLarge)),
                                  child: ElevatedButton(
                                      onPressed: () {
                                        token = "";
                                        GetStorage().erase();
                                        filterController.clearFilter();
                                        Get.toNamed(WebRoutes.homeMain);
                                        generalController.currentIndex.value =
                                            0;
                                        loginModel = null;
                                      },
                                      style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor:
                                              notifires.getblackwhitecolor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.radiusExtraLarge),
                                          )),
                                      child: Text(
                                        'Skip'.tr,
                                        style: buttonTextAirMd.copyWith(
                                            color: notifires.getwhiteblackcolor,
                                            fontSize: 14),
                                      )),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 50),
                          commonlyUserlogo(),
                          const SizedBox(
                            height: 15,
                          ),
                          Text("Let's sign you in.".tr,
                              style: heading1(context)),
                          const SizedBox(height: 5),
                          Text("Welcome back. You've been missed!".tr,
                              style: regular2(context).copyWith(
                                  color: notifires.getGrey3Whitecolor)),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          const SizedBox(
                            height: 8,
                          ),
                          Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  TextFieldRefs(
                                    inputAlignment: TextAlign.start,
                                    txt: 'Email',
                                    icons: Icon(Icons.mail,
                                        color: getColorBasedOnActiveModuleid()),
                                    textEditingControllerCommon: authController
                                        .textEditingControllerEmail,
                                    inputType: TextInputType.emailAddress,
                                    validator: (value) {
                                      return validateEmail(value!);
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  CustomTextFields(
                                      txt: 'Password',
                                      textEditingControllerCommon:
                                          authController
                                              .textEditingControllerPass,
                                      validator: (value) {
                                        return validatePassword(value!);
                                      }),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: InkWell(
                                      onTap: () {
                                        handlelogin = false;
                                        Get.toNamed(
                                            WebRoutes.forgetPasswordScreen);
                                      },
                                      child: Text('Forget Password?'.tr,
                                          style: regular3(context).copyWith(
                                              color:
                                                  getColorBasedOnActiveModuleid(),
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  CustomsButtons(
                                      onPressed: () {
                                        filterController.clearFilter();
                                        someMethodWhereYouCallLogin();
                                      },
                                      text: 'Login'.tr,
                                      backgroundColor:
                                          getColorBasedOnActiveModuleid()),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                ],
                              )),
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
                                        authController.googleLogin(context);
                                      },
                                      child: Container(
                                        height: 84,
                                        width: 84,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            border:
                                                Border.all(color: strockcolor),
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
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Don't have an account?".tr,
                                  style: regular3(context).copyWith(
                                      color: notifires.getGrey2Whitecolor)),
                              const SizedBox(
                                width: 5,
                              ),
                              InkWell(
                                onTap: () {
                                  handlelogin = false;
                                  clearSignUpData();
                                  filterController.clearFilter();
                                  Get.toNamed(WebRoutes.signUpScreen);
                                },
                                child: Text('Sign Up'.tr,
                                    style: regular2(context).copyWith(
                                        color: getColorBasedOnActiveModuleid(),
                                        fontSize: 16)),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
