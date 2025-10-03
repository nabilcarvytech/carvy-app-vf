import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/auth_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/theme_style.dart';

class OtpScreen extends StatefulWidget {
  final String? number;
  final String? countryCode;
  final String? otpValue;
  final String? email;
  final Map? changeMobiles;
  final bool? changeMobile;
  final bool? changeEmail;
  final String? defaultCountry;

  const OtpScreen(
      {super.key,
      this.number,
      this.countryCode,
      this.otpValue,
      this.email,
      this.changeMobile,
      this.changeEmail,
      this.changeMobiles,
      this.defaultCountry});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final AuthController controller = Get.find();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 1),
      () {
        controller.textEditingOtpController.text = widget.otpValue!;
      },
    );
    startResendTimer();
  }

  int _remainingTime = 15;
  bool _isResendEnabled = true;
  late Timer _timer;

  void startResendTimer() {
    setState(() {
      _isResendEnabled = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer.cancel();
          _isResendEnabled = true;
          _remainingTime = 0;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: Dimensions.containerWidth,
        child: Scaffold(
          backgroundColor: notifires.getbgcolor,
          body: Stack(
            children: [
         
              Positioned(
                left: 0,
                bottom: 0,
                top: 0,
                right: 0,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                        vertical: Dimensions.paddingSizeExtraLarge),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 80,
                          ),
                          SvgPicture.asset("assets/images/otpveriyfi.svg"),
                          const SizedBox(
                            height: 20,
                          ),
                          Text("Verification Code".tr,
                              style: heading1(context)),
                          const SizedBox(
                            height: 15,
                          ),
                          Text("We have sent the code verification to".tr,
                              style: regular(context)),
                          const SizedBox(height: 10),
                          Text(
                              widget.number!.isNotEmpty
                                  ? "${widget.countryCode} ${widget.number}"
                                  : "${widget.email}".tr,
                              style: heading3(context)),
                          const SizedBox(
                            height: 20,
                          ),
                          _isResendEnabled
                              ? SizedBox(
                                  height: 22,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Didn't receive code?".tr,
                                          style: regular3(context).copyWith(
                                              color: notifires
                                                  .getGrey2Whitecolor)),
                                      const SizedBox(width: 5),
                                      Obx(
                                        () => controller.isResendLoading.value
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator())
                                            : InkWell(
                                                onTap: () async {
                                                  controller.resendNewCodeFunction(
                                                      context, _formKey,
                                                      otp: controller
                                                          .textEditingOtpController
                                                          .text,
                                                      changeEmail:
                                                          widget.changeEmail,
                                                      changeMobile:
                                                          widget.changeMobile,
                                                      email: widget.email,
                                                      number: widget.number,
                                                      cuntryCode:
                                                          widget.countryCode,
                                                      changeMobiles:
                                                          widget.changeMobiles);
                                                  startResendTimer();
                                                  setState(() {
                                                    _remainingTime = 15;
                                                    _isResendEnabled = false;
                                                  });
                                                },
                                                child: Text(
                                                    "Resend New Code".tr,
                                                    style: regular2(context)
                                                        .copyWith(
                                                            color: acentColor,
                                                            fontSize: 16)),
                                              ),
                                      )
                                    ],
                                  ),
                                )
                              : SizedBox(
                                  height: 22,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Resend code in '.tr,
                                        style: regular3(context).copyWith(
                                            color:
                                                notifires.getGrey2Whitecolor),
                                      ),
                                      Text('00:$_remainingTime',
                                          style: regular2(context).copyWith(
                                            color: acentColor,
                                            fontSize: 16,
                                          ))
                                    ],
                                  ),
                                ),
                          const SizedBox(height: 20),
                          TextFormField(
                            style: regular3(context).copyWith(
                                fontSize: 20,
                                color: notifires.getGrey2Whitecolor),
                            controller: controller.textEditingOtpController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            onChanged: ((value) {}),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: notifires.getBoxColor,
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault),
                                borderSide: BorderSide(
                                    color: notifires.getGrey6Whitecolor),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault),
                                borderSide: BorderSide(
                                    color: notifires.getGrey6Whitecolor),
                              ),
                              hintText: 'Enter OTP'.tr,
                              hintStyle: regular(context),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(13),
                                  borderSide: BorderSide(
                                      color: notifires.getGrey6Whitecolor)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(13),
                                  borderSide: BorderSide(
                                      color: notifires.getGrey6Whitecolor)),
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          CustomsButtons(
                              onPressed: () {
                                controller.verifyFunction(context, _formKey,
                                    otp: controller
                                        .textEditingOtpController.text,
                                    // otp: widget.otpValue,
                                    changeEmail: widget.changeEmail,
                                    changeMobile: widget.changeMobile,
                                    number: widget.number,
                                    cuntryCode: widget.countryCode,
                                    email: widget.email,
                                    defaultCountry: widget.defaultCountry);
                              },
                              text: 'Verify'.tr,
                              backgroundColor: acentColor),
                          const SizedBox(
                            height: 60,
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
                                    Get.back();
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
