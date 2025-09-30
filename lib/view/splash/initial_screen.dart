import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:carvy/controller/kyc_controller.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import 'package:carvy/view/splash/splash_screen.dart';
import 'package:carvy/work_space.dart';
import '../../customwidget/custom_active_module_id_widget.dart';
import '../host/bottom_bar_host.dart';
import '../onBoarding/vehicle/vehicle_on_boarding_screen.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  KycController kycController = Get.find();
  @override
  void initState() {
    super.initState();
    // Remove splash after a delay or when data is loaded
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        FlutterNativeSplash.remove();
        setScreen();
      }
    });
  }

  Future<void> setScreen() async {
    final duration = Duration(
      seconds: GetStorage().read('Firstuser') == null ? 5 : 0,
    );

    Timer(duration, () {
      if (webPlateForm) {
        if (GetStorage().read('Firstuser') != true ||
            GetStorage().read('Firstuser') != true) {
          Get.offNamed(WebRoutes.vehicleOnboardingScreen);
        } else {
          isHostMode.value == true
              ? Get.offNamed(WebRoutes.buttomHost)
              : Get.offNamed(WebRoutes.homeMain);
        }
      } else {
        if (GetStorage().read('Firstuser') != true) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const VehicleOnBoardingScreen()));
        } else if (GetStorage().read('Firstuser') != true) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const VehicleOnBoardingScreen()));
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => isHostMode.value == true
                      ? const BottomHost(initialIndex: 0)
                      : const HomeMain(initialIndex: 0)));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return Scaffold(backgroundColor: themeColor, body: const SplashScreen());
  }
}
