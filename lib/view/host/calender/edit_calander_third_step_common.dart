import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/controller/add_items_host_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/calendar_model.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/rolling_calendar_bounds.dart';
import 'package:carvy/utils/safe_rebuild.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/host/bottom_bar_host.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import 'package:carvy/view/host/calender/edit_price_on_edit_third_step_calender.dart';

import 'package:carvy/work_space.dart';

class EditCalenderOnThirdStepCommon extends StatefulWidget {
  const EditCalenderOnThirdStepCommon({super.key});

  @override
  State<EditCalenderOnThirdStepCommon> createState() =>
      _EditCalenderOnThirdStepCommonState();
}

class _EditCalenderOnThirdStepCommonState
    extends State<EditCalenderOnThirdStepCommon> {
  AddItemsHostController addItemsHostController = Get.find();
  DateRangePickerController dateRangePickerControllers =
      DateRangePickerController();
  List<Map<String, Object>> selectedDateRange = [];
  bool isDateSelected = false;
  List<PickerDateRange> selectedDates = [];
  List selectedPriceMap = [];
  List selectedAvailableRange = [];
  List selectedNotAvailableRange = [];
  List myNewDateAndStatusListAvailable = [];
  List myNewDateAndStatusListNotAvailable = [];

  List<PickerDateRange> initialList = [];

  String endDate = '';

  String startDate = '';
  List<PickerDateRange> availableDates = [];
  List<PickerDateRange> notAvailableDates = [];
  List<PickerDateRange> bookedDates = [];
  List<String> avialblePrice = [];
  CalendarItemId? calendarItemId;
  ItemDates? itemDates;

  dynamic futurePrice;
  dynamic bookedPrice;

  int toggle = 1;

  int initialLabelIndex = 0;

  @override
  initState() {
    super.initState();
    runAfterFirstFrame(fetchDataCalendar);
  }

  void submitMethod() async {
    if (addItemsHostController.isChecked1.value == false &&
        addItemsHostController.isChecked2.value == false) {
      showErrorToastMessage("Please Select the checkBox");
      return;
    }

    DateTime now = DateTime.now();
    DateTime maxDate = RollingCalendarBounds.lastDate();

    if (addItemsHostController.isChecked1.value) {
      if (addItemsHostController.textEditingControllerFuturePrice.text == "" ||
          addItemsHostController.textEditingControllerFuturePrice.text == "0") {
        showErrorToastMessage("Price should not be zero or empty");
        return;
      }

      for (var x in selectedAvailableRange) {
        DateTime startDate = x['date'].startDate ?? DateTime.now();
        DateTime endDate = x['date'].endDate ?? DateTime.now();

        if (endDate.isAfter(maxDate)) {
          showErrorToastMessage(
              "The selected date range must be within the current month and the next two months."
                  .tr);
          return;
        }

        Duration totalRange = endDate.difference(startDate);
        List aList = [];

        for (int i = 0; i <= totalRange.inDays; i++) {
          aList.add(jsonEncode({
            "date": DateFormat("yyyy-MM-dd")
                .parse("${x['date'].startDate.add(Duration(days: i))}")
                .toString()
                .split(" ")[0],
            "status": x['status'],
            "price": x['value']
          }));
        }

        myNewDateAndStatusListAvailable.add(aList);
      }
    }

    if (addItemsHostController.isChecked2.value) {
      for (var x in selectedNotAvailableRange) {
        DateTime startDate = x['date'].startDate ?? DateTime.now();
        DateTime endDate = x['date'].endDate ?? DateTime.now();
        DateTime today = DateTime.now();
        DateTime currentDateOnly = DateTime(today.year, today.month, today.day);
        DateTime startDateOnly =
            DateTime(startDate.year, startDate.month, startDate.day);
        DateTime endDateOnly =
            DateTime(endDate.year, endDate.month, endDate.day);

        if (endDate.isAfter(maxDate)) {
          showErrorToastMessage(
              "The selected date range must be within the current month and the next two months."
                  .tr);
          return;
        }

        Duration totalRange = endDate.difference(startDate);
        List aList = [];

        for (int i = 0; i <= totalRange.inDays; i++) {
          aList.add(jsonEncode({
            "date": DateFormat("yyyy-MM-dd")
                .parse("${x['date'].startDate.add(Duration(days: i))}")
                .toString()
                .split(" ")[0],
            "status": x['status'],
            "price": "0".toString(),
            "reason": addItemsHostController.calendarBlockReason.value,
          }));
        }
        myNewDateAndStatusListNotAvailable.add(aList);
      }
    }

    showLoading();
    
    // Extraire start_date et end_date des ranges sélectionnés
    String? startDate;
    String? endDate;
    List<DateTime> allStartDates = [];
    List<DateTime> allEndDates = [];
    
    if (addItemsHostController.isChecked1.value && selectedAvailableRange.isNotEmpty) {
      for (var x in selectedAvailableRange) {
        DateTime rangeStart = x['date'].startDate ?? DateTime.now();
        DateTime rangeEnd = x['date'].endDate ?? DateTime.now();
        allStartDates.add(rangeStart);
        allEndDates.add(rangeEnd);
      }
    } else if (addItemsHostController.isChecked2.value && selectedNotAvailableRange.isNotEmpty) {
      for (var x in selectedNotAvailableRange) {
        DateTime rangeStart = x['date'].startDate ?? DateTime.now();
        DateTime rangeEnd = x['date'].endDate ?? DateTime.now();
        allStartDates.add(rangeStart);
        allEndDates.add(rangeEnd);
      }
    }
    
    if (allStartDates.isNotEmpty && allEndDates.isNotEmpty) {
      // Trouver la première date (la plus ancienne) et la dernière date (la plus récente)
      DateTime earliestStart = allStartDates.reduce((a, b) => a.isBefore(b) ? a : b);
      DateTime latestEnd = allEndDates.reduce((a, b) => a.isAfter(b) ? a : b);
      startDate = DateFormat('yyyy-MM-dd').format(earliestStart);
      endDate = DateFormat('yyyy-MM-dd').format(latestEnd);
    }
    
    // Déterminer item_id avec validation
    String? itemIdValue = item?.id?.toString() ?? addItemsHostController.itemHostId?.toString();
    
    // Validation : vérifier que item_id n'est pas null ou vide
    if (itemIdValue == null || itemIdValue.isEmpty || itemIdValue == 'null') {
      closeLoading();
      showErrorToastMessage("Erreur: L'ID du véhicule est manquant. Veuillez sélectionner un véhicule.");
      print('❌ [CALENDAR_DIAG] item_id est manquant ou invalide');
      return;
    }
    
    Map map = {
      "availability_dates": addItemsHostController.isChecked1.value
          ? myNewDateAndStatusListAvailable.toString()
          : myNewDateAndStatusListNotAvailable.toString(),
      "item_id": itemIdValue
    };
    
    // Ajouter start_date et end_date si disponibles
    if (startDate != null && endDate != null) {
      map["start_date"] = startDate;
      map["end_date"] = endDate;
    }

    // ========== MOCK DATA - OLD API CALL COMMENTED ==========
    // var response = await httpPost(Config.addEditCalender, map);
    
    // MOCK: Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // MOCK: Static success response for calendar update
    Map<String, dynamic> mockResponse = {
      "status": 200,
      "message": "Calendar updated successfully",
      "error": "",
      "data": {
        "id": (item?.id ?? addItemsHostController.itemHostId).toString(),
        "updated": true
      }
    };
    
    var response = mockResponse;
    // ========== END MOCK DATA ==========
    
    closeLoading();
    if (response != null) {
      if (response['status'] == 200) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (builder) => const EditCalenderOnThirdStepCommon()));
      } else {
        showErrorToastMessage(response['error']);
      }
    }
  }

  String price = "";
  String? avaialbleCellPrice;

  Future<void> fetchDataCalendar() async {
    showLoading();
    
    // ========== MOCK DATA - OLD API CALL COMMENTED ==========
    // var response = await httpGet(Config.getItemDates, {
    //   "item_id": (item?.id ?? addItemsHostController.itemHostId).toString()
    // });
    
    // MOCK: Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // MOCK: Static calendar dates data
    Map<String, dynamic> mockGetItemDatesResponse = {
      "status": 200,
      "message": "Item dates retrieved successfully",
      "error": "",
      "data": {
        "ItemDates": {
          "price": "50.00",
          "available_dates": [
            {"date": "2025-12-20", "price": "50.00"},
            {"date": "2025-12-21", "price": "50.00"},
            {"date": "2025-12-22", "price": "55.00"},
            {"date": "2025-12-23", "price": "55.00"},
            {"date": "2025-12-24", "price": "60.00"}
          ],
          "not_available_dates": [
            {"date": "2025-12-25"},
            {"date": "2025-12-26"},
            {"date": "2025-12-27"}
          ],
          "booked_dates": [
            {"date": "2025-12-28", "price": "60.00"},
            {"date": "2025-12-29", "price": "60.00"}
          ]
        }
      }
    };
    
    var response = mockGetItemDatesResponse;
    // ========== END MOCK DATA ==========

    if (response != null) {
      closeLoading();
      calendarItemId = CalendarItemId.fromJson(response);

      if (calendarItemId != null && calendarItemId!.data != null) {
        setState(() {
          itemDates = calendarItemId!.data!.itemDates;
        });

        if (itemDates != null) {
          if (itemDates!.notAvailableDates != null) {
            String jsonString = jsonEncode(itemDates!.notAvailableDates!);
            List jsonList = jsonDecode(jsonString);

            if (jsonList.isNotEmpty) {
              for (var x in jsonList) {
                notAvailableDates.add(PickerDateRange(
                  DateTime.tryParse(x['date']),
                  DateTime.tryParse(x['date']),
                ));
              }
            }
          }
          avaialbleCellPrice = '';

          // Additional logic for available dates
          if (itemDates!.availableDates != null) {
            String jsonString = jsonEncode(itemDates!.availableDates!);
            List jsonList = jsonDecode(jsonString);

            if (jsonList.isNotEmpty) {
              for (var x in jsonList) {
                availableDates.add(PickerDateRange(
                  DateTime.tryParse(x['date']),
                  DateTime.tryParse(x['date']),
                ));
                avialblePrice.add(x['price']);
              }
            }
          }

          if (itemDates!.bookedDates != null) {
            String jsonString = jsonEncode(itemDates!.bookedDates!);
            List jsonList = jsonDecode(jsonString);

            if (jsonList.isNotEmpty) {
              for (var x in jsonList) {
                bookedDates.add(PickerDateRange(
                  DateTime.tryParse(x['date']),
                  DateTime.tryParse(x['date']),
                ));
                bookedPrice = x['price'];
              }
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      appBar: AppBar(
        surfaceTintColor: notifires.getbgcolor,
        backgroundColor: notifires.getbgcolor,
        leadingWidth: 80,
        leading: InkWell(
            onTap: () {
              Get.to(() => const BottomHost(initialIndex: 0));
            },
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 20, top: 8, bottom: 8, right: 20),
              child: PhysicalModel(
                color: Colors.transparent,
                shadowColor: notifires.getGrey4Whitecolor,
                elevation: 5.0, // Adjust the elevation value as needed
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
            )),
        title: Text(
          "Calendar".tr,
          style: heading2Grey1(context),
        ),
        centerTitle: true,
      ),
      body: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                color: notifires.getboxcolor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: notifires.getGrey3Whitecolor.withOpacity(0.1),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(0, 0), // changes position of shadow
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12), // Image border
                        child: SizedBox.fromSize(
                          size: const Size.fromRadius(180), // Image radius
                          child: FadeInImage.assetNetwork(
                            fadeInCurve: Curves.easeInCirc,
                            placeholder: "assets/images/ezgif.com-crop.gif",
                            height: 50,
                            image: (item?.frontImage?.thumbnail) ?? '',
                            imageErrorBuilder: (context, error, stackTrace) {
                              return getErrorImage();
                            },
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item?.title ?? "No Title".tr,
                                style: heading3Grey1(context)),
                            Text(
                              item?.description ?? "No Description".tr,
                              style: regular2(context),
                              maxLines: 2,
                              softWrap: true,
                            ),
                          ]),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          const Divider(
            thickness: 2,
            endIndent: 12,
            indent: 12,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Avability(
                    color: greentext,
                    borderColor: lightsGrey,
                  ),
                  const SizedBox(width: 10),
                  LabelNames(labelname: 'Booked'.tr),
                  const SizedBox(width: 15),
                  Avability(
                    color: redColor,
                    borderColor: redColor,
                  ),
                  const SizedBox(width: 10),
                  LabelNames(labelname: 'Not available'.tr),
                  const SizedBox(width: 15),
                  Avability(
                    color: darkbox,
                    borderColor: notifires.getwhiteblackcolor,
                  ),
                  const SizedBox(width: 10),
                  LabelNames(labelname: 'Available'.tr)
                ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(children: [
              Avability(color: yellowColor, borderColor: yellowColor),
              const SizedBox(width: 12),
              LabelNames(labelname: "Selected".tr),
              const SizedBox(width: 15),
              Avability(
                  color: greycolor.withOpacity(0.4),
                  borderColor: greycolor.withOpacity(0.4)),
              const SizedBox(width: 15),
              LabelNames(labelname: "Past Dates".tr)
            ]),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 800,
            child: SfDateRangePicker(
                headerHeight: 48,
                headerStyle: DateRangePickerHeaderStyle(
                  textAlign: TextAlign.start,
                  backgroundColor: Colors.white,
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: boxcolor,
                  ),
                ),
                monthCellStyle: DateRangePickerMonthCellStyle(
                    blackoutDateTextStyle: const TextStyle(
                      color: Colors.white,
                    ),
                    blackoutDatesDecoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.green.shade100)),
                controller: dateRangePickerControllers,
                monthViewSettings: DateRangePickerMonthViewSettings(
                  firstDayOfWeek: 7,
                  viewHeaderHeight: 36,
                  dayFormat: 'EEE',
                  viewHeaderStyle: DateRangePickerViewHeaderStyle(
                    backgroundColor: darkbox.withOpacity(
                        0.1),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 11),
                  ),
                ),
                backgroundColor: Colors.white,
                navigationDirection:
                    DateRangePickerNavigationDirection.vertical,
                navigationMode: DateRangePickerNavigationMode.scroll,
                enableMultiView: false,
                allowViewNavigation: false,
                minDate: RollingCalendarBounds.firstDate(),
                maxDate: RollingCalendarBounds.lastDate(),
                enablePastDates: false,
                onViewChanged: (args) {
                  RollingCalendarBounds.clampPickerView(
                    args,
                    dateRangePickerControllers,
                  );
                },
                view: DateRangePickerView.month,
                selectionMode: DateRangePickerSelectionMode.range,
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  PickerDateRange? selectedRange = args.value;
                  if (selectedRange != null) {
                    selectedDates = [selectedRange];
                    DateTime startDate =
                        selectedRange.startDate ?? DateTime.now();
                    DateTime endDate = selectedRange.endDate ?? DateTime.now();
                    Duration totalRange = endDate.difference(startDate);
                    List<DateTime> allDates = [];
                    for (int i = 0; i <= totalRange.inDays; i++) {
                      allDates.add(startDate.add(Duration(days: i)));
                    }
                    if (allDates.isNotEmpty) {
                      setState(() {
                        isDateSelected = true;
                      });
                    } else {
                      setState(() {
                        isDateSelected = false;
                      });
                    }
                  } else {}
                  if (selectedDates.isNotEmpty) {
                    selectedAvailableRange = selectedDates
                        .map((date) => {
                              "date": date,
                              "value": addItemsHostController
                                      .textEditingControllerPrice.text.isEmpty
                                  ? "0"
                                  : addItemsHostController
                                      .textEditingControllerPrice.text,
                              'status': "Available",
                            })
                        .toList();
                  }
                  if (selectedDates.isNotEmpty) {
                    selectedNotAvailableRange = selectedDates
                        .map((date) => {
                              "date": date,
                              "value": addItemsHostController
                                      .textEditingControllerPrice.text.isEmpty
                                  ? "0"
                                  : addItemsHostController
                                      .textEditingControllerPrice.text,
                              'status': "Not Available",
                            })
                        .toList();
                  }
                },
                cellBuilder: (BuildContext context,
                    DateRangePickerCellDetails cellDetails) {
                  Color cellColor = whiteColor; 
                  Color textColor = blackColor; 
                  String cellPrice = '';
                  bool isNotAvailableDate = false;
                  bool isBookedDate = false;
                  bool isAvailableDate = false;
                  bool isSelectedDate = false;
                  isBookedDate = bookedDates.any((range) {
                    return range.startDate != null &&
                        range.endDate != null &&
                        (cellDetails.date.isAfter(range.startDate!) &&
                                cellDetails.date.isBefore(range.endDate!) ||
                            cellDetails.date
                                .isAtSameMomentAs(range.startDate!) ||
                            cellDetails.date.isAtSameMomentAs(range.endDate!));
                  });

                  if (isBookedDate) {
                    cellColor = greentext;
                    textColor = whiteColor;
                    cellPrice = '$currency $bookedPrice';
                  } else {
                    isAvailableDate = availableDates.any((range) {
                      return range.startDate != null &&
                          range.endDate != null &&
                          (cellDetails.date.isAfter(range.startDate!) &&
                                  cellDetails.date.isBefore(range.endDate!) ||
                              cellDetails.date
                                  .isAtSameMomentAs(range.startDate!) ||
                              cellDetails.date
                                  .isAtSameMomentAs(range.endDate!));
                    });

                    if (isAvailableDate) {
                      cellColor = darkbox;
                      textColor = whiteColor;

                      int index = availableDates.indexWhere((range) =>
                          range.startDate != null &&
                          range.endDate != null &&
                          (cellDetails.date.isAfter(range.startDate!) &&
                                  cellDetails.date.isBefore(range.endDate!) ||
                              cellDetails.date
                                  .isAtSameMomentAs(range.startDate!) ||
                              cellDetails.date
                                  .isAtSameMomentAs(range.endDate!)));

                      if (index != -1 && index < avialblePrice.length) {
                        var dataForDate = avialblePrice[index];
                        cellPrice = "$currency $dataForDate";
                      }
                    } else {
                      isNotAvailableDate = notAvailableDates.any((range) {
                        return range.startDate != null &&
                            range.endDate != null &&
                            (cellDetails.date.isAfter(range.startDate!) &&
                                    cellDetails.date.isBefore(range.endDate!) ||
                                cellDetails.date
                                    .isAtSameMomentAs(range.startDate!) ||
                                cellDetails.date
                                    .isAtSameMomentAs(range.endDate!));
                      });

                      if (isNotAvailableDate) {
                        cellColor = Colors.red;
                        textColor = whiteColor;
                      }
                    }

                    // Check if the date is selected
                    isSelectedDate = selectedDates.any((range) {
                      return range.startDate != null &&
                          range.endDate != null &&
                          (cellDetails.date.isAfter(range.startDate!) &&
                                  cellDetails.date.isBefore(range.endDate!) ||
                              cellDetails.date
                                  .isAtSameMomentAs(range.startDate!) ||
                              cellDetails.date
                                  .isAtSameMomentAs(range.endDate!));
                    });

                    if (isSelectedDate) {
                      cellColor = orangeColor;
                      textColor = whiteColor;
                      cellPrice = ''; // Set price to empty for selected dates
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: cellDetails.date.isBefore(DateTime.now())
                                ? greyColor.withOpacity(0.5)
                                : darkbox,
                            width: 1.5,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(5),
                        color: cellColor,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            convertToLocaleDigits(
                                cellDetails.date.day.toString()),
                            style: TextStyle(
                                color: cellDetails.date.isBefore(DateTime.now())
                                    ? whiteColor
                                    : textColor,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            convertToLocaleDigits(cellPrice.toString()),
                            style: smallAirBk.copyWith(
                                fontSize: 8,
                                color: cellDetails.date.isBefore(DateTime.now())
                                    ? whiteColor
                                    : textColor,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: isDateSelected
          ? SizedBox(
              height: 50,
              child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                    constraints: const BoxConstraints.expand(),
                    useRootNavigator: true,
                    backgroundColor: notifires.getblackwhitecolor,
                    isScrollControlled: true,
                    useSafeArea: false,
                    context: context,
                    builder: (BuildContext context) {
                      return EditPriceOnThirdStepCommonCalender(
                        selectedDates: selectedDates,
                        onPressed: () {
                          submitMethod();
                        },
                        selectedAvailableRange: selectedAvailableRange,
                      );
                    },
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                        child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.radiusExtraLarge,
                          vertical: 11),
                      decoration: BoxDecoration(
                          border: Border.all(color: darkbox),
                          color: darkbox,
                          borderRadius: BorderRadius.circular(
                              Dimensions.radiusExtraLarge)),
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            size: 15,
                            color: whiteColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Edit'.tr,
                            style: smallHeadigAirBd.copyWith(color: whiteColor),
                          ),
                        ],
                      ),
                    ))
                  ],
                ),
              ),
            )
          : const SizedBox(),
      // : null,
    );
  }
}
