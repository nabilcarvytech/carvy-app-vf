import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/customwidget/form_validation.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/amenities_model.dart';
import 'package:carvy/model/cancellation_policies_model.dart';
import 'package:carvy/model/category_model.dart';
import 'package:carvy/model/fetch_item_id.dart';
import 'package:carvy/model/fuel_type_model.dart';
import 'package:carvy/model/get_year_model.dart';
import 'package:carvy/model/location_host_model.dart';
import 'package:carvy/model/locations_model.dart';
import 'package:carvy/model/make_model_vehicle.dart';
import 'package:carvy/model/my_items_model.dart';
import 'package:carvy/model/odometer_model.dart';
import 'package:carvy/model/item_type_model.dart';
import 'package:carvy/model/sub_category_model.dart';
import 'package:carvy/model/transmission_model.dart';
import 'package:carvy/view/host/bottom_bar_host.dart';
import 'package:carvy/view/host/location_screen_host.dart';
import 'package:carvy/view/host/upload_image_screen.dart';
import 'package:carvy/view/host/vehiclehost/addvehicle/vehicle_description.dart';
import 'package:carvy/view/host/vehiclehost/addvehicle/vehicle_features_screen.dart';
import 'package:carvy/view/host/vehiclehost/editvehicle/edit_vehicle_home_screen.dart';
import 'package:carvy/work_space.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../model/add_rules_model.dart';

class AddItemsHostController extends GetxController implements GetxService {
  bool isCheckeddoorstep = false;
  bool isCheckedSecurityDeposit = false;
  bool isAgeRestricted = false;
  RxBool isChecked1 = false.obs;
  RxBool isChecked2 = false.obs;
  bool numerictype = false;
  RxInt totalEditBeds = 1.obs;
  RxInt totalEditBathroom = 1.obs;
  RxInt totalEditAllowed = 1.obs;
  RxInt totalEditRooms = 1.obs;
  RxBool isUploadingImage = false.obs;
  int selectedRadio = 1;
  List listDeleteImages = [];
  XFile? frontImage;
  List<XFile> galleryImageList = [];
  String? frontImageBase64;
  List galleryImageBase64List = [];
  AmenitiesModel? amenitiesModel;
  GetMakeModel? getMakeModel;
  String? selectedYear;
  int selectedVechicleYear = DateTime.now().year;
  String? selectedHour;
  int? selectedSpaceCapicity;
  String? selectedSpaceSize;
  int? selectedBoatYear = DateTime.now().year;
  LocationsModel? locationsModel;
  LocationsHostModel? locationsHostModel;
  CancellationPoliciesModel? cancellationPoliciesModel;
  AddRulesModel? addRulesModel;
  String selectedMonthlyDiscountType = "percent";
  String selectedWeeklyDiscountType = "percent";
  String? selectedCityName;
  bool forLocation = true;
  String? selectedCityShortName;
  String? serviceType = "";
  String? convertFirstLettertoCapital = "";
  String? selectedVehicleType;
  List<LocationsHost> listLocation = [];
  RxString selectedOdometerId = "".obs;
  RxString selectedFueltypeid = "".obs;
  String? selectedMake;
  String? selectedModel;
  XFile? docementsImage;
  String? frontImageBase64fordoec;
  List<String> serviceTypeList = ["Booking", "Sale", "Rent"];
  List<Getodometer> listSpeedOdometer = [];
  List<FuelType> fuelTypeList = [];
  List<GetYearModel> getYearVechileList = [];
  List<ItemTypes> vehicleListItemType = [];
  List<Amenities> listAmenities = <Amenities>[].obs;
  List<LocationsHost> listVehicleLocation = [];
  late Locations location;
  late LocationsHost locationsHost;
  List<CancellationPolicies> listCancellationPoliciesVehcile = [];
  List<AddRules> listAddRules = [];
  List<CancellationPolicies> listAddPolicy = [];
  List selectedAmenitiesList = [];
  List selectedRulesList = [];
  GoogleMapController? mapController;
  RxString selectedLat = "".obs;
  RxString selectedLong = "".obs;
  ItemTypeModel? itemTypeModel;
  CategoryModel? categoryModel;
  SubCategoryModel? subCategoryModel;
  Odometer? odometer;
  FuelTypeModel? fuelTypeModel;
  GetYearModel? getYearModel;
  AmenitiesModel? vehicleAmenitiesModel;
  List<Amenities> vehicleListAmenities = <Amenities>[].obs;
  CancellationPoliciesModel? vechileCancellationPoliciesModel;
  List<CancellationPolicies> vechilelistCancellationPolicies = [];
  TextEditingController textEditingControllerTitle = TextEditingController();
  TextEditingController textEditingControllerEditTitle =
      TextEditingController();
  TextEditingController textEditingControllerDesc = TextEditingController();
  TextEditingController textEditingControllerEditDesc = TextEditingController();
  TextEditingController textEditingControllerArea = TextEditingController();
  TextEditingController textEditingControllerAddress = TextEditingController();
  TextEditingController textEditingControllerEditAddress =
      TextEditingController();
  TextEditingController textEditingControllerPrice = TextEditingController();
  TextEditingController textEditingControllerEditPrice =
      TextEditingController();
  TextEditingController textEditingControllerEditSecurityMoney =
      TextEditingController();
  TextEditingController textEditingControllersaddSecurityMoney =
      TextEditingController();
  TextEditingController textEditingControllerZip = TextEditingController();
  TextEditingController textEditingControllerEditZip = TextEditingController();
  TextEditingController textEditingControllerCountry = TextEditingController();
  TextEditingController textEditingControllerEditCountry =
      TextEditingController();
  TextEditingController textEditingControllerState = TextEditingController();
  TextEditingController textEditingControllerEditState =
      TextEditingController();
  TextEditingController textEditingControllerCity = TextEditingController();
  TextEditingController textEditingControllerEditCity = TextEditingController();
  TextEditingController textEditingControllerDoorstepPrice =
      TextEditingController();
  TextEditingController textEditingControllerSecurityBoatPrice =
      TextEditingController();
  TextEditingController textEditingControllerVehicleAddRules =
      TextEditingController();
  TextEditingController textEditingControllerParkingAddRules =
      TextEditingController();
  TextEditingController textEditingControllerSpaceAddRules =
      TextEditingController();
  TextEditingController textEditingControllerSpaceCleaningFee =
      TextEditingController();
  TextEditingController textEditingControllerSpacePeopleCapicity =
      TextEditingController();
  TextEditingController textEditingControllerEditSpaceCleaningFee =
      TextEditingController();
  TextEditingController textEditingControllerSpaceDiscount =
      TextEditingController();
  TextEditingController textEditingControllerCleaningFee =
      TextEditingController();
  TextEditingController textEditingControllerAdditionalGusets =
      TextEditingController();
  TextEditingController textEditingControllerSecurityDeposit =
      TextEditingController();
  TextEditingController textEditingControllerWeekendPricing =
      TextEditingController();
  TextEditingController textEditingControllerWeekDiscount =
      TextEditingController();
  TextEditingController textEditingControllerEditWeekDiscount =
      TextEditingController();
  TextEditingController textEditingControllerMonthDiscount =
      TextEditingController();
  TextEditingController textEditingControllerEditMonthDiscount =
      TextEditingController();
  TextEditingController textEditingControllerFuturePrice =
      TextEditingController();
  TextEditingController textEditingControllerEditLicensePlate =
      TextEditingController();
  TextEditingController textEditingControllerLicensePlate =
      TextEditingController();
  TextEditingController textEditingControllerEditMinDays =
      TextEditingController();
  TextEditingController textEditingControllerMinDays = TextEditingController();
  TextEditingController textEditingControllerEditMinAge =
      TextEditingController();
  TextEditingController textEditingControllerMinAge = TextEditingController();
  String? insuranceCoverage;
  bool isSmokingAllowed = false;
  bool isInternationalTravelAllowed = false;
  TextEditingController seatcapicity = TextEditingController();
  DateRangePickerController dateRangePickerController =
      DateRangePickerController();
  var isloading = true.obs;
  var isvechileloading = true.obs;

  void setInsuranceCoverage(String? value) {
    insuranceCoverage = value;
    update();
  }

  void setSmokingAllowed(bool value) {
    isSmokingAllowed = value;
    update();
  }

  void setInternationalTravelAllowed(bool value) {
    isInternationalTravelAllowed = value;
    update();
  }

  var isloadingCat = true.obs;
  Transmission? transmission;
  List<Options> listTransmission = [];
  String? selectTransmission = "";
  String? selectfuelType = "";
  var isTransmission = true.obs;
  Future<void> getDataTransmission() async {
    isTransmission.value = true;
    var typeString = GetStorage().read("transmission");
    if (typeString == null) {
      var response3 = await httpGet(Config.odometermannual, {});
      if (response3 != null) {
        transmission = Transmission.fromJson(response3);
        listTransmission.assignAll(transmission!.data!.options!);
        GetStorage().write("transmission", response3);
        isTransmission.value = false;
      }
    } else {
      transmission = Transmission.fromJson(typeString);
      listTransmission.assignAll(transmission!.data!.options!);
      isTransmission.value = false;
    }
    update();
  }

  var isOdometer = true.obs;
  Future<void> getDataOdometerList() async {
    isOdometer.value = true;
    var typeString = GetStorage().read("odometer");
    if (typeString == null) {
      var response2 = await httpGet(Config.vechileOdometer, {});
      if (response2 != null) {
        odometer = Odometer.fromJson(response2);
        listSpeedOdometer.assignAll(odometer!.data!.odometerList!);
        GetStorage().write("odometer", response2);
        isOdometer.value = false;
      }
    } else {
      odometer = Odometer.fromJson(typeString);
      listSpeedOdometer.assignAll(odometer!.data!.odometerList!);
      isOdometer.value = false;
    }
    update();
  }

  Future<void> getDatafuelType() async {
    final storage = GetStorage();
    final cachedData = storage.read("getFueltype");
    if (cachedData == null) {
      var response = await httpGet(Config.fuelType, {});
      if (response != null) {
        try {
          fuelTypeModel = FuelTypeModel.fromJson(response);
          fuelTypeList.assignAll(fuelTypeModel!.fuelTypes);
          storage.write("getFueltype", response);
        } catch (e) {}
      }
    } else {
      try {
        fuelTypeModel = FuelTypeModel.fromJson(cachedData);
        fuelTypeList.assignAll(fuelTypeModel!.fuelTypes);
      } catch (e) {}
    }
    update();
  }

  void cleanNumericInput(TextEditingController controller, String value) {
    if (value.isNotEmpty && !RegExp(r'^\d*\.?\d*$').hasMatch(value)) {
      String cleanedText = value.replaceAll(RegExp(r'[^\d.]'), '');
      if (RegExp(r'\..*\.').hasMatch(cleanedText)) {
        cleanedText = cleanedText.replaceFirst(RegExp(r'\.$'), '');
      }
      controller.text = cleanedText;
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: cleanedText.length),
      );
    }
  }

  var isloadingType = false.obs;
  Future<void> getDataItemType() async {
    isloadingType.value = true;
    var response2 = await httpGet(Config.itemsType, {});
    if (response2 != null) {
      itemTypeModel = ItemTypeModel.fromJson(response2);
      update();
      isloadingType.value = false;
      vehicleListItemType.assignAll(itemTypeModel!.data!.itemTypes!);
      GetStorage().write("vehicleStr", response2);
    }
    update();
  }

  var isAmentiesloading = true.obs;
  Future<void> getDataAmenties() async {
    isAmentiesloading.value = true;
    GetStorage().read("amenitiesVechicle");
    var response = await httpGet(Config.amenities, {});
    if (response != null) {
      amenitiesModel = AmenitiesModel.fromJson(response);
      update();
      vehicleListAmenities.assignAll(amenitiesModel!.data!.amenities!);
      GetStorage().write("amenitiesVechicle", response);
      isAmentiesloading.value = false;
    }
    update();
  }

  List<MakeTypes> listMakesType = [];
  List<Models> listModelType = [];
  var isMakeModel = true.obs;
  var isMakeModelonTap = true.obs;
  Future<void> getVehicleDataMakeModel() async {
    isMakeModel.value = true;
    var response = await httpGet(Config.getMakesModel, {});
    if (response != null) {
      getMakeModel = GetMakeModel.fromJson(response);
      update();
      if (getMakeModel!.data != null) {
        listMakesType.assignAll(getMakeModel!.data!.makesTypes ?? []);
        listModelType.clear();
        for (var makeType in listMakesType) {
          listModelType.addAll(makeType.models ?? []);
        }
      }
    }
    isMakeModel.value = false;
    update();
  }

  Future<void> getVehicleDataMakeModelforOnTap(value) async {
    isMakeModelonTap.value = true;
    showLoading();
    var response = await httpGet(
        Config.getMakesModel, {"type_id": "${value == "" ? "" : value}"});
    if (response != null) {
      getMakeModel = GetMakeModel.fromJson(response);
      update();
      if (getMakeModel!.data != null) {
        listMakesType.assignAll(getMakeModel!.data!.makesTypes ?? []);
        listModelType.clear();
        closeLoading();
        for (var makeType in listMakesType) {
          listModelType.addAll(makeType.models ?? []);
        }
      }
    }
    isMakeModelonTap.value = false;
    closeLoading();
    update();
  }

  Future<void> getVehicleDataMakeModelforEditinitial(value) async {
    isMakeModel.value = true;
    var response = await httpGet(
        Config.getMakesModel, {"type_id": "${value == "" ? "" : value}"});
    if (response != null) {
      getMakeModel = GetMakeModel.fromJson(response);
      update();
      if (getMakeModel!.data != null) {
        listMakesType.assignAll(getMakeModel!.data!.makesTypes ?? []);
        listModelType.clear();
        for (var makeType in listMakesType) {
          listModelType.addAll(makeType.models ?? []);
        }
      }
    }
    isMakeModel.value = false;
    update();
  }

  var isLoactionloading = true.obs;
  RxBool isload = true.obs;
  Future<void> getDataYourLocation() async {
    var response = await httpGet(Config.yourLocation, {});
    if (response != null) {
      locationsHostModel = LocationsHostModel.fromJson(response);
      update();
      listLocation.assignAll(locationsHostModel!.data!.locations!);
      GetStorage().write("yourLocation", response);
    } else {}
    locationsModel = null;
    update();
  }

  var isPolicyloading = true.obs;
  Future<void> getCancellationPolicy() async {
    isPolicyloading.value = true;
    var response4 = await httpGet(Config.getCancellationPolicies, {});
    if (response4 != null) {
      cancellationPoliciesModel = CancellationPoliciesModel.fromJson(response4);
      update();
      listCancellationPoliciesVehcile
          .assignAll(cancellationPoliciesModel!.data!.cancellationPolicies!);
      GetStorage().write("cancellationPoliciesVech", response4);
      isPolicyloading.value = false;
    }
    update();
  }

  var isRuleloading = true.obs;
  Future<void> getRules() async {
    isRuleloading.value = true;
    var response4 = await httpGet(Config.getItemRules, {});
    if (response4 != null) {
      addRulesModel = AddRulesModel.fromJson(response4);
      update();
      listAddRules.assignAll(addRulesModel!.data!.addRules!);
      isRuleloading.value = false;
    }
    update();
  }

  String? selectedEditBookableCategoryId;
  String? selectedEditBookableSubCategoryId;
  MyItemsModel? myPropertiesModels;
  Map<String, dynamic> itemInfoDescription = {};
  Map<String, dynamic> itemInfoData = {};
  dynamic cleaningFee = "";

  Future<void> fetchItemData() async {
    cleanTextController();
    if (item != null) {
      if (item!.placeId != null) {
        selectedCityName = item!.placeId;
      }
      selectedVehicleType = item!.itemTypeId;
      if (item!.title != null) {
        textEditingControllerEditTitle.text = item!.title!;
      }
      if (item!.description != null) {
        textEditingControllerEditDesc.text = item!.description!;
      }
      if (item!.address != null) {
        textEditingControllerEditAddress.text = item!.address!;
      }
      if (item!.price != null) {
        textEditingControllerEditPrice.text = item!.price!;
      }
      if (item!.weeklyDiscount != null) {
        textEditingControllerEditWeekDiscount.text = item!.weeklyDiscount!;
      }
      if (item!.monthlyDiscount != null) {
        textEditingControllerEditMonthDiscount.text = item!.monthlyDiscount!;
      }
      if (item!.weeklyDiscountType != null) {
        selectedWeeklyDiscountType = item!.weeklyDiscountType!;
      }
      if (item!.monthlyDiscountType != null) {
        selectedMonthlyDiscountType = item!.monthlyDiscountType!;
      }
      if (item!.latitude != null) {
        selectedLat.value = item!.latitude!;
        update();
      }
      if (item!.longitude != null) {
        selectedLong.value = item!.longitude!;
        update();
      }
      if (item!.zipPostalCode != null) {
        textEditingControllerEditZip.text = item!.zipPostalCode!;
      }
      if (item!.stateRegion != null) {
        textEditingControllerEditState.text = item!.stateRegion!;
      }
      if (item!.city != null) {
        textEditingControllerEditCity.text = item!.city!;
      }
      if (item!.country != null) {
        textEditingControllerEditCountry.text = item!.country!;
      }
      if (item!.bookingPoliciesId != null) {
        selectedRadio = (item!.bookingPoliciesId!);
      }
      if (item!.amenitiesId != null) {
        selectedAmenitiesList = item!.amenitiesId!
            .split(",")
            .map((s) {
              try {
                return int.parse(s.trim());
              } catch (e) {
                return null;
              }
            })
            .where((id) => id != null)
            .toList();
      }
      if (item!.metaData != null && item!.itemInfo != null) {
        itemInfoDescription = json.decode(item!.metaData!);
        itemInfoData = json.decode(item!.itemInfo!);
        if (itemInfoDescription["rules"] != null) {
          selectedRulesList = itemInfoDescription["rules"];
        }
        if (itemInfoDescription["odometer"] != null) {
          selectedOdometerId.value = itemInfoDescription["odometer"];
        }
        if (itemInfoDescription["service_type"] != null) {
          serviceType = itemInfoDescription["service_type"].toString() != ""
              ? itemInfoDescription["service_type"].toString()
              : "booking";
          String value = serviceType!;
          convertFirstLettertoCapital =
              value[0].toUpperCase() + value.substring(1);
        }
        if (itemInfoDescription["category_id"] != null) {
          selectedMake = itemInfoDescription["category_id"].toString();
        }
        if (itemInfoDescription["subcategory_id"] != null) {
          selectedModel = itemInfoDescription["subcategory_id"].toString();
        }
        if (itemInfoDescription["year"] != null) {
          selectedYear = itemInfoDescription["year"];
        }
        if (itemInfoDescription["transmission"] != null) {
          selectTransmission = itemInfoDescription["transmission"];
        }
        if (itemInfoDescription["doorStep_price"] != null) {
          textEditingControllerDoorstepPrice.text =
              itemInfoDescription["doorStep_price"].toString();
        }
        if (itemInfoDescription["security_fee"] != null) {
          textEditingControllerSecurityDeposit.text =
              itemInfoDescription["security_fee"].toString();
        }
        if (itemInfoDescription["number_of_seats"] != null) {
          seatcapicity.text = itemInfoDescription["number_of_seats"].toString();
        }
        if (itemInfoDescription["fuel_type"] != null) {
          selectedFueltypeid.value =
              itemInfoDescription["fuel_type"].toString();
        }
        if (itemInfoData["license_plate"] != null) {
          textEditingControllerEditLicensePlate.text =
              itemInfoData["license_plate"].toString();
        }
        if (itemInfoData["min_rental_days"] != null) {
          textEditingControllerEditMinDays.text =
              itemInfoData["min_rental_days"].toString();
        }
        if (itemInfoData["insurance_coverage"] != null) {
          insuranceCoverage = itemInfoData["insurance_coverage"].toString();
        }
        if (itemInfoData["min_age"] != null) {
          textEditingControllerMinAge.text = itemInfoData["min_age"].toString();
        }
        if (itemInfoData["smoking_status"] != null) {
          isSmokingAllowed = itemInfoData["smoking_status"] == true ||
              itemInfoData["smoking_status"] == "true" ||
              itemInfoData["smoking_status"] == "1" ||
              itemInfoData["smoking_status"] == 1;
        } else {
          isSmokingAllowed = false;
        }

        if (itemInfoData["international_travel_status"] != null) {
          isInternationalTravelAllowed =
              itemInfoData["international_travel_status"] == true ||
                  itemInfoData["international_travel_status"] == "true" ||
                  itemInfoData["international_travel_status"] == "1" ||
                  itemInfoData["international_travel_status"] == 1;
        } else {
          isInternationalTravelAllowed = false;
        }
        update();
      }
    }
  }

  String vehicleHostMetaData() {
    Map<String, dynamic> map = {
      "rules": selectedRulesList,
      "doorStep_price": isCheckeddoorstep == true
          ? textEditingControllerDoorstepPrice.text
          : "",
      "security_fee": isCheckedSecurityDeposit == true
          ? textEditingControllerSecurityDeposit.text
          : "",
      "category_id": selectedMake ?? "",
      "subcategory_id": selectedModel ?? "",
      "odometer": selectedOdometerId.value,
      "year": selectedVechicleYear,
      "transmission": selectTransmission ?? "",
      "service_type": serviceType ?? "",
      "fuel_type_id": selectedFueltypeid.value,
      "number_of_seats": seatcapicity.text,
      "license_plate": textEditingControllerLicensePlate.text.isNotEmpty
          ? textEditingControllerLicensePlate.text
          : textEditingControllerEditLicensePlate.text,
      "min_rental_days": textEditingControllerMinDays.text.isNotEmpty
          ? textEditingControllerMinDays.text
          : textEditingControllerEditMinDays.text,
      "insurance_coverage": insuranceCoverage ?? "",
      "min_age":
          isAgeRestricted == true ? textEditingControllerMinAge.text : "",
      "smoking_status": isSmokingAllowed ? 1 : 0,
      "international_travel_status": isInternationalTravelAllowed ? 1 : 0,
    };
    String jsonString = jsonEncode(map);
    return jsonString;
  }

  Future<void> cleanTextController() async {
    textEditingControllerTitle.clear();
    textEditingControllerDesc.clear();
    textEditingControllerPrice.clear();
    textEditingControllerArea.clear();
    textEditingControllerWeekDiscount.clear();
    textEditingControllerMonthDiscount.clear();
    textEditingControllerAddress.clear();
    textEditingControllerCountry.clear();
    textEditingControllerState.clear();
    textEditingControllerCity.clear();
    textEditingControllerZip.clear();
    textEditingControllerEditAddress.clear();
    textEditingControllerEditCountry.clear();
    textEditingControllerEditState.clear();
    textEditingControllerEditCity.clear();
    textEditingControllerEditZip.clear();
    textEditingControllerAdditionalGusets.clear();
    textEditingControllerSecurityDeposit.clear();
    textEditingControllerCleaningFee.clear();
    textEditingControllerWeekendPricing.clear();
    textEditingControllerLicensePlate.clear();
    textEditingControllerEditLicensePlate.clear();
    textEditingControllerMinDays.clear();
    textEditingControllerEditMinDays.clear();
    textEditingControllerMinAge.clear();
    textEditingControllerEditMinAge.clear();
    insuranceCoverage = null;
    isSmokingAllowed = false;
    isInternationalTravelAllowed = false;
    selectedLat.value = "";
    selectedLong.value = "";
    selectedAmenitiesList = [];
    isCheckeddoorstep = false;
    isAgeRestricted = false;
    isCheckedSecurityDeposit = false;
    selectedCityName = "";
    selectedRulesList = [];
    selectedRadio = 1;
    selectedVehicleType = "";
    selectedMake = "";
    selectedModel = "";
    selectedYear = "";
    selectTransmission = "";
    selectedOdometerId.value = "";
    selectedFueltypeid.value = "";
    textEditingControllerDoorstepPrice.clear();
    seatcapicity.clear();
  }

  FetchItemId? fetchItemId;
  dynamic itemHostId;
  Future addItems() async {
    showLoading();
    Map? itemMap;
    try {
      itemMap = {
        "item_type_id": selectedVehicleType.toString().isEmpty
            ? ""
            : selectedVehicleType.toString(),
        "features_id": "$selectedAmenitiesList",
        "place_id": selectedCityName,
        "title": textEditingControllerTitle.text,
        "description": textEditingControllerDesc.text,
        "price": textEditingControllerPrice.text,
        "address": textEditingControllerAddress.text,
        "weekly_discount": textEditingControllerWeekDiscount.text,
        "weekly_discount_type": selectedWeeklyDiscountType,
        "monthly_discount": textEditingControllerMonthDiscount.text,
        "monthly_discount_type": selectedMonthlyDiscountType,
        "zip_postal_code": textEditingControllerZip.text,
        "country": textEditingControllerCountry.text.toString(),
        "state_region": textEditingControllerState.text.toString(),
        "city_name": textEditingControllerCity.text.toString(),
        "booking_policies_id": '1',
        "platitude": selectedLat.value,
        "plongitude": selectedLong.value,
        "metaData": vehicleHostMetaData(),
      };
      var response = await httpPost(Config.insertItem, itemMap);
      closeLoading();
      if (response != null) {
        if (response['status'] == 200) {
          fetchItemId = FetchItemId.fromJson(response);
          if (fetchItemId!.insertItemHost != null) {
            itemHostId = fetchItemId!.insertItemHost!.id!;
          }
          GetStorage().remove("dashboardItemdata");
          GetStorage().remove("dashboard");
          Get.to(() => const UploadImageScreen(mode: ScreenMode.add));
        } else {
          showErrorToastMessage(response['error']);
        }
      }
    } catch (e) {
      closeLoading();
    }
  }
  bool selectLocation = false;
  Future updateMethod() async {
    showLoading();
    Map? itemEditMap;
    itemEditMap = {};
    try {
      itemEditMap = {
        "id": item!.id.toString(),
        "item_type_id": selectedVehicleType.toString().isEmpty
            ? ""
            : selectedVehicleType.toString(),
        "features_id": "$selectedAmenitiesList",
        "place_id": selectedCityName.toString(),
        "title": textEditingControllerEditTitle.text,
        "description": textEditingControllerEditDesc.text,
        "price": textEditingControllerEditPrice.text,
        "address": textEditingControllerEditAddress.text,
        "platitude": selectedLat.value,
        "plongitude": selectedLong.value,
        "weekly_discount": textEditingControllerEditWeekDiscount.text,
        "weekly_discount_type": selectedWeeklyDiscountType,
        "monthly_discount": textEditingControllerEditMonthDiscount.text,
        "monthly_discount_type": selectedMonthlyDiscountType,
        "zip_postal_code": textEditingControllerEditZip.text.toString(),
        "country": textEditingControllerEditCountry.text.toString(),
        "state_region": textEditingControllerEditState.text.toString(),
        "city_name": textEditingControllerEditCity.text.toString(),
        "booking_policies_id": '1',
        "metaData": vehicleHostMetaData(),
      };
      var response = await httpPost(Config.editItem, itemEditMap);
      closeLoading();
      if (response != null) {
        if (response['status'] == 200) {
          removeDashBoardData();
          removeMyPostData();
          showToastMessage(response['message']);
          checkUpdateStep1 = true;
          GetStorage().remove("dashboardItemdata");
          GetStorage().remove("dashboard");
          update();
          selectLocation = false;
          Get.to(() => const EditVehicleHomeScreen())?.then((value) {
            item = null;
          });
        } else {
          showErrorToastMessage(response['error']);
        }
      }
    } catch (e) {
      closeLoading();
    }
  }

  updateUploadImage(ScreenMode mode) async {
    showLoading();
    Map map = {
      "id": (item?.id ?? itemHostId).toString(),
      "front_image": frontImageBase64 ?? "",
      "front_image_doc": frontImageBase64fordoec ?? "",
      "gallery_image": galleryImageBase64List.isEmpty
          ? ""
          : galleryImageBase64List.join("##"),
      "gallery_image_delete":
          listDeleteImages.isEmpty ? "" : listDeleteImages.toString(),
    };
    var response = await httpPost(Config.addEditItemImage, map);
    closeLoading();
    if (response != null) {
      if (response['status'] == 200) {
        removeDashBoardData();
        removeMyPostData();
        showToastMessage(response['message']);
        GetStorage().remove("dashboardItemdata");
        GetStorage().remove("dashboard");
        checkUpdateStep2 = true;
        if (mode == ScreenMode.add) {
          Get.to(() => const BottomHost(initialIndex: 0));
        } else if (mode == ScreenMode.edit) {
          Get.to(() => const EditVehicleHomeScreen())?.then((value) {
            item = null;
          });
        }
        galleryImageBase64List.clear();
      } else {
        showErrorToastMessage(response['error']);
      }
    }
  }

  void onMapCreated(GoogleMapController controller) {
    if (mapController != null) {
      mapController!.dispose();
    }
    mapController = controller;
  }

  void zoomIn() {
    mapController?.animateCamera(
      CameraUpdate.zoomIn(),
    );
  }
  void zoomOut() {
    mapController?.animateCamera(
      CameraUpdate.zoomOut(),
    );
  }

  void updateMapLocationForSeachWithAutoSuggestation() {
    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLng(
          parseLatLng(
            selectedLat.value,
            selectedLong.value,
          )!,
        ),
      );
    }
  }

  var markers = <Marker>{}.obs;
  late BitmapDescriptor searchMarkerIcon;
  late LatLng initialPosition;
  Future<void> updateMapLocation(LatLng newPosition, ScreenMode mode) async {
    selectedLat.value = newPosition.latitude.toString();
    selectedLong.value = newPosition.longitude.toString();
    await getPlaceDetailFromLatLng(
      newPosition.latitude,
      newPosition.longitude,
      mode,
    );
  }

  Future<void> getPlaceDetailFromId(placeId, ScreenMode mode) async {
    final request =
        'https://maps.googleapis.com/maps/api/geocode/json?place_id=$placeId&key=${Config.googleKey}';
    final response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        final components =
            result['results'][0]['address_components'] as List<dynamic>;
        String? city;
        String? zipCode;
        String? country;
        String? state;
        for (var component in components) {
          if (component['types'].contains('postal_code')) {
            zipCode = component['long_name'];
          }
          if (component['types'].contains('country')) {
            country = component['long_name'];
          }
          if (component['types'].contains('administrative_area_level_1')) {
            state = component['long_name'];
          }
          if (component['types'].contains('locality') ||
              component['types'].contains('administrative_area_level_3')) {
            city = component['long_name'];
          }
        }
        if (zipCode != null) {
          if (mode == ScreenMode.add) {
            textEditingControllerZip.text = zipCode;
          } else if (mode == ScreenMode.edit) {
            textEditingControllerEditZip.text = zipCode;
          }
        }
        if (country != null) {
          if (mode == ScreenMode.add) {
            textEditingControllerCountry.text = country;
          } else if (mode == ScreenMode.edit) {
            textEditingControllerEditCountry.text = country;
          }
        }
        if (state != null) {
          if (mode == ScreenMode.add) {
            textEditingControllerState.text = state;
          } else if (mode == ScreenMode.edit) {
            textEditingControllerEditState.text = state;
          }
        }
        if (city != null) {
          if (mode == ScreenMode.add) {
            textEditingControllerCity.text = city;
          } else if (mode == ScreenMode.edit) {
            textEditingControllerEditCity.text = city;
          }
        }
      } else {
        throw Exception('Failed to fetch suggestion');
      }
    } else {
      throw Exception('Failed to fetch place details');
    }
  }

  Future<String> getMainAddress(double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=${Config.googleKey}'));
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        List<dynamic> addressComponents =
            result['results'][0]['address_components'];
        for (var component in addressComponents) {
          if (component['types'].contains('street_address')) {
            return component['long_name'];
          }
        }
        return result['results'][0]['formatted_address'];
      } else {
        throw Exception('Failed to fetch address');
      }
    } else {
      throw Exception('Failed to fetch address');
    }
  }

  Future<void> getPlaceDetailFromLatLng(
      double lat, double lng, ScreenMode mode) async {
    final request =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${Config.googleKey}';
    final response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        final placeId = result['results'][0]['place_id'];
        await getPlaceDetailFromId(placeId, mode);
      } else {
        throw Exception('Failed to fetch place details');
      }
    } else {
      throw Exception('Failed to fetch place details');
    }
  }

  LatLng? parseLatLng(String? latitude, String? longitude) {
    try {
      if (latitude != null && longitude != null) {
        update();
        return LatLng(double.parse(latitude), double.parse(longitude));
      }
    } catch (e) {
      //
    }
    return null;
  }

  void validateprice({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required ScreenMode mode,
    VoidCallback? onNextButtonPressed,
    bool isVehicle = false,
    bool isAddItems = false,
  }) {
    String price = mode == ScreenMode.edit
        ? textEditingControllerEditPrice.text
        : textEditingControllerPrice.text;
    String weekDiscount = mode == ScreenMode.add
        ? textEditingControllerWeekDiscount.text
        : textEditingControllerEditWeekDiscount.text;
    String monthDiscount = mode == ScreenMode.add
        ? textEditingControllerMonthDiscount.text
        : textEditingControllerEditMonthDiscount.text;
    num? priceValue = num.tryParse(price);
    num? weeklyDiscount = num.tryParse(weekDiscount);
    num? monthlyDiscount = num.tryParse(monthDiscount);
    if (priceValue == null) {
      showErrorToastMessage("The Price field must be a Number".tr);
      return;
    }
    if (priceValue == 0) {
      showErrorToastMessage("The Price should not be Zero".tr);
      return;
    }
    if (weeklyDiscount != null && weeklyDiscount > 90) {
      showErrorToastMessage("Weekly Discount cannot exceed 90%");
      return;
    }
    if (monthlyDiscount != null && monthlyDiscount > 90) {
      showErrorToastMessage("Monthly Discount cannot exceed 90%");
      return;
    }
    try {
      if (formKey.currentState!.validate()) {
        if (mode == ScreenMode.edit) {
          onNextButtonPressed!();
        } else {
          Get.to(() => const LocationScreenHost(
                mode: ScreenMode.add,
              ));
        }
      }
    } catch (e) {
      //
    }
  }

  void validateLocation({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required ScreenMode mode,
    VoidCallback? onNextButtonPressed,
    bool isVehicle = false,
    bool isboat = false,
    bool isAddItem = false,
  }) {
    if (mode == ScreenMode.edit
        ? textEditingControllerEditAddress.text.isEmpty
        : textEditingControllerAddress.text.isEmpty) {
      showErrorToastMessage("Enter the address field".tr);
    }
    if (selectedCityName == null) {
      showErrorToastMessage("Please Select Location".tr);
      return;
    }
    try {
      if (formKey.currentState!.validate()) {
        if (mode == ScreenMode.edit) {
          onNextButtonPressed!();
        } else {
          Get.to(() => const VehicleFeaturesScreen(
                mode: ScreenMode.add,
              ));
        }
      }
    } catch (e) {
      //
    }
  }

  void validateAndNavigate({
    BuildContext? context,
    GlobalKey<FormState>? formKey,
    ScreenMode? mode,
    VoidCallback? onNextButtonPressed,
    TextEditingController? titleController,
    TextEditingController? areaController,
    TextEditingController? descriptionController,
    Widget? navigateToScreen,
  }) {
    String title = titleController!.text;
    String area = areaController?.text ?? "455";
    String description = descriptionController!.text;
    String licensePlate = mode == ScreenMode.edit
        ? textEditingControllerEditLicensePlate.text
        : textEditingControllerLicensePlate.text;
    String minRentalDays = mode == ScreenMode.edit
        ? textEditingControllerEditMinDays.text
        : textEditingControllerMinDays.text;
    if (licensePlate.isEmpty) {
      showErrorToastMessage("Please enter the License Plate Number".tr);
      return;
    }
    if (minRentalDays.isEmpty) {
      showErrorToastMessage("Please enter the Minimum Rental Days".tr);
      return;
    }
    if (!RegExp(r'^\d+$').hasMatch(minRentalDays)) {
      showErrorToastMessage("Minimum Rental Days must be a valid number".tr);
      return;
    }
    if (int.parse(minRentalDays) <= 0) {
      showErrorToastMessage("Minimum Rental Days must be greater than 0".tr);
      return;
    }
    if (insuranceCoverage == null) {
      showErrorToastMessage("Please select an Insurance Coverage option".tr);
      return;
    }
    if (isAgeRestricted && textEditingControllerMinAge.text.isEmpty) {
      showErrorToastMessage("Please enter the Minimum Age".tr);
      return;
    }
    if (isAgeRestricted &&
        !RegExp(r'^\d+$').hasMatch(textEditingControllerMinAge.text)) {
      showErrorToastMessage("Minimum Age must be a valid number".tr);
      return;
    }
    if (isAgeRestricted && int.parse(textEditingControllerMinAge.text) < 18) {
      showErrorToastMessage("Minimum Age must be at least 18".tr);
      return;
    }

    ValidationService.validateAndNavigate(
      title: title,
      area: area,
      description: description,
      showErrorToastMessage: showErrorToastMessage,
      navigateToNextScreen: () {
        try {
          if (formKey!.currentState!.validate()) {
            if (mode == ScreenMode.edit) {
              onNextButtonPressed!();
            } else {
              if (navigateToScreen != null) {
                Get.to(() => navigateToScreen);
              }
            }
          }
        } catch (e) {
          //
        }
      },
    );
  }

  void validateType({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required ScreenMode mode,
    VoidCallback? onNextButtonPressed,
  }) {
    if (selectedVehicleType == null || selectedVehicleType.toString().isEmpty) {
      showErrorToastMessage("Please Select Vehicle type".tr);
      return;
    }
    if (selectedMake == null || selectedMake!.toString().isEmpty) {
      showErrorToastMessage("Please Select Make".tr);
      return;
    }
    if (selectedModel == null || selectedModel!.toString().isEmpty) {
      showErrorToastMessage("Please Select Model".tr);
      return;
    }
    if (selectTransmission == null || selectTransmission!.isEmpty) {
      showErrorToastMessage("Please Select Transmission option".tr);
      return;
    }
    if (selectedOdometerId.value == "") {
      showErrorToastMessage("Please Select Odometer option".tr);
      return;
    }
    if (selectedFueltypeid.value == "") {
      showErrorToastMessage("Please select the fuel type".tr);
      return;
    }
    if (seatcapicity.text.isEmpty) {
      showErrorToastMessage("Please Enter the number of seats".tr);
      return;
    }
    if (mode == ScreenMode.edit) {
      onNextButtonPressed?.call();
    } else {
      Get.to(() => const VehcileDescriptionScreen(
            mode: ScreenMode.add,
          ));
    }
  }

  dynamic dashBoardData;
  void readDashBoardData() {
    dashBoardData = GetStorage().read("vehicleDashBoard");
  }

  void writeDashBoardData(data) {
    GetStorage().write("vehicleDashBoard", data);
  }

  dynamic myPostData;
  void readMyPostData() {
    myPostData = GetStorage().read("vehicleMyPost");
  }

  void writeMyPost(data) {
    GetStorage().write("vehicleMyPost", data);
  }

  void removeDashBoardData() {
    GetStorage().remove("vehicleDashBoard");
  }

  void removeMyPostData() {
    GetStorage().remove("vehicleMyPost");
  }
}
