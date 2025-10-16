import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/bottombar/home_main.dart';

class CustomAppBars extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final Color? iconColor;
  final Color titleColor;
  final VoidCallback? onBackButtonPressed;
  final List<Widget>? actions;
  final double elevation;
  final bool? centerTitle;

  const CustomAppBars(
      {super.key,
      required this.title,
      required this.backgroundColor,
      this.iconColor,
      required this.titleColor,
      this.onBackButtonPressed,
      this.actions,
      this.elevation = 0.0,
      this.centerTitle});

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return AppBar(
      centerTitle: true,
      backgroundColor: backgroundColor,
      surfaceTintColor: backgroundColor,
      elevation: elevation,
      leadingWidth: 85,
      leading: GestureDetector(
        onTap: onBackButtonPressed ??
            () {
              Navigator.pop(context);
            },
        child: Padding(
          padding:
              const EdgeInsets.only(left: 20, top: 8, bottom: 8, right: 20),
          child: PhysicalModel(
            color: Colors.transparent,
            shadowColor: notifires.getGrey4Whitecolor,
            elevation: 1.0, 
            borderRadius: BorderRadius.circular(8),
            child: Container(
              alignment: Alignment.center,
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  color: notifires.getboxcolor,
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.arrow_back,
                  color: getColorBasedOnActiveModuleid()),
            ),
          ),
        ),
      ),
      title: Text(title,
          style: heading2Grey1(context).copyWith(color: titleColor)),
      actions: actions,
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


class CustomAppBarHeaders extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomAppBarHeaders({super.key});
  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return LayoutBuilder(builder: (context, constraints) {
      if (Get.width >= 850) {
        return const SizedBox();
      } else {
        return const SizedBox();
      }
    });
  }
  @override
  Size get preferredSize => const Size(200, kToolbarHeight);
}

class BottomAppBarFooters extends StatelessWidget {
  const BottomAppBarFooters({super.key});
  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return LayoutBuilder(builder: (context, constraints) {
      if (Get.width >= 950) {
        return BottomAppBar(
            padding: EdgeInsets.zero,
            color: whiteColor,
            surfaceTintColor: whiteColor,
            height: 370,
            child: Column(
              children: [
                Stack(
                  children: [
                    Flexible(
                      child: Container(
                        height: 270,
                        margin: const EdgeInsets.only(top: 30),
                        width: Dimensions.containerWidth,
                        color: const Color.fromARGB(255, 248, 236, 217)
                            .withOpacity(0.5),
                        child: Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 40),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 30),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 3.0,
                                                  color: whiteColor,
                                                  style: BorderStyle.solid),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions
                                                          .radiusExtraLarge),
                                              color: const Color.fromARGB(
                                                  255, 248, 236, 217),
                                            ),
                                            child: Center(
                                              child: Image.asset(
                                                'assets/images/ub-logo.png',
                                                height: 35,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            'carvy'.tr,
                                            style: largeHeading.copyWith(
                                                color: themeColor),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          'Subscribe to our news letter to get latest Update'
                                              .tr,
                                          style: appSmallText.copyWith(
                                              fontWeight: FontWeight.w600,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Flexible(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Flexible(
                                                child: Image.asset(
                                                    'assets/images/facebook.png',
                                                    height: 30)),
                                            const SizedBox(width: 20),
                                            Flexible(
                                                child: Image.asset(
                                                    'assets/images/instagram.png',
                                                    height: 30)),
                                            const SizedBox(width: 20),
                                            Flexible(
                                                child: Image.asset(
                                                    'assets/images/linkedin.png',
                                                    height: 30)),
                                            const SizedBox(width: 20),
                                            Flexible(
                                                child: Image.asset(
                                                    'assets/images/twitter.png',
                                                    height: 30)),
                                            const SizedBox(width: 20),
                                            Flexible(
                                                child: Image.asset(
                                                    'assets/images/youtube.png',
                                                    height: 30)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 25),
                                      Flexible(
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Container(
                                                width: 150,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                    color: notifires
                                                        .getwhiteblackcolor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            Dimensions
                                                                .radiusSmall)),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(width: 5),
                                                    Flexible(
                                                        child: Image.asset(
                                                            'assets/images/googleplay.png',
                                                            height: 30)),
                                                    Flexible(
                                                      child: Column(
                                                        children: [
                                                          const SizedBox(
                                                              height: 5),
                                                          Flexible(
                                                              child: Text(
                                                            'GET IT ON',
                                                            style: appRegularText.copyWith(
                                                                color: notifires
                                                                    .getblackwhitecolor,
                                                                fontSize: 8,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis),
                                                          )),
                                                          const SizedBox(
                                                              height: 2),
                                                          Text(
                                                            'Google Play',
                                                            style: smallHeading.copyWith(
                                                                color: notifires
                                                                    .getblackwhitecolor,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                fontSize: 14),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Flexible(
                                              child: Container(
                                                width: 150,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                    color: notifires
                                                        .getwhiteblackcolor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            Dimensions
                                                                .radiusSmall)),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(width: 10),
                                                    Flexible(
                                                        child: Image.asset(
                                                      'assets/images/apple.png',
                                                      height: 25,
                                                      color: notifires
                                                          .getblackwhitecolor,
                                                    )),
                                                    const SizedBox(width: 5),
                                                    Flexible(
                                                      child: Column(
                                                        children: [
                                                          const SizedBox(
                                                              height: 5),
                                                          Flexible(
                                                              child: Text(
                                                            'Download on the',
                                                            style: appRegularText.copyWith(
                                                                color: notifires
                                                                    .getblackwhitecolor,
                                                                fontSize: 8,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis),
                                                          )),
                                                          const SizedBox(
                                                              height: 2),
                                                          Text(
                                                            'App Store',
                                                            style: smallHeading.copyWith(
                                                                color: notifires
                                                                    .getblackwhitecolor,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                fontSize: 14),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Flexible(
                              flex: 2,
                              child: Container(
                                margin: const EdgeInsets.only(
                                    top: 40, right: 40, bottom: 50),
                                decoration: BoxDecoration(
                                    color: const Color(0xFFedc4b3)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusDefault)),
                                child: Row(
                                  children: [
                                    Flexible(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 25, left: 25),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Flexible(
                                                child: Text(
                                              'Become a store Owner',
                                              style: gilroySemiBold.copyWith(
                                                  fontSize: 10),
                                            )),
                                            const SizedBox(height: 12),
                                            Flexible(
                                                child: Text('Help & Support',
                                                    style:
                                                        gilroySemiBold.copyWith(
                                                            fontSize: 10))),
                                            const SizedBox(height: 12),
                                            Flexible(
                                                child: Text(
                                                    'Privacy and Policy',
                                                    style:
                                                        gilroySemiBold.copyWith(
                                                            fontSize: 10))),
                                            const SizedBox(height: 12),
                                            Flexible(
                                                child: Text(
                                                    'Terms and Condition',
                                                    style:
                                                        gilroySemiBold.copyWith(
                                                            fontSize: 10))),
                                            const SizedBox(height: 12),
                                            Flexible(
                                                child: Text('Product details',
                                                    style:
                                                        gilroySemiBold.copyWith(
                                                            fontSize: 10))),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 60),
                                    Flexible(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/mail.png',
                                            height: 40,
                                          ),
                                          const SizedBox(height: 8),
                                          Text('Send Us Mail',
                                              style: smallHeading.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14)),
                                          const SizedBox(height: 5),
                                          Text(
                                            'abcd@gmail.com',
                                            style: appSmallText.copyWith(
                                                fontSize: 10,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 70),
                                    Flexible(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                              'assets/images/receiver.png',
                                              height: 40),
                                          const SizedBox(height: 8),
                                          Text('Contact Us',
                                              style: smallHeading.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14)),
                                          const SizedBox(height: 5),
                                          Text('92967835778',
                                              style: appSmallText.copyWith(
                                                  fontSize: 10,
                                                  overflow:
                                                      TextOverflow.ellipsis))
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 65),
                                    Flexible(
                                      flex: 2,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/serachImg.png',
                                            height: 35,
                                          ),
                                          const SizedBox(height: 8),
                                          Text('Find Us',
                                              style: smallHeading.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14)),
                                          const SizedBox(height: 5),
                                          Text(
                                              'Sec-D 52,Noida sec -16,Country-India',
                                              style: appSmallText.copyWith(
                                                  fontSize: 10,
                                                  overflow:
                                                      TextOverflow.ellipsis))
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: Container(
                    width: Dimensions.containerWidth,
                    height: 120,
                    color: const Color.fromARGB(255, 248, 236, 217),
                    child: const Center(
                      child: Text('copyright @ 2023-2024'),
                    ),
                  ),
                )
              ],
            ));
      } else {
        return const HomeMain(initialIndex: 0);
      }
    });
  }
}

class DetailBottomBar extends StatelessWidget implements PreferredSizeWidget {
  const DetailBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return LayoutBuilder(builder: (context, constraints) {
      if (Get.width >= 850) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
              width: Dimensions.containerWidth,
              height: kToolbarHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 20),
                  Text(
                    '\$317.2 / day',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: notifires.getwhiteblackcolor),
                  ),
                  const SizedBox(width: 100),
                  ElevatedButton(
                    onPressed: () {
                      Get.toNamed(WebRoutes.checkavailabilityScreen);
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(themeColor),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimensions
                              .radiusSmall),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 5),
                        Text(
                          'Continue',
                          style: gilroyMedium.copyWith(color: whiteColor),
                        ),
                        const SizedBox(width: 3),
                        Icon(Icons.arrow_forward, size: 16, color: whiteColor),
                        const SizedBox(width: 5),
                      ],
                    ),
                  )
                ],
              )),
        );
      } else {
        return carbuildBottomAppBar();
      }
    });
  }
  @override
  Size get preferredSize => const Size(200, kToolbarHeight);
}


class DynamicBottomSheetContent extends StatefulWidget {
  final String title;
  final String description;
  final String firstButtontxt;
  final String secondButtontxt;
  final VoidCallback onpressed;
  final VoidCallback onpressed1;

  const DynamicBottomSheetContent(
      {super.key,
      required this.title,
      required this.description,
      required this.firstButtontxt,
      required this.secondButtontxt,
      required this.onpressed,
      required this.onpressed1});

  @override
  State<DynamicBottomSheetContent> createState() =>
      _DynamicBottomSheetContentState();
}

class _DynamicBottomSheetContentState extends State<DynamicBottomSheetContent> {
  bool isCancelSelected = true;
  bool isDeleteSelected = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: notifires.getblackwhitecolor,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(0), topRight: Radius.circular(0))),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
              child: Text(widget.title.tr,
                  style: heading2Grey1(context)
                      .copyWith(color: getColorBasedOnActiveModuleid()))),
          const SizedBox(height: 20),
          Divider(
            height: 1,
            color: notifires.getGrey3Whitecolor,
          ),
          const SizedBox(height: 15),
          Flexible(
              child:
                  Text(widget.description.tr, style: heading3Grey1(context))),
          const SizedBox(height: 30),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: ConstrainedBox(
                      constraints: BoxConstraints.expand(
                          height: 60, width: Get.width * 0.38),
                      child: ElevatedButton(
                        onPressed: widget.onpressed,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: notifires.getBoxColor,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusLarge),
                          ),
                        ),
                        child: Text(widget.firstButtontxt.tr,
                            style: heading3(context)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 25),
                  Flexible(
                    child: ConstrainedBox(
                      constraints: BoxConstraints.expand(
                          height: 60, width: Get.width * 0.38),
                      child: ElevatedButton(
                        onPressed: widget.onpressed1,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: getColorBasedOnActiveModuleid(),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                width: 1.0,
                                color: getColorBasedOnActiveModuleid()),
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusLarge),
                          ),
                        ),
                        child: Text(widget.secondButtontxt.tr,
                            style:
                                heading3(context).copyWith(color: whiteColor)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

void showDynamicBottomSheets(BuildContext context,
    {required String title,
    required String description,
    required String firstButtontxt,
    required String secondButtontxt,
    required final VoidCallback onpressed,
    required final VoidCallback onpressed1}) {
  showModalBottomSheet(
    isScrollControlled: false,
    constraints:
        const BoxConstraints.expand(width: double.infinity, height: 240),
    context: context,
    builder: (context) {
      return DynamicBottomSheetContent(
        title: title,
        description: description,
        firstButtontxt: firstButtontxt,
        secondButtontxt: secondButtontxt,
        onpressed: onpressed,
        onpressed1: onpressed1,
      );
    },
  );
}

class CustomAppBarLogins extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomAppBarLogins({super.key});

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return LayoutBuilder(builder: (context, constraints) {
      if (Get.width >= 850) {
        return Align(
          alignment: Alignment.center,
          child: SizedBox(
              width: Dimensions.containerWidth,
              height: kToolbarHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 15),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Opacity(
                      opacity: 1.0,
                      child: Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 5.0,
                              color: onoffColor.withOpacity(0.7),
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(
                              Dimensions.radiusExtraLarge),
                          color: whiteColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(
                              Dimensions.paddingSizeExtraSmall),
                          child: Center(
                            child: Card(
                              elevation: 0,
                              child: Image.asset(
                                'assets/images/UniLogoIcon.png',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: Dimensions.paddingSizeExtraLarge,
                        top: Dimensions.paddingSizeExtraSmall),
                    child: Container(
                      height: Get.height * 0.05,
                      decoration: BoxDecoration(
                          border: Border.all(color: greyColor2, width: 1.5),
                          borderRadius: BorderRadius.circular(
                              Dimensions.radiusExtraLarge)),
                      child: ElevatedButton(
                          onPressed: () {
                    
                          },
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: notifires.getblackwhitecolor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusExtraLarge),
                              )),
                          child: Text(
                            'Skip'.tr,
                            style: appRegularText.copyWith(
                                color: notifires.getwhiteblackcolor),
                          )),
                    ),
                  )
                ],
              )),
        );
      } else {
        return AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: notifires.getbgcolor,
          centerTitle: false,
          title: Padding(
            padding: const EdgeInsets.only(
                left: Dimensions.paddingSizeExtraSmall,
                top: Dimensions.paddingSizeExtraSmall,
                bottom: 8),
            child: Opacity(
              opacity: 1.0,
              child: Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 5.0,
                      color: onoffColor.withOpacity(0.7),
                      style: BorderStyle.solid),
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusExtraLarge),
                  color: whiteColor,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  child: Center(
                    child: Card(
                      elevation: 0,
                      child: Image.asset(
                        'assets/images/UniLogoIcon.png',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(
                  right: Dimensions.paddingSizeExtraLarge,
                  top: Dimensions.paddingSizeExtraSmall),
              child: Container(
                height: Get.height * 0.05,
                decoration: BoxDecoration(
                    border: Border.all(color: greyColor2, width: 1.5),
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusExtraLarge)),
                child: ElevatedButton(
                    onPressed: () {
                      Get.toNamed(WebRoutes.homeMain);
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: notifires.getblackwhitecolor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              Dimensions.radiusExtraLarge),
                        )),
                    child: Text(
                      'Skip'.tr,
                      style: appRegularText.copyWith(
                          color: notifires.getwhiteblackcolor),
                    )),
              ),
            )
          ],
        );
      }
    });
  }

  @override
  Size get preferredSize => const Size(200, kToolbarHeight);
}



class Demo extends StatelessWidget implements PreferredSizeWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return LayoutBuilder(builder: (context, constraints) {
      if (Get.width >= 850) {
        return Align(
          alignment: Alignment.center,
          child: Container(
              alignment: Alignment.center,
              height: kToolbarHeight,
              color: const Color.fromARGB(255, 248, 236, 217),
              child: SizedBox(
                width: Dimensions.containerWidthAppbar,
                child: Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 5),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                width: 3.0,
                                color: whiteColor,
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(
                                Dimensions.radiusExtraLarge),
                            color: const Color.fromARGB(255, 248, 236, 217),
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/ub-logo.png',
                              height: 50,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                      Flexible(
                        flex: 2,

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('Home',
                                style: gilroySemiBold.copyWith(fontSize: 16)),
                            const SizedBox(width: 25),
                            Text('Category',
                                style: gilroySemiBold.copyWith(fontSize: 16)),
                            const SizedBox(width: 25),
                            Text('Stores',
                                style: gilroySemiBold.copyWith(fontSize: 16)),
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            const Icon(
                              Icons.lock_outline,
                              size: 18,
                            ),
                            const SizedBox(width: 5),
                            Text('Sign In',
                                style: gilroySemiBold.copyWith(fontSize: 16)),
                            const SizedBox(width: 20),
                            const Icon(Icons.person, size: 18),
                            const SizedBox(width: 5),
                            Text('Join Us',
                                style: gilroySemiBold.copyWith(fontSize: 16)),
                            const SizedBox(width: 50),
                            const Icon(Icons.notifications, size: 20),
                            const SizedBox(width: 20),
                            const Icon(
                              Icons.search,
                              size: 20,
                            ),
                            const SizedBox(width: 20),
                            const Icon(Icons.menu, size: 20),
                            const SizedBox(width: 20),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )),
        );
      } else {
        return const SizedBox();
      }
    });
  }

  @override
  Size get preferredSize => const Size(200, kToolbarHeight);
}
