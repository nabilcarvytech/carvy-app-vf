import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/add_items_host_controller.dart';
import 'package:carvy/controller/profile_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import 'package:carvy/view/host/vehiclehost/addvehicle/vehicle_type_screen.dart';
import 'package:carvy/work_space.dart';

class InitialHostCommonScreen extends StatefulWidget {
  const InitialHostCommonScreen({super.key});

  @override
  State<InitialHostCommonScreen> createState() =>
      _InitialHostCommonScreenState();
}

class _InitialHostCommonScreenState extends State<InitialHostCommonScreen> {
  AddItemsHostController addItemsHostController = Get.find();
  ProfileController profileController = Get.find();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      addItemsHostController.getDataOdometerList();
      addItemsHostController.getVehicleDataMakeModel();
      addItemsHostController.getDataTransmission();
      addItemsHostController.cleanTextController();
      addItemsHostController.getDataItemType();
      addItemsHostController.getDataYourLocation();
      addItemsHostController.getDataAmenties();
      addItemsHostController.getRules();
      addItemsHostController.getCancellationPolicy();
      addItemsHostController.getDatafuelType();
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
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      appBar: AppBar(
          surfaceTintColor: notifires.getbgcolor,
          backgroundColor: notifires.getbgcolor,
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: featuresBoxHost()),
          )),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 100,
                width: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Obx(() {
                    final v = profileController.myImage.value;
                    if (v.isEmpty) {
                      return const Icon(
                        Icons.account_circle_rounded,
                        size: 80,
                      );
                    }
                    return buildAvatarImage(v, fit: BoxFit.cover);
                  }),
                ),
              ),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  "Hi".tr + " ${profileController.myName.value}".tr,
                  style: heading1(context),
                ),
              ]),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Text(
                  "Let's get you ready to become \n a host .".tr,
                  textAlign: TextAlign.center,
                  style: heading3Grey1(context),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 55, right: 55),
                child: SizedBox(
                  // width: Get.width / 2.5,
                  child: CustomsButtons(
                      text: "Let's start!".tr,
                      backgroundColor: getColorBasedOnActiveModuleid(),
                      onPressed: () {
                        addItemsHostController.cleanTextController();
                        Get.to(() =>
                            const VehicleTypeScreen(mode: ScreenMode.add));

                        // Get.to(() => EditFirstScreen());
                      }),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
