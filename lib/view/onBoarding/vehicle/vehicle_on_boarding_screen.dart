import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/view/auth/login_screen.dart';
import 'package:carvy/work_space.dart';
import '../../../customwidget/form_elements.dart';
import '../../../utils/theme_style.dart';

class VehicleOnBoardingScreen extends StatefulWidget {
  const VehicleOnBoardingScreen({super.key});
  @override
  State<VehicleOnBoardingScreen> createState() =>
      _VehicleOnBoardingScreenState();
}

class _VehicleOnBoardingScreenState extends State<VehicleOnBoardingScreen> {
  late PageController pageController;

  List get content => [
    {
      "image": "assets/images/car-photo.png",
      "title": "Welcome to Carvy".tr,
      "description":
          "Book cars and bikes easily for any journey. Quick rides or long trips, we've got you covered".tr
    }
  ];
  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Utiliser ValueListenableBuilder pour reconstruire automatiquement lors du changement de langue
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, child) {
        return Scaffold(
      backgroundColor: whiteColor,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: PageView.builder(
                      controller: pageController,
                      scrollDirection: Axis.horizontal,
                      itemCount: content.length,
                      itemBuilder: (context, index) {
                        return customOnboardingWidget(
                            content[index]["image"],
                            content[index]["title"],
                            content[index]["description"]);
                      }),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            // top: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: CustomsButtons(
                      text: "Get Started!".tr,
                      backgroundColor: vehicalThemColor,
                      onPressed: () {
                        if (webPlateForm) {
                          Get.offNamed(WebRoutes.loginScreen);
                        } else {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation,
                                      secondaryAnimation) =>
                                  const LoginScreen(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                var begin = const Offset(1.0, 0.0);
                                var end = Offset.zero;
                                var curve = Curves.ease;
                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));
                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                            ),
                          );
                        }
                      }),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}
