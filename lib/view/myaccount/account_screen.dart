import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:carvy/controller/profile_controller.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/booking/vehicle_photoes_booking.dart';
import 'package:carvy/view/host/wallet/finance_screen.dart';
import 'package:carvy/view/host/orders/orders_screen.dart';
import 'package:carvy/view/host/wallet/payment_method_screen.dart';
import 'package:carvy/view/kyc/user_kyc.dart';
import 'package:carvy/view/myaccount/addaddress/pick_address_with_map.dart';
import 'package:carvy/view/myaccount/my_profile_screen.dart';
import 'package:carvy/view/myaccount/static_page_screen.dart';
import 'package:carvy/work_space.dart';
import '../booking/my_booking_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});
  @override
  State<AccountScreen> createState() => _AccounScreenState();
}

class _AccounScreenState extends State<AccountScreen> {
  ProfileController profileController = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (loginModel != null) {
        if (loginModel!.data != null) {
          if (loginModel!.data!.profileImage != null &&
              loginModel!.data!.profileImage!.containsKey('url')) {
            profileController.myImage.value =
                loginModel!.data!.profileImage!['url'];
          }
          if (loginModel!.data!.firstName != null) {
            profileController.myName.value = loginModel!.data!.firstName!;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return PopScope(
      canPop: false,
      onPopInvoked: (v) {
        if (isHostMode.value == true) {
          generalController.tabControllerHost.index = 0;
          generalController.currentIndexHost.value = 0;
        } else {
          generalController.currentIndex.value = 0;
          generalController.tabController.index = 0;
        }
      },
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: Dimensions.containerWidth,
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              toolbarHeight: 0,
              backgroundColor: notifires.getbgcolor,
            ),
            backgroundColor: notifires.getbgcolor,
            body: showerrorWhenloginwithOtherDevice.toString() ==
                        "The selected token is invalid." ||
                    showerrorWhenloginwithOtherDevice.toString() ==
                        "token not match"
                ? Center(
                    child: showTokenExpirePlease(),
                  )
                : token.isEmpty
                    ? Center(child: notloginwidget())
                    : SafeArea(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    if (webPlateForm) {
                                      Get.toNamed(
                                        WebRoutes.myprofile,
                                      );
                                    } else {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const MyProfile()));
                                    }
                                  },
                                  child: Column(children: [
                                    Stack(
                                      children: [
                                        Obx(
                                          () => SizedBox(
                                            height: 138,
                                            width: 138,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(76),
                                              child: profileController
                                                          .myImage.value
                                                          .toString() ==
                                                      ""
                                                  ? SizedBox(
                                                      height: 138,
                                                      width: 128,
                                                      child: CircleAvatar(
                                                        radius: 76,
                                                        child: Icon(
                                                          Icons.person,
                                                          size: 65,
                                                          color: blackColor,
                                                        ),
                                                      ),
                                                    )
                                                  : CachedNetworkImage(
                                                      fit: BoxFit.cover,
                                                      imageUrl:
                                                          profileController
                                                              .myImage.value,
                                                      errorWidget: (context,
                                                          exception,
                                                          stackTrace) {
                                                        return const Icon(
                                                          Icons
                                                              .account_circle_rounded,
                                                          size: 120,
                                                        );
                                                      },
                                                    ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                            right: 0,
                                            bottom: 20,
                                            child: SvgPicture.asset(
                                                "assets/images/editlogo.svg"))
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Obx(
                                          () => Text(
                                            profileController.myName.value,
                                            style: heading2Grey1(context),
                                          ),
                                        ),
                                        Text(
                                          loginModel?.data?.country != null
                                              ? "${"Live in".tr} ${loginModel?.data?.country ?? ""}"
                                              : "",
                                          style: regular(context).copyWith(),
                                        )
                                      ],
                                    ),
                                  ]),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                switchToOwner(context),
                                const SizedBox(
                                  height: 5,
                                ),
                                HeaderTextWidget(
                                  headingText: "Bookings".tr,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                isHostMode.value == true
                                    ? const SizedBox()
                                    : ForwardActionTile(
                                        onTap: () {
                                          addAddressController
                                              .preventDate.value = false;
                                          Get.to(PickAddressWitjhMap());
                                        },
                                        bookingText: "Address".tr,
                                        textStyle: headingh5,
                                        leadingIcon: Icons
                                            .location_city, // Your custom icon
                                        iconColor:
                                            getColorBasedOnActiveModuleid(), // Your custom color
                                      ),
                                const SizedBox(
                                  height: 10,
                                ),
                                ForwardActionTile(
                                  onTap: () {
                                    if (isHostMode.value == true) {
                                      if (webPlateForm) {
                                        Get.toNamed(WebRoutes.orderScreen,
                                            arguments: {
                                              "fromPropBooking": true
                                            });
                                      } else {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (builder) =>
                                                    const OrdersScreen(
                                                      fromPropBooking: true,
                                                    )));
                                      }
                                    } else {
                                      if (webPlateForm) {
                                        Get.toNamed(WebRoutes.myBooking,
                                            arguments: {
                                              "fromPropBooking": true
                                            });
                                      } else {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (builder) => MyBooking(
                                                      fromPropBooking: true,
                                                    )));
                                      }
                                    }
                                  },
                                  bookingText: isHostMode.value == true
                                      ? "Orders".tr
                                      : "My Booking".tr,
                                  textStyle: headingh5,
                                  leadingIcon: Icons.event, // Your custom icon
                                  iconColor:
                                      getColorBasedOnActiveModuleid(), // Your custom color
                                ),
                                HeaderTextWidget(
                                  headingText: "Account Settings".tr,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                ForwardActionTile(
                                  onTap: () {
                                    Get.toNamed(WebRoutes.settingScreen);
                                  },
                                  bookingText: "Settings".tr,
                                  textStyle: headingh5,
                                  leadingIcon:
                                      Icons.settings, // Your custom icon
                                  iconColor:
                                      getColorBasedOnActiveModuleid(), // Your custom color
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                isHostMode.value == true
                                    ? SizedBox()
                                    : kycenable != "Active"
                                        ? SizedBox()
                                        : ForwardActionTile(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (builder) =>
                                                          const UserKyc()));
                                            },
                                            bookingText: "KYC".tr,
                                            textStyle: headingh5,
                                            leadingIcon: Icons
                                                .settings, // Your custom icon
                                            iconColor:
                                                getColorBasedOnActiveModuleid(), // Your custom color
                                          ),
                                isHostMode.value == true
                                    ? SizedBox()
                                    : kycenable != "Active"
                                        ? SizedBox()
                                        : const SizedBox(
                                            height: 10,
                                          ),
                                ForwardActionTile(
                                  onTap: () {
                                    if (isHostMode.value == true) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (builder) =>
                                                  const FinanceMainScreen(
                                                    isFormHome: false,
                                                  )));
                                    } else {
                                      Get.toNamed(WebRoutes.walletScreen);
                                    }
                                  },
                                  bookingText: isHostMode.value == true
                                      ? 'Financial Report'.tr
                                      : "Wallet".tr,
                                  textStyle: headingh5,
                                  leadingIcon: Icons.wallet, // Your custom icon
                                  iconColor:
                                      getColorBasedOnActiveModuleid(), // Your custom color
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                isHostMode.value == true
                                    ? ForwardActionTile(
                                        onTap: () {
                                          if (webPlateForm) {
                                            Get.toNamed(
                                              WebRoutes.addbanckAccount,
                                            );
                                          } else {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (builder) =>
                                                        const PaymentMethod()));
                                          }
                                        },
                                        bookingText: "Payment Method".tr,
                                        textStyle: headingh5,
                                        leadingIcon: Icons
                                            .account_balance, // Your custom icon
                                        iconColor:
                                            getColorBasedOnActiveModuleid(), // Your custom color
                                      )
                                    : const SizedBox(),
                                isHostMode.value == true
                                    ? const SizedBox(
                                        height: 10,
                                      )
                                    : const SizedBox(),
                                ForwardActionTile(
                                  onTap: () {
                                    Get.dialog(
                                        const DeleteConfirmationDialogs());
                                  },
                                  bookingText: "Delete Your Account".tr,
                                  textStyle: headingh5,
                                  leadingIcon: Icons.account_box,
                                  iconColor: getColorBasedOnActiveModuleid(),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                ForwardActionTile(
                                  onTap: () {
                                    Get.toNamed(WebRoutes.aboutUsScreen);
                                  },
                                  bookingText: "About".tr,
                                  textStyle: headingh5,
                                  leadingIcon: Icons.info,
                                  iconColor: getColorBasedOnActiveModuleid(),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                HeaderTextWidget(
                                  headingText: "Support".tr,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                isHostMode.value == true
                                    ? ForwardActionTile(
                                        onTap: () {
                                          if (webPlateForm) {
                                            Get.toNamed(
                                              WebRoutes.staticPages,
                                            );
                                          } else {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (builder) =>
                                                        StaticPage(
                                                            data:
                                                                "Terms of Service for Vehicle Owner"
                                                                    .tr)));
                                          }
                                        },
                                        bookingText:
                                            "Terms of Service for Vehicle Owner"
                                                .tr,
                                        textStyle: headingh5,
                                        leadingIcon: Icons.fingerprint,
                                        iconColor:
                                            getColorBasedOnActiveModuleid(),
                                      )
                                    : ForwardActionTile(
                                        onTap: () {
                                          Get.toNamed(
                                              WebRoutes.privacyPolicyScreen);
                                        },
                                        bookingText:
                                            "Terms of Service & Privacy Policy"
                                                .tr,
                                        textStyle: headingh5,
                                        leadingIcon: Icons
                                            .fingerprint, // Your custom icon
                                        iconColor:
                                            getColorBasedOnActiveModuleid(),
                                      ),
                                const SizedBox(
                                  height: 10,
                                ),
                                ForwardActionTile(
                                  onTap: () {
                                    Get.toNamed(WebRoutes.getHelpScreen);
                                  },
                                  bookingText: "Get Help".tr,
                                  textStyle: headingh5,
                                  leadingIcon: Icons.help, // Your custom icon
                                  iconColor: getColorBasedOnActiveModuleid(),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                ForwardActionTile(
                                  onTap: () {
                                    Get.toNamed(WebRoutes.giveUsFeedback);
                                  },
                                  bookingText: "Give us feedback".tr,
                                  textStyle: headingh5,
                                  leadingIcon: Icons.feedback,
                                  iconColor: getColorBasedOnActiveModuleid(),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                ForwardActionTile(
                                  onTap: () {
                                    showDynamicBottomSheets(context,
                                        title: "Logout".tr,
                                        description:
                                            "Are you sure You Want to Logout? "
                                                .tr,
                                        firstButtontxt: "Cancel".tr,
                                        secondButtontxt: "Yes".tr,
                                        onpressed: () {
                                      Get.back();
                                    }, onpressed1: () async {
                                      logout();
                                    });
                                  },
                                  bookingText: "Logout".tr,
                                  textStyle: headingh5,
                                  leadingIcon: Icons.logout, // Your custom icon
                                  iconColor:
                                      getColorBasedOnActiveModuleid(), // Your custom color
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      "Version 1.4".tr,
                                      style: regular(context).copyWith(),
                                    ),
                                    const SizedBox(
                                      height: 40,
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}
