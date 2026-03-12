import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/add_items_host_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/model/get_year_model.dart';
import 'package:carvy/model/make_model_vehicle.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import 'package:carvy/work_space.dart';

class VehicleTypeScreen extends StatefulWidget {
  final VoidCallback? onNextButtonPressed;
  final ScreenMode mode;
  const VehicleTypeScreen(
      {super.key, this.onNextButtonPressed, required this.mode});
  @override
  State<VehicleTypeScreen> createState() => _VehicleTypeScreenState();
}

class _VehicleTypeScreenState extends State<VehicleTypeScreen> {
  // or any default value from the list
  GetYearModel? yearListModel;
  void resetDependentFields() {
    setState(() {
      // Réinitialiser les valeurs sélectionnées
      addItemsHostController.selectedMake = null;
      addItemsHostController.selectedModel = null;
      
      // Vider les listes pour forcer le rechargement (comme en mode Ajout)
      addItemsHostController.listMakesType.clear();
      addItemsHostController.listModelType.clear();
      
      // Activer le loader pour indiquer le chargement
      addItemsHostController.isMakeModelonTap.value = true;
      addItemsHostController.update();
    });
  }

  final _formKey = GlobalKey<FormState>();
  AddItemsHostController addItemsHostController = Get.find();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      generateYearsList();
      if (widget.mode == ScreenMode.edit) {
        addItemsHostController.isMakeModelonTap.value = false;
      }
    });
    setState(() {});
  }

  /// Charge les modèles pour une marque via l'API séparée (identique à l'ajout)
  /// Utilise exactement la même API que l'écran d'ajout
  Future<void> filterModelTypes(String? selectedMake) async {
    if (selectedMake != null && selectedMake.isNotEmpty) {
      debugPrint('🔍 [FILTER_MODELS] Chargement des modèles pour la marque ID: $selectedMake');
      
      // Activer le loader pour indiquer le chargement
      addItemsHostController.isMakeModelonTap.value = true;
      addItemsHostController.update();
      
      try {
        // Appeler l'API séparée des modèles (identique à l'ajout)
        await addItemsHostController.getModelApi(selectedMake);
        
        debugPrint('✅ [FILTER_MODELS] ${addItemsHostController.listModelType.length} modèles chargés pour la marque $selectedMake');
        
        // Mettre à jour l'état local
        setState(() {
          isMakeSelected = true;
        });
      } catch (e) {
        debugPrint('❌ [FILTER_MODELS] Erreur lors du chargement des modèles: $e');
      } finally {
        // Désactiver le loader
        addItemsHostController.isMakeModelonTap.value = false;
        addItemsHostController.update();
      }
    } else {
      debugPrint('⚠️ [FILTER_MODELS] selectedMake est null ou vide');
      addItemsHostController.listModelType.clear();
      addItemsHostController.update();
    }
  }

List<int> generateYearsList() {
  int currentYear = DateTime.now().year;
  List<int> years = [];
  for (int i = currentYear; i >= currentYear - 5; i--) {
    years.add(i);
  }
  return years;
}
  bool isMakeSelected = false;
  bool cleardata = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: notifires.getbgcolor,
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(150),
            child: widget.mode == ScreenMode.add
                ? AppText(txt: "What kind of Vehicle are you \nlistings".tr)
                : const SizedBox()),
        body: Center(
          child: SingleChildScrollView(
            child: Obx(
              () => addItemsHostController.isMakeModel.value == true || 
                    addItemsHostController.isLoadingEdit.value == true
                  ? const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(child: CircularProgressIndicator()),
                      ],
                    )
                  : Column(
                      children: [
                        // lineContainer(),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 0),
                          child: GetBuilder<AddItemsHostController>(
                            builder: (controller) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LabelNames(labelname: "Vehicle Type".tr),
                                const SizedBox(height: 10),
                                CustomDropdownHost(
                                  mode: widget.mode,
                                  heading: "Choose Vehicle Type".tr,
                                  options: controller.vehicleListItemType,
                                  onSelected: (value) {
                                    controller.selectedVehicleType = value;
                                    
                                    // 1. Réinitialiser les champs dépendants (Make / Model + listes)
                                    resetDependentFields();
                                    
                                    // 2. Recharger TOUTES les marques et modèles, sans filtre,
                                    //    en réutilisant exactement la même API que l'écran d'ajout
                                    controller.getVehicleDataMakeModel();
                                    
                                    // 3. Forcer la mise à jour de l'UI
                                    controller.update();
                                  },
                                  checkmarkColor: getColorBasedOnActiveModuleid(),
                                  selectedEditInitialValue: controller.selectedVehicleType,
                                ),
                                // ),
                                const SizedBox(height: 10),
                                LabelNames(labelname: "Make".tr),
                                const SizedBox(
                                  height: 10,
                                ),

                                // GetBuilder + Obx pour forcer le rafraîchissement quand selectedMake change
                                GetBuilder<AddItemsHostController>(
                                  builder: (controller) => Obx(() => CustomDropdownHost(
                                    clearDataonVehgicletype: controller.isMakeModelonTap.value,
                                    mode: widget.mode,
                                    heading: "Choose Make Type".tr,
                                    options: controller.listMakesType,
                                    onSelected: (value) {
                                      debugPrint('🔄 [MAKE_SELECTED] Marque sélectionnée: $value');
                                      
                                      // 1. Assigner la nouvelle marque
                                      controller.selectedMake = value;
                                      
                                      // 2. Vider le modèle précédemment sélectionné (car il n'appartient plus à cette marque)
                                      controller.selectedModel = null;
                                      
                                      // 3. Vider la liste des modèles pour forcer le refresh
                                      controller.listModelType.clear();
                                      
                                      // 4. Charger les modèles via l'API séparée (identique à l'ajout)
                                      // Cette fonction utilise EXACTEMENT la même API que l'écran d'ajout
                                      if (value != null && value.isNotEmpty) {
                                        filterModelTypes(value);
                                      } else {
                                        debugPrint('⚠️ [MAKE_SELECTED] value est null ou vide, impossible de charger les modèles');
                                      }
                                      
                                      // 5. Forcer la mise à jour de l'UI du contrôleur
                                      controller.update();
                                    },
                                    checkmarkColor: getColorBasedOnActiveModuleid(),
                                    selectedEditInitialValue: controller.selectedMake,
                                  )),
                                ),

                                const SizedBox(height: 10),
                                LabelNames(labelname: "Model".tr),
                                const SizedBox(height: 10),

                                // GetBuilder + Obx pour forcer le rafraîchissement quand selectedModel change
                                GetBuilder<AddItemsHostController>(
                                  builder: (controller) => Obx(() => CustomDropdownHost(
                                    clearDataonVehgicletype: controller.isMakeModelonTap.value,
                                    mode: widget.mode,
                                    heading: "Choose Model Type".tr,
                                    options: (controller.selectedMake != null && controller.selectedMake!.isNotEmpty)
                                        ? (controller.listModelType) // Utiliser directement listModelType du contrôleur
                                        : [],
                                    onSelected: (value) {
                                      controller.selectedModel = value;
                                      controller.update();
                                    },
                                    checkmarkColor: getColorBasedOnActiveModuleid(),
                                    selectedEditInitialValue: controller.selectedModel,
                                  )),
                                ),

                                const SizedBox(height: 10),
                                LabelNames(labelname: "Year".tr),
                                const SizedBox(height: 10),
                                CustomDropdownHostYears(
                                  mode: widget.mode,
                                  heading: "Choose Year".tr,
                                  years: generateYearsList(),
                                  onSelected: (year) {
                                    controller.selectedVechicleYear = year;
                                  },
                                  checkmarkColor: getColorBasedOnActiveModuleid(),
                                  hintText: 'Select Year'.tr,
                                ),
                                const SizedBox(height: 10),
                                LabelNames(labelname: "Transmissions".tr),
                                const SizedBox(height: 10),
                                CustomDropdownHost2(
                                  mode: widget.mode,
                                  heading: "Choose transmission".tr,
                                  options: controller.listTransmission,
                                  onSelected: (value) {
                                    controller.selectTransmission = value;
                                  },
                                  checkmarkColor: getColorBasedOnActiveModuleid(),
                                ),
                                const SizedBox(height: 10),
                                LabelNames(labelname: "Odometer".tr),
                                const SizedBox(height: 10),
                                CustomDropdownHost(
                                  mode: widget.mode,
                                  heading: "Choose odometer".tr,
                                  options: controller.listSpeedOdometer,
                                  onSelected: (value) {
                                    controller.selectedOdometerId.value = value;
                                  },
                                  selectedEditInitialValue: controller.selectedOdometerId.value,
                                  checkmarkColor: getColorBasedOnActiveModuleid(),
                                ),
                                const SizedBox(height: 10),

                                LabelNames(labelname: 'Fuel Type'.tr),
                                const SizedBox(height: 10),
                                CustomDropdownHost(
                                  mode: widget.mode,
                                  heading: "Select Fuel Type".tr,
                                  options: controller.fuelTypeList,
                                  onSelected: (value) {
                                    controller.selectedFueltypeid.value = value;
                                  },
                                  selectedEditInitialValue: controller.selectedFueltypeid.value,
                                  checkmarkColor: getColorBasedOnActiveModuleid(),
                                ),

                                const SizedBox(height: 10),
                                LabelNames(labelname: 'Number of Seats'.tr),
                                const SizedBox(height: 10),
                                TextFieldRefs(
                                  onTap: () {
                                    controller.numerictype = true;
                                  },
                                  onChange: (c) {
                                    controller.cleanNumericInput(
                                        controller.seatcapicity, c!);
                                    return null;
                                  },
                                  textInputAction: TextInputAction.done,
                                  txt: 'Number of Seats'.tr,
                                  textEditingControllerCommon: controller.seatcapicity,
                                  inputType: TextInputType.name,
                                  inputAlignment: TextAlign.left,
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        bottomSheet: MediaQuery.of(context).viewInsets.bottom == 0
            ? null
            : addItemsHostController.numerictype && Platform.isIOS
                ? Row(
                    children: [
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          setState(() {
                            addItemsHostController.numerictype = false;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: getColorBasedOnActiveModuleid(),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              " DONE ".tr,
                              style: TextStyle(color: whiteColor),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
        bottomNavigationBar: BottomHosts(
          onTap: () {
            addItemsHostController.validateType(
              context: context,
              formKey: _formKey,
              mode: widget.mode,
              onNextButtonPressed: widget.onNextButtonPressed,
            );
          },
          txt: truncatetext("Next".tr, 9),
          backButtontxt: "Back".tr,
          backOnPressed: (() {
            Get.back();
          }),
        ));
  }
}
