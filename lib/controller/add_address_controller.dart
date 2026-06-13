import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/door_step_address_model.dart';
import 'package:carvy/model/login_model.dart';
import 'package:carvy/services/geocoding_service.dart';
import 'package:carvy/services/location_service.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import 'package:carvy/work_space.dart';

class AddAddressController extends GetxController implements GetxService {
  TextEditingController houseFloorNumberController = TextEditingController();
  TextEditingController buildingBlockNumberController = TextEditingController();
  TextEditingController landmarkController = TextEditingController();
  TextEditingController fullAddressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();

  RxString doorSteplatitude = "".obs;
  RxString doorSteplongitude = "".obs;
  String? selectedLat, selectedLong;
  var markers = <Marker>{}.obs;
  RxString fulladdress = "".obs;
  var preventDate = false.obs;

  RxString addressText = "".obs;
  RxBool isAddressLoading = false.obs;
  bool _isInternalAddressWrite = false;

  static const List<String> _knownTestAddressMarkers = [
    'los angeles',
    'mountain view',
    '90001',
    '123 main street',
    'california',
  ];

  @override
  void onInit() {
    super.onInit();
    fullAddressController.addListener(_syncAddressTextFromController);
  }

  @override
  void onClose() {
    fullAddressController.removeListener(_syncAddressTextFromController);
    super.onClose();
  }

  void _syncAddressTextFromController() {
    if (_isInternalAddressWrite) return;
    final txt = fullAddressController.text.trim();
    if (addressText.value != txt) {
      addressText.value = txt;
      update();
    }
  }

  /// Centre carte neutre (Maroc) — pas d'adresse texte affichée tant que le GPS n'a pas répondu.
  static const double fallbackMapLat = 31.7917;
  static const double fallbackMapLng = -7.0926;

  LatLng get doorstepMapCenter {
    final lat = double.tryParse(doorSteplatitude.value);
    final lng = double.tryParse(doorSteplongitude.value);
    if (lat != null && lng != null) return LatLng(lat, lng);
    return const LatLng(fallbackMapLat, fallbackMapLng);
  }

  bool get hasValidDoorstepCoordinates {
    final lat = double.tryParse(doorSteplatitude.value);
    final lng = double.tryParse(doorSteplongitude.value);
    return lat != null && lng != null;
  }

  bool get canConfirmDoorstepAddress {
    if (!hasValidDoorstepCoordinates) return false;
    if (isAddressLoading.value) return false;
    if (addressText.value.trim().isEmpty &&
        fullAddressController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  bool _isLikelyTestOrStaleAddress(String? address) {
    if (address == null || address.trim().isEmpty) return false;
    final lower = address.toLowerCase();
    return _knownTestAddressMarkers.any(lower.contains);
  }

  Future<void> _clearStaleAddressCache() async {
    await GetStorage().remove("customerAddress");
    clearAddressFields();
  }

  void _applyResolvedAddress(ResolvedAddress resolved) {
    final display = shortenAddress(resolved.fullAddress, 120);
    _isInternalAddressWrite = true;
    fullAddressController.text = display;
    _isInternalAddressWrite = false;
    addressText.value = display;

    if (resolved.city.isNotEmpty) cityController.text = resolved.city;
    if (resolved.state.isNotEmpty) stateController.text = resolved.state;
    if (resolved.country.isNotEmpty) countryController.text = resolved.country;
    if (resolved.postalCode.isNotEmpty) {
      postalCodeController.text = resolved.postalCode;
    }

    fulladdress.value = display.trim();
  }

  /// Reverse geocoding (package geocoding) + remplissage des champs adresse.
  Future<void> resolveAddressFromLatLng(double lat, double lng) async {
    isAddressLoading.value = true;
    _isInternalAddressWrite = true;
    fullAddressController.clear();
    _isInternalAddressWrite = false;
    addressText.value = "";
    update();

    try {
      final resolved = await GeocodingService.reverseGeocode(lat, lng);
      if (resolved == null || resolved.fullAddress.trim().isEmpty) {
        throw Exception('Reverse geocoding returned no address');
      }
      _applyResolvedAddress(resolved);
    } catch (e, st) {
      debugPrint('resolveAddressFromLatLng: $e\n$st');
      _isInternalAddressWrite = true;
      fullAddressController.clear();
      _isInternalAddressWrite = false;
      addressText.value = "";
      fulladdress.value = "";
    } finally {
      isAddressLoading.value = false;
      update();
    }
  }

  Future<({double lat, double lng})?> fetchCurrentLocation(
    BuildContext context,
  ) async {
    try {
      showLoading();
      final position = await LocationService.getCurrentPositionWithChecks(
        context,
        timeLimit: LocationService.defaultTimeLimit,
      );
      closeLoading();

      if (position == null) {
        return null;
      }

      doorSteplatitude.value = position.latitude.toString();
      doorSteplongitude.value = position.longitude.toString();
      await resolveAddressFromLatLng(position.latitude, position.longitude);
      update();
      return (lat: position.latitude, lng: position.longitude);
    } catch (e) {
      closeLoading();
      debugPrint('fetchCurrentLocation: $e');
      return null;
    }
  }

  Future<void> getUserLocationForBetterSearch(BuildContext context) async {
    await fetchCurrentLocation(context);
  }

  void setLoginModel(LoginModel model) {
    loginModel = model;
  }

  String shortenAddress(String address, int maxLength) {
    if (address.length <= maxLength) {
      return address;
    }
    return '${address.substring(0, maxLength)}...';
  }

  AddressResponse? addressResponse;

  Future<void> updateAddress(BuildContext context) async {
    if (isAddressLoading.value) {
      showErrorToastMessage("Retrieving your location...".tr);
      return;
    }
    if (!hasValidDoorstepCoordinates ||
        doorSteplatitude.value.isEmpty ||
        doorSteplongitude.value.isEmpty) {
      showErrorToastMessage("Please select the address from the map.".tr);
      return;
    }
    if (fullAddressController.text.trim().isEmpty &&
        addressText.value.trim().isEmpty) {
      showErrorToastMessage("Please select the address from the map.".tr);
      return;
    }

    if (houseFloorNumberController.text.isEmpty) {
      showErrorToastMessage(
          "Please enter the house number and floor number.".tr);
      return;
    }

    if (fullAddressController.text.isEmpty) {
      showErrorToastMessage("Please select the address from the map.".tr);
      return;
    }

    final map = {
      "house_floor_number": houseFloorNumberController.text,
      "building_block_number": buildingBlockNumberController.text,
      "landmark": landmarkController.text,
      "full_address": fullAddressController.text,
      "city": cityController.text,
      "state": stateController.text,
      "country": countryController.text,
      "postal_code": postalCodeController.text,
      "doorstep_latitude": doorSteplatitude.value,
      "doorstep_longitude": doorSteplongitude.value,
    };

    try {
      showLoading();
      final response = await httpPost(Config.saveDoorStepAddress, map);
      closeLoading();

      if (response != null && response["status"] == 200) {
        showToastMessage("${response["message"]}");
        await getDoorStepAddressp(false);
        generalController.currentIndex.value = 0;

        if (preventDate.value == true) {
          Get.back();
          Get.back();
          return;
        }
        Get.to(const HomeMain(initialIndex: 0));
      } else {
        showErrorToastMessage("${response?["error"] ?? "Error".tr}");
      }
    } catch (e) {
      debugPrint('updateAddress: $e');
      closeLoading();
    }
  }

  /// Charge l'adresse depuis l'API (plus de cache local seul qui masque la réalité).
  Future<void> getDoorStepAddressp(bool? sholoading) async {
    try {
      if (sholoading == true) {
        showLoading();
      }

      final response = await httpPost(Config.getDoorStepAddress, {});

      if (sholoading == true) {
        closeLoading();
      }

      if (response != null &&
          response["status"] == 200 &&
          response["data"] != null) {
        final doorStep = response["data"]?["door_step_address"];
        final fullAddr = doorStep?["full_address"]?.toString();
        if (_isLikelyTestOrStaleAddress(fullAddr)) {
          await _clearStaleAddressCache();
          if (sholoading == true) {
            showErrorToastMessage(
                "Please select the address from the map.".tr);
          }
          return;
        }

        await GetStorage().write("customerAddress", response);
        addressResponse = AddressResponse.fromJson(
          Map<String, dynamic>.from(response as Map),
        );
        setAddressData();
        if (sholoading == true && response["message"] != null) {
          showToastMessage("${response["message"]}");
        }
      } else {
        await _clearStaleAddressCache();
      }
    } catch (e) {
      debugPrint("getDoorStepAddressp: $e");
      if (sholoading == true) {
        closeLoading();
        showErrorToastMessage("Something went wrong. Please try again.".tr);
      }
      await _clearStaleAddressCache();
    }
  }

  void setAddressData() {
    final data = addressResponse?.data?.doorStepAddress;
    if (data == null) return;

    if (_isLikelyTestOrStaleAddress(data.fullAddress?.toString())) {
      GetStorage().remove("customerAddress");
      clearAddressFields();
      return;
    }

    houseFloorNumberController.text =
        data.houseFloorNumber?.toString() ?? '';
    buildingBlockNumberController.text =
        data.buildingBlockNumber?.toString() ?? '';
    landmarkController.text = data.landmark?.toString() ?? '';
    fullAddressController.text = data.fullAddress?.toString() ?? '';
    cityController.text = data.city?.toString() ?? '';
    stateController.text = data.state?.toString() ?? '';
    countryController.text = data.country?.toString() ?? '';
    postalCodeController.text = data.postalCode?.toString() ?? '';
    doorSteplatitude.value = data.doorstepLatitude?.toString() ?? "";
    doorSteplongitude.value = data.doorstepLongitude?.toString() ?? "";
    addressText.value = fullAddressController.text;
    fulladdress.value =
        "${houseFloorNumberController.text.isNotEmpty ? houseFloorNumberController.text : ""} "
        "${buildingBlockNumberController.text.isNotEmpty ? buildingBlockNumberController.text : ""} "
        "${landmarkController.text.isNotEmpty ? landmarkController.text : ""} "
        "${fullAddressController.text}".trim();

    update();
  }

  void clearAddressFields() {
    houseFloorNumberController.clear();
    buildingBlockNumberController.clear();
    landmarkController.clear();
    fullAddressController.clear();
    cityController.clear();
    stateController.clear();
    countryController.clear();
    postalCodeController.clear();
    doorSteplatitude.value = "";
    doorSteplongitude.value = "";
    addressText.value = "";
    isAddressLoading.value = false;
    fulladdress.value = "";
    addressResponse = null;
    update();
  }
}
