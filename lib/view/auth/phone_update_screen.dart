import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:carvy/controller/auth_controller.dart';
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
  late final AuthController authController = Get.find();

  bool isOtpSent = false;
  Map<String, dynamic>? _changeMobilePayload;
  Timer? _resendTimer;
  int _remainingResend = 60;
  bool _canResendOtp = false;

  @override
  void initState() {
    super.initState();
    if (loginModel != null) {
      if (loginModel!.data!.phoneCountry != null) {
        profileController.selectedCountry.value =
            loginModel!.data!.phoneCountry!;
      }
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _cancelResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = null;
  }

  void _startResendCountdown() {
    _cancelResendTimer();
    setState(() {
      _remainingResend = 60;
      _canResendOtp = false;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_remainingResend > 0) {
          _remainingResend--;
        } else {
          _cancelResendTimer();
          _canResendOtp = true;
        }
      });
    });
  }

  void _onOtpSentFromApi(String otpValue, Map<String, dynamic> mapx) {
    setState(() {
      isOtpSent = true;
      _changeMobilePayload = mapx;
    });
    _startResendCountdown();
    authController.textEditingOtpController.clear();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        authController.textEditingOtpController.text = otpValue;
      }
    });
  }

  Future<void> _onPrimaryButtonPressed(BuildContext context) async {
    if (!isOtpSent) {
      if (profileController.textEditingPhoneUpdateController.text ==
          loginModel!.data!.phone!) {
        showErrorToastMessage("Please change the number");
        return;
      }
      await profileController.checkPhoneUpdate(
        context,
        _formKey,
        selectedCountries: profileController.selectedCountry.value,
        selectedCountryIso: profileController.defaultCountry.value,
        onOtpSentInline: _onOtpSentFromApi,
      );
      return;
    }

    await authController.verifyFunction(
      context,
      _formKey,
      otp: authController.textEditingOtpController.text.trim(),
      changeMobile: true,
      email: '',
      number: profileController.textEditingPhoneUpdateController.text,
      cuntryCode: profileController.selectedCountry.value,
      defaultCountry: profileController.defaultCountry.value,
    );
  }

  Future<void> _onResendTap(BuildContext context) async {
    if (_changeMobilePayload == null || !_canResendOtp) return;
    await authController.resendNewCodeFunction(
      context,
      _formKey,
      changeMobile: true,
      changeMobiles: _changeMobilePayload,
      number: profileController.textEditingPhoneUpdateController.text,
      cuntryCode: profileController.selectedCountry.value,
    );
    if (!mounted) return;
    _startResendCountdown();
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
                          const SizedBox(height: 120),
                          SvgPicture.asset("assets/images/forgotpass.svg"),
                          const SizedBox(height: 30),
                          Text(
                            'Change Phone Number'.tr,
                            style: heading1(context),
                          ),
                          const SizedBox(height: 30),
                          AnimatedOpacity(
                            opacity: isOtpSent ? 0.65 : 1,
                            duration: const Duration(milliseconds: 250),
                            child: IntelPhoneFieldRefs(
                              defultcountry:
                                  profileController.defaultCountry.value,
                              textEditingControllerCommons: profileController
                                  .textEditingPhoneUpdateController,
                              selectedcountry:
                                  profileController.selectedCountry.value,
                              readOnly: isOtpSent,
                              isenable: !isOtpSent,
                              oncountryChanged: (value) {
                                if (isOtpSent) return;
                                profileController
                                    .textEditingPhoneUpdateController
                                    .clear();
                                profileController.selectedCountry.value =
                                    "+${value.dialCode}";
                                profileController.defaultCountry.value =
                                    value.code;
                              },
                              onChanged: (value) {
                                if (isOtpSent) return null;
                                int expectedLength = phoneLengths[
                                        profileController
                                            .defaultCountry.value] ??
                                    10;

                                if (value!.number.length > expectedLength) {
                                  profileController
                                          .textEditingPhoneUpdateController
                                          .text =
                                      value.number.substring(0, expectedLength);
                                  profileController
                                      .textEditingPhoneUpdateController
                                      .selection = TextSelection.fromPosition(
                                    TextPosition(
                                      offset: profileController
                                          .textEditingPhoneUpdateController
                                          .text
                                          .length,
                                    ),
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

                                if (phoneNumber.number.length !=
                                    expectedLength) {
                                  return 'Phone number must be $expectedLength digits';
                                }
                                return null;
                              },
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 320),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.08),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: !isOtpSent
                                ? const SizedBox(
                                    key: ValueKey('no_otp'),
                                    height: 8,
                                  )
                                : Padding(
                                    key: const ValueKey('otp_block'),
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Saisissez le code OTP'.tr,
                                            style: regular2(context).copyWith(
                                              color: notifires
                                                  .getGrey2Whitecolor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        TextFormField(
                                          style: regular3(context).copyWith(
                                            fontSize: 18,
                                            color: notifires
                                                .getGrey2Whitecolor,
                                            letterSpacing: 4,
                                          ),
                                          controller: authController
                                              .textEditingOtpController,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.sms_outlined,
                                              color: acentColor,
                                            ),
                                            filled: true,
                                            fillColor: notifires.getBoxColor,
                                            hintText: 'Enter OTP'.tr,
                                            hintStyle: regular(context),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                Dimensions.radiusDefault,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(13),
                                              borderSide: BorderSide(
                                                color: notifires
                                                    .getGrey6Whitecolor,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(13),
                                              borderSide: BorderSide(
                                                color: acentColor,
                                                width: 1.2,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            if (_canResendOtp) ...[
                                              Text(
                                                "Didn't receive code?".tr,
                                                style: regular3(context)
                                                    .copyWith(
                                                  color: notifires
                                                      .getGrey2Whitecolor,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Obx(
                                                () => authController
                                                        .isResendLoading.value
                                                    ? const SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                      )
                                                    : InkWell(
                                                        onTap: () =>
                                                            _onResendTap(
                                                                context),
                                                        child: Text(
                                                          'Resend New Code'.tr,
                                                          style: regular2(
                                                                  context)
                                                              .copyWith(
                                                            color:
                                                                acentColor,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                            ] else
                                              Text(
                                                'register_wizard_resend_in_seconds'
                                                    .trParams({
                                                  'n': '$_remainingResend',
                                                }),
                                                style: regular3(context)
                                                    .copyWith(
                                                  color: notifires
                                                      .getGrey2Whitecolor,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 35),
                          CustomsButtons(
                            onPressed: () => _onPrimaryButtonPressed(context),
                            text: isOtpSent
                                ? 'Vérifier'.tr
                                : 'Envoyer'.tr,
                            backgroundColor: getColorBasedOnActiveModuleid(),
                          ),
                          const SizedBox(height: 100),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Try again".tr,
                                style: regular3(context).copyWith(
                                    color: notifires.getGrey2Whitecolor),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  Get.back();
                                },
                                child: Text(
                                  "Go Back".tr,
                                  style: boldstyle(context).copyWith(
                                    color: getColorBasedOnActiveModuleid(),
                                  ),
                                ),
                              ),
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
