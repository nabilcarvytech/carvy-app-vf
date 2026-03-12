import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/add_items_host_controller.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/host/location_screen_host.dart';
import 'package:carvy/view/host/vehiclehost/addvehicle/vehicle_type_screen.dart';
import 'package:carvy/view/host/vehiclehost/addvehicle/vehicle_price_screen.dart';
import 'package:carvy/view/host/vehiclehost/addvehicle/vehicle_description.dart';
import 'package:carvy/view/host/vehiclehost/addvehicle/vehicle_rules_screen.dart';
import 'package:carvy/view/host/vehiclehost/addvehicle/vehicle_features_screen.dart';
import 'package:carvy/work_space.dart';

/// Écran d'édition avec onglets - Identique à l'écran d'ajout
/// Utilise exactement les mêmes écrans et le même design
class EditVehicleTabScreen extends StatefulWidget {
  final String vehicleId;

  const EditVehicleTabScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  State<EditVehicleTabScreen> createState() => _EditVehicleTabScreenState();
}

class _EditVehicleTabScreenState extends State<EditVehicleTabScreen>
    with SingleTickerProviderStateMixin {
  AddItemsHostController addItemsHostController = Get.find();

  List<Map<String, dynamic>> editboxProperties = [
    {'icon': Icons.home, 'title': 'Vehicle type'.tr},
    {'icon': Icons.star, 'title': 'Vehicle Description'.tr},
    {'icon': Icons.price_change, 'title': 'Price'.tr},
    {'icon': Icons.location_on, 'title': 'Location'.tr},
    {'icon': Icons.star_rate, 'title': 'Vehicle Features'.tr},
    {'icon': Icons.policy, 'title': 'Vehicle Policies'.tr},
  ];
  List<Map<String, dynamic>> heading = [
    {'title': 'What kind of Vehicle are you listings?'.tr},
    {'title': 'Vehicle Description'.tr},
    {'title': 'What will be expected price'.tr},
    {'title': "Where's your place located?".tr},
    {'title': "What features does your vehicle offer?".tr},
    {'title': "Rules and Policies".tr},
  ];

  TabController? _tabcontroller;
  int? index;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _tabcontroller =
        TabController(length: editboxProperties.length, vsync: this);
    _tabcontroller?.addListener(() {
      setState(() {
        index = _tabcontroller?.index;
      });
    });
    
    // Charger les données du véhicule au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVehicleData();
    });
  }

  /// Charge les données du véhicule et pré-remplit tous les champs
  Future<void> _loadVehicleData() async {
    try {
      setState(() {
        isLoading = true;
      });

      // 1. Charger toutes les API de référence
      addItemsHostController.getDataYourLocation();
      addItemsHostController.getDataAmenties();
      addItemsHostController.getRules();
      addItemsHostController.getCancellationPolicy();
      addItemsHostController.getDataOdometerList();
      addItemsHostController.getDataTransmission();
      addItemsHostController.getDatafuelType();
      addItemsHostController.getDataItemType();
      await addItemsHostController.getVehicleDataMakeModel();

      // 2. Récupérer les détails du véhicule
      var detailedVehicle = await addItemsHostController.fetchVehicleDetails(widget.vehicleId);

      if (detailedVehicle != null) {
        // Stocker le véhicule dans le contrôleur
        addItemsHostController.item = detailedVehicle;
        addItemsHostController.currentVehicleId = widget.vehicleId;

        // Pré-remplir tous les champs
        await addItemsHostController.populateFields(detailedVehicle);

        debugPrint('✅ [EDIT_TAB] Données du véhicule chargées avec succès');
      } else {
        Get.snackbar('Erreur', 'Impossible de charger les données du véhicule');
        Get.back();
      }
    } catch (e) {
      debugPrint('❌ [EDIT_TAB] Erreur lors du chargement: $e');
      Get.snackbar('Erreur', 'Erreur lors du chargement des données');
      Get.back();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void onBackButtonPressed() {
    if (_tabcontroller!.index > 0) {
      _tabcontroller!.animateTo(_tabcontroller!.index - 1);
    } else {
      Get.back();
    }
  }

  void onNextButtonPressed() {
    if (_tabcontroller!.index < _tabcontroller!.length - 1) {
      _tabcontroller!.animateTo(_tabcontroller!.index + 1);
    }
  }

  @override
  void dispose() {
    _tabcontroller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: notifires.getbgcolor,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: notifires.getbgcolor,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(185),
          child: AppBar(
            automaticallyImplyLeading: false,
            leading: backButton(),
            leadingWidth: 80,
            title: Text(
              "Edit Vehicle Detail".tr,
              style: heading2Grey1(context),
            ),
            backgroundColor: notifires.getbgcolor,
            surfaceTintColor: notifires.getAppBarcolor,
            flexibleSpace: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: TabBar(
                      overlayColor:
                          const WidgetStatePropertyAll(Colors.transparent),
                      dividerColor: Colors.transparent,
                      indicatorPadding: EdgeInsets.zero,
                      tabAlignment: TabAlignment.start,
                      isScrollable: true,
                      padding: const EdgeInsets.all(0),
                      controller: _tabcontroller,
                      indicator: null,
                      indicatorColor: Colors.transparent,
                      tabs: editboxProperties.asMap().entries.map((entry) {
                        int idx = entry.key;
                        Map<String, dynamic> item = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Container(
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: notifires.getboxcolor,
                                  borderRadius: BorderRadius.circular(30)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Container(
                                      height: 45,
                                      width: 45,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: _tabcontroller?.index == idx
                                              ? getColorBasedOnActiveModuleid()
                                                  .withOpacity(0.3)
                                              : grey5,
                                          borderRadius:
                                              BorderRadius.circular(25)),
                                      child: Icon(item['icon'],
                                          color: _tabcontroller?.index == idx
                                              ? getColorBasedOnActiveModuleid()
                                              : getColorBasedOnActiveModuleid()),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    item['title'],
                                    style: regular3(context).copyWith(
                                        fontSize: 14,
                                        color: notifires.getGrey2Whitecolor),
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10, top: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: heading.asMap().entries.map((entry) {
                        int idx = entry.key;
                        Map<String, dynamic> item = entry.value;
                        return _tabcontroller?.index == idx
                            ? Flexible(
                                child: Text(
                                  item['title'],
                                  style: heading2(context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                ),
                              )
                            : const Text("");
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          )),
      body: TabBarView(
        controller: _tabcontroller,
        children: [
          VehicleTypeScreen(
            onNextButtonPressed: onNextButtonPressed,
            mode: ScreenMode.edit,
          ),
          VehcileDescriptionScreen(
            mode: ScreenMode.edit,
            onNextButtonPressed: onNextButtonPressed,
            onBackButtonPressed: onBackButtonPressed,
          ),
          VehiclePriceScreen(
              mode: ScreenMode.edit,
              onNextButtonPressed: onNextButtonPressed,
              onBackButtonPressed: onBackButtonPressed),
          LocationScreenHost(
            onNextButtonPressed: onNextButtonPressed,
            mode: ScreenMode.edit,
            onBackButtonPressed: onBackButtonPressed,
          ),
          VehicleFeaturesScreen(
            onNextButtonPressed: onNextButtonPressed,
            mode: ScreenMode.edit,
            onBackButtonPressed: onBackButtonPressed,
          ),
          VehcileRulesScreen(
            onNextButtonPressed: onNextButtonPressed,
            mode: ScreenMode.edit,
            onBackButtonPressed: onBackButtonPressed,
          )
        ],
      ),
    );
  }
}
