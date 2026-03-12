import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/standalone_edit_controller.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/work_space.dart';

/// Écran d'édition autonome - Clone propre de l'écran d'ajout
/// Tous les champs sur une seule page scrollable
class StandaloneEditVehicleScreen extends StatelessWidget {
  final String vehicleId;

  const StandaloneEditVehicleScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  Widget build(BuildContext context) {
    // Initialiser le contrôleur
    final controller = Get.put(StandaloneEditController());
    
    // Charger les données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initEdit(vehicleId);
    });

    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      appBar: AppBar(
        backgroundColor: notifires.getbgcolor,
        surfaceTintColor: notifires.getbgcolor,
        title: Text('Modifier le véhicule'.tr, style: heading1Grey1(context)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: notifires.getwhiteblackcolor),
          onPressed: () => Get.back(),
        ),
      ),
      body: GetBuilder<StandaloneEditController>(
        builder: (controller) {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ========== TITRE ==========
                LabelNames(labelname: 'Titre'.tr),
                const SizedBox(height: 10),
                TextFieldRefs(
                  txt: 'Titre du véhicule'.tr,
                  textEditingControllerCommon: controller.titleController,
                  inputType: TextInputType.text,
                  inputAlignment: TextAlign.left,
                ),
                const SizedBox(height: 20),

                // ========== TYPE DE VÉHICULE ==========
                LabelNames(labelname: 'Type de véhicule'.tr),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Choisir le type'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: notifires.getBoxColor,
                  ),
                  value: controller.typesList.any((e) => e.id.toString() == controller.selectedVehicleType)
                      ? controller.selectedVehicleType
                      : null,
                  items: controller.typesList.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id.toString(),
                      child: Text(item.name ?? ''),
                    );
                  }).toList(),
                  onChanged: (val) {
                    controller.selectedVehicleType = val;
                    controller.selectedMake = null;
                    controller.selectedModel = null;
                    controller.modelsList.clear();
                    controller.update();
                  },
                ),
                const SizedBox(height: 20),

                // ========== MARQUE ==========
                LabelNames(labelname: 'Marque'.tr),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Choisir la marque'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: notifires.getBoxColor,
                  ),
                  value: controller.makesList.any((e) => e.id.toString() == controller.selectedMake)
                      ? controller.selectedMake
                      : null,
                  items: controller.makesList.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id.toString(),
                      child: Text(item.name ?? ''),
                    );
                  }).toList(),
                  onChanged: (val) {
                    controller.selectedMake = val;
                    
                    // 1. Réinitialiser le modèle
                    controller.selectedModel = null;
                    controller.modelsList.clear();
                    
                    // 2. Déclencher l'API des modèles
                    if (val != null) {
                      controller.getModelApi(val);
                    }
                    
                    controller.update();
                  },
                ),
                const SizedBox(height: 20),

                // ========== MODÈLE ==========
                LabelNames(labelname: 'Modèle'.tr),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Choisir le modèle'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: notifires.getBoxColor,
                  ),
                  // SÉCURITÉ ABSOLUE : Si la valeur n'est pas dans la liste, on passe null.
                  value: (controller.selectedModel != null && controller.modelsList.any((e) => e.id.toString() == controller.selectedModel)) 
                      ? controller.selectedModel
                      : null,
                  items: controller.modelsList.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id.toString(),
                      child: Text(item.name ?? ''),
                    );
                  }).toList(),
                  onChanged: (val) {
                    controller.selectedModel = val;
                    controller.update();
                  },
                ),
                const SizedBox(height: 20),

                // ========== ANNÉE ==========
                LabelNames(labelname: 'Année'.tr),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Choisir l\'année'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: notifires.getBoxColor,
                  ),
                  // SÉCURITÉ ABSOLUE : Si la valeur n'est pas dans la liste, on passe null.
                  value: (controller.selectedYear != null && controller.yearsList.contains(controller.selectedYear)) 
                      ? controller.selectedYear 
                      : null,
                  items: controller.yearsList.map((String year) {
                    return DropdownMenuItem<String>(
                      value: year,
                      child: Text(year),
                    );
                  }).toList(),
                  onChanged: (val) {
                    controller.selectedYear = val;
                    controller.update();
                  },
                ),
                const SizedBox(height: 20),

                // ========== TRANSMISSION ==========
                LabelNames(labelname: 'Transmission'.tr),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Choisir la transmission'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: notifires.getBoxColor,
                  ),
                  value: controller.transmissionList.any((e) => e.option == controller.selectedTransmission)
                      ? controller.selectedTransmission
                      : null,
                  items: controller.transmissionList.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.option,
                      child: Text(item.option ?? ''),
                    );
                  }).toList(),
                  onChanged: (val) {
                    controller.selectedTransmission = val;
                    controller.update();
                  },
                ),
                const SizedBox(height: 20),

                // ========== ODOMÈTRE ==========
                LabelNames(labelname: 'Kilométrage'.tr),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Choisir le kilométrage'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: notifires.getBoxColor,
                  ),
                  value: controller.odometerList.any((e) => e.id.toString() == controller.selectedOdometer)
                      ? controller.selectedOdometer
                      : null,
                  items: controller.odometerList.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id.toString(),
                      child: Text(item.name ?? ''),
                    );
                  }).toList(),
                  onChanged: (val) {
                    controller.selectedOdometer = val;
                    controller.update();
                  },
                ),
                const SizedBox(height: 20),

                // ========== TYPE DE CARBURANT ==========
                LabelNames(labelname: 'Type de carburant'.tr),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Choisir le type de carburant'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: notifires.getBoxColor,
                  ),
                  value: controller.fuelTypeList.any((e) => e.id.toString() == controller.selectedFuelType)
                      ? controller.selectedFuelType
                      : null,
                  items: controller.fuelTypeList.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id.toString(),
                      child: Text(item.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    controller.selectedFuelType = val;
                    controller.update();
                  },
                ),
                const SizedBox(height: 20),

                // ========== NOMBRE DE PLACES ==========
                LabelNames(labelname: 'Nombre de places'.tr),
                const SizedBox(height: 10),
                TextFieldRefs(
                  txt: 'Nombre de places'.tr,
                  textEditingControllerCommon: controller.seatCapacityController,
                  inputType: TextInputType.number,
                  inputAlignment: TextAlign.left,
                ),
                const SizedBox(height: 20),

                // ========== PRIX ==========
                LabelNames(labelname: 'Prix'.tr),
                const SizedBox(height: 10),
                TextFieldRefs(
                  txt: 'Prix par jour'.tr,
                  textEditingControllerCommon: controller.priceController,
                  inputType: TextInputType.number,
                  inputAlignment: TextAlign.left,
                ),
                const SizedBox(height: 20),

                // ========== RÉDUCTION HEBDOMADAIRE ==========
                LabelNames(labelname: 'Réduction hebdomadaire'.tr),
                const SizedBox(height: 10),
                TextFieldRefs(
                  txt: 'Réduction hebdomadaire (%)'.tr,
                  textEditingControllerCommon: controller.weeklyDiscountController,
                  inputType: TextInputType.number,
                  inputAlignment: TextAlign.left,
                ),
                const SizedBox(height: 20),

                // ========== RÉDUCTION MENSUELLE ==========
                LabelNames(labelname: 'Réduction mensuelle'.tr),
                const SizedBox(height: 10),
                TextFieldRefs(
                  txt: 'Réduction mensuelle (%)'.tr,
                  textEditingControllerCommon: controller.monthlyDiscountController,
                  inputType: TextInputType.number,
                  inputAlignment: TextAlign.left,
                ),
                const SizedBox(height: 20),

                // ========== ADRESSE ==========
                LabelNames(labelname: 'Adresse'.tr),
                const SizedBox(height: 10),
                TextFieldRefs(
                  txt: 'Adresse complète'.tr,
                  textEditingControllerCommon: controller.addressController,
                  inputType: TextInputType.streetAddress,
                  inputAlignment: TextAlign.left,
                ),
                const SizedBox(height: 20),

                // ========== VILLE ==========
                LabelNames(labelname: 'Ville'.tr),
                const SizedBox(height: 10),
                TextFieldRefs(
                  txt: 'Ville'.tr,
                  textEditingControllerCommon: controller.cityController,
                  inputType: TextInputType.text,
                  inputAlignment: TextAlign.left,
                ),
                const SizedBox(height: 20),

                // ========== RÉGION/ÉTAT ==========
                LabelNames(labelname: 'Région/État'.tr),
                const SizedBox(height: 10),
                TextFieldRefs(
                  txt: 'Région ou État'.tr,
                  textEditingControllerCommon: controller.stateController,
                  inputType: TextInputType.text,
                  inputAlignment: TextAlign.left,
                ),
                const SizedBox(height: 30),

                // ========== BOUTON SAUVEGARDER ==========
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            final success = await controller.updateVehicle();
                            if (success) {
                              Get.back();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vehicalThemColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Sauvegarder les modifications'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
