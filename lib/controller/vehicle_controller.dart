import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/model/make_type_model.dart';
import 'package:carvy/model/make_model_vehicle.dart';
import 'package:carvy/model/fuel_type_model.dart';
import 'package:carvy/model/odometer_model.dart';
import 'package:carvy/model/location_host_model.dart';
import 'package:carvy/model/my_items_model.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:bot_toast/bot_toast.dart';
import '../helper/http_service.dart';
import '../work_space.dart';
import '../view/auth/login_screen.dart';

/// Controller pour gérer l'ajout de véhicules
/// Récupère les données nécessaires et soumet les véhicules au backend Node.js
class VehicleController extends GetxController implements GetxService {
  // ========== ÉTATS DE CHARGEMENT ==========
  RxBool isLoadingMakes = false.obs;
  RxBool isLoadingModels = false.obs;
  RxBool isLoadingFuelTypes = false.obs;
  RxBool isLoadingOdometer = false.obs;
  RxBool isUploadingImages = false.obs;
  RxBool isSubmittingVehicle = false.obs;
  RxBool isLoading = false.obs; // Variable principale pour le loader global
  RxString errorMessage = ''.obs; // Message d'erreur observable
  RxBool isSuccess = false.obs; // Variable pour forcer la disparition du loader après succès

  // ========== DONNÉES RÉCUPÉRÉES ==========
  // Makes (Marques)
  CarMakes? makesModel;
  RxList<Makes> makesList = <Makes>[].obs;

  // Models (Modèles)
  GetMakeModel? makeModelData;
  RxList<MakeTypes> makeTypesList = <MakeTypes>[].obs;
  RxList<Models> modelsList = <Models>[].obs;

  // Fuel Types (Types de carburant)
  FuelTypeModel? fuelTypeModel;
  RxList<FuelType> fuelTypesList = <FuelType>[].obs;

  // Odometer (Odomètre)
  Odometer? odometerModel;
  RxList<Getodometer> odometerList = <Getodometer>[].obs;

  // Vehicle Types (Types de véhicules)
  RxBool isLoadingVehicleTypes = false.obs;
  RxList<dynamic> vehicleTypesList = <dynamic>[].obs; // Utiliser dynamic car ItemTypes peut varier

  // Categories (Catégories)
  RxBool isLoadingCategories = false.obs;
  RxList<dynamic> categoriesList = <dynamic>[].obs;

  // Images uploadées
  RxList<String> uploadedImageUrls = <String>[].obs;

  // Liste des véhicules du vendor (Mes publications)
  RxBool isLoadingMyVehicles = false.obs;
  var myVehicles = <Map<String, dynamic>>[].obs;
  // Liste des Items pour compatibilité avec VehicleItemCard
  List<Items> myVehiclesItems = [];

  // ========== DONNÉES DE L'ÉTAPE 2 (Détails du véhicule) ==========
  // Plaque d'immatriculation
  String plateNumber1 = '';
  String plateNumber2 = '';
  String plateNumber3 = '';
  
  // Location & Assurance
  String minRentalDays = '1';
  String selectedInsurance = ''; // 'Basic' ou 'Full'
  
  // Restrictions
  bool hasAgeRestriction = false;
  String minAge = '18';
  bool allowsInternationalTravel = false;

  // ========== DONNÉES DE L'ÉTAPE 3 (Tarification) ==========
  // Prix et Caution
  double pricePerDay = 0.0;
  double deposit = 0.0;
  
  // Réductions
  bool hasWeeklyDiscount = false;
  double weeklyDiscountValue = 0.0;
  String weeklyDiscountType = 'percent'; // 'percent' ou 'fixed'
  
  bool hasMonthlyDiscount = false;
  double monthlyDiscountValue = 0.0;
  String monthlyDiscountType = 'percent'; // 'percent' ou 'fixed'
  
  // Livraison
  bool hasHomeDelivery = false;
  double deliveryPrice = 0.0;

  // ========== DONNÉES DE L'ÉTAPE 4 (Localisation) ==========
  // Locations (Villes/Régions) - API Node.js
  RxBool isLoadingLocations = false.obs;
  RxList<dynamic> locationsList = <dynamic>[].obs;
  
  // Regions (pour compatibilité)
  RxBool isLoadingRegions = false.obs;
  RxList<dynamic> regionsList = <dynamic>[].obs;
  
  // Région sélectionnée et coordonnées
  RxString selectedRegionId = ''.obs;
  RxString fullAddress = ''.obs;
  RxDouble selectedLatitude = 0.0.obs;
  RxDouble selectedLongitude = 0.0.obs;

  // ========== DONNÉES DE L'ÉTAPE 5 (Équipements) ==========
  RxBool isLoadingFeatures = false.obs;
  RxList<dynamic> featuresList = <dynamic>[].obs;
  RxList<String> selectedFeatures = <String>[].obs; // Liste des IDs des équipements sélectionnés

  // ========== DONNÉES DE L'ÉTAPE 6 (Politiques & Règles) ==========
  RxBool isLoadingPolicies = false.obs;
  RxList<dynamic> policiesList = <dynamic>[].obs;
  RxString selectedPolicyId = ''.obs; // ID de la politique d'annulation sélectionnée (Niveau 1: Non-remboursable ou Flexible)
  
  // Paliers (Niveau 2) - Utilise les politiques de l'API comme paliers
  RxMap<String, bool> tierSwitches = <String, bool>{}.obs; // Map<tierId, isEnabled>
  RxMap<String, String> tierRetentionFees = <String, String>{}.obs; // Map<tierId, retentionFee>

  RxBool isLoadingRules = false.obs;
  RxList<dynamic> rulesList = <dynamic>[].obs;
  RxList<String> selectedRules = <String>[].obs; // Liste des IDs des règles sélectionnées

  // ========== DONNÉES DE L'ÉTAPE 7 (Photos) ==========
  RxList<XFile> selectedImages = <XFile>[].obs; // Liste des images sélectionnées
  final ImagePicker _imagePicker = ImagePicker();

  // ========== DONNÉES DE L'ÉTAPE 8 (Documents) ==========
  Rx<File?> registrationCardRecto = Rx<File?>(null); // Carte grise recto
  Rx<File?> registrationCardVerso = Rx<File?>(null); // Carte grise verso
  Rx<File?> ministryAuthorization = Rx<File?>(null); // Autorisation du ministère

  // ========== HELPER SÉCURISÉ POUR RÉCUPÉRER LE TOKEN ==========
  
  /// Récupère le token de manière sécurisée depuis le storage
  /// IMPORTANT : Ne jamais modifier le token (pas de trim, strip, etc.) car cela casserait la signature JWT
  /// Retourne null si le token est invalide ou manquant
  Future<String?> _getSecureToken() async {
    try {
      // 1. Essayer depuis GetStorage
      String? authToken = GetStorage().read('token');
      
      // 2. Si vide, essayer depuis la variable globale
      if (authToken == null || authToken.isEmpty) {
        authToken = token;
      }
      
      // 3. Si toujours vide, essayer depuis UserData
      if (authToken == null || authToken.isEmpty) {
        try {
          var userData = GetStorage().read('UserData');
          if (userData != null) {
            var userDataMap = jsonDecode(userData);
            if (userDataMap['data'] != null && userDataMap['data']['token'] != null) {
              authToken = userDataMap['data']['token'].toString();
            }
          }
        } catch (e) {
          debugPrint('❌ [VEHICLE] Erreur lors de la récupération du token depuis UserData: $e');
        }
      }
      
      // 4. Validation : vérifier que le token n'est pas vide
      if (authToken == null || authToken.isEmpty) {
        debugPrint('❌ [VEHICLE] Token manquant ou vide');
        return null;
      }
      
      // 5. Log pour vérification (seulement les 20 premiers caractères pour sécurité)
      final tokenPreview = authToken.length > 20 
          ? '${authToken.substring(0, 20)}...' 
          : authToken;
      debugPrint('✅ [VEHICLE] Token récupéré: $tokenPreview (length: ${authToken.length})');
      
      // IMPORTANT : Ne jamais modifier le token (pas de trim, strip, etc.)
      // Le token JWT doit être envoyé tel quel pour que la signature soit valide
      return authToken;
    } catch (e) {
      debugPrint('❌ [VEHICLE] Erreur lors de la récupération du token: $e');
      return null;
    }
  }
  
  /// Vérifie si une erreur indique un token invalide et redirige vers login si nécessaire
  void _handleTokenError(dynamic error, {bool shouldRedirect = true}) {
    final errorString = error.toString().toLowerCase();
    final isTokenError = errorString.contains('invalid signature') ||
                        errorString.contains('invalid token') ||
                        errorString.contains('token expired') ||
                        errorString.contains('unauthorized') ||
                        errorString.contains('401');
    
    if (isTokenError && shouldRedirect) {
      debugPrint('🔒 [VEHICLE] Token invalide détecté, redirection vers login...');
      closeLoading();
      showErrorToastMessage('Session expirée. Veuillez vous reconnecter.');
      Future.delayed(const Duration(seconds: 1), () {
        logout();
        Get.offAll(() => const LoginScreen());
      });
    }
  }
  
  /// Réinitialise tous les champs du formulaire après une soumission réussie
  void clearFormFields() {
    debugPrint('🧹 [VEHICLE] Réinitialisation du formulaire...');
    
    // CRITIQUE : Arrêter TOUS les loaders en cours pour éviter les spinners bloqués
    isLoadingMakes.value = false;
    isLoadingModels.value = false;
    isLoadingFuelTypes.value = false;
    isLoadingOdometer.value = false;
    isLoadingVehicleTypes.value = false;
    isLoadingLocations.value = false;
    isLoadingFeatures.value = false;
    isLoadingPolicies.value = false;
    isLoadingRules.value = false;
    isLoadingMyVehicles.value = false;
    
    // Réinitialiser les sélections de base
    // Note: Les listes (makesList, modelsList, etc.) sont conservées pour éviter de recharger
    
    // Étape 1: Type de véhicule, marque, modèle, carburant
    // (Les sélections sont gérées dans add_vehicle_screen.dart, pas besoin de les réinitialiser ici)
    
    // Étape 2: Détails du véhicule
    plateNumber1 = '';
    plateNumber2 = '';
    plateNumber3 = '';
    minRentalDays = '1';
    selectedInsurance = '';
    hasAgeRestriction = false;
    minAge = '18';
    allowsInternationalTravel = false;
    
    // Étape 3: Tarification
    pricePerDay = 0.0;
    deposit = 0.0;
    hasWeeklyDiscount = false;
    weeklyDiscountValue = 0.0;
    weeklyDiscountType = 'percent';
    hasMonthlyDiscount = false;
    monthlyDiscountValue = 0.0;
    monthlyDiscountType = 'percent';
    hasHomeDelivery = false;
    deliveryPrice = 0.0;
    
    // Étape 4: Localisation
    selectedRegionId.value = '';
    fullAddress.value = '';
    selectedLatitude.value = 0.0;
    selectedLongitude.value = 0.0;
    
    // Étape 5: Équipements
    selectedFeatures.clear();
    
    // Étape 6: Politiques & Règles
    selectedPolicyId.value = '';
    tierSwitches.clear();
    tierRetentionFees.clear();
    selectedRules.clear();
    
    // Étape 7: Photos
    selectedImages.clear();
    uploadedImageUrls.clear();
    
    // Étape 8: Documents
    registrationCardRecto.value = null;
    registrationCardVerso.value = null;
    ministryAuthorization.value = null;
    
    // Reset final : remettre isSuccess à false pour le prochain ajout
    isSuccess.value = false;
    
    debugPrint('✅ [VEHICLE] Formulaire réinitialisé');
    update();
  }

  /// Force le rafraîchissement du bearer token avant les appels API
  /// Utile lors de l'initialisation pour s'assurer que le token n'est pas expiré
  Future<bool> refreshBearerToken() async {
    try {
      debugPrint('🔄 [VEHICLE] Rafraîchissement du bearer token...');
      // Effacer l'ancien bearer token pour forcer la régénération
      bearerToken = "";
      GetStorage().remove("bearerToken");
      
      // Régénérer le bearer token
      final newBearerToken = await generateToken();
      if (newBearerToken != null && newBearerToken.isNotEmpty) {
        debugPrint('✅ [VEHICLE] Bearer token rafraîchi avec succès');
        return true;
      } else {
        debugPrint('❌ [VEHICLE] Échec du rafraîchissement du bearer token');
        return false;
      }
    } catch (e) {
      debugPrint('❌ [VEHICLE] Erreur lors du rafraîchissement du bearer token: $e');
      return false;
    }
  }

  /// Sélectionne plusieurs images depuis la galerie
  /// Limite : 10 images maximum
  Future<void> pickMultipleImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        // Limiter à 10 images au total
        final int remainingSlots = 10 - selectedImages.length;
        if (remainingSlots > 0) {
          final List<XFile> imagesToAdd = images.take(remainingSlots).toList();
          selectedImages.addAll(imagesToAdd);
          
          if (images.length > remainingSlots) {
            showErrorToastMessage('Maximum 10 images autorisées. ${images.length - remainingSlots} image(s) ignorée(s)');
          }
        } else {
          showErrorToastMessage('Maximum 10 images autorisées');
        }
      }
    } catch (e) {
      debugPrint('❌ [VEHICLE] Erreur lors de la sélection des images: $e');
      showErrorToastMessage('Erreur lors de la sélection des images: $e');
    }
  }

  /// Supprime une image de la liste
  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }

  /// Sélectionne un document (image JPG/PNG ou PDF)
  /// Type peut être : 'recto', 'verso', 'authorization'
  /// Limite : 5MB maximum
  Future<void> pickDocument(String type) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();
        final maxSize = 5 * 1024 * 1024; // 5MB

        if (fileSize > maxSize) {
          showErrorToastMessage('Le fichier est trop volumineux. Taille maximum : 5MB');
          return;
        }

        // Assigner le fichier selon le type
        switch (type) {
          case 'recto':
            registrationCardRecto.value = file;
            break;
          case 'verso':
            registrationCardVerso.value = file;
            break;
          case 'authorization':
            ministryAuthorization.value = file;
            break;
          default:
            debugPrint('❌ [VEHICLE] Type de document inconnu: $type');
        }
      }
    } catch (e) {
      debugPrint('❌ [VEHICLE] Erreur lors de la sélection du document: $e');
      showErrorToastMessage('Erreur lors de la sélection du document: $e');
    }
  }

  /// Supprime un document selon son type
  void removeDocument(String type) {
    switch (type) {
      case 'recto':
        registrationCardRecto.value = null;
        break;
      case 'verso':
        registrationCardVerso.value = null;
        break;
      case 'authorization':
        ministryAuthorization.value = null;
        break;
    }
  }

  // ========== PARAMÈTRES DE COMPRESSION ==========
  static const int maxWidth = 1920; // 1080p width
  static const int maxHeight = 1080; // 1080p height
  static const int compressionQuality = 80; // 80% de qualité

  // ========== MÉTHODES DE RÉCUPÉRATION DES DONNÉES ==========

  /// Récupère la liste des marques (VehicleMake) depuis l'API
  /// URL utilisée : /api/vehicle-reference/makes (sans /v1/)
  Future<void> fetchVehicleMakes({String? typeId}) async {
    try {
      isLoadingMakes.value = true;
      debugPrint('🔄 [VEHICLE] Début fetchVehicleMakes - typeId: $typeId');
      
      final Map<String, dynamic> params = {};
      if (typeId != null && typeId.isNotEmpty) {
        params['type_id'] = typeId;
      }

      // Utiliser adminBaseUrl qui est déjà /api/ (sans /v1/)
      final fullUrl = '${Config.adminBaseUrl}${Config.vehicleReferenceMakes}';
      debugPrint('📡 [VEHICLE] Appel API: $fullUrl avec params: $params');
      
      final response = await httpGetAdmin(Config.vehicleReferenceMakes, params);
      
      // 🔍 DEBUG: Afficher le body complet de la réponse
      debugPrint('🔍 [DEBUG] Body complet de la réponse: $response');
      debugPrint('🔍 [DEBUG] Type de réponse: ${response.runtimeType}');
      
      debugPrint('📥 [VEHICLE] Réponse reçue: ${response != null ? "OK" : "NULL"}');
      
      // Parsing robuste : L'API renvoie { "success": true, "data": { "data": [...] } } ou { "success": true, "data": [...] }
      if (response != null && response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] != null) {
          var dataObj = response['data'];
          List<dynamic> list;
          
          if (dataObj is List) {
            // Structure directe : { "success": true, "data": [...] }
            list = dataObj as List;
          } else if (dataObj is Map<String, dynamic> && dataObj['data'] != null) {
            // Structure imbriquée : { "success": true, "data": { "data": [...] } }
            list = dataObj['data'] as List;
          } else {
            debugPrint('⚠️ [VEHICLE] Structure de data inattendue: ${dataObj.runtimeType}');
            list = [];
          }
          
          debugPrint('✅ [VEHICLE] Structure détectée - longueur: ${list.length}');
          
          try {
            makesList.clear();
            for (var item in list) {
              if (item is Map<String, dynamic>) {
                makesList.add(Makes.fromJson(item));
              }
            }
            debugPrint('✅ [VEHICLE] makesList mis à jour - longueur: ${makesList.length}');
          } catch (e, stackTrace) {
            debugPrint('❌ [VEHICLE] Erreur lors du parsing: $e');
            debugPrint('❌ [VEHICLE] StackTrace: $stackTrace');
            showErrorToastMessage('Erreur lors du parsing des marques: $e');
          }
        } else {
          debugPrint('⚠️ [VEHICLE] response["success"] != true ou response["data"] est NULL');
          debugPrint('📋 [VEHICLE] Structure complète de la réponse: $response');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [VEHICLE] Erreur lors de la récupération des marques: $e');
      debugPrint('❌ [VEHICLE] StackTrace: $stackTrace');
      
      // Vérifier si c'est une erreur de token invalide
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('invalid signature') || 
          errorString.contains('invalid token') ||
          errorString.contains('unauthorized')) {
        _handleTokenError(e, shouldRedirect: true);
        return;
      }
      
      showErrorToastMessage('Erreur lors de la récupération des marques');
    } finally {
      isLoadingMakes.value = false;
      debugPrint('🏁 [VEHICLE] fetchVehicleMakes terminé - makesList.length: ${makesList.length}');
      update();
    }
  }

  /// Récupère la liste des modèles (VehicleModel) depuis l'API
  /// typeId : ID du type de véhicule (optionnel)
  /// makeId : ID de la marque pour filtrer les modèles (optionnel)
  /// IMPORTANT : L'URL utilisée est /api/vehicle-reference/models?make=$makeId (sans /v1/, paramètre 'make' et non 'makeId')
  Future<void> fetchVehicleModels({String? typeId, String? makeId}) async {
    try {
      isLoadingModels.value = true;
      
      // IMPORTANT : Vider la liste au début pour éviter d'afficher les modèles d'une ancienne marque
      modelsList.clear();

      // Récupérer le token de manière sécurisée
      final String? authToken = await _getSecureToken();
      
      if (authToken == null || authToken.isEmpty) {
        isLoadingModels.value = false;
        showErrorToastMessage('Token d\'authentification manquant');
        _handleTokenError('Token manquant', shouldRedirect: true);
        return;
      }

      // Construire l'URL avec /api/ (sans /v1/) comme demandé
      String url = '${Config.adminBaseUrl}${Config.vehicleReferenceModels}';
      
      // Ajouter les query parameters
      // IMPORTANT : Le paramètre est 'make' et non 'makeId'
      final List<String> queryParams = [];
      if (typeId != null && typeId.isNotEmpty) {
        queryParams.add('typeId=$typeId');
      }
      if (makeId != null && makeId.isNotEmpty) {
        queryParams.add('make=$makeId'); // Paramètre 'make' et non 'makeId'
      }
      
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }
      
      debugPrint('📡 [VEHICLE] Appel API: $url');
      
      // Utiliser Dio pour l'appel API avec l'URL exacte demandée
      final dio.Dio dioInstance = dio.Dio();
      final String bearerHeader = 'Bearer $authToken';
      
      final dio.Options options = dio.Options(
        headers: {
          'Authorization': bearerHeader,
          'Content-Type': 'application/json',
        },
      );
      
      final dio.Response response = await dioInstance.get(url, options: options);
      
      // Construire l'URL pour le debug
      final debugUrl = url;
      
      debugPrint('🔍 [DEBUG] Body complet de la réponse (Models): ${response.data}');
      debugPrint('📡 [VEHICLE] Appel API: $debugUrl');
      
      // Parsing robuste : L'API renvoie { "success": true, "data": { "data": [...] } } ou { "success": true, "data": [...] }
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData != null && responseData is Map<String, dynamic>) {
          if (responseData['success'] == true && responseData['data'] != null) {
            var dataObj = responseData['data'];
            List<dynamic> list;
            
            if (dataObj is List) {
              // Structure directe : { "success": true, "data": [...] }
              list = dataObj as List;
            } else if (dataObj is Map<String, dynamic> && dataObj['data'] != null) {
              // Structure imbriquée : { "success": true, "data": { "data": [...] } }
              list = dataObj['data'] as List;
            } else if (dataObj is Map<String, dynamic> && dataObj['models'] != null) {
              // Structure alternative : { "success": true, "data": { "models": [...] } }
              list = dataObj['models'] as List;
            } else {
              debugPrint('⚠️ [VEHICLE] Structure de data inattendue: ${dataObj.runtimeType}');
              list = [];
            }
            
            debugPrint('✅ [VEHICLE] Structure détectée - longueur: ${list.length}');
            
            try {
              for (var item in list) {
                if (item is Map<String, dynamic>) {
                  try {
                    // Créer un objet Models depuis la réponse avec gestion d'erreur par élément
                    modelsList.add(Models.fromJson(item));
                  } catch (e, stackTrace) {
                    // Si une erreur survient sur un élément, logger l'élément problématique
                    debugPrint('❌ [VEHICLE] Erreur sur l\'élément: $item');
                    debugPrint('❌ [VEHICLE] Erreur: $e');
                    debugPrint('❌ [VEHICLE] StackTrace: $stackTrace');
                    // Continuer avec les autres éléments sans bloquer toute la liste
                  }
                }
              }
              debugPrint('✅ [VEHICLE] modelsList mis à jour - longueur: ${modelsList.length}');
            } catch (e, stackTrace) {
              debugPrint('❌ [VEHICLE] Erreur lors du parsing Models (niveau liste): $e');
              debugPrint('❌ [VEHICLE] StackTrace: $stackTrace');
              showErrorToastMessage('Erreur lors du parsing des modèles: $e');
            }
          } else {
            debugPrint('⚠️ [VEHICLE] response["success"] != true ou response["data"] est NULL');
            debugPrint('📋 [VEHICLE] Structure complète: $responseData');
          }
        }
      } else {
        debugPrint('❌ [VEHICLE] Erreur HTTP: ${response.statusCode}');
        showErrorToastMessage('Erreur lors de la récupération des modèles: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      String errorMessage = 'Erreur réseau ou serveur: ${e.message}';
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString() ?? errorMessage;
          // Vérifier si c'est une erreur de token invalide
          final errorString = errorMessage.toLowerCase();
          if (errorString.contains('invalid signature') || 
              errorString.contains('invalid token') ||
              errorString.contains('unauthorized') ||
              e.response?.statusCode == 401) {
            _handleTokenError(errorMessage, shouldRedirect: true);
            return;
          }
        }
      }
      debugPrint('❌ [VEHICLE] Erreur Dio lors de la récupération des modèles: $e');
      showErrorToastMessage(errorMessage);
    } catch (e) {
      debugPrint('❌ [VEHICLE] Erreur lors de la récupération des modèles: $e');
      showErrorToastMessage('Erreur lors de la récupération des modèles');
    } finally {
      isLoadingModels.value = false;
      update();
    }
  }

  /// Récupère la liste des types de carburant (VehicleFuelType) depuis l'API
  Future<void> fetchVehicleFuelTypes() async {
    try {
      isLoadingFuelTypes.value = true;

      final response = await httpGetAdmin(Config.vehicleReferenceFuelTypes, {});
      
      debugPrint('🔍 [DEBUG] Body complet de la réponse (FuelTypes): $response');
      
      // Parsing robuste : L'API renvoie { "success": true, "data": { "data": [...] } } ou { "success": true, "data": [...] }
      if (response != null && response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] != null) {
          var dataObj = response['data'];
          List<dynamic> list;
          
          if (dataObj is List) {
            // Structure directe : { "success": true, "data": [...] }
            list = dataObj as List;
          } else if (dataObj is Map<String, dynamic> && dataObj['data'] != null) {
            // Structure imbriquée : { "success": true, "data": { "data": [...] } }
            list = dataObj['data'] as List;
          } else {
            debugPrint('⚠️ [VEHICLE] Structure de data inattendue: ${dataObj.runtimeType}');
            list = [];
          }
          
          debugPrint('✅ [VEHICLE] Structure détectée - longueur: ${list.length}');
          
          try {
            fuelTypesList.clear();
            for (var item in list) {
              if (item is Map<String, dynamic>) {
                fuelTypesList.add(FuelType.fromJson(item));
              }
            }
            debugPrint('✅ [VEHICLE] fuelTypesList mis à jour - longueur: ${fuelTypesList.length}');
          } catch (e, stackTrace) {
            debugPrint('❌ [VEHICLE] Erreur lors du parsing FuelTypes: $e');
            debugPrint('❌ [VEHICLE] StackTrace: $stackTrace');
            showErrorToastMessage('Erreur lors du parsing des types de carburant: $e');
          }
        } else {
          debugPrint('⚠️ [VEHICLE] response["success"] != true ou response["data"] est NULL');
          debugPrint('📋 [VEHICLE] Structure complète: $response');
        }
      }
    } catch (e) {
      debugPrint('❌ [VEHICLE] Erreur lors de la récupération des types de carburant: $e');
      
      // Vérifier si c'est une erreur de token invalide
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('invalid signature') || 
          errorString.contains('invalid token') ||
          errorString.contains('unauthorized')) {
        _handleTokenError(e, shouldRedirect: true);
        return;
      }
      
      showErrorToastMessage('Erreur lors de la récupération des types de carburant');
    } finally {
      isLoadingFuelTypes.value = false;
      update();
    }
  }

  /// Récupère la liste des types de véhicules depuis l'API
  Future<void> fetchVehicleTypes() async {
    try {
      isLoadingVehicleTypes.value = true;

      // Utiliser la même route que l'écran d'accueil (Home) qui fonctionne déjà
      // Home utilise: httpGet(Config.itemsType, {}) où itemsType = 'get-all-categories'
      // URL complète: https://carvy.tech/api/v1/get-all-categories
      debugPrint('📡 [VEHICLE] Appel API VehicleTypes (même route que Home): ${Config.baseurl}${Config.itemsType}');
      
      // Utiliser httpGet (comme Home) au lieu de httpGetAdmin
      final response = await httpGet(Config.itemsType, {});
      
      debugPrint('🔍 [DEBUG] Body complet de la réponse (VehicleTypes): $response');
      
      if (response != null && response is Map<String, dynamic>) {
        // Structure attendue: { "status": 200, "data": { "itemTypes": [...] } }
        // (même format que HomeController)
        var dataObj = response['data'];
        
        if (dataObj != null && dataObj is Map<String, dynamic>) {
          // Extraire itemTypes depuis data.itemTypes (format Home)
          var itemTypes = dataObj['itemTypes'];
          
          if (itemTypes != null && itemTypes is List) {
            debugPrint('✅ [VEHICLE] Structure détectée (format Home) - longueur: ${itemTypes.length}');
            
            try {
              vehicleTypesList.clear();
              // Parser chaque élément et s'assurer que _id est bien mappé
              for (var item in itemTypes) {
                if (item is Map<String, dynamic>) {
                  // S'assurer que l'id utilise _id si présent (mapping MongoDB)
                  if (item['_id'] != null && item['id'] == null) {
                    item['id'] = item['_id'].toString();
                  }
                  vehicleTypesList.add(item);
                }
              }
              debugPrint('✅ [VEHICLE] vehicleTypesList mis à jour - longueur: ${vehicleTypesList.length}');
            } catch (e, stackTrace) {
              debugPrint('❌ [VEHICLE] Erreur lors du parsing VehicleTypes: $e');
              debugPrint('❌ [VEHICLE] StackTrace: $stackTrace');
              showErrorToastMessage('Erreur lors du parsing des types de véhicules: $e');
            }
          } else {
            debugPrint('⚠️ [VEHICLE] data.itemTypes n\'est pas une liste: ${itemTypes?.runtimeType}');
            debugPrint('📋 [VEHICLE] Structure complète: $response');
          }
        } else if (dataObj != null && dataObj is List) {
          // Fallback: si data est directement une liste
          debugPrint('✅ [VEHICLE] Structure directe (Liste) - longueur: ${dataObj.length}');
          try {
            vehicleTypesList.clear();
            for (var item in dataObj) {
              if (item is Map<String, dynamic>) {
                if (item['_id'] != null && item['id'] == null) {
                  item['id'] = item['_id'].toString();
                }
                vehicleTypesList.add(item);
              }
            }
            debugPrint('✅ [VEHICLE] vehicleTypesList mis à jour - longueur: ${vehicleTypesList.length}');
          } catch (e) {
            debugPrint('❌ [VEHICLE] Erreur lors du parsing: $e');
          }
        } else {
          debugPrint('⚠️ [VEHICLE] Structure de data inattendue: ${dataObj?.runtimeType}');
          debugPrint('📋 [VEHICLE] Structure complète: $response');
        }
      } else {
        debugPrint('⚠️ [VEHICLE] Réponse invalide ou null');
        debugPrint('📋 [VEHICLE] Type de réponse: ${response?.runtimeType}');
      }
    } catch (e) {
      debugPrint('❌ [VEHICLE] Erreur lors de la récupération des types de véhicules: $e');
      showErrorToastMessage('Erreur lors de la récupération des types de véhicules');
    } finally {
      isLoadingVehicleTypes.value = false;
      update();
    }
  }

  /// Récupère la liste des catégories depuis l'API
  Future<void> fetchCategories() async {
    try {
      isLoadingCategories.value = true;

      // Utiliser la route get-all-categories
      final response = await httpGet(Config.itemsType, {});
      
      debugPrint('🔍 [DEBUG] Body complet de la réponse (Categories): $response');
      
      // Parsing robuste : L'API renvoie { "status": 200, "data": { "itemTypes": [...] } }
      if (response != null && response is Map<String, dynamic>) {
        if (response['data'] != null) {
          var dataObj = response['data'];
          List<dynamic> list;
          
          if (dataObj is Map<String, dynamic>) {
            // Structure : { "data": { "itemTypes": [...] } }
            if (dataObj['itemTypes'] != null && dataObj['itemTypes'] is List) {
              list = dataObj['itemTypes'] as List;
            } else if (dataObj['data'] != null && dataObj['data'] is List) {
              list = dataObj['data'] as List;
            } else {
              debugPrint('⚠️ [VEHICLE] Structure de data inattendue: ${dataObj.runtimeType}');
              list = [];
            }
          } else if (dataObj is List) {
            list = dataObj;
          } else {
            list = [];
          }
          
          debugPrint('✅ [VEHICLE] Structure détectée - longueur: ${list.length}');
          
          try {
            categoriesList.clear();
            for (var item in list) {
              if (item is Map<String, dynamic>) {
                // S'assurer que l'id utilise _id si présent (mapping MongoDB)
                if (item['_id'] != null && item['id'] == null) {
                  item['id'] = item['_id'].toString();
                }
                categoriesList.add(item);
              }
            }
            debugPrint('✅ [VEHICLE] categoriesList mis à jour - longueur: ${categoriesList.length}');
          } catch (e, stackTrace) {
            debugPrint('❌ [VEHICLE] Erreur lors du parsing Categories: $e');
            debugPrint('❌ [VEHICLE] StackTrace: $stackTrace');
            showErrorToastMessage('Erreur lors du parsing des catégories: $e');
          }
        } else {
          debugPrint('⚠️ [VEHICLE] response["data"] est NULL');
          debugPrint('📋 [VEHICLE] Structure complète: $response');
        }
      }
    } catch (e) {
      debugPrint('❌ [VEHICLE] Erreur lors de la récupération des catégories: $e');
      showErrorToastMessage('Erreur lors de la récupération des catégories');
    } finally {
      isLoadingCategories.value = false;
      update();
    }
  }

  /// Récupère la liste des odomètres (Kilométrage) depuis l'API
  Future<void> fetchOdometers() async {
    try {
      isLoadingOdometer.value = true;
      odometerList.clear();

      // Utiliser la route vehicle-reference/odometers
      final response = await httpGetAdmin(Config.vehicleReferenceOdometers, {});
      
      debugPrint('🔍 [DEBUG] Body complet de la réponse (Odometers): $response');
      
      // Parsing robuste : L'API renvoie { "success": true, "data": [...] }
      if (response != null && response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] != null) {
          var dataObj = response['data'];
          List<dynamic> list;
          
          if (dataObj is List) {
            list = dataObj as List;
          } else if (dataObj is Map<String, dynamic> && dataObj['data'] != null) {
            list = dataObj['data'] as List;
          } else {
            debugPrint('⚠️ [VEHICLE] Structure de data inattendue: ${dataObj.runtimeType}');
            list = [];
          }
          
          debugPrint('✅ [VEHICLE] Structure détectée - longueur: ${list.length}');
          
          try {
            for (var item in list) {
              if (item is Map<String, dynamic>) {
                try {
                  // Créer un Getodometer depuis la réponse avec gestion d'erreur par élément
                  // S'assurer que l'id utilise _id si présent (mapping MongoDB)
                  if (item['_id'] != null && item['id'] == null) {
                    item['id'] = item['_id'].toString();
                  }
                  odometerList.add(Getodometer.fromJson(item));
                } catch (e, stackTrace) {
                  debugPrint('❌ [VEHICLE] Erreur sur l\'élément: $item');
                  debugPrint('❌ [VEHICLE] Erreur: $e');
                  debugPrint('❌ [VEHICLE] StackTrace: $stackTrace');
                }
              }
            }
            debugPrint('✅ [VEHICLE] odometerList mis à jour - longueur: ${odometerList.length}');
          } catch (e, stackTrace) {
            debugPrint('❌ [VEHICLE] Erreur lors du parsing Odometers: $e');
            debugPrint('❌ [VEHICLE] StackTrace: $stackTrace');
            showErrorToastMessage('Erreur lors du parsing des kilométrages: $e');
          }
        } else {
          debugPrint('⚠️ [VEHICLE] response["success"] != true ou response["data"] est NULL');
          debugPrint('📋 [VEHICLE] Structure complète: $response');
        }
      }
    } catch (e) {
      debugPrint('❌ [VEHICLE] Erreur lors de la récupération des odomètres: $e');
      showErrorToastMessage('Erreur lors de la récupération des kilométrages');
    } finally {
      isLoadingOdometer.value = false;
      update();
    }
  }

  /// Récupère la liste des régions (Villes/Régions) depuis l'API
  Future<void> fetchRegions() async {
    try {
      isLoadingRegions.value = true;
      regionsList.clear();

      // Utiliser la route vehicle-reference/regions
      final response = await httpGetAdmin(Config.vehicleReferenceRegions, {});
      
      debugPrint('🔍 [DEBUG] Body complet de la réponse (Regions): $response');
      
      // Parsing robuste : L'API renvoie { "success": true, "data": [...] }
      if (response != null && response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] != null) {
          var dataObj = response['data'];
          List<dynamic> list;
          
          if (dataObj is List) {
            list = dataObj as List;
          } else if (dataObj is Map<String, dynamic> && dataObj['data'] != null) {
            list = dataObj['data'] as List;
          } else if (dataObj is Map<String, dynamic> && dataObj['regions'] != null) {
            list = dataObj['regions'] as List;
          } else {
            debugPrint('⚠️ [VEHICLE] Structure de data inattendue: ${dataObj.runtimeType}');
            list = [];
          }
          
          debugPrint('✅ [VEHICLE] Structure détectée - longueur: ${list.length}');
          
          try {
            for (var item in list) {
              if (item is Map<String, dynamic>) {
                try {
                  // S'assurer que l'id utilise _id si présent (mapping MongoDB)
                  if (item['_id'] != null && item['id'] == null) {
                    item['id'] = item['_id'].toString();
                  }
                  regionsList.add(item);
                } catch (e, stackTrace) {
                  debugPrint('❌ [VEHICLE] Erreur sur l\'élément: $item');
                  debugPrint('❌ [VEHICLE] Erreur: $e');
                  debugPrint('❌ [VEHICLE] StackTrace: $stackTrace');
                }
              }
            }
            debugPrint('✅ [VEHICLE] regionsList mis à jour - longueur: ${regionsList.length}');
          } catch (e, stackTrace) {
            debugPrint('❌ [VEHICLE] Erreur lors du parsing Regions: $e');
            debugPrint('❌ [VEHICLE] StackTrace: $stackTrace');
            showErrorToastMessage('Erreur lors du parsing des régions: $e');
          }
        } else {
          debugPrint('⚠️ [VEHICLE] response["success"] != true ou response["data"] est NULL');
          debugPrint('📋 [VEHICLE] Structure complète: $response');
        }
      }
    } catch (e) {
      debugPrint('❌ [VEHICLE] Erreur lors de la récupération des régions: $e');
      showErrorToastMessage('Erreur lors de la récupération des régions');
    } finally {
      isLoadingRegions.value = false;
      update();
    }
  }

  /// Récupère la liste des localisations (Villes/Régions) depuis l'API Node.js
  /// Utilise /api/vehicle-reference/locations (route publique)
  Future<void> fetchLocations() async {
    try {
      isLoadingLocations.value = true;
      locationsList.clear();

      // Utiliser la route publique vehicle-reference/locations
      final response = await httpGetAdmin(Config.vehicleReferenceLocations, {});
      debugPrint('🔍 [DEBUG] Réponse depuis /api/vehicle-reference/locations: $response');
      
      // Parsing robuste : L'API renvoie { "success": true, "data": [...] }
      if (response != null && response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] != null) {
          var dataObj = response['data'];
          List<dynamic> list;
          
          if (dataObj is List) {
            list = dataObj as List;
          } else if (dataObj is Map<String, dynamic> && dataObj['data'] != null) {
            list = dataObj['data'] as List;
          } else if (dataObj is Map<String, dynamic> && dataObj['locations'] != null) {
            list = dataObj['locations'] as List;
          } else {
            debugPrint('⚠️ [VEHICLE] Structure de data inattendue: ${dataObj.runtimeType}');
            list = [];
          }
          
          debugPrint('✅ [VEHICLE] Structure détectée - longueur: ${list.length}');
          
          try {
            // Utiliser assignAll pour une mise à jour réactive complète
            final processedList = <Map<String, dynamic>>[];
            for (var item in list) {
              if (item is Map<String, dynamic>) {
                try {
                  // S'assurer que l'id utilise _id si présent (mapping MongoDB)
                  if (item['_id'] != null && item['id'] == null) {
                    item['id'] = item['_id'].toString();
                  }
                  processedList.add(item);
                } catch (e, stackTrace) {
                  debugPrint('❌ [VEHICLE] Erreur sur l\'élément: $item');
                  debugPrint('❌ [VEHICLE] Erreur: $e');
                  debugPrint('❌ [VEHICLE] StackTrace: $stackTrace');
                }
              }
            }
            // Utiliser assignAll pour déclencher la réactivité GetX
            locationsList.assignAll(processedList);
            debugPrint('✅ [VEHICLE] locationsList mis à jour - longueur: ${locationsList.length}');
          } catch (e, stackTrace) {
            debugPrint('❌ [VEHICLE] Erreur lors du parsing Locations: $e');
            debugPrint('❌ [VEHICLE] StackTrace: $stackTrace');
            showErrorToastMessage('Erreur lors du parsing des localisations: $e');
          }
        } else {
          debugPrint('⚠️ [VEHICLE] response["success"] != true ou response["data"] est NULL');
          debugPrint('📋 [VEHICLE] Structure complète: $response');
        }
      }
    } catch (e) {
      debugPrint('❌ [VEHICLE] Erreur lors de la récupération des localisations: $e');
      showErrorToastMessage('Erreur lors de la récupération des localisations');
    } finally {
      isLoadingLocations.value = false;
      update();
    }
  }

  /// Récupère la liste des équipements depuis l'API Node.js
  /// Utilise /api/vehicle-reference/features (route publique)
  Future<void> fetchFeatures() async {
    try {
      isLoadingFeatures.value = true;
      featuresList.clear();

      final response = await httpGetAdmin(Config.vehicleReferenceFeatures, {});
      debugPrint('🔍 [DEBUG] Réponse depuis /api/vehicle-reference/features: $response');
      
      // Parsing robuste : L'API renvoie { "success": true, "data": [...] }
      if (response != null && response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] != null) {
          var dataObj = response['data'];
          List<dynamic> list;
          
          if (dataObj is List) {
            list = dataObj as List;
          } else if (dataObj is Map<String, dynamic> && dataObj['data'] != null) {
            list = dataObj['data'] as List;
          } else if (dataObj is Map<String, dynamic> && dataObj['features'] != null) {
            list = dataObj['features'] as List;
          } else {
            debugPrint('⚠️ [VEHICLE] Structure de data inattendue: ${dataObj.runtimeType}');
            list = [];
          }
          
          debugPrint('✅ [VEHICLE] Structure détectée - longueur: ${list.length}');
          
          try {
            // Utiliser assignAll pour une mise à jour réactive complète
            final processedList = <Map<String, dynamic>>[];
            for (var item in list) {
              if (item is Map<String, dynamic>) {
                try {
                  // S'assurer que l'id utilise _id si présent (mapping MongoDB)
                  if (item['_id'] != null && item['id'] == null) {
                    item['id'] = item['_id'].toString();
                  }
                  processedList.add(item);
                } catch (e, stackTrace) {
                  debugPrint('❌ [VEHICLE] Erreur sur l\'élément: $item');
                  debugPrint('❌ [VEHICLE] Erreur: $e');
                  debugPrint('❌ [VEHICLE] StackTrace: $stackTrace');
                }
              }
            }
            // Utiliser assignAll pour déclencher la réactivité GetX
            featuresList.assignAll(processedList);
            debugPrint('✅ [VEHICLE] featuresList mis à jour - longueur: ${featuresList.length}');
          } catch (e, stackTrace) {
            debugPrint('❌ [VEHICLE] Erreur lors du parsing Features: $e');
            debugPrint('❌ [VEHICLE] StackTrace: $stackTrace');
            showErrorToastMessage('Erreur lors du parsing des équipements: $e');
          }
        } else {
          debugPrint('⚠️ [VEHICLE] response["success"] != true ou response["data"] est NULL');
          debugPrint('📋 [VEHICLE] Structure complète: $response');
        }
      }
    } catch (e) {
      debugPrint('❌ [VEHICLE] Erreur lors de la récupération des équipements: $e');
      showErrorToastMessage('Erreur lors de la récupération des équipements');
    } finally {
      isLoadingFeatures.value = false;
      update();
    }
  }

  /// Récupère la liste des politiques d'annulation depuis l'API Node.js
  /// Utilise /api/vehicle-reference/cancellation-policies (route publique)
  Future<void> fetchPolicies() async {
    try {
      isLoadingPolicies.value = true;
      policiesList.clear();

      final response = await httpGetAdmin(Config.vehicleReferenceCancellationPolicies, {});
      debugPrint('🔍 [DEBUG] Réponse depuis /api/vehicle-reference/cancellation-policies: $response');
      
      // Parsing robuste : L'API renvoie { "success": true, "data": [...] }
      if (response != null && response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] != null) {
          var dataObj = response['data'];
          List<dynamic> list;
          
          if (dataObj is List) {
            list = dataObj as List;
          } else if (dataObj is Map<String, dynamic> && dataObj['data'] != null) {
            list = dataObj['data'] as List;
          } else if (dataObj is Map<String, dynamic> && dataObj['policies'] != null) {
            list = dataObj['policies'] as List;
          } else {
            debugPrint('⚠️ [VEHICLE] Structure de data inattendue: ${dataObj.runtimeType}');
            list = [];
          }
          
          debugPrint('✅ [VEHICLE] Structure détectée - longueur: ${list.length}');
          
          try {
            // Utiliser assignAll pour une mise à jour réactive complète
            final processedList = <Map<String, dynamic>>[];
            for (var item in list) {
              if (item is Map<String, dynamic>) {
                try {
                  // S'assurer que l'id utilise _id si présent (mapping MongoDB)
                  if (item['_id'] != null && item['id'] == null) {
                    item['id'] = item['_id'].toString();
                  }
                  processedList.add(item);
                } catch (e, stackTrace) {
                  debugPrint('❌ [VEHICLE] Erreur sur l\'élément: $item');
                  debugPrint('❌ [VEHICLE] Erreur: $e');
                  debugPrint('❌ [VEHICLE] StackTrace: $stackTrace');
                }
              }
            }
            // Utiliser assignAll pour déclencher la réactivité GetX
            policiesList.assignAll(processedList);
            debugPrint('✅ [VEHICLE] policiesList mis à jour - longueur: ${policiesList.length}');
          } catch (e, stackTrace) {
            debugPrint('❌ [VEHICLE] Erreur lors du parsing Policies: $e');
            debugPrint('❌ [VEHICLE] StackTrace: $stackTrace');
            showErrorToastMessage('Erreur lors du parsing des politiques: $e');
          }
        } else {
          debugPrint('⚠️ [VEHICLE] response["success"] != true ou response["data"] est NULL');
          debugPrint('📋 [VEHICLE] Structure complète: $response');
        }
      }
    } catch (e) {
      debugPrint('❌ [VEHICLE] Erreur lors de la récupération des politiques: $e');
      showErrorToastMessage('Erreur lors de la récupération des politiques');
    } finally {
      isLoadingPolicies.value = false;
      update();
    }
  }

  /// Récupère la liste des véhicules du vendor depuis l'API
  /// Utilise la même méthode que le Dashboard : httpPost(Config.myItems, {"offset": "0"})
  Future<void> fetchMyVehicles() async {
    try {
      isLoadingMyVehicles.value = true;
      myVehicles.clear();
      myVehiclesItems.clear();

      debugPrint('📡 [VEHICLE] Appel API fetchMyVehicles avec Config.myItems');
      
      // Utiliser la même méthode que le Dashboard
      var response = await httpPost(Config.myItems, {"offset": "0"});
      
      debugPrint('🔍 [DEBUG] Réponse fetchMyVehicles: ${response?['status']}');
      
      if (response != null && response['status'] == 200) {
        // Parser la réponse comme le Dashboard le fait
        final myItemsModel = MyItemsModel.fromJson(response);
        
        if (myItemsModel.data != null && myItemsModel.data!.items != null) {
          final items = myItemsModel.data!.items!;
          debugPrint('✅ [VEHICLE] ${items.length} véhicule(s) récupéré(s)');
          
          // 🔍 DEBUG : Vérifier les IDs de tous les véhicules
          for (var i = 0; i < items.length; i++) {
            final item = items[i];
            final itemIdStr = item.id?.toString() ?? 'null';
            debugPrint('🔍 [VEHICLE] Véhicule $i: ${item.title ?? itemIdStr} - ID: $itemIdStr (type: ${item.id?.runtimeType})');
            if (item.id == null || itemIdStr.isEmpty || itemIdStr == 'null') {
              debugPrint('❌ [VEHICLE] ⚠️ ATTENTION: Véhicule $i n\'a pas d\'ID!');
            }
          }
          
          // Stocker les Items directement pour utilisation avec VehicleItemCard
          myVehiclesItems = items;
          
          // Convertir les Items en Map<String, dynamic> pour myVehicles (pour compatibilité)
          // Utiliser un traitement optimisé pour éviter de bloquer l'UI
          final vehiclesList = <Map<String, dynamic>>[];
          for (var item in items) {
            try {
              final itemMap = item.toJson();
              vehiclesList.add(itemMap);
            } catch (e) {
              debugPrint('⚠️ [VEHICLE] Erreur lors de la conversion d\'un item: $e');
            }
          }
          
          // Assigner la liste complète APRÈS le parsing
          myVehicles.assignAll(vehiclesList);
          debugPrint('✅ [VEHICLE] Liste myVehicles mise à jour avec ${myVehicles.length} véhicule(s)');
          
          // isLoadingMyVehicles.value = false est appelé APRÈS que la liste soit totalement remplie
          isLoadingMyVehicles.value = false;
          update();
        } else {
          debugPrint('⚠️ [VEHICLE] myItemsModel.data ou items est null');
          isLoadingMyVehicles.value = false;
          update();
        }
      } else {
        if (response != null && response["error"] != null) {
          debugPrint('❌ [VEHICLE] Erreur API: ${response["error"]}');
          showErrorToastMessage("${response["error"]}");
        } else {
          debugPrint('❌ [VEHICLE] Erreur: Réponse null ou status != 200');
          showErrorToastMessage("Failed to load items. Please try again.".tr);
        }
        isLoadingMyVehicles.value = false;
        update();
      }
    } catch (e) {
      debugPrint('❌ [VEHICLE] Erreur lors de fetchMyVehicles: $e');
      showErrorToastMessage('Erreur lors de la récupération des véhicules');
      isLoadingMyVehicles.value = false;
      update();
    }
  }

  /// Récupère la liste des règles depuis l'API Node.js
  /// Utilise /api/vehicle-reference/rules (route publique)
  Future<void> fetchRules() async {
    try {
      isLoadingRules.value = true;
      rulesList.clear();

      final response = await httpGetAdmin(Config.vehicleReferenceRules, {});
      debugPrint('🔍 [DEBUG] Réponse depuis /api/vehicle-reference/rules: $response');
      
      // Parsing robuste : L'API renvoie { "success": true, "data": [...] }
      if (response != null && response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] != null) {
          var dataObj = response['data'];
          List<dynamic> list;
          
          if (dataObj is List) {
            list = dataObj as List;
          } else if (dataObj is Map<String, dynamic> && dataObj['data'] != null) {
            list = dataObj['data'] as List;
          } else if (dataObj is Map<String, dynamic> && dataObj['rules'] != null) {
            list = dataObj['rules'] as List;
          } else {
            debugPrint('⚠️ [VEHICLE] Structure de data inattendue: ${dataObj.runtimeType}');
            list = [];
          }
          
          debugPrint('✅ [VEHICLE] Structure détectée - longueur: ${list.length}');
          
          try {
            // Utiliser assignAll pour une mise à jour réactive complète
            final processedList = <Map<String, dynamic>>[];
            for (var item in list) {
              if (item is Map<String, dynamic>) {
                try {
                  // S'assurer que l'id utilise _id si présent (mapping MongoDB)
                  if (item['_id'] != null && item['id'] == null) {
                    item['id'] = item['_id'].toString();
                  }
                  processedList.add(item);
                } catch (e, stackTrace) {
                  debugPrint('❌ [VEHICLE] Erreur sur l\'élément: $item');
                  debugPrint('❌ [VEHICLE] Erreur: $e');
                  debugPrint('❌ [VEHICLE] StackTrace: $stackTrace');
                }
              }
            }
            // Utiliser assignAll pour déclencher la réactivité GetX
            rulesList.assignAll(processedList);
            debugPrint('✅ [VEHICLE] rulesList mis à jour - longueur: ${rulesList.length}');
          } catch (e, stackTrace) {
            debugPrint('❌ [VEHICLE] Erreur lors du parsing Rules: $e');
            debugPrint('❌ [VEHICLE] StackTrace: $stackTrace');
            showErrorToastMessage('Erreur lors du parsing des règles: $e');
          }
        } else {
          debugPrint('⚠️ [VEHICLE] response["success"] != true ou response["data"] est NULL');
          debugPrint('📋 [VEHICLE] Structure complète: $response');
        }
      }
    } catch (e) {
      debugPrint('❌ [VEHICLE] Erreur lors de la récupération des règles: $e');
      showErrorToastMessage('Erreur lors de la récupération des règles');
    } finally {
      isLoadingRules.value = false;
      update();
    }
  }

  // ========== MÉTHODE DE COMPRESSION D'IMAGE ==========

  /// Compresse une image pour réduire sa taille avant l'upload
  /// - Résolution max : 1080p (1920x1080)
  /// - Qualité : 80%
  /// Retourne le chemin du fichier compressé
  Future<File?> _compressImage(XFile imageFile) async {
    try {
      final File originalFile = File(imageFile.path);
      
      if (!await originalFile.exists()) {
        debugPrint('❌ [VEHICLE] Fichier image introuvable: ${imageFile.path}');
        return null;
      }

      // Obtenir le répertoire temporaire
      final Directory tempDir = await getTemporaryDirectory();
      final String targetPath = path.join(
        tempDir.path,
        'vehicle_image_${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}',
      );

      // Compresser l'image avec les paramètres spécifiés
      final List<int>? compressedBytes = await FlutterImageCompress.compressWithFile(
        originalFile.path,
        quality: compressionQuality,
        minWidth: maxWidth,
        minHeight: maxHeight,
      );

      if (compressedBytes == null || compressedBytes.isEmpty) {
        debugPrint('❌ [VEHICLE] La compression de l\'image a échoué');
        // En cas d'erreur, retourner le fichier original
        return originalFile;
      }

      // Écrire le fichier compressé
      final File compressedFile = File(targetPath);
      await compressedFile.writeAsBytes(compressedBytes);

      debugPrint('✅ [VEHICLE] Image compressée: ${originalFile.lengthSync()} bytes → ${compressedFile.lengthSync()} bytes');
      
      return compressedFile;
    } catch (e) {
      debugPrint('❌ [VEHICLE] Erreur lors de la compression de l\'image: $e');
      // En cas d'erreur, retourner le fichier original
      try {
        return File(imageFile.path);
      } catch (_) {
        return null;
      }
    }
  }

  // ========== MÉTHODE D'UPLOAD D'IMAGES ==========

  /// Upload une liste d'images vers /api/upload/images
  /// Les images sont compressées avant l'upload (max 1080p, qualité 80%)
  /// Retourne la liste des URLs des images uploadées
  Future<List<String>> uploadVehicleImages(List<XFile> imageFiles) async {
    if (imageFiles.isEmpty) {
      return [];
    }

    try {
      isUploadingImages.value = true;
      showLoading();

      // Récupérer le token de manière sécurisée (sans modification)
      final String? authToken = await _getSecureToken();
      
      if (authToken == null || authToken.isEmpty) {
        closeLoading();
        showErrorToastMessage('Token d\'authentification manquant');
        _handleTokenError('Token manquant', shouldRedirect: true);
        return [];
      }

      // Construire l'URL
      final String baseUrl = Config.baseUrlWithoutV1;
      final String url = '${baseUrl}${Config.uploadImages}';

      // Créer une instance Dio
      final dio.Dio dioInstance = dio.Dio();

      // Créer FormData avec les images
      final dio.FormData formData = dio.FormData();
      
      // Liste pour stocker les chemins des fichiers compressés (pour nettoyage ultérieur)
      final List<String> compressedFilePaths = [];

      // Compresser et ajouter chaque image
      for (int i = 0; i < imageFiles.length; i++) {
        // Compresser l'image avant l'upload
        final File? compressedFile = await _compressImage(imageFiles[i]);
        
        if (compressedFile == null || !await compressedFile.exists()) {
          debugPrint('❌ [VEHICLE] Impossible de compresser l\'image $i, passage à la suivante');
          continue;
        }

        // Stocker le chemin pour nettoyage ultérieur
        compressedFilePaths.add(compressedFile.path);

        // Déterminer le nom du fichier avec l'extension appropriée
        String filename = 'vehicle_image_$i.jpg';
        final String extension = path.extension(compressedFile.path).toLowerCase();
        if (extension.isNotEmpty && extension != '.') {
          filename = 'vehicle_image_$i$extension';
        }

        // Déterminer le ContentType selon l'extension
        String contentType = 'image/jpeg'; // Par défaut
        if (extension == '.png') {
          contentType = 'image/png';
        } else if (extension == '.jpg' || extension == '.jpeg') {
          contentType = 'image/jpeg';
        } else if (extension == '.webp') {
          contentType = 'image/webp';
        }

        // Créer MultipartFile avec ContentType explicite
        // IMPORTANT: Utiliser la clé 'images' pour chaque fichier (le backend attend upload.array('images', 10))
        formData.files.add(
          MapEntry(
            'images', // Clé impérative pour correspondre à upload.array('images', 10)
            await dio.MultipartFile.fromFile(
              compressedFile.path,
              filename: filename,
              contentType: MediaType.parse(contentType), // ContentType explicite (sans préfixe dio)
            ),
          ),
        );
      }

      // Vérifier qu'on a au moins une image à uploader
      if (formData.files.isEmpty) {
        closeLoading();
        // Nettoyer les fichiers temporaires en cas d'erreur
        _cleanupCompressedFilesPaths(compressedFilePaths);
        showErrorToastMessage('Aucune image valide à uploader');
        return [];
      }

      // Headers avec Bearer Token
      // IMPORTANT : Le token doit être envoyé tel quel, sans modification (pas de trim, etc.)
      // Note: Ne pas définir Content-Type explicitement, Dio le gère automatiquement pour FormData
      // Cela inclut le boundary nécessaire pour multipart/form-data
      final String bearerHeader = 'Bearer $authToken';
      debugPrint('🔑 [VEHICLE] Authorization header: ${bearerHeader.length > 30 ? "${bearerHeader.substring(0, 30)}..." : bearerHeader}');
      
      final dio.Options options = dio.Options(
        headers: {
          'Authorization': bearerHeader, // Token envoyé tel quel, sans modification
        },
      );

      // Envoyer la requête
      final dio.Response response = await dioInstance.post(
        url,
        data: formData,
        options: options,
      );

      closeLoading();

      // Nettoyer les fichiers temporaires compressés après l'upload
      _cleanupCompressedFilesPaths(compressedFilePaths);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        
        // Vérifier que la réponse contient success: true
        if (responseData is Map<String, dynamic>) {
          final bool isSuccess = responseData['success'] == true || 
                                 responseData['status'] == 200 || 
                                 response.statusCode == 200 || 
                                 response.statusCode == 201;
          
          if (!isSuccess) {
            closeLoading();
            final String errorMsg = responseData['message']?.toString() ?? 
                                   'Erreur lors de l\'upload des images';
            showErrorToastMessage(errorMsg);
            debugPrint('❌ [VEHICLE] Upload images échoué: $responseData');
            return [];
          }
        }
        
        // Le backend devrait retourner un objet avec une liste d'URLs
        // Format attendu: { "success": true, "data": [{ "url": "..." }, { "url": "..." }] }
        // ou { "success": true, "data": ["url1", "url2", ...] }
        List<String> urls = [];
        
        if (responseData is Map<String, dynamic>) {
          if (responseData['data'] != null) {
            final data = responseData['data'];
            // Si data est directement une liste
            if (data is List) {
              // Extraire l'URL depuis chaque item (peut être un objet avec 'url' ou directement une string)
              urls = data.map((item) {
                if (item is Map<String, dynamic> && item['url'] != null) {
                  return item['url'] as String;
                } else {
                  return item.toString();
                }
              }).whereType<String>().toList();
            } 
            // Si data est une Map (format: {"data": {"urls": [...]}})
            else if (data is Map<String, dynamic>) {
              if (data['urls'] != null && data['urls'] is List) {
                urls = (data['urls'] as List).map((item) {
                  if (item is Map<String, dynamic> && item['url'] != null) {
                    return item['url'] as String;
                  } else {
                    return item.toString();
                  }
                }).whereType<String>().toList();
              } else if (data['images'] != null && data['images'] is List) {
                urls = (data['images'] as List).map((item) {
                  if (item is Map<String, dynamic> && item['url'] != null) {
                    return item['url'] as String;
                  } else {
                    return item.toString();
                  }
                }).whereType<String>().toList();
              }
            }
          } else if (responseData['urls'] != null && responseData['urls'] is List) {
            urls = (responseData['urls'] as List).map((item) {
              if (item is Map<String, dynamic> && item['url'] != null) {
                return item['url'] as String;
              } else {
                return item.toString();
              }
            }).whereType<String>().toList();
          }
        }

        if (urls.isEmpty) {
          closeLoading();
          showErrorToastMessage('Aucune URL d\'image reçue du serveur');
          debugPrint('❌ [VEHICLE] Aucune URL dans la réponse: $responseData');
          return [];
        }

        uploadedImageUrls.assignAll(urls);
        debugPrint('✅ [VEHICLE] ${urls.length} image(s) uploadée(s) avec succès');
        return urls;
      } else {
        closeLoading();
        showErrorToastMessage('Erreur lors de l\'upload des images: ${response.statusMessage}');
        return [];
      }
    } on dio.DioException catch (e) {
      closeLoading();
      String errorMessage = 'Erreur réseau ou serveur: ${e.message}';
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString() ?? errorMessage;
          // Vérifier si c'est une erreur de token invalide
          final errorString = errorMessage.toLowerCase();
          if (errorString.contains('invalid signature') || 
              errorString.contains('invalid token') ||
              errorString.contains('unauthorized') ||
              e.response?.statusCode == 401) {
            _handleTokenError(errorMessage, shouldRedirect: true);
            return [];
          }
        }
      }
      showErrorToastMessage(errorMessage);
      debugPrint('❌ [VEHICLE] Erreur Dio lors de l\'upload: $e');
      // Nettoyer les fichiers temporaires même en cas d'erreur
      _cleanupAllTemporaryFiles();
      return [];
    } catch (e) {
      closeLoading();
      _handleTokenError(e, shouldRedirect: false);
      showErrorToastMessage('Une erreur inattendue est survenue: $e');
      debugPrint('❌ [VEHICLE] Erreur inattendue lors de l\'upload: $e');
      // Nettoyer les fichiers temporaires même en cas d'erreur
      _cleanupAllTemporaryFiles();
      return [];
    } finally {
      isUploadingImages.value = false;
    }
  }

  /// Upload les documents (Recto, Verso, Autorisation) vers /api/upload/documents
  /// Retourne un Map avec les URLs : { "registrationCardFront": "...", "registrationCardBack": "...", "ministryAuthorization": "..." }
  Future<Map<String, String?>> uploadDocuments({
    File? registrationCardFront,
    File? registrationCardBack,
    File? ministryAuthorization,
  }) async {
    final Map<String, String?> result = {
      'registrationCardFront': null,
      'registrationCardBack': null,
      'ministryAuthorization': null,
    };

    // Si aucun document, retourner le résultat vide
    if (registrationCardFront == null && 
        registrationCardBack == null && 
        ministryAuthorization == null) {
      return result;
    }

    try {
      // Récupérer le token de manière sécurisée (sans modification)
      final String? authToken = await _getSecureToken();
      
      if (authToken == null || authToken.isEmpty) {
        showErrorToastMessage('Token d\'authentification manquant');
        _handleTokenError('Token manquant', shouldRedirect: true);
        return result;
      }

      // Construire l'URL
      final String url = '${Config.baseUrlWithoutV1}${Config.uploadDocuments}';

      // Créer une instance Dio
      final dio.Dio dioInstance = dio.Dio();

      // Créer FormData avec les documents
      final dio.FormData formData = dio.FormData();
      
      // Helper pour déterminer le ContentType selon l'extension
      String getContentType(String filePath) {
        final extension = path.extension(filePath).toLowerCase();
        if (extension == '.pdf') {
          return 'application/pdf';
        } else if (extension == '.jpg' || extension == '.jpeg') {
          return 'image/jpeg';
        } else if (extension == '.png') {
          return 'image/png';
        } else {
          return 'application/pdf'; // Par défaut pour les documents
        }
      }

      if (registrationCardFront != null && await registrationCardFront.exists()) {
        final contentType = getContentType(registrationCardFront.path);
        formData.files.add(
          MapEntry(
            'registrationCardFront', // Clé exacte requise par le backend
            await dio.MultipartFile.fromFile(
              registrationCardFront.path,
              filename: path.basename(registrationCardFront.path),
              contentType: MediaType.parse(contentType), // ContentType explicite
            ),
          ),
        );
      }

      if (registrationCardBack != null && await registrationCardBack.exists()) {
        final contentType = getContentType(registrationCardBack.path);
        formData.files.add(
          MapEntry(
            'registrationCardBack', // Clé exacte requise par le backend
            await dio.MultipartFile.fromFile(
              registrationCardBack.path,
              filename: path.basename(registrationCardBack.path),
              contentType: MediaType.parse(contentType), // ContentType explicite
            ),
          ),
        );
      }

      if (ministryAuthorization != null && await ministryAuthorization.exists()) {
        final contentType = getContentType(ministryAuthorization.path);
        formData.files.add(
          MapEntry(
            'ministryAuthorization', // Clé exacte requise par le backend
            await dio.MultipartFile.fromFile(
              ministryAuthorization.path,
              filename: path.basename(ministryAuthorization.path),
              contentType: MediaType.parse(contentType), // ContentType explicite
            ),
          ),
        );
      }

      // Headers avec Bearer Token
      // IMPORTANT : Le token doit être envoyé tel quel, sans modification (pas de trim, etc.)
      // Note: Ne pas définir Content-Type explicitement, Dio le gère automatiquement pour FormData
      final String bearerHeader = 'Bearer $authToken';
      debugPrint('🔑 [VEHICLE] Authorization header (documents): ${bearerHeader.length > 30 ? "${bearerHeader.substring(0, 30)}..." : bearerHeader}');
      
      final dio.Options options = dio.Options(
        headers: {
          'Authorization': bearerHeader, // Token envoyé tel quel, sans modification
        },
      );

      // Envoyer la requête
      final dio.Response response = await dioInstance.post(
        url,
        data: formData,
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        
        // Vérifier que la réponse contient success: true
        if (responseData is Map<String, dynamic>) {
          final bool isSuccess = responseData['success'] == true || 
                                 responseData['status'] == 200 || 
                                 response.statusCode == 200 || 
                                 response.statusCode == 201;
          
          if (!isSuccess) {
            final String errorMsg = responseData['message']?.toString() ?? 
                                   'Erreur lors de l\'upload des documents';
            showErrorToastMessage(errorMsg);
            debugPrint('❌ [VEHICLE] Upload documents échoué: $responseData');
            return result;
          }
        }
        
        // Le backend devrait retourner un objet avec les URLs des documents
        // Format attendu: { "success": true, "data": { "registrationCardFront": { "url": "..." }, ... } }
        // ou { "success": true, "data": { "registrationCardFront": "url", ... } }
        if (responseData is Map<String, dynamic>) {
          final data = responseData['data'] ?? responseData;
          if (data is Map<String, dynamic>) {
            // Extraire l'URL depuis chaque document (peut être un objet avec 'url' ou directement une string)
            if (data['registrationCardFront'] != null) {
              final front = data['registrationCardFront'];
              result['registrationCardFront'] = (front is Map<String, dynamic> && front['url'] != null) 
                  ? front['url'] as String 
                  : front.toString();
            }
            if (data['registrationCardBack'] != null) {
              final back = data['registrationCardBack'];
              result['registrationCardBack'] = (back is Map<String, dynamic> && back['url'] != null) 
                  ? back['url'] as String 
                  : back.toString();
            }
            if (data['ministryAuthorization'] != null) {
              final auth = data['ministryAuthorization'];
              result['ministryAuthorization'] = (auth is Map<String, dynamic> && auth['url'] != null) 
                  ? auth['url'] as String 
                  : auth.toString();
            }
          }
        }

        debugPrint('✅ [VEHICLE] Documents uploadés avec succès: $result');
        return result;
      } else {
        showErrorToastMessage('Erreur lors de l\'upload des documents: ${response.statusMessage}');
        return result;
      }
    } on dio.DioException catch (e) {
      String errorMessage = 'Erreur réseau ou serveur: ${e.message}';
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString() ?? errorMessage;
          // Vérifier si c'est une erreur de token invalide
          final errorString = errorMessage.toLowerCase();
          if (errorString.contains('invalid signature') || 
              errorString.contains('invalid token') ||
              errorString.contains('unauthorized') ||
              e.response?.statusCode == 401) {
            _handleTokenError(errorMessage, shouldRedirect: true);
            return result;
          }
        }
      }
      showErrorToastMessage(errorMessage);
      debugPrint('❌ [VEHICLE] Erreur Dio lors de l\'upload des documents: $e');
      return result;
    } catch (e) {
      _handleTokenError(e, shouldRedirect: false);
      showErrorToastMessage('Une erreur inattendue est survenue: $e');
      debugPrint('❌ [VEHICLE] Erreur inattendue lors de l\'upload des documents: $e');
      return result;
    }
  }

  /// Upload un document (PDF ou image) vers /api/upload/images
  /// Retourne l'URL du document uploadé ou null en cas d'erreur
  /// [DEPRECATED] Utiliser uploadDocuments à la place
  Future<String?> uploadDocument(File documentFile) async {
    try {
      // Récupérer le token
      String? authToken = GetStorage().read('token') ?? token;
      if (authToken.isEmpty) {
        try {
          var userData = GetStorage().read('UserData');
          if (userData != null) {
            var userDataMap = jsonDecode(userData);
            if (userDataMap['data'] != null && userDataMap['data']['token'] != null) {
              authToken = userDataMap['data']['token'].toString();
            }
          }
        } catch (e) {
          debugPrint('❌ [VEHICLE] Erreur lors de la récupération du token: $e');
        }
      }
      
      if (authToken == null || authToken.isEmpty) {
        showErrorToastMessage('Token d\'authentification manquant');
        return null;
      }

      // Construire l'URL
      final String baseUrl = Config.baseUrlWithoutV1;
      final String url = '${baseUrl}${Config.uploadImages}';

      // Créer une instance Dio
      final dio.Dio dioInstance = dio.Dio();

      // Créer FormData avec le document
      final dio.FormData formData = dio.FormData();
      
      // Déterminer le nom du fichier avec l'extension appropriée
      String filename = path.basename(documentFile.path);
      if (filename.isEmpty) {
        filename = 'document_${DateTime.now().millisecondsSinceEpoch}${path.extension(documentFile.path)}';
      }

      formData.files.add(
        MapEntry(
          'images',
          await dio.MultipartFile.fromFile(
            documentFile.path,
            filename: filename,
          ),
        ),
      );

      // Headers avec Bearer Token
      // IMPORTANT : Le token doit être envoyé tel quel, sans modification (pas de trim, etc.)
      // Note: Ne pas définir Content-Type explicitement, Dio le gère automatiquement pour FormData
      final String bearerHeader = 'Bearer $authToken';
      debugPrint('🔑 [VEHICLE] Authorization header (documents): ${bearerHeader.length > 30 ? "${bearerHeader.substring(0, 30)}..." : bearerHeader}');
      
      final dio.Options options = dio.Options(
        headers: {
          'Authorization': bearerHeader, // Token envoyé tel quel, sans modification
        },
      );

      // Envoyer la requête
      final dio.Response response = await dioInstance.post(
        url,
        data: formData,
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        
        // Le backend devrait retourner un objet avec une liste d'URLs
        List<String> urls = [];
        
        if (responseData is Map<String, dynamic>) {
          if (responseData['data'] != null) {
            final data = responseData['data'];
            if (data is List) {
              urls = List<String>.from(data.map((e) => e.toString()));
            } else if (data is Map<String, dynamic>) {
              if (data['urls'] != null && data['urls'] is List) {
                urls = List<String>.from(data['urls'].map((e) => e.toString()));
              } else if (data['images'] != null && data['images'] is List) {
                urls = List<String>.from(data['images'].map((e) => e.toString()));
              }
            }
          } else if (responseData['urls'] != null && responseData['urls'] is List) {
            urls = List<String>.from(responseData['urls'].map((e) => e.toString()));
          }
        }

        if (urls.isNotEmpty) {
          return urls.first;
        }
        return null;
      } else {
        showErrorToastMessage('Erreur lors de l\'upload du document: ${response.statusMessage}');
        return null;
      }
    } on dio.DioException catch (e) {
      String errorMessage = 'Erreur réseau ou serveur: ${e.message}';
      if (e.response != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      showErrorToastMessage(errorMessage);
      debugPrint('❌ [VEHICLE] Erreur Dio lors de l\'upload du document: $e');
      return null;
    } catch (e) {
      showErrorToastMessage('Une erreur inattendue est survenue: $e');
      debugPrint('❌ [VEHICLE] Erreur inattendue lors de l\'upload du document: $e');
      return null;
    }
  }

  // ========== MÉTHODE DE SOUMISSION DU VÉHICULE ==========

  /// Soumet un véhicule au backend en suivant le flux React/Node.js :
  /// Étape 1 : Upload des images via POST /api/upload/images
  /// Étape 2 : Upload des documents via POST /api/upload/documents
  /// Étape 3 : Création du véhicule avec POST /api/vehicles (JSON pur)
  /// 
  /// Format JSON final:
  /// {
  ///   "specs": { "brand": id, "model": id, "fuel": id, "transmission": "MANUAL/AUTOMATIC", ... },
  ///   "pricing": { "basePrice": num, "currency": "MAD", ... },
  ///   "location": { "type": "Point", "coordinates": [longitude, latitude], "address": "...", "city": "..." },
  ///   "images": [list_of_urls],
  ///   "registrationCardFront": "url",
  ///   "registrationCardBack": "url",
  ///   "ministryAuthorization": "url"
  /// }
  Future<bool> submitVehicle({
    required String? vehicleTypeId,
    required String? brandId,
    required String? modelId,
    required String? fuelId,
    required String transmission, // "MANUAL" ou "AUTOMATIC"
    required String? odometerId,
    required int year,
    required int seats,
    required double basePrice,
    required String currency, // "MAD"
    required double deposit,
    required bool hasWeeklyDiscount,
    required double weeklyDiscountValue,
    required String weeklyDiscountType,
    required bool hasMonthlyDiscount,
    required double monthlyDiscountValue,
    required String monthlyDiscountType,
    required bool hasHomeDelivery,
    required double deliveryPrice,
    required String? regionId,
    required String fullAddress,
    String? city,
    required double latitude,
    required double longitude,
    required List<String> selectedFeatures,
    required String? policyId,
    required List<String> selectedRules,
    required String plateNumber1,
    required String plateNumber2,
    required String plateNumber3,
    required String minRentalDays,
    required String insurance,
    required bool hasAgeRestriction,
    required String minAge,
    required bool allowsInternationalTravel,
    required List<XFile> imageFiles, // Fichiers images à uploader
    File? registrationCardFront, // Fichier recto à uploader
    File? registrationCardBack, // Fichier verso à uploader
    File? ministryAuthorization, // Fichier autorisation à uploader
  }) async {
    // Nettoyage de l'état UI AVANT d'envoyer la requête
    errorMessage.value = '';
    isLoading.value = true; // Assure-toi que c'est la seule variable de loader
    isSubmittingVehicle.value = true;
    
    try {
      showLoading();

      // Récupérer le token de manière sécurisée (sans modification)
      final String? authToken = await _getSecureToken();
      
      if (authToken == null || authToken.isEmpty) {
        closeLoading();
        showErrorToastMessage('Token d\'authentification manquant');
        _handleTokenError('Token manquant', shouldRedirect: true);
        return false;
      }

      // ========== ÉTAPE 1 : UPLOAD DES IMAGES ==========
      debugPrint('📤 [VEHICLE] Étape 1 : Upload des images...');
      List<String> imageUrls = [];
      if (imageFiles.isNotEmpty) {
        imageUrls = await uploadVehicleImages(imageFiles);
        // Ne passer à l'étape suivante que si l'upload a réussi (liste non vide)
        if (imageUrls.isEmpty) {
          closeLoading();
          showErrorToastMessage('Erreur lors de l\'upload des images. Veuillez réessayer.');
          return false;
        }
        debugPrint('✅ [VEHICLE] Étape 1 réussie : ${imageUrls.length} image(s) uploadée(s)');
      } else {
        closeLoading();
        showErrorToastMessage('Au moins une image est requise');
        return false;
      }

      // ========== ÉTAPE 2 : UPLOAD DES DOCUMENTS ==========
      debugPrint('📤 [VEHICLE] Étape 2 : Upload des documents...');
      final Map<String, String?> documentUrls = await uploadDocuments(
        registrationCardFront: registrationCardFront,
        registrationCardBack: registrationCardBack,
        ministryAuthorization: ministryAuthorization,
      );
      
      // Vérifier qu'au moins un document a été uploadé avec succès (optionnel mais vérifier la structure)
      final bool hasAtLeastOneDocument = documentUrls['registrationCardFront'] != null ||
                                        documentUrls['registrationCardBack'] != null ||
                                        documentUrls['ministryAuthorization'] != null;
      
      debugPrint('✅ [VEHICLE] Étape 2 terminée : Documents uploadés: $documentUrls');

      // ========== ÉTAPE 3 : CRÉATION DU VÉHICULE (JSON PUR) ==========
      debugPrint('📤 [VEHICLE] Étape 3 : Création du véhicule...');

      // Construire le payload JSON selon le modèle Mongoose IVehicle documenté
      // Structure exacte requise selon la documentation backend

      // ========== SPECS (uniquement les champs autorisés) ==========
      final Map<String, dynamic> specs = {};
      
      // Validation : brand doit être un ObjectId valide (pas "0" ou vide)
      if (brandId != null && brandId.isNotEmpty && brandId != "0") {
        specs['brand'] = brandId;
      }
      
      // IMPORTANT: model et fuel sont OBLIGATOIRES et doivent être des ObjectIds valides
      // Le backend exige qu'ils soient présents et non null dans l'objet specs
      // Nettoyage et validation de modelId
      final String? cleanModelId = modelId?.trim();
      if (cleanModelId != null && 
          cleanModelId.isNotEmpty && 
          cleanModelId != "0" && 
          cleanModelId.toLowerCase() != "null" &&
          cleanModelId.length >= 24) { // ObjectId MongoDB fait 24 caractères hex
        specs['model'] = cleanModelId;
        debugPrint('✅ [VEHICLE] model ajouté à specs: $cleanModelId');
      } else {
        // Si modelId est invalide, on ne peut pas continuer car le backend l'exige
        showErrorToastMessage('Le modèle du véhicule est requis et doit être valide');
        debugPrint('❌ [VEHICLE] modelId invalide ou manquant: $modelId (nettoyé: $cleanModelId)');
        return false;
      }
      
      // Nettoyage et validation de fuelId
      final String? cleanFuelId = fuelId?.trim();
      if (cleanFuelId != null && 
          cleanFuelId.isNotEmpty && 
          cleanFuelId != "0" && 
          cleanFuelId.toLowerCase() != "null" &&
          cleanFuelId.length >= 24) { // ObjectId MongoDB fait 24 caractères hex
        specs['fuel'] = cleanFuelId;
        debugPrint('✅ [VEHICLE] fuel ajouté à specs: $cleanFuelId');
      } else {
        // Si fuelId est invalide, on ne peut pas continuer car le backend l'exige
        showErrorToastMessage('Le type de carburant est requis et doit être valide');
        debugPrint('❌ [VEHICLE] fuelId invalide ou manquant: $fuelId (nettoyé: $cleanFuelId)');
        return false;
      }
      
      specs['transmission'] = transmission.toUpperCase();
      if (odometerId != null && odometerId.isNotEmpty && odometerId != "0") {
        specs['odometer'] = odometerId;
      }
      specs['year'] = year;
      specs['seats'] = seats;

      // ========== PRICING (structure exacte avec objets imbriqués) ==========
      final Map<String, dynamic> pricing = {
        'basePrice': basePrice.toDouble(), // Force en double
        'currency': currency.toUpperCase(),
        'deposit': {
          'value': deposit.toDouble(), // Force en double
          'managedBy': 'AGENCY', // La gestion de la caution est toujours gérée par l'agence
        },
      };
      
      if (hasWeeklyDiscount) {
        // IMPORTANT : Convertir "percent" en "PERCENTAGE" et "fixed" en "FIXED"
        String discountType = weeklyDiscountType.toLowerCase();
        if (discountType == 'percent') {
          discountType = 'PERCENTAGE';
        } else if (discountType == 'fixed') {
          discountType = 'FIXED';
        } else {
          discountType = weeklyDiscountType.toUpperCase();
        }
        
        pricing['weeklyDiscount'] = {
          'value': weeklyDiscountValue.toDouble(), // Force en double
          'type': discountType, // PERCENTAGE ou FIXED en majuscules
        };
      }
      
      if (hasMonthlyDiscount) {
        // IMPORTANT : Convertir "percent" en "PERCENTAGE" et "fixed" en "FIXED"
        String discountType = monthlyDiscountType.toLowerCase();
        if (discountType == 'percent') {
          discountType = 'PERCENTAGE';
        } else if (discountType == 'fixed') {
          discountType = 'FIXED';
        } else {
          discountType = monthlyDiscountType.toUpperCase();
        }
        
        pricing['monthlyDiscount'] = {
          'value': monthlyDiscountValue.toDouble(), // Force en double
          'type': discountType, // PERCENTAGE ou FIXED en majuscules
        };
      }
      
      if (hasHomeDelivery) {
        pricing['homeDeliveryPrice'] = deliveryPrice.toDouble(); // Force en double
      }

      // ========== LOCATION (structure GeoJSON) ==========
      final Map<String, dynamic> location = {
        'type': 'Point',
        'coordinates': [longitude.toDouble(), latitude.toDouble()], // IMPORTANT: [longitude, latitude] (doubles)
        'address': fullAddress,
      };
      if (city != null && city.isNotEmpty) {
        location['city'] = city;
      }

      // ========== FEATURES (tableau d'ObjectIds) ==========
      final List<String> features = selectedFeatures.where((id) => id.isNotEmpty && id != "0").toList();

      // ========== RULES (tableau d'ObjectIds au niveau racine) ==========
      final List<String> rules = selectedRules.where((id) => id.isNotEmpty && id != "0").toList();

      // ========== CANCELLATION POLICIES (structure exacte avec ObjectId réel) ==========
      final List<Map<String, dynamic>> cancellationPolicies = [];
      if (policyId != null && policyId.isNotEmpty && policyId != "0") {
        // IMPORTANT: policyId peut être 'non-refundable' ou 'flexible' (string)
        // Il faut trouver l'ObjectId réel dans policiesList
        String? realPolicyObjectId;
        
        // Chercher la politique correspondante dans policiesList
        for (var policy in policiesList) {
          if (policy is Map<String, dynamic>) {
            final policyIdValue = policy['id']?.toString() ?? policy['_id']?.toString();
            final policyName = policy['name']?.toString().toLowerCase() ?? '';
            final policyType = policy['type']?.toString().toLowerCase() ?? '';
            
            // Vérifier si cette politique correspond à policyId
            if (policyId == 'non-refundable' || policyId == 'nonremboursable') {
              if (policyName.contains('non') || policyName.contains('remboursable') || 
                  policyType == 'non-refundable' || policyType == 'nonremboursable') {
                realPolicyObjectId = policyIdValue;
                break;
              }
            } else if (policyId == 'flexible') {
              if (policyName.contains('flexible') || policyType == 'flexible') {
                realPolicyObjectId = policyIdValue;
                break;
              }
            } else {
              // Si policyId est déjà un ObjectId (format MongoDB), l'utiliser directement
              if (policyIdValue == policyId || policyId.length == 24) {
                realPolicyObjectId = policyId;
                break;
              }
            }
          }
        }
        
        // Si on n'a pas trouvé, mais que policyId ressemble à un ObjectId (24 caractères hex), l'utiliser
        if (realPolicyObjectId == null && policyId.length == 24) {
          realPolicyObjectId = policyId;
        }
        
        // Ajouter la politique seulement si on a un ObjectId valide
        if (realPolicyObjectId != null && realPolicyObjectId.isNotEmpty) {
          cancellationPolicies.add({
            'policy': realPolicyObjectId, // ObjectId réel, pas 'non-refundable' ou 'flexible'
            'percentage': 0, // Par défaut, peut être ajusté si nécessaire
          });
          debugPrint('✅ [VEHICLE] Politique d\'annulation ajoutée avec ObjectId: $realPolicyObjectId');
        } else {
          debugPrint('⚠️ [VEHICLE] Impossible de trouver l\'ObjectId pour la politique: $policyId');
        }
      }

      // ========== AGE RESTRICTION (structure exacte) ==========
      final Map<String, dynamic> ageRestriction = {
        'enabled': hasAgeRestriction,
        'minimumAge': hasAgeRestriction ? (int.tryParse(minAge) ?? 18) : 18,
      };

      // ========== PAYLOAD FINAL (structure exacte selon documentation) ==========
      final Map<String, dynamic> payload = {
        'type': 'CAR', // Type de véhicule (peut être ajusté selon les besoins)
        'category': 'SUV', // Catégorie (peut être ajusté selon les besoins)
        'vehicleType': vehicleTypeId, // ObjectId au niveau racine
        'specs': specs,
        'pricing': pricing,
        'location': location,
        'features': features,
        'rules': rules,
        'images': imageUrls, // Tableau de strings (URLs)
        'cancellationPolicies': cancellationPolicies,
        'minRentalDays': int.tryParse(minRentalDays) ?? 1,
        // Nettoyage de la plaque d'immatriculation : remplacer les barres | par des tirets -
        'licencePlateNumber': _cleanPlateNumber(plateNumber1, plateNumber2, plateNumber3), // Au niveau racine
        'insuranceCoverage': insurance.toUpperCase(), // Au niveau racine (pas insurance)
        'ageRestriction': ageRestriction,
        'smokingAllowed': false, // Par défaut (peut être ajusté si nécessaire)
        'internationalTravelAllowed': allowsInternationalTravel,
        'isActive': false, // Par défaut, le véhicule n'est pas actif à la création
      };

      // Ajouter les URLs des documents directement dans le payload (au niveau racine)
      if (documentUrls['registrationCardFront'] != null && documentUrls['registrationCardFront']!.isNotEmpty) {
        payload['registrationCardFront'] = documentUrls['registrationCardFront'];
      }
      if (documentUrls['registrationCardBack'] != null && documentUrls['registrationCardBack']!.isNotEmpty) {
        payload['registrationCardBack'] = documentUrls['registrationCardBack'];
      }
      if (documentUrls['ministryAuthorization'] != null && documentUrls['ministryAuthorization']!.isNotEmpty) {
        payload['ministryAuthorization'] = documentUrls['ministryAuthorization'];
      }

      // Construire l'URL
      final String baseUrl = Config.baseUrlWithoutV1;
      final String url = '${baseUrl}${Config.submitVehicle}';

      // Créer une instance Dio
      final dio.Dio dioInstance = dio.Dio();

      // Headers avec Bearer Token et Content-Type: application/json
      // IMPORTANT : Le token doit être envoyé tel quel, sans modification (pas de trim, etc.)
      final String bearerHeader = 'Bearer $authToken';
      debugPrint('🔑 [VEHICLE] Authorization header (submit): ${bearerHeader.length > 30 ? "${bearerHeader.substring(0, 30)}..." : bearerHeader}');
      
      final dio.Options options = dio.Options(
        headers: {
          'Authorization': bearerHeader, // Token envoyé tel quel, sans modification
          'Content-Type': 'application/json',
        },
      );

      // Envoyer la requête POST avec JSON pur
      debugPrint('📤 [VEHICLE] Envoi du payload JSON: ${jsonEncode(payload)}');
      final dio.Response response = await dioInstance.post(
        url,
        data: payload,
        options: options,
      );

      closeLoading();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          if (responseData['success'] == true || responseData['status'] == 200 || response.statusCode == 201) {
            // --- NOUVEAU FLUX : RESTER SUR LA PAGE ---
            
            // 1. Arrêter immédiatement tous les loaders
            isLoading.value = false;
            isSubmittingVehicle.value = false;
            isSuccess.value = true;
            update();
            
            // 2. BOUTON NUCLÉAIRE : Ferme TOUS les dialogues, overlays et snackbars ouverts
            closeLoading();
            Get.closeAllSnackbars(); // Fermer tous les snackbars GetX
            // Fermer tous les toasts BotToast
            try {
              BotToast.closeAllLoading();
              BotToast.cleanAll();
            } catch (e) {
              // Ignorer si BotToast n'est pas disponible
            }
            while (Get.isOverlaysOpen) {
              Get.back();
            }
            
            // 3. Vider le formulaire immédiatement
              clearFormFields();
              
            // 4. Rafraîchir les données en silence
            await fetchMyVehicles();
            
            // 5. Attendre un court instant pour s'assurer que tout est nettoyé
            await Future.delayed(const Duration(milliseconds: 100));
            
            // 6. Afficher un Toast avec le nombre de véhicules
              final vehicleCount = myVehiclesItems.length;
              showToastMessage('Véhicule n°$vehicleCount ajouté avec succès !');
              
              // Reset pour le prochain ajout
              isSuccess.value = false;
            update();
            
            return true; // IMPORTANT: return ici pour éviter d'exécuter le bloc suivant
          } else {
            isLoading.value = false;
            isSubmittingVehicle.value = false;
            update();
            showErrorToastMessage(responseData['message'] ?? 'Échec de l\'ajout du véhicule');
            return false;
          }
        }
        // Si pas de structure de réponse mais status 201, considérer comme succès
        if (response.statusCode == 201) {
          // --- NOUVEAU FLUX : RESTER SUR LA PAGE ---
          
          // 1. Arrêter immédiatement tous les loaders
          isLoading.value = false;
          isSubmittingVehicle.value = false;
          isSuccess.value = true;
          update();
          
          // 2. BOUTON NUCLÉAIRE : Ferme TOUS les dialogues, overlays et snackbars ouverts
          closeLoading();
          Get.closeAllSnackbars(); // Fermer tous les snackbars GetX
          // Fermer tous les toasts BotToast
          try {
            BotToast.closeAllLoading();
            BotToast.cleanAll();
          } catch (e) {
            // Ignorer si BotToast n'est pas disponible
          }
          while (Get.isOverlaysOpen) {
            Get.back();
          }
          
          // 3. Vider le formulaire immédiatement
            clearFormFields();
            
          // 4. Rafraîchir les données en silence
          await fetchMyVehicles();
          
          // 5. Attendre un court instant pour s'assurer que tout est nettoyé
          await Future.delayed(const Duration(milliseconds: 100));
          
          // 6. Afficher un Toast avec le nombre de véhicules
            final vehicleCount = myVehiclesItems.length;
            showToastMessage('Véhicule n°$vehicleCount ajouté avec succès !');
            
            // Reset pour le prochain ajout
            isSuccess.value = false;
          update();
          
          return true;
        }
        isLoading.value = false;
        isSubmittingVehicle.value = false;
        update();
        showToastMessage('Véhicule ajouté avec succès');
        return true;
      } else {
        isLoading.value = false;
        isSubmittingVehicle.value = false;
        update();
        showErrorToastMessage('Erreur lors de l\'ajout du véhicule: ${response.statusMessage}');
        return false;
      }
    } on dio.DioException catch (e) {
      closeLoading();
      isLoading.value = false;
      isSubmittingVehicle.value = false; // Libérer l'écran en cas d'erreur
      update();
      String errorMessage = 'Erreur réseau ou serveur: ${e.message}';
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString() ?? errorMessage;
          // Vérifier si c'est une erreur de token invalide
          final errorString = errorMessage.toLowerCase();
          if (errorString.contains('invalid signature') || 
              errorString.contains('invalid token') ||
              errorString.contains('unauthorized') ||
              e.response?.statusCode == 401) {
            _handleTokenError(errorMessage, shouldRedirect: true);
            return false;
          }
        }
      }
      showErrorToastMessage(errorMessage);
      debugPrint('❌ [VEHICLE] Erreur Dio lors de la soumission: $e');
      return false;
    } catch (e) {
      closeLoading();
      isLoading.value = false;
      isSubmittingVehicle.value = false; // Libérer l'écran en cas d'erreur
      update();
      _handleTokenError(e, shouldRedirect: false);
      showErrorToastMessage('Une erreur inattendue est survenue: $e');
      debugPrint('❌ [VEHICLE] Erreur inattendue lors de la soumission: $e');
      return false;
    }
  }

  // ========== MÉTHODES UTILITAIRES ==========

  /// Nettoie et fusionne les parties de la plaque d'immatriculation
  /// Remplace les barres | par des tirets - et supprime les espaces
  /// Exemple : "1 | A | 33" devient "1-A-33"
  String _cleanPlateNumber(String plate1, String plate2, String plate3) {
    // Nettoyer chaque partie : supprimer les espaces et remplacer les barres par des tirets
    String clean1 = plate1.trim().replaceAll('|', '-').replaceAll(' ', '');
    String clean2 = plate2.trim().replaceAll('|', '-').replaceAll(' ', '');
    String clean3 = plate3.trim().replaceAll('|', '-').replaceAll(' ', '');
    
    // Fusionner les trois parties avec des tirets
    final List<String> parts = [];
    if (clean1.isNotEmpty) parts.add(clean1);
    if (clean2.isNotEmpty) parts.add(clean2);
    if (clean3.isNotEmpty) parts.add(clean3);
    
    final String cleanedPlate = parts.join('-');
    debugPrint('🔧 [VEHICLE] Plaque nettoyée: "$plate1|$plate2|$plate3" -> "$cleanedPlate"');
    return cleanedPlate;
  }

  /// Nettoie les fichiers temporaires compressés après l'upload
  Future<void> _cleanupCompressedFilesPaths(List<String> filePaths) async {
    try {
      for (String filePath in filePaths) {
        try {
          final File file = File(filePath);
          if (await file.exists()) {
            await file.delete();
            debugPrint('🗑️ [VEHICLE] Fichier temporaire supprimé: $filePath');
          }
        } catch (e) {
          debugPrint('⚠️ [VEHICLE] Impossible de supprimer le fichier temporaire: $filePath - $e');
        }
      }
    } catch (e) {
      debugPrint('⚠️ [VEHICLE] Erreur lors du nettoyage des fichiers temporaires: $e');
    }
  }

  /// Nettoie tous les fichiers temporaires de compression dans le répertoire temporaire
  /// Utilisé en cas d'erreur pour éviter d'encombrer le stockage
  Future<void> _cleanupAllTemporaryFiles() async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final List<FileSystemEntity> files = tempDir.listSync();
      
      // Supprimer les fichiers temporaires de compression (ceux qui commencent par 'vehicle_image_')
      for (var file in files) {
        if (file is File && path.basename(file.path).startsWith('vehicle_image_')) {
          try {
            await file.delete();
            debugPrint('🗑️ [VEHICLE] Fichier temporaire supprimé: ${file.path}');
          } catch (e) {
            debugPrint('⚠️ [VEHICLE] Impossible de supprimer le fichier temporaire: ${file.path}');
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ [VEHICLE] Erreur lors du nettoyage général des fichiers temporaires: $e');
    }
  }

  /// Réinitialise toutes les données du controller
  void reset() {
    makesList.clear();
    makeTypesList.clear();
    modelsList.clear();
    fuelTypesList.clear();
    odometerList.clear();
    uploadedImageUrls.clear();
    update();
  }

  @override
  void onClose() {
    reset();
    super.onClose();
  }
}
