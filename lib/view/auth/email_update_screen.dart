import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:carvy/controller/profile_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/form_validation.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/work_space.dart';

class EmailUpdateScreen extends StatefulWidget {
  const EmailUpdateScreen({super.key});

  @override
  State<EmailUpdateScreen> createState() => _EmailUpdateScreenState();
}

class _EmailUpdateScreenState extends State<EmailUpdateScreen> {
  ProfileController controller = Get.find();
  @override
  void initState() {
    super.initState();
    if (loginModel != null) {
      if (loginModel!.data!.email != null) {
        controller.textEditingProfileControllerCheckEmail.text =
            loginModel!.data!.email!;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    notifires = Provider.of<ColorNotifires>(context, listen: true);

    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      body: Stack(
        children: [
          Positioned(
              right: 0,
              top: 0,
              child: Image.asset("assets/images/Vector2.png")),
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
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 120,
                      ),
                      SvgPicture.asset("assets/images/forgotpass.svg"),
                      const SizedBox(height: 30),
                      Text(
                        'Change Email ID'.tr,
                        style: heading1(context),
                      ),
                      const SizedBox(height: 30),
                      TextFieldRefs(
                        inputAlignment: TextAlign.start,
                        txt: 'Enter Your Email'.tr,
                        textEditingControllerCommon:
                            controller.textEditingProfileControllerCheckEmail,
                        inputType: TextInputType.emailAddress,
                        validator: (value) {
                          return validateEmail(value!);
                        },
                        icons: Icon(Icons.mail,
                            color:
                                notifires.getwhiteblackcolor.withOpacity(0.4)),
                      ),
                      const SizedBox(height: 35),
                      CustomsButtons(
                          onPressed: () {
                            if (controller
                                    .textEditingProfileControllerCheckEmail
                                    .text ==
                                loginModel!.data!.email!) {
                              showErrorToastMessage("Please change the email");
                              return;
                            }
                            controller.checkEmailUpdate(context, formKey);
                          },
                          text: 'Submit'.tr,
                          backgroundColor: getColorBasedOnActiveModuleid()),
                      const SizedBox(height: 100),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Try again".tr,
                            style: regular3(context)
                                .copyWith(color: notifires.getGrey2Whitecolor),
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
          ),
        ],
      ),
    );
  }
}
