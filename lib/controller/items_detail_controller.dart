import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:carvy/controller/booking_controller.dart';
import 'package:carvy/constants/app_constants.dart';
import 'package:carvy/controller/kyc_controller.dart';
import 'package:carvy/work_space.dart';
import '../api/config.dart';
import '../helper/http_service.dart';
import '../model/item_details_model.dart';
import '../model/vehicle_home_model.dart';

class ItemDetailsController extends GetxController implements GetxService {
  BookingController bookingController = Get.find();
  bool houseRuleLoading = false;
  bool cancellationLoading = false;
  bool isDescriptionExpanded = false;
  late GoogleMapController mapController;
  ItemDetailsModel? vehicleDetailModel;
  bool vehicleCarRules = false;
  bool vehiclecancellationLoading = false;
  bool vehicleisDescriptionExpanded = false;
  var isLoadingVehicle = true.obs;
  var isLoadingVehicleNotFound = true.obs;
  List vehicleimageList = [];
  ItemInfo? itemInfo;
  
  @override
  void onReady() {
    super.onReady();
    if (AppConstants.isKycEnabled) {
      final kycController = Get.find<KycController>();
      kycController.getKycDetails();
    }
  }
  Future getdataVehicle(id) async {
    // ========== INITIALIZATION ==========
    debugPrint("🔍 getdataVehicle() - Called with id: $id");
    itemInfoDetails.clear();
    vehicleimageList.clear();
    isLoadingVehicle.value = true;
    isLoadingVehicleNotFound.value = false;
    update();

    try {
      // ========== API CALL ==========
      // 1. Log URL complète utilisée AVANT l'appel
      final fullUrl = "${Config.baseurl}${Config.getItemDetails}";
      debugPrint("🚀 APPEL VERS : ${Config.baseurl}${Config.getItemDetails}");
      debugPrint("🔍 [DEBUG] URL complète: $fullUrl");
      debugPrint("🔍 [DEBUG] Request Body: ${json.encode({"item_id": "$id"})}");
      
      // 2. Log de connexion avant l'appel API
      debugPrint("🚀 [FLUTTER] Tentative de connexion vers : ${Config.baseurl}${Config.getItemDetails}");
      debugPrint("🚀 [FLUTTER] Base URL configurée : ${Config.baseurl}");
      debugPrint("🚀 [FLUTTER] Endpoint : ${Config.getItemDetails}");
      
      // 3. Appel API réel (PAS de données mockées, PAS de données de secours)
      var response = await httpPost(Config.getItemDetails, {"item_id": "$id"});
      
      // 3. Log réponse brute complète (JSON Body)
      debugPrint("📦 [DEBUG] JSON Body: ${json.encode(response)}");
      debugPrint("🔍 [DEBUG] Response status: ${response['status']}");
      
      // ========== SUCCESS HANDLING (Status 200) ==========
      if (response['status'] == 200) {
        debugPrint("✅ getdataVehicle() - Response status is 200, parsing ItemDetailsModel");
        
        try {
          // Parse la réponse JSON de l'API (pas de données hardcodées)
          vehicleDetailModel = ItemDetailsModel.fromJson(response);
          debugPrint("✅ getdataVehicle() - ItemDetailsModel parsed successfully");
          
          // Log cancellation_reason depuis la réponse brute pour vérification
          if (response['data'] != null && response['data']['ItemDetails'] != null) {
            final rawCancellationReason = response['data']['ItemDetails']['cancellation_reason'];
            debugPrint("🔍 [DEBUG] cancellation_reason from raw JSON: $rawCancellationReason");
            debugPrint("🔍 [DEBUG] cancellation_reason type: ${rawCancellationReason.runtimeType}");
            debugPrint("🔍 [DEBUG] cancellation_reason is null? ${rawCancellationReason == null}");
            debugPrint("🔍 [DEBUG] cancellation_reason is empty string? ${rawCancellationReason == ''}");
            
            // ========== DEBUG VEHICLE RULES ==========
            final rawVehicleRules = response['data']['ItemDetails']['vehicle_rules'];
            debugPrint("🔍 [DEBUG RULES] Raw vehicle_rules from API: $rawVehicleRules");
            debugPrint("🔍 [DEBUG RULES] vehicle_rules type: ${rawVehicleRules.runtimeType}");
            debugPrint("🔍 [DEBUG RULES] vehicle_rules is null? ${rawVehicleRules == null}");
            
            if (rawVehicleRules != null) {
              if (rawVehicleRules is List) {
                debugPrint("🔍 [DEBUG RULES] vehicle_rules is a List with ${rawVehicleRules.length} items");
                if (rawVehicleRules.isNotEmpty) {
                  debugPrint("🔍 [DEBUG RULES] First rule: ${rawVehicleRules[0]}");
                  debugPrint("🔍 [DEBUG RULES] First rule type: ${rawVehicleRules[0].runtimeType}");
                  if (rawVehicleRules[0] is Map) {
                    debugPrint("🔍 [DEBUG RULES] First rule keys: ${(rawVehicleRules[0] as Map).keys.toList()}");
                  }
                } else {
                  debugPrint("⚠️ [DEBUG RULES] vehicle_rules array is EMPTY!");
                }
              } else {
                debugPrint("⚠️ [DEBUG RULES] vehicle_rules is NOT a List! Type: ${rawVehicleRules.runtimeType}");
              }
            } else {
              debugPrint("⚠️ [DEBUG RULES] vehicle_rules is NULL or missing in API response!");
            }
            // ========== END DEBUG VEHICLE RULES ==========
          }
          
          // Vérification et log de cancellationReason après parsing
          final parsedCancellationReason = vehicleDetailModel?.data?.itemDetails?.cancellationReason;
          debugPrint("🧐 [DEBUG] Parsed cancellationReason: $parsedCancellationReason");
          debugPrint("🧐 [DEBUG] Parsed cancellationReason type: ${parsedCancellationReason.runtimeType}");
          debugPrint("🧐 [DEBUG] Est-ce null? ${parsedCancellationReason == null}");
          
          if (parsedCancellationReason != null) {
            debugPrint("🧐 [DEBUG] Est-ce une chaîne vide? ${parsedCancellationReason.toString().isEmpty}");
            debugPrint("🧐 [DEBUG] String representation: '${parsedCancellationReason.toString()}'");
            debugPrint("🧐 [DEBUG] String length: ${parsedCancellationReason.toString().length}");
          } else {
            debugPrint("🧐 [DEBUG] ⚠️ cancellationReason est NULL ou manquant dans la réponse API");
          }

              // Traitement des données parsées (uniquement depuis l'API)
              if (vehicleDetailModel?.data?.itemDetails != null) {
                final itemDetails = vehicleDetailModel!.data!.itemDetails!;

                // ========== DEBUG PARSED VEHICLE RULES ==========
                final parsedVehicleRules = itemDetails.vehicleRules;
                debugPrint("🧐 [DEBUG RULES] Parsed vehicleRules: $parsedVehicleRules");
                debugPrint("🧐 [DEBUG RULES] Parsed vehicleRules type: ${parsedVehicleRules.runtimeType}");
                debugPrint("🧐 [DEBUG RULES] Parsed vehicleRules is null? ${parsedVehicleRules == null}");
                if (parsedVehicleRules != null) {
                  debugPrint("🧐 [DEBUG RULES] Parsed vehicleRules length: ${parsedVehicleRules.length}");
                  if (parsedVehicleRules.isNotEmpty) {
                    debugPrint("🧐 [DEBUG RULES] First parsed rule: '${parsedVehicleRules[0]}'");
                  } else {
                    debugPrint("⚠️ [DEBUG RULES] Parsed vehicleRules array is EMPTY!");
                  }
                } else {
                  debugPrint("⚠️ [DEBUG RULES] Parsed vehicleRules is NULL!");
                }
                // ========== END DEBUG PARSED VEHICLE RULES ==========

                // Récupération des images de la galerie
                vehicleimageList.addAll(itemDetails.galleryImageUrls ?? []);

                // Ajout de l'image principale en premier
                if (itemDetails.frontImageUrl != null && itemDetails.frontImageUrl!.isNotEmpty) {
                  vehicleimageList.insert(0, itemDetails.frontImageUrl!);
                }

                // Décodage de itemInfo (JSON stringifié)
                String? itemInfoString = itemDetails.itemInfo;
                if (itemInfoString != null && itemInfoString.isNotEmpty) {
                  try {
                    // Récupérer la catégorie depuis response['data']['ItemDetails']['item_type']
                    final rootType = response['data']['ItemDetails']['item_type'];
                    
                    // Décoder le JSON item_info dans une variable Map<String, dynamic> itemData
                    Map<String, dynamic> itemData = json.decode(itemInfoString);
                    
                    // Forcer l'écrasement avant de créer ItemInfo
                    itemData['type'] = rootType;
                    
                    // Log de contrôle
                    print('✅ SUCCESS : Catégorie détectée (${rootType}) et injectée dans ItemInfo');
                    
                    // Passer ce itemData à ItemInfo.fromJson(itemData)
                    final parsedItemInfo = ItemInfo.fromJson(itemData);
                    
                    // Sécurité : Extraire cancellation_reason du JSON et l'assigner à cancellationReasonTitle si nécessaire
                    // Vérifier d'abord dans response['data']['ItemDetails'], puis dans itemData
                    final itemDetailsJson = response['data']?['ItemDetails'];
                    final cancellationReasonFromJson = itemDetailsJson?['cancellation_reason'] ?? 
                                                       itemDetailsJson?['cancellation_reason_title'] ?? 
                                                       itemData['cancellation_reason'] ?? 
                                                       itemData['cancellation_reason_title'];
                    
                    // S'assurer que cancellationReason est bien assigné
                    if (cancellationReasonFromJson != null) {
                      parsedItemInfo.cancellationReasonTitle = cancellationReasonFromJson.toString();
                      parsedItemInfo.cancellationReason = cancellationReasonFromJson;
                      debugPrint('✅ [FIX] cancellationReasonTitle assigné depuis JSON: ${parsedItemInfo.cancellationReasonTitle}');
                    } else if (parsedItemInfo.cancellationReasonTitle == null) {
                      // Fallback si toujours null
                      parsedItemInfo.cancellationReasonTitle = 'Politique standard';
                      debugPrint('⚠️ [FIX] cancellationReasonTitle était null, valeur par défaut assignée');
                    }
                    
                    // Récupérer cancellation_rules depuis ItemDetails et l'assigner à cancellationReasonDescription
                    final cancellationRules = itemDetails.cancellationRules ?? [];
                    if (cancellationRules.isNotEmpty) {
                      parsedItemInfo.cancellationReasonDescription = cancellationRules.map((rule) => rule.toString()).toList();
                      debugPrint('✅ [FIX] cancellationReasonDescription assigné depuis cancellation_rules: ${parsedItemInfo.cancellationReasonDescription?.length} règles');
                    } else if (parsedItemInfo.cancellationReasonDescription == null || parsedItemInfo.cancellationReasonDescription!.isEmpty) {
                      // Si cancellationReasonDescription est vide, créer une liste à partir du titre
                      if (parsedItemInfo.cancellationReasonTitle != null && parsedItemInfo.cancellationReasonTitle.toString().isNotEmpty) {
                        parsedItemInfo.cancellationReasonDescription = [parsedItemInfo.cancellationReasonTitle.toString()];
                        debugPrint('✅ [FIX] cancellationReasonDescription créé depuis cancellationReasonTitle');
                      }
                    }

                    // Injecter les champs de pricing/réduction exposés au niveau ItemDetails.
                    parsedItemInfo.weeklyDiscountValue =
                        itemDetails.weeklyDiscountValue;
                    parsedItemInfo.monthlyDiscountValue =
                        itemDetails.monthlyDiscountValue;
                    parsedItemInfo.hasDiscounts = itemDetails.hasDiscounts;
                    if (itemDetails.priceDetails != null) {
                      parsedItemInfo.priceDetails = ItemInfoPriceDetails(
                        originalDailyPrice:
                            itemDetails.priceDetails?.originalDailyPrice,
                        discountedDailyPriceWeekly: itemDetails
                            .priceDetails?.discountedDailyPriceWeekly,
                        discountedDailyPriceMonthly: itemDetails
                            .priceDetails?.discountedDailyPriceMonthly,
                      );
                    }
                    
                    // Mettre à jour itemInfo dans le controller (c'est cet objet qui sera transmis)
                    itemInfo = parsedItemInfo;
                    
                    // Stocker dans itemInfoDetails pour compatibilité
                    itemInfoDetails = itemData;
                    
                    debugPrint("✅ getdataVehicle() - itemInfo decoded successfully");
                    debugPrint("✅ [FIX] itemInfo.cancellationReasonTitle final: ${itemInfo?.cancellationReasonTitle}");
                    debugPrint("✅ [FIX] itemInfo.cancellationReason final: ${itemInfo?.cancellationReason}");
                    debugPrint("✅ [FIX] itemInfo object updated in controller");
                  } catch (e) {
                    debugPrint("❌ getdataVehicle() - Error decoding itemInfo JSON: $e");
                  }
                }
              }

          isLoadingVehicle.value = false;
          isLoadingVehicleNotFound.value = false;
          update();
          debugPrint("✅ getdataVehicle() - Successfully loaded vehicle details from API");
          
        } catch (e, stackTrace) {
          // Erreur de parsing - Afficher l'erreur mais NE PAS charger de données de secours
          debugPrint("❌ getdataVehicle() - ERROR parsing ItemDetailsModel: $e");
          debugPrint("❌ getdataVehicle() - Stack trace: $stackTrace");
          debugPrint("❌ ERREUR PARSING : $e");
          isLoadingVehicleNotFound.value = true;
          isLoadingVehicle.value = false;
          update();
          // Get.snackbar remplacé par log console pour éviter "No Overlay widget found"
          // Get.snackbar(
          //   "Erreur".tr,
          //   "Une erreur est survenue lors du chargement des détails du véhicule".tr,
          //   snackPosition: SnackPosition.BOTTOM,
          // );
        }
      } 
      // ========== ERROR HANDLING (Status != 200) ==========
      else {
        // Erreur API - Afficher l'erreur mais NE PAS charger de données de secours
        debugPrint("❌ getdataVehicle() - Response status is not 200: ${response['status']}");
        debugPrint("❌ getdataVehicle() - Error message: ${response['message'] ?? 'Unknown error'}");
        debugPrint("❌ ERREUR API - Status: ${response['status']}, Message: ${response['message'] ?? 'Unknown error'}");
        isLoadingVehicleNotFound.value = true;
        isLoadingVehicle.value = false;
        update();
        // Get.snackbar remplacé par log console pour éviter "No Overlay widget found"
        // Get.snackbar(
        //   "Erreur".tr,
        //   response['message']?.toString() ?? "Impossible de charger les détails du véhicule".tr,
        //   snackPosition: SnackPosition.BOTTOM,
        // );
      }
    } catch (e, stackTrace) {
      // Exception lors de l'appel API - NE PAS charger de données de secours
      debugPrint("❌ ERREUR CONNEXION : $e");
      debugPrint("❌ [FLUTTER] Erreur de connexion : $e");
      debugPrint("❌ getdataVehicle() - Exception during API call: $e");
      debugPrint("❌ getdataVehicle() - Stack trace: $stackTrace");
      debugPrint("❌ [FLUTTER] URL tentée : ${Config.baseurl}${Config.getItemDetails}");
      isLoadingVehicleNotFound.value = true;
      isLoadingVehicle.value = false;
      update();
      // Get.snackbar remplacé par log console pour éviter "No Overlay widget found"
      // Get.snackbar(
      //   "Erreur".tr,
      //   "Impossible de se connecter au serveur".tr,
      //   snackPosition: SnackPosition.BOTTOM,
      // );
    }
    
    debugPrint("🔍 getdataVehicle() - Function completed");
  }

  late GoogleMapController vehicleMapController;
  void vehicleOnMapCreated(GoogleMapController controller) {
    vehicleMapController = controller;
  }

  void vehicleZoomIn() {
    vehicleMapController.animateCamera(
      CameraUpdate.zoomIn(),
    );
  }

  void vehicleZoomOut() {
    vehicleMapController.animateCamera(
      CameraUpdate.zoomOut(),
    );
  }

  bool showMore = true;
  void vehicleDispose() {
    isLoadingVehicle.value = true;
  }

  bool isDescriptionExpandedVehicle = false;
}
