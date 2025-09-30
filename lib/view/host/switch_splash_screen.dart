import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/work_space.dart';

import '../../utils/common_widget.dart';

class SwitchSplashScreen extends StatefulWidget {
  final bool isHostMode;

  const SwitchSplashScreen({super.key, required this.isHostMode});
  @override
  State<SwitchSplashScreen> createState() => _SwitchSplashScreenState();
}

class _SwitchSplashScreenState extends State<SwitchSplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      switchphostFunmction(context);
      generalController.fetchGeneralSettings();
    });
  }

  bool darkMode = GetStorage().read("getDarkValue") ?? false;

  @override
  Widget build(BuildContext context) {
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
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  commonlyUserlogo(),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                      widget.isHostMode
                          ? "Switch to Rent".tr
                          : "Switch to Lend".tr,
                      style: heading1(context))
                ]),
          ),
        ],
      ),
    );
  }
}
