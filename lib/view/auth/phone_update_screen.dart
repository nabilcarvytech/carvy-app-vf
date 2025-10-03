import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:carvy/controller/profile_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/work_space.dart';

class PhoneUpdateScreen extends StatefulWidget {
  final bool? fromProfile;
  const PhoneUpdateScreen({super.key, this.fromProfile});
  @override
  State<PhoneUpdateScreen> createState() => _PhoneUpdateScreenState();
}

class _PhoneUpdateScreenState extends State<PhoneUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  ProfileController profileController = Get.find();

  @override
  void initState() {
    super.initState();
    // SchedulerBinding.instance.addPostFrameCallback((_) {
    if (loginModel != null) {
      if (loginModel!.data!.phoneCountry != null) {
        profileController.selectedCountry.value =
            loginModel!.data!.phoneCountry!;
      }
    }

    // });
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return Align(
      alignment: Alignment.center,
      child: Form(
        key: _formKey,
        child: SizedBox(
          width: Dimensions.containerWidth,
          child: Scaffold(
            backgroundColor: notifires.getbgcolor,
            body: Stack(
              children: [        
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeLarge,
                          vertical: Dimensions.paddingSizeExtraLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 120,
                          ),
                          SvgPicture.asset("assets/images/forgotpass.svg"),
                          const SizedBox(height: 30),
                          Text(
                            'Change Phone Number'.tr,
                            style: heading1(context),
                          ),
                          const SizedBox(height: 30),
                          IntelPhoneFieldRefs(
                            defultcountry:
                                profileController.defaultCountry.value,
                            textEditingControllerCommons: profileController
                                .textEditingPhoneUpdateController,
                            selectedcountry:
                                profileController.selectedCountry.value,
                            oncountryChanged: (value) {
                              profileController.textEditingPhoneUpdateController
                                  .clear();
                              profileController.selectedCountry.value =
                                  "+${value.dialCode}";
                              profileController.defaultCountry.value =
                                  value.code;
                            },
                            onChanged: (value) {
                              int expectedLength = phoneLengths[
                                      profileController.defaultCountry.value] ??
                                  10;

                              if (value!.number.length > expectedLength) {
                                profileController
                                        .textEditingPhoneUpdateController.text =
                                    value.number.substring(0, expectedLength);
                                profileController
                                    .textEditingPhoneUpdateController
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
                            validator: (phoneNumber) {
                              if (phoneNumber == null ||
                                  phoneNumber.number.isEmpty) {
                                return 'Please enter your phone number';
                              }

                              int expectedLength =
                                  phoneLengths[phoneNumber.countryISOCode] ??
                                      10;

                              if (phoneNumber.number.length != expectedLength) {
                                return 'Phone number must be $expectedLength digits';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 35),
                          CustomsButtons(
                              onPressed: () {
                                if (profileController
                                        .textEditingPhoneUpdateController
                                        .text ==
                                    loginModel!.data!.phone!) {
                                  showErrorToastMessage(
                                      "Please change the number");
                                  return;
                                }
                                profileController.checkPhoneUpdate(
                                    context, _formKey,
                                    selectedCountries:
                                        profileController.selectedCountry.value,
                                    selectedCountryIso:
                                        profileController.defaultCountry.value);
                              },
                              text: 'Submit'.tr,
                              backgroundColor: getColorBasedOnActiveModuleid()),
                          const SizedBox(height: 100),
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
                                        color: getColorBasedOnActiveModuleid()),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
