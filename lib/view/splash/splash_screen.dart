import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/work_space.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double opacity = 0.0;
  AnimationController? controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
    controller?.forward();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: controller!,
                    reverseCurve: Curves.bounceInOut,
                    curve: Curves.easeInCubic,
                  ),
                ),
                child: Column(
                  children: [
                    ScaleTransition(
                      scale: CurvedAnimation(
                          parent: controller!, curve: Curves.bounceInOut),
                      child: Material(
                          elevation:
                              6.0, // Adds shadow effect (adjust value as needed, e.g., 4.0 to 10.0)
                          shape: CircleBorder(),
                          child: commonlyUserlogo()),
                    ),
                    const SizedBox(height: 15),
                    Text('Welcome to'.tr,
                        style: regular01.copyWith(color: whiteColor)),
                    Text(appName.tr,
                        style: heading01.copyWith(color: whiteColor)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
    // );
  }
}
