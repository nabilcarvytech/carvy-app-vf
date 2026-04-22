import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:carvy/controller/auth_controller.dart';
import 'package:carvy/controller/profile_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/form_validation.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/auth/register/widgets/terms_step.dart';
import 'package:carvy/work_space.dart';

/// Inscription en 3 étapes : identité → téléphone / OTP → conditions générales (comme maquette).
class RegisterWizardScreen extends StatefulWidget {
  const RegisterWizardScreen({super.key});

  @override
  State<RegisterWizardScreen> createState() => _RegisterWizardScreenState();
}

class _RegisterWizardScreenState extends State<RegisterWizardScreen> {
  final AuthController auth = Get.find();
  final ProfileController profileController = Get.find();
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _formKeyIdentity = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyPhone = GlobalKey<FormState>();

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    auth.resetRegisterWizardFlow();
    auth.registerWizardEmbarked.value = true;
  }

  @override
  void dispose() {
    auth.registerWizardEmbarked.value = false;
    _pageController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } else {
      backbuttonforWeb(context);
    }
  }

  /// Barre de progression sur 3 étapes.
  Widget _wizardProgressBar() {
    final progress = (_currentPage + 1) / 3;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 6,
          backgroundColor: notifires.getGrey4Whitecolor.withOpacity(0.35),
          color: getColorBasedOnActiveModuleid(),
        ),
      ),
    );
  }

  Widget _stepIdentity(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
      child: Form(
        key: _formKeyIdentity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text('Register step identity'.tr, style: heading1(context)),
            const SizedBox(height: 8),
            Text(
              'Register step identity subtitle'.tr,
              style: regular2(context).copyWith(color: notifires.getGrey3Whitecolor),
            ),
            const SizedBox(height: 24),
            TextFieldRefs(
              inputAlignment: TextAlign.start,
              txt: 'First Name'.tr,
              icons: Icon(Icons.person_2_outlined, color: acentColor),
              textEditingControllerCommon:
                  auth.textEditingSignUpControllerFirstName,
              inputType: TextInputType.name,
              validator: (v) =>
                  isValidName(v!) ? null : 'Name is invalid'.tr,
            ),
            const SizedBox(height: 16),
            TextFieldRefs(
              inputAlignment: TextAlign.start,
              txt: 'Last Name'.tr,
              icons: Icon(Icons.person_2_outlined, color: acentColor),
              textEditingControllerCommon:
                  auth.textEditingSingUpControllerlastName,
              inputType: TextInputType.name,
              validator: (v) =>
                  isValidName(v!) ? null : 'Name is invalid'.tr,
            ),
            const SizedBox(height: 16),
            TextFieldRefs(
              inputAlignment: TextAlign.start,
              txt: 'Email Address'.tr,
              icons: Icon(Icons.mail, color: acentColor),
              textEditingControllerCommon:
                  auth.textEditingSignUpControllerEmail,
              inputType: TextInputType.emailAddress,
              validator: (v) => validateEmail(v!),
            ),
            const SizedBox(height: 16),
            CustomTextFields(
              txt: 'Password'.tr,
              textEditingControllerCommon:
                  auth.textEditingSignUpControllerPassword,
              validator: (v) => validatesPassword(v!),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 2,
                  width: Get.width * 0.06,
                  color: notifires.getGrey4Whitecolor,
                ),
                const SizedBox(width: 8),
                Text('Or pre-fill with'.tr, style: regular3(context)),
                const SizedBox(width: 8),
                Container(
                  height: 2,
                  width: Get.width * 0.06,
                  color: notifires.getGrey4Whitecolor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: InkWell(
                onTap: () => auth.prefillSignUpFormFromGoogle(context),
                child: Container(
                  height: 64,
                  width: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: strockcolor),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SvgPicture.asset('assets/images/google_icon.svg',
                      height: 28),
                ),
              ),
            ),
            const SizedBox(height: 32),
            CustomsButtons(
              onPressed: () {
                if (_formKeyIdentity.currentState?.validate() ?? false) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOut,
                  );
                }
              },
              text: 'Next'.tr,
              backgroundColor: getColorBasedOnActiveModuleid(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _stepPhoneOtp(BuildContext context) {
    final dial = profileController.selectedCountry.value;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
      child: Form(
        key: _formKeyPhone,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text('Register step phone'.tr, style: heading1(context)),
            const SizedBox(height: 8),
            Text(
              'Register step phone subtitle'.tr,
              style: regular2(context).copyWith(color: notifires.getGrey3Whitecolor),
            ),
            const SizedBox(height: 20),
            Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    IntelPhoneFieldRefs(
                      defultcountry: profileController.defaultCountry.value,
                      textEditingControllerCommons:
                          auth.textEditingSingUpControllerPhoneNumber,
                      oncountryChanged: (number) {
                        auth.phoneError.value = '';
                        auth.textEditingSingUpControllerPhoneNumber.clear();
                        profileController.selectedCountry.value = number.dialCode;
                        profileController.defaultCountry.value = number.code;
                      },
                      onChanged: (value) {
                        auth.phoneError.value = '';
                        final expectedLength =
                            phoneLengths[
                                    profileController.defaultCountry.value] ??
                                10;
                        if (value!.number.length > expectedLength) {
                          auth.textEditingSingUpControllerPhoneNumber.text =
                              value.number.substring(0, expectedLength);
                          auth.textEditingSingUpControllerPhoneNumber.selection =
                              TextSelection.fromPosition(
                            TextPosition(
                                offset: auth
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
                        final expectedLength =
                            phoneLengths[phoneNumber.countryISOCode] ?? 10;
                        if (phoneNumber.number.length != expectedLength) {
                          return 'Phone number must be $expectedLength digits';
                        }
                        return null;
                      },
                    ),
                    if (auth.phoneError.value.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        auth.phoneError.value,
                        style: regular3(context).copyWith(color: redColor),
                      ),
                    ],
                  ],
                )),
            const SizedBox(height: 20),
            Obx(() {
              if (!auth.registerWizardPhoneCodeSent.value) {
                return CustomsButtons(
                  onPressed: () {
                    if (_formKeyPhone.currentState?.validate() ?? false) {
                      auth.registerWizardSendPhoneCode(
                        context,
                        profileController.selectedCountry.value,
                        profileController.defaultCountry.value,
                      );
                    }
                  },
                  text: 'Send verification code'.tr,
                  backgroundColor: getColorBasedOnActiveModuleid(),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Enter OTP'.tr, style: heading3(context)),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: auth.textEditingOtpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'register_wizard_otp_placeholder'.tr,
                      hintStyle: regular(context),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: notifires.getGrey4Whitecolor.withOpacity(0.9),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: getColorBasedOnActiveModuleid(),
                          width: 2,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    final sec = auth.registerWizardResendSeconds.value;
                    final canResend = sec == 0;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          canResend
                              ? "Didn't receive code?".tr
                              : 'register_wizard_resend_in_seconds'
                                  .trParams({'n': '$sec'}),
                          style: regular3(context).copyWith(
                            color: notifires.getGrey2Whitecolor,
                          ),
                        ),
                        if (canResend) ...[
                          const SizedBox(width: 8),
                          Obx(() => auth.isResendLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : InkWell(
                                  onTap: () => auth.registerWizardResendOtp(
                                    context,
                                    dial.startsWith('+') ? dial : '+$dial',
                                  ),
                                  child: Text(
                                    'Resend New Code'.tr,
                                    style: regular2(context).copyWith(
                                      color: getColorBasedOnActiveModuleid(),
                                    ),
                                  ),
                                )),
                        ],
                      ],
                    );
                  }),
                  const SizedBox(height: 20),
                  CustomsButtons(
                    onPressed: () {
                      auth.verifyFunction(
                        context,
                        _formKeyPhone,
                        otp: auth.textEditingOtpController.text,
                        changeEmail: null,
                        changeMobile: null,
                        number: auth.textEditingSingUpControllerPhoneNumber.text,
                        cuntryCode:
                            dial.startsWith('+') ? dial : '+$dial',
                        email: '',
                        defaultCountry: profileController.defaultCountry.value,
                        onRegisterWizardPhoneVerified: () {
                          if (!mounted) return;
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOut,
                          );
                        },
                      );
                    },
                    text: 'Verify'.tr,
                    backgroundColor: getColorBasedOnActiveModuleid(),
                  ),
                ],
              );
            }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return PopScope(
      canPop: false,
      onPopInvoked: (v) {
        backbuttonforWeb(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: _currentPage == 0
              ? null
              : IconButton(
                  icon: Icon(Icons.arrow_back_ios_new,
                      color: notifires.getwhiteblackcolor, size: 20),
                  onPressed: _goBack,
                ),
          title: Text(
            'register_wizard_app_bar_title'.tr,
            style: heading2Grey1(context),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            _wizardProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _stepIdentity(context),
                  _stepPhoneOtp(context),
                  TermsStep(controller: auth),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextButton(
                onPressed: () => Get.toNamed(WebRoutes.loginScreen),
                child: Text(
                  'Already have an account?'.tr,
                  style: regular3(context).copyWith(
                    color: notifires.getGrey3Whitecolor,
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
