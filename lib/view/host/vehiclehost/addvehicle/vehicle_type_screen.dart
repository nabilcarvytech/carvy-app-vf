import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/add_items_host_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/model/get_year_model.dart';
import 'package:carvy/model/make_model_vehicle.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import 'package:carvy/work_space.dart';

class VehicleTypeScreen extends StatefulWidget {
  final VoidCallback? onNextButtonPressed;
  final ScreenMode mode;
  const VehicleTypeScreen(
      {super.key, this.onNextButtonPressed, required this.mode});
  @override
  State<VehicleTypeScreen> createState() => _VehicleTypeScreenState();
}

class _VehicleTypeScreenState extends State<VehicleTypeScreen> {
  // or any default value from the list
  GetYearModel? yearListModel;
  void resetDependentFields() {
    setState(() {
      addItemsHostController.selectedMake = null;
      addItemsHostController.selectedModel = null;
    });
  }

  final _formKey = GlobalKey<FormState>();
  AddItemsHostController addItemsHostController = Get.find();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      generateYearsList();
      if (widget.mode == ScreenMode.edit) {
        addItemsHostController.isMakeModelonTap.value = false;
      }
    });
    setState(() {});
  }

  void filterModelTypes(String? selectedMake) {
    if (selectedMake != null) {
      MakeTypes? selectedMakeType = addItemsHostController.listMakesType
          .firstWhereOrNull(
              (makeType) => makeType.id.toString() == selectedMake);

      if (selectedMakeType != null) {
        setState(() {
          addItemsHostController.listModelType = selectedMakeType.models ?? [];
        });
      }
    }
  }

  List<int> years = [];

  List<int> generateYearsList() {
    int currentYear = DateTime.now().year;
    for (int i = currentYear; i >= currentYear - 20; i--) {
      years.add(i);
    }
    return years;
  }

  bool isMakeSelected = false;
  bool cleardata = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: notifires.getbgcolor,
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(150),
            child: widget.mode == ScreenMode.add
                ? AppText(txt: "What kind of Vehicle are you \nlistings".tr)
                : const SizedBox()),
        body: Center(
          child: SingleChildScrollView(
            child: Obx(
              () => addItemsHostController.isMakeModel.value == true
                  ? const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(child: CircularProgressIndicator()),
                      ],
                    )
                  : Column(
                      children: [
                        // lineContainer(),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LabelNames(labelname: "Vehicle Type".tr),
                              const SizedBox(height: 10),
                              CustomDropdownHost(
                                mode: widget.mode,
                                heading: "Choose Vehicle Type".tr,
                                options:
                                    addItemsHostController.vehicleListItemType,
                                onSelected: (value) {
                                  addItemsHostController.selectedVehicleType =
                                      value;
                                  resetDependentFields();
                                  addItemsHostController
                                      .getVehicleDataMakeModelforOnTap(value);
                                },
                                checkmarkColor: getColorBasedOnActiveModuleid(),
                                selectedEditInitialValue:
                                    addItemsHostController.selectedVehicleType,
                              ),
                              // ),
                              const SizedBox(height: 10),
                              LabelNames(labelname: "Make".tr),
                              const SizedBox(
                                height: 10,
                              ),

                              CustomDropdownHost(
                                clearDataonVehgicletype: addItemsHostController
                                    .isMakeModelonTap.value,
                                mode: widget.mode,
                                heading: "Choose Make Type".tr,
                                options: addItemsHostController.listMakesType,
                                onSelected: (value) {
                                  addItemsHostController.selectedMake = value;
                                  isMakeSelected = true;
                                  filterModelTypes(
                                      addItemsHostController.selectedMake);
                                },
                                checkmarkColor: getColorBasedOnActiveModuleid(),
                                selectedEditInitialValue:
                                    addItemsHostController.selectedMake,
                              ),

                              const SizedBox(height: 10),
                              LabelNames(labelname: "Model".tr),
                              const SizedBox(height: 10),

                              CustomDropdownHost(
                                clearDataonVehgicletype: addItemsHostController
                                    .isMakeModelonTap.value,
                                mode: widget.mode,
                                heading: "Choose Model Type".tr,
                                options: isMakeSelected ||
                                        (addItemsHostController
                                                .selectedMake?.isNotEmpty ??
                                            false)
                                    ? addItemsHostController
                                        .listModelType // Ensure listModelType is not null
                                    : [],
                                onSelected: (value) {
                                  addItemsHostController.selectedModel = value;
                                },
                                checkmarkColor: getColorBasedOnActiveModuleid(),
                                selectedEditInitialValue:
                                    addItemsHostController.selectedModel,
                              ),

                              const SizedBox(height: 10),
                              LabelNames(labelname: "Year".tr),
                              const SizedBox(height: 10),
                              CustomDropdownHostYears(
                                mode: widget.mode,
                                heading: "Choose Year".tr,
                                years: generateYearsList(),
                                onSelected: (year) {
                                  addItemsHostController.selectedVechicleYear =
                                      year;
                                },
                                checkmarkColor: getColorBasedOnActiveModuleid(),
                                hintText: 'Select Year'.tr,
                              ),
                              const SizedBox(height: 10),
                              LabelNames(labelname: "Transmissions".tr),
                              const SizedBox(height: 10),
                              CustomDropdownHost2(
                                mode: widget.mode,
                                heading: "Choose transmission".tr,
                                options:
                                    addItemsHostController.listTransmission,
                                onSelected: (value) {
                                  addItemsHostController.selectTransmission =
                                      value;
                                },
                                checkmarkColor: getColorBasedOnActiveModuleid(),
                              ),
                              const SizedBox(height: 10),
                              LabelNames(labelname: "Odometer".tr),
                              const SizedBox(height: 10),
                              CustomDropdownHost(
                                mode: widget.mode,
                                heading: "Choose odometer".tr,
                                options:
                                    addItemsHostController.listSpeedOdometer,
                                onSelected: (value) {
                                  addItemsHostController
                                      .selectedOdometerId.value = value;
                                },
                                selectedEditInitialValue: addItemsHostController
                                    .selectedOdometerId.value,
                                checkmarkColor: getColorBasedOnActiveModuleid(),
                              ),
                              const SizedBox(height: 10),

                              LabelNames(labelname: 'Fuel Type'.tr),
                              const SizedBox(height: 10),
                              CustomDropdownHost(
                                mode: widget.mode,
                                heading: "Select Fuel Type".tr,
                                options: addItemsHostController.fuelTypeList,
                                onSelected: (value) {
                                  addItemsHostController
                                      .selectedFueltypeid.value = value;
                                },
                                selectedEditInitialValue: addItemsHostController
                                    .selectedFueltypeid.value,
                                checkmarkColor: getColorBasedOnActiveModuleid(),
                              ),

                              const SizedBox(height: 10),
                              LabelNames(labelname: 'Number of Seats'.tr),
                              const SizedBox(height: 10),
                              TextFieldRefs(
                                onTap: () {
                                  addItemsHostController.numerictype = true;
                                },
                                onChange: (c) {
                                  addItemsHostController.cleanNumericInput(
                                      addItemsHostController.seatcapicity, c!);
                                  return null;
                                },
                                textInputAction: TextInputAction.done,
                                txt: 'Number of Seats'.tr,
                                textEditingControllerCommon:
                                    addItemsHostController.seatcapicity,
                                inputType: TextInputType.name,
                                inputAlignment: TextAlign.left,
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        bottomSheet: MediaQuery.of(context).viewInsets.bottom == 0
            ? null
            : addItemsHostController.numerictype && Platform.isIOS
                ? Row(
                    children: [
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          setState(() {
                            addItemsHostController.numerictype = false;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: getColorBasedOnActiveModuleid(),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              " DONE ".tr,
                              style: TextStyle(color: whiteColor),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
        bottomNavigationBar: BottomHosts(
          onTap: () {
            addItemsHostController.validateType(
              context: context,
              formKey: _formKey,
              mode: widget.mode,
              onNextButtonPressed: widget.onNextButtonPressed,
            );
          },
          txt: truncatetext("Next".tr, 9),
          backButtontxt: "Back".tr,
          backOnPressed: (() {
            Get.back();
          }),
        ));
  }
}
