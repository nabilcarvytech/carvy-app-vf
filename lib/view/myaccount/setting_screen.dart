import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:carvy/change_languages.dart';
import 'package:carvy/controller/notification_controller.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/customwidget/project_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import 'package:carvy/view/host/bottom_bar_host.dart';
import 'package:carvy/work_space.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  NotificationController notificationController = Get.find();

  bool isdark = GetStorage().read("getDarkValue") ?? false;

  bool darkMode = true;
  @override
  void initState() {
    super.initState();
    notificationController.initilizedValue();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);

    return PopScope(
      canPop: false,
      onPopInvoked: (v) {
        if (isHostMode.value == true) {
          generalController.currentIndexHost.value = 4;
          if (webPlateForm) {
            Get.toNamed(WebRoutes.buttomHost, arguments: {"initialIndex": 4});
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const BottomHost(
                          initialIndex: 4,
                        )));
          }
        } else {
          generalController.currentIndex.value = 4;
          if (webPlateForm) {
            Get.toNamed(WebRoutes.homeMain, arguments: {"initialIndex": 4});
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const HomeMain(
                          initialIndex: 4,
                        )));
          }
        }

        // return false;
      },
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: Dimensions.containerWidth,
          child: Scaffold(
            backgroundColor: notifires.getbgcolor,
            appBar: CustomAppBars(
              onBackButtonPressed: () {
                if (isHostMode.value == true) {
                  generalController.currentIndexHost.value = 4;
                  if (webPlateForm) {
                    Get.toNamed(WebRoutes.buttomHost,
                        arguments: {"initialIndex": 4});
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BottomHost(
                                  initialIndex: 4,
                                )));
                  }
                } else {
                  generalController.currentIndex.value = 4;
                  if (webPlateForm) {
                    Get.toNamed(WebRoutes.homeMain,
                        arguments: {"initialIndex": 4});
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeMain(
                                  initialIndex: 4,
                                )));
                  }
                }
              },
              title: 'Setting'.tr,
              backgroundColor: notifires.getbgcolor,
              iconColor: notifires.getwhiteblackcolor,
              titleColor: notifires.getwhiteblackcolor,
            ),
            body: SingleChildScrollView(
              child: Column(children: [
                Column(
                  children: [
                    const SizedBox(
                      height: 38,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 2),
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                            color: notifires.getBoxColor,
                            borderRadius: BorderRadius.circular(13)),
                        alignment: Alignment.center,
                        width: Get.size.width,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            Icon(
                              Icons.dark_mode_outlined,
                              color: notifires.getGrey3Whitecolor,
                              size: 20,
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Text("Dark Mode".tr,
                                style: regular3(context).copyWith(
                                    color: notifires.getGrey2Whitecolor)),
                            const Spacer(),
                            Transform.scale(
                              scale: .8,
                              child: Switch(
                                value: isdark,
                                inactiveTrackColor: grey4,
                                activeTrackColor:
                                    getColorBasedOnActiveModuleid(),
                                inactiveThumbColor: Colors.white,
                                trackOutlineColor:
                                    WidgetStateProperty.resolveWith<Color?>(
                                        (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return notifires
                                        .getBoxColor; // When the switch is ON
                                  }
                                  return notifires
                                      .getBoxColor; // When the switch is OFF
                                }),
                                onChanged: (value) async {
                                  setState(() {
                                    isdark = value;
                                  });

                                  setState(() {
                                    notifires.setIsDark = value;
                                    GetStorage().write("getDarkValue", value);
                                    // prefs.setBool("setIsDark", value);
                                  });
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: InkWell(
                    onTap: () {
                      Get.toNamed(WebRoutes.changePasswordScreen);
                    },
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                          color: notifires.getBoxColor,
                          borderRadius: BorderRadius.circular(13)),
                      alignment: Alignment.center,
                      width: Get.size.width,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                          ),
                          Icon(
                            Icons.password_sharp,
                            color: notifires.getGrey3Whitecolor,
                            size: 20,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Text(
                            "Change Password".tr,
                            style: regular3(context)
                                .copyWith(color: notifires.getGrey2Whitecolor),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: notifires.getGrey3Whitecolor,
                            size: 17,
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                InkWell(
                  onTap: () async {
                    Get.to(() => const ChangeLanguages());
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                          color: notifires.getBoxColor,
                          borderRadius: BorderRadius.circular(13)),
                      alignment: Alignment.center,
                      width: Get.size.width,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                          ),
                          Icon(
                            Icons.language,
                            color: notifires.getGrey3Whitecolor,
                            size: 20,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Text(
                            "Change Language".tr,
                            style: regular3(context)
                                .copyWith(color: notifires.getGrey2Whitecolor),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: notifires.getGrey3Whitecolor,
                            size: 17,
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // isHostMode.value == true
                //     ? const SizedBox()
                //     : InkWell(
                //         onTap: () async {
                //            Get.toNamed(WebRoutes.changeCurrency);
                //         },
                //         child: Padding(
                //           padding: const EdgeInsets.symmetric(
                //               horizontal: 20, vertical: 5),
                //           child: Container(
                //             height: 55,
                //             decoration: BoxDecoration(
                //                 color: notifires.getBoxColor,
                //                 borderRadius: BorderRadius.circular(13)),
                //             alignment: Alignment.center,
                //             width: Get.size.width,
                //             child: Row(
                //               crossAxisAlignment: CrossAxisAlignment.center,
                //               children: [
                //                 const  SizedBox(
                //                   width: 20,
                //                 ),
                //                 Icon(
                //                   Icons.currency_exchange_rounded,
                //                   color: notifires.getGrey3Whitecolor,
                //                   size: 20,
                //                 ),
                //                 const   SizedBox(
                //                   width: 12,
                //                 ),
                //                 Text(
                //                   "Currency".tr,
                //                   style: regular3(context).copyWith(
                //                       color: notifires.getGrey2Whitecolor),
                //                 ),
                //                 const Spacer(),
                //                 Text(
                //                   currency.tr,
                //                   style: regular3(context).copyWith(
                //                       color: notifires.getGrey2Whitecolor),
                //                 ),
                //                 const SizedBox(
                //                   width: 2,
                //                 ),
                //                 Icon(
                //                   Icons.arrow_forward_ios,
                //                   color: notifires.getGrey3Whitecolor,
                //                   size: 17,
                //                 ),
                //                 const SizedBox(
                //                   width: 20,
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //       )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
