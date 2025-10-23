import 'dart:convert';
import 'dart:core';
import 'dart:math';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:carvy/controller/add_address_controller.dart';
import 'package:carvy/controller/items_detail_controller.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/model/digital_singnature_model.dart';
import 'package:carvy/model/item_details_model.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import '../api/config.dart';
import '../customwidget/miscellaneous_project_elements.dart';
import '../customwidget/project_color.dart';
import '../helper/http_service.dart';
import '../model/book_date_real_estate.dart';
import '../model/booking_model.dart';
import '../model/calendar_model.dart';
import '../model/get_item_prices.dart';
import '../model/wallet_model.dart';
import '../view/booking/payment_screen.dart';
import '../view/booking/vehicle/vehicle_booking_summary_screen.dart';
import '../work_space.dart';

ItemDetailsController spaceDetailController = Get.find();

class BookingController extends GetxController implements GetxService {
  @override
  void onInit() {
    super.onInit();
    selectedDate = DateTime.now();
    currenttimeSlots = <String>[].obs;
    filteredTimeSlotsEndTime = <String>[].obs;
    avalibleSlots = <String>[];
  }

  int numberofguest = 1;
  bool isChecked = false;
  RxBool isDateAvailale = false.obs;
  bool processing = true;
  RxString endDate = ''.obs;
  RxString startDate = ''.obs;
  RxString datednotAvalibleError = ''.obs;
  final TextEditingController textControllerNotetoOwner =
      TextEditingController();
  final TextEditingController vehicleNoController = TextEditingController();
  final TextEditingController textControllerBookingforSomeone =
      TextEditingController();
  DateRangePickerController dateRangePickerController =
      DateRangePickerController();
  List<DateTime> alreadySelectedList = [];
  List<DateTime> availableDates = [];
  RxBool isDateChecking = false.obs;
  String checkDateMsg = "";
  bool checkDateResult = false;
  bool chack = false;
  bool addDoorStepPrice = false;
  dynamic idFeatured = "";
  RxString curreentStatus = "".obs;
  List availableDatesPrice = [];
  List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  getData(dynamic idFeatured) async {
    BookdDate bookdDate = await bookDateApi(idFeatured: '$idFeatured');
    for (int i = 0; i < bookdDate.data!.itemBookingDate!.length; i++) {
      List<DateTime> daysx = getDaysInBetween(
        DateTime.tryParse(bookdDate.data!.itemBookingDate![i].checkIn!)!,
        DateTime.tryParse(bookdDate.data!.itemBookingDate![i].checkOut!)!,
      );
      alreadySelectedList.addAll(daysx);
    }
    processing = false;
  }

  checkDateApi({
    String? idFeatured,
  }) async {
    error.value = false;

    if (activeModuleId.value != 2 &&
        activeModuleId.value != 3 &&
        activeModuleId.value != 5 &&
        activeModuleId.value != 6 &&
        activeModuleId.value != 4) {
      if (startDate.value == endDate.value) {
        isDateAvailale.value = false;
        endDate.value = "";
        return;
      }
    }
    isDateChecking.value = true;
    try {
      String startTimeForBackend = selectedStartTime.value;
      String endTimeForBackend = selectedEndTime.value;

      if (selectedStartTime.value.contains(RegExp(r'^[0-9]{1,2}:[0-9]{2}$'))) {
        startTimeForBackend = convert24To12(selectedStartTime.value);
        endTimeForBackend = convert24To12(selectedEndTime.value);
      }
      Map map = {
        "item_id": "$idFeatured",
        "check_in": startDate.value,
        "check_out": endDate.value,
        "start_time": startTimeForBackend,
        "end_time": endTimeForBackend,
      };

      var result = await httpPost(Config.checkBookingAvailability, map);

      if (result['status'] == 200 || result['status'] == 422) {
        final data = result["data"];
        if (data != null) {
          if (data["next_start_time"] != null) {
            nextStartTime.value = convert12To24(data["next_start_time"]);
            nextEndTime.value = convert12To24(data["next_end_time"]);
          }

          if (data["availability"] != null) {
            final availability = data["availability"];
            if (availability["next_start_time"] != null) {
              nextStartTime.value =
                  convert12To24(availability["next_start_time"]);
              nextEndTime.value = convert12To24(availability["next_end_time"]);
            }
          }
        }
      }
      if (result['status'] == 422) {
        isDateAvailale.value = false;
        isDateChecking.value = false;
        final bookingDetails = result["data"]?["bookingOverlapDetails"];
        final nextTimeSlot = result["data"]?["next_start_time"];
        if (bookingDetails is List && bookingDetails.isNotEmpty) {
          showBookingOverlapBottomSheet(bookingDetails, nextTimeSlot);
          isDateAvailale.value = true;
        } else {
          isDateAvailale.value = false;
        }
      } else if (result['status'] == 200) {
        isDateChecking.value = false;
        checkDateResult = result["data"]['availability']['is_available'];
        checkDateMsg = result["error"];
        if (checkDateResult) {
          isDateAvailale.value = true;
        } else {
          isDateAvailale.value = false;
          showErrorToastMessage((checkDateMsg.isEmpty
                  ? 'Booking not available at this date'
                  : checkDateMsg)
              .tr);
        }
      } else {
        error.value = true;
        isDateAvailale.value = false;
        datednotAvalibleError.value = result["error"];
        showErrorToastMessage(result["error"]);
      }

      update();
      return result;
    } finally {
      isDateChecking.value = false;
      update();
    }
  }

  int tabIndexOfMybooking = 0;
  var isLoading = false.obs;
  bookDateApi({String? idFeatured}) async {
    isLoading.value = true;
    var response = await httpPost(Config.itemBookingDate, {'id': idFeatured});
    BookdDate result = BookdDate.fromJson(response);
    isLoading.value = false;
    update();
    return result;
  }

  PageController pageControllerslider = PageController();
  final ValueNotifier<int> currentPageSliderNotifier = ValueNotifier<int>(0);
  RxBool showAddCouponBtn = false.obs;
  var isPaymentSuccess = false.obs;
  String currency = "";
  double discount = 0;
  double basePrice = 0;
  double serviceCharge = 0;
  double tax = 0;
  GetItemPrices? getItemPrices;
  WalletModel? walletModel;
  TextEditingController textEditingController = TextEditingController();
  listner() {
    if (textEditingController.text.isNotEmpty) {
      showAddCouponBtn.value = true;
    } else {
      showAddCouponBtn.value = false;
    }
  }

  onWillPop() {
    if (isPaymentSuccess.value == false) {
      Get.back();
      update();
    } else {
      update();
    }
  }

  String convert12To24(String time12) {
    if (time12.isEmpty) return "";
    try {
      String cleanTime = time12.trim().toUpperCase();
      if (!cleanTime.contains(" ")) {
        cleanTime = cleanTime.replaceAllMapped(
            RegExp(r'([0-9])([AP]M)'), (Match m) => '${m[1]} ${m[2]}');
      }
      DateFormat inputFormat = DateFormat('h:mm a');
      DateFormat outputFormat = DateFormat('HH:mm');
      DateTime dateTime = inputFormat.parse(cleanTime);
      return outputFormat.format(dateTime);
    } catch (e) {
      debugPrint('Error converting 12 to 24: $e for time: $time12');
      try {
        String cleanTime = time12.trim().toUpperCase();
        bool isPM = cleanTime.contains('PM');
        String timeWithoutAmPm =
            cleanTime.replaceAll(RegExp(r'[AP]M'), '').trim();

        List<String> parts = timeWithoutAmPm.split(':');
        if (parts.length != 2) return time12;
        int hours = int.tryParse(parts[0]) ?? 0;
        int minutes = int.tryParse(parts[1]) ?? 0;

        if (isPM && hours < 12) {
          hours += 12;
        } else if (!isPM && hours == 12) {
          hours = 0;
        }
        return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
      } catch (e2) {
        debugPrint('Manual conversion also failed: $e2');
        return "00:00";
      }
    }
  }

  String convert24To12(String time24) {
    try {
      DateFormat inputFormat = DateFormat('HH:mm');
      DateFormat outputFormat = DateFormat('h:mm a');
      DateTime dateTime = inputFormat.parse(time24);
      return outputFormat.format(dateTime);
    } catch (e) {
      try {
        List<String> parts = time24.split(':');
        int hours = int.parse(parts[0]);
        int minutes = int.parse(parts[1]);

        String amPm = hours >= 12 ? 'PM' : 'AM';
        int hour12 = hours % 12;
        if (hour12 == 0) hour12 = 12;

        return '$hour12:${minutes.toString().padLeft(2, '0')} $amPm';
      } catch (e) {
        return time24;
      }
    }
  }

  var error = false.obs;
  getDataBookingSummery(
      dynamic idFeatured, coupon, wallet, isAddDoorStepPrice) async {
    error.value = false;
    update();

    String startTimeForBackend = selectedStartTime.value;
    String endTimeForBackend = selectedEndTime.value;

    if (selectedStartTime.value.contains(RegExp(r'^[0-9]{1,2}:[0-9]{2}$'))) {
      startTimeForBackend = convert24To12(selectedStartTime.value);
      endTimeForBackend = convert24To12(selectedEndTime.value);
    }

    Map map = {
      "item_id": "$idFeatured",
      "check_in": "$startDate",
      "check_out": "$endDate",
      "coupon_code": coupon,
      "wallet_amount": "$wallet",
      "start_time": startTimeForBackend,
      "end_time": endTimeForBackend,
      "doorStep_price": "$isAddDoorStepPrice",
    };
    var response = await httpPost(Config.getItemPrices, map);
    if (response != null) {
      if (response['status'] == 200) {
        getItemPrices = GetItemPrices.fromJson(response);
      } else {
        error.value = true;
        showErrorToastMessage(response['error']);
        update();
      }
    }
  }

  getWalletData() async {
    error.value = false;
    update();
    var resp = await httpPost(Config.getUserWallet, {});
    if (resp != null) {
      walletModel = WalletModel.fromJson(resp);
      if (walletModel!.status == 200) {
      } else {
        error.value = true;
        update();
        showErrorToastMessage(walletModel!.error);
      }
    }
  }

  bookingMainFunction(
      itemId,
      totalDayNight,
      price,
      bookingForSomeOne,
      hostId,
      numberofguest,
      addDoorStepPrice,
      itemType,
      image,
      itemDetail,
      address,
      rating,
      tittle,
      [meta]) async {
    if (error.value == true) {
      showCustomSnackbar(
        title: 'Token does not match'.tr,
        message: 'Please login again'.tr,
        color: redColor,
        contentType: ContentType.warning,
      );
      return;
    }
    showLoading();
    dynamic couponCode;
    if (getItemPrices!.data!.couponCode == null) {
      couponCode = "";
    } else {
      couponCode = getItemPrices!.data!.couponCode;
    }
    var result = await bookMethod(
        "$itemId",
        startDate.value,
        endDate.value,
        "${totalDayNight - 1}",
        "$price",
        bookingForSomeOne,
        "${getItemPrices!.data!.priceBeforeDiscount}",
        getItemPrices!.data!.serviceCharge!,
        "0",
        getItemPrices!.data!.tax!,
        getItemPrices!.data!.grossPrice!,
        currency,
        'stripe',
        getItemPrices!.data!.walletAmount!.toString(),
        hostId,
        "$numberofguest",
        couponCode,
        getItemPrices!.data!.discountPrice!.toString(),
        getItemPrices!.data!.couponDiscount!.toString(),
        getItemPrices!.data!.discountType!,
        getItemPrices!.data!.cleaningCharge!.toString(),
        addDoorStepPrice.toString(),
        meta);
    closeLoading();

    if (result != null) {
      if (result['data'] != null) {
        var paymentUrl = result['data']['payment_url'];
        var bookingId = result['data']['booking_id'];
        if (paymentUrl is String && bookingId is int) {
          if (webPlateForm) {
            Get.toNamed(WebRoutes.paymentScreen, arguments: {
              "url": paymentUrl,
              "bookingId": bookingId.toString(),
            })?.then((value) {
              if (value != null && value == "Paid") {
                update();
                isPaymentSuccess.value = true;
              } else {
                update();
                isPaymentSuccess.value = false;
              }
            });
          } else {
            Get.offAll(() => PaymentScreen(
                  title: tittle,
                  rating: rating,
                  address: address,
                  itemDetails: itemDetail,
                  frontImage: image,
                  itemType: itemType,
                  isAddDoorStepPrice: addDoorStepPrice.toString(),
                  idFeatured: itemId,
                  fromBooking: true,
                  price: getItemPrices!.data!.grossPrice!,
                  url: paymentUrl,
                  bookingId: bookingId.toString(),
                ))?.then((value) {
              if (value == null) {
                return;
              }
              if (value == "Paid") {
                update();
                isPaymentSuccess.value = true;
              } else {
                update();
                isPaymentSuccess.value = false;
              }
            });
          }
        } else {}
      }
    }
  }

  bookMethod(
      String itemId,
      String checkIn,
      String checkOut,
      String totalDayNight,
      String pernight,
      String bookfor,
      String basePrice,
      String serviceCharge,
      String serviceMoney,
      String ivaText,
      String total,
      String currencyCode,
      String paymentMethod,
      String wallAmount,
      String hostId,
      String totalGuest,
      String couponCode,
      String discountPrice,
      String couponDiscount,
      String discountType,
      String cleaningCharges,
      String addDoorStepPrice,
      dynamic meta) async {
    meta ??= "";
    String startTimeForBackend = selectedStartTime.value;
    String endTimeForBackend = selectedEndTime.value;

    if (selectedStartTime.value.contains(RegExp(r'^[0-9]{1,2}:[0-9]{2}$'))) {
      startTimeForBackend = convert24To12(selectedStartTime.value);
      endTimeForBackend = convert24To12(selectedEndTime.value);
    }
    Map map = {
      "item_id": itemId,
      "check_in": checkIn,
      "check_out": checkOut,
      "total_day": totalDayNight,
      "per_day": pernight,
      "book_for": bookfor,
      "base_price": basePrice,
      "service_charge": serviceCharge,
      "security_money": serviceCharge,
      "iva_tax": ivaText,
      "total": total,
      "currency_code": currencyCode,
      "payment_method": paymentMethod,
      "wall_amt": wallAmount,
      "host_id": hostId,
      "total_guest": totalGuest,
      "coupon_code": couponCode,
      "discount_price": discountPrice,
      "coupon_discount": couponDiscount,
      "discount_type": discountType,
      "cleaning_charges": cleaningCharges,
      "start_time": startTimeForBackend,
      "end_time": endTimeForBackend,
      "onlinepayment": "$paymentStatus",
      "doorStep_price": addDoorStepPrice,
      "doorStep_address": addDoorStepPrice != "0" ? doorStepAddress() : "",
      "meta": meta,
    };

    var response = await httpPost(Config.bookItem, map);
    if (response != null) {
      if (response['status'] == 200) {
      } else {
        showErrorToastMessage("${response['error']}");
      }
    }
    return response;
  }

  var isenqablestarttime = false.obs;
  var isenableendTime = false.obs;
  RxString selectedStartTime = "".obs;
  RxString selectedEndTime = "".obs;
  RxString hindTimeStart = "".obs;
  RxString hindTimeSEnd = "".obs;
  RxInt currentdatebool = 1.obs;
  RxInt currentdateboospace = 1.obs;

  bool isEndTimeBeforeStartTime(String startTime, String endTime) {
    bool is24HourFormat =
        startTime.contains(RegExp(r'^[0-9]{1,2}:[0-9]{2}$')) &&
            endTime.contains(RegExp(r'^[0-9]{1,2}:[0-9]{2}$'));

    if (is24HourFormat) {
      DateFormat dateFormat = DateFormat('HH:mm');
      DateTime startTimeDateTime = dateFormat.parse(startTime);
      DateTime endTimeDateTime = dateFormat.parse(endTime);
      return endTimeDateTime.isBefore(startTimeDateTime) ||
          endTimeDateTime == startTimeDateTime;
    } else {
      DateFormat dateFormat = DateFormat('h:mm a');
      DateTime startTimeDateTime = dateFormat.parse(startTime);
      DateTime endTimeDateTime = dateFormat.parse(endTime);
      return endTimeDateTime.isBefore(startTimeDateTime) ||
          endTimeDateTime == startTimeDateTime;
    }
  }

  commonNavigateToBookingSummary(BuildContext context, idFeatured, itemDetails,
      address, frontimage, title, rating, itemtypes, price, addDoorStepPrice) {
    chack == true;
    if (startDate.value.isEmpty || endDate.value.isEmpty) {
      showErrorToastMessage("Select date to continue".tr);

      return;
    }

    if (selectedStartTime.value == "") {
      showErrorToastMessage("Select Start  time to continue".tr);
      return;
    }
    if (selectedEndTime.value == "") {
      showErrorToastMessage("Select  End time to continue".tr);
      return;
    }
    if (startDate.value == endDate.value) {
      if (isEndTimeBeforeStartTime(
          selectedStartTime.value, selectedEndTime.value)) {
        showErrorToastMessage("End time must be after Start time".tr);
        return;
      }
    }

    List totalNight = getDaysInBetween(
      DateTime.tryParse(startDate.value)!,
      DateTime.tryParse(endDate.value)!,
    );
    if (webPlateForm) {
      Get.toNamed(WebRoutes.vehicleBookingSummaryScreen, arguments: {
        "idFeatured": idFeatured,
        "totalNight": totalNight.length,
        "itemDetails": itemDetails,
        "address": address,
        "rating": rating,
        "title": title,
        "frontImage": frontimage,
        "itemType": itemtypes,
        "price": price,
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VehicleBookingSummary(
              idFeatured: idFeatured,
              totalNight: totalNight.length,
              itemDetails: itemDetails,
              address: address,
              rating: rating,
              title: title,
              frontImage: frontimage,
              itemType: itemtypes,
              price: price,
              isAddDoorStepPrice: addDoorStepPrice),
        ),
      );
    }
  }

  late DateTime selectedDate;
  late RxList<String> currenttimeSlots;
  late RxList<String> filteredTimeSlots;
  late RxList<String> filteredTimeSlotsEndTime;
  late List<String> avalibleSlots;
  RxString checkTheSelectedStartDate = "".obs;
  RxString checkTheSelectedEndDate = "".obs;
  bool isBetween(DateTime startTime, DateTime endTime) {
    DateTime currentTime = DateTime.now();
    if (currentTime.isAfter(startTime) && currentTime.isBefore(endTime)) {
      return true;
    }
    return false;
  }

  DateTime convertToDateTime(String timeString) {
    try {
      DateFormat format = DateFormat('HH:mm');
      return format.parse(timeString);
    } catch (e) {
      List<String> parts = timeString.split(':');
      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);
      return DateTime(1, 1, 1, hours, minutes);
    }
  }

  List<String> getManualTimeSlots24() {
    return [
      '00:30',
      '01:00',
      '01:30',
      '02:00',
      '02:30',
      '03:00',
      '03:30',
      '04:00',
      '04:30',
      '05:00',
      '05:30',
      '06:00',
      '06:30',
      '07:00',
      '07:30',
      '08:00',
      '08:30',
      '09:00',
      '09:30',
      '10:00',
      '10:30',
      '11:00',
      '11:30',
      '12:00',
      '12:30',
      '13:00',
      '13:30',
      '14:00',
      '14:30',
      '15:00',
      '15:30',
      '16:00',
      '16:30',
      '17:00',
      '17:30',
      '18:00',
      '18:30',
      '19:00',
      '19:30',
      '20:00',
      '20:30',
      '21:00',
      '21:30',
      '22:00',
      '22:30',
      '23:00',
      '23:30'
    ];
  }

  List<String> generateTimeSlots(DateTime selectedDate) {
    currenttimeSlots.clear();
    DateTime currentTime = DateTime.now();
    if (selectedDate.year == currentTime.year &&
        selectedDate.month == currentTime.month &&
        selectedDate.day == currentTime.day) {
      int remainingMinutes = 30 - (currentTime.minute % 30);
      currentTime = currentTime.add(Duration(minutes: remainingMinutes));
      DateTime endDate = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        23,
        59,
      );
      if (currentTime.hour == 23 && currentTime.minute >= 30) {
        return [];
      }
      while (currentTime.isBefore(endDate) ||
          currentTime.isAtSameMomentAs(endDate)) {
        String formattedTime = DateFormat('HH:mm').format(currentTime);
        currenttimeSlots.add(formattedTime);
        currentTime = currentTime.add(const Duration(minutes: 30));
      }
      return currenttimeSlots;
    } else {
      return getManualTimeSlots24();
    }
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  DateTime? _lastSelectionTime;
  DateTime? _lastAlertTime;
  final Duration _alertDebounceDuration = const Duration(minutes: 2);
  final Duration _debounceDuration = const Duration(milliseconds: 300);
  DateTime? previousStartDate;
  DateTime? previousEndDate;
  var nextStartTime = "".obs;
  var nextEndTime = "".obs;
  var handleTimeSlotsOnCurrentDate = false.obs;
  DateTime? _lastSnackbarShownTime;
  final Duration _snackbarDebounceDuration = const Duration(minutes: 1);

  void onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    selectedStartTime.value = "";
    nextStartTime.value = "";
    nextEndTime.value = "";
    selectedEndTime.value = "";
    hindTimeStart.value = "";
    hindTimeSEnd.value = "";
    isDateAvailale.value = false;
    handleTimeSlotsOnCurrentDate.value = false;
    avalibleSlots.clear();
    update();
    final now = DateTime.now();
    if (_lastSelectionTime != null &&
        now.difference(_lastSelectionTime!) < _debounceDuration) {
      return;
    }
    _lastSelectionTime = now;
    if (args.value is PickerDateRange) {
      final DateTime? selectedStartDate = args.value.startDate as DateTime?;
      final DateTime? selectedEndDate = args.value.endDate as DateTime?;
      bool isStartDateAvailable = selectedStartDate != null &&
          availableDates.contains(selectedStartDate);
      bool isEndDateAvailable =
          selectedEndDate != null && availableDates.contains(selectedEndDate);
      if (!isStartDateAvailable ||
          (selectedEndDate != null && !isEndDateAvailable)) {
        _showUnavailableDateError(now);
        return;
      }
      if (selectedEndDate == null) {
        if (isStartDateAvailable) {
          startDate.value = DateFormat('yyyy-MM-dd').format(selectedStartDate);
          endDate.value = DateFormat('yyyy-MM-dd').format(selectedStartDate);
          previousStartDate = selectedStartDate;
          previousEndDate = selectedStartDate;
        } else {
          _showUnavailableDateError(now);
          startDate.value = previousStartDate != null
              ? DateFormat('yyyy-MM-dd').format(previousStartDate!)
              : '';
          endDate.value = previousEndDate != null
              ? DateFormat('yyyy-MM-dd').format(previousEndDate!)
              : '';
          return;
        }
      } else {
        if (isStartDateAvailable && isEndDateAvailable) {
          startDate.value = DateFormat('yyyy-MM-dd').format(selectedStartDate);
          endDate.value = DateFormat('yyyy-MM-dd').format(selectedEndDate);
          previousStartDate = selectedStartDate;
          previousEndDate = selectedEndDate;
        } else {
          _showUnavailableDateError(now);
          startDate.value = previousStartDate != null
              ? DateFormat('yyyy-MM-dd').format(previousStartDate!)
              : '';
          endDate.value = previousEndDate != null
              ? DateFormat('yyyy-MM-dd').format(previousEndDate!)
              : '';
          return;
        }
      }
      bool isStartDateToday = isToday(selectedStartDate);
      if (isStartDateToday) {
        DateTime startTime = DateTime(now.year, now.month, now.day, 23, 01);
        DateTime endTime = DateTime(now.year, now.month, now.day, 23, 59);
        bool isBetweenTimeRange = isBetween(startTime, endTime);
        if (isBetweenTimeRange) {
          if (_lastSnackbarShownTime == null ||
              now.difference(_lastSnackbarShownTime!) >
                  _snackbarDebounceDuration) {
            _lastSnackbarShownTime = now;
            showCustomSnackbar(
              title: 'Booking Unavailable'.tr,
              message:
                  'You cannot book the vehicle between 23:01 and 23:59.'.tr,
              color: redColor,
              contentType: ContentType.warning,
            );
          }
          currenttimeSlots.clear();
          avalibleSlots.clear();
          update();
          return;
        }
      }
      checkDateApi(idFeatured: '$idFeatured').then((value) {
        if (value != null && value["data"] != null) {
          print("1");
          if (value["data"]["next_start_time"] != null) {
            print("2");
            nextStartTime.value =
                convert12To24(value["data"]["next_start_time"]);
            nextEndTime.value = convert12To24(value["data"]["next_end_time"]);
            debugPrint(
                'next_available_time_on_checkout: ${nextStartTime.value}');
          } else {
            print("3");
            nextStartTime.value = "00:00";
            nextEndTime.value = "11:30";
            debugPrint(
                'next_available_time_on_checkout is null, using fallback: ${nextStartTime.value}');
          }
          if (value["data"]["availability"] != null &&
              value["data"]["availability"]["next_start_time"] != null) {
            print("4");
            nextStartTime.value =
                convert12To24(value["data"]["availability"]["next_start_time"]);
            nextEndTime.value =
                convert12To24(value["data"]["availability"]["next_end_time"]);
            debugPrint(
                'next_start_time from availability: ${nextStartTime.value}');
          }
          if (isToday(selectedStartDate)) {
            print("5");
            compareAndGenerateSlots(
                selectedStartDate, nextStartTime.value, nextEndTime.value);
          } else {
            if (startDate.value == endDate.value) {
              curreentStatus.value = "SameDate";
              filterTimeSlotsfunctionSameDate(
                  nextStartTime.value, nextEndTime.value);
            } else {
              print("6");
              filterTimeSlotsfunctionSameDate(
                  nextStartTime.value, nextEndTime.value);
              curreentStatus.value = "otherDates";
            }
          }
          setDefaultTime();
          update();
        } else {
          print("7");
          showErrorToastMessage(
              "Failed to fetch availability. Please try again.");
        }
      }).catchError((error) {
        print("8");
        debugPrint('Error in checkDateApi: $error');
        showErrorToastMessage(
            "An error occurred while checking availability.".tr);
        nextStartTime.value = "00:00";
        nextEndTime.value = "23:30";
        update();
      });
      update();
    }
  }

void compareAndGenerateSlots(
    DateTime selectedStartDate, String nextStartTime, String nextEndTime) {
  DateTime parsedNextStartTime;
  if (nextStartTime.contains(RegExp(r'^[0-9]{1,2}:[0-9]{2}$'))) {
    DateFormat dateFormat24 = DateFormat('HH:mm');
    parsedNextStartTime = dateFormat24.parse(nextStartTime);
  } else {
    DateFormat dateFormat12 = DateFormat('h:mm a');
    parsedNextStartTime = dateFormat12.parse(nextStartTime);
  }

  DateTime nextStartTimeWithToday = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    parsedNextStartTime.hour,
    parsedNextStartTime.minute,
  );
  DateTime currentTime = DateTime.now();
   print("kljl${currentTime}");
  if (currentTime.isAfter(nextStartTimeWithToday)) {
    handleTimeSlotsOnCurrentDate.value = true;
    curreentStatus.value = "CurrentDate";
    generateTimeSlots(selectedStartDate);
  } else {
    curreentStatus.value = "CurrentDate";
    filterTimeSlotsfunctionSameDate(nextStartTime, nextEndTime);
  }
  update();
}


  void _showUnavailableDateError(DateTime now) {
    if (_lastAlertTime == null ||
        now.difference(_lastAlertTime!) >= _alertDebounceDuration) {
      showCustomSnackbar(
        title: 'Date Unavailable',
        message: 'The selected date is not available for booking.',
        color: Colors.red,
        contentType: ContentType.warning,
      );
      _lastAlertTime = now;
    }
  }

  List<String> filterTimeSlotsfunctionSameDate(
      String startTimeString, String endTimeString) {
    filteredTimeSlotsEndTime.clear();
    update();
    List<String> manualTimeSlots = getManualTimeSlots24();

    DateTime startTime = convertToDateTime(startTimeString);
    DateTime endTime = convertToDateTime(endTimeString);
    int startIndex = manualTimeSlots
        .indexWhere((slot) => convertToDateTime(slot).isAfter(startTime));
    if (startIndex == -1) {
      startIndex = manualTimeSlots.length;
    }
    int endIndex = manualTimeSlots
        .lastIndexWhere((slot) => convertToDateTime(slot).isBefore(endTime));
    if (endIndex == -1) {
      endIndex = 0;
    }
    if (startIndex > endIndex) {
      int temp = startIndex;
      startIndex = endIndex;
      endIndex = temp;
    }

    filteredTimeSlotsEndTime.value = manualTimeSlots.sublist(
        max(0, startIndex), min(manualTimeSlots.length, endIndex + 1));
    update();
    return filteredTimeSlotsEndTime;
  }

  clearMethod() {
    isDateAvailale.value = false;
    startDate.value = "";
    endDate.value = "";
    dateRangePickerController.selectedRange = null;
    selectedStartTime.value = "";
    selectedEndTime.value = "";
    hindTimeStart.value = "";
    hindTimeSEnd.value = "";
    isenqablestarttime.value = false;
    isenableendTime.value = false;
    vehicleNoController.clear();
    update();
  }

  String commonMetaData() {
    Map<String, dynamic> map = {
      "vehicle_no": vehicleNoController.text,
      "host_message": textControllerNotetoOwner.text,
    };

    String jsonString = jsonEncode(map);
    return jsonString;
  }

  void setDefaultTime() {
    List<String> startSlots = getSlotsStartTime();
    if (startSlots.isNotEmpty) {
      selectedStartTime.value = startSlots.first;
      isenqablestarttime.value = true;
    }

    List<String> endSlots = getSlotsEndTime();
    if (endSlots.isNotEmpty) {
      selectedEndTime.value = endSlots.last;
      isenableendTime.value = true;
    }
  }

  List<String> getSlotsStartTime() {
    switch (curreentStatus.value) {
      case "CurrentDate":
        if (handleTimeSlotsOnCurrentDate.value == true) {
          return currenttimeSlots;
        } else {
          return filteredTimeSlotsEndTime;
        }

      case "SameDate":
        return filteredTimeSlotsEndTime;
      case "otherDates":
        return filteredTimeSlotsEndTime;
      default:
        return getManualTimeSlots24();
    }
  }

  List<String> getSlotsEndTime() {
    switch (curreentStatus.value) {
      case "CurrentDate":
        if (startDate.value == endDate.value) {
          if (handleTimeSlotsOnCurrentDate.value == true) {
            return currenttimeSlots;
          } else {
            return filteredTimeSlotsEndTime;
          }
        } else {
          return getManualTimeSlots24();
        }
      case "SameDate":
        return filteredTimeSlotsEndTime;
      case "otherDates":
        if (startDate.value == endDate.value) {
          return filteredTimeSlotsEndTime;
        } else {
          return getManualTimeSlots24();
        }
      default:
        return getManualTimeSlots24();
    }
  }

  Widget startTime() {
    return Expanded(
      child: Obx(
        () => TimePickerPopup(
          hintText: "Start time".tr,
          timesList: getSlotsStartTime(),
          initialValue: selectedStartTime.value.isNotEmpty
              ? selectedStartTime.value
              : null,
          onSelected: (value) {
            isenqablestarttime.value = true;
            selectedStartTime.value = value;
            List<String> endSlots = getSlotsEndTime();
            int startIndex = getSlotsStartTime().indexOf(value);
            int endIndex = startIndex + 3;
            if (endIndex < endSlots.length) {
              selectedEndTime.value = endSlots[endIndex];
            } else {
              selectedEndTime.value = endSlots.last;
            }
            isenableendTime.value = true;
          },
          checkmarkColor: themeColor,
          format24Hour: true,
        ),
      ),
    );
  }

  Widget endTime() {
    return Expanded(
      child: Obx(
        () => TimePickerEndTime(
          hintText: "End time".tr,
          timesList: getSlotsEndTime(),
          initialValue:
              selectedEndTime.value.isNotEmpty ? selectedEndTime.value : null,
          onSelected: (value) {
            isenableendTime.value = true;
            selectedEndTime.value = value;
          },
          checkmarkColor: themeColor,
          format24Hour: true,
        ),
      ),
    );
  }

  String doorStepAddress() {
    AddAddressController addAddressController = Get.find();
    Map<String, dynamic> map = {
      "house_floor_number":
          addAddressController.houseFloorNumberController.text,
      "building_block_number":
          addAddressController.buildingBlockNumberController.text,
      "landmark": addAddressController.landmarkController.text,
      "full_address": addAddressController.fullAddressController.text,
      "city": addAddressController.cityController.text,
      "state": addAddressController.stateController.text,
      "country": addAddressController.countryController.text,
      "postal_code": addAddressController.postalCodeController.text,
      "doorstep_latitude": addAddressController.doorSteplatitude.value,
      "doorstep_longitude": addAddressController.doorSteplongitude.value,
    };
    String jsonString = jsonEncode(map);
    return jsonString;
  }

  String? vehicleType;
  String? vehicleModel;
  String? vehicleMake;
  String? vehicleYear;
  String? vehicleTransmission;
  String? vehicleOdometer;
  String? address;
  String? bookingTypeDetail;
  String? dateStart;
  String? bookingDetailType;
  String? bookingDetailMake;
  String? bookingDateStart;
  String? bookingDateEnd;
  String? jsonItemData;
  String? bookingType;
  String? boiatType;
  String? boatLength;
  String? boatYear;
  String? parkingType;

  void moduleBasedData({required Bookings bookings}) {
    String? bookingMeta = bookings.bookingMeta;
    String jsonItemData = bookings.itemData;
    List<dynamic> decodedData = jsonDecode(jsonItemData);
    if (bookingMeta != null) {
      bookingMetaList = json.decode(bookingMeta);
    }
    bookingDateStart = "Trip Start";
    bookingDateEnd = "Trip end";
    bookingDateStart = "Trip Start";
    bookingDateEnd = "Trip end";
    bookingTypeDetail = "Vehicle Details";
    bookingDetailMake = "Model";
    bookingDetailType = "Type";
    bookingType = "Year";
    String itemInfoString = decodedData[0]['item_info'] ?? "";
    Map<String, dynamic> itemInfoVehicle = jsonDecode(itemInfoString);
    vehicleType = itemInfoVehicle['vehicleType'] ?? '';
    vehicleModel = itemInfoVehicle['model'] ?? '';
    vehicleMake = itemInfoVehicle['make_type'] ?? '';
    vehicleYear = itemInfoVehicle['year'] ?? '';
    vehicleTransmission = itemInfoVehicle['transmission'] ?? '';
    vehicleOdometer = itemInfoVehicle['odometer'] ?? '';
    address = decodedData[0]['address'] ?? "";
  }

  CalendarItemId? calendarItemId;
  ItemDates? itemDates;
  Future<void> fetchDataCalendar(id) async {
    isLoading.value = true;
    var response =
        await httpGet(Config.getItemDates, {"item_id": id.toString()});
    if (response != null) {
      calendarItemId = CalendarItemId.fromJson(response);
      if (calendarItemId != null && calendarItemId!.data != null) {
        itemDates = calendarItemId!.data!.itemDates;
        if (itemDates != null) {
          if (itemDates!.availableDates != null) {
            String jsonString = jsonEncode(itemDates!.availableDates!);
            List jsonList = jsonDecode(jsonString);
            isLoading.value = false;
            if (jsonList.isNotEmpty) {
              for (var x in jsonList) {
                availableDates.add(DateTime.parse(x["date"]));
                availableDatesPrice.add(x["price"]);
              }
            }
          }
          if (itemDates!.bookedDates != null) {
            String jsonString = jsonEncode(itemDates!.bookedDates!);
            List jsonList = jsonDecode(jsonString);
            isLoading.value = false;
            if (jsonList.isNotEmpty) {
              for (var x in jsonList) {
                alreadySelectedList.add(DateTime.parse(x["date"]));
              }
            }
          }
        }
      }
    }
  }

  final TextEditingController otpController = TextEditingController();
  final TextEditingController dropOtpController = TextEditingController();
  var showhideisReturn = false.obs;
  var dropoffshowHise = false.obs;
  Future<String> updateItemReceivedStatus({required String bookingId}) async {
    showhideisReturn.value = false;
    showLoading();
    String result = "no";
    try {
      var response = await httpPost(Config.updateItemReceivedStatus, {
        "booking_id": bookingId,
        "is_item_received": "1",
        "pick_otp": otpController.text
      });
      closeLoading();
      if (response["status"] == 200) {
        String? isItemReceived =
            response["data"]["booking_extension"]["is_item_received"];
        if (isItemReceived == "1") {
          showhideisReturn.value = true;
          result = "yes";
          update();
        }
      } else {
        showErrorToastMessage(response['error']);
      }
    } catch (e) {
      closeLoading();
      showErrorToastMessage("Something went wrong, please try again.");
    }
    update();
    return result;
  }

  Future<String> updateItemDeliverStatus({required String bookingId}) async {
    dropoffshowHise.value = false;
    showLoading();
    String result = "error";
    try {
      var response = await httpPost(Config.updateItemReturnedStatus, {
        "booking_id": bookingId,
        "is_item_returned": "1",
        "drop_otp": dropOtpController.text,
      });
      closeLoading();
      if (response["status"] == 200) {
        var isItemDelivered =
            response["data"]["booking_extension"]["is_item_delivered"];
        showToastMessage(response["message"]);
        result = isItemDelivered == "1" ? "no" : "yes";
        dropoffshowHise.value = true;
        update();
      } else {
        showErrorToastMessage(response['error']);
      }
    } catch (e) {
      closeLoading();
      print("Error in OTP verification: $e");
      showErrorToastMessage("OTP verification failed.");
    }
    return result;
  }

  clearBookingData() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      showhideisReturn.value = false;
      dropoffshowHise.value = false;
      otpController.clear();
      dropOtpController.clear();
      update();
    });
  }

  Future<void> updateBookingStatusIfExists({
    required String bookingId,
    required String hostId,
    required String userId,
    required String newStatus,
  }) async {
    try {
      final database = FirebaseDatabase.instance.ref().child("chatList");
      final currentUserChatRef =
          database.child(userId).child("${bookingId}_$hostId");
      final currentUserChatSnapshot = await currentUserChatRef.once();
      final hostUserChatRef =
          database.child(hostId).child("${bookingId}_$userId");
      final hostUserChatSnapshot = await hostUserChatRef.once();
      if (currentUserChatSnapshot.snapshot.exists) {
        await currentUserChatRef.update({'bookingStatus': newStatus});
        print("Updated booking status to $newStatus for user: $userId");
      } else {
        print("Chat node does not exist for user: $userId, skipping update");
      }
      if (hostUserChatSnapshot.snapshot.exists) {
        await hostUserChatRef.update({'bookingStatus': newStatus});
        print("Updated booking status to $newStatus for host: $hostId");
      } else {
        print("Chat node does not exist for host: $hostId, skipping update");
      }
    } catch (e) {
      print("Error updating booking status: $e");
    }
  }

  SignatureDataResponse? signatureDataResponse;
  Future<SignatureDataResponse?> singnatureApi(
      String id, bool showloading) async {
    if (showloading == true) {
      showLoading();
    }
    signatureDataResponse = null;
    try {
      var responce =
          await httpGet(Config.getDigitalSingnature, {"booking_id": "${id}"});
      if (responce != null && responce["success"] == 200) {
        signatureDataResponse = SignatureDataResponse.fromJson(responce);
        if (showloading == true) {
          closeLoading();
        }
        return signatureDataResponse;
      } else {
        if (showloading == true) {
          closeLoading();
        }
        return null;
      }
    } catch (e) {
      print('Error fetching signature data: $e');
      if (showloading == true) {
        closeLoading();
      }
      return null;
    }
  }

  Future<String> updateItemDeliverStatusHost(
      {required String bookingId}) async {
    var isItemDelivered;
    String result;
    var response = await httpPost(Config.updateItemDeliveredStatus,
        {"booking_id": bookingId, "is_item_delivered": "1"});
    if (response["status"] == 200) {
      isItemDelivered =
          response["data"]["booking_extension"]["is_item_delivered"];
      showToastMessage(response["message"]);
      result = isItemDelivered == "1" ? "no" : "yes";
    } else {
      showErrorToastMessage(response['error']);
      result = "yes";
    }
    return result;
  }
}
