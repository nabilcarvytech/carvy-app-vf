import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/model/odometer_model.dart';
import 'package:carvy/model/items_model.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import 'package:carvy/view/search/vehicle/vehicle_filter.dart';
import '../api/config.dart';
import '../customwidget/custom_active_module_id_widget.dart';
import '../customwidget/miscellaneous_project_elements.dart';
import '../helper/http_service.dart';
import '../model/amenities_model.dart';
import '../model/make_type_model.dart';
import '../model/item_type_model.dart';
import '../model/fuel_type_model.dart';
import '../model/transmission_model.dart'; // NOUVEAU: Import du modèle Transmission
import '../view/search/after_search.dart';
import '../work_space.dart';
import 'package:uuid/uuid.dart';

class SearchControllerHome extends GetxController implements GetxService {
  RxString globalItemType = '0'.obs;
  RxString globalItemTypNamee = "".obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var isLoadingSpace = false.obs;
  var showHide = false.obs;
  RxBool datePopup = false.obs;
  bool hitApiOnMap = false;
  bool aftersearch = false;
  var desildetoSendparametersBasedOnPage = false.obs;
  clearMethod() {
    generalScopeController.citySelected = null;
    generalScopeController.textEditingControllerCity.text = "";
    generalScopeController.startDate.value = "";
    generalScopeController.endDate.value = "";
    generalScopeController.numberOfGuest.value = 1;
    generalScopeController.dateRangePickerController.selectedRange = null;
    generalScopeController.dateRangePickerControllerCustom.selectedRange = null;
    showHide.value = true;
    update();
  }

  num offset = 0;

  void searchMethod(
      BuildContext context, Prediction selectedPrediction, String sLat, slong) {
    Navigator.pop(context);
    if (webPlateForm) {
      Get.toNamed(
        WebRoutes.afterSearch,
        arguments: {
          'checkIn': generalScopeController.startDate.value,
          'checkout': generalScopeController.endDate.value,
          'guest': generalScopeController.numberOfGuest.value.toString(),
          'cityName': selectedPrediction.description,
          'mode': true
        },
      );
    } else {
      Get.to(
        AfterSearch(
          checkIn: generalScopeController.startDate.value,
          checkout: generalScopeController.endDate.value,
          guest: generalScopeController.numberOfGuest.value.toString(),
          cityName: selectedPrediction.description,
          mode: true,
        ),
      );
    }
    update();
  }

  String? from;
  String? to;
  String? numberofPeople;

  void dataChangedBasedOnModuleid() {
    if (activeModuleId.value == 1) {
      from = "Check in";
      to = "Check Out";
      numberofPeople = " Number of Guest";
    } else if (activeModuleId.value == 2) {
      from = "Trip Start";
      to = "Trip end";
    } else if (activeModuleId.value == 3 ||
        activeModuleId.value == 5 ||
        activeModuleId.value == 6 ||
        activeModuleId.value == 4) {
      from = "From date";
      numberofPeople = " Number of People";
      to = "To date";
    }
  }

  RxString startDate = ''.obs;
  RxString endDates = ''.obs;
  @override
  void onInit() {
    super.onInit();
    selectedDate = DateTime.now();
    currenttimeSlots = <String>[].obs;
    filteredTimeSlotsEndTime = <String>[].obs;
    avalibleSlots = <String>[];
  }

  late DateTime selectedDate;
  late RxList<String> currenttimeSlots;
  late RxList<String> filteredTimeSlots;
  late RxList<String> filteredTimeSlotsEndTime;
  late List<String> avalibleSlots;
  RxString curreentStatus = "".obs;
  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  RxString startTimeSearch = ''.obs;
  RxString endTimeSearch = ''.obs;
  DateRangePickerController dateRangePickerControllerCustom =
      DateRangePickerController();
  String convert12To24(String time12) {
    DateFormat inputFormat = DateFormat('h:mm a');
    DateFormat outputFormat = DateFormat('HH:mm');
    DateTime dateTime = inputFormat.parse(time12);
    return outputFormat.format(dateTime);
  }

  String convert24To12(String time24) {
    DateFormat inputFormat = DateFormat('HH:mm');
    DateFormat outputFormat = DateFormat('h:mm a');
    DateTime dateTime = inputFormat.parse(time24);
    return outputFormat.format(dateTime);
  }

  void setDefaultDates({
    required RxString startDateCustomDate,
    required RxString endDateCustomDate,
    required RxString startDate,
    required RxString endDates,
  }) {
    DateTime currentDate = DateTime.now();
    DateTime futureDate = currentDate.add(const Duration(days: 2));
    startDateCustomDate.value = DateFormat('yyyy-MM-dd').format(currentDate);
    endDateCustomDate.value = DateFormat('yyyy-MM-dd').format(futureDate);
    startDate.value = DateFormat('MMM d, EEE').format(currentDate);
    endDates.value = DateFormat('MMM d, EEE').format(futureDate);
    dateRangePickerControllerCustom.selectedRange =
        PickerDateRange(currentDate, futureDate);
    DateTime parsedStart =
        DateFormat('yyyy-MM-dd').parse(startDateCustomDate.value);
    DateTime parsedEnd =
        DateFormat('yyyy-MM-dd').parse(endDateCustomDate.value);
    startTimeSearch.value = "00:30";
    endTimeSearch.value = "23:30";
    if (isToday(parsedStart)) {
      handleCurrentDateSelection(parsedStart, parsedEnd);
    } else {
      handleOtherDateSelection(parsedStart, parsedEnd);
    }
  }

  void onSelectionChangedCustomDatePicker(
      DateRangePickerSelectionChangedArgs args) {
    startDate.value = '';
    endDates.value = '';
    startTimeSearch.value = '';
    endTimeSearch.value = '';
    avalibleSlots.clear();
    update();
    if (args.value is PickerDateRange) {
      final PickerDateRange range = args.value;
      final DateTime startDateTime = range.startDate!;
      final DateTime endDateTime = range.endDate ?? startDateTime;
      generalScopeController.startDateCustomDate.value =
          DateFormat('yyyy-MM-dd').format(startDateTime);
      generalScopeController.endDateCustomDate.value =
          DateFormat('yyyy-MM-dd').format(endDateTime);
      startDate.value = DateFormat('MMM d, EEE').format(startDateTime);
      endDates.value = DateFormat('MMM d, EEE').format(endDateTime);
      GetStorage().write("startDate", startDate.value);
      GetStorage().write("endDates", endDates.value);
      final DateTime today = DateTime.now();
      final DateTime normalizedStart =
          DateTime(startDateTime.year, startDateTime.month, startDateTime.day);
      final DateTime normalizedToday =
          DateTime(today.year, today.month, today.day);
      if (normalizedStart == normalizedToday) {
        handleCurrentDateSelection(startDateTime, endDateTime);
      } else {
        handleOtherDateSelection(startDateTime, endDateTime);
      }
    }
    update();
  }

  void handleCurrentDateSelection(
    DateTime selectedStartDate,
    DateTime selectedEndDate,
  ) {
    List<String> timeSlots = generateTimeSlots(selectedStartDate);
    if (timeSlots.isNotEmpty) {
      String nextSlot = timeSlots.first;
      String endSlot = calculateEndSlot(nextSlot, 1);

      if (selectedStartDate == selectedEndDate) {
        startTimeSearch.value = nextSlot;
        endTimeSearch.value = "23:30";
        curreentStatus.value = "CurrebtDate";
        filterTimeSlotsfunctionSameDate(startTimeSearch.value, "00:30");
      } else {
        curreentStatus.value = "StartCurrentEndOther";
        startTimeSearch.value = nextSlot;
        endTimeSearch.value = "00:30";
        filterTimeSlotsfunctionSameDate(startTimeSearch.value, "00:30");
        handleNextDaySlots(selectedEndDate);
      }
    } else {
      curreentStatus.value = "NoSlotsAvailable";
    }
    update();
  }

  void handleOtherDateSelection(
    DateTime selectedStartDate,
    DateTime selectedEndDate,
  ) {
    if (selectedStartDate == selectedEndDate) {
      curreentStatus.value = "OtherSameDate";
      startTimeSearch.value = "00:30";
      endTimeSearch.value = "01:30";
      filterTimeSlotsfunctionSameDate(
        startTimeSearch.value,
        endTimeSearch.value,
      );
    } else {
      curreentStatus.value = "CrossOtherDates";
      startTimeSearch.value = "00:30";
      endTimeSearch.value = "01:30";
      filterTimeSlotsfunctionSameDate(
        startTimeSearch.value,
        endTimeSearch.value,
      );
      handleNextDaySlots(selectedEndDate);
    }

    update();
  }

  var handleTimeSlotsOnCurrentDate = false.obs;
  String generateNextAvailableSlot(DateTime selectedDate) {
    DateTime currentTime = DateTime.now();
    if (selectedDate.year == currentTime.year &&
        selectedDate.month == currentTime.month &&
        selectedDate.day == currentTime.day) {
      int remainingMinutes = 30 - (currentTime.minute % 30);
      currentTime = currentTime.add(Duration(minutes: remainingMinutes));
      return formatTime(currentTime);
    }
    return "12:00 AM";
  }

  String calculateEndSlot(String startSlot, int hoursToAdd) {
    DateTime startTime = convertToDateTime(startSlot);
    DateTime endTime = startTime.add(Duration(hours: hoursToAdd));
    return formatTime(endTime);
  }

  void handleNextDaySlots(DateTime selectedEndDate) {
    if (!isToday(selectedEndDate)) {
      filterTimeSlotsfunctionSameDate("12:00 AM", "12:30 AM");
    }
  }

  List<String> generateTimeSlots(DateTime selectedDate) {
    handleTimeSlotsOnCurrentDate.value = true;
    update();
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

  String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  var isLoadingItems = false.obs;
  var isLoadingVehicle = false.obs;
  var isLoadingVehiclemake = false.obs;
  var isLoadingBoat = false.obs;
  List<dynamic> maketypesValus = [];
  List<dynamic> selectedtypesvalues = [];
  List<dynamic> featuresvalues = [];
  List<dynamic> odometerValues = [];
  List<dynamic> selectedModelYear = [];
  List<dynamic> selectedFuelTypes = []; // Types de carburant sélectionnés
  List<dynamic> selectedTransmissions =
      []; // NOUVEAU: Transmissions sélectionnées
  List<dynamic> fitvalue = [];
  List<dynamic> colorvalue = [];
  List<dynamic> sizevalue = [];
  List<Items> searchFilterList = [];
  List<dynamic> collectionvalue = [];
  int selectedBeds = 1;
  int selectedBathroom = 1;
  bool showMore = true;
  RxDouble startRange = 0.0.obs;
  RxDouble endRage = 0.0.obs;
  AmenitiesModel? amenitiesModelVehicle;
  Odometer? odometerModelVehicle;
  ItemTypeModel? vehicleTypeModel;
  CarMakes? makeTypeModel;
  FuelTypeModel? fuelTypeModelFilter; // Modèle pour les types de carburant
  Transmission?
      transmissionModelFilter; // NOUVEAU: Modèle pour les transmissions

  ItemTypeModel? typeAfterSearchModel;
  void disposeFunctionFilter() {
    isLoadingItems.value = false;
    isLoadingVehicle.value = false;
  }

  void filterApiBasedOnModule() {
    getAminitiesvehicle();
    getMakeApi();
    getOdometersvehicle();
    getFuelTypesForFilter();
    getTransmissionsForFilter(); // NOUVEAU: Charger les transmissions
    update();
  }

  Future getAminitiesvehicle() async {
    isLoadingVehicle.value = true;
    var vehicleAminities = GetStorage().read("vehicleAminities");
    if (vehicleAminities == null) {
      final response = await httpGet(Config.amenities, {});
      if (response != null) {
        GetStorage().write("vehicleAminities", response);
        amenitiesModelVehicle = AmenitiesModel.fromJson(response);
      }
    } else {
      amenitiesModelVehicle = AmenitiesModel.fromJson(vehicleAminities);
    }
    isLoadingVehicle.value = false;
    update();
  }

  Future getOdometersvehicle() async {
    isLoadingVehicle.value = true;
    var vehicleOdometer = GetStorage().read("vehicleOdometer");
    if (vehicleOdometer == null) {
      final response = await httpGet(Config.vechileOdometer, {});
      if (response != null) {
        GetStorage().write("vehicleOdometer", response);
        odometerModelVehicle = Odometer.fromJson(response);
      }
    } else {
      odometerModelVehicle = Odometer.fromJson(vehicleOdometer);
    }
    isLoadingVehicle.value = false;
    update();
  }

  // NOUVEAU: Récupérer les types de carburant pour le filtre
  Future getFuelTypesForFilter() async {
    isLoadingVehicle.value = true;
    var fuelTypesCache = GetStorage().read("fuelTypesFilter");
    if (fuelTypesCache == null) {
      final response = await httpGet(Config.fuelType, {});
      if (response != null) {
        GetStorage().write("fuelTypesFilter", response);
        fuelTypeModelFilter = FuelTypeModel.fromJson(response);
      }
    } else {
      fuelTypeModelFilter = FuelTypeModel.fromJson(fuelTypesCache);
    }
    isLoadingVehicle.value = false;
    update();
  }

  // NOUVEAU: Récupérer les transmissions pour le filtre
  Future getTransmissionsForFilter() async {
    isLoadingVehicle.value = true;
    var transmissionCache = GetStorage().read("transmissionFilter");
    if (transmissionCache == null) {
      final response = await httpGet(Config.odometermannual, {});
      if (response != null) {
        GetStorage().write("transmissionFilter", response);
        transmissionModelFilter = Transmission.fromJson(response);
      }
    } else {
      transmissionModelFilter = Transmission.fromJson(transmissionCache);
    }
    isLoadingVehicle.value = false;
    update();
  }

  Future getMakeApi() async {
    showLoading();
    isLoadingVehiclemake.value = true;
    var vehiclemakedata = GetStorage().read("vehiclemake");
    try {
      if (vehiclemakedata == null) {
        final response =
            await httpGet(Config.makeType, {"type_id": "$globalItemType"});
        if (response != null) {
          GetStorage().write("vehiclemake", response);
          makeTypeModel = CarMakes.fromJson(response);
        }
      } else {
        makeTypeModel = CarMakes.fromJson(vehiclemakedata);
      }
    } finally {
      // Toujours fermer le loader même en cas d'erreur ou de première requête
      closeLoading();
      isLoadingVehicle.value = false;
      update();
    }
  }

  clearFilter() {
    clearMethod();
    if (activeModuleId.value == 1) {
      selectedBeds = 1;
      selectedBathroom = 1;
    }
    selectredeShortByvalue.value = "Nearest Location";
    selectedtypesvalues.clear();
    featuresvalues.clear();
    fitvalue.clear();
    collectionvalue.clear();
    selectedModelYear.clear();
    selectedFuelTypes.clear();
    selectedTransmissions.clear(); // NOUVEAU: Nettoyer les transmissions
    odometerValues.clear();
    sizevalue.clear();
    searchFilterList.clear();
    maketypesValus.clear();
    startDate.value = '';
    endDates.value = '';
    startTimeSearch.value = '';
    endTimeSearch.value = '';
    avalibleSlots.clear();
    setBoolForCurrentLocation.value = false;
    sLongSearch = "";
    slatsearch = "";
    generalScopeController.slat = "";
    generalScopeController.sLong = "";
    generalScopeController.textEditingControllerCity.clear();
    generalScopeController.homeSearchLocation.value = "";
    generalScopeController.startDateCustomDate.value = "";
    generalScopeController.endDateCustomDate.value = "";
    dateRangePickerControllerCustom.selectedRange = null;
    update();
  }

  datecleatr(bool? clear) {
    startDate.value = '';
    endDates.value = '';
    generalScopeController.startDateCustomDate.value = "";
    generalScopeController.endDateCustomDate.value = "";
    dateRangePickerControllerCustom.selectedRange = null;
    update();
  }

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

  Future submitMethod(BuildContext context, [bool? apply]) async {
    print("📍 submitMethod appelé - apply: $apply");
    print(
        "   - homeSearchLocation: '${generalScopeController.homeSearchLocation.value}'");
    print(
        "   - textEditingControllerCity: '${generalScopeController.textEditingControllerCity.text}'");
    print("   - startDate: '${startDate.value}'");
    print("   - endDates: '${endDates.value}'");
    print("   - slatsearch: '$slatsearch'");
    print("   - sLongSearch: '$sLongSearch'");

    if (apply != true) {
      if (generalScopeController.textEditingControllerCity.text.isEmpty ||
          generalScopeController.homeSearchLocation.value == "" ||
          generalScopeController.textEditingControllerCity.text == "") {
        generalScopeController.textEditingControllerCity.text = "All Locations";
        generalScopeController.homeSearchLocation.value =
            "All Locations"; // BUG FIX: était == au lieu de =
      }
      if (generalScopeController.homeSearchLocation.value == "All Locations") {
        print("❌ BLOQUÉ: All Locations - Please Select location");
        showErrorToastMessage("Please Select location".tr);
        return;
      }

      if (startDate.value == "" || endDates.value == "") {
        // BUG FIX: était && startDate au lieu de || endDates
        print("❌ BLOQUÉ: Dates vides - Please Select Dates");
        showErrorToastMessage("Please Select Dates".tr);
        return;
      }
      if (startDate.value != "") {
        if (startDate.value == endDates.value) {
          print("rjhafvblj");
          print(startTimeSearch.value);
          print(endTimeSearch.value);
          if (isEndTimeBeforeStartTime(
              startTimeSearch.value, endTimeSearch.value)) {
            showErrorToastMessage("End time must be after Start time".tr);
            return;
          }
        }
      }
    }
    if (webPlateForm) {
      Get.toNamed(
        WebRoutes.afterSearch,
        arguments: {
          'checkIn':
              generalScopeController.startDateCustomDate.value.toString(),
          'checkout': generalScopeController.endDateCustomDate.value.toString(),
          'guest': generalScopeController.numberOfGuest.value.toString(),
          'slat': slatsearch,
          'slong': sLongSearch,
          'mode': false
        },
      );
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AfterSearch(
                    checkIn: generalScopeController.startDateCustomDate.value
                        .toString(),
                    checkout: generalScopeController.endDateCustomDate.value
                        .toString(),
                    guest:
                        generalScopeController.numberOfGuest.value.toString(),
                    cityName:
                        generalScopeController.textEditingControllerCity.text,
                    slat: slatsearch,
                    slong: sLongSearch,
                    mode: false,
                  )));
    }
  }

  String maketypeFunction() {
    Map<String, dynamic> map = {
      "make_type": maketypesValus.toString(),
    };
    return jsonEncode(map);
  }

  Map<String, dynamic> bookablemetadata() {
    Map<String, dynamic> map = {
      "color": colorvalue.toString(),
      "fit": fitvalue.toString(),
      "size": sizevalue.toString(),
      "collection": collectionvalue.toString(),
    };
    return map;
  }

  bool filterAvailable = false;
  void disposeFunction() {
    selectedBeds = 1;
    selectedBathroom = 1;
    showMore = true;
  }

  var isLoadingAfterSearchtype = false.obs;

  // Helper function pour normaliser les valeurs de transmission
  // Convertit "manuelle", "Manual", "automatique", etc. vers "manual" ou "automatic"
  String _normalizeTransmission(String transmission) {
    String normalized = transmission.toLowerCase().trim();

    // Mapping des valeurs possibles vers le format backend
    if (normalized.contains('manual') ||
        normalized.contains('manuelle') ||
        normalized == 'm') {
      return 'manual';
    } else if (normalized.contains('automatic') ||
        normalized.contains('automatique') ||
        normalized == 'a') {
      return 'automatic';
    }

    // Si aucune correspondance, retourner en minuscule
    return normalized;
  }

  Future<Map<String, dynamic>> searchItems(
    String title,
    String itemsType,
    String price,
    String beds,
    String bathroom,
    String facility,
    String limit,
    String checkIn,
    String checkout,
    String guest,
    String slot,
    String slong,
    BuildContext context,
    dynamic meta,
  ) async {
    if (price == "0.0-0.0") {
      price = "";
    }
    if (desildetoSendparametersBasedOnPage.value == true) {
      limit = "50";
      offset = 0;
    }
    slot;
    String startTimeForBackend = startTimeSearch.value;
    String endTimeForBackend = endTimeSearch.value;

    if (startTimeSearch.value.contains(RegExp(r'^[0-9]{1,2}:[0-9]{2}$'))) {
      startTimeForBackend = convert24To12(startTimeSearch.value);
      endTimeForBackend = convert24To12(endTimeSearch.value);
    }
    Map<String, dynamic> map = {
      "title": title,
      "price": price,
      "facility": facility,
      "limit": limit,
      "offset": "$offset",
      "Slatitude": slatsearch,
      "Slongitude": sLongSearch,
      "check_in": checkIn,
      "check_out": checkout,
      "city": setCity,
      "zip_code": setZipCode,
      "country": setCountry,
      "state": setState,
      "central_Latitude": centralLat.toString(),
      "central_longitude": centralLng.toString(),
      "radius": placeRadius.toString(),
      "search_on_map":
          desildetoSendparametersBasedOnPage.value == true ? "1" : "0",
      "sort": selectredeShortByvalue.value == "Nearest Location"
          ? "nearest_location"
          : selectredeShortByvalue.value == "Highest Ranked"
              ? "highest_rated"
              : "cheapest_price",
      "meta": meta,
      "odometer": odometerValues.toString(),
      "start_time": startTimeForBackend,
      "end_time": endTimeForBackend,
      "modelYear": selectedModelYear.toString(),
      // Envoyer fuel_type comme array de numbers [1,2,3]
      "fuel_type":
          selectedFuelTypes.isNotEmpty ? selectedFuelTypes.toList() : [],
      // Envoyer transmission comme array de strings ["manual","automatic"]
      // Normaliser les valeurs pour correspondre au format backend
      "transmission": selectedTransmissions.isNotEmpty
          ? selectedTransmissions
              .map((t) => _normalizeTransmission(t.toString()))
              .toList()
          : [],
    };

    // Préparer une URL GET lisible pour le backend (debug uniquement)
    final String cityForUrl = setCity.isNotEmpty
        ? setCity
        : generalScopeController.homeSearchLocation.value;
    final String categoryIdForUrl = globalItemType.value;

    final Uri baseUri = Uri.parse(Config.baseurl);
    final String basePath = baseUri.path.endsWith('/')
        ? baseUri.path.substring(0, baseUri.path.length - 1)
        : baseUri.path;
    final Uri searchDebugUri = Uri(
      scheme: baseUri.scheme,
      host: baseUri.host,
      port: baseUri.port,
      path: '$basePath/vehicles/search',
      queryParameters: {
        'location': cityForUrl,
        'startDate': checkIn,
        'endDate': checkout,
        'categoryId': categoryIdForUrl,
        'lat': slatsearch,
        'lng': sLongSearch,
      },
    );

    // DEBUG: Afficher les valeurs des filtres et l'URL attendue par le backend
    print("🔍 DEBUG FILTRES:");
    print("   - slatsearch: '$slatsearch'");
    print("   - sLongSearch: '$sLongSearch'");
    print("   - setCity: '$setCity'");
    print("   - cityForUrl (location): '$cityForUrl'");
    print("   - categoryId (globalItemType): '$categoryIdForUrl'");
    print("   - fuel_type: ${selectedFuelTypes.toList()}");
    print("   - transmission (raw): ${selectedTransmissions.toList()}");
    print(
        "   - transmission (normalized): ${selectedTransmissions.isNotEmpty ? selectedTransmissions.map((t) => _normalizeTransmission(t.toString())).toList() : []}");
    print("   - Map envoyée (POST ${Config.itemSearch}): $map");
    print("   🔵 [SEARCH_DEBUG_URL] $searchDebugUri");

    // Appel RÉEL à l'API de recherche (item-search)
    final dynamic response = await httpPost(Config.itemSearch, map);

    // DEBUG: afficher la réponse brute telle que retournée par l'API
    print("🔍 RAW SEARCH RESPONSE: $response");

    if (response is Map<String, dynamic>) {
      return response;
    } else {
      print(
          "❌ [SEARCH_API] Type de réponse inattendu: ${response.runtimeType}");
      return {
        "status": 500,
        "message": "Invalid response from search API",
        "error": "invalid_response",
        "data": {}
      };
    }
  }

  String setpriceforrecentvalue = "";
  var sendvalueInApiforrecentValue = true.obs;
  Map<String, dynamic> globalSearchParams = {};
  void loadAndSendSearch(int index, BuildContext context) async {
    List<Map<String, dynamic>> recentSearches = loadRecentSearches();
    if (index >= 0 && index < recentSearches.length) {
      setCity = "";
      setCountry = "";
      setState = "";
      placeRadius = "";
      centralLat = "";
      featuresvalues.clear();
      selectedModelYear.clear();
      selectedFuelTypes.clear();
      selectedTransmissions.clear(); // NOUVEAU: Nettoyer les transmissions
      odometerValues.clear();
      centralLng = "";
      Map<String, dynamic> search = recentSearches[index];
      selectedtypesvalues.clear();
      setpriceforrecentvalue = search['price'] ?? '';
      slatsearch = search['Slatitude'] ?? '';
      sLongSearch = search['Slongitude'] ?? '';
      setCity = search['city'] ?? '';
      setZipCode = search['zip_code'] ?? '';
      setCountry = search['country'] ?? '';
      setState = search['state'] ?? '';
      centralLat = search['central_Latitude'] ?? '';
      centralLng = search['central_longitude'] ?? '';
      placeRadius = search['radius'] ?? '';
      generalScopeController.textEditingControllerCity.text =
          search['controller_value'] ?? '';
      generalScopeController.homeSearchLocation.value =
          search['controller_value'] ?? '';
      if (desildetoSendparametersBasedOnPage.value == true) {
        Navigator.pop(context);
      } else {
        if (webPlateForm) {
          Get.toNamed(
            WebRoutes.afterSearch,
            arguments: {
              'checkIn': search['check_in'] ?? '',
              'checkout': search['check_out'] ?? '',
            },
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AfterSearch(
                      checkIn: search['check_in'] ?? '',
                      checkout: search['check_out'] ?? '',
                    )),
          );
        }
      }
    } else {}
  }

  List<Map<String, dynamic>> loadRecentSearches() {
    final box = GetStorage();
    var storedData = box.read('recent_searches');
    if (storedData is List) {
      return storedData.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  String dataNotFound = "";
  void datanotFoundUi() {
    dataNotFound = "Vehicle Not Available".tr;
  }

  routeBasedOnmoduleId(BuildContext context, VoidCallback onRefresh) async {
    showPopUpScreen(
        context,
        VehicleFilter(
          mode: false,
          onRefresh: onRefresh,
        ));
  }

  RxBool searchOurRecommendationCheck = false.obs;
  ItemModel? itemModel;
  AmenitiesModel? fitmodel;
  AmenitiesModel? colorModel;
  AmenitiesModel? sizeModel;
  AmenitiesModel? collectionmodel;
  String setCity = "";
  String setZipCode = "";
  String setCountry = "";
  String setState = "";
  dynamic centralLat = "";
  dynamic centralLng = "";
  dynamic placeRadius = "";

  Future<void> getPlaceDetailFromId(placeId) async {
    setCity = "";
    setZipCode = "";
    setCountry = "";
    setState = "";
    centralLat = "";
    centralLng = "";
    placeRadius = "";
    final placesRequest =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${Config.googleKey}';
    final placesResponse = await http.get(Uri.parse(placesRequest));

    if (placesResponse.statusCode == 200) {
      final placesResult = json.decode(placesResponse.body);
      if (placesResult['status'] == 'OK') {
        final placeDetails = placesResult['result'];
        centralLat = placeDetails['geometry']['location']['lat'];
        centralLng = placeDetails['geometry']['location']['lng'];
        final geocodeRequest =
            'https://maps.googleapis.com/maps/api/geocode/json?place_id=$placeId&key=${Config.googleKey}';
        final geocodeResponse = await http.get(Uri.parse(geocodeRequest));
        if (geocodeResponse.statusCode == 200) {
          final geocodeResult = json.decode(geocodeResponse.body);
          if (geocodeResult['status'] == 'OK') {
            final components = geocodeResult['results'][0]['address_components']
                as List<dynamic>;
            String? city;
            String? zipCode;
            String? country;
            String? state;
            for (var component in components) {
              final types = component['types'] as List<dynamic>;
              if (types.contains('postal_code')) {
                zipCode = component['long_name'];
              }
              if (types.contains('country')) {
                country = component['long_name'];
              }
              if (types.contains('administrative_area_level_1')) {
                state = component['long_name'];
              }
              if (types.contains('locality') ||
                  types.contains('administrative_area_level_3')) {
                city = component['long_name'];
              }
            }

            if (zipCode != null) {
              setZipCode = zipCode;
            }
            if (country != null) {
              setCountry = country;
            }
            if (state != null) {
              setState = state;
            }
            if (city != null) {
              setCity = city;
            }
          } else {
            throw Exception('Failed to fetch suggestion');
          }
        } else {
          throw Exception('Failed to fetch place details');
        }
      } else {
        throw Exception(
            'Failed to fetch place details: ${placesResult['status']}');
      }
    } else {
      throw Exception('Failed to fetch place details');
    }
  }

  Location location = Location();
  String aroundCurrentLocation = "Around Current Location".tr;
  var setBoolForCurrentLocation = false.obs;
  bool showselectedColorofRegion = false;

  Future<void> getUserLocationForBetterSearch(BuildContext context) async {
    SearchControllerHome filterController = Get.find();
    setCity = "";
    setZipCode = "";
    setCountry = "";
    setState = "";
    centralLat = "";
    centralLng = "";
    placeRadius = "";
    generalScopeController.textEditingControllerCity.clear();
    var uuid = const Uuid();
    String sessionId = uuid.v4();
    print("Session ID: $sessionId");
    try {
      showLoading();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          closeLoading();
          showOpenAppSettingsDialog(
              context,
              "Please enable location services to show the nearest vehicles around you.."
                  .tr);
          return;
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          closeLoading();
          showOpenAppSettingsDialog(
              context,
              "Location permission denied. Please go to settings and allow the location"
                  .tr);
          return;
        }
      }

      LocationData locationData = await location
          .getLocation()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        closeLoading();
        showErrorToastMessage(
            "Failed to get current location within the timeout please search manually"
                .tr);
        throw TimeoutException("Fetching location timed out.");
      });

      closeLoading();
      if (locationData.latitude != null && locationData.longitude != null) {
        slatsearch = locationData.latitude.toString();
        sLongSearch = locationData.longitude.toString();
        String placeId =
            await getPlaceId(locationData.latitude!, locationData.longitude!);
        String fullAddress = await getAddressFromPlaceId(placeId);
        generalScopeController.homeSearchLocation.value = fullAddress;
        generalScopeController.textEditingControllerCity.text = fullAddress;
        update();
        if (filterController.hitApiOnMap == true) {
          Navigator.pop(context);
        }
      } else {
        showErrorToastMessage("Failed to get current location.");
      }
    } catch (e) {
      closeLoading();
    }
  }

  Future<String> getPlaceId(double latitude, double longitude) async {
    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=${Config.googleKey}',
      ),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].length > 0) {
        return data['results'][0]['place_id'];
      } else {
        throw Exception('No results found for the given location.');
      }
    } else {
      throw Exception('Failed to fetch place ID.');
    }
  }

  Future<String> getAddressFromPlaceId(String placeId) async {
    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?place_id=$placeId&key=${Config.googleKey}',
      ),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].length > 0) {
        return data['results'][0]['formatted_address'];
      } else {
        throw Exception('No address found for the given place ID.');
      }
    } else {
      throw Exception('Failed to fetch address.');
    }
  }

  RxString selectredeShortByvalue = "Nearest Location".obs;
}
