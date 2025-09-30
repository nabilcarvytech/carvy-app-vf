import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/auth/login_screen.dart';
import 'package:carvy/view/host/bottom_bar_host.dart';
import 'package:carvy/work_space.dart';
import '../bottombar/home_main.dart';

class SuccessChangePassword extends StatefulWidget {
  const SuccessChangePassword({super.key});

  @override
  State<SuccessChangePassword> createState() => _SuccessChangePasswordState();
}

class _SuccessChangePasswordState extends State<SuccessChangePassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
                child: SvgPicture.asset("assets/images/successPassword.svg")),
            const SizedBox(
              height: 20,
            ),
            Text("Great! Password Changed".tr, style: heading1(context)),
            const SizedBox(
              height: 15,
            ),
            Material(
              child: Text(
                'Don\'t worry! we\'ll let you know if there is any\nproblem with your account'
                    .tr,
                textAlign: TextAlign.center,
                style: regular3(context).copyWith(fontSize: 14),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            CustomsButtons(
              text: 'Continue'.tr,
              onPressed: () async {
                if (GetStorage().read('Firstuser') == true) {
                  if (isHostMode.value == true) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BottomHost(
                                  initialIndex: 0,
                                )));
                    generalController.currentIndexHost.value = 0;
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeMain(
                                  initialIndex: 0,
                                )));
                    generalController.currentIndex.value = 0;
                  }
                } else {
                  Get.offAll(const LoginScreen());
                }
              },
              backgroundColor: acentColor,
            ),
            const SizedBox(
              height: 80,
            ),
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
                      style: boldstyle(context).copyWith(color: acentColor),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
