import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/form_validation.dart';
import 'package:carvy/customwidget/project_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/utils/theme_style.dart';

class UserGoogleSignUpScreen extends StatefulWidget {
  const UserGoogleSignUpScreen({super.key});

  @override
  State<UserGoogleSignUpScreen> createState() => _UserGoogleSignUpScreenState();
}

class _UserGoogleSignUpScreenState extends State<UserGoogleSignUpScreen> {
  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);

    TextEditingController textEditingGoogleSignUpFirstNameController =
        TextEditingController();
    TextEditingController textEditingGoogleSignUpLastNameController =
        TextEditingController();
    TextEditingController textEditingGoogleSignUpEmailController =
        TextEditingController();
    TextEditingController textEditingGoogleSignUpPhoneNumberController =
        TextEditingController();

    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      appBar: CustomAppBars(
          title: 'Update Profile'.tr,
          backgroundColor: notifires.getbgcolor,
          iconColor: whiteColor,
          titleColor: whiteColor),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeLarge,
              vertical: Dimensions.paddingSizeExtraLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabelNames(labelname: 'First Name'.tr),
              const SizedBox(height: 8),
              TextFieldRefs(
                inputAlignment: TextAlign.start,
                txt: "First Name".tr,
                icons: Icon(
                  Icons.person_2_outlined,
                  color: notifires.getwhiteblackcolor.withOpacity(0.4),
                ),
                textEditingControllerCommon:
                    textEditingGoogleSignUpFirstNameController,
                inputType: TextInputType.name,
                validator: (value) {
                  if (isValidName(value!)) {
                    return null;
                  } else {
                    return 'Name is invalid'.tr;
                  }
                },
              ),
              const SizedBox(height: 16),
              LabelNames(labelname: 'Last Name'.tr),
              const SizedBox(height: 8),
              TextFieldRefs(
                inputAlignment: TextAlign.start,
                txt: "Last Name".tr,
                icons: Icon(
                  Icons.person_2_outlined,
                  color: notifires.getwhiteblackcolor.withOpacity(0.4),
                ),
                textEditingControllerCommon:
                    textEditingGoogleSignUpLastNameController,
                inputType: TextInputType.name,
                validator: (value) {
                  if (isValidName(value!)) {
                    return null;
                  } else {
                    return 'Name is invalid'.tr;
                  }
                },
              ),
              const SizedBox(height: 16),
              LabelNames(labelname: 'Email'.tr),
              const SizedBox(height: 8),
              TextFieldRefs(
                inputAlignment: TextAlign.start,
                txt: "Email Address".tr,
                icons: Icon(
                  Icons.mail,
                  color: notifires.getwhiteblackcolor.withOpacity(0.4),
                ),
                textEditingControllerCommon:
                    textEditingGoogleSignUpEmailController,
                inputType: TextInputType.emailAddress,
                validator: (value) {
                  return validateEmail(value!);
                },
              ),
              const SizedBox(height: 16),
              LabelNames(labelname: 'Phone Number'.tr),
              const SizedBox(height: 8),
              IntelPhoneFieldRefs(
                  textEditingControllerCommons:
                      textEditingGoogleSignUpPhoneNumberController),
              const SizedBox(height: 35),
              CustomsButtons(
                  onPressed: () {
                    Get.toNamed(WebRoutes.homeMain);
                  },
                  text: 'Submit'.tr,
                  backgroundColor: themeColor)
            ],
          ),
        ),
      ),
    );
  }
}
