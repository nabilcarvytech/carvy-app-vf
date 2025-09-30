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
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/calendar_model.dart';
import 'package:carvy/model/my_items_model.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/host/bottom_bar_host.dart';
import 'package:carvy/view/host/calender/add_price_on_common_calander.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import 'package:carvy/view/host/initial_host_common_screen.dart';
import 'package:carvy/work_space.dart';

class CalendarCommonScreen extends StatefulWidget {
  const CalendarCommonScreen({super.key});

  @override
  State<CalendarCommonScreen> createState() => _CalendarCommonScreenState();
}

class _CalendarCommonScreenState extends State<CalendarCommonScreen> {
  AddItemsHostController addItemsHostController = Get.find();
  DateRangePickerController dateRangePickerControllers =
      DateRangePickerController();
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
  CalendarItemId? calendarItemId;
  ItemDates? itemDates;
  List<String> avialblePrice = [];
  dynamic futurePrice;
  dynamic bookedPrice;

  int toggle = 1;

  int initialLabelIndex = 0;

  @override
  initState() {
    super.initState();

    fetchDataCalendar();
  }

  MyItemsModel? myItemsModelHost;
  List<Items> list = [];
  num offset = 0;
  num? lastItemId;
  Items? lastItems;

  itemDataApi() async {
    try {
      var response = await httpPost(Config.myItems, {"offset": "$offset"});

      if (response != null) {
        myItemsModelHost = MyItemsModel.fromJson(response);
        if (myItemsModelHost!.data != null) {
          list.addAll(myItemsModelHost!.data!.items!);
          offset = myItemsModelHost!.data!.offset!;
          checkItemPiblicationLimit = response["data"]["checkLimit"];

          if (list.isNotEmpty) {
            lastItems = list.last;
            lastItemId = lastItems!.id!;

            var response = await httpGet(
              Config.getItemDates,
              {"item_id": (initialitems?.id ?? lastItemId).toString()},
            );

            if (response != null) {
              calendarItemId = CalendarItemId.fromJson(response);
              if (calendarItemId != null && calendarItemId!.data != null) {
                itemDates = calendarItemId!.data!.itemDates;

                if (itemDates != null) {
                  if (itemDates!.notAvailableDates != null) {
                    String jsonString =
                        jsonEncode(itemDates!.notAvailableDates!);
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

                  if (itemDates!.availableDates != null) {
                    String jsonString = jsonEncode(itemDates!.availableDates!);
                    List jsonList = jsonDecode(jsonString);

                    if (jsonList.isNotEmpty) {
                      for (var x in jsonList) {
                        futurePrice = x['price'];
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }

      setState(() {});
    } catch (e) {
      setState(() {});
    }
  }

  submitMethod(BuildContext context) async {
    if (addItemsHostController.isChecked1.value == false &&
        addItemsHostController.isChecked2.value == false) {
      showErrorToastMessage("Please Select the checkBox");
      return;
    }
    DateTime now = DateTime.now();
    DateTime maxDate = now.add(const Duration(days: 120));
    if (addItemsHostController.isChecked1.value) {
      if (addItemsHostController.textEditingControllerFuturePrice.text == "" ||
          addItemsHostController.textEditingControllerFuturePrice.text == "0") {
        showErrorToastMessage("price should not be zero or empty");
        return;
      }

      for (var x in selectedAvailableRange) {
        DateTime startDate = x['date'].startDate ?? DateTime.now();
        DateTime endDate = x['date'].endDate ?? DateTime.now();

        if (endDate.isAfter(maxDate)) {
          showErrorToastMessage(
              "The selected date range must be within the current date to the next 120 days.");
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

        if (startDateOnly == currentDateOnly ||
            endDateOnly == currentDateOnly) {
          showErrorToastMessage("Can't block the current date");
          return;
        }
        if (endDate.isAfter(maxDate)) {
          showErrorToastMessage(
              "The selected date range must be within the current date to the next 120 days.");
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
            "price": "0".toString()
          }));
        }
        myNewDateAndStatusListNotAvailable.add(aList);
      }
    }

    showLoading();
    Map map = {
      "availability_dates": addItemsHostController.isChecked1.value
          ? myNewDateAndStatusListAvailable.toString()
          : myNewDateAndStatusListNotAvailable.toString(),
      "id": (initialitems?.id ?? lastItemId).toString(),
    };

    var response = await httpPost(Config.addEditCalender, map);
    closeLoading();
    if (response != null) {
      if (response['status'] == 200) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (builder) => const BottomHost(initialIndex: 1)));
      } else {
        showErrorToastMessage(response['error']);
      }
    } else {}
  }

  Future<void> fetchDataCalendar() async {
    if (token.isEmpty) {
      return;
    }
    await itemDataApi();
  }

  bool isDateInRange(DateTime date, PickerDateRange range) {
    if (range.startDate != null && range.endDate != null) {
      return (date.isAfter(range.startDate!) ||
              date.isAtSameMomentAs(range.startDate!)) &&
          (date.isBefore(range.endDate!) ||
              date.isAtSameMomentAs(range.endDate!));
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return showerrorWhenloginwithOtherDevice == "token not match"
        ? Center(child: showTokenExpirePlease())
        : myItemsModelHost == null
            ? calanderScreenShimmer()
            : list.isEmpty
                ? Addproperty(
                    title: "You don't have any List".tr,
                    subTitle: staticContantforHost(),
                    btnTxt: "Add New List".tr,
                    onTap: () {
                      if (showerrorWhenloginwithOtherDevice ==
                          "token not match") {
                        showErrorToastMessage("Please login again");
                        return;
                      }
                      if (checkItemPiblicationLimit.toString() == "0") {
                        showErrorToastMessage(
                            "You have reached the limit for publishing items. Please contact the admin for further assistance.");
                        return;
                      }
                      Get.to(() => const InitialHostCommonScreen());
                    },
                  )
                : Scaffold(
                    backgroundColor: notifires.getbgcolor,
                    appBar: AppBar(
                      automaticallyImplyLeading: false,
                      surfaceTintColor: notifires.getbgcolor,
                      backgroundColor: notifires.getbgcolor,
                      title: Text("Calendar".tr, style: heading2Grey1(context)),
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
                                  color: notifires.getGrey3Whitecolor
                                      .withOpacity(0.1),
                                  spreadRadius: 3,
                                  blurRadius: 5,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 120,
                                    height: 120,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          12), // Image border
                                      child: SizedBox.fromSize(
                                        size: const Size.fromRadius(180),
                                        child: FadeInImage.assetNetwork(
                                          fadeInCurve: Curves.easeInCirc,
                                          placeholder:
                                              "assets/images/ezgif.com-crop.gif",
                                          height: 50,
                                          image: (initialitems
                                                      ?.frontImage?.thumbnail ??
                                                  lastItems?.frontImage
                                                      ?.thumbnail) ??
                                              '',
                                          imageErrorBuilder:
                                              (context, error, stackTrace) {
                                            return getErrorImage();
                                          },
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  Flexible(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                              initialitems?.title ??
                                                  lastItems?.title ??
                                                  "No Title".tr,
                                              style: heading3Grey1(context)),
                                          Text(
                                            initialitems?.description ??
                                                lastItems?.description ??
                                                "No Description".tr,
                                            style: regular2(context),
                                            maxLines: 2,
                                          ),
                                        ]),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      _showItemListDialog(context, list);
                                    },
                                    child: Container(
                                      width: 20,
                                      height: 55,
                                      alignment: Alignment.topCenter,
                                      child: Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 30,
                                        color: notifires.getwhiteblackcolor,
                                      ),
                                    ),
                                  ),
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
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // First Row of Legend Items
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Avability(
                                    color: greentext,
                                    borderColor: lightsGrey,
                                  ),
                                  const SizedBox(width: 10),
                                  LabelNames(labelname: 'Booked'.tr),
                                  const SizedBox(width: 20),
                                  Avability(
                                    color: redColor,
                                    borderColor: redColor,
                                  ),
                                  const SizedBox(width: 10),
                                  LabelNames(labelname: 'Not available'.tr),
                                  const SizedBox(width: 20),
                                  Avability(
                                    color: darkbox,
                                    borderColor: notifires.getwhiteblackcolor,
                                  ),
                                  const SizedBox(width: 10),
                                  LabelNames(labelname: 'Available'.tr),
                                ],
                              ),
                              const SizedBox(
                                  height:
                                      15), // Add some spacing between the rows
                              // Second Row of Legend Items
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Avability(
                                    color: yellowColor,
                                    borderColor: yellowColor,
                                  ),
                                  const SizedBox(width: 10),
                                  LabelNames(labelname: "Selected".tr),
                                  const SizedBox(width: 20),
                                  Avability(
                                    color: greycolor.withOpacity(0.4),
                                    borderColor: greycolor.withOpacity(0.4),
                                  ),
                                  const SizedBox(width: 10),
                                  LabelNames(labelname: "Past Dates".tr),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 800,
                          child: SfDateRangePicker(
                              allowViewNavigation: false,
                              headerStyle: DateRangePickerHeaderStyle(
                                textAlign: TextAlign.start,
                                textStyle:
                                    TextStyle(fontSize: 18, color: boxcolor),
                              ),
                              monthCellStyle: DateRangePickerMonthCellStyle(
                                  blackoutDateTextStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  blackoutDatesDecoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green.shade100)),
                              controller: dateRangePickerControllers,
                              monthViewSettings:
                                  DateRangePickerMonthViewSettings(
                                viewHeaderStyle: DateRangePickerViewHeaderStyle(
                                  backgroundColor: darkbox.withOpacity(0.1),
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 12),
                                ),
                              ),
                              backgroundColor: Colors.white,
                              navigationDirection:
                                  DateRangePickerNavigationDirection.vertical,
                              navigationMode:
                                  DateRangePickerNavigationMode.scroll,
                              enableMultiView: true,
                              minDate: DateTime.now(),
                              view: DateRangePickerView.month,
                              selectionMode: DateRangePickerSelectionMode.range,
                              onSelectionChanged:
                                  (DateRangePickerSelectionChangedArgs args) {
                                PickerDateRange? selectedRange = args.value;

                                if (selectedRange != null) {
                                  selectedDates = [selectedRange];

                                  DateTime startDate =
                                      selectedRange.startDate ?? DateTime.now();

                                  DateTime endDate =
                                      selectedRange.endDate ?? DateTime.now();
                                  Duration totalRange =
                                      endDate.difference(startDate);

                                  List<DateTime> allDates = [];

                                  for (int i = 0; i <= totalRange.inDays; i++) {
                                    allDates
                                        .add(startDate.add(Duration(days: i)));
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
                                                    .textEditingControllerPrice
                                                    .text
                                                    .isEmpty
                                                ? "0"
                                                : addItemsHostController
                                                    .textEditingControllerPrice
                                                    .text,
                                            'status': "Available",
                                          })
                                      .toList();
                                }

                                if (selectedDates.isNotEmpty) {
                                  selectedNotAvailableRange = selectedDates
                                      .map((date) => {
                                            "date": date,
                                            "value": addItemsHostController
                                                    .textEditingControllerPrice
                                                    .text
                                                    .isEmpty
                                                ? "0"
                                                : addItemsHostController
                                                    .textEditingControllerPrice
                                                    .text,
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
                                      (cellDetails.date
                                                  .isAfter(range.startDate!) &&
                                              cellDetails.date
                                                  .isBefore(range.endDate!) ||
                                          cellDetails.date.isAtSameMomentAs(
                                              range.startDate!) ||
                                          cellDetails.date.isAtSameMomentAs(
                                              range.endDate!));
                                });

                                if (isBookedDate) {
                                  cellColor = greentext;
                                  textColor = whiteColor;
                                  cellPrice = '$currency $bookedPrice';
                                } else {
                                  // Check if the date is available
                                  isAvailableDate = availableDates.any((range) {
                                    return range.startDate != null &&
                                        range.endDate != null &&
                                        (cellDetails.date.isAfter(
                                                    range.startDate!) &&
                                                cellDetails.date
                                                    .isBefore(range.endDate!) ||
                                            cellDetails.date.isAtSameMomentAs(
                                                range.startDate!) ||
                                            cellDetails.date.isAtSameMomentAs(
                                                range.endDate!));
                                  });

                                  if (isAvailableDate) {
                                    cellColor = darkbox;
                                    textColor = whiteColor;

                                    int index =
                                        availableDates.indexWhere(
                                            (range) =>
                                                range.startDate != null &&
                                                range.endDate != null &&
                                                (cellDetails.date.isAfter(
                                                            range.startDate!) &&
                                                        cellDetails.date
                                                            .isBefore(range
                                                                .endDate!) ||
                                                    cellDetails.date
                                                        .isAtSameMomentAs(
                                                            range.startDate!) ||
                                                    cellDetails.date
                                                        .isAtSameMomentAs(
                                                            range.endDate!)));

                                    if (index != -1 &&
                                        index < avialblePrice.length) {
                                      var dataForDate = avialblePrice[index];
                                      cellPrice = "$currency $dataForDate";
                                    }
                                  } else {
                                    isNotAvailableDate =
                                        notAvailableDates.any((range) {
                                      return range.startDate != null &&
                                          range.endDate != null &&
                                          (cellDetails.date.isAfter(
                                                      range.startDate!) &&
                                                  cellDetails.date.isBefore(
                                                      range.endDate!) ||
                                              cellDetails.date.isAtSameMomentAs(
                                                  range.startDate!) ||
                                              cellDetails.date.isAtSameMomentAs(
                                                  range.endDate!));
                                    });

                                    if (isNotAvailableDate) {
                                      cellColor = Colors.red;
                                      textColor = whiteColor;
                                    }
                                  }

                                  isSelectedDate = selectedDates.any((range) {
                                    return range.startDate != null &&
                                        range.endDate != null &&
                                        (cellDetails.date.isAfter(
                                                    range.startDate!) &&
                                                cellDetails.date
                                                    .isBefore(range.endDate!) ||
                                            cellDetails.date.isAtSameMomentAs(
                                                range.startDate!) ||
                                            cellDetails.date.isAtSameMomentAs(
                                                range.endDate!));
                                  });

                                  if (isSelectedDate) {
                                    cellColor = orangeColor;
                                    textColor = whiteColor;
                                    cellPrice = '';
                                  }
                                }

                                return Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: cellDetails.date
                                                  .isBefore(DateTime.now())
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
                                              color: cellDetails.date
                                                      .isBefore(DateTime.now())
                                                  ? whiteColor
                                                  : textColor,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          convertToLocaleDigits(
                                              cellPrice.toString()),
                                          style: smallAirBk.copyWith(
                                              fontSize: 8,
                                              color: cellDetails.date
                                                      .isBefore(DateTime.now())
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
                                    return AddPriceOnCommonCalander(
                                      selectedDates: selectedDates,
                                      onPressed: () {
                                        submitMethod(context);
                                      },
                                      selectedAvailableRange:
                                          selectedAvailableRange,
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
                                          style: smallHeadigAirBd.copyWith(
                                              color: whiteColor),
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

  void _showItemListDialog(BuildContext context, List<Items> list) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: notifires.getblackwhitecolor,
          surfaceTintColor: notifires.getblackwhitecolor,
          contentPadding: const EdgeInsets.only(left: 4, right: 4),
          titlePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                width: 10,
              ),
              Text(
                'Select an Item'.tr,
                style: heading1Grey1(context),
              ),
              const Spacer(),
              InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Card(
                    elevation: 5,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: notifires.getboxcolor),
                      child: Icon(
                        size: 20,
                        Icons.close,
                        color: grey1,
                      ),
                    ),
                  ))
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    if (webPlateForm) {
                      Get.to(const BottomHost(
                        initialIndex: 1,
                      ));
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => const BottomHost(
                                    initialIndex: 1,
                                  )));
                    }

                    setState(() {
                      initialitems = list[index];
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: notifires.getboxcolor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                notifires.getGrey3Whitecolor.withOpacity(0.1),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: const Offset(
                                0, 0), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 64,
                              height: 64,
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(10), // Image border
                                child: SizedBox.fromSize(
                                  size: const Size.fromRadius(
                                      180), // Image radius
                                  child: FadeInImage.assetNetwork(
                                    fadeInCurve: Curves.easeInCirc,
                                    placeholder:
                                        "assets/images/ezgif.com-crop.gif",
                                    height: 50,
                                    image: list[index].frontImage == null
                                        ? ''
                                        : "${list[index].frontImage!.thumbnail}",
                                    imageErrorBuilder:
                                        (context, error, stackTrace) {
                                      return getErrorImage();
                                    },
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      list[index].title!.length > 40
                                          ? list[index].title!.substring(0, 39)
                                          : list[index].title!,
                                      style: heading3Grey1(context)),
                                  Text(
                                    list[index].description!.length > 25
                                        ? list[index]
                                            .description!
                                            .substring(0, 24)
                                        : list[index].description!,
                                    style: regular2(context),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
