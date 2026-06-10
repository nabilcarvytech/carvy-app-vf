import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/utils/safe_navigation.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/work_space.dart';

Widget buildNoDataWidget(BuildContext context, String? name,
    {String? dynamicText}) {
  return TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0, end: 1),
    duration: const Duration(seconds: 1),
    builder: (BuildContext context, double opacity, Widget? child) {
      return Opacity(
        opacity: opacity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "assets/images/nodata.png",
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 20),
              Text(
                "$name",
                textAlign: TextAlign.center,
                style: heading3Grey1(context),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget connectionError(BuildContext context, String? name,
    {String? dynamicText}) {
  return TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0, end: 1),
    duration: const Duration(seconds: 1),
    builder: (BuildContext context, double opacity, Widget? child) {
      return Opacity(
        opacity: opacity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset("assets/images/offline.svg"),
              const SizedBox(
                height: 30,
              ),
              Text(
                "$name",
                textAlign: TextAlign.center,
                style: heading2(context),
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                  onTap: () {
                    safeGetBack(context: context);
                  },
                  child: Text(
                    "Back",
                    style: boldstyle(context).copyWith(
                        color: getColorBasedOnActiveModuleid(),
                        fontSize: 18,
                        decoration: TextDecoration.underline,
                        decorationColor: getColorBasedOnActiveModuleid()),
                  )),
            ],
          ),
        ),
      );
    },
  );
}

Widget buildNoDataWidgetforDetail(BuildContext context, String? name,
    {String? dynamicText}) {
  return TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0, end: 1),
    duration: const Duration(seconds: 1),
    builder: (BuildContext context, double opacity, Widget? child) {
      return Opacity(
        opacity: opacity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "assets/images/noData.webp",
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 20),
              Text(
                "$name",
                textAlign: TextAlign.center,
                style: heading3Grey1(context),
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                  onTap: () {
                    if (webPlateForm) {
                      if (isHostMode.value == true) {
                        generalController.currentIndexHost.value = 0;
                        Get.toNamed(
                          WebRoutes.buttomHost,
                        );
                      } else {
                        generalController.currentIndex.value = 0;
                        Get.toNamed(
                          WebRoutes.homeMain,
                        );
                      }
                    } else {
                      safeGetBack(context: context);
                    }
                  },
                  child: Text(
                    "Back",
                    style: boldstyle(context).copyWith(
                        color: getColorBasedOnActiveModuleid(),
                        fontSize: 18,
                        decoration: TextDecoration.underline,
                        decorationColor: getColorBasedOnActiveModuleid()),
                  )),
            ],
          ),
        ),
      );
    },
  );
}
