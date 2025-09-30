import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/add_items_host_controller.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/host/location_screen_host.dart';
import 'package:carvy/view/host/vehiclehost/addvehicle/vehicle_type_screen.dart';
import 'package:carvy/view/host/vehiclehost/addvehicle/vehicle_price_screen.dart';
import 'package:carvy/view/host/vehiclehost/addvehicle/vehicle_description.dart';
import 'package:carvy/view/host/vehiclehost/addvehicle/vehicle_rules_screen.dart';
import 'package:carvy/view/host/vehiclehost/addvehicle/vehicle_features_screen.dart';

import 'package:carvy/work_space.dart';

class EditVehicleFirstSectionScreen extends StatefulWidget {
  const EditVehicleFirstSectionScreen({super.key});

  @override
  State<EditVehicleFirstSectionScreen> createState() =>
      _EditVehicleFirstSectionScreenState();
}

class _EditVehicleFirstSectionScreenState
    extends State<EditVehicleFirstSectionScreen>
    with SingleTickerProviderStateMixin {
  AddItemsHostController addItemsHostController = Get.find();

  List<Map<String, dynamic>> editboxProperties = [
    {'icon': Icons.home, 'title': 'Vehicle type'.tr},
    {'icon': Icons.star, 'title': 'Vehicle Description'.tr},
    {'icon': Icons.price_change, 'title': 'Price'.tr},
    {'icon': Icons.location_on, 'title': 'Location'.tr},
    {'icon': Icons.star_rate, 'title': 'Vehicle Features'.tr},
    {'icon': Icons.policy, 'title': 'Vehicle Policies'.tr},
  ];
  List<Map<String, dynamic>> heading = [
    {'title': 'What kind of Vehicle are you listings?'.tr},
    {'title': 'Vehicle Description'.tr},
    {'title': 'What will be expected price'.tr},
    {'title': "Where's your place located?".tr},
    {'title': "What features does your vehicle offer?".tr},
    {'title': "Rules and Policies".tr},
  ];

  TabController? _tabcontroller;
  int? index;
  @override
  void initState() {
    super.initState();

    _tabcontroller =
        TabController(length: editboxProperties.length, vsync: this);
    _tabcontroller?.addListener(() {
      setState(() {
        index = _tabcontroller?.index;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshData();
    });
  }

  void refreshData() {
    setState(() {
      addItemsHostController.getDataYourLocation();
      addItemsHostController.getDataAmenties();
      addItemsHostController.getRules();
      addItemsHostController.getCancellationPolicy();
      addItemsHostController.getDataOdometerList();
      addItemsHostController.getDataTransmission();
      addItemsHostController.getDatafuelType();
    });
  }

  void onBackButtonPressed() {
    if (_tabcontroller!.index > 0) {
      _tabcontroller!.animateTo(_tabcontroller!.index - 1);
    } else {}
  }

  void onNextButtonPressed() {
    if (_tabcontroller!.index < _tabcontroller!.length - 1) {
      _tabcontroller!.animateTo(_tabcontroller!.index + 1);
    } else {}
  }

  @override
  void dispose() {
    _tabcontroller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: notifires.getbgcolor,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(185),
          child: AppBar(
            automaticallyImplyLeading: false,
            leading: backButton(),
            leadingWidth: 80,
            title: Text(
              "Edit Vehicle Detail".tr,
              style: heading2Grey1(context),
            ),
            backgroundColor: notifires.getbgcolor,
            surfaceTintColor: notifires.getAppBarcolor,
            flexibleSpace: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: TabBar(
                      overlayColor:
                          const WidgetStatePropertyAll(Colors.transparent),
                      dividerColor: Colors.transparent,
                      indicatorPadding: EdgeInsets.zero,
                      tabAlignment: TabAlignment.start,
                      isScrollable: true,
                      padding: const EdgeInsets.all(0),
                      controller: _tabcontroller,
                      indicator: null,
                      indicatorColor: Colors.transparent,
                      tabs: editboxProperties.asMap().entries.map((entry) {
                        int idx = entry.key;
                        Map<String, dynamic> item = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Container(
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: notifires.getboxcolor,
                                  borderRadius: BorderRadius.circular(30)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Container(
                                      height: 45,
                                      width: 45,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: _tabcontroller?.index == idx
                                              ? getColorBasedOnActiveModuleid()
                                                  .withOpacity(0.3)
                                              : grey5,
                                          borderRadius:
                                              BorderRadius.circular(25)),
                                      child: Icon(item['icon'],
                                          color: _tabcontroller?.index == idx
                                              ? getColorBasedOnActiveModuleid()
                                              : getColorBasedOnActiveModuleid()),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    item['title'],
                                    style: regular3(context).copyWith(
                                        fontSize: 14,
                                        color: notifires.getGrey2Whitecolor),
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10, top: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: heading.asMap().entries.map((entry) {
                        int idx = entry.key;
                        Map<String, dynamic> item = entry.value;
                        return _tabcontroller?.index == idx
                            ? Flexible(
                                child: Text(
                                  item['title'],
                                  style: heading2(context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  // textAlign: TextAlign.left,
                                  softWrap: true,
                                ),
                              )
                            : const Text("");
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // lineContainer()
                  // Flexible(
                  //   child: Container(
                  //     width: Get.width,
                  //     height: 15,
                  //     decoration: BoxDecoration(
                  //         border: Border(
                  //           top: BorderSide(
                  //             color: notifires.getwhiteblackcolor,
                  //             width: 2.0,
                  //           ),
                  //         ),
                  //         borderRadius: BorderRadius.only(
                  //             topLeft: Radius.circular(20),
                  //             topRight: Radius.circular(20))),
                  //   ),
                  // ),
                ],
              ),
            ),
          )),
      body: TabBarView(
        controller: _tabcontroller,
        children: [
          VehicleTypeScreen(
            onNextButtonPressed: onNextButtonPressed,
            mode: ScreenMode.edit,
          ),
          VehcileDescriptionScreen(
            mode: ScreenMode.edit,
            onNextButtonPressed: onNextButtonPressed,
            onBackButtonPressed: onBackButtonPressed,
          ),
          VehiclePriceScreen(
              mode: ScreenMode.edit,
              onNextButtonPressed: onNextButtonPressed,
              onBackButtonPressed: onBackButtonPressed),
          LocationScreenHost(
            onNextButtonPressed: onNextButtonPressed,
            mode: ScreenMode.edit,
            onBackButtonPressed: onBackButtonPressed,
          ),
          VehicleFeaturesScreen(
            onNextButtonPressed: onNextButtonPressed,
            mode: ScreenMode.edit,
            onBackButtonPressed: onBackButtonPressed,
          ),
          VehcileRulesScreen(
            onNextButtonPressed: onNextButtonPressed,
            mode: ScreenMode.edit,
            onBackButtonPressed: onBackButtonPressed,
          )
        ],
      ),
    );
  }
}
