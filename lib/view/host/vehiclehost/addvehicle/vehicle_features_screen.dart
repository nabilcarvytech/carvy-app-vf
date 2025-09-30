import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/add_items_host_controller.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import 'package:carvy/view/host/vehiclehost/addvehicle/vehicle_rules_screen.dart';
import 'package:carvy/work_space.dart';

class VehicleFeaturesScreen extends StatefulWidget {
  final VoidCallback? onNextButtonPressed;
  final VoidCallback? onBackButtonPressed;
  final ScreenMode mode;

  const VehicleFeaturesScreen(
      {super.key,
      this.onNextButtonPressed,
      required this.mode,
      this.onBackButtonPressed});

  @override
  State<VehicleFeaturesScreen> createState() => _VehicleFeaturesScreenState();
}

class _VehicleFeaturesScreenState extends State<VehicleFeaturesScreen> {
  AddItemsHostController addItemsHostController = Get.find();
  bool selectColor = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: notifires.getbgcolor,
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(150),
            child: widget.mode == ScreenMode.add
                ? AppText(txt: "Do you offer any standout \namenities?".tr)
                : const SizedBox()),
        body: SingleChildScrollView(
            child: Column(
          children: [
            // lineContainer(),
            const SizedBox(height: 15),
            Obx(
              () => addItemsHostController.vehicleListAmenities.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: addItemsHostController.vehicleListAmenities
                            .map((amenity) {
                          addItemsHostController.vehicleListAmenities
                              .indexOf(amenity);
                          bool isSelected = addItemsHostController
                              .selectedAmenitiesList
                              .contains(amenity.id);
                          return GestureDetector(
                            onTap: () {
                              if (isSelected) {
                                addItemsHostController.selectedAmenitiesList
                                    .remove(amenity.id);
                              } else {
                                addItemsHostController.selectedAmenitiesList
                                    .add(amenity.id);
                              }
                              setState(() {});
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: notifires.getboxcolor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: notifires.getGrey3Whitecolor
                                          .withOpacity(0.1),
                                      spreadRadius: 3,
                                      blurRadius: 5,
                                      offset: const Offset(
                                          0, 0), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Transform.scale(
                                            scale: 1.5,
                                            child: Checkbox(
                                              side: BorderSide(
                                                  color:
                                                      getColorBasedOnActiveModuleid(),
                                                  width: 1),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                              ),
                                              activeColor:
                                                  getColorBasedOnActiveModuleid(),
                                              value: isSelected,
                                              onChanged: (newValue) {
                                                if (isSelected) {
                                                  addItemsHostController
                                                      .selectedAmenitiesList
                                                      .remove(amenity.id);
                                                } else {
                                                  addItemsHostController
                                                      .selectedAmenitiesList
                                                      .add(amenity.id);
                                                }
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Text(amenity.name!,
                                                textAlign: TextAlign.start,
                                                style: regular3(context).copyWith(
                                                    color: notifires
                                                        .getGrey2Whitecolor)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
            )
          ],
        )),
        bottomNavigationBar: BottomHosts(
          onTap: () {
            if (widget.mode == ScreenMode.edit) {
              widget.onNextButtonPressed!();
            } else {
              if (addItemsHostController.selectedAmenitiesList.isEmpty) {
                showErrorToastMessage("Please select the amenities".tr);
                return;
              }
              Get.to(() => const VehcileRulesScreen(
                    mode: ScreenMode.add,
                  ));
            }
          },
          txt: truncatetext("Next".tr, 9),
          backButtontxt: "Back".tr,
          backOnPressed: () {
            if (widget.mode == ScreenMode.edit) {
              widget.onBackButtonPressed!();
            } else {
              Get.back();
            }
          },
        ));
  }
}
