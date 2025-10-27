import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/add_items_host_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import '../../../../work_space.dart';

class VehiclePriceScreen extends StatefulWidget {
  final VoidCallback? onNextButtonPressed;
  final VoidCallback? onBackButtonPressed;
  final ScreenMode mode;
  const VehiclePriceScreen(
      {super.key,
      this.onNextButtonPressed,
      required this.mode,
      this.onBackButtonPressed});

  @override
  State<VehiclePriceScreen> createState() => _VehiclePriceScreenState();
}

class _VehiclePriceScreenState extends State<VehiclePriceScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.mode == ScreenMode.add) {
      addItemsHostController.convertFirstLettertoCapital = "Booking";
      addItemsHostController.serviceType = "booking";
    }
    if (addItemsHostController
        .textEditingControllerDoorstepPrice.text.isNotEmpty) {
      addItemsHostController.isCheckeddoorstep = true;
      addItemsHostController.isCheckedSecurityDeposit = true;
    }
  }

  AddItemsHostController addItemsHostController = Get.find();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: notifires.getbgcolor,
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(130),
            child: widget.mode == ScreenMode.add
                ? AppText(txt: "what will be expected price".tr)
                : const SizedBox()),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      addItemsHostController.serviceType.toString() == "booking"
                          ? LabelNames(labelname: 'Price/day'.tr)
                          : LabelNames(labelname: 'Price'.tr),
                      const SizedBox(height: 10),
                      TextFieldRefs(
                          suffixtext: currency,
                          txt: 'Enter price'.tr,
                          textEditingControllerCommon:
                              widget.mode == ScreenMode.edit
                                  ? addItemsHostController
                                      .textEditingControllerEditPrice
                                  : addItemsHostController
                                      .textEditingControllerPrice,
                          inputType: TextInputType.number,
                          inputAlignment: TextAlign.left,
                          onTap: () {
                            addItemsHostController.numerictype = true;
                          },
                          onChange: (value) {
                            TextEditingController controller =
                                widget.mode == ScreenMode.edit
                                    ? addItemsHostController
                                        .textEditingControllerEditPrice
                                    : addItemsHostController
                                        .textEditingControllerPrice;

                            addItemsHostController.cleanNumericInput(
                                controller, value!);
                            return null;
                          }),
                      const SizedBox(height: 10),
                      addItemsHostController.serviceType.toString() == "booking"
                          ? Column(
                              children: [
                                const SizedBox(height: 10),
                                DiscountPrize(mode: widget.mode),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Transform.translate(
                                      offset: const Offset(-10, 0),
                                      child: Checkbox(
                                        activeColor:
                                            getColorBasedOnActiveModuleid(),
                                        value: addItemsHostController
                                            .isCheckeddoorstep,
                                        onChanged: (value) {
                                          setState(() {
                                            addItemsHostController
                                                .isCheckeddoorstep = value!;
                                          });
                                        },
                                      ),
                                    ),
                                    Transform.translate(
                                        offset: const Offset(-10, 0),
                                        child: LabelNames(
                                            labelname:
                                                "Doorstep delivery Price".tr))
                                  ],
                                ),
                                 const SizedBox(height: 5),
                                addItemsHostController.isCheckeddoorstep
                                    ? TextFieldRefs(
                                        onChange: (value) {
                                          addItemsHostController.cleanNumericInput(
                                              addItemsHostController
                                                  .textEditingControllerDoorstepPrice,
                                              value!);
                                          return null;
                                        },
                                        suffixtext: currency,
                                        onTap: () {
                                          addItemsHostController.numerictype =
                                              true;
                                        },
                                        txt: "Enter the price".tr,
                                        textEditingControllerCommon:
                                            addItemsHostController
                                                .textEditingControllerDoorstepPrice,
                                        inputType: TextInputType.number,
                                        inputAlignment: TextAlign.left,
                                      )
                                    : const SizedBox(),
                                    const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Transform.translate(
                                      offset: const Offset(-10, 0),
                                      child: Checkbox(
                                        activeColor:
                                            getColorBasedOnActiveModuleid(),
                                        value: addItemsHostController
                                            .isCheckedSecurityDeposit,
                                        onChanged: (value) {
                                          setState(() {
                                            addItemsHostController
                                                .isCheckedSecurityDeposit = value!;
                                          });
                                        },
                                      ),
                                    ),
                                    Transform.translate(
                                        offset: const Offset(-10, 0),
                                        child: LabelNames(
                                            labelname:
                                                "Security Deposit Price".tr))
                                  ],
                                ),
                                const SizedBox(height: 5),
                                addItemsHostController.isCheckedSecurityDeposit
                                    ? TextFieldRefs(
                                        onChange: (value) {
                                          addItemsHostController.cleanNumericInput(
                                              addItemsHostController
                                                  .textEditingControllerSecurityDeposit,
                                              value!);
                                          return null;
                                        },
                                        suffixtext: currency,
                                        onTap: () {
                                          addItemsHostController.numerictype =
                                              true;
                                        },
                                        txt: "Enter the price".tr,
                                        textEditingControllerCommon:
                                            addItemsHostController
                                                .textEditingControllerSecurityDeposit,
                                        inputType: TextInputType.number,
                                        inputAlignment: TextAlign.left,
                                      )
                                    : const SizedBox(),
                              ],
                            )
                          : const SizedBox()
                    ],
                  ),
                ),
              ),
            ],
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
            if (addItemsHostController.isCheckeddoorstep == true) {
              if (addItemsHostController
                  .textEditingControllerDoorstepPrice.text.isEmpty) {
                showErrorToastMessage(
                    "Please uncheck the doorstep price or enter the doorstep price."
                        .tr);
                return;
              }
            }
              if (addItemsHostController.isCheckedSecurityDeposit == true) {
              if (addItemsHostController
                  .textEditingControllerSecurityDeposit.text.isEmpty) {
                showErrorToastMessage(
                    "Please uncheck the security deposit or enter the security deposit."
                        .tr);
                return;
              }
            }


            addItemsHostController.validateprice(
                context: context,
                formKey: _formKey,
                mode: widget.mode,
                isVehicle: true,
                onNextButtonPressed: widget.onNextButtonPressed);
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
