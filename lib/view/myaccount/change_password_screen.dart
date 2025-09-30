import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/auth_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/form_validation.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String? email;
  final String? resetToken;
  const ChangePasswordScreen({super.key, this.email, this.resetToken});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  AuthController authController = Get.find();
  final _formKey = GlobalKey<FormState>();
  String newPassword = "";

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);

    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: Dimensions.containerWidth,
        child: Scaffold(
          backgroundColor: notifires.getbgcolor,
          appBar: AppBar(
            backgroundColor: notifires.getbgcolor,
            elevation: 0,
            centerTitle: true,
            leading: InkWell(
              onTap: () {
                Get.back();
              },
              child: Icon(
                Icons.arrow_back,
                color: notifires.getwhiteblackcolor,
              ),
            ),
            title: Text(
              "Change Password".tr,
              style:
                  appBarHeading.copyWith(color: notifires.getwhiteblackcolor),
            ),
          ),
          body: SafeArea(
              child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    LabelNames(labelname: 'Old Password'.tr),
                    const SizedBox(height: 8),
                    CustomTextFields(
                        onChnage: (value) {
                          return null;

                          // newPassword = value!;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your old Password'.tr;
                          }
                          return null;
                        },
                        txt: 'Old Password'.tr,
                        textEditingControllerCommon:
                            authController.textEditingControllerOldPassword,
                        validateMsg: "Enter your new password".tr),
                    const SizedBox(height: 16),
                    LabelNames(labelname: 'New Password'.tr),
                    const SizedBox(height: 8),
                    CustomTextFields(
                        onChnage: (value) {
                          newPassword = value!;
                          return null;
                        },
                        validator: validatesPassword,
                        txt: 'New Password'.tr,
                        textEditingControllerCommon:
                            authController.textEditingControllerNewPassword,
                        validateMsg: "Enter your new password".tr),
                    const SizedBox(height: 16),
                    LabelNames(labelname: 'Confirm Password'.tr),
                    const SizedBox(height: 8),
                    CustomTextFields(
                        validator: (value) {
                          if (authController
                                  .textEditingControllerNewPassword.text !=
                              authController
                                  .textEditingControllerConfirmPassword.text) {
                            return "Password did not match".tr;
                          }
                          return null;
                        },
                        txt: 'Confirm Password'.tr,
                        textEditingControllerCommon:
                            authController.textEditingControllerConfirmPassword,
                        validateMsg: "Enter your confirm password".tr),
                    const SizedBox(height: 40),
                    CustomsButtons(
                        onPressed: () {
                          // authcontroller.updateThePassword(context, _formKey);

                          if (_formKey.currentState!.validate()) {
                            authController.updateThePassword(context, _formKey);
                          } else {}
                        },
                        text: 'Continue'.tr,
                        backgroundColor: getColorBasedOnActiveModuleid())
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
