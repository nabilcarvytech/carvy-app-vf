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
  import 'package:flutter/material.dart';
import 'package:carvy/model/amenities_model.dart';
import 'package:carvy/model/cancellation_policies_model.dart';
import 'package:carvy/model/category_model.dart';
import 'package:carvy/model/fetch_item_id.dart';
import 'package:carvy/model/fuel_type_model.dart';
import 'package:carvy/model/get_year_model.dart';
import 'package:carvy/model/location_host_model.dart';
import 'package:carvy/model/locations_model.dart';
import 'package:carvy/model/make_model_vehicle.dart';
import 'package:carvy/model/make_type_model.dart';
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
import 'package:carvy/utils/calendar_block_reasons.dart';
import 'package:carvy/work_space.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';
import '../model/add_rules_model.dart';
import 'vehicle_controller.dart';

class AddItemsHostController extends GetxController implements GetxService {
  // Variable pour stocker le véhicule sélectionné lors de l'édition
  Items? item;
  // Variable pour sauvegarder l'ID du véhicule actuellement en cours d'édition
  String? currentVehicleId;
  
  bool isCheckeddoorstep = false;
  bool isCheckedSecurityDeposit = false;
  bool isAgeRestricted = false;
  RxBool isChecked1 = false.obs;
  RxBool isChecked2 = false.obs;
  /// Raison affichée / envoyée lors d'un blocage de dates (add-editCalender).
  RxString calendarBlockReason = CalendarBlockReasons.defaultReason.obs;
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
  
  // Listes pour gérer les images existantes (URLs) vs nouvelles images (XFile)
  // Images existantes chargées depuis le backend (URLs réseau)
  List<String> existingFrontImageUrls = [];
  List<String> existingGalleryImageUrls = [];
  
  // Liste des URLs d'images supprimées (pour les retirer lors de l'envoi PUT)
  List<String> deletedImageUrls = [];
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
  // Variable pour gérer le chargement lors de l'édition
  RxBool isLoadingEdit = false.obs;
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
  TextEditingController textEditingControllerEditYear = TextEditingController();
  TextEditingController textEditingControllerEditMileage = TextEditingController();
  // Livraison à domicile multi-destinations (jusqu'à 3 villes/zones)
  // Chaque entrée: { "location": <id>, "locationName": <name>, "price": <int> }
  RxList<Map<String, dynamic>> deliveryLocations =
      <Map<String, dynamic>>[].obs;
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

  TextEditingController part1Controller = TextEditingController();
  TextEditingController part1ControllerEdit = TextEditingController();
  TextEditingController part2Controller = TextEditingController();
  TextEditingController part2ControllerEdit = TextEditingController();
  TextEditingController part3Controller = TextEditingController();
  TextEditingController part3ControllerEdit = TextEditingController();

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

  // Ajoute une destination de livraison (max 3, sans doublon sur locationId)
  void addDeliveryLocation(String locationId, String locationName) {
    if (deliveryLocations.length >= 3) return;
    if (locationId.isEmpty) return;

    final alreadyExists = deliveryLocations.any((e) =>
        (e['location']?.toString() ?? '') == locationId.toString());
    if (alreadyExists) return;

    deliveryLocations.add({
      'location': locationId,
      'locationName': locationName,
      // Valeur par défaut (sera remplie via l'UI)
      'price': 0,
    });

    isCheckeddoorstep = true;
    update();
  }

  // Met à jour le prix d'une destination (index dans deliveryLocations)
  void updateDeliveryPrice(int index, String price) {
    if (index < 0 || index >= deliveryLocations.length) return;
    final parsedInt = int.tryParse(price) ??
        (double.tryParse(price)?.toInt() ?? 0);

    deliveryLocations[index]['price'] = parsedInt;
    update();
  }

  // Supprime une destination de livraison
  void removeDeliveryLocation(int index) {
    if (index < 0 || index >= deliveryLocations.length) return;
    deliveryLocations.removeAt(index);
    if (deliveryLocations.isEmpty) {
      isCheckeddoorstep = false;
    }
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
    try {
      final storage = GetStorage();
      final cached = storage.read("transmission");

      if (cached == null) {
        debugPrint('📡 [TRANSMISSION] Appel API GET transmission (Config.odometermannual)');
        var response3 = await httpGet(Config.odometermannual, {});
        debugPrint('📥 [TRANSMISSION] Réponse brute: $response3');

        if (response3 != null) {
          transmission = Transmission.fromJson(response3);
          listTransmission.assignAll(transmission!.data!.options ?? []);
          storage.write("transmission", response3);
        } else {
          debugPrint('⚠️ [TRANSMISSION] Réponse nulle lors du chargement des transmissions');
        }
      } else {
        debugPrint('📦 [TRANSMISSION] Chargement transmissions depuis le cache');
        transmission = Transmission.fromJson(cached);
        listTransmission.assignAll(transmission!.data!.options ?? []);
      }
    } catch (e, stack) {
      debugPrint('❌ [TRANSMISSION] Erreur lors du chargement des transmissions: $e');
      debugPrint('❌ [TRANSMISSION] Stack: $stack');
    } finally {
      isTransmission.value = false;
      update();
    }
  }

  var isOdometer = true.obs;
  Future<void> getDataOdometerList() async {
    isOdometer.value = true;
    try {
      final storage = GetStorage();
      final cached = storage.read("odometer");

      if (cached == null) {
        debugPrint('📡 [ODOMETER] Appel API GET odometer (Config.vechileOdometer)');
        var response2 = await httpGet(Config.vechileOdometer, {});
        debugPrint('📥 [ODOMETER] Réponse brute: $response2');

        if (response2 != null) {
          odometer = Odometer.fromJson(response2);
          listSpeedOdometer.assignAll(odometer!.data!.odometerList ?? []);
          storage.write("odometer", response2);
        } else {
          debugPrint('⚠️ [ODOMETER] Réponse nulle lors du chargement du kilométrage');
        }
      } else {
        debugPrint('📦 [ODOMETER] Chargement odometer depuis le cache');
        odometer = Odometer.fromJson(cached);
        listSpeedOdometer.assignAll(odometer!.data!.odometerList ?? []);
      }
    } catch (e, stack) {
      debugPrint('❌ [ODOMETER] Erreur lors du chargement du kilométrage: $e');
      debugPrint('❌ [ODOMETER] Stack: $stack');
    } finally {
      isOdometer.value = false;
      update();
    }
  }

  Future<void> getDatafuelType() async {
    try {
      final storage = GetStorage();
      final cachedData = storage.read("getFueltype");

      if (cachedData == null) {
        debugPrint('📡 [FUEL] Appel API GET fuel types (Config.fuelType)');
        var response = await httpGet(Config.fuelType, {});
        debugPrint('📥 [FUEL] Réponse brute: $response');

        if (response != null) {
          try {
            fuelTypeModel = FuelTypeModel.fromJson(response);
            fuelTypeList.assignAll(fuelTypeModel!.fuelTypes);
            storage.write("getFueltype", response);
          } catch (e) {
            debugPrint('❌ [FUEL] Erreur lors du parsing des types de carburant: $e');
          }
        } else {
          debugPrint('⚠️ [FUEL] Réponse nulle lors du chargement des types de carburant');
        }
      } else {
        try {
          debugPrint('📦 [FUEL] Chargement des types de carburant depuis le cache');
          fuelTypeModel = FuelTypeModel.fromJson(cachedData);
          fuelTypeList.assignAll(fuelTypeModel!.fuelTypes);
        } catch (e) {
          debugPrint('❌ [FUEL] Erreur lors du parsing du cache des types de carburant: $e');
        }
      }
    } catch (e, stack) {
      debugPrint('❌ [FUEL] Erreur lors du chargement des types de carburant: $e');
      debugPrint('❌ [FUEL] Stack: $stack');
    } finally {
      update();
    }
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

    try {
      // Appel réel au backend Node.js pour récupérer les types de véhicule (IDs MongoDB)
      // Endpoint: /api/v1/get-all-categories
      debugPrint('📡 [CATEGORIES] Appel API GET get-all-categories');
      final response = await httpGet(Config.itemsType, {});

      debugPrint('📥 [CATEGORIES] Réponse brute: $response');

      if (response != null &&
          response is Map<String, dynamic> &&
          response['status'] == 200 &&
          response['data'] != null) {
        // Utiliser le même modèle ItemTypeModel, qui gère déjà les IDs en String via .toString()
        // Structure attendue: { "status": 200, "data": { "itemTypes": [...] } }
        itemTypeModel = ItemTypeModel.fromJson(response);
        vehicleListItemType.assignAll(itemTypeModel!.data!.itemTypes ?? []);

        // 📚 DEBUG MISMATCH IDS - LOG DE LA LISTE DE RÉFÉRENCE DES TYPES
        debugPrint(
            '📚 [REF_API_DATA] Liste des types chargés depuis l\'API (MongoDB IDs) :');
        vehicleListItemType.forEach((element) {
          debugPrint(
              '   - ID: ${element.id} (Type: ${element.id.runtimeType}), Nom: ${element.name}');
        });

        // Log de confirmation
        debugPrint('✅ [CATEGORIES] Liste chargée depuis get-all-categories');
      } else {
        debugPrint(
            '⚠️ [CATEGORIES] Réponse invalide lors du chargement des types: $response');
      }
    } catch (e, stack) {
      debugPrint('❌ [CATEGORIES] Erreur lors du chargement des types: $e');
      debugPrint('❌ [CATEGORIES] Stack: $stack');
    } finally {
      isloadingType.value = false;
      update();
    }
  }

  var isAmentiesloading = true.obs;
  Future<void> getDataAmenties() async {
    isAmentiesloading.value = true;
    try {
      // Lecture éventuelle du cache (sans l'utiliser comme source unique)
      GetStorage().read("amenitiesVechicle");

      // Appel réel au backend pour récupérer les équipements
      debugPrint('📡 [AMENITIES] Appel API GET amenities');
      var response = await httpGet(Config.amenities, {});
      debugPrint('📥 [AMENITIES] Réponse brute: $response');

      if (response != null &&
          response is Map<String, dynamic> &&
          response['status'] == 200 &&
          response['data'] != null &&
          response['data']['amenities'] != null) {
        amenitiesModel = AmenitiesModel.fromJson(response);
        vehicleListAmenities.assignAll(amenitiesModel!.data!.amenities ?? []);
        GetStorage().write("amenitiesVechicle", response);
        debugPrint('✅ [AMENITIES] Liste des équipements chargée depuis l\'API');
      } else {
        debugPrint('⚠️ [AMENITIES] Réponse invalide lors du chargement des équipements: $response');
      }
    } catch (e, stack) {
      debugPrint('❌ [AMENITIES] Erreur lors du chargement des équipements: $e');
      debugPrint('❌ [AMENITIES] Stack: $stack');
    } finally {
      isAmentiesloading.value = false;
      update();
    }
  }

  List<MakeTypes> listMakesType = [];
  List<Models> listModelType = [];
  var isMakeModel = true.obs;
  var isMakeModelonTap = true.obs;
  Future<void> getVehicleDataMakeModel() async {
    isMakeModel.value = true;

    try {
      // 🚀 [EDIT_MAKE] LOGS MASSIFS - Début de la récupération des marques
      debugPrint('🚀 [EDIT_MAKE] ==========================================');
      debugPrint('🚀 [EDIT_MAKE] DÉBUT getVehicleDataMakeModel()');
      debugPrint('🚀 [EDIT_MAKE] URL API: ${Config.baseurl}${Config.makeType}');
      debugPrint('🚀 [EDIT_MAKE] Endpoint: ${Config.makeType}');
      debugPrint('🚀 [EDIT_MAKE] Paramètres envoyés: {} (aucun filtre)');
      debugPrint('🚀 [EDIT_MAKE] État actuel - listMakesType.length: ${listMakesType.length}');
      
      // Appel réel au backend Node.js pour récupérer les marques et modèles
      debugPrint('📡 [MAKES_MODELS] Appel API GET vehicle-reference/makes');
      debugPrint('📡 [EDIT_MAKE] Appel httpGet en cours...');
      
      var response = await httpGet(Config.makeType, {});
      
      // 📦 [EDIT_MAKE] LOGS MASSIFS - Réponse brute
      debugPrint('📦 [EDIT_MAKE] ==========================================');
      debugPrint('📦 [EDIT_MAKE] RÉPONSE BRUTE REÇUE');
      debugPrint('📦 [EDIT_MAKE] Type de réponse: ${response.runtimeType}');
      debugPrint('📦 [EDIT_MAKE] Réponse complète: $response');
      
      if (response != null) {
        debugPrint("📦 [EDIT_MAKE] Réponse n'est PAS null");
        if (response is Map<String, dynamic>) {
          debugPrint('📦 [EDIT_MAKE] Réponse est un Map<String, dynamic>');
          debugPrint('📦 [EDIT_MAKE] Clés de la réponse: ${response.keys.toList()}');
          debugPrint('📦 [EDIT_MAKE] response["success"]: ${response["success"]}');
          debugPrint('📦 [EDIT_MAKE] response["status"]: ${response["status"]}');
          debugPrint('📦 [EDIT_MAKE] response["data"] existe: ${response.containsKey("data")}');
          debugPrint('📦 [EDIT_MAKE] response["data"] type: ${response["data"]?.runtimeType}');
          
          if (response['data'] != null) {
            debugPrint("📦 [EDIT_MAKE] response[\"data\"] n'est PAS null");
            if (response['data'] is List) {
              debugPrint('📦 [EDIT_MAKE] response["data"] est une List');
              debugPrint('📦 [EDIT_MAKE] Taille de la liste: ${(response['data'] as List).length}');
            } else {
              debugPrint("⚠️ [EDIT_MAKE] response[\"data\"] n'est PAS une List, type: ${response['data'].runtimeType}");
            }
          } else {
            debugPrint('⚠️ [EDIT_MAKE] response["data"] est NULL');
          }
        } else {
          debugPrint("⚠️ [EDIT_MAKE] Réponse n'est PAS un Map<String, dynamic>");
        }
      } else {
        debugPrint('⚠️ [EDIT_MAKE] La réponse HTTP est NULL');
      }

      // Parsing sécurisé de la réponse : {status: 200, data: {makes: [...]}}
      if (response != null && response is Map<String, dynamic>) {
        debugPrint('🔍 [EDIT_MAKE] Début du parsing de la réponse...');
        
        try {
          debugPrint('🛠️ [EDIT_MAKE] Tentative de parsing manuel...');
          
          // 1. On vérifie que response['data'] existe
          if (response['data'] != null) {
            // Cas 1: Structure {status: 200, data: {makes: [...]}}
            if (response['data'] is Map<String, dynamic>) {
              final dataMap = response['data'] as Map<String, dynamic>;
              
              if (dataMap['makes'] != null && dataMap['makes'] is List) {
              List<dynamic> makesList = dataMap['makes'];
              
              debugPrint('✅ [EDIT_MAKE] Structure détectée: data.makes existe avec ${makesList.length} éléments');
              
              // 2. On mappe la liste brute vers des objets Makes, puis on convertit en MakeTypes
              var fetchedMakes = makesList.map((m) {
                try {
                  // Parser avec Makes.fromJson qui gère correctement _id et name
                  final makes = Makes.fromJson(m is Map<String, dynamic> ? m : Map<String, dynamic>.from(m));
                  
                  // Convertir Makes en MakeTypes pour la liste listMakesType
                  return MakeTypes(
                    id: makes.id,
                    name: makes.makeName ?? makes.id, // makeName correspond à 'name' dans le JSON
                    description: makes.description,
                    status: makes.status,
                    models: null, // Les modèles ne sont pas dans la réponse initiale
                  );
                } catch (e) {
                  debugPrint('❌ [EDIT_MAKE] Erreur lors du parsing d\'un élément: $e');
                  debugPrint('❌ [EDIT_MAKE] Élément problématique: $m');
                  return null;
                }
              }).where((make) => make != null && make.id != null && make.name != null).cast<MakeTypes>().toList();
              
              debugPrint('✅ [EDIT_MAKE] Parsing réussi. Nombre de marques trouvées : ${fetchedMakes.length}');
              
              // 3. Assigne à la liste utilisée par l'UI
              listMakesType = fetchedMakes;
              
              // Afficher les premières marques pour vérification
              if (listMakesType.isNotEmpty) {
                debugPrint('📋 [EDIT_MAKE] Premières marques dans la liste:');
                for (int i = 0; i < (listMakesType.length > 5 ? 5 : listMakesType.length); i++) {
                  debugPrint('   ${i + 1}. ID: ${listMakesType[i].id}, Name: ${listMakesType[i].name}');
                }
              }
              
              listModelType.clear();
              for (var makeType in listMakesType) {
                if (makeType.models != null) {
                  listModelType.addAll(makeType.models!);
                }
              }
              
                debugPrint('✅ [SUCCESS] Nombre de marques réelles dans la liste: ${listMakesType.length}');
                debugPrint('✅ [SUCCESS] Nombre de modèles dans la liste: ${listModelType.length}');
              } else {
                debugPrint('⚠️ [EDIT_MAKE] Le chemin data.makes n\'existe pas ou n\'est pas une List dans la réponse JSON.');
                debugPrint('⚠️ [EDIT_MAKE] data.makes type: ${dataMap['makes']?.runtimeType}');
                listMakesType = [];
              }
            } 
            // Cas 2: Structure ancienne où data est directement une List
            else if (response['data'] is List) {
              debugPrint('✅ [EDIT_MAKE] Structure ancienne détectée (data est directement une List)');
              List rawData = response['data'] as List;
              
              var fetchedMakes = rawData.map((m) {
                try {
                  final makes = Makes.fromJson(m is Map<String, dynamic> ? m : Map<String, dynamic>.from(m));
                  return MakeTypes(
                    id: makes.id,
                    name: makes.makeName ?? makes.id,
                    description: makes.description,
                    status: makes.status,
                    models: null,
                  );
                } catch (e) {
                  debugPrint('❌ [EDIT_MAKE] Erreur lors du parsing d\'un élément: $e');
                  return null;
                }
              }).where((make) => make != null && make.id != null && make.name != null).cast<MakeTypes>().toList();
              
              listMakesType = fetchedMakes;
              listModelType.clear();
              debugPrint('✅ [SUCCESS] Nombre de marques réelles dans la liste (structure data=List): ${listMakesType.length}');
            } else {
              debugPrint('⚠️ [EDIT_MAKE] response["data"] n\'est ni un Map ni une List');
              listMakesType = [];
            }
            
            // Fallback final : Essayer GetMakeModel pour compatibilité
            if (listMakesType.isEmpty) {
              try {
                getMakeModel = GetMakeModel.fromJson(response);
                debugPrint('✅ [EDIT_MAKE] GetMakeModel.fromJson réussi (fallback final)');
                if (getMakeModel!.data != null) {
                  debugPrint('✅ [EDIT_MAKE] getMakeModel.data existe');
                  debugPrint('📊 [EDIT_MAKE] Nombre de makesTypes dans data: ${getMakeModel!.data!.makesTypes?.length ?? 0}');
                  listMakesType.assignAll(getMakeModel!.data!.makesTypes ?? []);
                  listModelType.clear();
                  for (var makeType in listMakesType) {
                    if (makeType.models != null) {
                      listModelType.addAll(makeType.models!);
                    }
                  }
                  debugPrint('✅ [SUCCESS] Nombre de marques réelles dans la liste (GetMakeModel): ${listMakesType.length}');
                }
              } catch (e) {
                debugPrint('❌ [EDIT_MAKE] Erreur lors du parsing avec GetMakeModel: $e');
              }
            }
          } else {
            debugPrint('⚠️ [EDIT_MAKE] response["data"] est NULL');
            listMakesType = [];
          }
        } catch (e) {
          debugPrint('❌ [EDIT_MAKE] Erreur lors du parsing JSON : $e');
          // Fallback de sécurité si le modèle plante
          listMakesType = [];
        }
      } else {
        debugPrint('⚠️ [MAKES_MODELS] Réponse invalide: $response');
        debugPrint('⚠️ [EDIT_MAKE] Réponse est null ou n\'est pas un Map');
        listMakesType = [];
      }
    } catch (e, stack) {
      debugPrint('❌ [MAKES_MODELS] Erreur lors du chargement: $e');
      debugPrint('❌ [MAKES_MODELS] Stack: $stack');
      debugPrint('❌ [EDIT_MAKE] EXCEPTION CAPTURÉE: $e');
      debugPrint('❌ [EDIT_MAKE] StackTrace: $stack');
    } finally {
      // Log global : Marques et Modèles chargés
      debugPrint('📦 [DATA_LOADED] Marques: ${listMakesType.length}, Modèles: ${listModelType.length}');
      debugPrint('📦 [EDIT_MAKE] ==========================================');
      debugPrint('📦 [EDIT_MAKE] FIN getVehicleDataMakeModel()');
      debugPrint('📦 [EDIT_MAKE] État final - listMakesType.length: ${listMakesType.length}');
      debugPrint('📦 [EDIT_MAKE] État final - isMakeModel.value: ${isMakeModel.value}');
      debugPrint('📦 [EDIT_MAKE] Appel de update() pour rafraîchir l\'UI...');
      
      isMakeModel.value = false;
      update();
      
      debugPrint('✅ [EDIT_MAKE] update() appelé - L\'UI devrait se rafraîchir maintenant');
      debugPrint('📦 [EDIT_MAKE] ==========================================');
    }
  }

  /// Charge les modèles pour une marque spécifique via l'API séparée
  /// Utilise exactement la même API que l'écran d'ajout
  Future<void> getModelApi(String makeId) async {
    try {
      debugPrint('📡 [MODELS_API] Appel API GET vehicle-reference/models pour makeId: $makeId');
      
      // IMPORTANT : Vider la liste au début pour éviter d'afficher les modèles d'une ancienne marque
      listModelType.clear();
      
      // Construire l'URL complète avec adminBaseUrl (sans /v1/)
      // IMPORTANT : Le paramètre est 'make' et non 'makeId'
      String url = '${Config.adminBaseUrl}${Config.vehicleReferenceModels}?make=$makeId';
      
      debugPrint('📡 [MODELS_API] URL complète: $url');
      
      // Utiliser http directement car httpGet utilise baseurl avec /v1/, 
      // mais cette API nécessite /api/ sans /v1/ (adminBaseUrl)
      // Récupérer le token depuis GetStorage
      final storage = GetStorage();
      final bearerToken = storage.read('bearerToken') ?? '';
      
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $bearerToken',
      };
      
      final httpResponse = await http.get(Uri.parse(url), headers: headers);
      
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
        final response = jsonDecode(httpResponse.body) as Map<String, dynamic>;
        
        if (response != null && response is Map<String, dynamic>) {
          // Parsing robuste : L'API renvoie { "success": true, "data": [...] } ou { "success": true, "data": { "data": [...] } }
          if (response['success'] == true && response['data'] != null) {
            var dataObj = response['data'];
            List<dynamic> list;
            
            if (dataObj is List) {
              // Structure directe : { "success": true, "data": [...] }
              list = dataObj;
            } else if (dataObj is Map<String, dynamic> && dataObj['data'] != null) {
              // Structure imbriquée : { "success": true, "data": { "data": [...] } }
              list = dataObj['data'] as List;
            } else if (dataObj is Map<String, dynamic> && dataObj['models'] != null) {
              // Structure alternative : { "success": true, "data": { "models": [...] } }
              list = dataObj['models'] as List;
            } else {
              debugPrint('⚠️ [MODELS_API] Structure de data inattendue: ${dataObj.runtimeType}');
              list = [];
            }
            
            debugPrint('✅ [MODELS_API] Structure détectée - longueur: ${list.length}');
            
            try {
              for (var item in list) {
                if (item is Map<String, dynamic>) {
                  try {
                    // Créer un objet Models depuis la réponse avec gestion d'erreur par élément
                    listModelType.add(Models.fromJson(item));
                  } catch (e) {
                    debugPrint('❌ [MODELS_API] Erreur sur l\'élément: $item');
                    debugPrint('❌ [MODELS_API] Erreur: $e');
                    // Continuer avec les autres éléments sans bloquer toute la liste
                  }
                }
              }
              debugPrint('✅ [MODELS_API] listModelType mis à jour - longueur: ${listModelType.length}');
            } catch (e) {
              debugPrint('❌ [MODELS_API] Erreur lors du parsing Models (niveau liste): $e');
            }
          } else {
            debugPrint('⚠️ [MODELS_API] response["success"] != true ou response["data"] est NULL');
            debugPrint('📋 [MODELS_API] Structure complète: $response');
          }
        } else {
          debugPrint('⚠️ [MODELS_API] Réponse invalide ou null');
        }
      } else {
        debugPrint('❌ [MODELS_API] Erreur HTTP: ${httpResponse.statusCode}');
        debugPrint('❌ [MODELS_API] Body: ${httpResponse.body}');
      }
    } catch (e) {
      debugPrint('❌ [MODELS_API] Erreur getModelApi: $e');
      listModelType = [];
    }
    update();
  }

  Future<void> getVehicleDataMakeModelforOnTap(value) async {
    isMakeModelonTap.value = true;
    showLoading();

    try {
      // Appel réel au backend Node.js pour récupérer TOUTES les marques et modèles
      // ❗ IMPORTANT: AUCUN filtre type_id ne doit être envoyé (comportement identique à Add Vehicle)
      debugPrint('📡 [MAKES_MODELS] Appel API GET vehicle-reference/makes SANS FILTRE (toutes les marques)');
      var response = await httpGet(Config.makeType, {});

      if (response != null && response is Map<String, dynamic>) {
        getMakeModel = GetMakeModel.fromJson(response);
        update();
        if (getMakeModel!.data != null) {
          listMakesType.assignAll(getMakeModel!.data!.makesTypes ?? []);
          listModelType.clear();
          for (var makeType in listMakesType) {
            listModelType.addAll(makeType.models ?? []);
          }
        }
      } else {
        debugPrint('⚠️ [MAKES_MODELS] Réponse invalide: $response');
      }
    } catch (e, stack) {
      debugPrint('❌ [MAKES_MODELS] Erreur lors du chargement: $e');
      debugPrint('❌ [MAKES_MODELS] Stack: $stack');
    } finally {
      // 📚 DEBUG MISMATCH IDS - LOG DES MARQUES ET MODÈLES CHARGÉS
      debugPrint(
          '📚 [REF_API_DATA] Liste des marques/modèles chargés depuis l\'API :');
      for (var make in listMakesType) {
        debugPrint(
            '   - MAKE ID: ${make.id} (Type: ${make.id.runtimeType}), Nom: ${make.name}');
        if (make.models != null) {
          for (var model in make.models!) {
            debugPrint(
                '       → MODEL ID: ${model.id} (Type: ${model.id.runtimeType}), Nom: ${model.name}');
          }
        }
      }

      // Log global : Marques et Modèles chargés
      debugPrint('📦 [DATA_LOADED] Marques: ${listMakesType.length}, Modèles: ${listModelType.length}');

      isMakeModelonTap.value = false;
      closeLoading();
      update();
    }
  }

  // getVehicleDataMakeModelforEditinitial supprimée : le mode édition réutilise désormais
  // exclusivement getVehicleDataMakeModel() pour charger les marques et modèles,
  // garantissant un comportement identique à l'écran d'ajout.

  var isLoactionloading = true.obs;
  RxBool isload = true.obs;
  Future<void> getDataYourLocation() async {
    try {
      debugPrint('📡 [LOCATIONS] Appel API GET vehicle-reference/locations');
      
      // Utiliser l'API réelle vehicle-reference/locations (identique à l'ajout)
      String url = '${Config.adminBaseUrl}${Config.vehicleReferenceLocations}';
      
      debugPrint('📡 [LOCATIONS] URL complète: $url');
      
      // Récupérer le token depuis GetStorage
      final storage = GetStorage();
      final bearerToken = storage.read('bearerToken') ?? '';
      
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $bearerToken',
      };
      
      final httpResponse = await http.get(Uri.parse(url), headers: headers);
      
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
        final response = jsonDecode(httpResponse.body) as Map<String, dynamic>;
        
        debugPrint('✅ [LOCATIONS] Réponse reçue: ${response['success']}');
        
        if (response != null && response is Map<String, dynamic>) {
          // Parsing robuste : L'API renvoie { "success": true, "data": [...] }
          if (response['success'] == true && response['data'] != null) {
            var dataObj = response['data'];
            List<dynamic> list;
            
            if (dataObj is List) {
              // Structure directe : { "success": true, "data": [...] }
              list = dataObj;
            } else if (dataObj is Map<String, dynamic> && dataObj['data'] != null) {
              // Structure imbriquée : { "success": true, "data": { "data": [...] } }
              list = dataObj['data'] as List;
            } else if (dataObj is Map<String, dynamic> && dataObj['locations'] != null) {
              // Structure alternative : { "success": true, "data": { "locations": [...] } }
              list = dataObj['locations'] as List;
            } else {
              debugPrint('⚠️ [LOCATIONS] Structure de data inattendue: ${dataObj.runtimeType}');
              list = [];
            }
            
            debugPrint('✅ [LOCATIONS] Structure détectée - longueur: ${list.length}');
            
            // Convertir la liste en format compatible avec LocationsHostModel
            // Le modèle attend: { "status": 200, "data": { "Locations": [...] } }
            Map<String, dynamic> formattedResponse = {
              "status": 200,
              "message": "Locations retrieved successfully",
              "error": "",
              "data": {
                "Locations": list.map((item) {
                  if (item is Map<String, dynamic>) {
                    return {
                      "id": item['_id'] ?? item['id'] ?? 0,
                      "city_name": item['name'] ?? item['city_name'] ?? item['cityName'] ?? '',
                      "description": item['description'] ?? item['city_name'] ?? '',
                      "latitude": item['latitude']?.toString() ?? '0.0',
                      "longitude": item['longitude']?.toString() ?? '0.0',
                      "country_code": item['country_code'] ?? item['countryCode'] ?? 'US',
                      "image": item['image'] ?? '',
                    };
                  }
                  return item;
                }).toList(),
              }
            };
            
            if (formattedResponse != null) {
              locationsHostModel = LocationsHostModel.fromJson(formattedResponse);
              update();
              listLocation.assignAll(locationsHostModel!.data!.locations!);
              GetStorage().write("yourLocation", formattedResponse);
              debugPrint('✅ [LOCATIONS] ${listLocation.length} locations chargées depuis la BD');
            }
          } else {
            debugPrint('⚠️ [LOCATIONS] response["success"] != true ou response["data"] est NULL');
          }
        } else {
          debugPrint('⚠️ [LOCATIONS] Réponse invalide ou null');
        }
      } else {
        debugPrint('❌ [LOCATIONS] Erreur HTTP: ${httpResponse.statusCode}');
        debugPrint('❌ [LOCATIONS] Body: ${httpResponse.body}');
      }
    } catch (e) {
      debugPrint('❌ [LOCATIONS] Erreur getDataYourLocation: $e');
    }
    locationsModel = null;
    update();
  }

  var isPolicyloading = true.obs;
  Future<void> getCancellationPolicy() async {
    isPolicyloading.value = true;
    
    // ========== MOCK DATA - OLD API CALL COMMENTED ==========
    // var response4 = await httpGet(Config.getCancellationPolicies, {});
    
    // MOCK: Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // MOCK: Static cancellation policies data
    Map<String, dynamic> mockResponse = {
      "status": 200,
      "message": "Cancellation policies retrieved successfully",
      "error": "",
      "data": {
        "cancellation_policies": [
          {
            "id": 1,
            "name": "Normal Policy",
            "description": "Standard cancellation policy with moderate refund terms",
            "type": "normal",
            "value": "50",
            "status": "1",
            "created_at": "2024-01-01T00:00:00.000Z",
            "updated_at": "2024-01-01T00:00:00.000Z"
          },
          {
            "id": 2,
            "name": "Super Policy",
            "description": "Premium cancellation policy with flexible refund terms",
            "type": "super",
            "value": "80",
            "status": "1",
            "created_at": "2024-01-01T00:00:00.000Z",
            "updated_at": "2024-01-01T00:00:00.000Z"
          },
          {
            "id": 3,
            "name": "Flexible Policy",
            "description": "Most flexible cancellation policy with full refund options",
            "type": "flexible",
            "value": "100",
            "status": "1",
            "created_at": "2024-01-01T00:00:00.000Z",
            "updated_at": "2024-01-01T00:00:00.000Z"
          }
        ]
      }
    };
    
    var response4 = mockResponse;
    // ========== END MOCK DATA ==========
    
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
    
    // ========== MOCK DATA - OLD API CALL COMMENTED ==========
    // var response4 = await httpGet(Config.getItemRules, {});
    
    // MOCK: Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // MOCK: Static booking rules data
    Map<String, dynamic> mockResponse = {
      "status": 200,
      "message": "Item rules retrieved successfully",
      "error": "",
      "data": {
        "booking_rules": [
          {
            "id": 1,
            "rule_name": "It is forbidden to lend, rent, or sublease the car to a third party.",
            "status": "1",
            "created_at": "2024-01-01T00:00:00.000Z",
            "updated_at": "2024-01-01T00:00:00.000Z"
          },
          {
            "id": 2,
            "rule_name": "The vehicle must be returned with the same fuel level as at pickup.",
            "status": "1",
            "created_at": "2024-01-01T00:00:00.000Z",
            "updated_at": "2024-01-01T00:00:00.000Z"
          },
          {
            "id": 3,
            "rule_name": "Smoking and eating inside the car are not allowed.",
            "status": "1",
            "created_at": "2024-01-01T00:00:00.000Z",
            "updated_at": "2024-01-01T00:00:00.000Z"
          },
          {
            "id": 4,
            "rule_name": "The vehicle must be returned on the agreed date, time, and location.",
            "status": "1",
            "created_at": "2024-01-01T00:00:00.000Z",
            "updated_at": "2024-01-01T00:00:00.000Z"
          }
        ]
      }
    };
    
    var response4 = mockResponse;
    // ========== END MOCK DATA ==========
    
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

  // ========== FONCTION populateFields POUR PRÉ-REMPLIR LE FORMULAIRE ==========
  /// Prépare le formulaire d'édition avec les données du véhicule
  /// Cette fonction doit être appelée AVANT la navigation vers EditVehicleHomeScreen
  /// 
  /// Gère les IDs MongoDB (_id) pour que les dropdowns affichent les bonnes valeurs
  Future<void> populateFields(Items vehicle) async {
    try {
      // STEP 1: Début populateFields
      debugPrint('step 1: Début populateFields');
      
      // 1. Sauvegarder l'ID du véhicule dès le début pour l'envoi ultérieur
      currentVehicleId = vehicle.id?.toString() ?? vehicle.toJson()['_id']?.toString();
      debugPrint('💾 [POPULATE_FIELDS] ID sauvegardé pour l\'envoi : $currentVehicleId');
      debugPrint('📝 [POPULATE_FIELDS] Pré-remplissage du formulaire pour le véhicule ID: ${vehicle.id}');
    
    // 0. Activer le loader pour éviter l'affichage des dropdowns avec des listes vides
    isLoadingEdit.value = true;
    update();
    
    // 2. Stocker le véhicule dans item
    item = vehicle;
    
    // 2. Nettoyer les contrôleurs avant de les remplir
    cleanTextController();
    
    // 1. RÉUTILISATION DES LISTES DE RÉFÉRENCE - Charger TOUTES les listes nécessaires au début
    // Utiliser la même logique que dans l'écran d'Ajout (InitialHostCommonScreen.initState)
    // pour garantir que vehicleListItemType, vehicleListAmenities, listSpeedOdometer,
    // listTransmission, fuelTypeList, etc. sont remplies.
    debugPrint('📋 [REFERENCE_LISTS] Chargement des listes de référence (ADD -> EDIT)...');
    
    // 🚗 DEBUG MISMATCH IDS - LOG DE L'ID TYPE REÇU POUR CE VÉHICULE (MongoDB vs Local)
    debugPrint('🚗 [VEHICLE_API_DATA] ID reçu pour ce véhicule :');
    debugPrint(
        '   - ID Type reçu (vehicle.type): ${vehicle.toJson()['type']} (Type: ${vehicle.toJson()['type']?.runtimeType})');

    // 1a. Charger les types de véhicules (obligatoire pour tout le reste)
    if (vehicleListItemType.isEmpty) {
      debugPrint('📋 [REFERENCE_LISTS] Chargement de vehicleListItemType...');
      await getDataItemType();
      update();
      debugPrint('✅ [REFERENCE_LISTS] vehicleListItemType chargé: ${vehicleListItemType.length} éléments');
    } else {
      debugPrint('✅ [REFERENCE_LISTS] vehicleListItemType déjà chargé: ${vehicleListItemType.length} éléments');
    }
    
    // 1b. Charger les amenities (caractéristiques)
    if (vehicleListAmenities.isEmpty) {
      debugPrint('📋 [REFERENCE_LISTS] Chargement de vehicleListAmenities...');
      await getDataAmenties();
      update();
      debugPrint('✅ [REFERENCE_LISTS] vehicleListAmenities chargé: ${vehicleListAmenities.length} éléments');
    } else {
      debugPrint('✅ [REFERENCE_LISTS] vehicleListAmenities déjà chargé: ${vehicleListAmenities.length} éléments');
    }
    
    // 1c. Charger le kilométrage (odomètre)
    if (listSpeedOdometer.isEmpty) {
      debugPrint('📋 [REFERENCE_LISTS] Chargement de listSpeedOdometer (odometer)...');
      await getDataOdometerList();
      update();
      debugPrint('✅ [REFERENCE_LISTS] listSpeedOdometer chargé: ${listSpeedOdometer.length} éléments');
    } else {
      debugPrint('✅ [REFERENCE_LISTS] listSpeedOdometer déjà chargé: ${listSpeedOdometer.length} éléments');
    }

    // 1d. Charger les transmissions
    if (listTransmission.isEmpty) {
      debugPrint('📋 [REFERENCE_LISTS] Chargement de listTransmission (transmissions)...');
      await getDataTransmission();
      update();
      debugPrint('✅ [REFERENCE_LISTS] listTransmission chargé: ${listTransmission.length} éléments');
    } else {
      debugPrint('✅ [REFERENCE_LISTS] listTransmission déjà chargé: ${listTransmission.length} éléments');
    }

    // 1e. Charger les types de carburant
    if (fuelTypeList.isEmpty) {
      debugPrint('📋 [REFERENCE_LISTS] Chargement de fuelTypeList (types de carburant)...');
      await getDatafuelType();
      update();
      debugPrint('✅ [REFERENCE_LISTS] fuelTypeList chargé: ${fuelTypeList.length} éléments');
    } else {
      debugPrint('✅ [REFERENCE_LISTS] fuelTypeList déjà chargé: ${fuelTypeList.length} éléments');
    }

    // Note: listMakesType sera chargé après avoir déterminé selectedVehicleType
    debugPrint('✅ [REFERENCE_LISTS] Listes de référence chargées (ADD -> EDIT synchronisées)');
    
    // 1. MATCHING DE TYPE ROBUSTE - Node.js envoie maintenant l'ID MongoDB dans le champ type
    // Récupère vehicle.type (qui contient l'ID MongoDB) et cherche cet ID dans vehicleListItemType
    // 3. Workflow de transformation : Print étape 2 - Matching Type
    debugPrint('⚙️ [WORKFLOW] Étape 2: Matching Type...');
    
    if (vehicle.toJson()['type'] != null || (vehicle.itemInfo != null)) {
      try {
        // Priorité 1: Récupérer depuis vehicle.toJson()['type'] directement
        dynamic vehicleTypeId = vehicle.toJson()['type'];
        
        // Priorité 2: Si pas disponible, chercher dans itemInfo
        if (vehicleTypeId == null && vehicle.itemInfo != null) {
          final itemInfoDecoded = json.decode(vehicle.itemInfo!);
          vehicleTypeId = itemInfoDecoded['type'];
        }
        
        if (vehicleTypeId != null) {
          // 4. Forçage de type : Si l'ID local est un int et que MongoDB envoie une String, convertis-le explicitement
          // Vérifier le type de l'ID dans la liste locale
          if (vehicleListItemType.isNotEmpty) {
            final localIdType = vehicleListItemType.first.id.runtimeType;
            debugPrint('🔍 [FORCE_TYPE] Type ID local: $localIdType');
            debugPrint('🔍 [FORCE_TYPE] Type ID reçu: ${vehicleTypeId.runtimeType}');
            
            // Si l'ID local est int et que MongoDB envoie une String, convertir explicitement
            if (localIdType == int && vehicleTypeId is String) {
              final parsedInt = int.tryParse(vehicleTypeId.toString());
              vehicleTypeId = parsedInt?.toString() ?? vehicleTypeId.toString();
              debugPrint('🔧 [FORCE_TYPE] Conversion String -> int -> String: $vehicleTypeId');
            } else if (localIdType == int && vehicleTypeId is! String) {
              vehicleTypeId = int.tryParse(vehicleTypeId.toString())?.toString() ?? vehicleTypeId.toString();
              debugPrint('🔧 [FORCE_TYPE] Conversion explicite vers String: $vehicleTypeId');
            } else {
              vehicleTypeId = vehicleTypeId.toString();
            }
          } else {
            vehicleTypeId = vehicleTypeId.toString();
          }
          
          debugPrint('🔍 [MATCHING_TYPE] ID MongoDB reçu depuis vehicle.type: $vehicleTypeId (type final: ${vehicleTypeId.runtimeType})');
          
          // Chercher cet ID dans la liste vehicleListItemType
          // Action : selectedVehicleType = vehicleListItemType.firstWhereOrNull((t) => t.id.toString() == vehicle.type.toString())?.id.toString();
          final typeFound = vehicleListItemType.firstWhereOrNull(
            (t) => t.id.toString() == vehicleTypeId.toString()
          );
          
          if (typeFound != null) {
            selectedVehicleType = typeFound.id.toString();
            debugPrint('✅ [MATCHING_TYPE] Type trouvé dans vehicleListItemType: ${typeFound.name} (ID: $selectedVehicleType)');
            
            // Charger les marques - Uniformiser avec l'écran d'Ajout : utiliser getVehicleDataMakeModel()
            await getVehicleDataMakeModel();
            update();
          } else {
            debugPrint('⚠️ [MATCHING_TYPE] Type ID $vehicleTypeId non trouvé dans vehicleListItemType');
          }
        }
      } catch (e) {
        debugPrint('⚠️ [MATCHING_TYPE] Erreur lors du parsing vehicle.type: $e');
      }
    }
    
    // 4. Remplir les TextEditingController de base (avec fallback sécurisés)
    textEditingControllerEditTitle.text = vehicle.title?.toString() ?? '';
    if (vehicle.title != null) {
      // 2. Correction de populateFields pour les données locales : Utiliser le title pour déduire marque et modèle
      // 2. Correction de populateFields pour les données locales : Utiliser le title pour déduire marque et modèle
      // Exemple: 'BMW - X1' -> marque: BMW, modèle: X1
      if (vehicle.title!.contains(' - ')) {
        var parts = vehicle.title!.split(' - ');
        if (parts.length >= 2) {
          final brandName = parts[0].trim(); // BMW
          final modelName = parts.length > 1 ? parts[1].trim() : ''; // X1
          
          debugPrint('🔍 [POPULATE_FIELDS] Extraction depuis title: Marque="$brandName", Modèle="$modelName"');
          
          // Charger les marques si nécessaire - Uniformiser avec l'écran d'Ajout : utiliser getVehicleDataMakeModel()
          if (listMakesType.isEmpty) {
            await getVehicleDataMakeModel();
            update();
          }
          
          // Chercher l'ID correspondant à la marque (ex: 'BMW') dans listMakesType
          final brand = listMakesType.firstWhereOrNull(
            (b) => b.name?.toLowerCase() == brandName.toLowerCase() ||
                   brandName.toLowerCase().contains(b.name?.toLowerCase() ?? '')
          );
          
          if (brand != null) {
            selectedMake = brand.id?.toString();
            debugPrint('✅ [POPULATE_FIELDS] Marque trouvée depuis title: ${brand.name} (ID: $selectedMake)');
            
            // Charger les modèles de cette marque
            if (selectedMake != null) {
              // Filtrer les modèles de cette marque depuis listMakesType
              // Car listModelType contient tous les modèles de toutes les marques
              final makeType = listMakesType.firstWhereOrNull(
                (m) => m.id?.toString() == selectedMake
              );
              
              if (makeType != null && makeType.models != null) {
                // Mettre à jour listModelType avec les modèles de cette marque seulement
                listModelType.clear();
                listModelType.addAll(makeType.models!);
                update();
                
                // Chercher le modèle correspondant
                if (modelName.isNotEmpty) {
                  final model = listModelType.firstWhereOrNull(
                    (m) => m.name?.toLowerCase() == modelName.toLowerCase() ||
                           modelName.toLowerCase().contains(m.name?.toLowerCase() ?? '')
                  );
                  
                  if (model != null) {
                    selectedModel = model.id?.toString();
                    debugPrint('✅ [POPULATE_FIELDS] Modèle trouvé depuis title: ${model.name} (ID: $selectedModel)');
                  }
                }
              }
            }
          } else {
            debugPrint('⚠️ [POPULATE_FIELDS] Marque "$brandName" non trouvée dans la liste');
          }
        }
      }
    }
    textEditingControllerEditDesc.text = vehicle.description?.toString() ?? '';
    textEditingControllerEditPrice.text = vehicle.price?.toString() ?? '';
    textEditingControllerEditAddress.text = vehicle.address?.toString() ?? '';
    textEditingControllerEditZip.text = vehicle.zipPostalCode?.toString() ?? '';
    textEditingControllerEditState.text = vehicle.stateRegion?.toString() ?? '';
    textEditingControllerEditCity.text = vehicle.city?.toString() ?? '';
    textEditingControllerEditCountry.text = vehicle.country?.toString() ?? '';
    textEditingControllerEditWeekDiscount.text = vehicle.weeklyDiscount?.toString() ?? '';
    textEditingControllerEditMonthDiscount.text = vehicle.monthlyDiscount?.toString() ?? '';
    update(); // Rafraîchir après remplissage des champs texte
    
    // 5. MAPPING MONGODB IMBRIQUÉ - Parser depuis itemInfo et metaData
    // Le backend Node.js peut envoyer les données dans itemInfo ou metaData
    // ⚠️ DÉSACTIVATION TEMPORAIRE DES SERVICES DE LOCALISATION pour éviter les crashes
    // Les coordonnées seront chargées depuis les données du véhicule, pas depuis Geolocator
    
    Map<String, dynamic>? vehicleDataMap;
    
    // DEBUG PROFOND : Vérifier les données brutes
    debugPrint('🔍 [DEBUG_MAPPING] vehicle.itemInfo: ${vehicle.itemInfo}');
    debugPrint('🔍 [DEBUG_MAPPING] vehicle.metaData: ${vehicle.metaData}');
    
    // Essayer de parser depuis itemInfo d'abord
    if (vehicle.itemInfo != null) {
      try {
        vehicleDataMap = jsonDecode(vehicle.itemInfo!);
        debugPrint('🔍 [DEBUG_MAPPING] itemInfo parsé avec succès, keys: ${vehicleDataMap?.keys}');
      } catch (e) {
        debugPrint('⚠️ [POPULATE_FIELDS] Impossible de parser itemInfo: $e');
      }
    }
    
    // Si metaData existe, le fusionner avec vehicleDataMap
    if (vehicle.metaData != null) {
      try {
        final metaDataMap = jsonDecode(vehicle.metaData!);
        debugPrint('🔍 [DEBUG_MAPPING] metaData parsé avec succès, keys: ${metaDataMap.keys}');
        vehicleDataMap ??= {};
        vehicleDataMap!.addAll(metaDataMap);
        debugPrint('🔍 [DEBUG_MAPPING] vehicleDataMap fusionné, keys: ${vehicleDataMap.keys}');
      } catch (e) {
        debugPrint('⚠️ [POPULATE_FIELDS] Impossible de parser metaData: $e');
      }
    }
    
    // DEBUG : Vérifier si specs existe directement dans vehicleDataMap
    if (vehicleDataMap != null) {
      debugPrint('🔍 [DEBUG_MAPPING] vehicleDataMap complet: ${jsonEncode(vehicleDataMap)}');
    }
    
    // 5a. Type de véhicule - Structure MongoDB imbriquée
      // Essayer vehicleType.id ou vehicleType directement depuis la structure MongoDB - FORCER EN STRING
      if (vehicleDataMap != null) {
        final dynamic vehicleTypeData = vehicleDataMap['type'] ?? 
                                       vehicleDataMap['vehicleType'] ?? 
                                       vehicleDataMap['item_type'];
        if (vehicleTypeData != null) {
          // Extraire la valeur brute (rawType)
          final rawType = vehicleTypeData is Map
              ? (vehicleTypeData['_id']?.toString() ?? 
                 vehicleTypeData['id']?.toString() ?? 
                 vehicleTypeData.toString())
              : vehicleTypeData.toString();
          
          // Charger les types de véhicules si nécessaire pour le matching
          if (vehicleListItemType.isEmpty) {
            await getDataItemType();
            update();
          }
          
          // 1. MATCHING INTELLIGENT - Chercher l'ID correspondant dans vehicleListItemType
          // Si Node.js envoie "CAR", cherche dans la liste l'élément dont le nom est "Voiture" ou "Car"
          // Si Node.js envoie un ID, cherche l'élément dont l'ID correspond
          final typeFound = vehicleListItemType.firstWhereOrNull(
            (t) => t.id.toString() == rawType.toString() || 
                   t.name?.toLowerCase() == rawType.toString().toLowerCase()
          );
          
          if (typeFound != null) {
            selectedVehicleType = typeFound.id.toString();
            debugPrint('✅ [MATCHING_TYPE] Type trouvé dans vehicleListItemType: ${typeFound.name} (ID: $selectedVehicleType)');
          } else {
            // Fallback: utiliser la valeur brute si pas trouvé
            selectedVehicleType = rawType.toString();
            debugPrint('⚠️ [MATCHING_TYPE] Type non trouvé dans vehicleListItemType, utilisation de la valeur brute: $selectedVehicleType');
          }
          
          debugPrint('📝 [POPULATE_FIELDS] Type de véhicule (MongoDB): $selectedVehicleType');
          
          // 3. CHARGEMENT DES DÉPENDANCES - Uniformiser avec l'écran d'Ajout : utiliser getVehicleDataMakeModel()
          if (selectedVehicleType != null && selectedVehicleType!.isNotEmpty) {
            await getVehicleDataMakeModel();
            update();
          }
        }
      }
    
    // Fallback: utiliser itemTypeId si la structure MongoDB n'est pas disponible - FORCER EN STRING
    if (selectedVehicleType == null || selectedVehicleType!.isEmpty) {
      if (vehicle.itemTypeId != null && vehicle.itemTypeId!.isNotEmpty) {
        final itemTypeIdStr = vehicle.itemTypeId.toString();
        // 4. Fix pour le Type de Véhicule : Mapper manuellement l'ID corrompu 12000-A-2
        if (itemTypeIdStr.contains('-A-') || itemTypeIdStr == '12000-A-2') {
          debugPrint('⚠️ [WARNING] ID de type corrompu détecté: $itemTypeIdStr, mappage manuel vers SUV');
          // Charger les types de véhicules si nécessaire
          if (vehicleListItemType.isEmpty) {
            await getDataItemType();
            update();
          }
          // Mapper vers 'SUV' par défaut si l'ID est corrompu
          final suvType = vehicleListItemType.firstWhereOrNull(
            (type) => type.name?.toLowerCase() == 'suv'
          );
          if (suvType != null) {
            selectedVehicleType = suvType.id?.toString();
            debugPrint('✅ [FIX_TYPE] Type mappé manuellement vers SUV (ID: $selectedVehicleType)');
          }
        } else {
          // Charger les types de véhicules si nécessaire pour le matching
          if (vehicleListItemType.isEmpty) {
            await getDataItemType();
            update();
          }
          
          // 1. MATCHING INTELLIGENT - Chercher l'ID correspondant dans vehicleListItemType
          final typeFound = vehicleListItemType.firstWhereOrNull(
            (t) => t.id.toString() == itemTypeIdStr.toString() || 
                   t.name?.toLowerCase() == itemTypeIdStr.toString().toLowerCase()
          );
          
          if (typeFound != null) {
            selectedVehicleType = typeFound.id.toString();
            debugPrint('✅ [MATCHING_TYPE] Type trouvé dans vehicleListItemType: ${typeFound.name} (ID: $selectedVehicleType)');
          } else {
            // Fallback: utiliser la valeur brute si pas trouvé
            selectedVehicleType = itemTypeIdStr;
            debugPrint('⚠️ [MATCHING_TYPE] Type non trouvé, utilisation de la valeur brute: $selectedVehicleType');
          }
          
          debugPrint('📝 [POPULATE_FIELDS] Type de véhicule (fallback itemTypeId): $selectedVehicleType');
        }
        
        // 3. CHARGEMENT DES DÉPENDANCES - Uniformiser avec l'écran d'Ajout : utiliser getVehicleDataMakeModel()
        if (selectedVehicleType != null && selectedVehicleType!.isNotEmpty) {
          await getVehicleDataMakeModel();
          update();
        }
        update();
      } else if (vehicle.itemType != null && vehicle.itemType!.isNotEmpty) {
        // 3. MAPPING PAR NOM : Si l'ID est corrompu (ex: 12000-A-2), chercher par nom
        final vehicleTypeName = vehicle.itemType.toString();
        debugPrint('🔍 [MAPPING_NOM] Recherche du type par nom: $vehicleTypeName');
        
        // Charger les types de véhicules si nécessaire
        if (vehicleListItemType.isEmpty) {
          await getDataItemType();
          update();
        }
        
        // Chercher le type par nom dans la liste (ex: 'SUV' dans vehicle.itemType)
        final matchingType = vehicleListItemType.firstWhereOrNull(
          (type) => type.name?.toLowerCase() == vehicleTypeName.toLowerCase() ||
                    type.name?.toLowerCase().contains(vehicleTypeName.toLowerCase()) == true ||
                    vehicleTypeName.toLowerCase().contains(type.name?.toLowerCase() ?? '')
        );
        
        if (matchingType != null) {
          selectedVehicleType = matchingType.id?.toString() ?? vehicleTypeName;
          debugPrint('✅ [MAPPING_NOM] Type trouvé par nom: ${matchingType.name} (ID: $selectedVehicleType)');
        } else {
          // Si vehicle.itemType contient 'SUV', chercher explicitement 'SUV'
          if (vehicleTypeName.toLowerCase().contains('suv')) {
            final suvType = vehicleListItemType.firstWhereOrNull(
              (type) => type.name?.toLowerCase() == 'suv'
            );
            if (suvType != null) {
              selectedVehicleType = suvType.id?.toString() ?? vehicleTypeName;
              debugPrint('✅ [MAPPING_NOM] Type SUV trouvé par recherche explicite (ID: $selectedVehicleType)');
            } else {
              selectedVehicleType = vehicleTypeName;
              debugPrint('⚠️ [MAPPING_NOM] Type SUV non trouvé dans la liste');
            }
          } else {
            selectedVehicleType = vehicleTypeName;
            debugPrint('⚠️ [MAPPING_NOM] Type non trouvé par nom, utilisation de la valeur brute: $selectedVehicleType');
          }
        }
        update();
      }
    } else {
      // NORMALISATION : Vérifier si l'ID existe dans la liste
      selectedVehicleType = selectedVehicleType.toString();
      
      // Charger les types de véhicules si nécessaire
      if (vehicleListItemType.isEmpty) {
        await getDataItemType();
        update();
      }
      
      // 1. LIAISON DES IDs TECHNIQUES : Si l'ID reçu est corrompu (ex: 16666-A-1), trouver le nom correspondant
      if (selectedVehicleType != null && 
          (selectedVehicleType!.contains('-A-') || 
           selectedVehicleType == '16666-A-1' || 
           selectedVehicleType == '12000-A-2')) {
        debugPrint('⚠️ [LIAISON_ID] ID corrompu détecté: $selectedVehicleType');
        
        // Charger les types si nécessaire
        if (vehicleListItemType.isEmpty) {
          await getDataItemType();
          update();
        }
        
        // Chercher le type par ID dans la liste (au cas où l'ID existe quand même)
        var matchingType = vehicleListItemType.firstWhereOrNull(
          (type) => type.id?.toString() == selectedVehicleType
        );
        
        // Si pas trouvé par ID, chercher par nom (SUV, Sedan, etc.) dans vehicle.itemType
        if (matchingType == null && vehicle.itemType != null) {
          final vehicleTypeName = vehicle.itemType.toString();
          debugPrint('🔍 [LIAISON_ID] Recherche par nom: $vehicleTypeName');
          matchingType = vehicleListItemType.firstWhereOrNull(
            (type) => type.name?.toLowerCase() == vehicleTypeName.toLowerCase() ||
                      type.name?.toLowerCase().contains(vehicleTypeName.toLowerCase()) == true
          );
        }
        
        // Si toujours pas trouvé, utiliser SUV par défaut
        if (matchingType == null) {
          matchingType = vehicleListItemType.firstWhereOrNull(
            (type) => type.name?.toLowerCase() == 'suv'
          );
        }
        
        if (matchingType != null) {
          selectedVehicleType = matchingType.id?.toString();
          debugPrint('✅ [LIAISON_ID] Type trouvé: ${matchingType.name} (ID corrigé: $selectedVehicleType)');
          update();
        } else {
          debugPrint('⚠️ [LIAISON_ID] Aucun type trouvé pour l\'ID corrompu: $selectedVehicleType');
        }
      }
      
      // Vérifier si l'ID existe dans la liste
      final typeExists = vehicleListItemType.any(
        (type) => type.id?.toString() == selectedVehicleType || type.id == selectedVehicleType
      );
      
      if (!typeExists) {
        debugPrint('⚠️ [MAPPING_NOM] Type ID $selectedVehicleType non trouvé dans la liste');
        
        // 3. MAPPING PAR NOM : Si l'ID est corrompu (ex: 12000-A-2), chercher par nom
        final typeName = vehicle.itemType ?? vehicle.itemTypeId?.toString();
        if (typeName != null) {
          // Chercher par correspondance exacte
          var matchingType = vehicleListItemType.firstWhereOrNull(
            (type) => type.name?.toLowerCase() == typeName.toLowerCase()
          );
          
          // Si pas trouvé, chercher par contenu (ex: 'SUV' dans le nom)
          if (matchingType == null && typeName.toLowerCase().contains('suv')) {
            matchingType = vehicleListItemType.firstWhereOrNull(
              (type) => type.name?.toLowerCase() == 'suv'
            );
          }
          
          // Si pas trouvé, chercher par correspondance partielle
          if (matchingType == null) {
            matchingType = vehicleListItemType.firstWhereOrNull(
              (type) => type.name?.toLowerCase().contains(typeName.toLowerCase()) == true ||
                        typeName.toLowerCase().contains(type.name?.toLowerCase() ?? '')
            );
          }
          
          if (matchingType != null) {
            selectedVehicleType = matchingType.id?.toString() ?? selectedVehicleType;
            debugPrint('✅ [MAPPING_NOM] Type trouvé par nom: ${matchingType.name} (ID: $selectedVehicleType)');
            update();
          } else {
            debugPrint('❌ [MAPPING_NOM] Type "$typeName" non trouvé dans la liste des types disponibles');
          }
        }
      } else {
        debugPrint('✅ [MAPPING_NOM] Type ID $selectedVehicleType trouvé dans la liste');
      }
    }
    // 2. SUPPRESSION RADICALE DE LA LOCALISATION - Ne plus utiliser getMainAddress ou Geolocator
    // Contente-toi des données directes du véhicule pour éviter les crashes
    if (vehicle.placeId != null) {
      selectedCityName = vehicle.placeId;
    }
    if (vehicle.latitude != null) {
      selectedLat.value = vehicle.latitude!;
    }
    if (vehicle.longitude != null) {
      selectedLong.value = vehicle.longitude!;
    }
    
    // ⚠️ DÉSACTIVATION COMPLÈTE : Ne plus appeler getMainAddress ou getPlaceDetailFromLatLng
    // Ces appels causent "Failed to fetch address" et bloquent l'édition
    // Utiliser uniquement les données directes du véhicule
    // if (vehicle.latitude != null && vehicle.longitude != null) {
    //   try {
    //     final address = await getMainAddress(double.parse(vehicle.latitude!), double.parse(vehicle.longitude!));
    //     // ... code commenté pour éviter les crashes
    //   } catch (e) {
    //     debugPrint('⚠️ [POPULATE_FIELDS] Erreur getMainAddress (ignorée): $e');
    //   }
    // }
    if (vehicle.weeklyDiscountType != null) {
      selectedWeeklyDiscountType = vehicle.weeklyDiscountType!;
    }
    if (vehicle.monthlyDiscountType != null) {
      selectedMonthlyDiscountType = vehicle.monthlyDiscountType!;
    }
    if (vehicle.bookingPoliciesId != null) {
      selectedRadio = vehicle.bookingPoliciesId!;
    }
    
    // 6. MAPPING MONGODB - Structure features imbriquée (liste d'objets avec _id)
    selectedAmenitiesList = [];
    
    // Essayer d'abord la structure MongoDB directe (features comme liste d'objets)
    if (vehicleDataMap != null && vehicleDataMap['features'] != null) {
      final dynamic featuresData = vehicleDataMap['features'];
      if (featuresData is List) {
        // Si c'est une liste d'objets MongoDB, extraire les _id
        for (var feature in featuresData) {
          if (feature is Map) {
            final id = feature['_id'] ?? feature['id'];
            if (id != null) {
              final idStr = id.toString().trim();
              if (idStr.isNotEmpty) {
                final intId = int.tryParse(idStr);
                selectedAmenitiesList.add(intId ?? idStr);
              }
            }
          } else {
            // Si c'est directement un ID (string ou int)
            final idStr = feature.toString().trim();
            if (idStr.isNotEmpty) {
              final intId = int.tryParse(idStr);
              selectedAmenitiesList.add(intId ?? idStr);
            }
          }
        }
        debugPrint('📝 [POPULATE_FIELDS] ${selectedAmenitiesList.length} caractéristiques chargées depuis features (MongoDB): $selectedAmenitiesList');
        update(); // Rafraîchir après assignation
      }
    }
    
    // Fallback: utiliser amenitiesId si features n'est pas disponible
    if (selectedAmenitiesList.isEmpty && vehicle.amenitiesId != null && vehicle.amenitiesId!.isNotEmpty) {
      // Gérer les IDs MongoDB (peuvent être des strings ou des entiers)
      // Le format peut être: "1,2,3" ou "[1,2,3]" ou "[{_id: 'xxx'}, {_id: 'yyy'}]" (MongoDB objets)
      String amenitiesIdStr = vehicle.amenitiesId!;
      
      // Nettoyer si c'est un array JSON stringifié
      if (amenitiesIdStr.startsWith('[') && amenitiesIdStr.endsWith(']')) {
        try {
          final parsed = jsonDecode(amenitiesIdStr) as List;
          // Si c'est une liste d'objets MongoDB, extraire les _id
          if (parsed.isNotEmpty && parsed.first is Map) {
            // Format: [{"_id": "xxx"}, {"_id": "yyy"}]
            for (var item in parsed) {
              if (item is Map) {
                final id = item['_id'] ?? item['id'];
                if (id != null) {
                  final idStr = id.toString().trim();
                  if (idStr.isNotEmpty) {
                    final intId = int.tryParse(idStr);
                    selectedAmenitiesList.add(intId ?? idStr);
                  }
                }
              }
            }
          } else {
            // Format: ["id1", "id2"] ou [1, 2, 3]
            amenitiesIdStr = parsed.map((e) => e.toString()).join(',');
            final amenitiesIds = amenitiesIdStr.split(",");
            for (var idStr in amenitiesIds) {
              final trimmedId = idStr.trim();
              if (trimmedId.isNotEmpty) {
                final intId = int.tryParse(trimmedId);
                selectedAmenitiesList.add(intId ?? trimmedId);
              }
            }
          }
        } catch (e) {
          debugPrint('⚠️ [POPULATE_FIELDS] Erreur parsing amenitiesId array: $e');
          // Fallback: traiter comme string simple
          final amenitiesIds = amenitiesIdStr.split(",");
          for (var idStr in amenitiesIds) {
            final trimmedId = idStr.trim().replaceAll('[', '').replaceAll(']', '').trim();
            if (trimmedId.isNotEmpty) {
              final intId = int.tryParse(trimmedId);
              selectedAmenitiesList.add(intId ?? trimmedId);
            }
          }
        }
      } else {
        // Format simple: "1,2,3" ou "id1,id2,id3"
        final amenitiesIds = amenitiesIdStr.split(",");
        for (var idStr in amenitiesIds) {
          final trimmedId = idStr.trim();
          if (trimmedId.isNotEmpty) {
            final intId = int.tryParse(trimmedId);
            selectedAmenitiesList.add(intId ?? trimmedId);
          }
        }
      }
      debugPrint('📝 [POPULATE_FIELDS] ${selectedAmenitiesList.length} caractéristiques chargées depuis amenitiesId: $selectedAmenitiesList');
      update(); // Rafraîchir après assignation
    }
    
    // 7. MAPPING DIRECT DEPUIS itemInfo (SANS specs) - Brand et Model
    // CORRECTION : Ne plus chercher 'specs', utiliser directement itemInfo comme source
    debugPrint('🔍 [DEBUG_MAPPING] vehicleDataMap est null? ${vehicleDataMap == null}');
    if (vehicleDataMap != null) {
      debugPrint('🔍 [DEBUG_MAPPING] vehicleDataMap.keys: ${vehicleDataMap.keys}');
    }
    
    // 7a. Marque (Brand) - Chercher directement dans itemInfo, puis dans vehicle
    dynamic brandData = vehicleDataMap?['brand'] ?? 
                        vehicleDataMap?['category_id'] ?? 
                        vehicleDataMap?['make'] ?? 
                        vehicleDataMap?['makeId'];
    
    // Fallback: chercher dans les champs racine de vehicle
    if (brandData == null) {
      // Essayer de récupérer depuis itemInfoDescription (metaData parsé)
      brandData = itemInfoDescription['category_id'] ?? 
                  itemInfoDescription['brand'] ?? 
                  itemInfoDescription['makeId'];
    }
    
    debugPrint('🔍 [DEBUG_ID] brandData: $brandData');
    debugPrint('🔍 [DEBUG_ID] brandData type: ${brandData?.runtimeType}');
    
    if (brandData != null) {
      if (brandData is Map) {
        debugPrint('🔍 [DEBUG_ID] brandData est un Map, keys: ${brandData.keys}');
        selectedMake = (brandData['_id']?.toString() ?? 
                      brandData['id']?.toString() ?? 
                      brandData.toString()).toString();
      } else {
        debugPrint('🔍 [DEBUG_ID] brandData n\'est pas un Map, valeur brute: $brandData');
        selectedMake = brandData.toString();
      }
      debugPrint('✅ [DEBUG_ID] selectedMake final: $selectedMake');
      update();
    } else {
      debugPrint('⚠️ [DEBUG_ID] brandData est null - la marque ne peut pas être chargée');
    }
    
    // 7b. Modèle (Model) - Chercher directement dans itemInfo, puis dans vehicle
    dynamic modelData = vehicleDataMap?['model'] ?? 
                        vehicleDataMap?['subcategory_id'] ?? 
                        vehicleDataMap?['modelId'];
    
    // Fallback: chercher dans les champs racine de vehicle
    if (modelData == null) {
      modelData = itemInfoDescription['subcategory_id'] ?? 
                  itemInfoDescription['model'] ?? 
                  itemInfoDescription['modelId'];
    }
    
    debugPrint('🔍 [DEBUG_ID] modelData: $modelData');
    debugPrint('🔍 [DEBUG_ID] modelData type: ${modelData?.runtimeType}');
    
    if (modelData != null) {
      if (modelData is Map) {
        debugPrint('🔍 [DEBUG_ID] modelData est un Map, keys: ${modelData.keys}');
        selectedModel = (modelData['_id']?.toString() ?? 
                       modelData['id']?.toString() ?? 
                       modelData.toString()).toString();
      } else {
        debugPrint('🔍 [DEBUG_ID] modelData n\'est pas un Map, valeur brute: $modelData');
        selectedModel = modelData.toString();
      }
      debugPrint('✅ [DEBUG_ID] selectedModel final: $selectedModel');
      update();
    } else {
      debugPrint('⚠️ [DEBUG_ID] modelData est null - le modèle ne peut pas être chargé');
    }
    
    // 7c. Transmission - Chercher directement dans itemInfo
    if (vehicleDataMap?['transmission'] != null) {
      selectTransmission = vehicleDataMap!['transmission'].toString();
      debugPrint('📝 [POPULATE_FIELDS] Transmission depuis itemInfo: $selectTransmission');
      update();
    } else if (itemInfoDescription['transmission'] != null) {
      selectTransmission = itemInfoDescription['transmission'].toString();
      debugPrint('📝 [POPULATE_FIELDS] Transmission depuis metaData: $selectTransmission');
      update();
    }
    
    // 7d. Année - Chercher directement dans itemInfo
    if (vehicleDataMap?['year'] != null) {
      final yearValue = vehicleDataMap!['year'];
      if (yearValue is int) {
        selectedVechicleYear = yearValue;
        selectedYear = yearValue.toString();
      } else {
        selectedYear = yearValue.toString();
        final yearInt = int.tryParse(selectedYear ?? "");
        if (yearInt != null) {
          selectedVechicleYear = yearInt;
        }
      }
      debugPrint('📝 [POPULATE_FIELDS] Année depuis itemInfo: $selectedVechicleYear');
      update();
    } else if (itemInfoDescription['year'] != null) {
      final yearValue = itemInfoDescription['year'];
      selectedYear = yearValue.toString();
      final yearInt = int.tryParse(selectedYear ?? "");
      if (yearInt != null) {
        selectedVechicleYear = yearInt;
      }
      debugPrint('📝 [POPULATE_FIELDS] Année depuis metaData: $selectedVechicleYear');
      update();
    }
    
    // 8. CHARGEMENT SÉQUENTIEL FORCÉ - Charger les listes AVANT de mapper les valeurs
    // CRITIQUE: getVehicleDataMakeModel() doit être terminé avant d'essayer de mapper la marque
    // Uniformiser avec l'écran d'Ajout : utiliser getVehicleDataMakeModel() qui récupère toutes les marques
    if (listMakesType.isEmpty) {
      debugPrint('⏳ [CHARGEMENT] Début du chargement des marques et modèles (liste complète)');
      await getVehicleDataMakeModel();
      debugPrint('✅ [CHARGEMENT] Marques et modèles chargés: ${listMakesType.length} marques, ${listModelType.length} modèles');
      update(); // Rafraîchir après chargement des listes
      
      // BLOC DE SÉCURITÉ : Charger les modèles après avoir assigné selectedMake
      if (selectedMake != null && selectedMake!.isNotEmpty) {
        // FORCER EN STRING pour garantir la compatibilité MongoDB
        selectedMake = selectedMake.toString();
        debugPrint('🔍 [SÉCURITÉ] Marque assignée: $selectedMake');
        
        if (getMakeModel != null && getMakeModel!.data != null) {
          final makeExists = getMakeModel!.data!.makesTypes?.any((make) => 
            make.id?.toString() == selectedMake || make.id == selectedMake
          ) ?? false;
          
          if (!makeExists) {
            debugPrint('⚠️ [SÉCURITÉ] Marque ID $selectedMake non trouvée dans la liste chargée');
            
            // 3. MAPPING PAR NOM : Si l'ID est corrompu (ex: 12000-A-2), chercher par nom
            debugPrint('🔍 [MAPPING_NOM] Tentative de recherche par nom...');
            
            // Extraire le nom de la marque depuis vehicle.title ou vehicle.description
            String? makeName;
            String? originalMakeId = selectedMake; // Sauvegarder l'ID original pour comparaison
            
            if (vehicle.title != null) {
              // Chercher des marques connues dans le titre (BMW, Toyota, Mercedes, etc.)
              final titleLower = vehicle.title!.toLowerCase();
              for (var makeType in getMakeModel!.data!.makesTypes ?? []) {
                if (makeType.name != null) {
                  final makeNameLower = makeType.name!.toLowerCase();
                  if (titleLower.contains(makeNameLower)) {
                    makeName = makeType.name;
                    selectedMake = makeType.id?.toString();
                    debugPrint('✅ [MAPPING_NOM] Marque trouvée par nom dans title: $makeName (ID: $selectedMake)');
                    break;
                  }
                }
              }
            }
            
            // Si pas trouvé dans title, essayer description
            if (selectedMake == originalMakeId) {
              if (vehicle.description != null) {
                final descLower = vehicle.description!.toLowerCase();
                for (var makeType in getMakeModel!.data!.makesTypes ?? []) {
                  if (makeType.name != null) {
                    final makeNameLower = makeType.name!.toLowerCase();
                    if (descLower.contains(makeNameLower)) {
                      makeName = makeType.name;
                      selectedMake = makeType.id?.toString();
                      debugPrint('✅ [MAPPING_NOM] Marque trouvée par nom dans description: $makeName (ID: $selectedMake)');
                      break;
                    }
                  }
                }
              }
            }
            
            if (selectedMake == originalMakeId) {
              debugPrint('❌ [MAPPING_NOM] Impossible de trouver la marque par nom');
            } else {
              // Si on a trouvé la marque par nom, charger les modèles pour cette marque
              MakeTypes? selectedMakeType;
              for (var makeType in getMakeModel!.data!.makesTypes ?? []) {
                if (makeType.id?.toString() == selectedMake || makeType.id == selectedMake) {
                  selectedMakeType = makeType;
                  break;
                }
              }
              
              if (selectedMakeType != null) {
                listModelType.clear();
                listModelType.addAll(selectedMakeType.models ?? []);
                debugPrint('✅ [MAPPING_NOM] ${listModelType.length} modèles chargés pour la marque trouvée par nom');
                update();
              }
            }
          } else {
            debugPrint('✅ [SÉCURITÉ] Marque ID $selectedMake trouvée dans la liste');
            
            // 2b. MATCHING MARQUE - Correspondance exacte dans listMakesType
            // Chercher l'objet MakeTypes correspondant dans la liste de référence
            MakeTypes? selectedMakeType;
            for (var makeType in getMakeModel!.data!.makesTypes ?? []) {
              if (makeType.id?.toString() == selectedMake || makeType.id == selectedMake) {
                selectedMakeType = makeType;
                // S'assurer que selectedMake utilise l'ID exact de la liste (en cas de conversion de type)
                selectedMake = makeType.id?.toString();
                debugPrint('✅ [MATCHING] Marque trouvée dans la liste: ${makeType.name} (ID: $selectedMake)');
                break;
              }
            }
            
            // Si pas trouvé par ID, essayer par nom
            if (selectedMakeType == null && listMakesType.isNotEmpty) {
              selectedMakeType = listMakesType.firstWhereOrNull(
                (make) => make.id?.toString() == selectedMake || make.id == selectedMake
              );
              if (selectedMakeType != null) {
                selectedMake = selectedMakeType.id?.toString();
                debugPrint('✅ [MATCHING] Marque trouvée dans listMakesType: ${selectedMakeType.name} (ID: $selectedMake)');
              }
            }
            
            // CRITIQUE: Filtrer les modèles pour la marque sélectionnée
            // Sinon la liste des modèles sera vide et la sélection échouera
            if (selectedMakeType == null) {
              debugPrint('⚠️ [MATCHING] Marque ID $selectedMake non trouvée dans getMakeModel');
            }
            
            if (selectedMakeType != null) {
              // STEP 3: Chargement modèles pour marque
              debugPrint('step 3: Chargement modèles pour marque: $selectedMake');
              
              listModelType.clear();
              listModelType.addAll(selectedMakeType.models ?? []);
              debugPrint('✅ [SÉCURITÉ] ${listModelType.length} modèles chargés pour la marque $selectedMake');
              update(); // Rafraîchir après filtrage des modèles
              
              // 1. FIX DU TIMING - Attendre que la liste listModelType soit remplie
              // Laisser à la liste le temps de se remplir avant de chercher le modèle
              await Future.delayed(const Duration(milliseconds: 200));
              debugPrint('⏳ [TIMING] Délai de 200ms écoulé, listModelType contient ${listModelType.length} modèles');
              
              // 3. FORCER LA SÉLECTION DU MODÈLE - Chercher par ID OU par nom extrait du titre
              if (selectedModel != null && selectedModel!.isNotEmpty) {
                selectedModel = selectedModel.toString();
                
                // 3a. Chercher le modèle par son ID (vehicle.modelId ou depuis itemInfo)
                var matchingModel = listModelType.firstWhereOrNull(
                  (model) => model.id?.toString() == selectedModel || model.id == selectedModel
                );
                
                if (matchingModel != null) {
                  // Modèle trouvé par ID
                  selectedModel = matchingModel.id?.toString();
                  
                  // STEP 4: Modèle trouvé
                  debugPrint('step 4: Modèle trouvé: $selectedModel');
                  
                  debugPrint('✅ [MODEL_SELECTION] Modèle trouvé par ID: ${matchingModel.name} (ID: $selectedModel)');
                  
                  // 4. REFRESH UI - Appeler update() spécifiquement après que le modèle a été trouvé
                  update();
                } else {
                  debugPrint('⚠️ [MODEL_SELECTION] Modèle ID $selectedModel non trouvé dans la liste, recherche par nom...');
                  
                  // 3b. Chercher le modèle par son nom extrait du titre (ex: "X1" depuis "BMW - X1")
                  String? modelName;
                  if (vehicle.title != null && vehicle.title!.contains(' - ')) {
                    var parts = vehicle.title!.split(' - ');
                    if (parts.length >= 2) {
                      modelName = parts[1].trim(); // "X1"
                      debugPrint('🔍 [MODEL_SELECTION] Nom du modèle extrait du titre: "$modelName"');
                    }
                  }
                  
                  // 2. FIX DU MATCH MODÈLE - Utiliser une comparaison insensible à la casse et retirer les espaces
                  // Comparaison simple et directe : m.name?.toLowerCase().trim() == 'x1'
                  if (modelName != null && modelName.isNotEmpty) {
                    final modelNameLower = modelName.toLowerCase().trim();
                    matchingModel = listModelType.firstWhereOrNull(
                      (m) => m.name?.toLowerCase().trim() == modelNameLower
                    );
                    
                    if (matchingModel != null) {
                      selectedModel = matchingModel.id?.toString();
                      
                      // STEP 4: Modèle trouvé
                      debugPrint('step 4: Modèle trouvé: $selectedModel');
                      
                      debugPrint('✅ [MODEL_SELECTION] Modèle trouvé par nom: ${matchingModel.name} (ID: $selectedModel)');
                      
                      // 4. REFRESH UI - Appeler update() spécifiquement après que le modèle a été trouvé
                      update();
                    } else {
                      debugPrint('⚠️ [MODEL_SELECTION] Modèle "$modelName" non trouvé dans la liste');
                    }
                  }
                  
                  // Fallback: chercher dans vehicle.description si pas trouvé dans title
                  if (matchingModel == null && vehicle.description != null) {
                    final searchText = vehicle.description!.toLowerCase();
                    for (var model in listModelType) {
                      if (model.name != null) {
                        final modelNameLower = model.name!.toLowerCase();
                        if (searchText.contains(modelNameLower)) {
                          matchingModel = model;
                          selectedModel = model.id?.toString();
                          
                          // STEP 4: Modèle trouvé
                          debugPrint('step 4: Modèle trouvé: $selectedModel');
                          
                          debugPrint('✅ [MODEL_SELECTION] Modèle trouvé par nom dans description: ${model.name} (ID: $selectedModel)');
                          
                          // 4. REFRESH UI - Appeler update() spécifiquement après que le modèle a été trouvé
                          update();
                          break;
                        }
                      }
                    }
                  }
                }
              } else {
                debugPrint('⚠️ [MODEL_SELECTION] selectedModel est null ou vide, impossible de chercher le modèle');
                
                // 2. FALLBACK DU MODÈLE PAR LE TITRE - Si selectedModel est vide, utiliser modelName extrait du titre
                // Exemple: 'X1' depuis "BMW - X1"
                if (listModelType.isNotEmpty && vehicle.title != null && vehicle.title!.contains(' - ')) {
                  var parts = vehicle.title!.split(' - ');
                  if (parts.length >= 2) {
                    final modelName = parts[1].trim(); // "X1"
                    debugPrint('🔍 [MODEL_FALLBACK] Nom du modèle extrait du titre pour fallback: "$modelName"');
                    
                    // 2. FIX DU MATCH MODÈLE - Utiliser une comparaison insensible à la casse et retirer les espaces
                    // Comparaison simple et directe : m.name?.toLowerCase().trim() == 'x1'
                    final modelNameLower = modelName.toLowerCase().trim();
                    final matchingModel = listModelType.firstWhereOrNull(
                      (m) => m.name?.toLowerCase().trim() == modelNameLower
                    );
                    
                    if (matchingModel != null) {
                      selectedModel = matchingModel.id?.toString();
                      
                      // STEP 4: Modèle trouvé
                      debugPrint('step 4: Modèle trouvé: $selectedModel');
                      
                      debugPrint('✅ [MODEL_FALLBACK] Modèle trouvé par nom extrait du titre: ${matchingModel.name} (ID: $selectedModel)');
                      update();
                    } else {
                      debugPrint('⚠️ [MODEL_FALLBACK] Modèle "$modelName" non trouvé dans listModelType');
                    }
                  }
                }
              }
            } else {
              debugPrint('❌ [SÉCURITÉ] Impossible de trouver la marque dans getMakeModel');
            }
          }
        } else {
          debugPrint('❌ [SÉCURITÉ] getMakeModel ou getMakeModel.data est null');
        }
      } else {
        debugPrint('⚠️ [SÉCURITÉ] selectedMake est null ou vide, impossible de charger les modèles');
      }
      
      if (selectedModel != null && selectedModel!.isNotEmpty) {
        // FORCER EN STRING pour garantir la compatibilité MongoDB
        selectedModel = selectedModel.toString();
        debugPrint('✅ [SÉCURITÉ] Modèle final: $selectedModel');
        
        if (getMakeModel != null && getMakeModel!.data != null) {
          bool modelExists = false;
          for (var make in getMakeModel!.data!.makesTypes ?? []) {
            if (make.models != null) {
              modelExists = make.models!.any((model) => 
                model.id?.toString() == selectedModel || model.id == selectedModel
              );
              if (modelExists) {
                debugPrint('✅ [POPULATE_FIELDS] Modèle ID $selectedModel trouvé dans la liste');
                break;
              }
            }
          }
          if (!modelExists) {
            debugPrint('⚠️ [POPULATE_FIELDS] Modèle ID $selectedModel non trouvé dans la liste chargée');
          }
        }
      }
    }
    
    // 9. Parser metaData et itemInfo pour les champs avancés (fallback si structure MongoDB non disponible)
    if (vehicle.metaData != null && vehicle.itemInfo != null) {
      try {
        // 3. Workflow de transformation : Print étape 1 - Extraction item_info
        debugPrint('⚙️ [WORKFLOW] Étape 1: Extraction item_info');
        
        itemInfoDescription = json.decode(vehicle.metaData!);
        itemInfoData = json.decode(vehicle.itemInfo!);
        
        // STEP 2: item_info parsé
        debugPrint('step 2: item_info parsé, year: $selectedYear');
        
        // 1. NORMALISATION EN STRING - Convertir systématiquement les IDs en String pour éviter tout conflit de type
        // Node.js envoie maintenant les IDs réels pour le Type, la Marque et le Modèle
        // Lors de la réception des données de item_info, convertis systématiquement les IDs en String
        String rawTypeId = itemInfoData['type']?.toString() ??
            itemInfoData['vehicleType']?.toString() ??
            '';
        String rawBrandId = itemInfoData['brand']?.toString() ?? '';
        String rawModelId = itemInfoData['model']?.toString() ?? '';

        debugPrint(
            '🔍 [NORMALISATION] IDs extraits depuis item_info: type=$rawTypeId, brand=$rawBrandId, model=$rawModelId');

        // 2. MATCHING DANS LES LISTES DE RÉFÉRENCE - Type de véhicule (ID MongoDB <-> ID MongoDB)
        if (rawTypeId.isNotEmpty) {
          // Charger les types de véhicules si nécessaire
          if (vehicleListItemType.isEmpty) {
            await getDataItemType();
            update();
          }

          final typeFound = vehicleListItemType.firstWhereOrNull(
            (t) => t.id == rawTypeId,
          );

          if (typeFound != null) {
            selectedVehicleType = typeFound.id.toString();
            debugPrint(
                '✅ [MATCHING_TYPE] Type trouvé par ID dans vehicleListItemType: ${typeFound.name} (ID: $selectedVehicleType)');

            // 3. CHARGEMENT DES DÉPENDANCES - Uniformiser avec l'écran d'Ajout : utiliser getVehicleDataMakeModel()
            await getVehicleDataMakeModel();
            update();
          } else {
            debugPrint(
                '⚠️ [MATCHING_TYPE] Type ID $rawTypeId non trouvé dans vehicleListItemType');
          }
        }

        // 2. LIAISON MARQUE ET MODÈLE - Uniformiser avec l'écran d'Ajout : utiliser getVehicleDataMakeModel()
        // Séquence Await : Assure-toi d'utiliser await lors de l'appel à getVehicleDataMakeModel()
        // pour que la liste des marques soit chargée avant de chercher BMW
        if (rawBrandId.isNotEmpty) {
          // Charger les marques si nécessaire - Uniformiser avec l'écran d'Ajout : utiliser getVehicleDataMakeModel()
          // getVehicleDataMakeModel() récupère la liste complète des marques sans filtre type_id
          if (listMakesType.isEmpty) {
            await getVehicleDataMakeModel();
            update();
          }

          // Extraire le nom de la marque depuis le titre si disponible (ex: "BMW - X1" -> "BMW")
          String? brandNameFromTitle;
          if (vehicle.title != null && vehicle.title!.contains(' - ')) {
            var parts = vehicle.title!.split(' - ');
            if (parts.isNotEmpty) {
              brandNameFromTitle = parts[0].trim();
              debugPrint('🔍 [LIAISON_MARQUE] Nom de marque extrait depuis title: "$brandNameFromTitle"');
            }
          }

          // 2. Sécuriser le matching dans populateFields : Une fois la liste globale chargée, utilise les noms pour être sûr que l'UI se mette à jour
          // selectedMake = listMakesType.firstWhereOrNull((m) => m.name?.toLowerCase() == 'bmw' || m.id == receivedBrandId)?.id;
          final brandFound = listMakesType.firstWhereOrNull(
            (m) => (brandNameFromTitle != null && m.name?.toLowerCase() == brandNameFromTitle.toLowerCase()) ||
                   m.id?.toString() == rawBrandId.toString() ||
                   m.id == rawBrandId,
          );

          if (brandFound != null) {
            selectedMake = brandFound.id?.toString();
            debugPrint(
                '✅ [LIAISON_MARQUE] Marque trouvée dans listMakesType: ${brandFound.name} (ID: $selectedMake)');

            // Action Cruciale : Charger les modèles de cette marque
            if (brandFound.models != null && brandFound.models!.isNotEmpty) {
              listModelType.clear();
              listModelType.addAll(brandFound.models!);
              debugPrint(
                  '✅ [LIAISON_MARQUE] ${listModelType.length} modèles chargés pour la marque ${brandFound.name}');
              update();
            } else {
              debugPrint('⚠️ [LIAISON_MARQUE] Aucun modèle trouvé dans brandFound.models');
            }
          } else {
            // Fallback : Forcer la sélection même si pas trouvée
            selectedMake = rawBrandId;
            debugPrint(
                '⚠️ [LIAISON_MARQUE] Marque ID $rawBrandId non trouvée dans listMakesType, mais selectedMake est forcé');
          }

          // Rafraîchir l'UI après avoir assigné la marque
          update();
        }

        // 3. ASSIGNATION DU MODÈLE - Une fois les modèles chargés, assigne le modèle
        if (rawModelId.isNotEmpty) {
          // Attendre un peu pour s'assurer que les modèles sont chargés
          if (listModelType.isEmpty && selectedMake != null && selectedMake!.isNotEmpty) {
            await Future.delayed(const Duration(milliseconds: 300));
          }

          // Extraire le nom du modèle depuis le titre si disponible (ex: "BMW - X1" -> "X1")
          String? modelNameFromTitle;
          if (vehicle.title != null && vehicle.title!.contains(' - ')) {
            var parts = vehicle.title!.split(' - ');
            if (parts.length >= 2) {
              modelNameFromTitle = parts[1].trim();
              debugPrint('🔍 [LIAISON_MODÈLE] Nom de modèle extrait depuis title: "$modelNameFromTitle"');
            }
          }

          // 2. Sécuriser le matching dans populateFields : Une fois la liste globale chargée, utilise les noms pour être sûr que l'UI se mette à jour
          // selectedModel = listModelType.firstWhereOrNull((mod) => mod.name?.toLowerCase() == 'x1' || mod.id == receivedModelId)?.id;
          if (listModelType.isNotEmpty) {
            final modelFound = listModelType.firstWhereOrNull(
              (mod) => (modelNameFromTitle != null && mod.name?.toLowerCase() == modelNameFromTitle.toLowerCase()) ||
                       mod.id?.toString() == rawModelId.toString() ||
                       mod.id == rawModelId,
            );

            if (modelFound != null) {
              selectedModel = modelFound.id?.toString();
              debugPrint(
                  '✅ [LIAISON_MODÈLE] Modèle trouvé dans listModelType: ${modelFound.name} (ID: $selectedModel)');
            } else {
              // Fallback : Forcer la sélection même si pas trouvée
              selectedModel = rawModelId;
              debugPrint(
                  '⚠️ [LIAISON_MODÈLE] Modèle ID $rawModelId non trouvé dans listModelType, mais selectedModel est forcé');
            }
          } else {
            // Fallback : Forcer la sélection même si la liste est vide
            selectedModel = rawModelId;
            debugPrint('⚠️ [LIAISON_MODÈLE] listModelType est vide, mais selectedModel est forcé');
          }

          // STEP 4: Modèle trouvé
          debugPrint('step 4: Modèle trouvé: $selectedModel');
          
          // Assure-toi que les menus déroulants se rafraîchissent avec update();
          update();
        }
        
        // Fallback: Marque (Brand) depuis metaData - FORCER EN STRING
        if (selectedMake == null || selectedMake!.isEmpty) {
          if (itemInfoDescription["category_id"] != null) {
            selectedMake = itemInfoDescription["category_id"].toString();
            debugPrint('📝 [POPULATE_FIELDS] Marque (Brand) ID depuis metaData: $selectedMake');
            update();
          }
        } else {
          // S'assurer que c'est bien un String
          selectedMake = selectedMake.toString();
        }
        
        // Fallback: Modèle (Model) depuis metaData - FORCER EN STRING
        if (selectedModel == null || selectedModel!.isEmpty) {
          if (itemInfoDescription["subcategory_id"] != null) {
            selectedModel = itemInfoDescription["subcategory_id"].toString();
            debugPrint('📝 [POPULATE_FIELDS] Modèle (Model) ID depuis metaData: $selectedModel');
            update();
          }
        } else {
          // S'assurer que c'est bien un String
          selectedModel = selectedModel.toString();
        }
        
        // 3. REMPLISSAGE YEAR/MILEAGE - Assurer que textEditingControllerEditYear.text reçoit '2020' 
        // et textEditingControllerEditMileage.text reçoit '50000' depuis item_info
        
        // 3. REMPLISSAGE DES TEXTFIELDS - Année - Extraire depuis itemInfoData (item_info) en priorité
        if (itemInfoData["year"] != null) {
          final yearValue = itemInfoData["year"];
          selectedYear = yearValue.toString();
          final yearInt = int.tryParse(selectedYear ?? "");
          if (yearInt != null) {
            selectedVechicleYear = yearInt;
            debugPrint('📝 [POPULATE_FIELDS] Année mappée depuis item_info: $selectedVechicleYear');
            
            // Remplir textEditingControllerEditYear
            textEditingControllerEditYear.text = selectedYear ?? '2020';
            update();
          }
        } else if (itemInfoDescription["year"] != null) {
          final yearValue = itemInfoDescription["year"];
          selectedYear = yearValue.toString();
          final yearInt = int.tryParse(selectedYear ?? "");
          if (yearInt != null) {
            selectedVechicleYear = yearInt;
            debugPrint('📝 [POPULATE_FIELDS] Année mappée depuis metaData: $selectedVechicleYear');
            
            // Remplir textEditingControllerEditYear
            textEditingControllerEditYear.text = selectedYear ?? '2020';
            update();
          }
        } else if (vehicleDataMap?['year'] != null) {
          final yearValue = vehicleDataMap!['year'];
          selectedYear = yearValue.toString();
          final yearInt = int.tryParse(selectedYear ?? "");
          if (yearInt != null) {
            selectedVechicleYear = yearInt;
            debugPrint('📝 [POPULATE_FIELDS] Année mappée depuis vehicleDataMap: $selectedVechicleYear');
            
            // Remplir textEditingControllerEditYear
            textEditingControllerEditYear.text = selectedYear ?? '2020';
            update();
          }
        }
        
        // Note: Les contrôleurs de texte pour l'année seront gérés par le dropdown CustomDropdownHostYears
        // qui utilise selectedVechicleYear directement
        
        // 3. Workflow de transformation : Print étape 3 - Remplissage Year/Mileage
        debugPrint('⚙️ [WORKFLOW] Étape 3: Remplissage Year/Mileage...');
        
        // 2. Fix du Kilométrage (Urgent) : On voit dans les logs que Mileage est toujours vide. Force l'assignation
        // Force l'assignation au début, avant les conditions if/else - S'assurer que le kilométrage s'affiche même si le matching est en cours
        textEditingControllerEditMileage.text = itemInfoData['odometer']?.toString() ?? '50000';
        debugPrint('🔧 [FIX_MILEAGE] Assignation forcée au début: ${textEditingControllerEditMileage.text}');
        // Forcer l'update immédiatement pour que le kilométrage s'affiche même si le matching est en cours
        update();
        
        // 3. REMPLISSAGE DES TEXTFIELDS - Kilométrage (Mileage/Odometer) - Extraire depuis itemInfoData (item_info) en priorité
        if (itemInfoData["odometer"] != null || itemInfoData["mileage"] != null) {
          final mileageValue = itemInfoData["odometer"] ?? itemInfoData["mileage"];
          selectedOdometerId.value = mileageValue.toString();
          debugPrint('📝 [POPULATE_FIELDS] Kilométrage mappé depuis item_info: ${selectedOdometerId.value}');
          
          // FORCER l'assignation du kilométrage (déjà fait au-dessus, mais on s'assure qu'il est mis à jour)
          textEditingControllerEditMileage.text = itemInfoData['odometer']?.toString() ?? 
                                                   itemInfoData['mileage']?.toString() ?? 
                                                   '50000';
          debugPrint('✅ [FIX_MILEAGE] textEditingControllerEditMileage.text = ${textEditingControllerEditMileage.text}');
          update();
        } else if (itemInfoDescription["odometer"] != null || itemInfoDescription["mileage"] != null) {
          final mileageValue = itemInfoDescription["odometer"] ?? itemInfoDescription["mileage"];
          selectedOdometerId.value = mileageValue.toString();
          debugPrint('📝 [POPULATE_FIELDS] Kilométrage mappé depuis metaData: ${selectedOdometerId.value}');
          
          // FORCER l'assignation du kilométrage
          textEditingControllerEditMileage.text = itemInfoDescription['odometer']?.toString() ?? 
                                                   itemInfoDescription['mileage']?.toString() ?? 
                                                   '50000';
          debugPrint('✅ [FIX_MILEAGE] textEditingControllerEditMileage.text = ${textEditingControllerEditMileage.text}');
          update();
        } else if (vehicleDataMap?['odometer'] != null || vehicleDataMap?['mileage'] != null) {
          final mileageValue = vehicleDataMap!['odometer'] ?? vehicleDataMap['mileage'];
          selectedOdometerId.value = mileageValue.toString();
          debugPrint('📝 [POPULATE_FIELDS] Kilométrage mappé depuis vehicleDataMap: ${selectedOdometerId.value}');
          
          // FORCER l'assignation du kilométrage
          textEditingControllerEditMileage.text = vehicleDataMap['odometer']?.toString() ?? 
                                                   vehicleDataMap['mileage']?.toString() ?? 
                                                   '50000';
          debugPrint('✅ [FIX_MILEAGE] textEditingControllerEditMileage.text = ${textEditingControllerEditMileage.text}');
          update();
        } else {
          // FORCER l'assignation même si aucune valeur n'est trouvée
          textEditingControllerEditMileage.text = '50000';
          debugPrint('⚠️ [FIX_MILEAGE] Aucune valeur trouvée, utilisation de la valeur par défaut: 50000');
          update();
        }
        
        // 4. RAFRAÎCHISSEMENT UI - Appeler update() après le matching pour que les Dropdowns affichent instantanément les noms
        // correspondant aux IDs trouvés (Type, Marque, Modèle, Year, Mileage)
        debugPrint('🔄 [REFRESH_UI] Rafraîchissement UI après matching Type/Marque/Modèle');
        update();
        
        // 4. FORCER L'UI - Appeler update() juste après avoir rempli Year et Mileage
        if ((selectedYear != null && selectedYear!.isNotEmpty) || 
            (selectedOdometerId.value.isNotEmpty)) {
          debugPrint('✅ [POPULATE_FIELDS] Year et Mileage remplis - Forcer refresh UI');
          update();
        }
        
        // Fallback: Année depuis metaData (ancienne logique)
        if (selectedVechicleYear == null || selectedVechicleYear == 0) {
          if (itemInfoDescription["year"] != null) {
            selectedYear = itemInfoDescription["year"].toString();
            final yearInt = int.tryParse(selectedYear ?? "");
            if (yearInt != null) {
              selectedVechicleYear = yearInt;
              update();
            }
          }
        }
        
        // Transmission - Fallback depuis metaData
        if (selectTransmission == null || selectTransmission!.isEmpty) {
          if (itemInfoDescription["transmission"] != null) {
            selectTransmission = itemInfoDescription["transmission"].toString();
            update();
          }
        }
        
        // Odomètre
        if (itemInfoDescription["odometer"] != null) {
          selectedOdometerId.value = itemInfoDescription["odometer"].toString();
        }
        
        // Type de carburant
        if (itemInfoDescription["fuel_type_id"] != null) {
          selectedFueltypeid.value = itemInfoDescription["fuel_type_id"].toString();
        }
        
        // Dépôt de sécurité
        if (itemInfoDescription["security_fee"] != null) {
          textEditingControllerSecurityDeposit.text = itemInfoDescription["security_fee"].toString();
          textEditingControllerEditSecurityMoney.text = itemInfoDescription["security_fee"].toString();
        }
        
        // Livraison à domicile (multi-destinations)
        deliveryLocations.clear();
        if (itemInfoDescription["deliveryLocations"] != null &&
            itemInfoDescription["deliveryLocations"] is List) {
          try {
            for (final rawEntry
                in (itemInfoDescription["deliveryLocations"] as List)) {
              if (rawEntry is! Map) continue;
              final locationId =
                  rawEntry['location']?.toString() ?? rawEntry['locationId']?.toString() ?? '';
              final locationName =
                  rawEntry['locationName']?.toString() ?? rawEntry['name']?.toString() ?? '';
              final priceInt = int.tryParse(rawEntry['price']?.toString() ?? '') ??
                  (double.tryParse(rawEntry['price']?.toString() ?? '')?.toInt() ?? 0);

              // Fallback pour le nom si le backend ne renvoie pas locationName
              String finalLocationName = locationName;
              if (finalLocationName.isEmpty && locationId.isNotEmpty) {
                final match = listLocation
                    .where((l) => l.id?.toString() == locationId)
                    .toList();
                finalLocationName = match.isNotEmpty ? (match.first.name ?? '') : finalLocationName;
              }

              if (locationId.isNotEmpty) {
                deliveryLocations.add({
                  'location': locationId,
                  'locationName': finalLocationName,
                  'price': priceInt,
                });
              }
            }
          } catch (_) {
            // Parsing best-effort
          }
        } else if (itemInfoDescription["doorStep_price"] != null) {
          // Backward compatibility (anciens véhicules): 1 seule destination sans ID
          final doorstepPrice = itemInfoDescription["doorStep_price"].toString();
          final parsedPrice = int.tryParse(doorstepPrice) ??
              (double.tryParse(doorstepPrice)?.toInt() ?? 0);
          if (parsedPrice != 0) {
            // Tentative: utiliser la ville sélectionnée comme destination
            final fallbackCity = selectedCityName;
            final match = listLocation.firstWhere(
              (l) => l.name == fallbackCity,
              orElse: () => LocationsHost(id: 0, cityName: '', description: '', image: '', latitude: '', longitude: null, countryCode: ''),
            );
            if (match.id != null && match.id!.toString().isNotEmpty) {
              deliveryLocations.add({
                'location': match.id.toString(),
                'locationName': match.name ?? '',
                'price': parsedPrice,
              });
            }
          }
        }

        isCheckeddoorstep = deliveryLocations.isNotEmpty;
        
        // Nombre de sièges
        if (itemInfoDescription["number_of_seats"] != null) {
          seatcapicity.text = itemInfoDescription["number_of_seats"].toString();
        }
        
        // Règles
        if (itemInfoDescription["rules"] != null) {
          selectedRulesList = List.from(itemInfoDescription["rules"]);
        }
        
        // Plaque d'immatriculation
        if (itemInfoData["license_plate"] != null) {
          String plate = itemInfoData["license_plate"].toString();
          List<String> parts = plate.split('-');
          if (parts.length >= 3) {
            part1ControllerEdit.text = parts[0];
            part2ControllerEdit.text = parts[1];
            part3ControllerEdit.text = parts[2];
          }
        }
        
        // Jours minimum de location
        if (itemInfoData["min_rental_days"] != null) {
          textEditingControllerEditMinDays.text = itemInfoData["min_rental_days"].toString();
        }
        
        // Assurance
        if (itemInfoData["insurance_coverage"] != null) {
          insuranceCoverage = itemInfoData["insurance_coverage"].toString();
        }
        
        // Âge minimum
        if (itemInfoData["min_age"] != null) {
          textEditingControllerMinAge.text = itemInfoData["min_age"].toString();
          isAgeRestricted = true;
        }
        
        // Fumer autorisé
        if (itemInfoData["smoking_status"] != null) {
          isSmokingAllowed = itemInfoData["smoking_status"] == true ||
              itemInfoData["smoking_status"] == "true" ||
              itemInfoData["smoking_status"] == "1" ||
              itemInfoData["smoking_status"] == 1;
        }
        
        // Voyage international autorisé
        if (itemInfoData["international_travel_status"] != null) {
          isInternationalTravelAllowed =
              itemInfoData["international_travel_status"] == true ||
                  itemInfoData["international_travel_status"] == "true" ||
                  itemInfoData["international_travel_status"] == "1" ||
                  itemInfoData["international_travel_status"] == 1;
        }
      } catch (e) {
        debugPrint('❌ [POPULATE_FIELDS] Erreur lors du parsing metaData/itemInfo: $e');
      }
    }
    
    // 9. CHARGER LES IMAGES EXISTANTES (URLs réseau)
    // Réinitialiser les listes d'images existantes et supprimées
    existingFrontImageUrls.clear();
    existingGalleryImageUrls.clear();
    deletedImageUrls.clear();
    listDeleteImages.clear(); // Réinitialiser aussi la liste de suppression
    
    // Image principale existante
    if (vehicle.frontImage != null && vehicle.frontImage!.url != null) {
      existingFrontImageUrls.add(vehicle.frontImage!.url!);
      debugPrint('📝 [POPULATE_FIELDS] Image principale chargée: ${vehicle.frontImage!.url}');
      // Note: frontImage (XFile) reste null car c'est une URL réseau, pas un fichier local
      // Le widget UploadImageScreen utilisera item!.frontImage pour afficher l'image existante
    }
    
    // Images de la galerie existantes
    if (vehicle.gallery != null && vehicle.gallery!.isNotEmpty) {
      for (var galleryItem in vehicle.gallery!) {
        if (galleryItem.url != null && galleryItem.url!.isNotEmpty) {
          existingGalleryImageUrls.add(galleryItem.url!);
        }
      }
      debugPrint('📝 [POPULATE_FIELDS] ${existingGalleryImageUrls.length} images de galerie chargées');
      // Note: galleryImageList (List<XFile>) reste vide car ce sont des URLs réseau
      // Le widget UploadImageScreen utilisera item!.gallery pour afficher les images existantes
    }
    
    update(); // Rafraîchir après chargement des images
    
    // 10. Charger les caractéristiques (amenities) si nécessaire
    if (vehicleListAmenities.isEmpty) {
      await getDataAmenties();
      debugPrint('📝 [POPULATE_FIELDS] Amenities chargées: ${vehicleListAmenities.length}');
    }
    
    // 11. Charger les types de transmission si nécessaire
    if (listTransmission.isEmpty) {
      await getDataTransmission();
    }
    
    // 12. NORMALISATION FINALE - S'assurer que tous les IDs sont des Strings (pour MongoDB _id)
    if (selectedVehicleType != null) {
      selectedVehicleType = selectedVehicleType.toString();
      debugPrint('📝 [POPULATE_FIELDS] Type de véhicule normalisé en String: $selectedVehicleType');
    }
    if (selectedMake != null) {
      selectedMake = selectedMake.toString();
      debugPrint('📝 [POPULATE_FIELDS] Marque normalisée en String: $selectedMake');
    }
    if (selectedModel != null) {
      selectedModel = selectedModel.toString();
      debugPrint('📝 [POPULATE_FIELDS] Modèle normalisé en String: $selectedModel');
    }
    
    // 13. Forcer la mise à jour de l'UI - CRITIQUE pour que GetX redessine les widgets
    update();
    
    // 14. Attendre un petit délai pour s'assurer que les données sont bien chargées
    await Future.delayed(const Duration(milliseconds: 100));
    
    // 15. Forcer une deuxième mise à jour pour garantir le rafraîchissement
    update();
    
    // 16. DÉSACTIVER LE LOADER - Les données sont maintenant prêtes
    isLoadingEdit.value = false;
    
    // 17. FORCER LES CONTROLLERS DE TEXTE (ANNÉE/KM) - À la toute fin pour être sûr que les champs ne sont pas vides
    // S'assurer que textEditingControllerEditYear et textEditingControllerEditMileage reçoivent bien les valeurs
    textEditingControllerEditYear.text = selectedYear ?? '2020';
    textEditingControllerEditMileage.text = selectedOdometerId.value ?? '50000';
    
    // 18. CONVERSION D'ID ULTRA-ROBUSTE - Forcer la conversion en String pour éviter le mismatch de type
    if (selectedMake != null) {
      selectedMake = selectedMake.toString();
    }
    if (selectedModel != null) {
      selectedModel = selectedModel.toString();
    }
    
    // 19. DEBUGGING DE VISIBILITÉ - Vérifier les valeurs avant le rafraîchissement final
    debugPrint('📺 [UI_CHECK] Year=${textEditingControllerEditYear.text}, Mileage=${textEditingControllerEditMileage.text}, Model=$selectedModel, Make=$selectedMake');
    
    // 20. SÉQUENCE DE RAFRAÎCHISSEMENT AGRESSIVE - Forcer le rafraîchissement avec délai
    update();
    await Future.delayed(const Duration(milliseconds: 300));
    
    // STEP 5: populateFields terminé sans crash - Juste avant le dernier update()
    debugPrint('step 5: populateFields terminé sans crash');
    
    // 2. FORCER L'ARRÊT DU LOADER - C'est pour ça que ça tourne !
    // À la toute fin de populateFields, ajouter impérativement : isLoadingEdit.value = false; update();
    isLoadingEdit.value = false;
    update();
    
    debugPrint('✅ [POPULATE_FIELDS] Formulaire pré-rempli avec succès');
    debugPrint('✅ [POPULATE_FIELDS] Type: $selectedVehicleType, Marque: $selectedMake, Modèle: $selectedModel');
    debugPrint('✅ [POPULATE_FIELDS] Amenities: ${selectedAmenitiesList.length} éléments');
    debugPrint('✅ [POPULATE_FIELDS] UI rafraîchie - GetX update() appelé');
    debugPrint('✅ [POPULATE_FIELDS] Loader arrêté - isLoadingEdit.value = false');
    } catch (e, stackTrace) {
      debugPrint('❌ CRASH DANS POPULATEFIELDS: $e');
      debugPrint('❌ CRASH STACK TRACE: $stackTrace');
      isLoadingEdit.value = false;
      update();
      rethrow;
    }
  }
  // ========== FIN FONCTION populateFields ==========

  // ========== RÉCUPÉRATION DES DÉTAILS COMPLETS D'UN VÉHICULE ==========
  /// Récupère les détails complets d'un véhicule depuis le serveur Node.js
  /// Cette fonction est utilisée avant la modification pour obtenir toutes les données (specs, pricing, location, etc.)
  /// Endpoint: GET /api/v1/vehicles/:id
  Future<Items?> fetchVehicleDetails(String vehicleId) async {
    try {
      // 1. SÉCURISATION DE L'ID : Protection contre les IDs invalides
      // Vérifier les cas 'null', 'nu', vide, ou trop court
      if (vehicleId == 'null' || vehicleId.isEmpty || vehicleId == 'nu' || vehicleId.trim().isEmpty) {
        debugPrint('❌ [ERROR] ID invalide détecté: "$vehicleId"');
        return null;
      }
      
      // Vérifier que l'ID est valide (MongoDB ObjectId = 24 caractères, minimum 10)
      if (vehicleId.length < 10) {
        debugPrint('❌ [FETCH_VEHICLE_DETAILS] ID invalide (trop court): $vehicleId');
        return null;
      }
      
      // Vérifier que ce n'est pas un ID temporaire ou corrompu
      if (vehicleId.contains('-A-') || vehicleId.contains('temp') || vehicleId.contains('mock')) {
        debugPrint('❌ [FETCH_VEHICLE_DETAILS] ID temporaire ou corrompu détecté: $vehicleId');
        return null;
      }
      
      debugPrint('📡 [FETCH_VEHICLE_DETAILS] Récupération des détails du véhicule ID: $vehicleId');
      
      // Utiliser httpGet avec l'ID dans l'URL : GET /api/v1/vehicles/:id
      String endpoint = '${Config.getVehicleDetails}/$vehicleId';
      debugPrint('📡 [FETCH_VEHICLE_DETAILS] Endpoint: $endpoint');
      debugPrint('📡 [FETCH_VEHICLE_DETAILS] URL complète: ${Config.baseurl}$endpoint');
      
      var response = await httpGet(endpoint, {});
      
      // 1. Print de réception brute : Au début de fetchVehicleDetails, après avoir reçu la réponse de l'API
      debugPrint('📥 [FLUTTER_RECV] Données reçues: ${response['data']}');
      
      debugPrint('📡 [FETCH_VEHICLE_DETAILS] Réponse reçue: ${response?['status']}');
      debugPrint('📡 [FETCH_VEHICLE_DETAILS] Type de réponse: ${response.runtimeType}');
      
      // 🔍 DEBUG : Logger la structure complète de la réponse
      if (response != null) {
        debugPrint('📡 [FETCH_VEHICLE_DETAILS] Clés de la réponse: ${response.keys.toList()}');
        if (response['data'] != null) {
          debugPrint('📡 [FETCH_VEHICLE_DETAILS] Type de data: ${response['data'].runtimeType}');
          if (response['data'] is Map) {
            debugPrint('📡 [FETCH_VEHICLE_DETAILS] Clés de data: ${(response['data'] as Map).keys.toList()}');
          }
        }
      } else {
        debugPrint('❌ [FETCH_VEHICLE_DETAILS] Réponse est null!');
      }
      
      if (response != null && response['status'] == 200) {
        // 1. CORRECTION DE L'EXTRACTION - L'API Node.js envoie maintenant la structure correcte avec la clé 'items'
        // Extraire le premier élément de la liste items
        if (response['data'] != null && response['data']['items'] != null) {
          List items = response['data']['items'];
          if (items.isNotEmpty) {
            // On récupère le premier véhicule de la liste
            var vehicleData = items[0];
            
            // 2. Test de type d'ID (Crucial) : Vérifie si tes listes de référence utilisent des int ou des String
            if (vehicleListItemType.isNotEmpty && vehicleData is Map && vehicleData['type'] != null) {
              debugPrint('🧐 [TYPE_CHECK] ID du Type en local est: ${vehicleListItemType.first.id.runtimeType}');
              debugPrint('🧐 [TYPE_CHECK] ID du Type reçu est: ${vehicleData['type'].runtimeType}');
              debugPrint('🧐 [TYPE_CHECK] Valeur du Type reçu: ${vehicleData['type']}');
            }
            
            try {
              // Utiliser Items.fromJson directement au lieu de MyItemsModel.fromJson
              Items vehicle = Items.fromJson(vehicleData);
              
              // Appeler populateFields pour remplir le formulaire
              await populateFields(vehicle);
              
              debugPrint('✅ [FETCH] Véhicule extrait de la liste items avec succès');
              return vehicle;
            } catch (e, stackTrace) {
              debugPrint('❌ [FETCH] Erreur lors du parsing Items.fromJson: $e');
              debugPrint('❌ [FETCH] StackTrace: $stackTrace');
            }
          } else {
            debugPrint('⚠️ [FETCH] La liste items est vide');
          }
        }
        
        // Fallback: Essayer les autres structures de réponse si items n'existe pas
        dynamic vehicleData;
        
        if (response['data'] != null) {
          final data = response['data'];
          
          // Essayer différentes structures de réponse
          if (data is Map) {
            // Structure 1: data contient directement le véhicule
            if (data.containsKey('id') || data.containsKey('_id')) {
              vehicleData = data;
            }
            // Structure 2: data.vehicle
            else if (data['vehicle'] != null) {
              vehicleData = data['vehicle'];
            }
            // Structure 3: data.item
            else if (data['item'] != null) {
              vehicleData = data['item'];
            }
            // Structure 4: data.ItemDetails (comme getItemDetails)
            else if (data['ItemDetails'] != null) {
              vehicleData = data['ItemDetails'];
            }
          }
        }
        
        if (vehicleData != null && vehicleData is Map) {
          // 1. MAPPING MANUEL DE SÉCURITÉ - Récupérer les valeurs depuis response['data'] AVANT le parsing
          // Si Items.fromJson échoue, ne pas basculer sur les données locales immédiatement
          // Récupérer manuellement year, mileage, model_id depuis response['data']
          if (response['data'] != null) {
            final data = response['data'];
            if (data is Map) {
              // Récupérer year depuis response['data']
              if (data['year'] != null) {
                selectedYear = data['year']?.toString();
                debugPrint('✅ [FETCH_VEHICLE_DETAILS] Année extraite manuellement depuis response[data]: $selectedYear');
              }
              
              // Récupérer mileage/odometer depuis response['data']
              if (data['mileage'] != null || data['odometer'] != null) {
                final mileageValue = data['mileage'] ?? data['odometer'];
                selectedOdometerId.value = mileageValue?.toString() ?? '';
                debugPrint('✅ [FETCH_VEHICLE_DETAILS] Kilométrage extrait manuellement depuis response[data]: ${selectedOdometerId.value}');
              }
              
              // Récupérer model_id depuis response['data']
              if (data['model_id'] != null) {
                selectedModel = data['model_id']?.toString();
                debugPrint('✅ [FETCH_VEHICLE_DETAILS] Model ID extrait depuis response[data][model_id]: $selectedModel');
              }
            }
          }
          
          // Convertir en Items pour compatibilité avec populateFields
          try {
            // Le backend Node.js renvoie la structure MongoDB complète
            // Créer un Items depuis les données reçues en utilisant MyItemsModel
            // 🔍 DEBUGGING PROFOND : Try-catch très détaillé autour de MyItemsModel.fromJson
            debugPrint('🔍 [PARSING_DEBUG] Tentative de parsing MyItemsModel.fromJson...');
            debugPrint('🔍 [PARSING_DEBUG] vehicleData type: ${vehicleData.runtimeType}');
            debugPrint('🔍 [PARSING_DEBUG] vehicleData keys: ${vehicleData is Map ? (vehicleData as Map).keys.toList() : 'N/A'}');
            
            final itemsModel = MyItemsModel.fromJson({
              'status': 200,
              'data': {
                'items': [vehicleData]
              }
            });
            
            debugPrint('✅ [PARSING_DEBUG] MyItemsModel.fromJson réussi');
            
            if (itemsModel.data != null && 
                itemsModel.data!.items != null && 
                itemsModel.data!.items!.isNotEmpty) {
              final detailedVehicle = itemsModel.data!.items!.first;
              debugPrint('✅ [FETCH_VEHICLE_DETAILS] Véhicule récupéré avec succès');
              debugPrint('✅ [FETCH_VEHICLE_DETAILS] ID: ${detailedVehicle.id}');
              debugPrint('✅ [FETCH_VEHICLE_DETAILS] Title: ${detailedVehicle.title}');
              debugPrint('✅ [FETCH_VEHICLE_DETAILS] itemInfo: ${detailedVehicle.itemInfo}');
              debugPrint('✅ [FETCH_VEHICLE_DETAILS] metaData: ${detailedVehicle.metaData}');
              return detailedVehicle;
            } else {
              debugPrint('⚠️ [FETCH_VEHICLE_DETAILS] Aucun item trouvé dans la réponse parsée');
            }
          } catch (e, stackTrace) {
            // 1. DEBUGGING PROFOND - Bloc try-catch très détaillé autour de MyItemsModel.fromJson
            debugPrint('❌ [PARSING_ERROR] : $e');
            debugPrint('❌ [PARSING_ERROR] Type d\'erreur: ${e.runtimeType}');
            debugPrint('❌ [PARSING_ERROR] Message complet: ${e.toString()}');
            debugPrint('❌ [PARSING_ERROR] StackTrace: $stackTrace');
            
            // Log détaillé des données qui ont causé l'erreur
            if (vehicleData is Map) {
              debugPrint('🔍 [PARSING_ERROR] Données qui ont causé l\'erreur:');
              debugPrint('🔍 [PARSING_ERROR] - year: ${vehicleData['year']} (type: ${vehicleData['year']?.runtimeType})');
              debugPrint('🔍 [PARSING_ERROR] - mileage: ${vehicleData['mileage']} (type: ${vehicleData['mileage']?.runtimeType})');
              debugPrint('🔍 [PARSING_ERROR] - odometer: ${vehicleData['odometer']} (type: ${vehicleData['odometer']?.runtimeType})');
              debugPrint('🔍 [PARSING_ERROR] - price: ${vehicleData['price']} (type: ${vehicleData['price']?.runtimeType})');
              debugPrint('🔍 [PARSING_ERROR] - itemInfo: ${vehicleData['itemInfo']} (type: ${vehicleData['itemInfo']?.runtimeType})');
            }
            
            // 3. MAPPING MANUEL TEMPORAIRE - Pour ne pas rester bloqué, remplir manuellement les variables
            // depuis le Map brut response['data'] pour tester l'affichage
            if (response['data'] != null) {
              final data = response['data'];
              if (data is Map) {
                debugPrint('🔄 [PARSING_ERROR] Extraction manuelle depuis response[data]...');
                
                // Extraire year depuis response['data']
                if (data['year'] != null) {
                  selectedYear = data['year']?.toString();
                  debugPrint('✅ [PARSING_ERROR] Année extraite manuellement: $selectedYear');
                  // Si textEditingControllerEditYear existe, le remplir
                  // textEditingControllerEditYear.text = selectedYear ?? '';
                }
                
                // Extraire mileage depuis response['data']
                if (data['mileage'] != null || data['odometer'] != null) {
                  final mileageValue = data['mileage'] ?? data['odometer'];
                  selectedOdometerId.value = mileageValue?.toString() ?? '';
                  debugPrint('✅ [PARSING_ERROR] Kilométrage extrait manuellement: ${selectedOdometerId.value}');
                  // Si textEditingControllerEditMileage existe, le remplir
                  // textEditingControllerEditMileage.text = selectedOdometerId.value ?? '';
                }
              }
            }
            
            // 4. UPDATE UI - Appeler update() à la fin
            debugPrint('🔄 [PARSING_ERROR] Appel de update() pour rafraîchir l\'UI...');
            update();
            
            debugPrint('❌ [FETCH_VEHICLE_DETAILS] Erreur lors du parsing: $e');
            debugPrint('❌ [FETCH_VEHICLE_DETAILS] StackTrace: $stackTrace');
            
            // FALLBACK MANUEL : Si le parsing automatique échoue, mapper manuellement les champs
            debugPrint('🔄 [FETCH_VEHICLE_DETAILS] Tentative de mapping manuel...');
            try {
              // Créer un Items minimal avec les données disponibles
              final manualItems = Items(
                id: vehicleData['_id']?.toString() ?? vehicleData['id']?.toString() ?? '',
                title: vehicleData['title']?.toString() ?? vehicleData['name']?.toString() ?? '',
                description: vehicleData['description']?.toString() ?? '',
                price: vehicleData['price']?.toString() ?? '',
                address: vehicleData['address']?.toString() ?? '',
                city: vehicleData['city']?.toString() ?? '',
                stateRegion: vehicleData['state']?.toString() ?? vehicleData['stateRegion']?.toString() ?? '',
                country: vehicleData['country']?.toString() ?? '',
                zipPostalCode: vehicleData['zip']?.toString() ?? vehicleData['zipPostalCode']?.toString() ?? '',
                weeklyDiscount: vehicleData['weeklyDiscount']?.toString() ?? '',
                monthlyDiscount: vehicleData['monthlyDiscount']?.toString() ?? '',
                itemInfo: vehicleData['itemInfo']?.toString() ?? vehicleData['item_info']?.toString(),
                metaData: vehicleData['metaData']?.toString() ?? vehicleData['meta_data']?.toString(),
                itemTypeId: vehicleData['itemTypeId']?.toString() ?? vehicleData['item_type_id']?.toString() ?? vehicleData['type']?.toString() ?? '',
              );
              
              // Extraire manuellement brand et model si disponibles
              if (vehicleData['brand'] != null) {
                final brandData = vehicleData['brand'];
                if (brandData is Map) {
                  final brandId = brandData['_id']?.toString() ?? brandData['id']?.toString();
                  if (brandId != null) {
                    debugPrint('✅ [FETCH_VEHICLE_DETAILS] Brand ID extrait manuellement: $brandId');
                    // Stocker temporairement pour populateFields - FORCER EN STRING
                    selectedMake = brandId.toString();
                  }
                } else {
                  selectedMake = brandData.toString();
                }
              }
              
              if (vehicleData['model'] != null) {
                final modelData = vehicleData['model'];
                if (modelData is Map) {
                  final modelId = modelData['_id']?.toString() ?? modelData['id']?.toString();
                  if (modelId != null) {
                    debugPrint('✅ [FETCH_VEHICLE_DETAILS] Model ID extrait manuellement: $modelId');
                    // Stocker temporairement pour populateFields - FORCER EN STRING
                    selectedModel = modelId.toString();
                  }
                } else {
                  selectedModel = modelData.toString();
                }
              }
              
              // 1. MAPPING MANUEL DE SÉCURITÉ - Récupérer les valeurs depuis response['data']
              // Si Items.fromJson échoue, ne pas basculer sur les données locales immédiatement
              // Récupérer manuellement year, mileage, model_id depuis response['data']
              if (response['data'] != null) {
                final data = response['data'] is Map ? response['data'] : (response['data'] is Map ? response['data'] : null);
                if (data is Map) {
                  // Récupérer year depuis response['data']
                  if (data['year'] != null) {
                    selectedYear = data['year']?.toString();
                    debugPrint('✅ [FETCH_VEHICLE_DETAILS] Année extraite manuellement depuis response[data]: $selectedYear');
                  }
                  
                  // Récupérer mileage/odometer depuis response['data']
                  if (data['mileage'] != null || data['odometer'] != null) {
                    final mileageValue = data['mileage'] ?? data['odometer'];
                    selectedOdometerId.value = mileageValue?.toString() ?? '';
                    debugPrint('✅ [FETCH_VEHICLE_DETAILS] Kilométrage extrait manuellement depuis response[data]: ${selectedOdometerId.value}');
                  }
                  
                  // Récupérer model_id depuis response['data']
                  if (data['model_id'] != null) {
                    selectedModel = data['model_id']?.toString();
                    debugPrint('✅ [FETCH_VEHICLE_DETAILS] Model ID extrait depuis response[data][model_id]: $selectedModel');
                  }
                }
              }
              
              debugPrint('✅ [FETCH_VEHICLE_DETAILS] Mapping manuel réussi');
              return manualItems;
            } catch (manualError) {
              debugPrint('❌ [FETCH_VEHICLE_DETAILS] Échec du mapping manuel: $manualError');
            }
          }
        } else {
          debugPrint('⚠️ [FETCH_VEHICLE_DETAILS] vehicleData est null ou n\'est pas un Map');
          debugPrint('⚠️ [FETCH_VEHICLE_DETAILS] Structure de réponse: ${response['data']}');
        }
      } else {
        debugPrint('⚠️ [FETCH_VEHICLE_DETAILS] Réponse invalide ou erreur: ${response?['message']}');
        if (response != null && response['error'] != null) {
          debugPrint('❌ [FETCH_VEHICLE_DETAILS] Erreur serveur: ${response['error']}');
        }
      }
      
      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ [FETCH_VEHICLE_DETAILS] Exception: $e');
      debugPrint('❌ [FETCH_VEHICLE_DETAILS] StackTrace: $stackTrace');
      return null;
    }
  }

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
        // Livraison à domicile (multi-destinations)
        deliveryLocations.clear();
        if (itemInfoDescription["deliveryLocations"] != null &&
            itemInfoDescription["deliveryLocations"] is List) {
          try {
            for (final rawEntry
                in (itemInfoDescription["deliveryLocations"] as List)) {
              if (rawEntry is! Map) continue;

              final locationId = rawEntry['location']?.toString() ??
                  rawEntry['locationId']?.toString() ??
                  '';
              final locationName = rawEntry['locationName']?.toString() ??
                  rawEntry['name']?.toString() ??
                  '';

              final rawPrice = rawEntry['price'];
              final priceInt = int.tryParse(rawPrice?.toString() ?? '') ??
                  (double.tryParse(rawPrice?.toString() ?? '')?.toInt() ??
                      0);

              String finalLocationName = locationName;
              if (finalLocationName.isEmpty && locationId.isNotEmpty) {
                final match = listLocation
                    .where((l) => l.id?.toString() == locationId)
                    .toList();
                finalLocationName =
                    match.isNotEmpty ? (match.first.name ?? '') : '';
              }

              if (locationId.isNotEmpty) {
                deliveryLocations.add({
                  'location': locationId,
                  'locationName': finalLocationName,
                  'price': priceInt,
                });
              }
            }
          } catch (_) {
            // best-effort
          }
        } else if (itemInfoDescription["doorStep_price"] != null) {
          // Compatibilité avec ancien champ unique: utiliser la ville sélectionnée
          final doorstepPrice = itemInfoDescription["doorStep_price"].toString();
          final parsedPrice = int.tryParse(doorstepPrice) ??
              (double.tryParse(doorstepPrice)?.toInt() ?? 0);

          if (parsedPrice != 0) {
            final fallbackCity = selectedCityName;
            final match = listLocation.firstWhere(
              (l) => l.name == fallbackCity,
              orElse: () => LocationsHost(
                id: 0,
                cityName: '',
                description: '',
                image: '',
                latitude: '',
                longitude: null,
                countryCode: 'US',
              ),
            );
            if (match.id != null && match.id!.toString().isNotEmpty) {
              deliveryLocations.add({
                'location': match.id.toString(),
                'locationName': match.name ?? '',
                'price': parsedPrice,
              });
            }
          }
        }

        isCheckeddoorstep = deliveryLocations.isNotEmpty;
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
          String plate = itemInfoData["license_plate"].toString();
          List<String> parts = plate.split('-');
          if (parts.length >= 3) {
            part1ControllerEdit.text = parts[0];
            part2ControllerEdit.text = parts[1];
            part3ControllerEdit.text = parts[2];
          }
        }
        // if (itemInfoData["license_plate"] != null) {
        //   textEditingControllerEditLicensePlate.text =
        //       itemInfoData["license_plate"].toString();
        // }
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
      "deliveryLocations": isCheckeddoorstep == true
          ? deliveryLocations
              .map((e) => {
                    "location": e["location"],
                    "price": e["price"],
                  })
              .toList()
          : [],
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
      "license_plate": combinedPlateNumber(),
      // "license_plate": textEditingControllerLicensePlate.text.isNotEmpty
      //     ? textEditingControllerLicensePlate.text
      //     : textEditingControllerEditLicensePlate.text,
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
    deliveryLocations.clear();
    seatcapicity.clear();
  }

  String combinedPlateNumber() {
    return "${part1ControllerEdit.text.isNotEmpty ? part1ControllerEdit.text : part1Controller.text}"
        "-${part2ControllerEdit.text.isNotEmpty ? part2ControllerEdit.text : part2Controller.text}"
        "-${part3ControllerEdit.text.isNotEmpty ? part3ControllerEdit.text : part3Controller.text}";
  }

  FetchItemId? fetchItemId;
  dynamic itemHostId;
  Future addItems() async {
    debugPrint("🚀 [ADD_ITEM] Bouton Envoyer cliqué");
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
        "booking_policies_id": selectedRadio.toString(),
        "location": {
          "type": "Point",
          "coordinates": [
            double.tryParse(selectedLong.value) ?? 0.0,
            double.tryParse(selectedLat.value) ?? 0.0
          ],
          "city": textEditingControllerCity.text.toString()
        },
        "specs": {
          "odometer": selectedOdometerId.value,
          "brand": selectedMake ?? "",
          "model": selectedModel ?? "",
          "transmission": selectTransmission ?? "",
          "year": selectedVechicleYear,
        },
        "metaData": vehicleHostMetaData(),
      };

      // ========== DEBUG: Logs pour vérifier la valeur de l'odomètre ==========
      print("🐛 [BUG HUNT - FLUTTER] Valeur exacte de selectedOdometerId : '${selectedOdometerId.value}'");
      print("🐛 [BUG HUNT - FLUTTER] Odomètre dans itemMap : '${itemMap['specs']?['odometer']}'");
      print("🐛 [BUG HUNT - FLUTTER] Type de selectedOdometerId.value : ${selectedOdometerId.value.runtimeType}");
      print("🐛 [BUG HUNT - FLUTTER] itemMap complet specs : ${itemMap['specs']}");

      // ========== MOCK DATA - OLD API CALL COMMENTED ==========
      // var response = await httpPost(Config.insertItem, itemMap);

      // MOCK: Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // MOCK: Static success response for inserting a new host item
      final Map<String, dynamic> mockResponse = {
        "status": 200,
        "message": "Vehicle saved successfully",
        "error": "",
        "data": {
          "id": 1001,
          "title": textEditingControllerTitle.text,
          "description": textEditingControllerDesc.text,
          "item_type_id": selectedVehicleType.toString().isEmpty
              ? ""
              : selectedVehicleType.toString()
        }
      };

      closeLoading();

      fetchItemId = FetchItemId.fromJson(mockResponse);
      if (fetchItemId!.insertItemHost != null) {
        itemHostId = fetchItemId!.insertItemHost!.id!;
      }
      GetStorage().remove("dashboardItemdata");
      GetStorage().remove("dashboard");
      Get.to(() => const UploadImageScreen(mode: ScreenMode.add));
    } catch (e) {
      closeLoading();
    }
  }

  bool selectLocation = false;
  Future updateMethod() async {
    debugPrint("🚀 [UPDATE_METHOD] Bouton Envoyer cliqué pour modification");
    showLoading();
    Map<String, dynamic> itemEditMap = {};
    try {
      // Récupérer le nom de la catégorie à partir du type de véhicule
      String categoryName = "SUV"; // Valeur par défaut
      if (selectedVehicleType != null && vehicleListItemType.isNotEmpty) {
        final vehicleType = vehicleListItemType.firstWhere(
          (type) => type.id == selectedVehicleType,
          orElse: () => vehicleListItemType.first,
        );
        categoryName = vehicleType.name ?? "SUV";
      }

      // Récupérer les images actuelles du véhicule
      // IMPORTANT: Exclure les images supprimées par l'utilisateur (dans listDeleteImages)
      List<String> currentImagesList = [];
      
      if (item != null) {
        // 1. Gérer l'image principale
        // Si frontImage (XFile) est null, on garde l'image existante (si elle n'est pas supprimée)
        // Si frontImage (XFile) n'est pas null, c'est une nouvelle image qui remplace l'ancienne
        if (frontImage == null) {
          // Aucune nouvelle image sélectionnée, garder l'image existante si elle n'est pas supprimée
          if (item!.frontImage != null && 
              item!.frontImage!.url != null && 
              !listDeleteImages.contains(item!.frontImage!.url)) {
            currentImagesList.add(item!.frontImage!.url!);
            debugPrint('📝 [UPDATE_METHOD] Image principale conservée: ${item!.frontImage!.url}');
          } else if (item!.frontImage != null && item!.frontImage!.url != null) {
            debugPrint('📝 [UPDATE_METHOD] Image principale supprimée: ${item!.frontImage!.url}');
          }
        } else {
          // Une nouvelle image a été sélectionnée, l'ancienne sera remplacée
          // L'ancienne image est déjà dans listDeleteImages
          debugPrint('📝 [UPDATE_METHOD] Nouvelle image principale sélectionnée, ancienne sera remplacée');
        }
        
        // 2. Ajouter les images de la galerie existantes (si elles n'ont pas été supprimées)
        // Note: item!.gallery a déjà été modifié par le widget (removeAt), donc on utilise existingGalleryImageUrls
        for (var galleryUrl in existingGalleryImageUrls) {
          if (!listDeleteImages.contains(galleryUrl)) {
            currentImagesList.add(galleryUrl);
          } else {
            debugPrint('📝 [UPDATE_METHOD] Image de galerie supprimée: $galleryUrl');
          }
        }
        
        // Alternative: utiliser item!.gallery si elle est encore à jour
        if (item!.gallery != null && item!.gallery!.isNotEmpty) {
          // Les images déjà supprimées ont été retirées de item!.gallery par le widget
          for (var galleryItem in item!.gallery!) {
            if (galleryItem.url != null && !listDeleteImages.contains(galleryItem.url)) {
              // Éviter les doublons
              if (!currentImagesList.contains(galleryItem.url)) {
                currentImagesList.add(galleryItem.url!);
              }
            }
          }
        }
      }
      
      // 3. Les nouvelles images (XFile) seront traitées séparément lors de l'upload
      // Pour l'instant, on envoie seulement les URLs des images existantes qui n'ont pas été supprimées
      
      debugPrint('📝 [UPDATE_METHOD] ${currentImagesList.length} images existantes conservées (après suppression)');

      // Construire le payload selon la structure MongoDB
      itemEditMap = {
        "type": selectedVehicleType ?? "",
        "category": categoryName,
        "specs": {
          "brand": selectedMake ?? "",
          "model": selectedModel ?? "",
          "transmission": selectTransmission ?? "",
          "year": selectedVechicleYear,
          "odometer": selectedOdometerId.value,
        },
        "pricing": {
          "basePrice": double.tryParse(textEditingControllerEditPrice.text) ?? 0.0,
          "deposit": {
            "value": double.tryParse(textEditingControllerEditSecurityMoney.text.isEmpty 
                ? (textEditingControllerSecurityDeposit.text.isEmpty ? "0" : textEditingControllerSecurityDeposit.text)
                : textEditingControllerEditSecurityMoney.text) ?? 0.0,
            "managedBy": "AGENCY" // La gestion de la caution est toujours gérée par l'agence
          }
        },
        "location": {
          "type": "Point",
          "coordinates": [
            double.tryParse(selectedLong.value) ?? 0.0,
            double.tryParse(selectedLat.value) ?? 0.0
          ],
          "city": textEditingControllerEditCity.text
        },
        "features": selectedAmenitiesList.map((id) => id.toString()).toList(),
        "images": currentImagesList, // URLs des images existantes (celles qui n'ont pas été supprimées)
        // Note: Les nouvelles images (XFile) seront uploadées séparément via updateUploadImage()
        // Les images supprimées sont dans listDeleteImages et seront envoyées via gallery_image_delete
        // Champs additionnels pour compatibilité
        "title": textEditingControllerEditTitle.text,
        "description": textEditingControllerEditDesc.text,
        "address": textEditingControllerEditAddress.text,
        "zip_postal_code": textEditingControllerEditZip.text,
        "country": textEditingControllerEditCountry.text,
        "state_region": textEditingControllerEditState.text,
        "weekly_discount": textEditingControllerEditWeekDiscount.text,
        "weekly_discount_type": selectedWeeklyDiscountType,
        "monthly_discount": textEditingControllerEditMonthDiscount.text,
        "monthly_discount_type": selectedMonthlyDiscountType,
        "booking_policies_id": selectedRadio.toString(),
      };

      // Vérifier que l'ID est disponible avant l'envoi
      if (currentVehicleId == null || currentVehicleId!.isEmpty || currentVehicleId == 'null') {
        closeLoading();
        debugPrint('❌ [UPDATE_METHOD] Impossible de modifier : ID manquant');
        showErrorToastMessage('Impossible de modifier : ID manquant');
        return;
      }

      // Inclure l'ID dans le body pour compatibilité avec certaines APIs
      itemEditMap['id'] = currentVehicleId;
      
      debugPrint('📤 [UPDATE_METHOD] Envoi de la mise à jour avec ID: $currentVehicleId');
      debugPrint('📤 [UPDATE_METHOD] URL: ${Config.editItem}/$currentVehicleId');

      // ✅ APPEL API RÉEL avec PUT - Utiliser currentVehicleId dans l'URL
      var response = await httpPut('${Config.editItem}/$currentVehicleId', itemEditMap);

      closeLoading();

      // Parser la réponse
      Map<String, dynamic> responseData;
      if (response is Map<String, dynamic>) {
        responseData = response;
      } else if (response is String) {
        responseData = jsonDecode(response);
      } else {
        responseData = {"status": 200, "message": "Vehicle updated successfully"};
      }

      // Vérifier le statut de la réponse
      if (responseData['status'] == 200 || responseData['status'] == 201) {
        // Vérifier si re-validation est requise
        if (responseData['requiresRevalidation'] == true) {
          // Afficher un Snackbar spécifique pour la re-validation
          Get.snackbar(
            'Modifications enregistrées',
            'Votre véhicule est en cours de re-validation par l\'admin.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
            margin: const EdgeInsets.all(16),
            borderRadius: 8,
          );
        } else {
          // Message de succès normal
          showToastMessage(responseData['message'] ?? 'Véhicule mis à jour avec succès');
        }

        removeDashBoardData();
        removeMyPostData();
        checkUpdateStep1 = true;
        GetStorage().remove("dashboardItemdata");
        GetStorage().remove("dashboard");
        update();
        selectLocation = false;
        
        // Naviguer vers le Dashboard
        Get.offAll(() => const BottomHost(initialIndex: 0));
        item = null;
      } else {
        // Gestion des erreurs
        String errorMessage = responseData['error'] ?? 
                             responseData['message'] ?? 
                             'Erreur lors de la mise à jour du véhicule';
        showErrorToastMessage(errorMessage);
      }
    } catch (e) {
      closeLoading();
      debugPrint('❌ [UPDATE_METHOD] Erreur: $e');
      showErrorToastMessage('Erreur: ${e.toString()}');
    }
  }

  updateUploadImage(ScreenMode mode) async {
    debugPrint("🚀 [UPLOAD_IMAGE] Upload des images - Mode: ${mode == ScreenMode.add ? 'ADD' : 'EDIT'}");
    showLoading();
    
    // Validation : Les documents du véhicule (Carte Grise) sont obligatoires
    if (frontImageBase64fordoec == null || frontImageBase64fordoec!.isEmpty) {
      debugPrint("❌ [UPLOAD_IMAGE] Échec : Documents manquants (frontImageBase64fordoec est null ou vide)");
      closeLoading();
      Get.snackbar(
        "Erreur",
        "Les documents du véhicule sont obligatoires. Merci.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }
    
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

    // ========== MOCK DATA - OLD API CALL COMMENTED ==========
    // var response = await httpPost(Config.addEditItemImage, map);

    // MOCK: Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // MOCK: Static success response for uploading item images
    final Map<String, dynamic> mockResponse = {
      "status": 200,
      "message": "Images saved successfully",
      "error": "",
      "data": {
        "id": (item?.id ?? itemHostId).toString(),
        "front_image_uploaded": (frontImageBase64 ?? "").isNotEmpty,
        "documents_image_uploaded": (frontImageBase64fordoec ?? "").isNotEmpty,
        "gallery_image_count": galleryImageBase64List.length
      }
    };

    closeLoading();

    removeDashBoardData();
    removeMyPostData();
    showToastMessage(mockResponse['message'] as String);
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
    String description = descriptionController?.text ?? "";
    String licensePlate1 = mode == ScreenMode.edit
        ? part1ControllerEdit.text
        : part1Controller.text;
    String licensePlate2 = mode == ScreenMode.edit
        ? part2ControllerEdit.text
        : part2Controller.text;
    String licensePlate3 = mode == ScreenMode.edit
        ? part3ControllerEdit.text
        : part3Controller.text;
    String minRentalDays = mode == ScreenMode.edit
        ? textEditingControllerEditMinDays.text
        : textEditingControllerMinDays.text;
    if (licensePlate1.isEmpty || licensePlate2.isEmpty || licensePlate3.isEmpty) {
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

  // ========== FONCTION DE DEMANDE DE SUPPRESSION DE VÉHICULE ==========
  /// Affiche une boîte de dialogue de confirmation et envoie une demande de suppression
  /// à l'administrateur pour validation finale
  Future<void> requestDeleteVehicle(String vehicleId) async {
    // 1. Popup de Confirmation : Utilise Get.dialog pour afficher une alerte
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Demande de suppression'.tr),
        content: Text('Êtes-vous sûr ? Cette demande sera envoyée à l\'administrateur pour validation finale.'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Annuler'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Confirmer'.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    // Si l'utilisateur n'a pas confirmé, arrêter ici
    if (confirmed != true) {
      return;
    }

    try {
      showLoading();
      
      // 2. Appel API : Si l'utilisateur confirme, appelle httpDelete vers /api/vehicles/$vehicleId
      final endpoint = '${Config.getVehicleDetails}/$vehicleId';
      var response = await httpDelete(endpoint);
      
      closeLoading();
      
      if (response != null) {
        // 3. Feedback : Affiche un Get.snackbar avec le message de succès renvoyé par le serveur
        if (response['status'] == 200 || response['success'] == true) {
          final successMessage = response['message'] ?? 'Votre demande de suppression a été envoyée à l\'administrateur.'.tr;
          
          Get.snackbar(
            'Succès'.tr,
            successMessage,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          
          // 4. Mise à jour UI : Rafraîchis la liste pour que le véhicule disparaisse de la vue du vendor
          // (ou affiche un badge 'En attente de suppression')
          try {
            final vehicleController = Get.find<VehicleController>();
            await vehicleController.fetchMyVehicles();
            update();
          } catch (e) {
            debugPrint('⚠️ [DELETE] Erreur lors du rafraîchissement de la liste: $e');
          }
        } else {
          // Afficher un message d'erreur
          Get.snackbar(
            'Erreur'.tr,
            response['error'] ?? response['message'] ?? 'Erreur lors de la demande de suppression'.tr,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      }
    } catch (e, stackTrace) {
      closeLoading();
      debugPrint('❌ [DELETE] Erreur lors de la demande de suppression: $e');
      debugPrint('❌ [DELETE] StackTrace: $stackTrace');
      
      Get.snackbar(
        'Erreur'.tr,
        'Erreur lors de la demande de suppression: $e'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ========== FONCTION DE SUPPRESSION SÉCURISÉE ==========
  /// Fonction de suppression sécurisée avec confirmation UI et gestion d'erreurs
  Future<void> deleteVehicleRequest(String vehicleId) async {
    // 1. Confirmation UI : Affiche une boîte de dialogue Get.defaultDialog
    // Crée une variable bool confirmed = false;
    bool confirmed = false;
    
    // Affiche le dialogue et attends qu'il se ferme
    await Get.defaultDialog(
      title: 'Confirmation de suppression'.tr,
      middleText: 'Voulez-vous vraiment demander la suppression de ce véhicule ? Cette action devra être validée par un administrateur.'.tr,
      textConfirm: 'Confirmer la demande'.tr,
      textCancel: 'Annuler'.tr,
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.grey,
      buttonColor: Colors.red,
      onConfirm: () {
        confirmed = true;
        Get.back();
      },
      onCancel: () {
        confirmed = false;
        Get.back();
      },
      barrierDismissible: false,
    );

    // Si l'utilisateur n'a pas confirmé, arrêter ici
    if (!confirmed) {
      return;
    }

    // Attendre que le dialogue soit complètement fermé avant d'exécuter l'appel API
    await Future.delayed(const Duration(milliseconds: 300));

    // 2. Logique de l'appel : Affiche un loader
    // Extraction de la logique : Le bloc try-catch est maintenant en dehors de onConfirm
    try {
      isLoadingEdit.value = true;
      update();
      
      // Correction de l'Endpoint : Utiliser /api/vehicles/$vehicleId (sans /v1/)
      // Config.baseUrlWithoutV1 = 'http://10.0.2.2:5000/api/'
      // Config.submitVehicle = 'vehicles'
      // Endpoint final : 'vehicles/$vehicleId'
      final endpoint = '${Config.submitVehicle}/$vehicleId';
      
      // Log de vérification : Afficher l'URL finale qui sera générée
      final fullUrl = '${Config.baseUrlWithoutV1}${Config.submitVehicle}/$vehicleId';
      debugPrint('🌐 [DELETE] URL FINALE APPELÉE : $fullUrl');
      
      // Logs de Sécurité : Ajoute print avant l'appel httpDelete
      debugPrint('🚀 [DELETE] ENVOI DE LA REQUÊTE À NODE JS...');
      debugPrint('🚀 [DELETE] Endpoint: $endpoint');
      debugPrint('🚀 [DELETE] Vehicle ID: $vehicleId');
      debugPrint('🚀 [DELETE] Base URL (sans v1): ${Config.baseUrlWithoutV1}');
      
      var response = await httpDelete(endpoint);
      
      // Print de la Réponse : Ajoute ces logs juste après l'appel httpDelete
      debugPrint('📩 [RESPONSE_RAW] : $response');
      debugPrint('🔢 [STATUS_CODE] : ${response != null ? "Données reçues" : "NULL"}');
      
      isLoadingEdit.value = false;
      update();
      
      // 3. Gestion de la réponse
      if (response != null) {
        // Vérification du Success : Ajoute debugPrint
        debugPrint('✅ [CHECK] Success est : ${response["success"]}');
        
        if (response['success'] == true) {
          // Désactive les Snackbars : Commente temporairement tous les Get.snackbar
          // Future.delayed(const Duration(milliseconds: 500), () {
          //   Get.snackbar(
          //     'Succès'.tr,
          //     'Demande envoyée ! Le véhicule sera supprimé après validation de l\'admin.'.tr,
          //     snackPosition: SnackPosition.TOP,
          //     backgroundColor: Colors.green,
          //     colorText: Colors.white,
          //     duration: const Duration(seconds: 3),
          //   );
          // });
          
          debugPrint('✅ [SUCCESS] La demande de suppression a été envoyée avec succès');
          
          // Rafraîchis la liste des véhicules en rappelant l'API du dashboard
          try {
            final vehicleController = Get.find<VehicleController>();
            await vehicleController.fetchMyVehicles();
            update();
          } catch (e) {
            debugPrint('⚠️ [DELETE] Erreur lors du rafraîchissement de la liste: $e');
          }
        } else {
          // Désactive les Snackbars : Commente temporairement tous les Get.snackbar
          final errorMessage = response['error'] ?? 
                               response['message'] ?? 
                               'Erreur lors de la demande de suppression'.tr;
          
          debugPrint('❌ [ERROR] Message d\'erreur: $errorMessage');
          
          // Future.delayed(const Duration(milliseconds: 500), () {
          //   Get.snackbar(
          //     'Erreur'.tr,
          //     errorMessage,
          //     snackPosition: SnackPosition.TOP,
          //     backgroundColor: Colors.red,
          //     colorText: Colors.white,
          //     duration: const Duration(seconds: 3),
          //   );
          // });
        }
      } else {
        debugPrint('❌ [ERROR] La réponse est NULL');
      }
    } catch (e, stackTrace) {
      // 4. Sécurité : Ajoute un try-catch pour capturer les erreurs de connexion
      isLoadingEdit.value = false;
      update();
      
      debugPrint('❌ [DELETE] Erreur lors de la demande de suppression: $e');
      debugPrint('❌ [DELETE] StackTrace: $stackTrace');
      
      // Affiche un message d'erreur si le serveur refuse (par exemple si une réservation est en cours)
      String errorMessage = 'Erreur lors de la demande de suppression'.tr;
      
      if (e.toString().contains('connection') || e.toString().contains('timeout')) {
        errorMessage = 'Erreur de connexion. Veuillez vérifier votre connexion internet.'.tr;
      } else if (e.toString().contains('booking') || e.toString().contains('reservation')) {
        errorMessage = 'Impossible de supprimer ce véhicule car une réservation est en cours.'.tr;
      } else {
        errorMessage = 'Erreur lors de la demande de suppression: ${e.toString()}'.tr;
      }
      
      // Désactive les Snackbars : Commente temporairement tous les Get.snackbar
      debugPrint('❌ [EXCEPTION] Erreur capturée: $errorMessage');
      
      // Future.delayed(const Duration(milliseconds: 500), () {
      //   Get.snackbar(
      //     'Erreur'.tr,
      //     errorMessage,
      //     snackPosition: SnackPosition.TOP,
      //     backgroundColor: Colors.red,
      //     colorText: Colors.white,
      //     duration: const Duration(seconds: 4),
      //   );
      // });
    }
    
    // Log de fin : Ajoute debugPrint
    debugPrint('🏁 [FIN_PROCEDURE] Fin de la fonction sans crash.');
  }

  /// Bascule l'état actif/inactif d'un véhicule (Publish / Unpublish).
  /// Endpoint côté backend : PATCH /api/v1/vehicles/:id/toggle-active (sans body)
  Future<void> toggleVehicleActiveStatus(int index, String vehicleId) async {
    // 1) Confirmation : recommandée (surtout pour "désactiver")
    bool confirmed = false;

    final vehicleController = Get.find<VehicleController>();

    // Déterminer l'état actuel si possible pour afficher le bon message
    String? currentStatus;
    try {
      final matching = vehicleController.myVehiclesItems.firstWhereOrNull(
        (v) => v.id?.toString() == vehicleId,
      );
      currentStatus = matching?.status;
    } catch (_) {}

    final bool isCurrentlyActive = currentStatus != null && currentStatus.toString() != '0';
    final String actionVerb = isCurrentlyActive ? 'désactiver' : 'activer';
    final Color actionColor = isCurrentlyActive ? Colors.orange : Colors.green;

    await Get.defaultDialog(
      title: 'Confirmation'.tr,
      middleText: 'Êtes-vous sûr de vouloir ${actionVerb} ce véhicule ? Il ne sera plus visible par les clients.'.tr,
      textConfirm: isCurrentlyActive ? 'Désactiver'.tr : 'Activer'.tr,
      textCancel: 'Annuler'.tr,
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.grey,
      buttonColor: actionColor,
      barrierDismissible: false,
      onConfirm: () {
        confirmed = true;
        Get.back();
      },
      onCancel: () {
        confirmed = false;
        Get.back();
      },
    );

    if (!confirmed) return;
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      isLoadingEdit.value = true;
      update();

      final String togglePath = 'vehicles/$vehicleId/toggle-active';
      final response = await httpPatch(togglePath);

      isLoadingEdit.value = false;
      update();

      final bool ok = response != null &&
          (response is Map<String, dynamic>) &&
          (response['success'] == true ||
              response['status'] == 200 ||
              response['status'] == 201 ||
              response['statusCode'] == 200 ||
              response['statusCode'] == 201);

      if (ok) {
        // Recharger la liste pour garantir l'état à jour
        try {
          await vehicleController.fetchMyVehicles();
          update();
        } catch (e) {
          debugPrint('⚠️ [TOGGLE_ACTIVE] Erreur refresh: $e');
        }
        showToastMessage('Statut du véhicule mis à jour'.tr);
      } else {
        final String message =
            response?['error'] ?? response?['message'] ?? 'Erreur lors de la mise à jour du statut'.tr;
        showErrorToastMessage(message);
      }
    } catch (e) {
      isLoadingEdit.value = false;
      update();
      showErrorToastMessage('Erreur lors de la mise à jour du statut: ${e.toString()}');
    }
  }
}
