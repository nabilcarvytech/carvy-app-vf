import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/controller/add_items_host_controller.dart';
import 'package:carvy/controller/home_controller.dart';
import 'package:carvy/customwidget/data_not_found.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/general_data_model.dart';
import 'package:carvy/model/my_items_model.dart';
import 'package:carvy/model/vehicle_home_model.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/host/bottom_bar_host.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import 'package:carvy/view/host/dash_board_screen.dart';
import 'package:carvy/view/host/vehiclehost/editvehicle/edit_vehicle_home_screen.dart';
import 'package:carvy/view/host/vehiclehost/editvehicle/clean_edit_vehicle_screen.dart';
import 'package:carvy/work_space.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../itemdetail/vehicle/vehicle_detail_screen.dart';
import 'package:carvy/controller/vehicle_controller.dart';

class HostSearchScreen extends StatefulWidget {
  final ScreenMode? mode;
  const HostSearchScreen({super.key, this.mode});
  @override
  State<HostSearchScreen> createState() => _HostSearchScreenState();
}

class _HostSearchScreenState extends State<HostSearchScreen> {
  final AddItemsHostController addItemsHostController = Get.find();
  final VehicleController vehicleController = Get.find<VehicleController>();
  bool showSuggestions = false;
  final FocusNode _focusNode = FocusNode();
  List<Map<String, String>> recentSearches = [];

  RefreshController refreshController = RefreshController();
  GeneralDataModel? generalDataModel;
  bool publicpost = false;
  getData(String? search) async {
    // Utiliser fetchMyVehicles() du VehicleController pour récupérer les véhicules réels
    await vehicleController.fetchMyVehicles();
    
    setState(() {});
    refreshController.loadComplete();
    refreshController.refreshCompleted();
  }
  
  // Liste filtrée pour la recherche
  List<Items> getFilteredItems(String? search) {
    if (search == null || search.isEmpty) {
      return vehicleController.myVehiclesItems;
    }
    
    final searchLower = search.toLowerCase();
    return vehicleController.myVehiclesItems.where((item) {
      final title = item.title?.toLowerCase() ?? '';
      final description = item.description?.toLowerCase() ?? '';
      // Extraire le matricule depuis itemInfo si disponible
      String? plateNumber = '';
      if (item.itemInfo != null) {
        try {
          final itemInfoMap = json.decode(item.itemInfo!);
          plateNumber = itemInfoMap['platNumber']?.toString().toLowerCase() ?? '';
        } catch (e) {
          // Ignorer les erreurs de parsing
        }
      }
      return title.contains(searchLower) || 
             description.contains(searchLower) || 
             (plateNumber ?? '').contains(searchLower);
    }).toList();
  }

  deleteMethod(int index) async {
    try {
      final vehicle = vehicleController.myVehicles[index];
      final vehicleId = vehicle['_id']?.toString() ?? vehicle['id']?.toString();
      
      if (vehicleId == null || vehicleId.isEmpty) {
        showErrorToastMessage('ID du véhicule introuvable');
        return;
      }
      
      // Appeler la nouvelle fonction deleteVehicleRequest du contrôleur
      await addItemsHostController.deleteVehicleRequest(vehicleId);
      
      // Rafraîchir la liste après la suppression
      onRefresh();
    } catch (e) {
      showErrorToastMessage('Erreur lors de la demande de suppression: $e');
    }
  }

  onLoading() {
    getData(generalScopeController.searchLead.text);
    setState(() {});
  }

  onRefresh() {
    vehicleController.myVehicles.clear();
    setState(() {});
    getData(generalScopeController.searchLead.text);
  }

  @override
  void initState() {
    super.initState();
    item = null;
    initialitems = null;
    // Charger les véhicules au démarrage
    getData("");
  }

  Timer? _debounce;
  @override
  void dispose() {
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  String _previousValue = '';

  void onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (value != _previousValue) {
      _debounce = Timer(const Duration(milliseconds: 1000), () {
        _previousValue = value;
        getData(value);
      });
    }
  }

  void resetSearch() {
    generalScopeController.searchLead.clear();
    getData("");
  }

  HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: Dimensions.containerWidth,
        child: Scaffold(
          backgroundColor: notifires.getbgcolor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            // titleSpacing: 10,
            centerTitle: true,
            backgroundColor: notifires.getbgcolor,
            elevation: 0,
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 38,
                child: TextFormField(
                  onChanged: (value) {
                    onSearchChanged(value);
                  },
                  focusNode: _focusNode,
                  style: regular2(context),
                  controller: generalScopeController.searchLead,
                  decoration: InputDecoration(
                    suffixIcon:
                        generalScopeController.searchLead.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear,
                                    color: notifires.getgreycolor),
                                onPressed: () {
                                  resetSearch();
                                  setState(() {});
                                },
                              )
                            : null,
                    filled: true,
                    fillColor: notifires.getboxcolor,
                    prefixIcon:
                        Icon(Icons.search, color: notifires.getgreycolor),
                    hintStyle: regular2(context),
                    contentPadding: const EdgeInsets.only(top: 0, bottom: 0),
                    hintText: "Search".tr,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: getColorBasedOnActiveModuleid(), width: 1)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: getColorBasedOnActiveModuleid(), width: 1)),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    generalController.currentIndexHost.value = 0;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BottomHost(
                                  initialIndex: 0,
                                )));

                    generalScopeController.searchLead.clear();
                  },
                  icon: Icon(
                    size: 28,
                    Icons.cancel_outlined,
                    color: notifires.getGrey3Whitecolor,
                  ))
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "My Posts".tr,
                    style: heading3Grey1(context),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SmartRefresher(
                    controller: refreshController,
                    onRefresh: onRefresh,
                    onLoading: onLoading,
                    enablePullUp: false,
                    child: Obx(() {
                      // Gestion du Loader : s'affiche uniquement si la liste est vide ET en chargement
                      final isLoading = vehicleController.isLoadingMyVehicles.value;
                      final hasVehicles = vehicleController.myVehiclesItems.isNotEmpty;
                      
                      // Si on charge ET qu'on n'a pas encore de véhicules, afficher le loader
                      if (isLoading && !hasVehicles) {
                        return verticleShimmerWidgetBookable();
                      }
                      
                      // SÉCURITÉ : Si on a des véhicules, forcer l'affichage de la liste
                      if (hasVehicles) {
                        // Utiliser la liste filtrée pour la recherche
                        final itemsList = getFilteredItems(generalScopeController.searchLead.text);
                        
                        if (itemsList.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 250),
                            child: Center(
                              child: buildNoDataWidget(
                                context,
                                "No product found".tr,
                              ),
                            ),
                          );
                        }
                        
                        return ListView(
                          children: [
                            GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                crossAxisSpacing: 8,
                                mainAxisExtent: 335,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: itemsList.length,
                              itemBuilder: (context, index) {
                                ItemInfo? itemInfoData;
                                String? jsonString = itemsList[index].itemInfo;
                                if (jsonString != null && jsonString.isNotEmpty) {
                                  try {
                                    final Map<String, dynamic> itemInfoJson = json.decode(jsonString);
                                    itemInfoData = ItemInfo.fromJson(itemInfoJson);
                                  } catch (e) {
                                    // Ignorer les erreurs de parsing
                                  }
                                }
                                
                                return VehicleItemCard(
                                  vehicle: itemsList[index],
                                  itemInfoData: itemInfoData,
                                  notifires: notifires,
                                  onTap: () {
                                    final vehicle = itemsList[index];
                                    final vehicleId = vehicle.id?.toString() ?? '';
                                    final vehicleTitle = vehicle.title;
                                    final vehicleRating = vehicle.itemRating ?? "0";
                                    final vehicleAddress = vehicle.address;
                                    final vehicleCity = vehicle.city;
                                    final vehicleLatitude = vehicle.latitude;
                                    final vehicleLongitude = vehicle.longitude;
                                    final vehicleImage = vehicle.frontImage?.thumbnail ?? vehicle.frontImage?.url;
                                    final vehiclePrice = vehicle.price;
                                    
                                    // Parser itemInfo si disponible
                                    ItemInfo? itemInfoData;
                                    String? jsonString = vehicle.itemInfo;
                                    if (jsonString != null && jsonString.isNotEmpty) {
                                      try {
                                        final Map<String, dynamic> itemInfoJson = json.decode(jsonString);
                                        itemInfoData = ItemInfo.fromJson(itemInfoJson);
                                      } catch (e) {
                                        // Ignorer les erreurs de parsing
                                      }
                                    }
                                    
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VehicleDetailSScreen(
                                          id: vehicleId,
                                          itemInfo: itemInfoData,
                                          title: vehicleTitle,
                                          rating: vehicleRating,
                                          address: vehicleAddress,
                                          city: vehicleCity,
                                          latitute: vehicleLatitude,
                                          longtitute: vehicleLongitude,
                                          frontImage: vehicleImage,
                                          itemType: vehicle.itemType,
                                          price: vehiclePrice,
                                          isWishList: false, // Items n'a pas isInWishlist
                                        ),
                                      ),
                                    );
                                  },
                                  onEdit: () async {
                                    // Afficher un loader pendant la récupération des détails
                                    showLoading();
                                    
                                    try {
                                      // Récupérer l'ID du véhicule - Utiliser item.id (MongoDB) et non un ID temporaire
                                      final vehicle = itemsList[index];
                                      
                                      // 🔍 DEBUG : Log de l'objet brut AVANT toute manipulation
                                      try {
                                        final vehicleJson = vehicle.toJson();
                                        debugPrint('📋 [OBJET_BRUT] JSON complet: ${vehicleJson.toString()}');
                                        debugPrint('📋 [OBJET_BRUT] Clés disponibles: ${vehicleJson.keys.toList()}');
                                      } catch (e) {
                                        debugPrint('❌ [OBJET_BRUT] Erreur lors de la conversion en JSON: $e');
                                      }
                                      
                                      // 🔍 DEBUG : Vérifier l'ID avant utilisation
                                      debugPrint('🔍 [DEBUG_EDIT] Véhicule sélectionné: ${vehicle.title ?? vehicle.id}');
                                      debugPrint('🔍 [DEBUG_EDIT] ID du véhicule (vehicle.id): ${vehicle.id}');
                                      debugPrint('🔍 [DEBUG_EDIT] Type de l\'ID: ${vehicle.id?.runtimeType}');
                                      debugPrint('🔍 [DEBUG_EDIT] Index dans la liste: $index');
                                      debugPrint('🔍 [DEBUG_EDIT] Taille de la liste: ${itemsList.length}');
                                      
                                      // Essayer plusieurs sources pour l'ID
                                      String? vehicleId = vehicle.id?.toString();
                                      
                                      // Si l'ID est null, vide, ou "null", essayer de récupérer depuis le JSON brut
                                      if (vehicleId == null || vehicleId.isEmpty || vehicleId == "null") {
                                        debugPrint('⚠️ [DEBUG_EDIT] ID null ou vide, tentative de récupération alternative...');
                                        // Tentative de récupération directe dans le map si le modèle a échoué
                                        try {
                                          final vehicleJson = vehicle.toJson();
                                          // Priorité: _id (MongoDB) > id (standard)
                                          vehicleId = vehicleJson['_id']?.toString() ?? 
                                                      vehicleJson['id']?.toString();
                                          
                                          // Si toujours null, essayer de chercher dans les clés avec différentes variantes
                                          if (vehicleId == null || vehicleId.isEmpty || vehicleId == "null") {
                                            debugPrint('⚠️ [DEBUG_EDIT] ID toujours null après toJson(), recherche dans toutes les clés...');
                                            for (var key in vehicleJson.keys) {
                                              if (key.toLowerCase().contains('id') && vehicleJson[key] != null) {
                                                final candidateId = vehicleJson[key].toString();
                                                if (candidateId.isNotEmpty && candidateId != "null" && candidateId.length >= 10) {
                                                  vehicleId = candidateId;
                                                  debugPrint('✅ [DEBUG_EDIT] ID trouvé dans la clé "$key": $vehicleId');
                                                  break;
                                                }
                                              }
                                            }
                                          }
                                          
                                          debugPrint('🔍 [DEBUG_EDIT] ID depuis toJson() (secours): $vehicleId');
                                        } catch (e) {
                                          debugPrint('❌ [DEBUG_EDIT] Erreur lors de la récupération depuis toJson(): $e');
                                        }
                                      }
                                      
                                      debugPrint('🔍 [DEBUG_EDIT] ID final utilisé: "$vehicleId"');
                                      
                                      // Vérifier si l'ID est valide (MongoDB ObjectId = 24 caractères, minimum 10)
                                      final bool hasValidId = vehicleId != null && 
                                                               vehicleId.isNotEmpty && 
                                                               vehicleId != 'null' && 
                                                               vehicleId != 'nu' && 
                                                               vehicleId.trim().isNotEmpty &&
                                                               vehicleId.length >= 10 &&
                                                               !vehicleId.contains('-A-') &&
                                                               !vehicleId.contains('temp') &&
                                                               !vehicleId.contains('mock');
                                      
                                      if (!hasValidId) {
                                        // ⚠️ ID manquant ou invalide : Afficher un message d'erreur
                                        debugPrint('⚠️ [WARNING] ID manquant ou invalide: "$vehicleId"');
                                        closeLoading();
                                        showErrorToastMessage('ID du véhicule invalide. Impossible de modifier ce véhicule.');
                                        return;
                                      }
                                      
                                      // ✅ ID valide : Récupérer les détails complets depuis le serveur
                                      debugPrint('✅ [DEBUG_EDIT] ID validé, récupération des détails...');
                                      
                                      // Récupérer les détails complets du véhicule depuis le serveur
                                      var detailedVehicle = await addItemsHostController.fetchVehicleDetails(vehicleId!);
                                      
                                      if (detailedVehicle != null) {
                                        // Stocker le véhicule détaillé
                                        addItemsHostController.item = detailedVehicle;
                                        
                                        // Remplir le formulaire avec les données détaillées
                                        await addItemsHostController.populateFields(detailedVehicle);
                                        
                                        closeLoading(); // Fermer le loader en cas de succès
                                        
                                        // Naviguer vers l'écran d'édition d'origine avec le même UI que l'ajout
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditVehicleHomeScreen(
                                              mode: ScreenMode.edit,
                                            ),
                                          ),
                                        ).then((value) {
                                          // Rafraîchir la liste après retour
                                          vehicleController.fetchMyVehicles();
                                          setState(() {});
                                        });
                                      } else {
                                        closeLoading();
                                        showErrorToastMessage('Impossible de charger les détails du véhicule pour édition.');
                                      }
                                      
                                      // ========== ANCIEN CODE (COMMENTÉ) ==========
                                      // Ancienne navigation vers CleanEditVehicleScreen (V2 temporaire)
                                      /*
                                      debugPrint('✅ [CLEAN_EDIT] Navigation vers CleanEditVehicleScreen avec ID: $vehicleId');
                                      closeLoading();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CleanEditVehicleScreen(
                                            vehicleId: vehicleId!,
                                          ),
                                        ),
                                      ).then((value) {
                                        vehicleController.fetchMyVehicles();
                                        setState(() {});
                                      });
                                      if (!hasValidId) {
                                        // ⚠️ ID manquant ou invalide : Utiliser les données locales directement
                                        debugPrint('⚠️ [WARNING] ID manquant, utilisation des données locales');
                                        debugPrint('⚠️ [WARNING] vehicleId: "$vehicleId"');
                                        
                                        // Stocker le véhicule local
                                        addItemsHostController.item = vehicle;
                                        
                                        // Remplir le formulaire avec les données locales (sans appel API)
                                        await addItemsHostController.populateFields(vehicle);
                                        
                                        closeLoading(); // Fermer le loader en cas de succès
                                        
                                        // Naviguer vers l'écran d'édition
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const EditVehicleHomeScreen(
                                              mode: ScreenMode.edit,
                                            ),
                                          ),
                                        ).then((value) {
                                          // Rafraîchir la liste après retour
                                          vehicleController.fetchMyVehicles();
                                          setState(() {});
                                        });
                                      } else {
                                        // ✅ ID valide : Récupérer les détails complets depuis le serveur
                                        debugPrint('✅ [DEBUG_EDIT] ID validé, récupération des détails...');
                                        
                                        // Récupérer les détails complets du véhicule depuis le serveur
                                        var detailedVehicle = await addItemsHostController.fetchVehicleDetails(vehicleId!);
                                        
                                        if (detailedVehicle != null) {
                                          // Stocker le véhicule détaillé
                                          addItemsHostController.item = detailedVehicle;
                                          
                                          // Remplir le formulaire avec les vraies données complètes
                                          await addItemsHostController.populateFields(detailedVehicle);
                                          
                                          closeLoading(); // Fermer le loader en cas de succès
                                          
                                          // Naviguer vers l'écran d'édition
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const EditVehicleHomeScreen(
                                                mode: ScreenMode.edit,
                                              ),
                                            ),
                                          ).then((value) {
                                            // Rafraîchir la liste après retour
                                            vehicleController.fetchMyVehicles();
                                            setState(() {});
                                          });
                                        } else {
                                          // Échec de l'API : Utiliser les données locales comme fallback
                                          debugPrint('⚠️ [WARNING] Échec de l\'API, utilisation des données locales');
                                          addItemsHostController.item = vehicle;
                                          await addItemsHostController.populateFields(vehicle);
                                          closeLoading();
                                          
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const EditVehicleHomeScreen(
                                                mode: ScreenMode.edit,
                                              ),
                                            ),
                                          ).then((value) {
                                            vehicleController.fetchMyVehicles();
                                            setState(() {});
                                          });
                                        }
                                      }
                                      */
                                      // ========== FIN ANCIEN CODE ==========
                                    } catch (e) {
                                      closeLoading(); // 4. CORRECTION DU LOADER : Fermer systématiquement en cas d'exception
                                      debugPrint('❌ [HOST_SEARCH] Erreur lors de la récupération des détails: $e');
                                      showErrorToastMessage('Erreur lors du chargement des détails');
                                    }
                                  },
                                  onDelete: () {
                                    deleteMethod(index);
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      }
                      
                      // Si on arrive ici, pas de véhicules et pas de chargement
                      return Padding(
                        padding: const EdgeInsets.only(top: 250),
                        child: Center(
                          child: buildNoDataWidget(
                            context,
                            "No product found".tr,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showDeleteDialog(BuildContext context, int index) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: notifires.getbgcolor,
          surfaceTintColor: notifires.getblackwhitecolor,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Icon(
                  Icons.error,
                  size: 75,
                  color: Colors.red,
                ),
                Text('Do you want to delete your items?'.tr,
                    textAlign: TextAlign.center,
                    style: smallHeadigAirBd.copyWith(
                        color: notifires.getwhiteblackcolor)),
              ],
            ),
          ),
          actions: <Widget>[
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                        onTap: () {},
                        child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                margin:
                                    const EdgeInsets.only(left: 8, right: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: getColorBasedOnActiveModuleid()),
                                    color: getColorBasedOnActiveModuleid(),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                    child: Text("Cancel".tr,
                                        style: normalAirBk.copyWith(
                                            color: Colors.white)))))),
                    InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          deleteMethod(index);
                        },
                        child: Container(
                            margin: const EdgeInsets.only(left: 8, right: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: getColorBasedOnActiveModuleid()),
                                color: getColorBasedOnActiveModuleid(),
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                                child: Text(
                              "Yes".tr,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )))),
                  ],
                ),
                const SizedBox(
                  height: 8,
                )
              ],
            )
          ],
        );
      },
    );
  }
}
