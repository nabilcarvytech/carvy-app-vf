import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:carvy/api/config.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/snackbar_service.dart';
import 'package:carvy/view/auth/agency_registration_pending_screen.dart';
import 'package:carvy/work_space.dart';

/// Controller pour gérer l'inscription des agences
/// Stocke toutes les données du formulaire multi-étapes
class AgencyController extends GetxController implements GetxService {
  // ========== ÉTAPE 1 : IDENTITÉ DU GÉRANT ==========
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // ========== ÉTAPE 2 : INFORMATIONS AGENCE ==========
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  
  // Forme légale sélectionnée
  RxString selectedLegalForm = ''.obs;
  
  // Logo de l'agence
  Rx<XFile?> agencyLogo = Rx<XFile?>(null);
  
  // Base64 du logo (pour l'envoi à l'API)
  RxString agencyLogoBase64 = ''.obs;

  // ========== PARAMÈTRES DE COMPRESSION ==========
  static const int maxFileSizeBytes = 500 * 1024; // 500 Ko
  static const int maxWidth = 800;
  static const int maxHeight = 800;
  static const int initialQuality = 90;
  static const int minQuality = 50;

  // ========== ÉTAPE 3 : APPEL DE VALIDATION ==========
  // Date sélectionnée pour l'appel de validation
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  
  // Créneau horaire sélectionné
  RxString selectedTimeSlot = ''.obs;

  // État de chargement pour l'envoi du formulaire
  RxBool isLoading = false.obs;

  // ========== MÉTHODES DE GESTION ==========
  
  /// Compresse une image jusqu'à ce qu'elle fasse moins de 500 Ko
  /// Retourne le chemin du fichier compressé ou null en cas d'erreur
  Future<XFile?> _compressImage(XFile imageFile) async {
    try {
      final File originalFile = File(imageFile.path);
      final int originalSize = await originalFile.length();

      // Si l'image fait déjà moins de 500 Ko, on la retourne telle quelle
      if (originalSize <= maxFileSizeBytes) {
        return imageFile;
      }

      // Obtenir le répertoire temporaire
      final Directory tempDir = await getTemporaryDirectory();
      final String targetPath = path.join(
        tempDir.path,
        'agency_logo_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Compression itérative avec réduction progressive de la qualité
      int quality = initialQuality;
      List<int>? compressedBytes;
      int compressedSize = originalSize;

      while (compressedSize > maxFileSizeBytes && quality >= minQuality) {
        compressedBytes = await FlutterImageCompress.compressWithFile(
          imageFile.path,
          quality: quality,
          minWidth: maxWidth,
          minHeight: maxHeight,
        );

        if (compressedBytes == null || compressedBytes.isEmpty) {
          throw Exception('La compression de l\'image a échoué');
        }

        compressedSize = compressedBytes.length;

        // Si on a atteint la taille cible, on arrête
        if (compressedSize <= maxFileSizeBytes) {
          break;
        }

        // Réduire la qualité pour la prochaine itération
        quality -= 10;
      }

      // Si après toutes les tentatives l'image est toujours trop grande,
      // on réduit encore les dimensions
      if (compressedSize > maxFileSizeBytes) {
        int reducedWidth = maxWidth;
        int reducedHeight = maxHeight;

        while (compressedSize > maxFileSizeBytes && reducedWidth > 400) {
          reducedWidth = (reducedWidth * 0.9).round();
          reducedHeight = (reducedHeight * 0.9).round();

          compressedBytes = await FlutterImageCompress.compressWithFile(
            imageFile.path,
            quality: minQuality,
            minWidth: reducedWidth,
            minHeight: reducedHeight,
          );

          if (compressedBytes == null || compressedBytes.isEmpty) {
            throw Exception('La compression de l\'image a échoué');
          }

          compressedSize = compressedBytes.length;
        }
      }

      // Écrire le fichier compressé
      final File compressedFile = File(targetPath);
      await compressedFile.writeAsBytes(compressedBytes!);

      // Retourner le nouveau XFile
      return XFile(compressedFile.path);
    } catch (e) {
      debugPrint('Erreur lors de la compression de l\'image: $e');
      // En cas d'erreur, retourner l'image originale
      return imageFile;
    }
  }

  /// Définit le logo de l'agence avec compression automatique
  /// L'image sera compressée pour ne pas dépasser 500 Ko
  Future<void> setAgencyLogo(XFile? logo) async {
    if (logo == null) {
      agencyLogo.value = null;
      agencyLogoBase64.value = '';
      return;
    }

    try {
      // Compresser l'image
      final XFile? compressedLogo = await _compressImage(logo);
      
      if (compressedLogo != null) {
        agencyLogo.value = compressedLogo;
        
        // Générer le base64 pour l'envoi à l'API
        final File compressedFile = File(compressedLogo.path);
        final List<int> imageBytes = await compressedFile.readAsBytes();
        final String base64Image = base64Encode(imageBytes);
        
        // Déterminer le format de l'image
        String format = 'jpeg';
        if (imageBytes.length > 8) {
          if (imageBytes[0] == 0xFF && imageBytes[1] == 0xD8) {
            format = 'jpeg';
          } else if (imageBytes[0] == 0x89 && imageBytes[1] == 0x50) {
            format = 'png';
          }
        }
        
        agencyLogoBase64.value = "data:image/$format;base64,$base64Image";
      } else {
        // Si la compression échoue, utiliser l'image originale
        agencyLogo.value = logo;
      }
    } catch (e) {
      debugPrint('Erreur lors du traitement du logo: $e');
      // En cas d'erreur, utiliser l'image originale
      agencyLogo.value = logo;
    }
  }

  /// Définit la date sélectionnée pour l'appel de validation
  void setSelectedDate(DateTime? date) {
    selectedDate.value = date;
  }

  /// Définit le créneau horaire sélectionné
  void setSelectedTimeSlot(String? slot) {
    selectedTimeSlot.value = slot ?? '';
  }

  /// Définit la forme légale sélectionnée
  void setSelectedLegalForm(String? form) {
    selectedLegalForm.value = form ?? '';
  }

  /// Réinitialise toutes les données du formulaire
  void resetForm() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    companyNameController.clear();
    addressController.clear();
    selectedLegalForm.value = '';
    agencyLogo.value = null;
    agencyLogoBase64.value = '';
    selectedDate.value = null;
    selectedTimeSlot.value = '';
    isLoading.value = false;
  }

  /// Vérifie si toutes les données requises sont remplies
  bool isFormComplete() {
    return firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        companyNameController.text.isNotEmpty &&
        selectedLegalForm.value.isNotEmpty &&
        addressController.text.isNotEmpty &&
        agencyLogo.value != null &&
        selectedDate.value != null &&
        selectedTimeSlot.value.isNotEmpty;
  }

  /// Soumet l'inscription de l'agence au backend
  /// Utilise Dio avec FormData pour envoyer les données et le fichier logo
  Future<void> submitRegistration() async {
    // Vérifier que toutes les données sont remplies
    if (!isFormComplete()) {
      showErrorToastMessage('Veuillez remplir tous les champs obligatoires');
      return;
    }

    // Vérifier que le logo existe
    if (agencyLogo.value == null) {
      showErrorToastMessage('Veuillez sélectionner un logo pour l\'agence');
      return;
    }

    try {
      isLoading.value = true;
      showLoading();

      // Créer une instance Dio
      final dio.Dio dioInstance = dio.Dio();

      // Créer FormData
      final dio.FormData formData = dio.FormData.fromMap({
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'companyName': companyNameController.text,
        'email': emailController.text,
        'phoneNumber': phoneController.text,
        'countryCode': '+212',
        'legalForm': selectedLegalForm.value,
        'address': addressController.text,
        'password': passwordController.text,
        // Date et créneau horaire pour l'appel de validation
        'validationDate': selectedDate.value != null
            ? '${selectedDate.value!.year}-${selectedDate.value!.month.toString().padLeft(2, '0')}-${selectedDate.value!.day.toString().padLeft(2, '0')}'
            : '',
        'validationTimeSlot': selectedTimeSlot.value,
      });

      // Ajouter le fichier logo
      final File logoFile = File(agencyLogo.value!.path);
      if (await logoFile.exists()) {
        // Déterminer le nom du fichier avec l'extension appropriée
        String filename = 'logo.png';
        final String extension = path.extension(logoFile.path).toLowerCase();
        if (extension.isNotEmpty) {
          filename = 'logo$extension';
        }

        formData.files.add(
          MapEntry(
            'logo',
            await dio.MultipartFile.fromFile(
              logoFile.path,
              filename: filename,
            ),
          ),
        );
      } else {
        closeLoading();
        showErrorToastMessage('Le fichier logo est introuvable');
        return;
      }

      // Construire l'URL complète
      // Utiliser /api/auth/agency/register comme demandé
      // Utiliser Config.baseUrlWithoutV1 pour éviter /v1
      final String baseUrl = Config.baseUrlWithoutV1;
      final String url = '${baseUrl}auth/agency/register';

      debugPrint('📤 [AGENCY_REGISTER] Envoi de la requête à: $url');
      debugPrint('📤 [AGENCY_REGISTER] Données: ${formData.fields}');

      // Envoyer la requête POST
      final dio.Response response = await dioInstance.post(
        url,
        data: formData,
        options: dio.Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      isLoading.value = false;
      closeLoading();

      debugPrint('📥 [AGENCY_REGISTER] Réponse reçue: ${response.statusCode}');
      debugPrint('📥 [AGENCY_REGISTER] Données: ${response.data}');

      // Vérifier la réponse
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = response.data is Map
            ? Map<String, dynamic>.from(response.data)
            : jsonDecode(response.data.toString());

        // Vérifier si success est true
        if (responseData['success'] == true ||
            responseData['status'] == 200) {
          // Afficher un message de succès
          showToastMessage(
            responseData['message'] ?? 'Inscription envoyée avec succès !',
          );

          // Réinitialiser le formulaire
          resetForm();

          // Rediriger vers l'écran de confirmation
          if (webPlateForm) {
            Get.offAllNamed(WebRoutes.agencyRegistrationPendingScreen);
          } else {
            Get.offAll(() => const AgencyRegistrationPendingScreen());
          }
        } else {
          // Erreur dans la réponse
          final String errorMessage = responseData['error'] ??
              responseData['message'] ??
              'Une erreur est survenue lors de l\'inscription';
          showErrorToastMessage(errorMessage);
        }
      } else if (response.statusCode == 400) {
        // Gestion spécifique pour le status 400 (Validation failed)
        try {
          dynamic rawData = response.data;
          debugPrint('🔍 [AGENCY_REGISTER] Status 400 - Type de rawData: ${rawData.runtimeType}');
          
          Map<String, dynamic> responseData;
          if (rawData is Map) {
            responseData = Map<String, dynamic>.from(rawData);
          } else if (rawData is String) {
            responseData = jsonDecode(rawData) as Map<String, dynamic>;
          } else {
            responseData = jsonDecode(rawData.toString()) as Map<String, dynamic>;
          }
          
          debugPrint('🔍 [AGENCY_REGISTER] Status 400 - responseData parsé: $responseData');
          debugPrint('🔍 [AGENCY_REGISTER] Status 400 - errors présent: ${responseData.containsKey('errors')}');
          
          String specificError = '';
          
          if (responseData['errors'] != null) {
            // On récupère le premier message d'erreur trouvé dans l'objet 'errors'
            var errorsMap = responseData['errors'] as Map<String, dynamic>;
            debugPrint('🔍 [AGENCY_REGISTER] Status 400 - errorsMap: $errorsMap');
            specificError = errorsMap.values.first.toString();
            debugPrint('✅ [AGENCY_REGISTER] Status 400 - Message extrait: $specificError');
          } else {
            specificError = responseData['message']?.toString() ?? 'Erreur de validation';
            debugPrint('⚠️ [AGENCY_REGISTER] Status 400 - Pas d\'errors, utilisation du message: $specificError');
          }

          // Affichage immédiat du message réel
          debugPrint('📢 [AGENCY_REGISTER] Status 400 - Affichage du snackbar avec: $specificError');
          
          // Utiliser Get.snackbar ET showErrorToastMessage pour garantir l'affichage
          Get.safeSnackbar(
            'Erreur d\'inscription',
            specificError, // Affichera 'This email is already in use'
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
            margin: const EdgeInsets.all(16),
            borderRadius: 8,
          );
          
          // Fallback avec toast pour garantir l'affichage
          showErrorToastMessage(specificError);
        } catch (parseError, stackTrace) {
          // En cas d'erreur de parsing, utiliser le message par défaut
          debugPrint('❌ [AGENCY_REGISTER] Status 400 - Erreur de parsing: $parseError');
          debugPrint('❌ [AGENCY_REGISTER] Status 400 - StackTrace: $stackTrace');
          showErrorToastMessage('Erreur de validation: ${parseError.toString()}');
        }
      } else {
        showErrorToastMessage(
          'Erreur lors de l\'envoi de la requête (${response.statusCode})',
        );
      }
    } on dio.DioException catch (e) {
      isLoading.value = false;
      closeLoading();
      debugPrint('❌ [AGENCY_REGISTER] Erreur Dio: ${e.message}');
      debugPrint('❌ [AGENCY_REGISTER] Status Code: ${e.response?.statusCode}');
      debugPrint('❌ [AGENCY_REGISTER] Erreur: ${e.response?.data}');

      // Gestion spécifique pour le status 400 (Validation failed)
      if (e.response?.statusCode == 400) {
        try {
          dynamic rawData = e.response!.data;
          debugPrint('🔍 [AGENCY_REGISTER] Type de rawData: ${rawData.runtimeType}');
          
          Map<String, dynamic> responseData;
          if (rawData is Map) {
            responseData = Map<String, dynamic>.from(rawData);
          } else if (rawData is String) {
            responseData = jsonDecode(rawData) as Map<String, dynamic>;
          } else {
            responseData = jsonDecode(rawData.toString()) as Map<String, dynamic>;
          }
          
          debugPrint('🔍 [AGENCY_REGISTER] responseData parsé: $responseData');
          debugPrint('🔍 [AGENCY_REGISTER] errors présent: ${responseData.containsKey('errors')}');
          
          String specificError = '';
          
          if (responseData['errors'] != null) {
            // On récupère le premier message d'erreur trouvé dans l'objet 'errors'
            var errorsMap = responseData['errors'] as Map<String, dynamic>;
            debugPrint('🔍 [AGENCY_REGISTER] errorsMap: $errorsMap');
            specificError = errorsMap.values.first.toString();
            debugPrint('✅ [AGENCY_REGISTER] Message extrait: $specificError');
          } else {
            specificError = responseData['message']?.toString() ?? 'Erreur de validation';
            debugPrint('⚠️ [AGENCY_REGISTER] Pas d\'errors, utilisation du message: $specificError');
          }

          // Affichage immédiat du message réel
          debugPrint('📢 [AGENCY_REGISTER] Affichage du snackbar avec: $specificError');
          
          // Utiliser Get.snackbar ET showErrorToastMessage pour garantir l'affichage
          Get.safeSnackbar(
            'Erreur d\'inscription',
            specificError, // Affichera 'This email is already in use'
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
            margin: const EdgeInsets.all(16),
            borderRadius: 8,
          );
          
          // Fallback avec toast pour garantir l'affichage
          showErrorToastMessage(specificError);
        } catch (parseError, stackTrace) {
          // En cas d'erreur de parsing, utiliser le message par défaut
          debugPrint('❌ [AGENCY_REGISTER] Erreur de parsing: $parseError');
          debugPrint('❌ [AGENCY_REGISTER] StackTrace: $stackTrace');
          showErrorToastMessage('Erreur de validation: ${parseError.toString()}');
        }
      } else {
        // Gestion des autres erreurs Dio
      String errorMessage = 'Une erreur est survenue lors de l\'inscription';
      if (e.response != null && e.response!.data != null) {
        final Map<String, dynamic>? errorData = e.response!.data is Map
            ? Map<String, dynamic>.from(e.response!.data)
            : null;
        if (errorData != null) {
          errorMessage = errorData['error'] ??
              errorData['message'] ??
              errorMessage;
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }

      showErrorToastMessage(errorMessage);
      }
    } catch (e) {
      isLoading.value = false;
      closeLoading();
      debugPrint('❌ [AGENCY_REGISTER] Erreur inattendue: $e');
      showErrorToastMessage(
        'Une erreur inattendue est survenue: ${e.toString()}',
      );
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    companyNameController.dispose();
    addressController.dispose();
    super.onClose();
  }
}
