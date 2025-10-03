import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:carvy/controller/auth_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/form_validation.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final AuthController controller = Get.find();
  final _formKey = GlobalKey<FormState>();

  void someMethodWhereYouCallForgetPassword() {
    controller.forgetPassword(context, _formKey);
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return Scaffold(
        backgroundColor: notifires.getbgcolor,
        body: Stack(
          children: [
        
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: 0,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: Dimensions.containerWidth,
                    child: Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeLarge),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 120,
                              ),
                              SvgPicture.asset("assets/images/forgotpass.svg"),
                              const SizedBox(height: 30),
                              Text(
                                'Reset Password'.tr,
                                style: heading1(context),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Enter the email address associated with your account,and we'll email you a link to reset your password."
                                    .tr,
                                style: regular2(context),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                              TextFieldRefs(
                                inputAlignment: TextAlign.start,
                                txt: 'Email'.tr,
                                icons: Icon(
                                  Icons.mail,
                                  color: notifires.getwhiteblackcolor
                                      .withOpacity(0.4),
                                ),
                                textEditingControllerCommon: controller
                                    .textEditingForgetPasswordControllerEmail,
                                inputType: TextInputType.emailAddress,
                                validator: (value) {
                                  return validateEmail(value!);
                                },
                              ),
                              const SizedBox(height: 50),
                              CustomsButtons(
                                  onPressed: () {
                                    someMethodWhereYouCallForgetPassword();
                                    // Your onPressed logic here
                                  },
                                  text: 'Send Otp'.tr,
                                  backgroundColor:
                                      getColorBasedOnActiveModuleid()),
                              const SizedBox(height: 140),
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
                                        Get.back();
                                      },
                                      child: Text(
                                        "Go Back".tr,
                                        style: boldstyle(context).copyWith(
                                            color:
                                                getColorBasedOnActiveModuleid()),
                                      )),
                                ],
                              ),
                              const SizedBox(
                                height: 70,
                              )
                            ],
                          ),
                        )),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
