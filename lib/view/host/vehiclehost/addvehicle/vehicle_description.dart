// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:carvy/controller/add_items_host_controller.dart';
// import 'package:carvy/customwidget/form_elements.dart';
// import 'package:carvy/customwidget/project_color.dart';
// import 'package:carvy/utils/common_widget.dart';
// import 'package:carvy/view/host/common_widget_host.dart';
// import 'package:carvy/view/host/vehiclehost/addvehicle/vehicle_price_screen.dart';

// import 'package:carvy/work_space.dart';

// class VehcileDescriptionScreen extends StatefulWidget {
//   final VoidCallback? onNextButtonPressed;
//   final ScreenMode? mode;
//   final VoidCallback? onBackButtonPressed;

//   const VehcileDescriptionScreen(
//       {super.key,
//       this.onNextButtonPressed,
//       this.mode,
//       this.onBackButtonPressed});
//   @override
//   State<VehcileDescriptionScreen> createState() =>
//       _VehcileDescriptionScreenState();
// }

// class _VehcileDescriptionScreenState extends State<VehcileDescriptionScreen> {
//   AddItemsHostController addItemsHostController = Get.find();

//   final _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: notifires.getbgcolor,
//         appBar: PreferredSize(
//             preferredSize: const Size.fromHeight(125),
//             child: widget.mode == ScreenMode.add
//                 ? AppText(txt: "Add Vehicle Detail".tr)
//                 : const SizedBox()),
//         body: SingleChildScrollView(
//           child:
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             const SizedBox(height: 15),
//             // lineContainer(),
//             Padding(
//               padding: const EdgeInsets.only(left: 20, right: 20),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     LabelNames(labelname: 'Vehicle Name'.tr),
//                     const SizedBox(height: 10),
//                     TextFieldRefs(
//                       textInputAction: TextInputAction.done,
//                       maxlength: 100,
//                       txt: 'Enter Title'.tr,
//                       textEditingControllerCommon: widget.mode ==
//                               ScreenMode.edit
//                           ? addItemsHostController
//                               .textEditingControllerEditTitle
//                           : addItemsHostController.textEditingControllerTitle,
//                       inputType: TextInputType.name,
//                       inputAlignment: TextAlign.left,
//                     ),
//                     LabelNames(labelname: 'Vehicle Description'.tr),
//                     const SizedBox(height: 10),
//                     TextFieldRefs(
//                         textInputAction: TextInputAction.done,
//                         txt: 'Enter Description'.tr,
//                         textEditingControllerCommon: widget.mode ==
//                                 ScreenMode.edit
//                             ? addItemsHostController
//                                 .textEditingControllerEditDesc
//                             : addItemsHostController.textEditingControllerDesc,
//                         inputType: TextInputType.multiline,
//                         minlines: 12,
//                         maxlength: 500,
//                         maxlines: null,
//                         inputAlignment: TextAlign.left),
//                     const SizedBox(height: 80),
//                   ],
//                 ),
//               ),
//             ),
//           ]),
//         ),
//         bottomNavigationBar: BottomHosts(
//           onTap: () {
//             addItemsHostController.validateAndNavigate(
//               context: context,
//               formKey: _formKey,
//               mode: widget.mode,
//               onNextButtonPressed: widget.onNextButtonPressed,
//               titleController: widget.mode == ScreenMode.edit
//                   ? addItemsHostController.textEditingControllerEditTitle
//                   : addItemsHostController.textEditingControllerTitle,
//               descriptionController: widget.mode == ScreenMode.edit
//                   ? addItemsHostController.textEditingControllerEditDesc
//                   : addItemsHostController.textEditingControllerDesc,
//               navigateToScreen: const VehiclePriceScreen(mode: ScreenMode.add),
//             );
//           },
//           txt: truncatetext("Next".tr, 9),
//           backButtontxt: "Back".tr,
//           // backOnPressed: (() {
//           //   Get.back();
//           // }),
//           backOnPressed: () {
//             if (widget.mode == ScreenMode.edit) {
//               widget.onBackButtonPressed!();
//             } else {
//               Get.back();
//             }
//           },
//         ));
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/add_items_host_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import 'package:carvy/view/host/vehiclehost/addvehicle/vehicle_price_screen.dart';
import 'package:carvy/work_space.dart';

class VehcileDescriptionScreen extends StatefulWidget {
  final VoidCallback? onNextButtonPressed;
  final ScreenMode? mode;
  final VoidCallback? onBackButtonPressed;
  const VehcileDescriptionScreen({
    super.key,
    this.onNextButtonPressed,
    this.mode,
    this.onBackButtonPressed,
  });
  @override
  State<VehcileDescriptionScreen> createState() =>
      _VehcileDescriptionScreenState();
}

class _VehcileDescriptionScreenState extends State<VehcileDescriptionScreen> {
  AddItemsHostController addItemsHostController = Get.find();
  final _formKey = GlobalKey<FormState>();
  String? _insuranceCoverage;

  @override
  void initState() {
    super.initState();
    if (widget.mode == ScreenMode.edit) {
      _initializeEditValues();
    } else {
      addItemsHostController.isSmokingAllowed = false;
      addItemsHostController.isInternationalTravelAllowed = false;
    }
  }

  void _initializeEditValues() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ScreenMode.edit == widget.mode) {
        addItemsHostController.isAgeRestricted = true;
      }
      setState(() {
        _insuranceCoverage = addItemsHostController.insuranceCoverage;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(125),
        child: widget.mode == ScreenMode.add
            ? AppText(txt: "Add Vehicle Detail".tr)
            : const SizedBox(),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabelNames(labelname: 'Vehicle Name'.tr),
                    const SizedBox(height: 10),
                    TextFieldRefs(
                      textInputAction: TextInputAction.done,
                      maxlength: 100,
                      txt: 'Enter Title'.tr,
                      textEditingControllerCommon: widget.mode ==
                              ScreenMode.edit
                          ? addItemsHostController
                              .textEditingControllerEditTitle
                          : addItemsHostController.textEditingControllerTitle,
                      inputType: TextInputType.name,
                      inputAlignment: TextAlign.left,
                    ),
                    const SizedBox(height: 15),
                    LabelNames(labelname: 'License Plate Number'.tr),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        plateBox(
                            controller: widget.mode == ScreenMode.edit
                                ? addItemsHostController.part1ControllerEdit
                                : addItemsHostController.part1Controller),
                        plateBox(
                            controller: widget.mode == ScreenMode.edit
                                ? addItemsHostController.part2ControllerEdit
                                : addItemsHostController.part2Controller),
                        plateBox(
                            controller: widget.mode == ScreenMode.edit
                                ? addItemsHostController.part3ControllerEdit
                                : addItemsHostController.part3Controller),
                      ],
                    ),
                    // TextFieldRefs(
                    //   textInputAction: TextInputAction.done,
                    //   maxlength: 20,
                    //   txt: 'Enter License Plate'.tr,
                    //   textEditingControllerCommon:
                    //       widget.mode == ScreenMode.edit
                    //           ? addItemsHostController
                    //               .textEditingControllerEditLicensePlate
                    //           : addItemsHostController
                    //               .textEditingControllerLicensePlate,
                    //   inputType: TextInputType.text,
                    //   inputAlignment: TextAlign.left,
                    // ),
                    SizedBox(height: 15),
                    LabelNames(labelname: 'Minimum Rental Days'.tr),
                    const SizedBox(height: 10),
                    TextFieldRefs(
                      textInputAction: TextInputAction.done,
                      maxlength: 3,
                      txt: 'Enter Minimum Days'.tr,
                      textEditingControllerCommon: widget.mode ==
                              ScreenMode.edit
                          ? addItemsHostController
                              .textEditingControllerEditMinDays
                          : addItemsHostController.textEditingControllerMinDays,
                      inputType: TextInputType.number,
                      inputAlignment: TextAlign.left,
                    ),
                    const SizedBox(height: 15),
                    LabelNames(labelname: 'Insurance Coverage'.tr),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _insuranceCoverage,
                      hint: Text('Select Insurance Coverage'.tr),
                      items: ['Basic', 'Full']
                          .map((coverage) => DropdownMenuItem(
                                value: coverage,
                                child: Text(coverage.tr),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _insuranceCoverage = value;
                          addItemsHostController.setInsuranceCoverage(value);
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: themeColor,
                            width: 1.5,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Transform.translate(
                          offset: const Offset(-10, 0),
                          child: Checkbox(
                            activeColor: getColorBasedOnActiveModuleid(),
                            value: addItemsHostController.isAgeRestricted,
                            onChanged: (value) {
                              setState(() {
                                addItemsHostController.isAgeRestricted = value!;
                              });
                            },
                          ),
                        ),
                        Transform.translate(
                            offset: const Offset(-10, 0),
                            child: LabelNames(labelname: "Age Restriction".tr))
                      ],
                    ),
                    const SizedBox(height: 5),
                    addItemsHostController.isAgeRestricted
                        ? TextFieldRefs(
                            onChange: (value) {
                              addItemsHostController.cleanNumericInput(
                                  addItemsHostController
                                      .textEditingControllerMinAge,
                                  value!);
                              return null;
                            },
                            onTap: () {
                              addItemsHostController.numerictype = true;
                            },
                            txt: "Enter the minimum age".tr,
                            textEditingControllerCommon: addItemsHostController
                                .textEditingControllerMinAge,
                            inputType: TextInputType.number,
                            inputAlignment: TextAlign.left,
                          )
                        : const SizedBox(),
                    const SizedBox(height: 15),
                    LabelNames(labelname: 'Smoking Allowed'.tr),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Radio<bool>(
                          activeColor: themeColor,
                          value: true,
                          groupValue: addItemsHostController.isSmokingAllowed,
                          onChanged: (value) {
                            setState(() {
                              addItemsHostController.isSmokingAllowed =
                                  value ?? false;
                            });
                          },
                        ),
                        Text('Yes'.tr),
                        const SizedBox(width: 20),
                        Radio<bool>(
                          activeColor: themeColor,
                          value: false,
                          groupValue: addItemsHostController.isSmokingAllowed,
                          onChanged: (value) {
                            setState(() {
                              addItemsHostController.isSmokingAllowed =
                                  value ?? false;
                            });
                          },
                        ),
                        Text('No'.tr),
                      ],
                    ),
                    const SizedBox(height: 15),
                    LabelNames(labelname: 'International Travel Allowed'.tr),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Radio<bool>(
                          activeColor: themeColor,
                          value: true,
                          groupValue: addItemsHostController
                              .isInternationalTravelAllowed,
                          onChanged: (value) {
                            setState(() {
                              addItemsHostController
                                      .isInternationalTravelAllowed =
                                  value ?? false;
                            });
                          },
                        ),
                        Text('Yes'.tr),
                        const SizedBox(width: 20),
                        Radio<bool>(
                          activeColor: themeColor,
                          value: false,
                          groupValue: addItemsHostController
                              .isInternationalTravelAllowed,
                          onChanged: (value) {
                            setState(() {
                              addItemsHostController
                                      .isInternationalTravelAllowed =
                                  value ?? false;
                            });
                          },
                        ),
                        Text('No'.tr),
                      ],
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomHosts(
        onTap: () {
          addItemsHostController.validateAndNavigate(
            context: context,
            formKey: _formKey,
            mode: widget.mode,
            onNextButtonPressed: widget.onNextButtonPressed,
            titleController: widget.mode == ScreenMode.edit
                ? addItemsHostController.textEditingControllerEditTitle
                : addItemsHostController.textEditingControllerTitle,
            navigateToScreen: const VehiclePriceScreen(mode: ScreenMode.add),
          );
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
      ),
    );
  }

  Widget plateBox({required TextEditingController controller}) {
    return Expanded(
      child: Container(
        height: 55,
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: grey5),
        ),
        child: Center(
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            maxLength: 10,
            style: const TextStyle(
              fontSize: 16,
            ),
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              counterText: "",
              border: InputBorder.none,
              hintText: "---",
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                letterSpacing: 3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
