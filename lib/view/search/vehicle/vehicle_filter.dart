import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/search_controller.dart';
import 'package:carvy/customwidget/custom_check_box.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/utils/vehicle_common_widgets.dart';
import 'package:carvy/work_space.dart';

class VehicleFilter extends StatefulWidget {
  final bool? mode;
  final bool? forsearch;
  final bool? forHome;
  final VoidCallback? onRefresh;
  final VoidCallback? onMapRefresh;
  const VehicleFilter(
      {super.key,
      this.mode,
      this.onRefresh,
      this.forsearch,
      this.onMapRefresh,
      this.forHome});
  @override
  State<VehicleFilter> createState() => _VehicleFilterState();
}

class _VehicleFilterState extends State<VehicleFilter> {
  SearchControllerHome filterController = Get.find();
  RangeValues currentRangeValues = const RangeValues(40, 1000);
  double? parseDoubleValue(String? stringValue) {
    if (stringValue != null && stringValue.isNotEmpty) {
      try {
        return double.parse(stringValue);
      } catch (e) {}
    }
    return null;
  }

  double height = 13;
  List<dynamic> years = [];
  List<dynamic> generateYearsList() {
    dynamic currentYear = DateTime.now().year;
    for (int i = currentYear; i >= currentYear - 25; i--) {
      years.add(i);
    }
    return years;
  }

// Copy
  void validateRangeValues() {
    double minPrice = double.parse("${minPricerange!}");
    double maxPrice = double.parse("$maxPriceRange");

    double startValue = filterController.startRange.value;
    double endValue = filterController.endRage.value;

    startValue = startValue < minPrice ? minPrice : startValue;
    startValue = startValue > maxPrice ? maxPrice : startValue;

    endValue = endValue < minPrice ? minPrice : endValue;
    endValue = endValue > maxPrice ? maxPrice : endValue;

    currentRangeValues = RangeValues(startValue, endValue);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      generateYearsList();

      currentRangeValues = RangeValues(
        double.parse("$minPricerange"),
        double.parse("$maxPriceRange"),
      );
      String startRangeString = currentRangeValues.start.toStringAsFixed(0);
      String endRangeString = currentRangeValues.end.toStringAsFixed(0);
      filterController.startRange.value = double.parse(startRangeString);
      filterController.endRage.value = double.parse(endRangeString);

      filterController.filterApiBasedOnModule();
      filterController.dataChangedBasedOnModuleid();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: Dimensions.containerWidth,
        child: Scaffold(
          backgroundColor: notifires.getbgcolor,
          appBar: AppBar(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            backgroundColor: notifires.getBoxColor,
            scrolledUnderElevation: 0,
            title: Text(
              "Filter".tr,
              style: heading2Grey1(context),
            ),
            automaticallyImplyLeading: false,
            actions: [
              Container(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: InkWell(
                      onTap: () {
                        filterController.clearFilter();
                        setState(() {});
                      },
                      child: Text(
                        "Clear".tr,
                        style: regular2(context)
                            .copyWith(color: getColorBasedOnActiveModuleid()),
                      )),
                ),
              )
            ],
          ),
          body: GetBuilder<SearchControllerHome>(
            // Use GetBuilder
            builder: (controller) {
              return filterUi(context, controller);
            },
          ),
          bottomNavigationBar: Obx(
            () => filterController.isLoadingVehicle.value
                ? const SizedBox()
                : Container(
                    padding: const EdgeInsets.only(
                        left: 25, right: 25, bottom: 10, top: 10),
                    height: 70,
                    child: CustomsButtons(
                      onPressed: () {
                        if (widget.mode == true) {
                          filterController.submitMethod(context);
                          return;
                        }
                        if (widget.forHome == true) {
                          Navigator.pop(context);
                          return;
                        }
                        if (widget.forsearch == true) {
                          widget.onMapRefresh!();
                          Navigator.pop(context);
                          return;
                        }
                        widget.onRefresh!();
                        Navigator.pop(context);
                      },
                      text: widget.mode == true ? 'Filters'.tr : "Apply".tr,
                      backgroundColor: getColorBasedOnActiveModuleid(),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget filterUi(context, controller) {
    return controller.isLoadingVehicle.value
        ? filterScreenShimmer()
        : Row(
            children: [
              Expanded(
                  child: Container(
                      height: double.maxFinite,
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 15,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Price range".tr,
                                      style: heading2Grey1(context),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    Obx(
                                      () => generalController
                                                  .hasGeneralData.value ==
                                              true
                                          ? const SizedBox()
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                    "($currency)- ${filterController.startRange.value.toInt().toString()}  ",
                                                    style: heading3(context)),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  "($currency)- ${filterController.endRage.value.toInt().toString()}  ",
                                                  style: smallHeading.copyWith(
                                                      color: notifires
                                                          .getwhiteblackcolor),
                                                ),
                                              ],
                                            ),
                                    ),
                                    Obx(() => generalController
                                                .hasGeneralData.value ==
                                            true
                                        ? const Center(
                                            child: CircularProgressIndicator())
                                        : Transform.scale(
                                            scale: 1.07,
                                            child: RangeSlider(
                                              values: currentRangeValues,
                                              activeColor:
                                                  getColorBasedOnActiveModuleid(),
                                              inactiveColor: Colors.grey,
                                              max: parseDoubleValue(
                                                      maxPriceRange) ??
                                                  1000,
                                              min: parseDoubleValue(
                                                      minPricerange) ??
                                                  10.0,
                                              divisions: int.parse(
                                                  "${maxPriceRange!}"),
                                              labels: RangeLabels(
                                                filterController
                                                    .startRange.value
                                                    .toInt()
                                                    .toString(),
                                                filterController.endRage.value
                                                    .toInt()
                                                    .toString(),
                                              ),
                                              onChanged: (RangeValues values) {
                                                setState(() {
                                                  currentRangeValues = values;
                                                  filterController
                                                          .startRange.value =
                                                      currentRangeValues.start;
                                                  filterController
                                                          .endRage.value =
                                                      currentRangeValues.end;
                                                });
                                              },
                                            ),
                                          )),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                buildDividervehicle(),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  "Make Type".tr,
                                  style: heading2Grey1(context),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InitialValueCheckBox(
                                        ismaketypr: true,
                                        initialValue: filterController
                                                .makeTypeModel?.data?.makes
                                                ?.map((itemType) => itemType.id)
                                                .toList() ??
                                            [],
                                        options: filterController
                                                .makeTypeModel?.data?.makes
                                                ?.map((itemType) =>
                                                    itemType.makeName)
                                                .toList() ??
                                            [],
                                        searchHintText: "Search Make type..",
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                buildDividervehicle(),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  "Features".tr,
                                  style: heading2Grey1(context),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyCustomCheckBox(
                                        initialValue: filterController
                                                .amenitiesModelVehicle
                                                ?.data
                                                ?.amenities
                                                ?.map((itemType) => itemType.id)
                                                .toList() ??
                                            [],
                                        options: filterController
                                                .amenitiesModelVehicle
                                                ?.data
                                                ?.amenities
                                                ?.map(
                                                    (itemType) => itemType.name)
                                                .toList() ??
                                            [],
                                        searchHintText: "Search features..",
                                        isOdometer: false,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                buildDividervehicle(),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  "Odometers".tr,
                                  style: heading2Grey1(context),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyCustomCheckBox(
                                        initialValue: filterController
                                                .odometerModelVehicle
                                                ?.data
                                                ?.odometerList
                                                ?.map((itemType) => itemType.id)
                                                .toList() ??
                                            [],
                                        options: filterController
                                                .odometerModelVehicle
                                                ?.data
                                                ?.odometerList
                                                ?.map(
                                                    (itemType) => itemType.name)
                                                .toList() ??
                                            [],
                                        searchHintText: "Search features..",
                                        isOdometer: true,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                buildDividervehicle(),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  "Model year".tr,
                                  style: heading2Grey1(context),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyCustomCheckBoxModelYear(
                                        initialValue: years,
                                        options: years,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                              ]),
                        ),
                      )))
            ],
          );
  }
}
