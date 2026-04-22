import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;
import 'package:carvy/api/config.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/door_step_address_model.dart';
import 'package:carvy/model/login_model.dart';
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
  /// Vide jusqu'à géolocalisation / sélection carte (pas d'adresse fictive type Los Angeles).
  RxString doorSteplatitude = "".obs;
  RxString doorSteplongitude = "".obs;
  String? selectedLat, selectedLong;
  var markers = <Marker>{}.obs;
  RxString fulladdress = "".obs;
  var preventDate = false.obs;

  /// Ligne affichée sous la carte ; mise à jour après géocodage.
  RxString addressText = "".obs;
  RxBool isAddressLoading = false.obs;
  bool _isInternalAddressWrite = false;

  @override
  void onInit() {
    super.onInit();
    // Synchronise le champ texte (saisie / autocomplete) avec la valeur réactive affichée.
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

  /// Cible caméra si pas encore de coordonnées précises (centre Maroc, pas d'adresse affichée).
  static const double fallbackMapLat = 31.7917;
  static const double fallbackMapLng = -7.0926;

  /// Centre carte : coordonnées porte-à-porte si valides, sinon [fallbackMapLat]/[fallbackMapLng].
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

  /// Enregistrement autorisé uniquement avec coordonnées valides et adresse résolue.
  bool get canConfirmDoorstepAddress {
    if (!hasValidDoorstepCoordinates) return false;
    if (isAddressLoading.value) return false;
    if (addressText.value.trim().isEmpty &&
        fullAddressController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  /// Géocodage inverse + remplissage des champs ; notifie l'UI (GetBuilder/update + Rx).
  Future<void> resolveAddressFromLatLng(double lat, double lng) async {
    isAddressLoading.value = true;
    addressText.value = "";
    update();
    try {
      await getPlaceDetailFromLatLng(lat, lng);
      final mainAddress =
          await getMainAddress(lat.toString(), lng.toString());
      final short = shortenAddress(mainAddress, 75);
      _isInternalAddressWrite = true;
      fullAddressController.text = short;
      _isInternalAddressWrite = false;
      addressText.value = short;
    } catch (e, st) {
      debugPrint('resolveAddressFromLatLng: $e\n$st');
      _isInternalAddressWrite = true;
      fullAddressController.clear();
      _isInternalAddressWrite = false;
      addressText.value = "";
    } finally {
      isAddressLoading.value = false;
      update();
    }
  }

  Future<void> getPlaceDetailFromLatLng(double lat, double lng) async {
    final request =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${Config.googleKey}';
    final response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        final placeId = result['results'][0]['place_id'];
        await getPlaceDetailFromId(
          placeId,
        );
      } else {
        throw Exception('Failed to fetch place details');
      }
    } else {
      throw Exception('Failed to fetch place details');
    }
  }

  Future<void> getPlaceDetailFromId(placeId) async {
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
        String? buildingNumber;
        for (var component in components) {
          final types = component['types'] as List<dynamic>;
          if (types.contains('street_number')) {
            buildingNumber = component['long_name'];
          }

          if (types.contains('postal_code')) {
            zipCode = component['long_name'];

            postalCodeController.text = zipCode!;
          }
          if (types.contains('country')) {
            country = component['long_name'];

            countryController.text = country!;
          }
          if (types.contains('administrative_area_level_1')) {
            state = component['long_name'];
            stateController.text = state!;
          }
          if (types.contains('locality') ||
              types.contains('administrative_area_level_3')) {
            city = component['long_name'];
            cityController.text = city!;
          }
        }
      } else {
        throw Exception('Failed to fetch suggestion');
      }
    } else {
      throw Exception('Failed to fetch place details');
    }
  }

  Future<String> getMainAddress(latitude, longitude) async {
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

  Future<void> getUserLocationForBetterSearch(BuildContext context) async {
    try {
      showLoading();
      loc.Location location = loc.Location();
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

      loc.PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          closeLoading();
          showOpenAppSettingsDialog(
              context,
              "Location permission denied. Please go to settings and allow the location"
                  .tr);
          return;
        }
      }

      loc.LocationData locationData = await location
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
        doorSteplatitude.value = locationData.latitude.toString();
        doorSteplongitude.value = locationData.longitude.toString();
        await resolveAddressFromLatLng(
            locationData.latitude!, locationData.longitude!);
      } else {
        closeLoading();
        showErrorToastMessage("Failed to get current location.".tr);
      }
    } catch (e) {
      closeLoading();
    }
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

    var map = {
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
      // ========== MOCK DATA - OLD API CALL COMMENTED ==========
      // var response = await httpPost(Config.saveDoorStepAddress, map);

      // MOCK: Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // MOCK: Static success response for saving doorstep address
      var response = {
        "status": 200,
        "message": "Doorstep address saved successfully",
        "error": ""
      };
      // ========== END MOCK DATA ==========
      closeLoading();

      if (response != null && response["status"] == 200) {
        showToastMessage("${response["message"]}");
        GetStorage().remove("customerAddress");
        generalController.currentIndex.value = 0;

        if (preventDate.value == true) {
          Get.back();
          Get.back();
          getDoorStepAddressp(false);
          return;
        }
        Get.to(const HomeMain(initialIndex: 0));
      } else {
        showErrorToastMessage("${response["error"]}");
      }
    } catch (e) {
      print(e);
      closeLoading();
    }
  }

  Future<void> getDoorStepAddressp(bool? sholoading) async {
    try {
      var localData = GetStorage().read("customerAddress");
      if (sholoading == true) {
        showLoading();
      }
      if (localData == null) {
        // ========== MOCK DATA - OLD API CALL COMMENTED ==========
        // var response = await httpPost(Config.getDoorStepAddress, {});

        // MOCK: Simulate network delay
        await Future.delayed(const Duration(seconds: 1));

        // Pas d'adresse fictive : nouveaux utilisateurs démarrent sans lieu par défaut.
        var response = {
          "status": 200,
          "message": "No doorstep address saved",
          "error": "",
          "data": null,
        };
        // ========== END MOCK DATA ==========
        if (sholoading == true) {
          closeLoading();
        }
        if (response != null && response["status"] == 200) {
          if (response["data"] != null) {
            addressResponse = AddressResponse.fromJson(response);
            GetStorage().write("customerAddress", response);
            setAddressData();
            if (sholoading == true) {
              showToastMessage("${response["message"]}");
            }
          } else {
            print("Error: No valid data found in response.");
            if (sholoading == true) {}
          }
        } else {
          print("API Error: ${response?["error"] ?? "Unknown Error"}");
          if (sholoading == true) {}
        }
      } else {
        if (sholoading == true) {
          closeLoading();
        }
        addressResponse = AddressResponse.fromJson(localData);
        setAddressData();
      }
    } catch (e) {
      print("Exception: $e");
      if (sholoading == true) {
        closeLoading();
        showErrorToastMessage("Something went wrong. Please try again.");
      }
    }
  }

  void setAddressData() {
    var data = GetStorage().read("customerAddress");
    if (data != null) {
      clearAddressFields();
      AddressResponse? addressResponse = AddressResponse.fromJson(data);
      if (addressResponse.data?.doorStepAddress != null) {
        DoorStepAddress? doorStepAddress =
            addressResponse.data!.doorStepAddress;
        houseFloorNumberController.text =
            doorStepAddress?.houseFloorNumber?.toString() ?? '';
        buildingBlockNumberController.text =
            doorStepAddress?.buildingBlockNumber?.toString() ?? '';
        landmarkController.text = doorStepAddress?.landmark?.toString() ?? '';
        fullAddressController.text =
            doorStepAddress?.fullAddress?.toString() ?? '';
        cityController.text = doorStepAddress?.city?.toString() ?? '';
        stateController.text = doorStepAddress?.state?.toString() ?? '';
        countryController.text = doorStepAddress?.country?.toString() ?? '';
        postalCodeController.text =
            doorStepAddress?.postalCode?.toString() ?? '';
        doorSteplatitude.value =
            doorStepAddress?.doorstepLatitude?.toString() ?? "";
        doorSteplongitude.value =
            doorStepAddress?.doorstepLongitude?.toString() ?? "";
        addressText.value = fullAddressController.text;
        fulladdress.value =
            "${houseFloorNumberController.text.isNotEmpty ? houseFloorNumberController.text : ""} "
            "${buildingBlockNumberController.text.isNotEmpty ? buildingBlockNumberController.text : ""} "
            "${landmarkController.text.isNotEmpty ? landmarkController.text : ""} "
            "${fullAddressController.text}";

        update();
      }
    }
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
    update();
  }
}
