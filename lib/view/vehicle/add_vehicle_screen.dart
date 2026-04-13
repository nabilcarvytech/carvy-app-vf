import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:carvy/controller/vehicle_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/model/make_type_model.dart';
import 'package:carvy/model/make_model_vehicle.dart';
import 'package:carvy/model/fuel_type_model.dart';
import 'package:carvy/model/odometer_model.dart';
import 'package:carvy/model/location_host_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/view/auth/login_screen.dart';
import 'package:get_storage/get_storage.dart';
import 'package:carvy/work_space.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final VehicleController vehicleController = Get.find<VehicleController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  // Variables de sélection
  dynamic _selectedVehicleType;
  final Set<String> _selectedCategoryIds = <String>{};
  final ScrollController _categoryScrollController = ScrollController();
  bool _catShowLeft = false;
  bool _catShowRight = false;
  Makes? _selectedMake;
  Models? _selectedModel;
  FuelType? _selectedFuelType;
  String _selectedTransmission = 'MANUAL';
  
  // Nouveaux champs pour l'étape Identité
  Getodometer? _selectedOdometer;
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController(text: '0');
  double _mileageKm = 0;
  // Saisie manuelle du modèle si "Autre" est sélectionné
  bool _isOtherModelSelected = false;
  final TextEditingController _otherModelController = TextEditingController();
  
  // Champs pour l'étape Technique
  final TextEditingController _plateNumber1Controller = TextEditingController();
  final TextEditingController _plateNumber2Controller = TextEditingController();
  final TextEditingController _plateNumber3Controller = TextEditingController();
  final TextEditingController _minRentalDaysController = TextEditingController(text: '1');
  String? _selectedInsurance;
  bool _hasAgeRestriction = false;
  final TextEditingController _minAgeController = TextEditingController(text: '18');
  bool _allowsInternationalTravel = false;
  
  // Champs pour l'étape Prix
  final TextEditingController _pricePerDayController = TextEditingController();
  final TextEditingController _depositController = TextEditingController();
  
  // Réductions
  bool _hasWeeklyDiscount = false;
  final TextEditingController _weeklyDiscountValueController = TextEditingController();
  String _weeklyDiscountType = 'percent'; // 'percent' ou 'fixed'
  
  bool _hasMonthlyDiscount = false;
  final TextEditingController _monthlyDiscountValueController = TextEditingController();
  String _monthlyDiscountType = 'percent'; // 'percent' ou 'fixed'
  
  // Livraison
  bool _hasHomeDelivery = false;
  dynamic _selectedDeliveryLocation;
  final List<Map<String, dynamic>> _deliveryLocations = <Map<String, dynamic>>[];
  final List<TextEditingController> _deliveryLocationPriceControllers = <TextEditingController>[];
  
  // Champs pour l'étape Localisation
  dynamic _selectedLocation;
  final TextEditingController _addressController = TextEditingController();
  GoogleMapController? _mapController;
  LatLng _selectedLatLng = const LatLng(33.5731, -7.5898); // Casablanca par défaut
  final Set<Marker> _markers = {};

  int _currentStep = 0;
  final int _totalSteps = 8; // 8 étapes logiques
  
  // Noms des étapes
  final List<String> _stepNames = [
    'Identité',
    'Technique',
    'Tarification',
    'Localisation',
    'Équipements',
    'Politiques & Règles',
    'Photos',
    'Documents',
  ];

  @override
  void initState() {
    super.initState();
    // Forcer le rafraîchissement du bearer token avant de charger les données
    _refreshTokenAndLoadData();
    _loadVehicleControllerData();
    // Initialiser le marqueur sur la carte
    _updateMarker(_selectedLatLng);

    _categoryScrollController.addListener(_updateCategoryArrowsVisibility);
  }
  
  /// Rafraîchit le bearer token et charge les données initiales
  /// Redirige vers login si le token est invalide
  Future<void> _refreshTokenAndLoadData() async {
    try {
      // Forcer le rafraîchissement du bearer token
      final tokenRefreshed = await vehicleController.refreshBearerToken();
      if (!tokenRefreshed) {
        // Si le rafraîchissement échoue, vérifier si c'est un problème de token
        final currentToken = GetStorage().read('token') ?? token;
        if (currentToken.isEmpty) {
          showErrorToastMessage('Session expirée. Veuillez vous reconnecter.');
          Future.delayed(const Duration(seconds: 1), () {
            logout();
            Get.offAll(() => const LoginScreen());
          });
          return;
        }
      }
      
      // Charger les données initiales
      await _loadInitialData();
      
      // Vérifier que les listes ne sont pas vides (indicateur de token invalide)
      if (vehicleController.categoriesList.isEmpty && 
          vehicleController.makesList.isEmpty) {
        // Ne pas rediriger immédiatement, peut-être que c'est juste un problème réseau
        // Mais afficher un message d'erreur
        showErrorToastMessage('Impossible de charger les données. Vérifiez votre connexion.');
      }
    } catch (e) {
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('invalid signature') || 
          errorString.contains('invalid token') ||
          errorString.contains('unauthorized')) {
        showErrorToastMessage('Session expirée. Veuillez vous reconnecter.');
        Future.delayed(const Duration(seconds: 1), () {
          logout();
          Get.offAll(() => const LoginScreen());
        });
      }
    }
  }

  void _updateCategoryArrowsVisibility() {
    if (!_categoryScrollController.hasClients) return;
    final max = _categoryScrollController.position.maxScrollExtent;
    final offset = _categoryScrollController.offset;
    final bool showLeft = offset > 8;
    final bool showRight = offset < (max - 8);
    if (showLeft != _catShowLeft || showRight != _catShowRight) {
      setState(() {
        _catShowLeft = showLeft;
        _catShowRight = showRight;
      });
    }
  }

  String? _extractCategoryId(dynamic c) {
    if (c == null) return null;
    try {
      if (c is Map<String, dynamic>) {
        return c['_id']?.toString() ?? c['id']?.toString();
      }
      // ItemTypes
      // ignore: unnecessary_cast
      final dynamic any = c as dynamic;
      return any._id?.toString() ?? any.id?.toString();
    } catch (_) {
      return null;
    }
  }

  String? _primarySelectedCategoryId() {
    return _selectedCategoryIds.isNotEmpty ? _selectedCategoryIds.first : null;
  }

  Widget _buildCategorySelectionWithArrows(List<dynamic> categoriesList) {
    if (categoriesList.isEmpty) {
      return Text('Aucune catégorie'.tr, style: TextStyle(color: Colors.grey[600]));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _updateCategoryArrowsVisibility());

    return Stack(
      children: [
        SizedBox(
          height: 92,
          child: ListView.separated(
            controller: _categoryScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: categoriesList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final c = categoriesList[index];
              final id = _extractCategoryId(c) ?? '';
              final name = c is Map<String, dynamic>
                  ? (c['name']?.toString() ?? '')
                  : (c.name?.toString() ?? '');
              final bool selected = _selectedCategoryIds.contains(id);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selected) {
                      _selectedCategoryIds.remove(id);
                      if (_selectedVehicleType == c) {
                        _selectedVehicleType = null;
                      }
                    } else {
                      _selectedCategoryIds.add(id);
                      _selectedVehicleType = c; // sert d’ancre pour chargement des modèles
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? vehicalThemColor : Colors.grey[300]!,
                      width: selected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_car_filled_outlined,
                          color: selected ? vehicalThemColor : Colors.grey[700]),
                      const SizedBox(width: 10),
                      Text(
                        name,
                        style: TextStyle(
                          color: selected ? vehicalThemColor : Colors.grey[900],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (selected) const Icon(Icons.check_circle, color: Colors.green, size: 18),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (_catShowLeft)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _categoryScrollController.animateTo(
                      (_categoryScrollController.offset - 180).clamp(
                        0.0,
                        _categoryScrollController.position.maxScrollExtent,
                      ),
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 2),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF27489E),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF27489E).withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                  ),
                ),
                Container(
                  width: 24,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.white, Colors.white.withOpacity(0.0)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (_catShowRight)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Row(
              children: [
                Container(
                  width: 24,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [Colors.white, Colors.white.withOpacity(0.0)],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _categoryScrollController.animateTo(
                      (_categoryScrollController.offset + 180).clamp(
                        0.0,
                        _categoryScrollController.position.maxScrollExtent,
                      ),
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 2),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF27489E),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF27489E).withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Charger les données depuis le controller si elles existent
  void _loadVehicleControllerData() {
    final controller = vehicleController;
    if (controller.plateNumber1.isNotEmpty) {
      _plateNumber1Controller.text = controller.plateNumber1;
    }
    if (controller.plateNumber2.isNotEmpty) {
      _plateNumber2Controller.text = controller.plateNumber2;
    }
    if (controller.plateNumber3.isNotEmpty) {
      _plateNumber3Controller.text = controller.plateNumber3;
    }
    if (controller.minRentalDays.isNotEmpty) {
      _minRentalDaysController.text = controller.minRentalDays;
    }
    if (controller.selectedInsurance.isNotEmpty) {
      _selectedInsurance = controller.selectedInsurance;
    } else {
      _selectedInsurance = null;
    }
    _hasAgeRestriction = controller.hasAgeRestriction;
    if (controller.minAge.isNotEmpty) {
      _minAgeController.text = controller.minAge;
    }
    _allowsInternationalTravel = controller.allowsInternationalTravel;
  }

  void _clearDeliveryLocations() {
    for (final controller in _deliveryLocationPriceControllers) {
      controller.dispose();
    }
    _deliveryLocationPriceControllers.clear();
    _deliveryLocations.clear();
    _selectedDeliveryLocation = null;
  }

  String _extractLocationId(dynamic location) {
    if (location is Map<String, dynamic>) {
      return (location['_id'] ?? location['id'])?.toString() ?? '';
    }
    try {
      return location.id?.toString() ?? location._id?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  String _extractLocationName(dynamic location) {
    if (location is Map<String, dynamic>) {
      return location['cityName']?.toString() ??
          location['city_name']?.toString() ??
          location['name']?.toString() ??
          location['region_name']?.toString() ??
          location['city']?.toString() ??
          '';
    }
    try {
      return location.cityName?.toString() ?? location.name?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  List<Map<String, dynamic>> _buildDeliveryLocationsPayload() {
    if (!_hasHomeDelivery) return <Map<String, dynamic>>[];

    return _deliveryLocations
        .map((loc) => <String, dynamic>{
              // Backend attendu : { "location": "<ID>", "price": 100 }
              'location': loc['locationId']?.toString() ?? '',
              'price': (loc['price'] as num?)?.toDouble() ?? 0.0,
            })
        .where((e) =>
            (e['location'] is String) && (e['location'] as String).isNotEmpty)
        .toList();
  }

  void _addDeliveryLocation() {
    if (_deliveryLocations.length >= 3) {
      showErrorToastMessage('Vous pouvez ajouter jusqu\'à 3 emplacements.'.tr);
      return;
    }

    if (_selectedDeliveryLocation == null) {
      showErrorToastMessage('Veuillez sélectionner une ville.'.tr);
      return;
    }

    final id = _extractLocationId(_selectedDeliveryLocation);
    if (id.isEmpty) {
      showErrorToastMessage('Emplacement invalide.'.tr);
      return;
    }

    final alreadyAdded = _deliveryLocations.any(
      (e) => e['locationId']?.toString() == id,
    );
    if (alreadyAdded) {
      showErrorToastMessage('Cet emplacement est déjà ajouté.'.tr);
      return;
    }

    final name = _extractLocationName(_selectedDeliveryLocation);
    if (name.isEmpty) {
      showErrorToastMessage('Nom de l\'emplacement introuvable.'.tr);
      return;
    }

    setState(() {
      _deliveryLocations.add(<String, dynamic>{
        'locationId': id,
        'locationName': name,
        'price': 0.0,
      });
      _deliveryLocationPriceControllers.add(
        TextEditingController(text: '0'),
      );
      _selectedDeliveryLocation = null;
    });
  }

  void _removeDeliveryLocation(int index) {
    if (index < 0 || index >= _deliveryLocations.length) return;
    setState(() {
      _deliveryLocationPriceControllers[index].dispose();
      _deliveryLocationPriceControllers.removeAt(index);
      _deliveryLocations.removeAt(index);
    });
  }

  Future<void> _loadInitialData() async {
    await vehicleController.fetchCategories();
    await vehicleController.fetchVehicleMakes();
    await vehicleController.fetchVehicleFuelTypes();
    await vehicleController.fetchOdometers();
    await vehicleController.fetchLocations();
    await vehicleController.fetchFeatures();
    await vehicleController.fetchPolicies();
    await vehicleController.fetchRules();
  }


  Future<void> _onVehicleTypeSelected(dynamic vehicleType) async {
    setState(() {
      _selectedVehicleType = vehicleType;
      _selectedMake = null;
      _selectedModel = null;
    });

    if (vehicleType != null) {
      String? typeId;
      if (vehicleType is Map<String, dynamic>) {
        typeId = vehicleType['id']?.toString();
      } else {
        typeId = vehicleType.id?.toString();
      }
      if (typeId != null && typeId.isNotEmpty) {
        await vehicleController.fetchVehicleMakes(typeId: typeId);
      }
    }
  }

  Future<void> _onMakeSelected(Makes? make) async {
    setState(() {
      _selectedMake = make;
      _selectedModel = null;
    });

    if (make != null && make.id != null && make.id!.isNotEmpty) {
      String? typeId;
      if (_selectedVehicleType != null) {
        if (_selectedVehicleType is Map<String, dynamic>) {
          typeId = _selectedVehicleType['id']?.toString();
        } else {
          typeId = _selectedVehicleType.id?.toString();
        }
      }
      await vehicleController.fetchVehicleModels(
        typeId: typeId,
        makeId: make.id,
      );
    }
  }

  List<Models> _getAvailableModels() {
    if (_selectedMake == null) return [];
    return vehicleController.modelsList.toList();
  }

  void _nextStep() async {
    if (_currentStep < _totalSteps - 1) {
      // Recharger les données si nécessaire quand on arrive sur l'étape 4
      if (_currentStep == 3) {
        // Arrivée sur l'étape 4 (Localisation) - Recharger les locations si la liste est vide
        if (vehicleController.locationsList.isEmpty) {
          await vehicleController.fetchLocations();
        }
      }
      
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitVehicle();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0: // Identité - Tous les champs doivent être remplis
        return _selectedCategoryIds.isNotEmpty &&
            _selectedMake != null &&
            _selectedModel != null &&
            _selectedOdometer != null &&
            _yearController.text.isNotEmpty &&
            _seatsController.text.isNotEmpty &&
            _selectedFuelType != null;
      case 1: // Technique - Plaque et assurance requises
        final plateComplete = _plateNumber1Controller.text.isNotEmpty &&
            _plateNumber2Controller.text.isNotEmpty &&
            _plateNumber3Controller.text.isNotEmpty;
        return plateComplete && _selectedInsurance != null && _selectedInsurance!.isNotEmpty;
      case 2: // Tarification - Prix par jour requis (doit être > 0)
        final price = double.tryParse(_pricePerDayController.text);
        if (price == null || price <= 0) return false;

        if (_hasHomeDelivery) {
          if (_deliveryLocations.isEmpty) return false;

          for (final loc in _deliveryLocations) {
            final double locPrice = (loc['price'] as num?)?.toDouble() ?? 0.0;
            if (locPrice <= 0) return false;
          }
        }

        return true;
      case 3: // Localisation - Ville requise
        return _selectedLocation != null;
      case 4: // Équipements - Au moins un équipement requis
        return vehicleController.selectedFeatures.isNotEmpty;
      case 5: // Politiques & Règles
        if (vehicleController.selectedPolicyId.value.isEmpty) {
          return false;
        }
        // Si Flexible, exiger que tous les paliers aient une valeur valide 0-100
        if (vehicleController.selectedPolicyId.value == 'flexible') {
          final policiesList = vehicleController.policiesList.toList();
          if (policiesList.isEmpty) return false;
          for (var tier in policiesList) {
            if (tier is! Map<String, dynamic>) return false;
            final String tierId = tier['_id']?.toString() ?? tier['id']?.toString() ?? '';
            if (tierId.isEmpty) return false;
            final String? fee = vehicleController.tierRetentionFees[tierId];
            if (fee == null || fee.trim().isEmpty) return false;
            final double? v = double.tryParse(fee.trim());
            if (v == null || v < 0 || v > 100) return false;
          }
        }
        return true;
      case 6: // Photos - Au moins une image requise
        return vehicleController.selectedImages.isNotEmpty;
      case 7: // Documents - Les 3 documents obligatoires doivent être présents
        return vehicleController.registrationCardRecto.value != null &&
               vehicleController.registrationCardVerso.value != null &&
               vehicleController.ministryAuthorization.value != null;
      default:
        return true; // Les autres étapes n'ont pas de validation stricte
    }
  }

  Future<void> _submitVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryIds.isEmpty) {
      showErrorToastMessage('Veuillez sélectionner au moins une catégorie de véhicule');
      _goToStep(1);
      return;
    }
    if (_selectedMake == null) {
      showErrorToastMessage('Veuillez sélectionner une marque');
      _goToStep(0);
      return;
    }
    if (_selectedModel == null) {
      showErrorToastMessage('Veuillez sélectionner un modèle');
      _goToStep(0);
      return;
    }
    if (_selectedOdometer == null) {
      showErrorToastMessage('Veuillez sélectionner un kilométrage');
      _goToStep(0);
      return;
    }
    if (_yearController.text.isEmpty) {
      showErrorToastMessage('Veuillez saisir l\'année');
      _goToStep(0);
      return;
    }
    if (_seatsController.text.isEmpty) {
      showErrorToastMessage('Veuillez saisir le nombre de sièges');
      _goToStep(0);
      return;
    }
    if (_selectedFuelType == null) {
      showErrorToastMessage('Veuillez sélectionner un type de carburant');
      _goToStep(0);
      return;
    }
    // Validation des images (maintenant dans une étape séparée ou intégrée ailleurs)
    // Les images seront gérées différemment selon le nouveau flux
    if (_pricePerDayController.text.isEmpty) {
      showErrorToastMessage('Veuillez entrer un prix par jour');
      _goToStep(2);
      return;
    }

    try {
      // Récupérer les IDs
      String? vehicleTypeId = _primarySelectedCategoryId();

      final double basePrice = double.tryParse(_pricePerDayController.text) ?? 0.0;
      if (basePrice <= 0) {
        showErrorToastMessage('Le prix doit être supérieur à 0');
        return;
      }

      final double deposit = double.tryParse(_depositController.text) ?? 0.0;
      final int year = int.tryParse(_yearController.text) ?? 0;
      final int seats = int.tryParse(_seatsController.text) ?? 0;

      // Récupérer l'ID de la région
      String? regionId = vehicleController.selectedRegionId.value.isNotEmpty 
          ? vehicleController.selectedRegionId.value 
          : null;

      // Récupérer la ville depuis _selectedLocation
      String? city;
      if (_selectedLocation != null) {
        if (_selectedLocation is Map<String, dynamic>) {
          city = _selectedLocation['cityName']?.toString() ?? 
                 _selectedLocation['city_name']?.toString() ?? 
                 _selectedLocation['name']?.toString() ?? 
                 _selectedLocation['city']?.toString();
        } else {
          city = _selectedLocation.cityName?.toString() ?? 
                 _selectedLocation.name?.toString();
        }
      }

      // Récupérer les coordonnées
      final double latitude = vehicleController.selectedLatitude.value;
      final double longitude = vehicleController.selectedLongitude.value;

      if (latitude == 0.0 || longitude == 0.0) {
        showErrorToastMessage('Veuillez sélectionner une localisation sur la carte');
        _goToStep(3);
        return;
      }

      // Extraction des IDs (maintenant tous en String grâce à la correction des modèles)
      // Les classes Models, FuelType et Makes utilisent maintenant String pour l'ID
      final String? extractedModelId = _selectedModel?.id?.trim();
      final String? extractedFuelId = _selectedFuelType?.id?.trim();
      final String? extractedBrandId = _selectedMake?.id?.trim();
      
      // Validation stricte des IDs avant soumission
      if (extractedModelId == null || extractedModelId.isEmpty || extractedModelId == "0" || extractedModelId.toLowerCase() == "null") {
        showErrorToastMessage('Le modèle du véhicule est requis. Veuillez sélectionner un modèle valide.');
        _goToStep(0); // Retourner à l'étape de sélection du modèle
        return;
      }
      
      if (extractedFuelId == null || extractedFuelId.isEmpty || extractedFuelId == "0" || extractedFuelId.toLowerCase() == "null") {
        showErrorToastMessage('Le type de carburant est requis. Veuillez sélectionner un type de carburant valide.');
        _goToStep(1); // Retourner à l'étape de sélection du carburant
        return;
      }
      
      if (extractedBrandId == null || extractedBrandId.isEmpty || extractedBrandId == "0" || extractedBrandId.toLowerCase() == "null") {
        showErrorToastMessage('La marque du véhicule est requise. Veuillez sélectionner une marque valide.');
        _goToStep(0);
        return;
      }
      
      // Préparer la liste complète des catégories sélectionnées (filtrée 24 hex)
      List<String> categoriesForBackend = _selectedCategoryIds
          .where((id) => id.length == 24 && RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(id))
          .toList(growable: false);

      debugPrint('📤 [ADD_VEHICLE_UI] vehicleTypeId principal: $vehicleTypeId');
      debugPrint('📤 [ADD_VEHICLE_UI] categoriesIds (multi): $categoriesForBackend');
      debugPrint('📤 [ADD_VEHICLE_UI] brand/model/fuel IDs: $extractedBrandId / $extractedModelId / $extractedFuelId');
      debugPrint('📤 [ADD_VEHICLE_UI] odometer/year/seats: ${_selectedOdometer?.id} / $year / $seats');
      debugPrint('📤 [ADD_VEHICLE_UI] pricing: base=$basePrice deposit=$deposit');
      debugPrint('📤 [ADD_VEHICLE_UI] location: region=$regionId city=$city lat=${_selectedLatLng.latitude} lng=${_selectedLatLng.longitude}');
      debugPrint('📤 [ADD_VEHICLE_UI] media counts: images=${vehicleController.selectedImages.length}, docs=${[
        vehicleController.registrationCardRecto.value,
        vehicleController.registrationCardVerso.value,
        vehicleController.ministryAuthorization.value
      ].where((f) => f != null).length}');

      final bool success = await vehicleController.submitVehicle(
        vehicleTypeId: vehicleTypeId,
        categoriesIds: categoriesForBackend,
        brandId: extractedBrandId,
        modelId: extractedModelId,
        otherModelName: _isOtherModelSelected
            ? _otherModelController.text.trim()
            : null,
        fuelId: extractedFuelId,
        transmission: _selectedTransmission,
        odometerId: _selectedOdometer?.id?.toString(),
        year: year,
        seats: seats,
        basePrice: basePrice,
        currency: 'MAD',
        deposit: deposit,
        hasWeeklyDiscount: _hasWeeklyDiscount,
        weeklyDiscountValue: double.tryParse(_weeklyDiscountValueController.text) ?? 0.0,
        weeklyDiscountType: _weeklyDiscountType,
        hasMonthlyDiscount: _hasMonthlyDiscount,
        monthlyDiscountValue: double.tryParse(_monthlyDiscountValueController.text) ?? 0.0,
        monthlyDiscountType: _monthlyDiscountType,
        hasHomeDelivery: _hasHomeDelivery,
        deliveryLocations: _buildDeliveryLocationsPayload(),
        regionId: regionId,
        fullAddress: vehicleController.fullAddress.value.isNotEmpty 
            ? vehicleController.fullAddress.value 
            : _addressController.text,
        city: city,
        latitude: latitude,
        longitude: longitude,
        selectedFeatures: vehicleController.selectedFeatures.toList(),
        policyId: vehicleController.selectedPolicyId.value.isNotEmpty 
            ? vehicleController.selectedPolicyId.value 
            : null,
        selectedRules: vehicleController.selectedRules.toList(),
        plateNumber1: _plateNumber1Controller.text,
        plateNumber2: _plateNumber2Controller.text,
        plateNumber3: _plateNumber3Controller.text,
        minRentalDays: _minRentalDaysController.text,
        insurance: _selectedInsurance ?? '',
        hasAgeRestriction: _hasAgeRestriction,
        minAge: _minAgeController.text,
        allowsInternationalTravel: _allowsInternationalTravel,
        imageFiles: vehicleController.selectedImages.toList(),
        registrationCardFront: vehicleController.registrationCardRecto.value,
        registrationCardBack: vehicleController.registrationCardVerso.value,
        ministryAuthorization: vehicleController.ministryAuthorization.value,
      );

      // La redirection et le snackbar sont maintenant gérés dans le controller (submitVehicle)
      // Le controller appelle Get.back() et Get.snackbar() directement après un succès (201)
      // On ne fait que réinitialiser le formulaire si nécessaire
      if (success) {
        _resetForm();
        // Note: Get.back() et le snackbar sont déjà appelés dans submitVehicle du controller
      }
    } catch (e) {
      showErrorToastMessage('Erreur lors de l\'ajout du véhicule: $e');
    }
  }

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
    });
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _resetForm() {
    setState(() {
      _selectedVehicleType = null;
      _selectedMake = null;
      _selectedModel = null;
      _selectedFuelType = null;
      _selectedTransmission = 'MANUAL';
      _selectedOdometer = null;
      _selectedInsurance = null;
      _hasAgeRestriction = false;
      _allowsInternationalTravel = false;
      _hasWeeklyDiscount = false;
      _hasMonthlyDiscount = false;
      _hasHomeDelivery = false;
      _weeklyDiscountType = 'percent';
      _monthlyDiscountType = 'percent';
      vehicleController.selectedImages.clear();
      _pricePerDayController.clear();
      _depositController.clear();
      _weeklyDiscountValueController.clear();
      _monthlyDiscountValueController.clear();
      _clearDeliveryLocations();
      _yearController.clear();
      _seatsController.clear();
      _plateNumber1Controller.clear();
      _plateNumber2Controller.clear();
      _plateNumber3Controller.clear();
      _minRentalDaysController.text = '1';
      _minAgeController.text = '18';
      _currentStep = 0;
    });
    _pageController.jumpToPage(0);
  }

  @override
  @override
  void dispose() {
    print('👋 [BYE] Écran d\'ajout détruit');
    _pricePerDayController.dispose();
    _depositController.dispose();
    _weeklyDiscountValueController.dispose();
    _monthlyDiscountValueController.dispose();
    _clearDeliveryLocations();
    _yearController.dispose();
    _seatsController.dispose();
    _plateNumber1Controller.dispose();
    _plateNumber2Controller.dispose();
    _plateNumber3Controller.dispose();
    _minRentalDaysController.dispose();
    _minAgeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Ajouter un véhicule'.tr),
        backgroundColor: vehicalThemColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // ========== BARRE DE PROGRESSION ==========
            _buildProgressStepper(),
            
            // ========== CONTENU DES ÉTAPES ==========
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1Identity(),
                  _buildStep2Technical(),
                  _buildStep3Pricing(),
                  _buildStep4Location(),
                  _buildStep5Features(),
                  _buildStep6Policies(),
                  _buildStep7Photos(),
                  _buildStep8Documents(),
                ],
              ),
            ),

            // ========== BOUTONS DE NAVIGATION ==========
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  // ========== HEADER FIXE AVEC BARRE DE PROGRESSION ==========
  Widget _buildProgressStepper() {
    final progress = (_currentStep + 1) / _totalSteps;
    final currentStepName = _stepNames[_currentStep].tr;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barre de progression linéaire animée
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(vehicalThemColor),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 12),
          // Texte : 'Étape X sur 8' en gras + nom de l'étape
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
              children: [
                TextSpan(
                  text: 'Étape ${_currentStep + 1} sur $_totalSteps'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' : $currentStepName'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== ÉTAPE 1 : IDENTITÉ ==========
  Widget _buildStep1Identity() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations du véhicule'.tr,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sélectionnez la catégorie, la marque et le modèle'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Carte Catégorie de véhicule
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catégorie de véhicule *'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final isLoading = vehicleController.isLoadingCategories.value;
                  final categoriesList = vehicleController.categoriesList.toList();
                  if (isLoading) return const Center(child: CircularProgressIndicator());
                  return _buildCategorySelectionWithArrows(categoriesList);
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Carte Marque
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Marque *'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final isLoading = vehicleController.isLoadingMakes.value;
                  final makesList = vehicleController.makesList.toList();
                  final makesCount = makesList.length;
                  if (isLoading) return const Center(child: CircularProgressIndicator());
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildModernDropdown<Makes>(
                        key: UniqueKey(),
                        value: _selectedMake,
                        items: makesList
                            .map((make) => DropdownMenuItem<Makes>(
                                  value: make,
                                  child: Text(make.makeName ?? ''),
                                ))
                            .toList(),
                        enabled: true,
                        onChanged: (Makes? newValue) async {
                          setState(() {
                            _selectedMake = newValue;
                            _selectedModel = null;
                          });
                          vehicleController.modelsList.clear();
                          if (newValue != null && newValue.id != null && newValue.id!.isNotEmpty) {
                            String? typeId = _primarySelectedCategoryId();
                            await vehicleController.fetchVehicleModels(
                              typeId: typeId,
                              makeId: newValue.id,
                            );
                          }
                        },
                        hint: makesCount == 0 ? 'Chargement...'.tr : 'Sélectionnez une option'.tr,
                        icon: Icons.directions_car_rounded,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Carte Modèle
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modèle *'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final isLoading = vehicleController.isLoadingModels.value;
                  final modelsList = vehicleController.modelsList.toList();
                  final modelsCount = modelsList.length;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _buildModernDropdown<Models>(
                              key: UniqueKey(),
                              value: _selectedModel,
                              items: modelsList
                                  .map((model) => DropdownMenuItem<Models>(
                                        value: model,
                                        child: Text(model.name ?? ''),
                                      ))
                                  .toList(),
                              enabled: true,
                              onChanged: (Models? model) {
                                setState(() {
                                  _selectedModel = model;
                                  final String selectedName = (model?.name ?? '').toString();
                                  _isOtherModelSelected = selectedName.toLowerCase() == 'autre';
                                  debugPrint('SÉLECTION MODÈLE: $selectedName | IS_OTHER: $_isOtherModelSelected');
                                });
                              },
                              hint: isLoading
                                  ? 'Chargement...'.tr
                                  : (modelsCount == 0
                                      ? 'Aucun modèle disponible'.tr
                                      : 'Sélectionnez un modèle'.tr),
                              icon: Icons.directions_car,
                            ),
                      if (_isOtherModelSelected) ...[
                        const SizedBox(height: 12),
                        _buildModernTextField(
                          controller: _otherModelController,
                          hint: 'Saisissez le modèle'.tr,
                          icon: Icons.edit,
                          keyboardType: TextInputType.text,
                        ),
                      ],
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Carte Kilométrage (champ + slider + mappage automatique d'intervalle)
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kilométrage *'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final isLoading = vehicleController.isLoadingOdometer.value;
                  final odometersList = vehicleController.odometerList.toList();
                  final odometersCount = odometersList.length;
                  
                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildModernDropdown<Getodometer>(
                        key: UniqueKey(),
                        value: _selectedOdometer,
                        items: odometersList.map((odometer) {
                          return DropdownMenuItem<Getodometer>(
                            value: odometer,
                            child: Text(odometer.name ?? ''),
                          );
                        }).toList(),
                        enabled: true,
                        onChanged: (Getodometer? odometer) {
                          setState(() {
                            _selectedOdometer = odometer;
                          });
                        },
                        hint: odometersCount == 0 ? 'Chargement...'.tr : 'Sélectionnez une option'.tr,
                        icon: Icons.speed,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Carte Année
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Année *'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 12),
                _buildModernTextField(
                  controller: _yearController,
                  hint: 'Ex: 2023'.tr,
                  icon: Icons.event,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Carte Transmission
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transmission *'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 12),
                _buildModernDropdown<String>(
                  key: UniqueKey(),
                  value: _selectedTransmission,
                  items: [
                    DropdownMenuItem<String>(
                      value: 'MANUAL',
                      child: Text('Manuelle'.tr),
                    ),
                    DropdownMenuItem<String>(
                      value: 'AUTOMATIC',
                      child: Text('Automatique'.tr),
                    ),
                  ],
                  enabled: true,
                  onChanged: (String? transmission) {
                    setState(() {
                      _selectedTransmission = transmission ?? 'MANUAL';
                    });
                  },
                  hint: 'Sélectionnez une transmission'.tr,
                  icon: Icons.settings_input_component,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Carte Nombre de sièges
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nombre de sièges *'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 12),
                _buildModernTextField(
                  controller: _seatsController,
                  hint: 'Ex: 5'.tr,
                  icon: Icons.event_seat,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Carte Type de carburant (déplacé depuis l'étape Technique)
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Type de carburant *'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final isLoading = vehicleController.isLoadingFuelTypes.value;
                  final fuelTypesList = vehicleController.fuelTypesList.toList();
                  final fuelTypesCount = fuelTypesList.length;
                  
                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildModernDropdown<FuelType>(
                        key: UniqueKey(),
                        value: _selectedFuelType,
                        items: fuelTypesList.map((fuelType) {
                                return DropdownMenuItem<FuelType>(
                                  value: fuelType,
                                  child: Text(fuelType.name ?? ''),
                                );
                              }).toList(),
                        enabled: true,
                        onChanged: (FuelType? fuelType) {
                          setState(() {
                            _selectedFuelType = fuelType;
                          });
                        },
                        hint: fuelTypesCount == 0 ? 'Chargement...'.tr : 'Sélectionnez une option'.tr,
                        icon: Icons.local_gas_station_rounded,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Cartes de sélection visuelles (icône + label + contour bleu si sélectionnée)
  Widget _buildSelectionCards<T>({
    required List<T> items,
    required bool Function(T) isSelected,
    required String Function(T) label,
    required IconData Function(T) icon,
    required void Function(T) onTap,
  }) {
    if (items.isEmpty) {
      return Text('Aucune donnée disponible'.tr, style: TextStyle(color: Colors.grey[600]));
    }

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final T item = items[index];
          final bool selected = isSelected(item);
          return GestureDetector(
            onTap: () => onTap(item),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? vehicalThemColor : Colors.grey[300]!,
                  width: selected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon(item), color: selected ? vehicalThemColor : Colors.grey[700]),
                  const SizedBox(width: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: Text(
                      label(item),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? vehicalThemColor : Colors.grey[900],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (selected)
                    const Icon(Icons.check_circle, color: Colors.green, size: 18),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Déduction simple de l'intervalle d'odomètre à partir d'un nombre (si le nom contient une plage)
  void _autoMapMileageToOdometer() {
    final list = vehicleController.odometerList.toList();
    if (list.isEmpty) return;

    Getodometer? best;
    for (final o in list) {
      final name = (o.name ?? '').replaceAll(' ', '');
      // Exemple formats: "0-10k", "10k-50k", "100000-150000", etc.
      final match = RegExp(r'(\d{1,6})\D*-\D*(\d{1,6})').firstMatch(name);
      if (match != null) {
        final start = int.tryParse(match.group(1)!) ?? 0;
        final end = int.tryParse(match.group(2)!) ?? start;
        final km = _mileageKm.toInt();
        if (km >= start && km <= end) {
          best = o;
          break;
        }
      }
    }
    setState(() {
      _selectedOdometer = best ?? _selectedOdometer;
    });
  }

  // ========== ÉTAPE 2 : TECHNIQUE ==========
  Widget _buildStep2Technical() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détails du véhicule'.tr,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complétez les informations de votre véhicule'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Carte Plaque d'immatriculation
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plaque d\'immatriculation *'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Format: 12345 | A | 45'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildModernTextField(
                        controller: _plateNumber1Controller,
                        hint: '12345'.tr,
                        icon: Icons.confirmation_number,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          vehicleController.plateNumber1 = value;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        '|',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 0,
                      child: SizedBox(
                        width: 60,
                        child: _buildModernTextField(
                          controller: _plateNumber2Controller,
                          hint: 'A'.tr,
                          icon: null,
                          keyboardType: TextInputType.text,
                          onChanged: (value) {
                            vehicleController.plateNumber2 = value;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        '|',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildModernTextField(
                        controller: _plateNumber3Controller,
                        hint: '45'.tr,
                        icon: null,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          vehicleController.plateNumber3 = value;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Carte Location & Assurance
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location & Assurance'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Jour de location minimum
                Text(
                  'Jour de location minimum'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                _buildModernTextField(
                  controller: _minRentalDaysController,
                  hint: '1'.tr,
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    vehicleController.minRentalDays = value;
                  },
                ),
                const SizedBox(height: 16),
                
                // Couverture d'assurance
                Text(
                  'Couverture d\'assurance *'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                _buildModernDropdown<String>(
                  key: UniqueKey(),
                  value: _selectedInsurance,
                  items: [
                    DropdownMenuItem<String>(
                      value: 'Basic',
                      child: Text('Basic'.tr),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Full',
                      child: Text('Full'.tr),
                    ),
                  ],
                  enabled: true,
                  onChanged: (String? insurance) {
                    setState(() {
                      _selectedInsurance = insurance;
                    });
                    // Synchroniser avec le controller
                    vehicleController.selectedInsurance = insurance ?? '';
                  },
                  hint: 'Sélectionnez une option'.tr,
                  icon: Icons.security,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Carte Restrictions
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Restrictions'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Restriction d'âge
                CheckboxListTile(
                  title: Text('Restriction d\'âge'.tr),
                  subtitle: Text('Définir un âge minimum pour la location'.tr),
                  value: _hasAgeRestriction,
                  onChanged: (bool? value) {
                    setState(() {
                      _hasAgeRestriction = value ?? false;
                    });
                    // Synchroniser avec le controller
                    vehicleController.hasAgeRestriction = _hasAgeRestriction;
                  },
                  activeColor: vehicalThemColor,
                  contentPadding: EdgeInsets.zero,
                ),
                
                // Champ âge minimum (affiché conditionnellement)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _hasAgeRestriction
                      ? Padding(
                          key: const ValueKey('ageField'),
                          padding: const EdgeInsets.only(top: 8, left: 16),
                          child: _buildModernTextField(
                            controller: _minAgeController,
                            hint: '18'.tr,
                            icon: Icons.person_outline,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              vehicleController.minAge = value;
                            },
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('empty')),
                ),
                const SizedBox(height: 12),
                
                // Voyage international
                CheckboxListTile(
                  title: Text('Voyage international autorisé'.tr),
                  subtitle: Text('Permettre la location pour des voyages internationaux'.tr),
                  value: _allowsInternationalTravel,
                  onChanged: (bool? value) {
                    setState(() {
                      _allowsInternationalTravel = value ?? false;
                    });
                    // Synchroniser avec le controller
                    vehicleController.allowsInternationalTravel = _allowsInternationalTravel;
                  },
                  activeColor: vehicalThemColor,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== ÉTAPE 3 : TARIFICATION ==========
  Widget _buildStep3Pricing() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tarification'.tr,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Définissez le prix et les options de tarification'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Carte Prix
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prix'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Row Prix par jour et Devise
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prix par jour *'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildModernTextField(
                            controller: _pricePerDayController,
                            hint: '0.00'.tr,
                            icon: Icons.attach_money_rounded,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) {
                              vehicleController.pricePerDay = double.tryParse(value) ?? 0.0;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Devise'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Champ Devise fixé sur MAD (affichage constant)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.currency_exchange, color: vehicalThemColor, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  'MAD',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[900],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Carte Caution (Section séparée)
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Caution'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Champ Caution
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Montant de la caution'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildModernTextField(
                      controller: _depositController,
                      hint: '0.00'.tr,
                      icon: Icons.security,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        vehicleController.deposit = double.tryParse(value) ?? 0.0;
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Carte Réduction Hebdomadaire
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  title: Text(
                    'Réduction Hebdomadaire'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  value: _hasWeeklyDiscount,
                  onChanged: (bool? value) {
                    setState(() {
                      _hasWeeklyDiscount = value ?? false;
                    });
                    // Synchroniser avec le controller
                    vehicleController.hasWeeklyDiscount = _hasWeeklyDiscount;
                  },
                  activeColor: vehicalThemColor,
                  contentPadding: EdgeInsets.zero,
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _hasWeeklyDiscount
                      ? Padding(
                          key: const ValueKey('weeklyDiscount'),
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildModernTextField(
                                  controller: _weeklyDiscountValueController,
                                  hint: '0'.tr,
                                  icon: Icons.percent,
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  onChanged: (value) {
                                    vehicleController.weeklyDiscountValue = double.tryParse(value) ?? 0.0;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildModernDropdown<String>(
                                  key: UniqueKey(),
                                  value: _weeklyDiscountType,
                                  items: [
                                    DropdownMenuItem<String>(
                                      value: 'percent',
                                      child: Text('Pourcentage (%)'.tr),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'fixed',
                                      child: Text('Montant Fixe MAD'.tr),
                                    ),
                                  ],
                                  enabled: true,
                                  onChanged: (String? type) {
                                    setState(() {
                                      _weeklyDiscountType = type ?? 'percent';
                                    });
                                    // Synchroniser avec le controller
                                    vehicleController.weeklyDiscountType = _weeklyDiscountType;
                                  },
                                  hint: 'Type'.tr,
                                  icon: Icons.category,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('emptyWeekly')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Carte Réduction Mensuelle
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  title: Text(
                    'Réduction Mensuelle'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  value: _hasMonthlyDiscount,
                  onChanged: (bool? value) {
                    setState(() {
                      _hasMonthlyDiscount = value ?? false;
                    });
                  },
                  activeColor: vehicalThemColor,
                  contentPadding: EdgeInsets.zero,
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _hasMonthlyDiscount
                      ? Padding(
                          key: const ValueKey('monthlyDiscount'),
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildModernTextField(
                                  controller: _monthlyDiscountValueController,
                                  hint: '0'.tr,
                                  icon: Icons.percent,
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  onChanged: (value) {
                                    vehicleController.monthlyDiscountValue = double.tryParse(value) ?? 0.0;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildModernDropdown<String>(
                                  key: UniqueKey(),
                                  value: _monthlyDiscountType,
                                  items: [
                                    DropdownMenuItem<String>(
                                      value: 'percent',
                                      child: Text('Pourcentage (%)'.tr),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'fixed',
                                      child: Text('Montant Fixe MAD'.tr),
                                    ),
                                  ],
                                  enabled: true,
                                  onChanged: (String? type) {
                                    setState(() {
                                      _monthlyDiscountType = type ?? 'percent';
                                    });
                                    // Synchroniser avec le controller
                                    vehicleController.monthlyDiscountType = _monthlyDiscountType;
                                  },
                                  hint: 'Type'.tr,
                                  icon: Icons.category,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('emptyMonthly')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Carte Livraison
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  title: Text('Livraison à domicile disponible'.tr),
                  subtitle: Text('Permettre la livraison du véhicule au client'.tr),
                  value: _hasHomeDelivery,
                  onChanged: (bool? value) {
                    setState(() {
                      _hasHomeDelivery = value ?? false;
                      if (!_hasHomeDelivery) {
                        _clearDeliveryLocations();
                      }
                    });
                    // Synchroniser avec le controller
                    vehicleController.hasHomeDelivery = _hasHomeDelivery;
                  },
                  activeColor: vehicalThemColor,
                  contentPadding: EdgeInsets.zero,
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _hasHomeDelivery
                      ? Padding(
                          key: const ValueKey('deliveryLocations'),
                          padding: const EdgeInsets.only(top: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "💡 Vous pouvez définir jusqu'à 3 zones ou villes de livraison, chacune avec son propre tarif personnalisé."
                                    .tr,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Obx(() {
                                final isLoading = vehicleController
                                    .isLoadingLocations.value;
                                final locationsList =
                                    vehicleController.locationsList.toList();
                                final addedLocationIds = _deliveryLocations
                                    .map((e) => e['locationId']?.toString())
                                    .whereType<String>()
                                    .where((id) => id.isNotEmpty)
                                    .toSet();

                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _buildModernDropdown<dynamic>(
                                      key: UniqueKey(),
                                      value: _selectedDeliveryLocation,
                                      items: locationsList
                                          .where((location) {
                                            final locationId =
                                                _extractLocationId(location);
                                            return locationId.isEmpty ||
                                                !addedLocationIds
                                                    .contains(locationId);
                                          })
                                          .map((location) {
                                            final name = location
                                                    is Map<String, dynamic>
                                                ? (location['cityName']
                                                        ?.toString() ??
                                                    location['city_name']
                                                        ?.toString() ??
                                                    location['name']
                                                        ?.toString() ??
                                                    location['region_name']
                                                        ?.toString() ??
                                                    location['city']?.toString() ??
                                                    '')
                                                : location.toString();

                                            return DropdownMenuItem<dynamic>(
                                              value: location,
                                              child: Text(
                                                name.isNotEmpty
                                                    ? name
                                                    : 'Ville inconnue',
                                              ),
                                            );
                                          }).toList(),
                                      enabled: !isLoading,
                                      onChanged: (dynamic v) {
                                        setState(() {
                                          _selectedDeliveryLocation = v;
                                        });
                                      },
                                      hint: locationsList.isEmpty
                                          ? 'Chargement...'.tr
                                          : addedLocationIds.length >= 3
                                              ? 'Toutes les villes sont ajoutées'.tr
                                              : 'Sélectionnez une ville'.tr,
                                      icon: Icons.location_city,
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed:
                                            _deliveryLocations.length >= 3
                                                ? null
                                                : _addDeliveryLocation,
                                        icon: const Icon(Icons.add),
                                        label: Text('Ajouter'.tr),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                              const SizedBox(height: 12),
                              ListView.builder(
                                itemCount: _deliveryLocations.length,
                                shrinkWrap: true,
                                physics:
                                    const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final loc = _deliveryLocations[index];
                                  final priceController =
                                      _deliveryLocationPriceControllers[index];
                                  final locationName =
                                      loc['locationName']?.toString() ??
                                          'Ville inconnue';

                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12),
                                    child: _buildCard(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  locationName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () =>
                                                    _removeDeliveryLocation(
                                                  index,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          _buildModernTextField(
                                            controller: priceController,
                                            hint: 'Prix (MAD)'.tr,
                                            icon: Icons.local_shipping,
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                                    decimal: true),
                                            onChanged: (value) {
                                              final parsed =
                                                  double.tryParse(value) ?? 0.0;
                                              setState(() {
                                                _deliveryLocations[index]
                                                    ['price'] = parsed;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('emptyDelivery')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== ÉTAPE 4 : LOCALISATION ==========
  Widget _buildStep4Location() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Étape 4 sur 8 : Localisation'.tr,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Définissez l\'emplacement de votre véhicule'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Carte Région (Ville)
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Région (Ville) *'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final isLoading = vehicleController.isLoadingLocations.value;
                  final locationsList = vehicleController.locationsList.toList();
                  final locationsCount = locationsList.length;
                  
                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildModernDropdown<dynamic>(
                        key: UniqueKey(),
                        value: _selectedLocation,
                        items: locationsList.map((location) {
                          // CORRECTION : L'API renvoie cityName en priorité
                          final name = location is Map<String, dynamic>
                              ? (location['cityName']?.toString() ?? 
                                 location['city_name']?.toString() ?? 
                                 location['name']?.toString() ?? 
                                 location['region_name']?.toString() ?? 
                                 location['city']?.toString() ?? '')
                              : (location.cityName?.toString() ?? 
                                 location.name?.toString() ?? '');
                          return DropdownMenuItem<dynamic>(
                            value: location,
                            child: Text(name.isNotEmpty ? name : 'Ville inconnue'),
                          );
                        }).toList(),
                        enabled: true,
                        onChanged: (dynamic location) async {
                          setState(() {
                            _selectedLocation = location;
                          });
                          
                          // Centrer la carte sur la ville sélectionnée et synchroniser avec le controller
                          if (location != null) {
                            String? locationId, latStr, lngStr;
                            if (location is Map<String, dynamic>) {
                              locationId = location['_id']?.toString() ?? location['id']?.toString();
                              latStr = location['latitude']?.toString();
                              lngStr = location['longitude']?.toString();
                            } else {
                              locationId = location.id?.toString() ?? location._id?.toString();
                              latStr = location.latitude?.toString();
                              lngStr = location.longitude?.toString();
                            }
                            
                            // Sauvegarder l'ID de la localisation
                            if (locationId != null) {
                              vehicleController.selectedRegionId.value = locationId;
                            }
                            
                            // Animer la carte vers les coordonnées par défaut de la ville
                            if (latStr != null && lngStr != null) {
                              final lat = double.tryParse(latStr);
                              final lng = double.tryParse(lngStr);
                              if (lat != null && lng != null) {
                                _selectedLatLng = LatLng(lat, lng);
                                _updateMarker(_selectedLatLng);
                                
                                // Animer la caméra vers la nouvelle position
                                if (_mapController != null) {
                                  await _mapController!.animateCamera(
                                    CameraUpdate.newLatLngZoom(_selectedLatLng, 15.0),
                                  );
                                }
                                
                                // Synchroniser avec le controller
                                vehicleController.selectedLatitude.value = lat;
                                vehicleController.selectedLongitude.value = lng;
                              }
                            }
                          }
                        },
                        hint: locationsCount == 0 ? 'Chargement...'.tr : 'Sélectionnez une ville'.tr,
                        icon: Icons.location_city,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Carte Adresse complète
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adresse complète *'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 12),
                _buildModernTextField(
                  controller: _addressController,
                  hint: 'Ex: 123 Rue Mohammed V, Casablanca'.tr,
                  icon: Icons.location_on_outlined,
                  keyboardType: TextInputType.streetAddress,
                  onChanged: (value) {
                    vehicleController.fullAddress.value = value;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Carte interactive
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Position sur la carte *'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Déplacez le marqueur pour définir l\'emplacement précis'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 400,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: GoogleMap(
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                      },
                      initialCameraPosition: CameraPosition(
                        target: _selectedLatLng,
                        zoom: 15.0,
                      ),
                      markers: _markers,
                      onTap: (LatLng position) {
                        setState(() {
                          _selectedLatLng = position;
                          _updateMarker(position);
                        });
                        // Synchroniser avec le controller
                        vehicleController.selectedLatitude.value = position.latitude;
                        vehicleController.selectedLongitude.value = position.longitude;
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: true,
                      mapType: MapType.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Méthode pour mettre à jour le marqueur
  void _updateMarker(LatLng position) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          draggable: true,
          onDragEnd: (LatLng newPosition) {
            setState(() {
              _selectedLatLng = newPosition;
            });
            // Synchroniser avec le controller
            vehicleController.selectedLatitude.value = newPosition.latitude;
            vehicleController.selectedLongitude.value = newPosition.longitude;
          },
        ),
      );
    });
  }

  // ========== ÉTAPE 5 : ÉQUIPEMENTS ==========
  Widget _buildStep5Features() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Étape 5 sur 8 : Équipements du véhicule'.tr,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sélectionnez les équipements disponibles dans votre véhicule'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          Obx(() {
            final isLoading = vehicleController.isLoadingFeatures.value;
            final featuresList = vehicleController.featuresList.toList();
            final featuresCount = featuresList.length;
            final selectedFeatures = vehicleController.selectedFeatures.toList();
            
            if (isLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            if (featuresList.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'Aucun équipement disponible'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              );
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Grille d'équipements (Style React avec Checkbox)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3.5,
                  ),
                  itemCount: featuresList.length,
                  itemBuilder: (context, index) {
                    final feature = featuresList[index];
                    String? featureId;
                    String featureName = '';
                    
                    if (feature is Map<String, dynamic>) {
                      // CORRECTION : Utiliser _id en priorité (MongoDB)
                      featureId = feature['_id']?.toString() ?? feature['id']?.toString();
                      featureName = feature['name']?.toString() ?? 
                                   feature['feature_name']?.toString() ?? 
                                   feature['title']?.toString() ?? '';
                    } else {
                      featureId = feature._id?.toString() ?? feature.id?.toString();
                      featureName = feature.name?.toString() ?? feature.featureName?.toString() ?? '';
                    }
                    
                    final isSelected = featureId != null && selectedFeatures.contains(featureId);
                    
                    return InkWell(
                      onTap: () {
                        if (featureId != null) {
                          if (isSelected) {
                            vehicleController.selectedFeatures.remove(featureId);
                          } else {
                            vehicleController.selectedFeatures.add(featureId);
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? vehicalThemColor : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            // Case à cocher (Checkbox)
                            Checkbox(
                              value: isSelected,
                              onChanged: (bool? value) {
                                if (featureId != null) {
                                  if (value == true) {
                                    vehicleController.selectedFeatures.add(featureId);
                                  } else {
                                    vehicleController.selectedFeatures.remove(featureId);
                                  }
                                }
                              },
                              activeColor: vehicalThemColor,
                              checkColor: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            // Nom de l'équipement
                            Expanded(
                              child: Text(
                                featureName.isNotEmpty ? featureName : 'Équipement',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? vehicalThemColor : Colors.grey[900],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ========== ÉTAPE 6 : POLITIQUES & RÈGLES ==========
  Widget _buildStep6Policies() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Étape 6 sur 8 : Politiques & Règles'.tr,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Définissez les politiques d\'annulation et les règles de votre véhicule'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // ========== POLITIQUES D'ANNULATION ==========
          _buildCard(
            child: Obx(() {
              final selectedPolicyId = vehicleController.selectedPolicyId.value;
              
              // Niveau 1 : Déterminer si "Non-remboursable" ou "Politique flexible" est sélectionné
              final isNonRefundable = selectedPolicyId == 'non-refundable';
              final isFlexible = selectedPolicyId == 'flexible';
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Politique d\'annulation *'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // ========== NIVEAU 1 : SÉLECTION PRINCIPALE ==========
                  RadioListTile<String>(
                    title: Text(
                      'Non-remboursable'.tr,
                      style: TextStyle(
                        fontWeight: isNonRefundable ? FontWeight.bold : FontWeight.normal,
                        color: isNonRefundable ? vehicalThemColor : Colors.grey[900],
                      ),
                    ),
                    subtitle: Text(
                      'Aucun remboursement en cas d\'annulation'.tr,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    value: 'non-refundable',
                    groupValue: selectedPolicyId.isNotEmpty ? selectedPolicyId : null,
                    onChanged: (String? value) {
                      if (value != null) {
                        vehicleController.selectedPolicyId.value = value;
                        // Réinitialiser les switches et frais de retenue
                        vehicleController.tierSwitches.clear();
                        vehicleController.tierRetentionFees.clear();
                      }
                    },
                    activeColor: vehicalThemColor,
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<String>(
                    title: Text(
                      'Politique flexible'.tr,
                      style: TextStyle(
                        fontWeight: isFlexible ? FontWeight.bold : FontWeight.normal,
                        color: isFlexible ? vehicalThemColor : Colors.grey[900],
                      ),
                    ),
                    subtitle: Text(
                      'Paliers personnalisables avec remboursement partiel'.tr,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    value: 'flexible',
                    groupValue: selectedPolicyId.isNotEmpty ? selectedPolicyId : null,
                    onChanged: (String? value) {
                      if (value != null) {
                        vehicleController.selectedPolicyId.value = value;
                      }
                    },
                    activeColor: vehicalThemColor,
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  // ========== NIVEAU 2 : PALIERS API (Conditionnel - Si Flexible) ==========
                  if (isFlexible) ...[
                    const SizedBox(height: 24),
                    Obx(() {
                      final isLoading = vehicleController.isLoadingPolicies.value;
                      final policiesList = vehicleController.policiesList.toList();
                      final tierSwitches = vehicleController.tierSwitches;
                      
                      if (isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (policiesList.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Chargement des paliers...'.tr,
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        );
                      }
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paliers de remboursement'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[900],
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...policiesList.map((tier) {
                            String? tierId;
                            String tierTitle = '';
                            String tierDescription = '';
                            
                            if (tier is Map<String, dynamic>) {
                              tierId = tier['_id']?.toString() ?? tier['id']?.toString();
                              tierTitle = tier['title']?.toString() ?? 
                                        tier['name']?.toString() ?? 
                                        tier['policy_name']?.toString() ?? 
                                        'Palier';
                              tierDescription = tier['description']?.toString() ?? 
                                             tier['desc']?.toString() ?? '';
                            }
                            
                            if (tierId == null) return const SizedBox.shrink();
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Titre du palier
                                Padding(
                                  padding: const EdgeInsets.only(left: 4, bottom: 6, top: 6),
                                  child: Text(
                                    tierTitle,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[900],
                                    ),
                                  ),
                                ),
                                if (tierDescription.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                                    child: Text(
                                      tierDescription,
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ),
                                // Champ obligatoire (toujours affiché si Flexible)
                                Padding(
                                  padding: const EdgeInsets.only(left: 0, top: 4, bottom: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: 'Frais de retenue (%) '.tr,
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          children: const [
                                            TextSpan(
                                              text: '*',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      TextFormField(
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: 'Ex: 30',
                                          helperText: 'Si vous réglez sur 30%, vous conserverez 30% du montant et le client sera remboursé de 70%'.tr,
                                          helperMaxLines: 2,
                                          prefixIcon: const Icon(Icons.percent, size: 20),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: vehicalThemColor, width: 2),
                                          ),
                                        ),
                                        initialValue: vehicleController.tierRetentionFees[tierId] ?? '',
                                        onChanged: (String value) {
                                          vehicleController.tierRetentionFees[tierId!] = value;
                                        },
                                        validator: (String? value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Veuillez saisir un pourcentage'.tr;
                                          }
                                          final num = double.tryParse(value);
                                          if (num == null || num < 0 || num > 100) {
                                            return 'Le pourcentage doit être entre 0 et 100'.tr;
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),
                              ],
                            );
                          }).toList(),
                        ],
                      );
                    }),
                  ],
                ],
              );
            }),
          ),
          const SizedBox(height: 24),

          // ========== RÈGLES DU VÉHICULE ==========
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Règles du véhicule'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final isLoading = vehicleController.isLoadingRules.value;
                  final rulesList = vehicleController.rulesList.toList();
                  final selectedRules = vehicleController.selectedRules.toList();
                  
                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (rulesList.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Aucune règle disponible'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    );
                  }
                  
                  return Column(
                    children: rulesList.map((rule) {
                      String? ruleId;
                      String ruleTitle = '';
                      String? ruleDescription;
                      
                      if (rule is Map<String, dynamic>) {
                        ruleId = rule['_id']?.toString() ?? rule['id']?.toString();
                        ruleTitle = rule['title']?.toString() ?? 
                                   rule['name']?.toString() ?? 
                                   rule['rule_name']?.toString() ?? '';
                        ruleDescription = rule['description']?.toString() ?? 
                                        rule['desc']?.toString();
                      }
                      
                      final isSelected = ruleId != null && selectedRules.contains(ruleId);
                      
                      return CheckboxListTile(
                        title: Text(
                          ruleTitle.isNotEmpty ? ruleTitle : 'Règle',
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? vehicalThemColor : Colors.grey[900],
                          ),
                        ),
                        subtitle: ruleDescription != null && ruleDescription.isNotEmpty
                            ? Text(
                                ruleDescription,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              )
                            : null,
                        value: isSelected,
                        onChanged: (bool? value) {
                          if (ruleId != null) {
                            if (value == true) {
                              vehicleController.selectedRules.add(ruleId);
                            } else {
                              vehicleController.selectedRules.remove(ruleId);
                            }
                          }
                        },
                        activeColor: vehicalThemColor,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== ÉTAPE 7 : PHOTOS ==========
  Widget _buildStep7Photos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Photos du véhicule'.tr,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez au moins une photo de votre véhicule'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Zone d'upload avec bordure en pointillés (effet visuel)
          Obx(() {
            final selectedImages = vehicleController.selectedImages.toList();
            final mainIdx = vehicleController.mainImageIndex.value;
            
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selectedImages.isEmpty ? Colors.grey[300]! : Colors.grey[200]!,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: selectedImages.isEmpty
                  ? // État vide : Zone d'upload avec icône grise
                  GestureDetector(
                      onTap: () => vehicleController.pickMultipleImages(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: Column(
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Télécharger des photos'.tr,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Aucune photo ajoutée'.tr,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : // Grille de prévisualisation
                  Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: selectedImages.length + (selectedImages.length < 10 ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Bouton pour ajouter plus d'images
                          if (index == selectedImages.length) {
                            return GestureDetector(
                              onTap: () => vehicleController.pickMultipleImages(),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: vehicalThemColor,
                                    width: 2,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: vehicalThemColor,
                                  size: 32,
                                ),
                              ),
                            );
                          }
                          final bool isMain = index == mainIdx;
                          // Miniature avec sélection d'image principale et bouton de suppression
                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isMain ? const Color(0xFF27489E) : Colors.grey[300]!,
                                    width: isMain ? 3 : 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(selectedImages[index].path),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                              ),
                              // Étoile de sélection (principale ou sélectionner)
                              Positioned(
                                top: 6,
                                left: 6,
                                child: GestureDetector(
                                  onTap: () => vehicleController.setMainImage(index),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isMain ? Icons.star : Icons.star_border,
                                        color: isMain ? Colors.amber : Colors.white,
                                        size: 20,
                                      ),
                                      if (isMain)
                                        Container(
                                          margin: const EdgeInsets.only(left: 4),
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.9),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: const Color(0xFF27489E)),
                                          ),
                                          child: const Text(
                                            'Principale',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF27489E),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              // Bouton supprimer
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => vehicleController.removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
            );
          }),
        ],
      ),
    );
  }

  // ========== ÉTAPE 8 : DOCUMENTS ==========
  Widget _buildStep8Documents() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Documents du véhicule'.tr,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Téléchargez les documents requis pour votre véhicule'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Trois blocs de téléchargement alignés verticalement
          Column(
            children: [
              // Carte grise (Recto)
              _buildDocumentBlock(
                title: 'Carte grise (Recto)'.tr,
                type: 'recto',
                file: vehicleController.registrationCardRecto.value,
              ),
              const SizedBox(height: 16),
              
              // Carte grise (Verso)
              _buildDocumentBlock(
                title: 'Carte grise (Verso)'.tr,
                type: 'verso',
                file: vehicleController.registrationCardVerso.value,
              ),
              const SizedBox(height: 16),
              
              // Autorisation du ministère
              _buildDocumentBlock(
                title: 'Autorisation du ministère'.tr,
                type: 'authorization',
                file: vehicleController.ministryAuthorization.value,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget réutilisable pour un bloc de téléchargement de document
  Widget _buildDocumentBlock({
    required String title,
    required String type,
    File? file,
  }) {
    final bool hasFile = file != null;
    final String fileName = hasFile ? path.basename(file.path) : '';
    final bool isImage = hasFile && (fileName.toLowerCase().endsWith('.jpg') || 
                                     fileName.toLowerCase().endsWith('.jpeg') || 
                                     fileName.toLowerCase().endsWith('.png'));
    
    return Obx(() {
      // Re-observer les valeurs réactives
      final currentFile = type == 'recto' 
          ? vehicleController.registrationCardRecto.value
          : type == 'verso'
              ? vehicleController.registrationCardVerso.value
              : vehicleController.ministryAuthorization.value;
      
      final hasCurrentFile = currentFile != null;
      final currentFileName = hasCurrentFile ? path.basename(currentFile.path) : '';
      final isCurrentImage = hasCurrentFile && (currentFileName.toLowerCase().endsWith('.jpg') || 
                                                currentFileName.toLowerCase().endsWith('.jpeg') || 
                                                currentFileName.toLowerCase().endsWith('.png'));
      
      return GestureDetector(
        onTap: () => vehicleController.pickDocument(type),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasCurrentFile ? vehicalThemColor : Colors.grey[300]!,
              width: 2,
              style: BorderStyle.solid,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Aperçu du document ou icône d'upload
                if (hasCurrentFile && isCurrentImage)
                  // Miniature de l'image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      currentFile,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  )
                else if (hasCurrentFile)
                  // Icône PDF
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          size: 48,
                          color: Colors.red[700],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'PDF',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  // Icône d'upload
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.cloud_upload_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Titre
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // Nom du fichier ou texte explicatif
                if (hasCurrentFile)
                  Column(
                    children: [
                      Text(
                        currentFileName,
                        style: TextStyle(
                          fontSize: 12,
                          color: vehicalThemColor,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => vehicleController.removeDocument(type),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete_outline, size: 16, color: Colors.red[700]),
                              const SizedBox(width: 4),
                              Text(
                                'Supprimer'.tr,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'JPG, PNG, PDF (max 5MB)'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        );
    });
  }

  // ========== WIDGETS RÉUTILISABLES ==========

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: vehicalThemColor,
              width: 2,
            ),
          ),
          prefixIcon: icon != null ? Icon(icon, color: vehicalThemColor) : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: TextStyle(
          color: Colors.grey[900],
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildModernDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
    required String hint,
    required IconData icon,
    bool enabled = true,
    Key? key,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<T>(
        key: key,
        value: value,
        items: items,
        onChanged: enabled ? onChanged : null,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: vehicalThemColor,
              width: 2,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(icon, color: vehicalThemColor),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: TextStyle(
          color: enabled ? Colors.grey[900] : Colors.grey[500],
          fontSize: 15,
        ),
      ),
    );
  }

  // ========== BOUTONS DE NAVIGATION ==========
  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.transparent,
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back_rounded, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    Text('Précédent'.tr,
                        style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: Obx(() {
              final bool isSubmitting = vehicleController.isSubmittingVehicle.value;
              final bool isLoading = vehicleController.isLoading.value || isSubmitting;
              final bool enabled = _canProceedToNextStep() && !isLoading;

              return InkWell(
                onTap: enabled ? _nextStep : null,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: enabled
                          ? [const Color(0xFF27489E), const Color(0xFF3F64D9)]
                          : [Colors.grey[300]!, Colors.grey[300]!],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      if (enabled)
                        BoxShadow(
                          color: const Color(0xFF27489E).withOpacity(0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                    ],
                  ),
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentStep == _totalSteps - 1 ? 'Envoyer'.tr : 'Suivant'.tr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentStep == _totalSteps - 1
                                    ? Icons.check_rounded
                                    : Icons.arrow_forward_rounded,
                                color: Colors.white,
                              ),
                            ],
                          ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
