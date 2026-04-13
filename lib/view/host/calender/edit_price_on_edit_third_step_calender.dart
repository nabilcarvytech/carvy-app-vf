import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:carvy/controller/add_items_host_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/calendar_block_reasons.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/work_space.dart';

class EditPriceOnThirdStepCommonCalender extends StatefulWidget {
  final List<PickerDateRange> selectedDates;
  final List selectedAvailableRange;
  final VoidCallback onPressed; //

  const EditPriceOnThirdStepCommonCalender({
    super.key,
    required this.selectedDates,
    required this.selectedAvailableRange,
    required this.onPressed,
  });

  @override
  State<EditPriceOnThirdStepCommonCalender> createState() =>
      _EditPriceOnThirdStepCommonCalenderState();
}

class _EditPriceOnThirdStepCommonCalenderState
    extends State<EditPriceOnThirdStepCommonCalender> {
  AddItemsHostController addItemsHostController = Get.find();
  @override
  void initState() {
    addItemsHostController.textEditingControllerFuturePrice.clear();
    addItemsHostController.calendarBlockReason.value =
        CalendarBlockReasons.defaultReason;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 70,
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    Dimensions.radiusLarge,
                  ),
                  color: notifires.getblackwhitecolor,
                  border: Border.all(
                    width: 1.0,
                    color: notifires.getgreywhite,
                  ),
                ),
                child: Icon(
                  Icons.cancel,
                  color: notifires.getwhiteblackcolor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Availability".tr, style: heading3Grey1(context)),
                const SizedBox(width: 40),
                Column(
                  children: [
                    Row(
                      children: [
                        Obx(() => Transform.translate(
                              offset: const Offset(-12, 0),
                              child: Checkbox(
                                activeColor: getColorBasedOnActiveModuleid(),
                                value: addItemsHostController.isChecked1.value,
                                onChanged: (value) {
                                  addItemsHostController.isChecked1.value =
                                      value!;
                                  addItemsHostController.isChecked2.value =
                                      !addItemsHostController.isChecked1.value;
                                },
                              ),
                            )),
                        Transform.translate(
                            offset: const Offset(-12, 0),
                            child:
                                Text('Available'.tr, style: regular2(context))),
                      ],
                    ),
                    Row(
                      children: [
                        Obx(() => Transform.translate(
                              offset: const Offset(-12, -10),
                              child: Checkbox(
                                activeColor: getColorBasedOnActiveModuleid(),
                                value: addItemsHostController.isChecked2.value,
                                onChanged: (value) {
                                  addItemsHostController.isChecked2.value =
                                      value!;
                                  addItemsHostController.isChecked1.value =
                                      !addItemsHostController.isChecked2.value;
                                },
                              ),
                            )),
                        Transform.translate(
                            offset: const Offset(-12, -10),
                            child: Text('Block'.tr, style: regular2(context))),
                      ],
                    ),
                  ],
                ),
                Obx(() => addItemsHostController.isChecked2.value
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: addItemsHostController
                                  .calendarBlockReason.value,
                          decoration: InputDecoration(
                            labelText: 'Blocking reason'.tr,
                            filled: true,
                            fillColor: notifires.getblackwhitecolor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusLarge,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusLarge,
                              ),
                              borderSide:
                                  BorderSide(color: notifires.getgreywhite),
                            ),
                          ),
                          items: CalendarBlockReasons.options
                              .map(
                                (e) => DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(
                                    e,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              addItemsHostController.calendarBlockReason.value =
                                  v;
                            }
                          },
                        ),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
            Column(
              children: List.generate(widget.selectedDates.length, (index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          color: notifires.getwhiteblackcolor,
                        ),
                        const SizedBox(width: 10),
                        Text(
                            "${DateFormat('yyyy/MM/dd').format(widget.selectedDates[index].startDate!)}${widget.selectedDates[index].endDate != null ? ' - ${DateFormat('yyyy/MM/dd').format(widget.selectedDates[index].endDate!)}' : ''}",
                            style: regular2(context)),
                        const SizedBox(width: 8),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Obx(() => addItemsHostController.isChecked1.value
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LabelNames(labelname: "Price per day".tr),
                              const SizedBox(
                                height: 15,
                              ),
                              TextFieldRefs(
                                txt: "Enter the price".tr,
                                suffixtext: currency,
                                textEditingControllerCommon:
                                    addItemsHostController
                                        .textEditingControllerFuturePrice,
                                inputType: webPlateForm
                                    ? TextInputType.number
                                    : Platform.isIOS
                                        ? const TextInputType.numberWithOptions(
                                            signed: true, decimal: true)
                                        : TextInputType.number,
                                textInputAction: TextInputAction.done,
                                inputAlignment: TextAlign.left,
                                onEditingComplete: () {
                                  FocusScope.of(context).unfocus();
                                },
                                onChange: (value) {
                                  if (value == "0") {
                                    addItemsHostController
                                        .textEditingControllerFuturePrice
                                        .text = "";
                                    showErrorToastMessage(
                                        "Price Should not be zero".tr);
                                    return;
                                  }
                                  widget.selectedAvailableRange[index]
                                      ['value'] = value;
                                  return null;
                                },
                              ),
                            ],
                          )
                        : const SizedBox()),
                  ],
                );
              }),
            ),
            const SizedBox(height: 20),
            CustomsButtons(
                text: "Save".tr,
                backgroundColor: getColorBasedOnActiveModuleid(),
                onPressed: widget.onPressed),
            const SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }
}
