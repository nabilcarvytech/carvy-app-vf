import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:carvy/controller/profile_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/project_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/auth/login_screen.dart';

class GoogleUpdate extends StatefulWidget {
  const GoogleUpdate({super.key});

  @override
  State<GoogleUpdate> createState() => _GoogleUpdateState();
}

class _GoogleUpdateState extends State<GoogleUpdate> {
  ProfileController profileController = Get.find();
  final _formKey = GlobalKey<FormState>();
  DateTime birthday = DateTime(1997, 3, 5);

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return PopScope(
      onPopInvoked: (val) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      },
      child: Scaffold(
        backgroundColor: notifires.getbgcolor,
        appBar: CustomAppBars(
          onBackButtonPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          title: 'Update Personal Info'.tr,
          backgroundColor: whiteColor,
          iconColor: notifires.getblackblue,
          titleColor: notifires.getblackblue,
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 16,
                  ),
                  LabelNames(labelname: 'Mobile Number'.tr),
                  const SizedBox(
                    height: 8,
                  ),
                  IntelPhoneFieldRefs(
                    validator: (phoneNumber) {
                      if (phoneNumber == null || phoneNumber.number.isEmpty) {
                        return 'Please enter your phone number';
                      }

                      int expectedLength =
                          phoneLengths[phoneNumber.countryISOCode] ?? 10;
                      if (phoneNumber.number.length != expectedLength) {
                        return 'Phone number must be $expectedLength digits';
                      }
                      return null;
                    },
                    defultcountry: profileController.defaultCountry.value,
                    textEditingControllerCommons:
                        profileController.textEditingPhoneUpdateController,
                    selectedcountry: profileController.selectedCountry.value,
                    oncountryChanged: (value) {
                      profileController.textEditingPhoneUpdateController
                          .clear();
                      profileController.selectedCountry.value =
                          "+${value.dialCode}";
                      profileController.defaultCountry.value = value.code;
                    },
                    onChanged: (value) {
                      // Limit the input to the expected length
                      int expectedLength = phoneLengths[
                              profileController.defaultCountry.value] ??
                          10;

                      if (value!.number.length > expectedLength) {
                        // Truncate the input to the expected length
                        profileController.textEditingPhoneUpdateController
                            .text = value.number.substring(0, expectedLength);
                        profileController.textEditingPhoneUpdateController
                            .selection = TextSelection.fromPosition(
                          TextPosition(
                              offset: profileController
                                  .textEditingPhoneUpdateController
                                  .text
                                  .length),
                        );
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  CustomsButtons(
                      onPressed: () {
                        profileController.loginWithSocialMedia.value = true;
                        profileController.checkPhoneUpdate(context, _formKey,
                            selectedCountries:
                                profileController.selectedCountry.value,
                            selectedCountryIso:
                                profileController.defaultCountry.value);
                      },
                      text: 'Update'.tr,
                      backgroundColor: themeColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
