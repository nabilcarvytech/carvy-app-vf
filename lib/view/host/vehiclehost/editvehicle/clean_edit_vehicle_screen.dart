import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/clean_edit_vehicle_controller.dart';

class CleanEditVehicleScreen extends StatelessWidget {
  final String vehicleId;

  const CleanEditVehicleScreen({Key? key, required this.vehicleId}) : super(key: key);

  String? _getValidDropdownValue(List list, String? currentValue) {
    if (currentValue == null || list.isEmpty) return null;
    bool exists = list.any((item) {
      String? itemId = item['_id']?.toString() ?? item['id']?.toString();
      return itemId == currentValue;
    });
    return exists ? currentValue : null;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CleanEditVehicleController(vehicleId),
      builder: (controller) {
        if (controller.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (controller.errorMessage.isNotEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text("Erreur")),
            body: Center(child: Text(controller.errorMessage)),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text("Modifier le véhicule (V2)")),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Titre"),
                TextField(
                  controller: controller.titleController,
                  decoration: const InputDecoration(border: OutlineInputBorder())
                ),
                const SizedBox(height: 16),
                
                const Text("Prix"),
                TextField(
                  controller: controller.priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(border: OutlineInputBorder())
                ),
                const SizedBox(height: 16),
                
                const Text("Marque"),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  hint: const Text("Sélectionner une marque"),
                  value: _getValidDropdownValue(controller.brandsList, controller.selectedBrandId),
                  items: controller.brandsList.map((item) {
                    return DropdownMenuItem<String>(
                      value: item['_id']?.toString() ?? item['id']?.toString(),
                      child: Text(item['name']?.toString() ?? "Inconnu"),
                    );
                  }).toList(),
                  onChanged: (val) {
                    controller.selectedBrandId = val;
                    controller.update();
                  },
                ),
                
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => controller.saveChanges(),
                  child: const Center(child: Text("Sauvegarder")),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
