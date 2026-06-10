import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../api/config.dart';
import '../customwidget/miscellaneous_project_elements.dart';
import '../model/booking_model.dart';
import '../model/extension_payment_context.dart';
import '../work_space.dart';

/// Controller pour gérer les enregistrements de réservations (booking records)
/// Connecté à l'API Node.js locale via POST /api/v1/booking-record
class BookingRecordController extends GetxController implements GetxService {
  // ========== ÉTATS DE CHARGEMENT ==========
  var isLoading = false.obs;
  var isSuccess = false.obs;
  var hasError = false.obs;
  String? errorMessage;

  // ========== DONNÉES ==========
  BookingModel? bookingModel;
  // Liste principale pour stocker toutes les réservations chargées
  // Utilisation de RxList pour une meilleure réactivité avec GetX
  RxList<Bookings> bookingsList = <Bookings>[].obs;
  num offset = 0;
  
  // Garder une trace du type actuel pour éviter les mélanges
  String? currentType;

  // ========== FONCTION PRINCIPALE : getBookingRecord() ==========
  /// Récupère les réservations depuis l'API Node.js
  /// [type] : "upcoming", "ongoing", "previous", ou "Cancelled"
  /// [offset] : Offset pour la pagination (optionnel, par défaut 0)
  Future<void> getBookingRecord({
    required String type,
    num? offset,
  }) async {
      // Réinitialiser l'état d'erreur
      hasError.value = false;
      errorMessage = null;

      // ========== NORMALISATION DU TYPE ==========
      // Normaliser le type : "Cancelled" -> "cancelled"
      String normalizedType = type.toLowerCase();
      if (normalizedType == 'cancelled') {
        normalizedType = 'cancelled';
      }

      // Utiliser l'offset fourni ou celui du controller
      num currentOffset = offset ?? this.offset;
      
      // Déterminer si c'est une nouvelle recherche (pas de pagination)
      // Si offset est null, c'est une pagination, sinon c'est une nouvelle recherche si offset == 0
      bool isNewSearch = offset != null && offset == 0;
      bool isTypeChanged = currentType != normalizedType;
      
      // ========== 1. RÉINITIALISATION DE LA LISTE ==========
      // Si offset est explicitement 0 (nouvelle recherche) ou si le type a changé, vider la liste
      if (isNewSearch || isTypeChanged) {
        debugPrint('🔄 [BookingRecord] Réinitialisation de la liste...');
        debugPrint('   • isNewSearch: $isNewSearch (offset fourni: ${offset != null ? offset : "null"})');
        debugPrint('   • isTypeChanged: $isTypeChanged (${currentType} → $normalizedType)');
        debugPrint('   • Liste avant clear: ${bookingsList.length} réservations');
        
        bookingsList.clear();
        this.offset = 0;
        currentOffset = 0;
        
        if (isTypeChanged) {
          currentType = normalizedType;
          debugPrint('🔄 [BookingRecord] Type changé de ${currentType} à $normalizedType, liste réinitialisée');
        } else {
          debugPrint('🔄 [BookingRecord] Nouvelle recherche (offset=0), liste réinitialisée');
        }
        
        debugPrint('   • Liste après clear: ${bookingsList.length} réservations');
      } else {
        debugPrint('📄 [BookingRecord] Pagination - offset: $currentOffset, liste actuelle: ${bookingsList.length} réservations');
      }

      isLoading.value = true;
      isSuccess.value = false;

      try {
        // ========== 1. RÉCUPÉRATION DU TOKEN ==========
        String? authToken = GetStorage().read('token') ?? token;
        if (authToken.isEmpty) {
          // Essayer de récupérer depuis UserData
          try {
            var userData = GetStorage().read('UserData');
            if (userData != null) {
              var userDataMap = jsonDecode(userData);
              if (userDataMap['data'] != null && userDataMap['data']['token'] != null) {
                authToken = userDataMap['data']['token'].toString();
              }
            }
          } catch (e) {
            debugPrint('❌ [BookingRecord] Erreur lors de la récupération du token: $e');
          }
        }

        if (authToken == null || authToken.isEmpty) {
          hasError.value = true;
          errorMessage = 'Token d\'authentification manquant';
          isLoading.value = false;
          update();
          return;
        }

        // ========== 2. CONSTRUCTION DE L'URL ==========
        String url = '${Config.baseurl}${Config.upcommingRecord}';

        // ========== 3. CONSTRUCTION DU BODY ==========

      Map<String, dynamic> requestBody = {
        "type": normalizedType,
        "offset": currentOffset.toString(),
      };

      // ========== 4. DEBUG LOGS ==========
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('📤 [BookingRecord] URL: $url');
      debugPrint('📤 [BookingRecord] Type: $normalizedType');
      debugPrint('📤 [BookingRecord] Offset: $currentOffset');
      debugPrint('📤 [BookingRecord] x-auth-token: ${authToken.length > 20 ? "${authToken.substring(0, 20)}..." : authToken}');
      debugPrint('📤 [BookingRecord] Request Body: ${jsonEncode(requestBody)}');
      debugPrint('═══════════════════════════════════════════════════════');

      // ========== 5. ENVOI DE LA REQUÊTE POST ==========
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': authToken,
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('La requête a expiré');
        },
      );

      // ========== 6. DEBUG: PRINT RÉPONSE BRUTE ==========
      print('📥 [BookingRecord] Réponse brute du serveur: ${response.body}');
      debugPrint('📥 [BookingRecord] Status Code: ${response.statusCode}');
      debugPrint('📥 [BookingRecord] Response Body Length: ${response.body.length}');

      // ========== 7. PARSING JSON ==========
      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
        debugPrint('✅ [BookingRecord] JSON parsing réussi');
      } catch (e, stackTrace) {
        debugPrint('❌ [BookingRecord] ERREUR DE PARSING JSON: $e');
        debugPrint('❌ [BookingRecord] StackTrace: $stackTrace');
        hasError.value = true;
        errorMessage = 'Format de réponse invalide';
        isLoading.value = false;
        update();
        return;
      }

      // ========== 8. VÉRIFICATION DU STATUS CODE ==========
      if (response.statusCode != 200) {
        String errorMsg = responseData['message'] ?? 
                         responseData['error'] ?? 
                         'Erreur lors de la récupération des réservations';
        hasError.value = true;
        errorMessage = errorMsg;
        isLoading.value = false;
        update();
        return;
      }

      // ========== 9. MAPPING DES DONNÉES ==========
      // Vérifier que la clé 'data' existe
      if (!responseData.containsKey('data')) {
        debugPrint('❌ [BookingRecord] ERREUR: responseData ne contient pas la clé "data"');
        debugPrint('❌ [BookingRecord] Clés disponibles: ${responseData.keys.toList()}');
        hasError.value = true;
        errorMessage = 'Réponse incomplète du serveur';
        isLoading.value = false;
        update();
        return;
      }

      // Vérifier que 'data' contient 'Bookings'
      if (!responseData['data'].containsKey('Bookings')) {
        debugPrint('❌ [BookingRecord] ERREUR: responseData["data"] ne contient pas la clé "Bookings"');
        hasError.value = true;
        errorMessage = 'Format de réponse invalide: clé Bookings manquante';
        isLoading.value = false;
        update();
        return;
      }

      // ========== 10. PRINT DES ATTENTES DU MODÈLE ==========
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('📋 [BookingRecord] ATTENTES DU MODÈLE BookingModel:');
      debugPrint('   Clés principales attendues dans responseData:');
      debugPrint('     • status (num?)');
      debugPrint('     • message (String?)');
      debugPrint('     • data (Map)');
      debugPrint('       - Bookings (List)');
      debugPrint('       - offset (num?)');
      debugPrint('       - limit (num?)');
      debugPrint('');
      debugPrint('   Clés attendues pour chaque Booking dans Bookings:');
      debugPrint('     • _id ou id (String?) - ID MongoDB');
      debugPrint('     • itemid (String?)');
      debugPrint('     • userid (String?)');
      debugPrint('     • host_id (String?)');
      debugPrint('     • check_in (String?)');
      debugPrint('     • check_out (String?)');
      debugPrint('     • status (String?)');
      debugPrint('     • total_day (String?)');
      debugPrint('     • per_day (String?)');
      debugPrint('     • base_price (String?)');
      debugPrint('     • service_charge (String?)');
      debugPrint('     • iva_tax (String?)');
      debugPrint('     • security_money (String?)');
      debugPrint('     • total_guest (String?)');
      debugPrint('     • total (String?)');
      debugPrint('     • currency_code (String?) ⚠️ CRITIQUE pour l\'affichage du prix');
      debugPrint('     • item_title (String?)');
      debugPrint('     • image (String?)');
      debugPrint('     • item_data (String/List?) - JSON stringifié');
      debugPrint('     • pick_otp (String?)');
      debugPrint('     • drop_otp (String?)');
      debugPrint('     • payment_method (String?)');
      debugPrint('     • payment_status (String?)');
      debugPrint('     • wall_amt (String?)');
      debugPrint('     • host_name, host_number, host_email (String?)');
      debugPrint('     • user_name, user_number, user_email (String?)');
      debugPrint('═══════════════════════════════════════════════════════');
      
      // ========== 10. PARSING DU MODÈLE ==========
      debugPrint('🔍 [BookingRecord] Début du parsing du modèle...');
      debugPrint('🔍 [BookingRecord] Nombre de Bookings dans responseData: ${responseData['data']['Bookings']?.length ?? 0}');
      
      // ========== DEBUG DES CLÉS MANQUANTES POUR CHAQUE RÉSERVATION ==========
      if (responseData['data']['Bookings'] != null && responseData['data']['Bookings'] is List) {
        List bookingsList = responseData['data']['Bookings'];
        debugPrint('🔍 [BookingRecord] Vérification des clés pour ${bookingsList.length} réservations...');
        
        for (int i = 0; i < bookingsList.length; i++) {
          Map<String, dynamic>? bookingJson = bookingsList[i] is Map ? Map<String, dynamic>.from(bookingsList[i]) : null;
          if (bookingJson == null) continue;
          
          debugPrint('═══════════════════════════════════════════════════════');
          debugPrint('🔍 [BookingRecord] Vérification Booking #$i:');
          debugPrint('   Clés disponibles: ${bookingJson.keys.toList()}');
          
          // Vérification des clés critiques
          List<String> missingKeys = [];
          
          if (bookingJson['_id'] == null && bookingJson['id'] == null) {
            missingKeys.add('_id/id');
            print('⚠️ [BookingRecord] Booking #$i: Clé _id/id manquante');
          }
          if (bookingJson['itemid'] == null) {
            missingKeys.add('itemid');
            print('⚠️ [BookingRecord] Booking #$i: Clé itemid manquante');
          }
          if (bookingJson['per_day'] == null) {
            missingKeys.add('per_day');
            print('⚠️ [BookingRecord] Booking #$i: Clé per_day manquante');
          }
          if (bookingJson['currency_code'] == null) {
            missingKeys.add('currency_code');
            print('⚠️ [BookingRecord] Booking #$i: Clé currency_code manquante ⚠️ CAUSE DU "null 127.5"');
          }
          if (bookingJson['total'] == null) {
            missingKeys.add('total');
            print('⚠️ [BookingRecord] Booking #$i: Clé total manquante');
          }
          if (bookingJson['item_title'] == null) {
            missingKeys.add('item_title');
            print('⚠️ [BookingRecord] Booking #$i: Clé item_title manquante');
          }
          if (bookingJson['item_data'] == null) {
            missingKeys.add('item_data');
            print('⚠️ [BookingRecord] Booking #$i: Clé item_data manquante');
          }
          if (bookingJson['check_in'] == null) {
            missingKeys.add('check_in');
            print('⚠️ [BookingRecord] Booking #$i: Clé check_in manquante');
          }
          if (bookingJson['check_out'] == null) {
            missingKeys.add('check_out');
            print('⚠️ [BookingRecord] Booking #$i: Clé check_out manquante');
          }
          if (bookingJson['status'] == null) {
            missingKeys.add('status');
            print('⚠️ [BookingRecord] Booking #$i: Clé status manquante');
          }
          
          if (missingKeys.isEmpty) {
            debugPrint('✅ [BookingRecord] Booking #$i: Toutes les clés critiques sont présentes');
          } else {
            debugPrint('❌ [BookingRecord] Booking #$i: ${missingKeys.length} clé(s) manquante(s): $missingKeys');
          }
          
          // Log des valeurs importantes pour debug
          debugPrint('   • _id/id: ${bookingJson['_id'] ?? bookingJson['id']}');
          debugPrint('   • currency_code: ${bookingJson['currency_code']} (null = cause "null 127.5")');
          debugPrint('   • total: ${bookingJson['total']}');
          debugPrint('   • per_day: ${bookingJson['per_day']}');
          debugPrint('   • item_title: ${bookingJson['item_title']}');
          debugPrint('   • pick_otp: ${bookingJson['pick_otp']} (null = badge OTP vide)');
          debugPrint('   • drop_otp: ${bookingJson['drop_otp']}');
          
          // ========== 1. PRINT DE L'OBJET DÉCODÉ item_data ==========
          if (bookingJson['item_data'] != null) {
            try {
              dynamic itemDataRaw = bookingJson['item_data'];
              dynamic itemDataDecoded;
              
              // Si c'est une String, la décoder
              if (itemDataRaw is String) {
                itemDataDecoded = jsonDecode(itemDataRaw);
                debugPrint('   • item_data est une String, décodage effectué');
              } else {
                itemDataDecoded = itemDataRaw;
                debugPrint('   • item_data est déjà un objet (${itemDataRaw.runtimeType})');
              }
              
              debugPrint('═══════════════════════════════════════════════════════');
              debugPrint('📦 [BookingRecord] CONTENU EXACT DE item_data pour Booking #$i:');
              debugPrint('   Type: ${itemDataDecoded.runtimeType}');
              
              if (itemDataDecoded is List && itemDataDecoded.isNotEmpty) {
                debugPrint('   item_data est une Liste de ${itemDataDecoded.length} élément(s)');
                Map<String, dynamic>? firstItem = itemDataDecoded[0] is Map 
                    ? Map<String, dynamic>.from(itemDataDecoded[0]) 
                    : null;
                
                if (firstItem != null) {
                  debugPrint('   Clés disponibles dans item_data[0]: ${firstItem.keys.toList()}');
                  debugPrint('   Contenu complet de item_data[0]:');
                  firstItem.forEach((key, value) {
                    debugPrint('     - $key: $value (type: ${value?.runtimeType})');
                  });
                  
                  // Vérification spécifique de no_of_seats et item_type
                  if (firstItem.containsKey('no_of_seats')) {
                    debugPrint('   ✅ no_of_seats trouvé: ${firstItem['no_of_seats']}');
                  } else {
                    debugPrint('   ⚠️ no_of_seats MANQUANT dans item_data[0]');
                  }
                  
                  if (firstItem.containsKey('item_type')) {
                    debugPrint('   ✅ item_type trouvé: ${firstItem['item_type']}');
                  } else {
                    debugPrint('   ⚠️ item_type MANQUANT dans item_data[0]');
                  }
                  
                  // Vérification de item_info (qui contient number_of_seats)
                  if (firstItem.containsKey('item_info')) {
                    debugPrint('   ✅ item_info trouvé (type: ${firstItem['item_info'].runtimeType})');
                    try {
                      dynamic itemInfoRaw = firstItem['item_info'];
                      Map<String, dynamic>? itemInfoMap;
                      
                      if (itemInfoRaw is String) {
                        itemInfoMap = Map<String, dynamic>.from(jsonDecode(itemInfoRaw));
                        debugPrint('   item_info est une String JSON, décodage effectué');
                      } else if (itemInfoRaw is Map) {
                        itemInfoMap = Map<String, dynamic>.from(itemInfoRaw);
                        debugPrint('   item_info est déjà un Map');
                      }
                      
                      if (itemInfoMap != null) {
                        debugPrint('   Clés disponibles dans item_info: ${itemInfoMap.keys.toList()}');
                        if (itemInfoMap.containsKey('number_of_seats')) {
                          debugPrint('   ✅ number_of_seats trouvé dans item_info: ${itemInfoMap['number_of_seats']}');
                        } else {
                          debugPrint('   ⚠️ number_of_seats MANQUANT dans item_info');
                          debugPrint('   Contenu de item_info:');
                          itemInfoMap.forEach((key, value) {
                            debugPrint('     - $key: $value');
                          });
                        }
                      }
                    } catch (e) {
                      debugPrint('   ❌ Erreur lors du décodage de item_info: $e');
                    }
                  } else {
                    debugPrint('   ⚠️ item_info MANQUANT dans item_data[0]');
                  }
                } else {
                  debugPrint('   ⚠️ item_data[0] n\'est pas un Map valide');
                }
              } else if (itemDataDecoded is Map) {
                debugPrint('   item_data est un Map');
                Map<String, dynamic> itemDataMap = Map<String, dynamic>.from(itemDataDecoded);
                debugPrint('   Clés disponibles: ${itemDataMap.keys.toList()}');
                debugPrint('   Contenu complet:');
                itemDataMap.forEach((key, value) {
                  debugPrint('     - $key: $value (type: ${value?.runtimeType})');
                });
              } else {
                debugPrint('   ⚠️ item_data a un type inattendu: ${itemDataDecoded.runtimeType}');
              }
              debugPrint('═══════════════════════════════════════════════════════');
            } catch (e, stackTrace) {
              debugPrint('❌ [BookingRecord] Erreur lors du décodage de item_data pour Booking #$i: $e');
              debugPrint('❌ [BookingRecord] StackTrace: $stackTrace');
            }
          } else {
            debugPrint('   ⚠️ item_data est null pour Booking #$i');
          }
        }
        debugPrint('═══════════════════════════════════════════════════════');
      }
      
      bookingModel = BookingModel.fromJson(responseData);
      
      if (bookingModel != null && bookingModel!.data != null) {
        // Ajouter les nouvelles réservations à la liste avec vérification des doublons
        if (bookingModel!.data!.bookings != null && bookingModel!.data!.bookings!.isNotEmpty) {
          debugPrint('📋 [BookingRecord] ${bookingModel!.data!.bookings!.length} réservations reçues du serveur');
          debugPrint('📋 [BookingRecord] Liste actuelle avant ajout: ${bookingsList.length} réservations');
          
          // ========== 2. GESTION DES DOUBLONS ==========
          // Créer un Set des IDs existants pour une vérification rapide
          Set<String?> existingIds = bookingsList.map((b) => b.id).toSet();
          
          // Filtrer les nouveaux bookings qui ne sont pas déjà dans la liste
          List<Bookings> newBookings = bookingModel!.data!.bookings!.where((newBooking) {
            // Vérifier si le booking existe déjà par son ID
            if (newBooking.id == null) {
              debugPrint('⚠️ [BookingRecord] Booking avec ID null ignoré');
              return false;
            }

            // Enrichissement client : même structure véhicule que vendor-booking-record
            newBooking.enrichVehicleFieldsLikeVendor();
            debugPrint(
              '🚗 [BookingRecord] Après enrich — itemid: ${newBooking.itemid}, '
              'vehicleId: ${newBooking.vehicleId}, titre: ${newBooking.propTitle}',
            );

            if (existingIds.contains(newBooking.id)) {
              debugPrint('⚠️ [BookingRecord] Booking dupliqué ignoré - ID: ${newBooking.id}');
              return false;
            }
            
            // Ajouter l'ID au Set pour éviter les doublons dans la même réponse
            existingIds.add(newBooking.id);
            debugPrint('✅ [BookingRecord] Booking ajouté - ID: ${newBooking.id}');
            return true;
          }).toList();
          
          // Ajouter uniquement les nouveaux bookings (sans doublons)
          if (newBookings.isNotEmpty) {
            bookingsList.addAll(newBookings);
            debugPrint('📊 [BookingRecord] ${newBookings.length} nouveau(x) booking(s) ajouté(s)');
          } else {
            debugPrint('⚠️ [BookingRecord] Aucun nouveau booking à ajouter (tous sont des doublons)');
          }
          
          debugPrint('✅ [BookingRecord] Total dans la liste après ajout: ${bookingsList.length} réservations');
          
          // ========== 3. RAFRAÎCHISSEMENT DE L'UI ==========
          // RxList notifie automatiquement GetX, mais on appelle update() pour être sûr
          update();
        } else {
          debugPrint('⚠️ [BookingRecord] bookingModel.data.bookings est null ou vide');
        }
        
        // Mettre à jour l'offset pour la pagination
        if (bookingModel!.data!.offset != null) {
          this.offset = bookingModel!.data!.offset!;
          debugPrint('📄 [BookingRecord] Offset mis à jour: ${this.offset}');
        } else {
          // Si offset est null, mettre à -1 pour désactiver la pagination
          this.offset = -1;
          debugPrint('📄 [BookingRecord] Offset null, désactivation pagination');
        }

        // ========== 11. VÉRIFICATION FINALE DES DONNÉES PARSÉES ==========
        debugPrint('═══════════════════════════════════════════════════════');
        debugPrint('🔍 [BookingRecord] VÉRIFICATION FINALE DES DONNÉES:');
        debugPrint('   • Nombre de réservations: ${bookingsList.length}');
        
        // ========== 🧪 TEST FINAL - Vérification après parsing ==========
        if (bookingsList.isNotEmpty) {
          var firstBooking = bookingsList[0];
          print('═══════════════════════════════════════════════════════');
          print('🧪 TEST FINAL - Booking ID: ${firstBooking.id}');
          print('🧪 TEST FINAL - pickOtp: ${firstBooking.pickOtp}'); // Si c'est null ici, le modèle est le coupable
          print('🧪 TEST FINAL - dropOtp: ${firstBooking.dropOtp}');
          print('🧪 TEST FINAL - itemid: ${firstBooking.itemid}');
          
          // Extraction de number_of_seats pour le test
          if (firstBooking.itemData != null) {
            try {
              dynamic itemDataDecoded = firstBooking.itemData;
              if (firstBooking.itemData is String) {
                itemDataDecoded = jsonDecode(firstBooking.itemData.toString());
              }
              
              if (itemDataDecoded is List && itemDataDecoded.isNotEmpty) {
                Map<String, dynamic>? firstItem = itemDataDecoded[0] is Map 
                    ? Map<String, dynamic>.from(itemDataDecoded[0]) 
                    : null;
                
                if (firstItem != null && firstItem.containsKey('item_info')) {
                  dynamic itemInfoRaw = firstItem['item_info'];
                  Map<String, dynamic>? itemInfoMap;
                  
                  if (itemInfoRaw is String) {
                    itemInfoMap = Map<String, dynamic>.from(jsonDecode(itemInfoRaw));
                  } else if (itemInfoRaw is Map) {
                    itemInfoMap = Map<String, dynamic>.from(itemInfoRaw);
                  }
                  
                  if (itemInfoMap != null) {
                    dynamic seats = itemInfoMap['number_of_seats'];
                    print('🧪 TEST FINAL - Seats (number_of_seats): ${seats ?? "null"}');
                    print('🧪 TEST FINAL - item_type: ${firstItem['item_type'] ?? "null"}');
                  }
                }
              }
            } catch (e) {
              print('🧪 TEST FINAL - Erreur extraction sièges: $e');
            }
          }
          print('═══════════════════════════════════════════════════════');
        }
        
        for (int i = 0; i < bookingsList.length; i++) {
          var b = bookingsList[i];
          debugPrint('   • Booking[$i]:');
          debugPrint('     - ID: ${b.id}');
          debugPrint('     - Status: ${b.status}');
          debugPrint('     - Total: ${b.total} (type: ${b.total?.runtimeType})');
          debugPrint('     - item_title: ${b.propTitle}');
          debugPrint('     - item_data: ${b.itemData != null ? "présent (${b.itemData.runtimeType})" : "null"}');
          debugPrint('     - address: ${b.itemData != null ? "à extraire de item_data" : "null"}');
          
          // ========== 2. ANALYSE DE LA VUE - Vérification pickOtp ==========
          debugPrint('     - pickOtp: ${b.pickOtp ?? "null"} ${b.pickOtp == null ? "⚠️ BADGE OTP SERA VIDE" : "✅ OK"}');
          debugPrint('     - dropOtp: ${b.dropOtp ?? "null"}');
          
          // Vérification de item_data pour les sièges
          if (b.itemData != null) {
            try {
              dynamic itemDataDecoded = b.itemData;
              if (b.itemData is String) {
                itemDataDecoded = jsonDecode(b.itemData.toString());
              }
              
              if (itemDataDecoded is List && itemDataDecoded.isNotEmpty) {
                Map<String, dynamic>? firstItem = itemDataDecoded[0] is Map 
                    ? Map<String, dynamic>.from(itemDataDecoded[0]) 
                    : null;
                
                if (firstItem != null && firstItem.containsKey('item_info')) {
                  try {
                    dynamic itemInfoRaw = firstItem['item_info'];
                    Map<String, dynamic>? itemInfoMap;
                    
                    if (itemInfoRaw is String) {
                      itemInfoMap = Map<String, dynamic>.from(jsonDecode(itemInfoRaw));
                    } else if (itemInfoRaw is Map) {
                      itemInfoMap = Map<String, dynamic>.from(itemInfoRaw);
                    }
                    
                    if (itemInfoMap != null) {
                      dynamic seats = itemInfoMap['number_of_seats'];
                      debugPrint('     - number_of_seats (depuis item_info): ${seats ?? "null"} ${seats == null ? "⚠️ SIÈGES SERONT NULL" : "✅ OK"}');
                    }
                  } catch (e) {
                    debugPrint('     - Erreur extraction number_of_seats: $e');
                  }
                }
              }
            } catch (e) {
              debugPrint('     - Erreur analyse item_data pour sièges: $e');
            }
          }
        }
        debugPrint('═══════════════════════════════════════════════════════');

        isSuccess.value = true;
        hasError.value = false;
        debugPrint('✅ [BookingRecord] ${bookingsList.length} réservations chargées avec succès');
      } else {
        debugPrint('❌ [BookingRecord] bookingModel ou bookingModel.data est null');
        hasError.value = true;
        errorMessage = 'Aucune donnée dans la réponse';
      }

    } catch (e, stackTrace) {
      debugPrint('❌ [BookingRecord] Erreur: $e');
      debugPrint('❌ [BookingRecord] StackTrace: $stackTrace');
      hasError.value = true;
      errorMessage = 'Erreur de connexion: ${e.toString()}';
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // ========== FONCTION POUR RÉINITIALISER LA LISTE ==========
  /// Réinitialise la liste et l'offset (utilisé pour le refresh)
  void resetList() {
    bookingsList.clear();
    offset = 0;
    bookingModel = null;
    currentType = null;
    isSuccess.value = false;
    hasError.value = false;
    errorMessage = null;
    update(); // Notifier GetX du changement
  }

  // ========== FONCTION POUR SUPPRIMER UNE RÉSERVATION DE LA LISTE ==========
  /// Supprime une réservation de la liste (utilisé après annulation)
  void removeBooking(int index) {
    if (index >= 0 && index < bookingsList.length) {
      bookingsList.removeAt(index);
      update();
    }
  }

  String? _userAuthToken() {
    String? authToken = GetStorage().read('token')?.toString();
    if (authToken != null && authToken.isNotEmpty) {
      return authToken;
    }
    if (token.isNotEmpty) {
      return token;
    }
    try {
      final userData = GetStorage().read('UserData');
      if (userData != null) {
        final userDataMap = jsonDecode(userData);
        final nested = userDataMap['data']?['token']?.toString();
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }
    } catch (e) {
      debugPrint('❌ [BookingRecord] _userAuthToken: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> _postReservationAuthed(
    String path,
    Map<String, dynamic> body,
  ) async {
    final authToken = _userAuthToken();
    if (authToken == null || authToken.isEmpty) {
      showErrorToastMessage('Something went wrong'.tr);
      return null;
    }

    try {
      final response = await http
          .post(
            Uri.parse('${Config.baseurl}$path'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
              'x-auth-token': authToken,
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      Map<String, dynamic> decoded;
      try {
        decoded = Map<String, dynamic>.from(jsonDecode(response.body));
      } catch (e) {
        debugPrint('❌ [BookingRecord] extend JSON parse: $e');
        showErrorToastMessage('Something went wrong'.tr);
        return null;
      }
      decoded['statusCode'] = response.statusCode;
      return decoded;
    } catch (e) {
      debugPrint('❌ [BookingRecord] _postReservationAuthed: $e');
      showErrorToastMessage(e.toString());
      return null;
    }
  }

  /// POST /api/v1/reservations/:id/extend-preview
  Future<Map<String, dynamic>?> extendReservationPreview({
    required String bookingId,
    required String newEndDate,
  }) async {
    final response = await _postReservationAuthed(
      Config.reservationExtendPreview(bookingId),
      {'new_end_date': newEndDate},
    );
    if (response == null) return null;

    final ok = response['statusCode'] == 200 ||
        response['status'] == 200 ||
        response['status'] == '200' ||
        response['success'] == true;
    if (!ok) {
      showErrorToastMessage(
        response['error']?.toString() ??
            response['message']?.toString() ??
            'Error'.tr,
      );
      return null;
    }

    final data = response['data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    showErrorToastMessage('Something went wrong'.tr);
    return null;
  }

  /// POST /api/v1/reservations/:id/extend-confirm
  Future<bool> extendReservationConfirm({
    required String bookingId,
    required String newEndDate,
    String? paymentMethodId,
  }) async {
    final result = await extendReservationConfirmWithDetails(
      bookingId: bookingId,
      newEndDate: newEndDate,
      paymentMethodId: paymentMethodId,
    );
    return result?.success == true;
  }

  /// Même route que [extendReservationConfirm], avec détails (ex. payment_url).
  Future<ReservationExtendConfirmResult?> extendReservationConfirmWithDetails({
    required String bookingId,
    required String newEndDate,
    String? paymentMethodId,
  }) async {
    final body = <String, dynamic>{'new_end_date': newEndDate};
    if (paymentMethodId != null && paymentMethodId.trim().isNotEmpty) {
      body['payment_method_id'] = paymentMethodId.trim();
    }

    final response = await _postReservationAuthed(
      Config.reservationExtendConfirm(bookingId),
      body,
    );
    if (response == null) return null;

    final ok = response['statusCode'] == 200 ||
        response['status'] == 200 ||
        response['status'] == '200' ||
        response['success'] == true;

    String? paymentUrl;
    final data = response['data'];
    if (data is Map) {
      paymentUrl = data['payment_url']?.toString() ??
          data['paymentUrl']?.toString();
    }
    paymentUrl ??= response['payment_url']?.toString();

    if (ok) {
      return ReservationExtendConfirmResult(
        success: true,
        paymentUrl: paymentUrl,
        message: response['message']?.toString(),
      );
    }

    showErrorToastMessage(
      response['error']?.toString() ??
          response['message']?.toString() ??
          'Error'.tr,
    );
    return ReservationExtendConfirmResult(
      success: false,
      paymentUrl: paymentUrl,
      message: response['message']?.toString(),
    );
  }
}

