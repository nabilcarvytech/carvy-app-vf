import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/helper/http_service.dart';
import 'dart:convert';
import 'dart:developer' as developer;

class CleanEditVehicleController extends GetxController {
  final String vehicleId;
  CleanEditVehicleController(this.vehicleId);

  // VARIABLES 100% SÉCURISÉES (Aucun Nullable pour les listes, Aucun late)
  bool isLoading = true;
  String errorMessage = "";

  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();

  List brandsList = [];
  String? selectedBrandId;

  @override
  void onInit() {
    super.onInit();
    try {
      safeInit();
    } catch (e) {
      errorMessage = "Erreur d'initialisation : $e";
      isLoading = false;
      update();
    }
  }

  Future safeInit() async {
    await Future.wait([
      fetchVehicleData(),
      fetchBrands()
    ]);
    isLoading = false;
    update();
  }

  Future<void> fetchBrands() async {
    try {
      // Même endpoint et mêmes paramètres que dans l'écran d'ajout (getVehicleDataMakeModel)
      final response = await httpGet(Config.makeType, {});

      // Parsing ultra-sécurisé sans modèles stricts
      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        List<dynamic> dataList = [];

        if (data is List) {
          // Certains backends renvoient directement une liste dans "data"
          dataList = data;
        } else if (data is Map<String, dynamic>) {
          // Cas classique: { data: { makes: [...] } } ou { data: { brands: [...] } }
          final makes = data['makes'];
          final brands = data['brands'];

          if (makes is List) {
            dataList = makes;
          } else if (brands is List) {
            dataList = brands;
          }
        }

        brandsList = dataList;
      }
    } catch (e) {
      developer.log('Erreur fetchBrands: $e');
    }
    update();
  }

  Future fetchVehicleData() async {
    try {
      final response = await httpGet('${Config.getVehicleDetails}/$vehicleId', {});
      if (response != null && response['data'] != null && response['data']['items'] != null) {
        List items = response['data']['items'];
        if (items.isNotEmpty) {
          Map<String, dynamic> vehicle = items.first;

          titleController.text = vehicle['title']?.toString() ?? "";
          priceController.text = vehicle['price']?.toString() ?? "";
          descController.text = vehicle['description']?.toString() ?? "";
          if (vehicle['itemInfo'] != null) {
            try {
              Map<String, dynamic> itemInfo = json.decode(vehicle['itemInfo'].toString());
              selectedBrandId = itemInfo['makeType']?.toString();
            } catch (_) {}
          }
          if (selectedBrandId == null && vehicle['brand'] != null) {
             selectedBrandId = vehicle['brand']['_id']?.toString() ?? vehicle['brand']['id']?.toString();
          }
        }
      }
    } catch (e) {
      developer.log('Erreur fetchVehicleData: $e');
      errorMessage = "Impossible de charger le véhicule.";
    }
  }

  Future saveChanges() async {
    isLoading = true;
    update();
    await Future.delayed(const Duration(seconds: 1)); // Simule l'API
    Get.snackbar("Succès", "Modifications simulées avec succès");
    isLoading = false;
    update();
  }
}
