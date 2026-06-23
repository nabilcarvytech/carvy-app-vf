import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:carvy/api/config.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/amenities_model.dart';
import 'package:carvy/model/fuel_type_model.dart';
import 'package:carvy/model/item_type_model.dart';
import 'package:carvy/model/make_model_vehicle.dart';
import 'package:carvy/model/make_type_model.dart';
import 'package:carvy/model/odometer_model.dart';
import 'package:carvy/model/transmission_model.dart';
import 'package:carvy/utils/snackbar_service.dart';
import 'package:carvy/work_space.dart';

/// Contrôleur autonome pour l'édition de véhicule
/// Clone propre de l'écran d'ajout, sans dépendances complexes
class StandaloneEditController extends GetxController {
  // ========== ÉTAT DE CHARGEMENT ==========
  RxBool isLoading = false.obs;

  // ========== TEXT EDITING CONTROLLERS ==========
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController seatCapacityController = TextEditingController();
  final TextEditingController weeklyDiscountController = TextEditingController();
  final TextEditingController monthlyDiscountController = TextEditingController();

  // ========== VARIABLES DE SÉLECTION ==========
  String? selectedVehicleType;
  String? selectedMake;
  String? selectedModel;
  String? selectedYear; // Changé en String pour éviter les doublons dans le Dropdown
  String? selectedTransmission;
  String? selectedOdometer;
  String? selectedFuelType;
  List<String> selectedAmenities = [];

  // ========== LISTES DE RÉFÉRENCE ==========
  List<ItemTypes> typesList = [];
  List<MakeTypes> makesList = [];
  List<Models> modelsList = [];
  List<Options> transmissionList = [];
  List<Getodometer> odometerList = [];
  List<FuelType> fuelTypeList = [];
  List<Map<String, dynamic>> amenitiesList = []; // Changé en Map pour éviter les erreurs de parsing
  final List<String> yearsList = List.generate(30, (index) => (DateTime.now().year - index).toString());

  // ========== MODÈLES ==========
  ItemTypeModel? itemTypeModel;
  GetMakeModel? getMakeModel;
  Transmission? transmissionModel;
  Odometer? odometerModel;
  FuelTypeModel? fuelTypeModel;
  AmenitiesModel? amenitiesModel;

  // ========== ID DU VÉHICULE EN ÉDITION ==========
  String? vehicleId;

  @override
  void onClose() {
    titleController.dispose();
    priceController.dispose();
    addressController.dispose();
    stateController.dispose();
    cityController.dispose();
    seatCapacityController.dispose();
    weeklyDiscountController.dispose();
    monthlyDiscountController.dispose();
    super.onClose();
  }

  // ========== API DE RÉFÉRENCE (COPIÉES DE L'AJOUT) ==========

  /// Charge les types de véhicules
  Future<void> getDataItemType() async {
    try {
      debugPrint('📡 [STANDALONE] Appel API GET get-all-categories');
      final response = await httpGet(Config.itemsType, {});

      if (response != null &&
          response is Map<String, dynamic> &&
          response['status'] == 200 &&
          response['data'] != null) {
        itemTypeModel = ItemTypeModel.fromJson(response);
        typesList = itemTypeModel!.data!.itemTypes ?? [];
        debugPrint('✅ [STANDALONE] Types chargés: ${typesList.length}');
      }
    } catch (e) {
      debugPrint('❌ [STANDALONE] Erreur getDataItemType: $e');
    }
    update();
  }

  /// Charge les marques et modèles
  Future<void> getVehicleDataMakeModel() async {
    try {
      debugPrint('📡 [STANDALONE] Appel API GET vehicle-reference/makes');
      final response = await httpGet(Config.makeType, {});
      
      if (response != null && response['data'] != null) {
        // On cherche les marques, qu'elles soient dans 'makes' ou dans 'makesTypes'
        var rawMakes = response['data']['makes'] ?? response['data']['makesTypes'] ?? [];
        
        if (rawMakes is Iterable) {
          makesList.clear();
          modelsList.clear();
          
          for (var m in rawMakes) {
            try {
              // 1. Créer une copie modifiable du JSON de la marque
              Map<String, dynamic> safeJson = Map<String, dynamic>.from(m);
              
              // 2. SÉCURITÉ : Si 'models' est null, on injecte un tableau vide pour éviter le crash de fromJson
              if (safeJson['models'] == null) {
                safeJson['models'] = [];
              }
              
              // 3. Parsing sécurisé
              MakeTypes make = MakeTypes.fromJson(safeJson);
              // Le fromJson gère déjà l'ID MongoDB (_id ou id), pas besoin de fallback manuel
              
              makesList.add(make);
              
              // 4. On extrait les modèles associés
              if (make.models != null && make.models!.isNotEmpty) {
                modelsList.addAll(make.models!);
              }
            } catch (e) {
              debugPrint('⚠️ [STANDALONE] Erreur sur une marque spécifique: $e');
            }
          }
          debugPrint('✅ [STANDALONE] Marques parsées: ${makesList.length}, Modèles: ${modelsList.length}');
        } else {
          makesList = [];
          modelsList = [];
          debugPrint('⚠️ [STANDALONE] rawMakes n\'est pas un Iterable');
        }
      } else {
        makesList = [];
        modelsList = [];
        debugPrint('⚠️ [STANDALONE] Réponse invalide ou data manquant');
      }
    } catch (e) {
      debugPrint('❌ [STANDALONE] Erreur getVehicleDataMakeModel: $e');
      makesList = [];
      modelsList = [];
    }
    update();
  }

  /// Charge les équipements
  Future<void> getDataAmenties() async {
    try {
      debugPrint('📡 [STANDALONE] Appel API GET amenities');
      final response = await httpGet(Config.amenities, {});

      if (response != null && response is Map<String, dynamic>) {
        try {
          // Parsing simplifié et sécurisé
          if (response['data'] is Map && response['data']['amenities'] != null) {
            final amenitiesRaw = response['data']['amenities'] as List;
            // Parser manuellement en Map<String, dynamic> pour éviter les erreurs de type strict
            amenitiesList = amenitiesRaw.map((e) {
              if (e is Map<String, dynamic>) {
                return e;
              } else {
                return {'id': e.toString(), 'name': e.toString()};
              }
            }).toList();
            GetStorage().write("amenitiesVechicle", response);
            debugPrint('✅ [STANDALONE] Équipements chargés: ${amenitiesList.length}');
          } else {
            amenitiesList = [];
            debugPrint('⚠️ [STANDALONE] Structure data.amenities non trouvée');
          }
        } catch (e) {
          debugPrint('❌ [STANDALONE] Erreur parsing amenities: $e');
          amenitiesList = [];
        }
      } else {
        amenitiesList = [];
        debugPrint('⚠️ [STANDALONE] Réponse invalide pour amenities');
      }
    } catch (e) {
      debugPrint('❌ [STANDALONE] Erreur getDataAmenties: $e');
      amenitiesList = [];
    }
    update();
  }

  /// Charge les transmissions
  Future<void> getDataTransmission() async {
    try {
      final storage = GetStorage();
      final cached = storage.read("transmission");

      if (cached == null) {
        debugPrint('📡 [STANDALONE] Appel API GET transmission');
        var response = await httpGet(Config.odometermannual, {});

        if (response != null) {
          transmissionModel = Transmission.fromJson(response);
          transmissionList = transmissionModel!.data!.options ?? [];
          storage.write("transmission", response);
        }
      } else {
        transmissionModel = Transmission.fromJson(cached);
        transmissionList = transmissionModel!.data!.options ?? [];
      }
      debugPrint('✅ [STANDALONE] Transmissions chargées: ${transmissionList.length}');
    } catch (e) {
      debugPrint('❌ [STANDALONE] Erreur getDataTransmission: $e');
    }
    update();
  }

  /// Charge les odomètres
  Future<void> getDataOdometerList() async {
    try {
      final storage = GetStorage();
      final cached = storage.read("odometer");

      if (cached == null) {
        debugPrint('📡 [STANDALONE] Appel API GET odometer');
        var response = await httpGet(Config.vechileOdometer, {});

        if (response != null) {
          odometerModel = Odometer.fromJson(response);
          odometerList = odometerModel!.data!.odometerList ?? [];
          storage.write("odometer", response);
        }
      } else {
        odometerModel = Odometer.fromJson(cached);
        odometerList = odometerModel!.data!.odometerList ?? [];
      }
      debugPrint('✅ [STANDALONE] Odomètres chargés: ${odometerList.length}');
    } catch (e) {
      debugPrint('❌ [STANDALONE] Erreur getDataOdometerList: $e');
    }
    update();
  }

  /// Charge les types de carburant
  Future<void> getDatafuelType() async {
    try {
      final storage = GetStorage();
      final cachedData = storage.read("getFueltype");

      if (cachedData == null) {
        debugPrint('📡 [STANDALONE] Appel API GET fuel types');
        var response = await httpGet(Config.fuelType, {});

        if (response != null) {
          fuelTypeModel = FuelTypeModel.fromJson(response);
          fuelTypeList = fuelTypeModel!.fuelTypes;
          storage.write("getFueltype", response);
        }
      } else {
        fuelTypeModel = FuelTypeModel.fromJson(cachedData);
        fuelTypeList = fuelTypeModel!.fuelTypes;
      }
      debugPrint('✅ [STANDALONE] Types de carburant chargés: ${fuelTypeList.length}');
    } catch (e) {
      debugPrint('❌ [STANDALONE] Erreur getDatafuelType: $e');
    }
    update();
  }

  /// Filtre les modèles selon la marque sélectionnée (depuis les objets MakeTypes)
  void filterModelsByMake(String? makeId) {
    if (makeId == null) {
      modelsList.clear();
      update();
      return;
    }

    final selectedMakeObj = makesList.firstWhereOrNull(
      (make) => make.id?.toString() == makeId.toString(),
    );

    if (selectedMakeObj != null && selectedMakeObj.models != null) {
      modelsList = selectedMakeObj.models!;
      debugPrint('✅ [STANDALONE] ${modelsList.length} modèles filtrés pour la marque');
    } else {
      modelsList = [];
      debugPrint('⚠️ [STANDALONE] Aucun modèle trouvé pour la marque $makeId');
    }
    update();
  }

  /// Récupère les modèles depuis l'API dédiée (même API que l'écran d'Ajout)
  /// IMPORTANT : L'URL utilisée est /api/vehicle-reference/models?make=$makeId (sans /v1/)
  Future<void> getModelApi(String makeId) async {
    try {
      debugPrint('📡 [STANDALONE] Appel API GET vehicle-reference/models pour makeId: $makeId');
      
      // IMPORTANT : Vider la liste au début pour éviter d'afficher les modèles d'une ancienne marque
      modelsList.clear();
      
      // Construire l'URL complète avec adminBaseUrl (sans /v1/)
      // IMPORTANT : Le paramètre est 'make' et non 'makeId'
      String url = '${Config.adminBaseUrl}${Config.vehicleReferenceModels}?make=$makeId';
      
      debugPrint('📡 [STANDALONE] URL complète: $url');
      
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
            debugPrint('⚠️ [STANDALONE] Structure de data inattendue: ${dataObj.runtimeType}');
            list = [];
          }
          
          debugPrint('✅ [STANDALONE] Structure détectée - longueur: ${list.length}');
          
          try {
            for (var item in list) {
              if (item is Map<String, dynamic>) {
                try {
                  // Créer un objet Models depuis la réponse avec gestion d'erreur par élément
                  modelsList.add(Models.fromJson(item));
                } catch (e) {
                  debugPrint('❌ [STANDALONE] Erreur sur l\'élément: $item');
                  debugPrint('❌ [STANDALONE] Erreur: $e');
                  // Continuer avec les autres éléments sans bloquer toute la liste
                }
              }
            }
            debugPrint('✅ [STANDALONE] modelsList mis à jour - longueur: ${modelsList.length}');
          } catch (e) {
            debugPrint('❌ [STANDALONE] Erreur lors du parsing Models (niveau liste): $e');
          }
        } else {
          debugPrint('⚠️ [STANDALONE] response["success"] != true ou response["data"] est NULL');
          debugPrint('📋 [STANDALONE] Structure complète: $response');
        }
        } else {
          debugPrint('⚠️ [STANDALONE] Réponse invalide ou null');
        }
      } else {
        debugPrint('❌ [STANDALONE] Erreur HTTP: ${httpResponse.statusCode}');
        debugPrint('❌ [STANDALONE] Body: ${httpResponse.body}');
      }
    } catch (e) {
      debugPrint('❌ [STANDALONE] Erreur getModelApi: $e');
      modelsList = [];
    }
    update();
  }

  // ========== INITIALISATION DE L'ÉDITION ==========

  /// Initialise l'édition d'un véhicule
  Future<void> initEdit(String id) async {
    isLoading.value = true;
    vehicleId = id;
    update();

    try {
      // 1. Charger toutes les API de référence
      debugPrint('🔄 [STANDALONE] Chargement des API de référence...');
      await Future.wait([
        getDataItemType(),
        getDataAmenties(),
        getDataTransmission(),
        getDataOdometerList(),
        getDatafuelType(),
        getVehicleDataMakeModel(),
      ]);

      // 2. Récupérer les données du véhicule
      debugPrint('🔄 [STANDALONE] Récupération des données du véhicule ID: $id');
      final response = await httpGet('${Config.getVehicleDetails}/$id', {});

      if (response != null &&
          response is Map<String, dynamic> &&
          response['data'] != null &&
          response['data']['items'] != null) {
        final items = response['data']['items'] as List;
        if (items.isNotEmpty) {
          final vehicle = items.first as Map<String, dynamic>;

          // 3. Pré-remplir les TextEditingControllers
          titleController.text = vehicle['title']?.toString() ?? '';
          priceController.text = vehicle['price']?.toString() ?? vehicle['pricing']?['basePrice']?.toString() ?? '';
          addressController.text = vehicle['address']?.toString() ?? '';
          stateController.text = vehicle['stateRegion']?.toString() ?? vehicle['state_region']?.toString() ?? '';
          cityController.text = vehicle['city']?.toString() ?? vehicle['location']?['city']?.toString() ?? '';
          seatCapacityController.text = vehicle['seatCapacity']?.toString() ?? '';
          weeklyDiscountController.text = vehicle['weeklyDiscount']?.toString() ?? vehicle['weekly_discount']?.toString() ?? '';
          monthlyDiscountController.text = vehicle['monthlyDiscount']?.toString() ?? vehicle['monthly_discount']?.toString() ?? '';

          // 4. Pré-remplir les variables de sélection depuis itemInfo
          if (vehicle['itemInfo'] != null) {
            try {
              final itemInfo = json.decode(vehicle['itemInfo'].toString()) as Map<String, dynamic>;
              
              selectedVehicleType = vehicle['type']?.toString() ?? itemInfo['type']?.toString();
              
              // 1. On extrait la marque existante
              selectedMake = itemInfo['makeType']?.toString() ?? itemInfo['makeId']?.toString();
              
              // 2. 🚨 APPEL DE L'API DES MODÈLES ICI 🚨
              if (selectedMake != null && selectedMake!.isNotEmpty) {
                debugPrint('🚀 [STANDALONE] Appel de l\'API des modèles pour la marque : $selectedMake');
                await getModelApi(selectedMake!);
              }

              // 3. SEULEMENT ENSUITE, on extrait le modèle existant
              selectedModel = itemInfo['modelType']?.toString() ?? itemInfo['modelId']?.toString();
              
              // Convertir l'année en String et nettoyer pour éviter les doublons dans le Dropdown
              final yearStr = (itemInfo['year']?.toString() ?? vehicle['year']?.toString() ?? '').trim();
              selectedYear = yearStr.isNotEmpty ? yearStr : null;
              // Vérifier que l'année est dans la liste, sinon la mettre à null
              if (selectedYear != null && !yearsList.contains(selectedYear)) {
                debugPrint('⚠️ [STANDALONE] Année $selectedYear non trouvée dans yearsList, mise à null');
                selectedYear = null;
              }
              selectedTransmission = itemInfo['transmission']?.toString();
              selectedOdometer = itemInfo['odometer']?.toString();
              selectedFuelType = itemInfo['fuelType']?.toString();

              // Charger les équipements sélectionnés
              if (itemInfo['amenities'] != null) {
                if (itemInfo['amenities'] is List) {
                  selectedAmenities = (itemInfo['amenities'] as List)
                      .map((e) => e.toString())
                      .toList();
                }
              }
            } catch (e) {
              debugPrint('⚠️ [STANDALONE] Erreur parsing itemInfo: $e');
            }
          }

          // Fallback: utiliser les champs directs si itemInfo n'est pas disponible
          if (selectedVehicleType == null) {
            selectedVehicleType = vehicle['type']?.toString();
          }
          if (selectedMake == null && vehicle['brand'] != null) {
            selectedMake = vehicle['brand']['_id']?.toString() ?? vehicle['brand']['id']?.toString();
          }

          debugPrint('✅ [STANDALONE] Données du véhicule chargées avec succès');
        }
      }
    } catch (e) {
      debugPrint('❌ [STANDALONE] Erreur initEdit: $e');
      Get.safeSnackbar('Erreur', 'Impossible de charger les données du véhicule');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // ========== MISE À JOUR DU VÉHICULE ==========

  /// Met à jour le véhicule via PUT
  Future<bool> updateVehicle() async {
    if (vehicleId == null) {
      Get.safeSnackbar('Erreur', 'ID du véhicule manquant');
      return false;
    }

    isLoading.value = true;
    update();

    try {
      // Construire le payload selon la structure de updateMethod (même format que l'écran d'ajout)
      // Récupérer le nom de la catégorie à partir du type de véhicule
      String categoryName = "SUV"; // Valeur par défaut
      if (selectedVehicleType != null && typesList.isNotEmpty) {
        final vehicleType = typesList.firstWhereOrNull(
          (type) => type.id.toString() == selectedVehicleType,
        );
        categoryName = vehicleType?.name ?? "SUV";
      }

      final payload = {
        "type": selectedVehicleType ?? "",
        "category": categoryName,
        "specs": {
          "brand": selectedMake ?? "",
          "model": selectedModel ?? "",
          "transmission": selectedTransmission ?? "",
          "year": selectedYear != null ? int.tryParse(selectedYear!) : null,
          "odometer": selectedOdometer ?? "",
          "fuelType": selectedFuelType ?? "",
        },
        "pricing": {
          "basePrice": double.tryParse(priceController.text) ?? 0.0,
        },
        "location": {
          "type": "Point",
          "coordinates": [0.0, 0.0], // TODO: Récupérer depuis le véhicule si disponible
          "city": cityController.text
        },
        "features": selectedAmenities.map((id) => id.toString()).toList(),
        // Champs additionnels pour compatibilité (même format que updateMethod)
        "title": titleController.text,
        "address": addressController.text,
        "state_region": stateController.text,
        "weekly_discount": weeklyDiscountController.text,
        "weekly_discount_type": "percent",
        "monthly_discount": monthlyDiscountController.text,
        "monthly_discount_type": "percent",
        "seatCapacity": seatCapacityController.text,
      };

      debugPrint('📤 [STANDALONE] Envoi PUT vers ${Config.editItem}/$vehicleId');
      final response = await httpPut('${Config.editItem}/$vehicleId', payload);

      if (response != null &&
          response is Map<String, dynamic> &&
          (response['status'] == 200 || response['success'] == true)) {
        Get.safeSnackbar('Succès', 'Véhicule mis à jour avec succès');
        debugPrint('✅ [STANDALONE] Véhicule mis à jour avec succès');
        return true;
      } else {
        Get.safeSnackbar('Erreur', 'Échec de la mise à jour');
        debugPrint('❌ [STANDALONE] Échec de la mise à jour: $response');
        return false;
      }
    } catch (e) {
      Get.safeSnackbar('Erreur', 'Erreur lors de la mise à jour: $e');
      debugPrint('❌ [STANDALONE] Erreur updateVehicle: $e');
      return false;
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
