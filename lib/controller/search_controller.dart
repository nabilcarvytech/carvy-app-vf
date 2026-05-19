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
import 'package:carvy/utils/rental_billing_days.dart';
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
    currenttimeSlots = <String>[].obs;
    filteredTimeSlotsEndTime = <String>[].obs;
    avalibleSlots = <String>[];
  }

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

  /// Réinitialise les dates / créneaux du bandeau de recherche (aucun préremplissage).
  void setDefaultDates({
    required RxString startDateCustomDate,
    required RxString endDateCustomDate,
    required RxString startDate,
    required RxString endDates,
  }) {
    startDateCustomDate.value = '';
    endDateCustomDate.value = '';
    startDate.value = '';
    endDates.value = '';
    startTimeSearch.value = '';
    endTimeSearch.value = '';
    dateRangePickerControllerCustom.selectedRange = null;
    avalibleSlots.clear();
    curreentStatus.value = '';
    update();
  }

  /// Vide les dates du bandeau (détail véhicule) sans préremplissage automatique.
  void clearVehicleDetailSearchDates() {
    startDate.value = '';
    endDates.value = '';
    startTimeSearch.value = '';
    endTimeSearch.value = '';
    generalScopeController.startDateCustomDate.value = '';
    generalScopeController.endDateCustomDate.value = '';
    dateRangePickerControllerCustom.selectedRange = null;
    curreentStatus.value = '';
    update();
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
        endTimeSearch.value =
            activeModuleId.value == 2 ? nextSlot : "22:00";
        curreentStatus.value = "CurrebtDate";
        filterTimeSlotsfunctionSameDate(
            startTimeSearch.value,
            activeModuleId.value == 2 ? endTimeSearch.value : "22:00");
      } else {
        curreentStatus.value = "StartCurrentEndOther";
        startTimeSearch.value = nextSlot;
        endTimeSearch.value =
            activeModuleId.value == 2 ? nextSlot : "22:00";
        filterTimeSlotsfunctionSameDate(
            startTimeSearch.value,
            activeModuleId.value == 2 ? endTimeSearch.value : "22:00");
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
      startTimeSearch.value = "09:00";
      endTimeSearch.value = activeModuleId.value == 2 ? "09:00" : "10:00";
      filterTimeSlotsfunctionSameDate(
        startTimeSearch.value,
        endTimeSearch.value,
      );
    } else {
      curreentStatus.value = "CrossOtherDates";
      startTimeSearch.value = "09:00";
      endTimeSearch.value = activeModuleId.value == 2 ? "09:00" : "10:00";
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
      final DateTime serviceStart = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        9,
        0,
      );
      final bool vehicleSearch = activeModuleId.value == 2;
      final DateTime serviceEnd = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        vehicleSearch ? 20 : 22,
        vehicleSearch ? 30 : 0,
      );
      if (currentTime.isBefore(serviceStart)) {
        currentTime = serviceStart;
      }
      if (currentTime.isAfter(serviceEnd)) {
        return [];
      }
      while (currentTime.isBefore(serviceEnd) ||
          currentTime.isAtSameMomentAs(serviceEnd)) {
        String formattedTime = DateFormat('HH:mm').format(currentTime);
        currenttimeSlots.add(formattedTime);
        currentTime = currentTime.add(const Duration(minutes: 30));
      }
      return currenttimeSlots;
    } else {
      return searchPickerBaselineSlots();
    }
  }

  List<String> filterTimeSlotsfunctionSameDate(
      String startTimeString, String endTimeString) {
    filteredTimeSlotsEndTime.clear();
    update();
    final List<String> manualTimeSlots = searchPickerBaselineSlots();

    if (activeModuleId.value == 2) {
      final DateTime startTime = convertToDateTime(startTimeString);
      final int from = manualTimeSlots.indexWhere(
        (slot) =>
            !convertToDateTime(slot).isBefore(startTime),
      );
      final int i = from >= 0 ? from : 0;
      filteredTimeSlotsEndTime.value = manualTimeSlots.sublist(i);
      update();
      return filteredTimeSlotsEndTime;
    }

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

  /// Heures d'ouverture des agences : 09:00 à 22:00 (sans 22:30 ni 23:00).
  List<String> getManualTimeSlots24() {
    return getServiceHours();
  }

  List<String> getServiceHours() {
    final List<String> times = [];
    for (int i = 9; i <= 22; i++) {
      final String hour = i.toString().padLeft(2, '0');
      times.add('$hour:00');
      if (i < 22) {
        times.add('$hour:30');
      }
    }
    return times;
  }

  String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  var isLoadingItems = false.obs;
  var isLoadingVehicle = false.obs;
  bool isFetching = false;
  var isLoadingVehiclemake = false.obs;
  var isLoadingBoat = false.obs;
  List<dynamic> maketypesValus = [];
  List<dynamic> selectedtypesvalues = [];
  List<dynamic> featuresvalues = [];
  var selectedOdometers = <String>[].obs;
  var selectedYears = <String>[].obs;
  var selectedFuels = <String>[].obs;
  var selectedTransmissions = <String>[].obs;
  List<dynamic> get odometerValues => selectedOdometers;
  set odometerValues(List<dynamic> value) =>
      selectedOdometers.assignAll(value.map((e) => e.toString()));
  List<dynamic> get selectedModelYear => selectedYears;
  set selectedModelYear(List<dynamic> value) =>
      selectedYears.assignAll(value.map((e) => e.toString()));
  List<dynamic> get selectedFuelTypes => selectedFuels;
  set selectedFuelTypes(List<dynamic> value) =>
      selectedFuels.assignAll(value.map((e) => e.toString()));
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
  // Filtre: n'afficher que les véhicules remboursables (politiques flexibles)
  RxBool isRefundableOnly = false.obs;
  // Filtre: Type d'assurance sélectionné ('BASIC' | 'FULL' | '')
  RxString selectedInsurance = ''.obs;
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
    print('🧹 [INIT] Vidage du cache des filtres...');
    GetStorage().remove("vehicleAminities");
    GetStorage().remove("vehiclemake");
    GetStorage().remove("vehicleOdometer");
    GetStorage().remove("fuelTypesFilter");
    GetStorage().remove("transmissionFilter");
    print('✅ [INIT] Cache vidé, démarrage des appels API...');
    getAminitiesvehicle();
    getMakeApi();
    getOdometersvehicle();
    getFuelTypesForFilter();
    getTransmissionsForFilter(); // NOUVEAU: Charger les transmissions
    update();
  }

  Future getAminitiesvehicle() async {
    if (isFetching) return;
    isFetching = true;
    try {
      print('🚀 [API GET_AMENITIES] Début de la requête...');
      isLoadingVehicle.value = true;
      var vehicleAminities = GetStorage().read("vehicleAminities");
      
      if (vehicleAminities == null) {
        print('📡 [API GET_AMENITIES] Aucun cache trouvé, appel HTTP en cours...');
        final response = await httpGet(Config.amenities, {});
        
        print('📦 [API GET_AMENITIES] Réponse brute reçue : $response'); // LOG CRUCIAL
        
        if (response != null) {
          GetStorage().write("vehicleAminities", response);
          try {
            amenitiesModelVehicle = AmenitiesModel.fromJson(response);
            print('✅ [API GET_AMENITIES] Parsing JSON réussi ! Nombre d\'éléments : ${amenitiesModelVehicle?.data?.amenities?.length ?? 0}');
          } catch (e) {
            print('❌ [API GET_AMENITIES] Erreur lors du parsing JSON : $e');
          }
        } else {
          print('⚠️ [API GET_AMENITIES] La réponse HTTP est nulle.');
        }
      } else {
        print('💾 [API GET_AMENITIES] Chargement depuis le cache.');
        try {
          amenitiesModelVehicle = AmenitiesModel.fromJson(vehicleAminities);
          print('✅ [API GET_AMENITIES] Cache chargé ! Nombre d\'éléments : ${amenitiesModelVehicle?.data?.amenities?.length ?? 0}');
        } catch (e) {
          print('❌ [API GET_AMENITIES] Erreur parsing du cache : $e');
        }
      }
      isLoadingVehicle.value = false;
      update();
    } catch (e) {
      print('💥 [API GET_AMENITIES] Erreur globale de la fonction : $e');
      isLoadingVehicle.value = false;
    } finally {
      isFetching = false;
    }
  }

  Future getOdometersvehicle() async {
    try {
      print('🚀 [API GET_ODOMETER] Début de la requête...');
      isLoadingVehicle.value = true;
      var vehicleOdometer = GetStorage().read("vehicleOdometer");
      
      if (vehicleOdometer == null) {
        print('📡 [API GET_ODOMETER] Aucun cache trouvé, appel HTTP en cours...');
        final response = await httpGet(Config.vechileOdometer, {});
        
        print('📦 [API GET_ODOMETER] Réponse brute reçue : $response'); // LOG CRUCIAL
        
        if (response != null) {
          GetStorage().write("vehicleOdometer", response);
          try {
            odometerModelVehicle = Odometer.fromJson(response);
            print('✅ [API GET_ODOMETER] Parsing JSON réussi ! Nombre d\'éléments : ${odometerModelVehicle?.data?.odometerList?.length ?? 0}');
          } catch (e) {
            print('❌ [API GET_ODOMETER] Erreur lors du parsing JSON : $e');
          }
        } else {
          print('⚠️ [API GET_ODOMETER] La réponse HTTP est nulle.');
        }
      } else {
        print('💾 [API GET_ODOMETER] Chargement depuis le cache.');
        try {
          odometerModelVehicle = Odometer.fromJson(vehicleOdometer);
          print('✅ [API GET_ODOMETER] Cache chargé ! Nombre d\'éléments : ${odometerModelVehicle?.data?.odometerList?.length ?? 0}');
        } catch (e) {
          print('❌ [API GET_ODOMETER] Erreur parsing du cache : $e');
        }
      }
      isLoadingVehicle.value = false;
      update();
    } catch (e) {
      print('💥 [API GET_ODOMETER] Erreur globale de la fonction : $e');
      isLoadingVehicle.value = false;
      update();
    }
  }

  // NOUVEAU: Récupérer les types de carburant pour le filtre
  Future getFuelTypesForFilter() async {
    try {
      print('🚀 [API GET_FUEL] Début de la requête...');
      isLoadingVehicle.value = true;
      var fuelTypesCache = GetStorage().read("fuelTypesFilter");
      
      if (fuelTypesCache == null) {
        print('📡 [API GET_FUEL] Aucun cache trouvé, appel HTTP en cours...');
        final response = await httpGet(Config.fuelType, {});
        
        print('📦 [API GET_FUEL] Réponse brute reçue : $response'); // LOG CRUCIAL
        
        if (response != null) {
          GetStorage().write("fuelTypesFilter", response);
          try {
            fuelTypeModelFilter = FuelTypeModel.fromJson(response);
            print('✅ [API GET_FUEL] Parsing JSON réussi ! Nombre d\'éléments : ${fuelTypeModelFilter?.fuelTypes.length ?? 0}');
          } catch (e) {
            print('❌ [API GET_FUEL] Erreur lors du parsing JSON : $e');
          }
        } else {
          print('⚠️ [API GET_FUEL] La réponse HTTP est nulle.');
        }
      } else {
        print('💾 [API GET_FUEL] Chargement depuis le cache.');
        try {
          fuelTypeModelFilter = FuelTypeModel.fromJson(fuelTypesCache);
          print('✅ [API GET_FUEL] Cache chargé ! Nombre d\'éléments : ${fuelTypeModelFilter?.fuelTypes.length ?? 0}');
        } catch (e) {
          print('❌ [API GET_FUEL] Erreur parsing du cache : $e');
        }
      }
      isLoadingVehicle.value = false;
      update();
    } catch (e) {
      print('💥 [API GET_FUEL] Erreur globale de la fonction : $e');
      isLoadingVehicle.value = false;
      update();
    }
  }

  // NOUVEAU: Récupérer les transmissions pour le filtre
  Future getTransmissionsForFilter() async {
    try {
      print('🚀 [API GET_TRANSMISSION] Début de la requête...');
      isLoadingVehicle.value = true;
      var transmissionCache = GetStorage().read("transmissionFilter");
      
      if (transmissionCache == null) {
        print('📡 [API GET_TRANSMISSION] Aucun cache trouvé, appel HTTP en cours...');
        final response = await httpGet(Config.odometermannual, {});
        
        print('📦 [API GET_TRANSMISSION] Réponse brute reçue : $response'); // LOG CRUCIAL
        
        if (response != null) {
          GetStorage().write("transmissionFilter", response);
          try {
            transmissionModelFilter = Transmission.fromJson(response);
            print('✅ [API GET_TRANSMISSION] Parsing JSON réussi ! Nombre d\'éléments : ${transmissionModelFilter?.data?.options?.length ?? 0}');
          } catch (e) {
            print('❌ [API GET_TRANSMISSION] Erreur lors du parsing JSON : $e');
          }
        } else {
          print('⚠️ [API GET_TRANSMISSION] La réponse HTTP est nulle.');
        }
      } else {
        print('💾 [API GET_TRANSMISSION] Chargement depuis le cache.');
        try {
          transmissionModelFilter = Transmission.fromJson(transmissionCache);
          print('✅ [API GET_TRANSMISSION] Cache chargé ! Nombre d\'éléments : ${transmissionModelFilter?.data?.options?.length ?? 0}');
        } catch (e) {
          print('❌ [API GET_TRANSMISSION] Erreur parsing du cache : $e');
        }
      }
      isLoadingVehicle.value = false;
      update();
    } catch (e) {
      print('💥 [API GET_TRANSMISSION] Erreur globale de la fonction : $e');
      isLoadingVehicle.value = false;
      update();
    }
  }

  Future getMakeApi() async {
    try {
      print('🚀 [API GET_MAKE] Début de la requête...');
      showLoading();
      isLoadingVehiclemake.value = true;
      var vehiclemakedata = GetStorage().read("vehiclemake");
      
      if (vehiclemakedata == null) {
        print('📡 [API GET_MAKE] Aucun cache trouvé, appel HTTP en cours...');
        print('📡 [API GET_MAKE] Paramètres : type_id = $globalItemType');
        final response =
            await httpGet(Config.makeType, {"type_id": "$globalItemType"});
        
        print('📦 [API GET_MAKE] Réponse brute reçue : $response'); // LOG CRUCIAL
        
        if (response != null) {
          GetStorage().write("vehiclemake", response);
          try {
            makeTypeModel = CarMakes.fromJson(response);
            print('✅ [API GET_MAKE] Parsing JSON réussi ! Nombre d\'éléments : ${makeTypeModel?.data?.makes?.length ?? 0}');
          } catch (e) {
            print('❌ [API GET_MAKE] Erreur lors du parsing JSON : $e');
          }
        } else {
          print('⚠️ [API GET_MAKE] La réponse HTTP est nulle.');
        }
      } else {
        print('💾 [API GET_MAKE] Chargement depuis le cache.');
        try {
          makeTypeModel = CarMakes.fromJson(vehiclemakedata);
          print('✅ [API GET_MAKE] Cache chargé ! Nombre d\'éléments : ${makeTypeModel?.data?.makes?.length ?? 0}');
        } catch (e) {
          print('❌ [API GET_MAKE] Erreur parsing du cache : $e');
        }
      }
    } catch (e) {
      print('💥 [API GET_MAKE] Erreur globale de la fonction : $e');
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
    selectedtypesvalues = [];
    featuresvalues = [];
    fitvalue = [];
    collectionvalue = [];
    selectedYears.clear();
    selectedFuels.clear();
    selectedTransmissions.clear(); // NOUVEAU: Nettoyer les transmissions
    selectedOdometers.clear();
    sizevalue = [];
    searchFilterList.clear();
    maketypesValus = [];
    startRange.value = double.tryParse("$minPricerange") ?? 0.0;
    endRage.value = double.tryParse("$maxPriceRange") ?? 0.0;
    startDate.value = '';
    isRefundableOnly.value = false;
    selectedInsurance.value = '';
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

  /// Véhicule : retour strictement avant départ (même jour) = invalide. L'égalité est autorisée.
  bool isEndTimeStrictlyBeforeStartTime(String startTime, String endTime) {
    return RentalBillingDays.isEndTimeStrictlyBeforeStartTime(
        startTime, endTime);
  }

  /// Grille affichée dans les pickers de recherche (véhicule : 09:00–20:30, sinon 09:00–22:00).
  List<String> searchPickerBaselineSlots() {
    if (activeModuleId.value == 2) {
      return RentalBillingDays.vehicleSearchTimeSlotsHHmm();
    }
    return getServiceHours();
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

      if (startDate.value.isNotEmpty &&
          endDates.value.isNotEmpty &&
          startDate.value == endDates.value) {
        if (startTimeSearch.value.isNotEmpty &&
            endTimeSearch.value.isNotEmpty) {
          final invalid = activeModuleId.value == 2
              ? isEndTimeStrictlyBeforeStartTime(
                  startTimeSearch.value, endTimeSearch.value)
              : isEndTimeBeforeStartTime(
                  startTimeSearch.value, endTimeSearch.value);
          if (invalid) {
            showErrorToastMessage("End time must be after Start time".tr);
            return;
          }
        }
      }
    }

    // Déjà sur les résultats : ne pas empiler un second AfterSearch.
    if (apply == true && aftersearch) {
      return;
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

  List<dynamic> cleanList(List? list) {
    if (list == null || list.isEmpty) return [];
    return list
        .where((item) => item != null && item.toString().trim().isNotEmpty)
        .toList();
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

    final List<dynamic> cleanedOdometer = cleanList(odometerValues);
    final List<dynamic> cleanedModelYear = cleanList(selectedModelYear);
    final List<dynamic> cleanedFuelTypes = cleanList(selectedFuelTypes);
    final List<dynamic> cleanedTransmissions = cleanList(selectedTransmissions)
        .map((t) => _normalizeTransmission(t.toString()))
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList();
    final List<dynamic> cleanedMakeTypes = cleanList(maketypesValus);

    dynamic metaPayload;
    if (meta is Map) {
      final Map<String, dynamic> sanitizedMeta = Map<String, dynamic>.from(meta);
      if (cleanedMakeTypes.isNotEmpty) {
        sanitizedMeta["make_type"] = cleanedMakeTypes;
      } else {
        sanitizedMeta.remove("make_type");
      }
      sanitizedMeta.removeWhere((key, value) {
        if (value == null) return true;
        if (value is String && value.trim().isEmpty) return true;
        if (value is List && cleanList(value).isEmpty) return true;
        return false;
      });
      if (sanitizedMeta.isNotEmpty) {
        metaPayload = sanitizedMeta;
      }
    } else if (cleanedMakeTypes.isNotEmpty) {
      metaPayload = {"make_type": cleanedMakeTypes};
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
              : selectredeShortByvalue.value == "Newest"
                  ? "newest"
                  : "cheapest_price",
      if (metaPayload != null) "meta": metaPayload,
      "start_time": startTimeForBackend,
      "end_time": endTimeForBackend,
      if (cleanedOdometer.isNotEmpty) "odometer": cleanedOdometer,
      if (cleanedModelYear.isNotEmpty) "modelYear": cleanedModelYear,
      if (cleanedFuelTypes.isNotEmpty) "fuel_type": cleanedFuelTypes,
      if (cleanedTransmissions.isNotEmpty) "transmission": cleanedTransmissions,
      if (isRefundableOnly.value) "isRefundable": true,
      if (selectedInsurance.value.trim().isNotEmpty)
        "insuranceType": selectedInsurance.value.trim(),
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
    print("   - price (param): '$price'");
    print("   - startRange (obs): ${startRange.value}");
    print("   - endRage (obs): ${endRage.value}");
    print("   - sendvalueInApiforrecentValue: ${sendvalueInApiforrecentValue.value}");
    print("   - setpriceforrecentvalue: '$setpriceforrecentvalue'");
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
    print("📤 [FRONT SEARCH] Payload envoyé : $map");

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

  /// Prix figé au clic « Appliquer » (évite une course avec initState du filtre).
  String? _pendingAppliedPriceRange;

  void prepareFilterSheetOpen() {
    sendvalueInApiforrecentValue.value = false;
    debugPrint(
      '🔎 [FILTER] Ouverture feuille — startRange=${startRange.value} '
      'endRage=${endRage.value} sendRecent=${sendvalueInApiforrecentValue.value}',
    );
  }

  void lockPriceRangeForNextSearch(String priceRange) {
    sendvalueInApiforrecentValue.value = false;
    _pendingAppliedPriceRange = priceRange;
    final parts = priceRange.split('-');
    if (parts.length == 2) {
      final min = double.tryParse(parts[0].trim());
      final max = double.tryParse(parts[1].trim());
      if (min != null) startRange.value = min;
      if (max != null) endRage.value = max;
    }
    debugPrint(
      '🔎 [FILTER] Prix verrouillé pour la prochaine API: $priceRange '
      '(startRange=${startRange.value} endRage=${endRage.value})',
    );
  }

  /// Prix envoyé à [searchItems] — priorité au verrou post-« Appliquer ».
  String resolveSearchPriceParam() {
    if (_pendingAppliedPriceRange != null) {
      final locked = _pendingAppliedPriceRange!;
      _pendingAppliedPriceRange = null;
      if (locked == '0-0' || locked == '0.0-0.0') {
        debugPrint('🔎 [FILTER] API price (verrouillé): vide');
        return '';
      }
      debugPrint('🔎 [FILTER] API price (verrouillé au clic): $locked');
      return locked;
    }

    if (sendvalueInApiforrecentValue.value == true &&
        setpriceforrecentvalue.trim().isNotEmpty) {
      debugPrint('🔎 [FILTER] API price (recherche récente): $setpriceforrecentvalue');
      return setpriceforrecentvalue;
    }

    sendvalueInApiforrecentValue.value = false;
    final built =
        '${startRange.value.round()}-${endRage.value.round()}';
    if (built == '0-0') {
      debugPrint('🔎 [FILTER] API price (controller): vide');
      return '';
    }
    debugPrint(
      '🔎 [FILTER] API price (controller): $built '
      '(startRange=${startRange.value} endRage=${endRage.value})',
    );
    return built;
  }
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

  /// Ferme la feuille de filtres puis lance la recherche ou rafraîchit les résultats.
  /// Les filtres (prix, marques, etc.) sont déjà dans les observables du contrôleur.
  void applyFiltersFromSheet(
    BuildContext sheetContext, {
    bool navigateToSearchResults = false,
    VoidCallback? refreshResults,
    VoidCallback? onMapRefresh,
    String? lockedPriceRange,
  }) {
    if (lockedPriceRange != null && lockedPriceRange.trim().isNotEmpty) {
      lockPriceRangeForNextSearch(lockedPriceRange.trim());
    } else {
      sendvalueInApiforrecentValue.value = false;
      final built =
          '${startRange.value.round()}-${endRage.value.round()}';
      lockPriceRangeForNextSearch(built == '0-0' ? '' : built);
    }

    dismissFilterBottomSheet(sheetContext);

    void runAfterSheetClosed() {
      final ctx = Get.context;
      if (ctx == null) return;

      if (navigateToSearchResults) {
        submitMethod(ctx, true);
        return;
      }
      if (onMapRefresh != null) {
        onMapRefresh();
        return;
      }
      refreshResults?.call();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => runAfterSheetClosed());
  }

  /// Ferme la feuille de filtres (useRootNavigator: true dans [showPopUpScreen]).
  void dismissFilterBottomSheet(BuildContext sheetContext) {
    if (sheetContext.mounted) {
      final rootNav = Navigator.of(sheetContext, rootNavigator: true);
      if (rootNav.canPop()) {
        rootNav.pop();
        return;
      }
      final nav = Navigator.of(sheetContext);
      if (nav.canPop()) {
        nav.pop();
        return;
      }
    }
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }
  }

  routeBasedOnmoduleId(BuildContext context, VoidCallback onRefresh) async {
    prepareFilterSheetOpen();
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
