import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/controller/auth_controller.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/user_kyc_model.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import 'package:carvy/view/kyc/user_kyc.dart';
import 'package:carvy/view/myaccount/account_screen.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/work_space.dart';

class KycController extends GetxController implements GetxService {
  TextEditingController referenceMobileNo1 = TextEditingController();
  TextEditingController referenceMobileNo2 = TextEditingController();
  String sourec = "";
  String defaultCountryCodePrimary = "";
  String countryShortNamePrimary = "";
  String defaultCountryCodeSecondary = "";
  String countryShortNameSecondary = "";
  // Initialisation Sécurisée : Assure-toi que la variable réactive est déclarée avec une valeur par défaut non nulle
  RxString activeStatus = 'pending'.obs;
  String base64frontAddharFront = "";
  String base64addharBack = "";
  String base64OthertypeFront = "";
  String base64OthertypeBack = "";
  Rx<XFile?> addharFrontImage = Rx<XFile?>(null);
  Rx<XFile?> addharBackImage = Rx<XFile?>(null);
  Rx<XFile?> otherimageFront = Rx<XFile?>(null);
  Rx<XFile?> otherImageBack = Rx<XFile?>(null);

  // Variables pour stocker les URLs des images KYC depuis le backend
  RxString frontImageUrl = "".obs;
  RxString backImageUrl = "".obs;
  RxString otherFrontImageUrl = "".obs;
  RxString otherBackImageUrl = "".obs;
  int fileSizeThreshold = 500 * 1024;
  int goodQuality = 90;
  int badQuality = 70;
  int maxWidth = 800;
  int maxHeight = 800;

  UserKYC? userKycModel;
  var isdataLoading = false.obs;
  // Variable pour suivre si l'utilisateur a cliqué sur "Passer pour l'instant"
  var hasSkippedKyc = false.obs;
  // Variable pour suivre si l'utilisateur a passé le KYC dans la session actuelle
  var hasSkippedInSession = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Réinitialiser hasSkippedKyc au démarrage
    hasSkippedKyc.value = false;
    // Ne pas réinitialiser hasSkippedInSession ici car elle doit persister pendant la session de réservation
    // Synchronisation au démarrage : récupérer l'état actuel depuis le backend
    getKycDetails();
  }

  // Fonction pour changer l'état du flag de skip
  void setSkipKyc(bool value) {
    hasSkippedKyc.value = value;
  }

  // Méthode explicite pour by-passer le KYC dans la session actuelle
  void bypassKyc() {
    hasSkippedInSession.value = true;
    update();
  }

  String getImageFormat(Uint8List bytes) {
    if (bytes.lengthInBytes < 8) return '';
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
      return 'jpg';
    } else if (bytes[0] == 0x89 && bytes[1] == 0x50) {
      return 'png';
    } else {
      return '';
    }
  }

  void clearAllValues() {
    referenceMobileNo1.clear();
    referenceMobileNo2.clear();
    defaultCountryCodePrimary = "+212"; // Maroc par défaut
    countryShortNamePrimary = "MA"; // Code ISO Maroc
    defaultCountryCodeSecondary = "+212"; // Maroc par défaut
    countryShortNameSecondary = "MA"; // Code ISO Maroc
    activeStatus.value = "";
    base64frontAddharFront = "";
    base64addharBack = "";
    base64OthertypeFront = "";
    base64OthertypeBack = "";
    addharFrontImage.value = null;
    addharBackImage.value = null;
    otherimageFront.value = null;
    otherImageBack.value = null;
    // Réinitialiser les URLs des images
    frontImageUrl.value = "";
    backImageUrl.value = "";
    otherFrontImageUrl.value = "";
    otherBackImageUrl.value = "";
    update();
  }

  void validateKycImages() {}

  Future<String?> convertUrlToBase64(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) {
        throw Exception('Image URL is empty');
      }

      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        String base64Image = base64Encode(bytes);

        String format = getImageFormat(bytes);
        String base64String = 'data:image/$format;base64,$base64Image';

        print("Base64 Encoded Image: $base64String");
        return base64String;
      } else {
        throw Exception(
            'Failed to load image from URL (Status: ${response.statusCode})');
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> getUserKycData() async {
    // Marqueur d'entrée : Tout au début de la fonction
    print('🚀 [FLOW] Entrée dans getUserKycData...');
    
    // Log du rôle avant l'appel KYC
    try {
      AuthController? authController;
      try {
        authController = Get.find<AuthController>();
        print('🔍 [DEBUG] Statut du rôle avant crash: ${authController.userRole.value}');
      } catch (e) {
        print('⚠️ [DEBUG] AuthController non trouvé: $e');
      }
    } catch (e) {
      print('⚠️ [DEBUG] Erreur lors de la récupération du rôle: $e');
    }

    // Forcer l'activation : Supprimer la condition qui vérifie kycenable != 'Active'
    // Nous voulons que le statut soit récupéré peu importe ce réglage global
    // if (kycenable == "Active") {
    print('🚀 [FLOW] KYC - Forçage de l\'activation (ignorant kycenable)');
    
    try {
      clearAllValues();
    } catch (e) {
      print('⚠️ [KYC] Erreur lors de clearAllValues: $e');
    }
    
    isdataLoading.value = true;
    userKycModel = null;

    // Désactiver le cache : Supprimer la vérification du stockage local pour forcer un appel réseau systématique
    // var storedata = GetStorage().read("kycdata"); // COMMENTÉ : On ignore le cache
    print('🚀 [FLOW] Cache désactivé - Appel API systématique');

    try {
      // Forcer l'Appel Réseau : Assure-toi que la fonction exécute toujours http.get
      print('🚀 [FLOW] Appel API forcé (cache ignoré)');

      // Utiliser la configuration de baseurl au lieu d'une URL hardcodée (10.0.2.2 ne fonctionne que sur émulateur)
      final url = Config.baseurl + Config.getKYCDetails;
      print('🔗 [DEBUG] Appel API sur : $url');

      // Ajout des Headers : Assure-toi que le Token est bien présent
      // Vérifier si le bearer token est disponible, sinon le générer
      String currentBearerToken = bearerToken;
      if (currentBearerToken.isEmpty) {
        print(
            '🔑 [DEBUG] Bearer token vide, tentative de récupération depuis le stockage...');
        currentBearerToken = GetStorage().read("bearerToken") ?? "";
        if (currentBearerToken.isEmpty) {
          print(
              '⚠️ [DEBUG] Aucun bearer token disponible. La requête sera envoyée sans authentification.');
        }
      }

      print(
          '🔑 [DEBUG] Bearer token utilisé : ${currentBearerToken.isNotEmpty ? "${currentBearerToken.substring(0, 20)}..." : "VIDE"}');

      // Préparer les headers
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (currentBearerToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $currentBearerToken';
      }

      // Vérification de l'ID : Ajoute un print du userId envoyé au serveur pour vérifier qu'on demande le statut du bon utilisateur
      print('👤 [USER] userId envoyé au serveur : $userId');
      print('🔗 [DEBUG] Attempting to call: $url');
      print('📡 [FLOW] Envoi de la requête GET à : $url');
      print('📡 [FLOW] Headers : $headers');

      // Appel HTTP direct avec http.get
      final httpResponse = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print(
          '🚀 [FLOW] Réponse HTTP reçue, statusCode: ${httpResponse.statusCode}');
      print('🚀 [FLOW] Response body length: ${httpResponse.body.length}');

      // Print de la réponse brute : Diagnostic réseau profond
      print('📡 RAW BODY: ${httpResponse.body}');

      // Sécurisation du Parsing : Ajouter une vérification pour éviter le crash NoSuchMethodError
      Map<String, dynamic>? response;
      try {
        if (httpResponse.statusCode == 200) {
          response = jsonDecode(httpResponse.body) as Map<String, dynamic>?;
          print('✅ [SYNC] Données parsées avec succès');
        } else {
          print(
              '❌ [ERROR] Erreur HTTP ${httpResponse.statusCode}: ${httpResponse.body}');
          // Si le serveur répond une erreur, créer une structure d'erreur
          response = {
            'status': httpResponse.statusCode,
            'error': 'Erreur HTTP ${httpResponse.statusCode}',
            'message': httpResponse.body,
            'data': null,
          };
        }
      } catch (e, stackTrace) {
        print('💥 [ERROR] Erreur lors du parsing de la réponse : $e');
        print('💥 [ERROR] StackTrace: $stackTrace');
        print('💥 [ERROR] Body brut: ${httpResponse.body}');
        // Créer une structure d'erreur pour éviter le crash
        response = {
          'status': 500,
          'error': 'Erreur de parsing: $e',
          'message': 'Impossible de parser la réponse du serveur',
          'data': null,
        };
      }

      // Print du Body garanti : Utilise debugPrint pour éviter que les longs messages ne soient tronqués
      if (response != null) {
        debugPrint('📡 [RAW DATA]: ${jsonEncode(response)}');
        print('✅ [SYNC] Données reçues du serveur : ${jsonEncode(response)}');
      }

      // Sécurisation du Parsing : Vérifier que response n'est pas null avant de l'utiliser
      if (response != null) {
        userKycModel = UserKYC.fromJson(response);

        // Print de comparaison : voir ce que le serveur répond réellement
        if (response['data'] != null &&
            response['data']['kyc_status'] != null) {
          print(
              '📡 API RESP: Status reçu du serveur = ${response['data']['kyc_status']}');
        } else {
          print(
              '📡 API RESP: Aucun statut KYC trouvé dans la réponse du serveur');
          print(
              '📡 API RESP: Structure de response = ${response.keys.toList()}');
          if (response['data'] != null) {
            print(
                '📡 API RESP: Structure de data = ${(response['data'] as Map).keys.toList()}');
          }
        }

        var referenceData = userKycModel?.data?.kycReferenceData;
        if (referenceData != null) {
          referenceMobileNo1.text = referenceData.referencePrimaryMobileNo;
          defaultCountryCodePrimary =
              referenceData.referencePrimaryCountryCode == ""
                  ? "+212" // Maroc par défaut
                  : referenceData.referencePrimaryCountryCode;
          countryShortNamePrimary =
              referenceData.referencePrimaryCountryShortCode == ""
                  ? "MA" // Code ISO Maroc
                  : referenceData.referencePrimaryCountryShortCode;

          referenceMobileNo2.text = referenceData.referenceSecondaryMobileNo;
          defaultCountryCodeSecondary =
              referenceData.referenceSecondaryCountryCode == ""
                  ? "+212" // Maroc par défaut
                  : referenceData.referenceSecondaryCountryCode;
          countryShortNameSecondary =
              referenceData.referenceSecondaryCountryShortCode == ""
                  ? "MA" // Code ISO Maroc
                  : referenceData.referenceSecondaryCountryShortCode;
        }
        // Protection du Parsing : Modifie getUserKycData pour qu'il soit extrêmement robuste
        try {
          // Appel API... (response est déjà vérifié non-null au niveau supérieur)
          if (response['data'] != null) {
            // Print du mapping : Diagnostic réseau profond
            print('🎯 Mapped Status: ${response['data']['kyc_status']}');
            print(
                '🎯 [DIAGNOSTIC] Structure complète de response[\'data\']: ${response['data']}');

            String rawStatus =
                response['data']['kyc_status']?.toString() ?? 'pending';
            print('🎯 [DIAGNOSTIC] Raw Status (avant mapping): $rawStatus');

            // Forcer la casse pour éviter les erreurs "PENDING" vs "pending"
            String lowerStatus = rawStatus.toLowerCase();
            print('🎯 [DIAGNOSTIC] Lower Status: $lowerStatus');

            // Mapping : Transformer VERIFIED en approved pour l'interface
            String mappedStatus = lowerStatus;
            if (lowerStatus == "verified") {
              mappedStatus = "approved";
              print('🎯 [SYNC] Transformation verified -> approved');
            } else if (lowerStatus == "pending" || lowerStatus == "review") {
              mappedStatus = "pending";
              print('🎯 [SYNC] Transformation $lowerStatus -> pending');
            } else if (lowerStatus == "rejected") {
              mappedStatus = "rejected";
              print('🎯 [SYNC] Transformation rejected -> rejected');
            } else if (lowerStatus == "approved") {
              mappedStatus = "approved";
              print(
                  '🎯 [SYNC] Status déjà approved, pas de transformation nécessaire');
            } else {
              print(
                  '⚠️ [DIAGNOSTIC] Statut inconnu: $lowerStatus, conservé tel quel');
            }

            print(
                '🎯 [DIAGNOSTIC] Mapped Status (avant assignation): $mappedStatus');
            print(
                '🎯 [DIAGNOSTIC] activeStatus.value AVANT mise à jour: ${activeStatus.value}');

            activeStatus.value = mappedStatus;

            print(
                '🎯 [DIAGNOSTIC] activeStatus.value APRÈS mise à jour: ${activeStatus.value}');
            print('🎯 [SYNC] Status final : ${activeStatus.value}');

            // Forçage UI : Après avoir mis à jour activeStatus.value, forcer GetX à redessiner
            update();
            print(
                '🔄 [DIAGNOSTIC] update() appelé immédiatement après mise à jour de activeStatus');

            // Mise à jour du Stockage : Une fois que l'API répond, sauvegarder cette nouvelle valeur dans le stockage local
            if (response['data'] != null &&
                response['data']['kyc_status'] != null) {
              String statusToSave = response['data']['kyc_status'].toString();
              GetStorage().write('kyc_status', statusToSave);
              print(
                  '💾 [STORAGE] Statut KYC sauvegardé dans le stockage : $statusToSave');
            }

            // Sauvegarder aussi les données complètes si le statut est approved
            if (activeStatus.value == "yes" ||
                activeStatus.value == "approved") {
              GetStorage().write("kycdata", response);
              print(
                  '💾 [STORAGE] Données KYC complètes sauvegardées (statut approved)');
            }
          } else {
            // Si 404 ou erreur, on définit une valeur par défaut au lieu de crasher
            print(
                '⚠️ [KYC] Serveur hors ligne ou route 404. Statut par défaut: pending');
            activeStatus.value = 'pending';
          }
        } catch (e) {
          print('💥 Erreur GetX : $e');
          activeStatus.value = 'pending';
        } finally {
          // Notifie l'UI même en cas d'erreur
          update();
        }

        // Stocker les URLs des images KYC depuis l'API
        var kycImages = userKycModel?.data?.kycImages;
        if (kycImages != null) {
          // Stocker les URLs directement depuis l'API (driver_license_front_image, driver_license_back_image)
          frontImageUrl.value = kycImages.aadharFrontImage ?? "";
          backImageUrl.value = kycImages.aadharBackImage ?? "";
          otherFrontImageUrl.value = kycImages.otherIdentityFrontImage ?? "";
          otherBackImageUrl.value = kycImages.otherIdentityBackImage ?? "";

          // Convertir les URLs en base64 si nécessaire (pour compatibilité)
          var base64Results = await Future.wait([
            convertUrlToBase64(kycImages.aadharFrontImage ?? ""),
            convertUrlToBase64(kycImages.aadharBackImage ?? ""),
            convertUrlToBase64(kycImages.otherIdentityFrontImage ?? ""),
            convertUrlToBase64(kycImages.otherIdentityBackImage ?? "")
          ]);

          base64frontAddharFront = base64Results[0] ?? "";
          base64addharBack = base64Results[1] ?? "";
          base64OthertypeFront = base64Results[2] ?? "";
          base64OthertypeBack = base64Results[3] ?? "";
        } else {
          // Réinitialiser les URLs si pas d'images
          frontImageUrl.value = "";
          backImageUrl.value = "";
          otherFrontImageUrl.value = "";
          otherBackImageUrl.value = "";
        }

        // Forçage UI : Après avoir mis à jour kycStatus.value, forcer GetX à redessiner tous les widgets dépendants
        update();
        print('🔄 UI: update() appelé pour forcer le redessin des widgets');
      } else {
        print('🚀 [FLOW] Réponse invalide ou null');
        activeStatus.value = "";
      }
    } catch (e, stackTrace) {
      // Capture d'erreur immédiate : Enveloppe tout le contenu de la fonction dans un try-catch robuste
      print('💥 [FLOW] Erreur fatale dans getUserKycData : $e');
      print('💥 [FLOW] Type d\'erreur: ${e.runtimeType}');
      print('💥 [FLOW] StackTrace: $stackTrace');
      
      // Protection supplémentaire : s'assurer que les valeurs sont sécurisées
      try {
        activeStatus.value = "";
        userKycModel = null;
      } catch (innerError) {
        print('💥 [FLOW] Erreur lors de la réinitialisation des valeurs: $innerError');
      }
      
      // Ne pas rethrow l'erreur pour éviter le crash de l'application
      // L'application peut continuer à fonctionner même si le KYC échoue
    } finally {
      try {
        isdataLoading.value = false;
        // Rafraîchissement global : Appeler update() à la fin de la fonction pour forcer la disparition du bandeau orange
        update();
        print(
            '🔄 UI: update() appelé dans finally pour forcer le redessin final');
        print('🚀 [FLOW] Sortie de getUserKycData (finally)');
      } catch (e) {
        print('💥 [FLOW] Erreur dans le bloc finally: $e');
        // Même en cas d'erreur dans finally, on ne doit pas crasher
      }
    }
    // } else {
    //   print('🚀 [FLOW] KYC n\'est pas activé (kycenable != Active)');
    // }

    // Rafraîchir le rôle de l'utilisateur après le chargement des données KYC
    try {
      AuthController? authController = Get.find<AuthController>();
      authController.refreshUserRole();
      print('✅ [KYC] Rôle rafraîchi après getUserKycData');
    } catch (e) {
      print('⚠️ [KYC] Erreur lors du rafraîchissement du rôle: $e');
    }

    // Rafraîchissement global : Appeler update() à la fin de la fonction pour forcer la disparition du bandeau orange sur tous les écrans
    update();
    print('🚀 [FLOW] Fin de getUserKycData - update() final appelé');
  }

  /// Récupère les détails KYC de l'utilisateur
  /// Cette méthode appelle getUserKycData() pour obtenir les informations KYC à jour
  Future<void> getKycDetails() async {
    await getUserKycData();
  }

  Future<void> uplaodImageAddharFront(
      ImageSource source, BuildContext context) async {
    String sourec = source == ImageSource.camera ? "Camera" : "Gallery";

    try {
      // Optimisation : Réduire la qualité à 50 pour réduire le poids sans perdre la lisibilité
      var image = await ImagePicker().pickImage(
        source: source,
        imageQuality: 50, // Qualité réduite pour optimiser l'envoi
      );
      if (image == null) return;

      addharFrontImage.value = image;
      var imageFile = File(image.path);

      int imageSize = await imageFile.length();
      int quality = imageSize > fileSizeThreshold ? badQuality : goodQuality;

      var compressedImage = await FlutterImageCompress.compressWithFile(
        image.path,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
      );

      if (compressedImage == null || compressedImage.isEmpty) {
        throw Exception("Image compression failed.");
      }

      var base64Image = base64Encode(compressedImage);

      String format = '';
      if (compressedImage.length > 8) {
        if (compressedImage[0] == 0xFF && compressedImage[1] == 0xD8) {
          format = 'jpeg';
        } else if (compressedImage[0] == 0x89 && compressedImage[1] == 0x50) {
          format = 'png';
        }
      }

      base64frontAddharFront = "data:image/$format;base64,$base64Image";
    } on PlatformException {
      if (Platform.isIOS) {
        showOpenAppSettingsDialog(context,
            "$sourec permission denied. Please go to settings and allow the $sourec.");
      }
    } catch (e) {
      debugPrint("Error uploading Aadhar Front Image: $e");
    }
  }

  Future<void> uplaodImageAddharback(
      ImageSource source, BuildContext context) async {
    if (source == ImageSource.camera) {
      sourec = "Camera";
    } else {
      sourec = "Gallery";
    }
    try {
      // Optimisation : Réduire la qualité à 50 pour réduire le poids sans perdre la lisibilité
      var image = await ImagePicker().pickImage(
        source: source,
        imageQuality: 50, // Qualité réduite pour optimiser l'envoi
      );

      if (image == null) {
        return;
      }
      addharBackImage.value = image;
      var imageFile = File(image.path);
      int imageSize = await imageFile.length();
      int quality = imageSize > fileSizeThreshold ? badQuality : goodQuality;
      var compressedImage = await FlutterImageCompress.compressWithFile(
        image.path,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
      );

      var base64Image = base64Encode(compressedImage!);

      String format = '';
      if (compressedImage.length > 8) {
        if (compressedImage[0] == 0xFF && compressedImage[1] == 0xD8) {
          format = 'jpeg';
        } else if (compressedImage[0] == 0x89 && compressedImage[1] == 0x50) {
          format = 'png';
        }
      }
      base64addharBack = "data:image/$format;base64,$base64Image";
      print(base64addharBack);
    } on PlatformException {
      if (Platform.isIOS) {
        showOpenAppSettingsDialog(context,
            "${sourec} permission denied. Please go to settings and allow the ${sourec}.");
      }
    }
  }

  Future<void> uploadotherIdentiotyFront(
      ImageSource source, BuildContext context) async {
    if (source == ImageSource.camera) {
      sourec = "Camera";
    } else {
      sourec = "Gallery";
    }
    try {
      var image = await ImagePicker().pickImage(source: source);

      if (image == null) {
        return;
      }
      otherimageFront.value = image;
      var imageFile = File(image.path);
      int imageSize = await imageFile.length();
      int quality = imageSize > fileSizeThreshold ? badQuality : goodQuality;
      var compressedImage = await FlutterImageCompress.compressWithFile(
        image.path,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
      );

      var base64Image = base64Encode(compressedImage!);

      String format = '';
      if (compressedImage.length > 8) {
        if (compressedImage[0] == 0xFF && compressedImage[1] == 0xD8) {
          format = 'jpeg';
        } else if (compressedImage[0] == 0x89 && compressedImage[1] == 0x50) {
          format = 'png';
        }
      }
      base64OthertypeFront = "data:image/$format;base64,$base64Image";
    } on PlatformException {
      if (Platform.isIOS) {
        showOpenAppSettingsDialog(context,
            "${sourec} permission denied. Please go to settings and allow the ${sourec}.");
      }
    }
  }

  Future<void> uploadotherIdentiotyBack(
      ImageSource source, BuildContext context) async {
    if (source == ImageSource.camera) {
      sourec = "Camera";
    } else {
      sourec = "Gallery";
    }
    try {
      var image = await ImagePicker().pickImage(source: source);

      if (image == null) {
        return;
      }

      otherImageBack.value = image;
      var imageFile = File(image.path);
      int imageSize = await imageFile.length();
      int quality = imageSize > fileSizeThreshold ? badQuality : goodQuality;
      var compressedImage = await FlutterImageCompress.compressWithFile(
        image.path,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
      );

      var base64Image = base64Encode(compressedImage!);

      String format = '';
      if (compressedImage.length > 8) {
        if (compressedImage[0] == 0xFF && compressedImage[1] == 0xD8) {
          format = 'jpeg';
        } else if (compressedImage[0] == 0x89 && compressedImage[1] == 0x50) {
          format = 'png';
        }
      }
      base64OthertypeBack = "data:image/$format;base64,$base64Image";
    } on PlatformException {
      if (Platform.isIOS) {
        showOpenAppSettingsDialog(context,
            "${sourec} permission denied. Please go to settings and allow the ${sourec}.");
      }
    }
  }

  Future<void> submit(BuildContext context) async {
    if (addharFrontImage.value == null) {
      showErrorToastMessage("Please select Driver license Front Image".tr);
      return;
    }
    if (addharBackImage.value == null) {
      showErrorToastMessage("Please select Driver license Back Image".tr);
      return;
    }

    if (base64OthertypeFront != "" && base64OthertypeBack == "") {
      showErrorToastMessage("Please select Other Identity Back Image".tr);
      return;
    }
    if (base64OthertypeBack != "" && base64OthertypeFront == "") {
      showErrorToastMessage("Please select Other Identity Front Image".tr);
      return;
    }
    if (referenceMobileNo1.text.isEmpty) {
      showErrorToastMessage("Please add Primary Reference MoB No".tr);
      return;
    }

    try {
      showLoading();

      // Créer une requête multipart
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Config.baseurl}${Config.addKycforCustomer}'),
      );

      // Ajouter le token d'authentification dans les en-têtes
      if (bearerToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $bearerToken';
      }

      // Note: Ne PAS définir Content-Type manuellement pour multipart/form-data
      // MultipartRequest gère automatiquement le Content-Type avec la boundary appropriée
      // Exemple: "multipart/form-data; boundary=----WebKitFormBoundary..."

      // Vérifier que les fichiers existent avant de les ajouter
      // Utiliser MultipartFile.fromPath avec les clés attendues par le backend Node.js
      if (addharFrontImage.value != null) {
        var frontImageFile = File(addharFrontImage.value!.path);
        if (await frontImageFile.exists()) {
          // fromPath est la méthode recommandée pour créer un MultipartFile depuis un chemin
          // Elle gère automatiquement la lecture asynchrone du fichier
          // Forcer le Content-Type en image/jpeg pour l'acceptation par Multer
          var frontFile = await http.MultipartFile.fromPath(
            'driver_license_front_image', // Clé attendue par Node.js
            frontImageFile.path,
            contentType:
                MediaType('image', 'jpeg'), // Force l'acceptation par Multer
          );
          request.files.add(frontFile);
        } else {
          closeLoading();
          showErrorToastMessage(
              "Le fichier du permis de conduire recto est introuvable".tr);
          return;
        }
      } else {
        closeLoading();
        showErrorToastMessage(
            "Veuillez sélectionner le permis de conduire recto".tr);
        return;
      }

      // Ajouter le fichier du permis de conduire verso
      if (addharBackImage.value != null) {
        var backImageFile = File(addharBackImage.value!.path);
        if (await backImageFile.exists()) {
          // fromPath est la méthode recommandée pour créer un MultipartFile depuis un chemin
          // Elle gère automatiquement la lecture asynchrone du fichier
          // Forcer le Content-Type en image/jpeg pour l'acceptation par Multer
          var backFile = await http.MultipartFile.fromPath(
            'driver_license_back_image', // Clé attendue par Node.js
            backImageFile.path,
            contentType:
                MediaType('image', 'jpeg'), // Force l'acceptation par Multer
          );
          request.files.add(backFile);
        } else {
          closeLoading();
          showErrorToastMessage(
              "Le fichier du permis de conduire verso est introuvable".tr);
          return;
        }
      } else {
        closeLoading();
        showErrorToastMessage(
            "Veuillez sélectionner le permis de conduire verso".tr);
        return;
      }

      // Ajouter le numéro de référence primaire (selon le contrat API)
      request.fields['reference_primary_mobile_no'] = referenceMobileNo1.text;
      request.fields['reference_primary_country_code'] =
          defaultCountryCodePrimary;
      request.fields['reference_primary_country_short_code'] =
          countryShortNamePrimary;

      // Ajouter les références secondaires si disponibles
      if (referenceMobileNo2.text.isNotEmpty) {
        request.fields['reference_secondary_mobile_no'] =
            referenceMobileNo2.text;
        request.fields['reference_secondary_country_code'] =
            defaultCountryCodeSecondary;
        request.fields['reference_secondary_country_short_code'] =
            countryShortNameSecondary;
      }

      // Logs de requête : Afficher la taille des fichiers avant l'envoi
      debugPrint("📤 [KYC Upload] Préparation de l'envoi des fichiers...");
      if (addharFrontImage.value != null) {
        var frontFile = File(addharFrontImage.value!.path);
        if (await frontFile.exists()) {
          var frontSize = await frontFile.length();
          var frontSizeKB = (frontSize / 1024).toStringAsFixed(2);
          debugPrint(
              "📤 [KYC Upload] driver_license_front_image: ${frontSizeKB} KB");
        }
      }
      if (addharBackImage.value != null) {
        var backFile = File(addharBackImage.value!.path);
        if (await backFile.exists()) {
          var backSize = await backFile.length();
          var backSizeKB = (backSize / 1024).toStringAsFixed(2);
          debugPrint(
              "📤 [KYC Upload] driver_license_back_image: ${backSizeKB} KB");
        }
      }
      var totalFields = request.fields.length;
      var totalFiles = request.files.length;
      debugPrint(
          "📤 [KYC Upload] Total: $totalFiles fichier(s), $totalFields champ(s)");
      debugPrint(
          "📤 [KYC Upload] URL: ${Config.baseurl}${Config.addKycforCustomer}");

      // Envoyer la requête
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      closeLoading();

      // Parser la réponse JSON
      Map<String, dynamic>? responseData;
      try {
        responseData = jsonDecode(response.body) as Map<String, dynamic>?;
      } catch (e) {
        debugPrint("Error parsing response: $e");
        showErrorToastMessage(
            "Erreur lors de la lecture de la réponse du serveur".tr);
        return;
      }

      if (response.statusCode == 200) {
        if (responseData != null && responseData["status"] == 200) {
          // Mise à jour immédiate du statut KYC AVANT le Get.back() pour que le bandeau apparaisse
          activeStatus.value =
              "pending"; // Statut "En attente" après soumission

          // Mettre à jour le modèle KYC local avec le nouveau statut
          if (userKycModel != null && userKycModel!.data != null) {
            // Créer une copie mise à jour des données KYC avec le nouveau statut
            var updatedKycData = {
              "status": 200,
              "message":
                  responseData["message"] ?? "KYC submitted successfully",
              "error": "",
              "data": {
                "kyc_images": userKycModel!.data!.kycImages.toJson(),
                "kyc_reference_data":
                    userKycModel!.data!.kycReferenceData?.toJson(),
                "kyc_status": "pending" // Nouveau statut
              }
            };
            // Mettre à jour le stockage local pour persister le statut
            GetStorage().write("kycdata", updatedKycData);
            // Mettre à jour le modèle en mémoire
            userKycModel = UserKYC.fromJson(updatedKycData);
          }

          update(); // Notifier les listeners du changement

          // Revenir immédiatement à l'écran de détails du véhicule
          Get.back();

          // Afficher le dialogue de succès sur l'écran de détails après un court délai
          // pour s'assurer que l'écran est bien chargé
          Future.delayed(Duration(milliseconds: 300), () {
            Get.defaultDialog(
              title: 'Succès',
              middleText:
                  'Documents envoyés avec succès ! Votre permis est en cours de validation par nos équipes.',
              textConfirm: 'OK',
              confirmTextColor: Colors.white,
              onConfirm: () {
                Get.back(); // Fermer le dialogue
              },
            );
          });
        } else {
          showErrorToastMessage(responseData?["error"]?.toString() ??
              "Une erreur est survenue".tr);
        }
      } else {
        showErrorToastMessage(responseData?["error"]?.toString() ??
            "Une erreur est survenue lors de l'envoi (Code: ${response.statusCode})"
                .tr);
      }
    } catch (e, stackTrace) {
      closeLoading();
      debugPrint("Error in submit: $e");
      debugPrint("StackTrace: $stackTrace");
      showErrorToastMessage(
          "Une erreur est survenue. Veuillez réessayer plus tard.".tr);
    }
  }

  Map<String, dynamic> getReviewStatus() {
    // Mapper les statuts selon le contrat API (kyc_status)
    switch (activeStatus.value) {
      case "approved":
      case "yes": // Compatibilité avec l'ancien format
        return {"text": "Vérifié", "color": Colors.green};
      case "pending":
      case "review": // Compatibilité avec l'ancien format
        return {"text": "Vérification en cours", "color": Colors.orange};
      case "rejected":
      case "reject": // Compatibilité avec l'ancien format
        return {"text": "Rejeté", "color": Colors.red};
      case "no":
      case "":
        return {"text": "", "color": null};
      default:
        return {"text": "", "color": null};
    }
  }

  Future<bool> kycStatus(var status, BuildContext context) async {
    if (kycenable == "Active") {
      if (status == null) {
        return false;
      }

      // Ne pas bloquer pour "pending" - permettre la continuation du processus de réservation
      if (status.toString().toLowerCase() == "pending") {
        return true;
      }

      if (status.toString() == "review") {
        await showModalBottomSheet(
          backgroundColor: whiteColor,
          context: context,
          useSafeArea: true,
          builder: (context) {
            return _buildKycBottomSheet(
                context,
                "Your KYC request is under review. Please wait for the admin to approve.",
                "Review");
          },
        );
        return false;
      } else if (status.toString() == "reject") {
        await showModalBottomSheet(
          backgroundColor: whiteColor,
          context: context,
          useSafeArea: true,
          builder: (context) {
            return _buildKycBottomSheet(
                context, "Your request is rejected.", "Apply Again");
          },
        );
        return false;
      } else if (status.toString() == "no") {
        await showModalBottomSheet(
          backgroundColor: whiteColor,
          context: context,
          useSafeArea: true,
          builder: (context) {
            return _buildKycBottomSheet(
                context, "Please fill your KYC Form.", "Apply");
          },
        );
        return false;
      }
    }

    return true;
  }

  Widget _buildKycBottomSheet(
      BuildContext context, String message, String actionName) {
    return Container(
      height: 250,
      width: Get.width,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Icon(Icons.info, size: 51, color: acentColor),
            const SizedBox(height: 20),
            Text(
              message.tr,
              style: regular3(context).copyWith(color: blackColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                            margin: const EdgeInsets.only(left: 8, right: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: redColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                                child: Text(
                              "Back".tr,
                              style: TextStyle(
                                  color: whiteColor,
                                  fontWeight: FontWeight.bold),
                            ))))),
                actionName == "Review"
                    ? SizedBox()
                    : Expanded(
                        child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              Get.to(UserKyc());
                            },
                            child: Container(
                                margin:
                                    const EdgeInsets.only(left: 8, right: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    border: Border.all(color: themeColor),
                                    color: themeColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                    child: Text(
                                  "$actionName".tr,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ))))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
