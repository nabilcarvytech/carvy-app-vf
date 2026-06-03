import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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

/// Inscription : identité → e-mail OTP optionnel → téléphone / OTP SMS.
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
  late final TapGestureRecognizer _supportTapRecognizer;

  @override
  void initState() {
    super.initState();
    auth.resetRegisterWizardFlow();
    auth.registerWizardEmbarked.value = true;
    _supportTapRecognizer =
        TapGestureRecognizer()..onTap = _showSupportBottomSheet;
  }

  @override
  void dispose() {
    auth.registerWizardEmbarked.value = false;
    _supportTapRecognizer.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } else if (webPlateForm) {
      backbuttonforWeb(context);
    } else if (Navigator.canPop(context)) {
      Get.back();
    }
  }

  void _goToPhoneStep() {
    if (!mounted) return;
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
    );
  }

  Future<void> _launchSupportUri(Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Impossible d'ouvrir ce lien"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSupportBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final primary = getColorBasedOnActiveModuleid();
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    "Besoin d'aide ?",
                    textAlign: TextAlign.center,
                    style:
                        heading2(context).copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    "Notre équipe est là pour vous accompagner.",
                    textAlign: TextAlign.center,
                    style: regular2(context).copyWith(color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 16),
                _supportTile(
                  icon: Icons.wechat_rounded,
                  iconColor: Colors.green,
                  title: "Chatter avec nous",
                  subtitle: "Réponse en quelques minutes",
                  onTap: () => _launchSupportUri(
                    Uri.parse(
                      "https://wa.me/212660060079?text=Bonjour%20Carvy%2C%20j%27ai%20un%20probl%C3%A8me%20lors%20de%20mon%20inscription.",
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _supportTile(
                  icon: Icons.phone_rounded,
                  iconColor: Colors.blue,
                  title: "Appeler le support",
                  subtitle: "Disponible de 9h à 20h",
                  onTap: () => _launchSupportUri(Uri.parse("tel:+212660060079")),
                ),
                const SizedBox(height: 10),
                _supportTile(
                  icon: Icons.mail_rounded,
                  iconColor: Colors.deepOrange,
                  title: "Envoyer un email",
                  subtitle: "Réponse sous 24h",
                  onTap: () => _launchSupportUri(
                    Uri.parse(
                      "mailto:nabil.carvytech@gmail.com?subject=Aide%20Inscription",
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      "Fermer",
                      style: regular3(context).copyWith(color: primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _supportTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: heading3(context)),
        subtitle: Text(
          subtitle,
          style: regular3(context).copyWith(color: Colors.black87),
        ),
      ),
    );
  }

  /// Barre de progression sur 3 étapes Flutter (l'OTP e-mail est un écran séparé).
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
              txt: 'Date of birth'.tr,
              icons: Icon(Icons.calendar_today, color: acentColor),
              textEditingControllerCommon:
                  auth.textEditingSingUpControllerDOB,
              inputType: TextInputType.none,
              readOnly: true,
              onTap: () => auth.pickSignUpBirthDate(context),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter Date of Birth'.tr;
                }
                return null;
              },
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
              onChange: (v) {
                auth.registerWizardEmailError.value = '';
                return null;
              },
            ),
            Obx(() => auth.registerWizardEmailError.value.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      auth.registerWizardEmailError.value,
                      style: regular3(context).copyWith(color: redColor),
                    ),
                  )),
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
              onPressed: () async {
                if (_formKeyIdentity.currentState?.validate() ?? false) {
                  final available =
                      await auth.registerWizardCheckEmailAvailability(context);
                  if (!available) return;
                  final readyForPhone =
                      await auth.registerWizardSendPhoneCode(
                    context,
                    profileController.selectedCountry.value,
                    profileController.defaultCountry.value,
                    onDuplicateEmail: () {
                      if (!mounted) return;
                      if (_currentPage != 0) {
                        _pageController.animateToPage(
                          0,
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                  );
                  if (!readyForPhone || !mounted) return;
                  _goToPhoneStep();
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
                      auth.requestPhoneOtp(
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
                                  onTap: () => auth.requestPhoneOtp(
                                    context,
                                    dial.startsWith('+') ? dial : '+$dial',
                                    profileController.defaultCountry.value,
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
                      auth.verifyPhoneOtp(
                        context,
                        auth.textEditingOtpController.text,
                        onSuccess: () {
                          _pageController.animateToPage(
                            2,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
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
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _goBack();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: notifires.getwhiteblackcolor,
            ),
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
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: "Besoin d'aide ? ",
                        style: regular3(context).copyWith(
                          color: notifires.getGrey3Whitecolor,
                          fontSize: 12.5,
                        ),
                        children: [
                          TextSpan(
                            text: "Contactez le support",
                            recognizer: _supportTapRecognizer,
                            style: regular3(context).copyWith(
                              color: getColorBasedOnActiveModuleid(),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(WebRoutes.loginScreen),
                    child: Text(
                      'Already have an account?'.tr,
                      style: regular3(context).copyWith(
                        color: notifires.getGrey3Whitecolor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
