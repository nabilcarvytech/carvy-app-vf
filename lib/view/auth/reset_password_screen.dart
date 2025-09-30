import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/auth_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/form_validation.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/auth/login_screen.dart';
import 'package:carvy/work_space.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? email;
  final String? resetToken;
  const ResetPasswordScreen({super.key, this.email, this.resetToken});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  AuthController authcontroller = Get.find();
  final _formKey = GlobalKey<FormState>();
  String newPassword = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);

    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: Dimensions.containerWidth,
        child: Scaffold(
          backgroundColor: notifires.getbgcolor,
          body: Stack(
            children: [
              Positioned(
                  right: 0,
                  top: 0,
                  child: Image.asset("assets/images/Vector2.png")),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 120,
                          ),
                          SvgPicture.asset("assets/images/forgotpass.svg"),
                          const SizedBox(height: 30),
                          Text(
                            'Create New Password'.tr,
                            style: heading1(context),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Create your new password to login to $appName".tr,
                            style: regular2(context),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          CustomTextFields(
                              onChnage: (value) {
                                newPassword = value!;
                                authcontroller.newpassword.value = value;
                                return null;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter your password';
                                }
                                // Validate password strength
                                var result = calculatePasswordStrength(value);
                                if (!result.isStrong) {
                                  return 'Password is not strong enough';
                                }
                                return null;
                              },
                              txt: 'New Password'.tr,
                              textEditingControllerCommon: authcontroller
                                  .textEditingResetControllerNewPassword,
                              validateMsg: "Enter your new password".tr),
                          const SizedBox(height: 16),
                          CustomTextFields(
                              validator: (value) {
                                if (authcontroller
                                        .textEditingResetControllerNewPassword
                                        .text !=
                                    authcontroller
                                        .textEditingResetControllerConfirmPassword
                                        .text) {
                                  return "Password did not match".tr;
                                }
                                return null;
                              },
                              txt: 'Confirm Password'.tr,
                              textEditingControllerCommon: authcontroller
                                  .textEditingResetControllerConfirmPassword,
                              validateMsg: "Enter your confirm password".tr),
                          const SizedBox(
                            height: 20,
                          ),
                          Obx(() => authcontroller.newpassword.isEmpty
                              ? const SizedBox()
                              : Builder(
                                  builder: (BuildContext context) {
                                    // Show password strength indicator below the TextFormField
                                    var result = calculatePasswordStrength(
                                        authcontroller.newpassword.value);
                                    return PasswordStrengthIndicator(
                                        result.strengthPercentage);
                                  },
                                )),
                          const SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              children: [
                                SvgPicture.asset("assets/images/alert.svg"),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(
                                    'For enhanced security, ensure your password includes at least one uppercase letter, one lowercase letter, a symbol, and incorporate numbers.'
                                        .tr,
                                    style: regular3(context).copyWith(
                                        fontSize: 12,
                                        color: notifires.getGrey2Whitecolor),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          CustomsButtons(
                              onPressed: () {
                                authcontroller.callChangePassApi(
                                    context, _formKey,
                                    otp: widget.resetToken,
                                    email: widget.email);
                              },
                              text: 'Continue'.tr,
                              backgroundColor: getColorBasedOnActiveModuleid()),
                          const SizedBox(
                            height: 40,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Try again".tr,
                                style: regular3(context).copyWith(
                                    color: notifires.getGrey2Whitecolor),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              InkWell(
                                  onTap: () {
                                    Get.offAll(const LoginScreen());
                                  },
                                  child: Text(
                                    "Go Back".tr,
                                    style: boldstyle(context)
                                        .copyWith(color: acentColor),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PasswordStrengthIndicator extends StatelessWidget {
  final double strengthPercentage;

  const PasswordStrengthIndicator(this.strengthPercentage, {super.key});

  @override
  Widget build(BuildContext context) {
    Color strengthColor;
    if (strengthPercentage >= 75) {
      strengthColor = Colors.green;
    } else if (strengthPercentage >= 50) {
      strengthColor = Colors.orange;
    } else {
      strengthColor = acentColor;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PasswordStrengthContainer(
            color: strengthPercentage >= 25
                ? strengthColor
                : notifires.getGrey5Whitecolor),
        const SizedBox(
          width: 5,
        ),
        PasswordStrengthContainer(
            color: strengthPercentage >= 50
                ? strengthColor
                : notifires.getGrey5Whitecolor),
        const SizedBox(
          width: 5,
        ),
        PasswordStrengthContainer(
            color: strengthPercentage >= 75
                ? strengthColor
                : notifires.getGrey5Whitecolor),
        const SizedBox(
          width: 5,
        ),
        PasswordStrengthContainer(
            color: strengthPercentage >= 90
                ? strengthColor
                : notifires.getGrey5Whitecolor),
        const SizedBox(
          width: 15,
        ),
        Text(
          strengthPercentage < 25
              ? "Very Poor"
              : strengthPercentage < 70
                  ? "Weak"
                  : 'Strong'.tr,
          style: regular3(context)
              .copyWith(color: notifires.getGrey2Whitecolor, fontSize: 16),
        )
      ],
    );
  }
}

class PasswordStrengthContainer extends StatelessWidget {
  final Color color;
  const PasswordStrengthContainer({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      // curve: Curves.elasticOut,
      width: 50,
      height: 8,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(30)),
      duration: const Duration(milliseconds: 300),
    );
  }
}
