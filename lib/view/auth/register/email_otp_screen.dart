import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:carvy/controller/auth_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';

/// Vérification OTP e-mail après inscription (`OTP_SENT`).
class EmailOtpScreen extends StatefulWidget {
  final String email;
  final bool fromRegisterWizard;
  final String? phoneDialCode;
  final String? phoneIsoCode;

  const EmailOtpScreen({
    super.key,
    required this.email,
    this.fromRegisterWizard = false,
    this.phoneDialCode,
    this.phoneIsoCode,
  });

  @override
  State<EmailOtpScreen> createState() => _EmailOtpScreenState();
}

class _EmailOtpScreenState extends State<EmailOtpScreen> {
  final AuthController auth = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    auth.textEditingEmailOtpController.clear();
    auth.textEditingEmailOtpController.addListener(_onOtpChanged);
    if (auth.emailOtpResendSeconds.value == 0) {
      auth.startEmailOtpResendCountdown(60);
    }
  }

  void _onOtpChanged() => setState(() {});

  @override
  void dispose() {
    auth.textEditingEmailOtpController.removeListener(_onOtpChanged);
    super.dispose();
  }

  PinTheme _pinTheme(BuildContext context, {bool focused = false}) {
    final accent = getColorBasedOnActiveModuleid();
    return PinTheme(
      width: 48,
      height: 56,
      textStyle: heading2(context).copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: notifires.getboxcolor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: accent.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
        border: Border.all(
          color: focused
              ? accent
              : notifires.getGrey4Whitecolor.withOpacity(0.9),
          width: focused ? 2 : 1.5,
        ),
      ),
    );
  }

  Future<void> _onVerify() async {
    final code = auth.textEditingEmailOtpController.text.trim();
    if (code.length != 6 || auth.emailOtpVerifying.value) return;
    await auth.verifyEmailOtpCode(
      code,
      context: context,
      email: widget.email,
      fromRegisterWizard: widget.fromRegisterWizard,
      phoneDialCode: widget.phoneDialCode,
      phoneIsoCode: widget.phoneIsoCode,
    );
  }

  void _onSkipEmailOtp() {
    auth.registerWizardPhoneCodeSent.value = false;
    auth.update();
    Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = 'email_otp_description'.trParams({'email': widget.email});

    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: Dimensions.containerWidth,
        child: Scaffold(
          backgroundColor: notifires.getbgcolor,
          appBar: AppBar(
            backgroundColor: notifires.getbgcolor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: notifires.getwhiteblackcolor,
              ),
              onPressed: () => Get.back(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge,
                vertical: Dimensions.paddingSizeDefault,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Center(
                      child: SvgPicture.asset('assets/images/otpveriyfi.svg'),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'email_otp_title'.tr,
                      style: heading1(context),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      style: regular2(context).copyWith(
                        color: notifires.getGrey3Whitecolor,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Pinput(
                        length: 6,
                        controller: auth.textEditingEmailOtpController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        defaultPinTheme: _pinTheme(context),
                        focusedPinTheme: _pinTheme(context, focused: true),
                        submittedPinTheme: _pinTheme(context, focused: true),
                        separatorBuilder: (index) => const SizedBox(width: 8),
                        hapticFeedbackType: HapticFeedbackType.lightImpact,
                        cursor: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 18,
                              height: 2,
                              color: getColorBasedOnActiveModuleid(),
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
                        onChanged: (_) => setState(() {}),
                        onCompleted: (_) => _onVerify(),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Obx(() {
                      final sec = auth.emailOtpResendSeconds.value;
                      final canResend = sec == 0;
                      if (!canResend) {
                        return Text(
                          'email_otp_resend_in'.trParams({'n': '$sec'}),
                          style: regular3(context).copyWith(
                            color: notifires.getGrey3Whitecolor,
                          ),
                          textAlign: TextAlign.center,
                        );
                      }
                      if (auth.emailOtpResendLoading.value) {
                        return const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      return Center(
                        child: TextButton(
                          onPressed: () => auth.resendEmailOtp(widget.email),
                          child: Text(
                            'email_otp_resend'.tr,
                            style: regular2(context).copyWith(
                              color: getColorBasedOnActiveModuleid(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 32),
                    Obx(() {
                      final code = auth.textEditingEmailOtpController.text;
                      final canVerify =
                          code.trim().length == 6 && !auth.emailOtpVerifying.value;
                      return Opacity(
                        opacity: canVerify ? 1 : 0.5,
                        child: CustomsButtons(
                          onPressed: canVerify ? _onVerify : () {},
                          text: auth.emailOtpVerifying.value
                              ? '...'
                              : 'email_otp_verify_button'.tr,
                          backgroundColor: canVerify
                              ? getColorBasedOnActiveModuleid()
                              : notifires.getGrey4Whitecolor,
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: auth.emailOtpVerifying.value
                            ? null
                            : _onSkipEmailOtp,
                        child: Text(
                          'email_otp_skip'.tr,
                          style: regular2(context).copyWith(
                            color: notifires.getGrey3Whitecolor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
