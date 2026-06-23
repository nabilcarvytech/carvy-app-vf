import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/controller/add_items_host_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/calendar_model.dart';
import 'package:carvy/model/my_items_model.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/host/bottom_bar_host.dart';
import 'package:carvy/utils/rolling_calendar_bounds.dart';
import 'package:carvy/utils/safe_navigation.dart';
import 'package:carvy/utils/safe_rebuild.dart';
import 'package:carvy/view/host/calender/add_price_on_common_calander.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import 'package:carvy/view/host/initial_host_common_screen.dart';
import 'package:carvy/work_space.dart';

class CalendarCommonScreen extends StatefulWidget {
  const CalendarCommonScreen({super.key});

  @override
  State<CalendarCommonScreen> createState() => _CalendarCommonScreenState();
}

class _CalendarCommonScreenState extends State<CalendarCommonScreen> {
  /// Parse une date de calendrier en ignorant totalement l'heure envoyée par le serveur.
  /// - Accepte des formats avec ou sans heure (ex: "2025-03-23", "2025-03-23T00:00:00Z", etc.)
  /// - Extrait uniquement la partie "YYYY-MM-DD"
  /// - Retourne un `DateTime(year, month, day)` en **local**, pour rester aligné
  ///   avec le comportement du widget de calendrier (qui fonctionne en heure locale).
  DateTime? parseCalendarDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      // On extrait uniquement les 10 premiers caractères (YYYY-MM-DD)
      final String dateOnly =
          dateStr.length >= 10 ? dateStr.substring(0, 10) : dateStr;
      final parts = dateOnly.split('-');
      if (parts.length == 3) {
        final int year = int.parse(parts[0]);
        final int month = int.parse(parts[1]);
        final int day = int.parse(parts[2]);
        // On crée une date **locale** (pas UTC) pour éviter le décalage d'un jour
        // lorsque le widget de calendrier interprète la date selon le fuseau local.
        return DateTime(year, month, day);
      }
    } catch (e) {
      print('Erreur de parsing de date: $dateStr');
    }
    return null;
  }

  AddItemsHostController addItemsHostController = Get.find();
  DateRangePickerController dateRangePickerControllers =
      DateRangePickerController();
  bool isDateSelected = false;
  List<PickerDateRange> selectedDates = [];
  List selectedPriceMap = [];
  List selectedAvailableRange = [];
  List selectedNotAvailableRange = [];
  List myNewDateAndStatusListAvailable = [];
  List myNewDateAndStatusListNotAvailable = [];
  List<PickerDateRange> initialList = [];
  String endDate = '';
  String startDate = '';
  List<PickerDateRange> availableDates = [];
  List<PickerDateRange> notAvailableDates = [];
  List<PickerDateRange> bookedDates = [];
  CalendarItemId? calendarItemId;
  ItemDates? itemDates;
  List<String> avialblePrice = [];
  dynamic futurePrice;
  dynamic bookedPrice;
  String defaultVehiclePrice = "0";
  String vehicleBasePrice = "0"; // Prix de base du véhicule
  String currency = "MAD";
  // Map pour stocker les prix par date (clé: "yyyy-MM-dd", valeur: prix)
  Map<String, String> datePrices = {};
  // Map pour stocker les prix personnalisés depuis le backend (clé: "yyyy-MM-dd", valeur: prix)
  Map<String, dynamic> finalCustomPricesMap = {};

  int toggle = 1;

  int initialLabelIndex = 0;

  @override
  initState() {
    super.initState();
    runAfterFirstFrame(fetchDataCalendar);
  }

  MyItemsModel? myItemsModelHost;
  List<Items> list = [];
  num offset = 0;
  String? lastItemId;
  Items? lastItems;
  Items? initialitems;

  itemDataApi() async {
    try {
      // ========== APPEL API RÉEL - Liste des véhicules ==========
      print('📡 [CALENDAR_DIAG] Chargement de mes véhicules depuis le backend...');
      var response = await httpPost(Config.myItems, {"offset": "$offset"});
      print('📥 [CALENDAR_DIAG] Réponse brute myItems: ${jsonEncode(response)}');
      // ========== END APPEL API RÉEL ==========

      if (response != null) {
        myItemsModelHost = MyItemsModel.fromJson(response);
        if (myItemsModelHost!.data != null) {
          // Important: on évite que la liste des véhicules s'additionne à chaque rechargement
          // (sinon tu obtiens le même véhicule dupliqué après plusieurs clics).
          list.clear();
          offset = 0;
          list.addAll(myItemsModelHost!.data!.items!);
          offset = myItemsModelHost!.data!.offset!;
          checkItemPiblicationLimit = response["data"]["checkLimit"];

          if (list.isNotEmpty) {
            lastItems = list.last;
            lastItemId = lastItems?.id ?? '';

            // ========== APPEL API RÉEL - Dates du calendrier ==========
            // IMPORTANT: L'ID est passé dans l'URL (ex: /get-item-dates/123)
            String itemId = (initialitems?.id ?? lastItemId).toString();
            String endpointWithId = "${Config.getItemDates}/$itemId";
            print('📡 [CALENDAR_DIAG] Chargement des dates du calendrier pour l\'ID: $itemId');
            var response = await httpGet(endpointWithId, {});
            print('📥 [CALENDAR_DIAG] Réponse brute getItemDates: ${jsonEncode(response)}');
            // ========== END APPEL API RÉEL ==========

            if (response != null) {
              // ========== FORCER LA LECTURE DU PRIX PERSONNALISÉ ==========
              // On récupère le corps de la réponse (response est déjà un Map décodé)
              // Si response est déjà un Map, on l'utilise directement
              Map<String, dynamic> responseData;
              if (response is Map<String, dynamic>) {
                responseData = response;
              } else {
                // Si c'est une String, on la décode
                responseData = json.decode(response.toString());
              }
              
              // On descend dans data -> custom_prices
              if (responseData['data'] != null && responseData['data']['custom_prices'] != null) {
                final Map<String, dynamic> rawCustomPrices = responseData['data']['custom_prices'] as Map<String, dynamic>;
                
                // On vide et on remplit manuellement la Map de prix
                finalCustomPricesMap.clear();
                rawCustomPrices.forEach((key, value) {
                  finalCustomPricesMap[key] = value.toString();
                });
                print('🚀 [FORCE_MAP] Mapping manuel réussi : ${finalCustomPricesMap.length} prix ajoutés');
                print('🚀 [FORCE_MAP] Test 2026-03-11 : ${finalCustomPricesMap["2026-03-11"]}');
                
                // Afficher quelques exemples
                if (finalCustomPricesMap.isNotEmpty) {
                  var firstFew = finalCustomPricesMap.entries.take(5);
                  print('🚀 [FORCE_MAP] Exemples de prix chargés:');
                  for (var entry in firstFew) {
                    print('   - ${entry.key}: ${entry.value}');
                  }
                }
                
                // Force le rafraîchissement immédiat
                setState(() {});
                print('🔄 [FORCE_MAP] setState() appelé après mapping manuel');
              } else {
                print('❌ [FORCE_MAP] custom_prices introuvable dans responseData');
                if (responseData['data'] == null) {
                  print('❌ [FORCE_MAP] responseData[\'data\'] est null');
                } else {
                  print('❌ [FORCE_MAP] responseData[\'data\'][\'custom_prices\'] est null');
                  print('❌ [FORCE_MAP] Clés dans data: ${responseData['data'].keys}');
                }
              }
              
              // ========== LOG DE LA RÉPONSE BRUTE ==========
              print('📥 [CALENDAR_DIAG] Réponse brute complète: ${jsonEncode(response)}');
              print('📥 [CALENDAR_DIAG] Structure de la réponse: ${response.runtimeType}');
              
              // ========== PARSING DIRECT DEPUIS response['data'] ==========
              // Accéder directement à response['data']['available_dates'] sans passer par ItemDates
              if (response['data'] != null) {
                var data = response['data'];
                
                // ========== RÉCUPÉRATION DU PRIX PAR DÉFAUT ET DE LA DEVISE ==========
                if (data['price'] != null) {
                  defaultVehiclePrice = data['price'].toString();
                  vehicleBasePrice = data['price'].toString(); // Stocker aussi dans vehicleBasePrice
                  print('💰 [CALENDAR_DIAG] Prix par défaut récupéré: $defaultVehiclePrice');
                } else {
                  print('⚠️ [CALENDAR_DIAG] Prix par défaut non trouvé dans la réponse');
                }
                
                if (data['currency'] != null) {
                  currency = data['currency'].toString();
                  print('💰 [CALENDAR_DIAG] Devise récupérée: $currency');
                } else {
                  // Utiliser MAD par défaut si la devise n'est pas fournie
                  currency = "MAD";
                  print('⚠️ [CALENDAR_DIAG] Devise non trouvée, utilisation de MAD par défaut');
                }
                
                // ========== NETTOYAGE DES LISTES AVANT REMPLISSAGE ==========
                notAvailableDates.clear();
                availableDates.clear();
                bookedDates.clear();
                avialblePrice.clear();
                datePrices.clear(); // Vider aussi la Map des prix
                finalCustomPricesMap.clear(); // Vider aussi la Map des prix personnalisés
                print('🧹 [CALENDAR_DIAG] Listes vidées avant remplissage');
                
                // ========== REMPLISSAGE DE finalCustomPricesMap DEPUIS response.data['custom_prices'] ==========
                // Accéder à response['data']['custom_prices'] (équivalent à response.data['custom_prices'] en Dart)
                if (response['data'] != null && response['data']['custom_prices'] != null) {
                  finalCustomPricesMap.clear();
                  
                  // Récupérer custom_prices depuis response.data
                  dynamic customPricesRaw = response['data']['custom_prices'];
                  
                  // Vérifier le type et convertir en Map
                  if (customPricesRaw is Map) {
                    customPricesRaw.forEach((key, value) {
                      finalCustomPricesMap[key.toString()] = value.toString();
                    });
                    
                    // IMPORTANT : Log de vérification
                    print('✅ [FLUTTER_SYNC] Map mise à jour avec ${finalCustomPricesMap.length} prix');
                    
                    // Afficher quelques exemples pour debug
                    if (finalCustomPricesMap.isNotEmpty) {
                      var firstFew = finalCustomPricesMap.entries.take(3);
                      print('💰 [FLUTTER_SYNC] Exemples de prix chargés:');
                      for (var entry in firstFew) {
                        print('   - ${entry.key}: ${entry.value}');
                      }
                    }
                    
                    // Force le rafraîchissement : Appeler setState dès que la Map est remplie
                    setState(() {});
                    print('🔄 [FLUTTER_SYNC] setState() appelé après remplissage de finalCustomPricesMap');
                  } else {
                    print('⚠️ [FLUTTER_SYNC] custom_prices n\'est pas une Map, type: ${customPricesRaw.runtimeType}');
                  }
                } else {
                  print('❌ [FLUTTER_SYNC] custom_prices est introuvable dans response[\'data\']');
                  if (response['data'] == null) {
                    print('❌ [FLUTTER_SYNC] response[\'data\'] est null');
                  } else {
                    print('❌ [FLUTTER_SYNC] response[\'data\'][\'custom_prices\'] est null');
                    print('❌ [FLUTTER_SYNC] Clés disponibles dans response[\'data\']: ${response['data'].keys}');
                  }
                }
                
                // ========== PARSING DES DATES DISPONIBLES ==========
                if (data['available_dates'] != null && data['available_dates'] is List) {
                  List availableDatesRaw = data['available_dates'];
                  print('📊 [CALENDAR_DIAG] Nombre de dates disponibles reçues: ${availableDatesRaw.length}');
                  
                  for (var item in availableDatesRaw) {
                    // item peut être un Map ou une String selon le format
                    String? dateStr;
                    dynamic price;
                    
                    if (item is Map) {
                      dateStr = item['date']?.toString();
                      price = item['price'];
                    } else if (item is String) {
                      dateStr = item;
                      price = null;
                    }
                    
                    print('📅 [CALENDAR_DIAG] Date brute reçue (available): $dateStr (type: ${dateStr.runtimeType}), prix: $price');
                    
                    if (dateStr != null && dateStr.isNotEmpty) {
                      DateTime? normalizedDate = parseCalendarDate(dateStr);
                      if (normalizedDate == null) {
                        print('⚠️ [CALENDAR_DIAG] Échec du parsing de la date: $dateStr');
                        continue;
                      }
                      availableDates.add(PickerDateRange(
                        normalizedDate,
                        normalizedDate,
                      ));
                      // Normaliser la date au format yyyy-MM-dd (format exact)
                      String dateFormatted = DateFormat('yyyy-MM-dd').format(normalizedDate);
                      
                      // Extraire et stocker le prix personnalisé dans customPrices
                      // Transformation propre du prix en String
                      String priceToUse;
                      if (price != null) {
                        // Convertir le prix en String proprement (gérer double, int, String)
                        String priceStr = price.toString().trim();
                        // Nettoyer le prix (enlever les espaces, vérifier que ce n'est pas "0" ou vide)
                        if (priceStr.isNotEmpty && priceStr != "0" && priceStr != "0.0" && priceStr != "0.00") {
                          priceToUse = priceStr;
                          // Stocker aussi dans finalCustomPricesMap si pas déjà présent
                          if (!finalCustomPricesMap.containsKey(dateFormatted)) {
                            finalCustomPricesMap[dateFormatted] = priceToUse;
                            print('💰 [MAP_DATA] Date: $dateFormatted | Prix stocké dans finalCustomPricesMap: ${finalCustomPricesMap[dateFormatted]} | Type: ${price.runtimeType}');
                          }
                        } else {
                          print('⚠️ [CALENDAR_DIAG] Prix invalide (0 ou vide) pour la date $dateStr');
                          priceToUse = defaultVehiclePrice;
                          // Ne pas stocker dans customPrices si c'est le prix par défaut
                        }
                      } else {
                        print('⚠️ [CALENDAR_DIAG] Prix null pour la date $dateStr, utilisation du prix par défaut: $defaultVehiclePrice');
                        priceToUse = defaultVehiclePrice;
                      }
                      avialblePrice.add(priceToUse);
                      
                      // Stocker aussi dans datePrices pour compatibilité
                      datePrices[dateFormatted] = priceToUse;
                      print('✅ [CALENDAR_DIAG] Date disponible ajoutée: $dateFormatted, prix: $priceToUse');
                    } else {
                      print('⚠️ [CALENDAR_DIAG] Date disponible null ou vide');
                    }
                  }
                  print('✅ [CALENDAR_DIAG] Total dates disponibles ajoutées: ${availableDates.length}');
                  print('✅ [CALENDAR_DIAG] Total prix ajoutés: ${avialblePrice.length}');
                } else {
                  print('⚠️ [CALENDAR_DIAG] available_dates est null ou n\'est pas une liste');
                }
                
                // ========== PARSING DES DATES NON DISPONIBLES ==========
                if (data['not_available_dates'] != null && data['not_available_dates'] is List) {
                  List notAvailableDatesRaw = data['not_available_dates'];
                  print('📊 [CALENDAR_DIAG] Nombre de dates non disponibles reçues: ${notAvailableDatesRaw.length}');
                  
                  for (var item in notAvailableDatesRaw) {
                    String? dateStr;
                    if (item is Map) {
                      dateStr = item['date']?.toString();
                    } else if (item is String) {
                      dateStr = item;
                    }
                    
                    print('📅 [CALENDAR_DIAG] Date brute reçue (notAvailable): $dateStr');
                    
                    if (dateStr != null && dateStr.isNotEmpty) {
                      DateTime? normalizedDate = parseCalendarDate(dateStr);
                      if (normalizedDate == null) {
                        print('⚠️ [CALENDAR_DIAG] Échec du parsing de la date: $dateStr');
                        continue;
                      }
                      notAvailableDates.add(PickerDateRange(
                        normalizedDate,
                        normalizedDate,
                      ));
                      String dateFormatted = DateFormat('yyyy-MM-dd').format(normalizedDate);
                      print('✅ [CALENDAR_DIAG] Date non disponible ajoutée: $dateFormatted');
                    }
                  }
                  print('✅ [CALENDAR_DIAG] Total dates non disponibles ajoutées: ${notAvailableDates.length}');
                } else {
                  print('⚠️ [CALENDAR_DIAG] not_available_dates est null ou n\'est pas une liste');
                }
                
                // ========== PARSING DES DATES RÉSERVÉES ==========
                if (data['booked_dates'] != null && data['booked_dates'] is List) {
                  List bookedDatesRaw = data['booked_dates'];
                  print('📊 [CALENDAR_DIAG] Nombre de dates réservées reçues: ${bookedDatesRaw.length}');
                  
                  for (var item in bookedDatesRaw) {
                    String? dateStr;
                    dynamic price;
                    if (item is Map) {
                      dateStr = item['date']?.toString();
                      price = item['price'];
                    } else if (item is String) {
                      dateStr = item;
                      price = null;
                    }
                    
                    print('📅 [CALENDAR_DIAG] Date brute reçue (booked): $dateStr, prix: $price');
                    
                    if (dateStr != null && dateStr.isNotEmpty) {
                      DateTime? normalizedDate = parseCalendarDate(dateStr);
                      if (normalizedDate == null) {
                        print('⚠️ [CALENDAR_DIAG] Échec du parsing de la date réservée: $dateStr');
                        continue;
                      }
                      bookedDates.add(PickerDateRange(
                        normalizedDate,
                        normalizedDate,
                      ));
                      if (price != null) {
                        bookedPrice = price.toString();
                      }
                      String dateFormatted = DateFormat('yyyy-MM-dd').format(normalizedDate);
                      print('✅ [CALENDAR_DIAG] Date réservée ajoutée: $dateFormatted');
                    }
                  }
                  print('✅ [CALENDAR_DIAG] Total dates réservées ajoutées: ${bookedDates.length}');
                } else {
                  print('⚠️ [CALENDAR_DIAG] booked_dates est null ou n\'est pas une liste');
                }
                
                // ========== EXTRACTION DES PRIX PERSONNALISÉS DEPUIS D'AUTRES SOURCES ==========
                // Vérifier s'il y a une liste séparée de prix personnalisés
                List<String> possiblePriceKeys = ['custom_prices', 'customPrices', 'special_prices', 'specialPrices', 'prices'];
                for (String key in possiblePriceKeys) {
                  if (data[key] != null) {
                    if (data[key] is Map) {
                      Map priceMap = data[key];
                      print('💰 [CHECK] Prix personnalisés trouvés dans la clé (Map): $key');
                      priceMap.forEach((dateKey, priceValue) {
                        String dateStr = dateKey.toString();
                        // Transformation propre du prix en String
                        String priceStr = priceValue?.toString().trim() ?? "";
                        if (dateStr.isNotEmpty && priceStr.isNotEmpty && priceStr != "0" && priceStr != "0.0" && priceStr != "0.00") {
                          DateTime? parsedDate = parseCalendarDate(dateStr);
                          if (parsedDate != null) {
                            String normalizedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
                            finalCustomPricesMap[normalizedDate] = priceStr;
                            print('💰 [MAP_DATA] Prix personnalisé ajouté (Map): $normalizedDate -> $priceStr | Type original: ${priceValue.runtimeType}');
                          } else if (dateStr.length == 10 && dateStr.contains('-')) {
                            finalCustomPricesMap[dateStr] = priceStr;
                            print('💰 [MAP_DATA] Prix personnalisé ajouté (format direct): $dateStr -> $priceStr');
                          }
                        }
                      });
                    } else if (data[key] is List) {
                      List priceList = data[key];
                      print('💰 [CHECK] Prix personnalisés trouvés dans la clé (List): $key');
                      for (var item in priceList) {
                        if (item is Map) {
                          String? dateStr = item['date']?.toString();
                          // Transformation propre du prix en String : item['price'].toString()
                          String? priceStr = item['price']?.toString().trim();
                          if (dateStr != null && dateStr.isNotEmpty && 
                              priceStr != null && priceStr.isNotEmpty && priceStr != "0" && priceStr != "0.0" && priceStr != "0.00") {
                            DateTime? parsedDate = parseCalendarDate(dateStr);
                            if (parsedDate != null) {
                              String normalizedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
                              finalCustomPricesMap[normalizedDate] = priceStr;
                              print('💰 [MAP_DATA] Prix personnalisé ajouté (List): $normalizedDate -> $priceStr | Type original: ${item['price'].runtimeType}');
                            }
                          }
                        }
                      }
                    }
                    break; // Sortir après avoir trouvé les prix
                  }
                }
                
                // ========== LOG FINAL DES LISTES REMPLIES ==========
                print('✅ [CALENDAR_DIAG] Listes mises à jour: ${availableDates.length} dates disponibles trouvées');
                print('✅ [CALENDAR_DIAG] Listes mises à jour: ${notAvailableDates.length} dates non disponibles trouvées');
                print('✅ [CALENDAR_DIAG] Listes mises à jour: ${bookedDates.length} dates réservées trouvées');
                print('✅ [CALENDAR_DIAG] Prix personnalisés chargés dans finalCustomPricesMap: ${finalCustomPricesMap.length}');
                if (finalCustomPricesMap.isNotEmpty) {
                  var firstFew = finalCustomPricesMap.entries.take(3);
                  print('💰 [UI_CHECK] Exemples de prix personnalisés:');
                  for (var entry in firstFew) {
                    print('   - ${entry.key}: ${entry.value}');
                  }
                }
                
                // ========== RÉCUPÉRATION DU PRIX FUTUR ==========
                if (availableDates.isNotEmpty && avialblePrice.isNotEmpty) {
                  String lastPrice = avialblePrice.last;
                  // Utiliser le prix par défaut si le dernier prix est 0 ou vide
                  futurePrice = (lastPrice != "0" && lastPrice.isNotEmpty) ? lastPrice : defaultVehiclePrice;
                } else {
                  // Si aucune date disponible, utiliser le prix par défaut
                  futurePrice = defaultVehiclePrice;
                }
                print('💰 [CALENDAR_DIAG] Prix futur défini: $futurePrice');
                
                // ========== FORCER LE REFRESH ==========
                print('🔄 [CALENDAR_DIAG] Forçage du refresh de l\'UI...');
                setState(() {});
                print('✅ [CALENDAR_DIAG] Refresh effectué - Le calendrier devrait maintenant afficher toutes les dates');
              } else {
                print('⚠️ [CALENDAR_DIAG] response[\'data\'] est null');
              }
            }
          }
        }
      }

      setState(() {});
    } catch (e) {
      setState(() {});
    }
  }

  submitMethod(BuildContext context) async {
    if (addItemsHostController.isChecked1.value == false &&
        addItemsHostController.isChecked2.value == false) {
      showErrorToastMessage("Please Select the checkBox");
      return;
    }
    DateTime maxDate = RollingCalendarBounds.lastDate();
    if (addItemsHostController.isChecked1.value) {
      if (addItemsHostController.textEditingControllerFuturePrice.text == "" ||
          addItemsHostController.textEditingControllerFuturePrice.text == "0") {
        showErrorToastMessage("price should not be zero or empty");
        return;
      }

      for (var x in selectedAvailableRange) {
        DateTime startDate = x['date'].startDate ?? DateTime.now();
        DateTime endDate = x['date'].endDate ?? DateTime.now();

        if (endDate.isAfter(maxDate)) {
          showErrorToastMessage(
              "The selected date range must be within the current month and the next two months."
                  .tr);
          return;
        }

        Duration totalRange = endDate.difference(startDate);
        List<Map<String, dynamic>> aList = [];

        for (int i = 0; i <= totalRange.inDays; i++) {
          DateTime dateTime = x['date'].startDate.add(Duration(days: i));
          // Utiliser DateFormat().format() pour générer la string de date proprement
          String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
          
          // Récupérer le prix depuis x['value'] ou depuis textEditingControllerFuturePrice
          String priceValue = x['value']?.toString() ?? "";
          
          // Si le prix n'est pas dans x['value'], essayer depuis le TextFormField
          if (priceValue.isEmpty || priceValue == "0" || priceValue == "null") {
            String priceFromField = addItemsHostController.textEditingControllerFuturePrice.text;
            if (priceFromField.isNotEmpty && priceFromField != "0") {
              priceValue = priceFromField;
            } else {
              // Si toujours vide, utiliser le prix par défaut
              priceValue = defaultVehiclePrice;
            }
          }
          
          // S'assurer que le prix est une string valide
          if (priceValue.isEmpty || priceValue == "0" || priceValue == "null") {
            priceValue = defaultVehiclePrice;
          }
          
          // Ajouter un simple objet Map avec le format attendu par le backend
          aList.add({
            "date": formattedDate,
            "status": x['status'] ?? "Available",
            "price": priceValue
          });
          
          print('💰 [SUBMIT] Date: $formattedDate, Status: ${x['status']}, Price: $priceValue');
        }

        myNewDateAndStatusListAvailable.add(aList);
      }
    }
    if (addItemsHostController.isChecked2.value) {
      for (var x in selectedNotAvailableRange) {
        DateTime startDate = x['date'].startDate ?? DateTime.now();
        DateTime endDate = x['date'].endDate ?? DateTime.now();

        if (endDate.isAfter(maxDate)) {
          showErrorToastMessage(
              "The selected date range must be within the current month and the next two months."
                  .tr);
          return;
        }

        Duration totalRange = endDate.difference(startDate);
        List<Map<String, dynamic>> aList = [];

        for (int i = 0; i <= totalRange.inDays; i++) {
          DateTime dateTime = x['date'].startDate.add(Duration(days: i));
          // Utiliser DateFormat().format() pour générer la string de date proprement
          String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
          
          // Ajouter un simple objet Map (pas de jsonEncode ici)
          aList.add({
            "date": formattedDate,
            "status": x['status'],
            "price": "0",
            "reason": addItemsHostController.calendarBlockReason.value,
          });
        }
        myNewDateAndStatusListNotAvailable.add(aList);
      }
    }

    showLoading();
    
    // ========== PRÉPARATION DES DONNÉES AU FORMAT JSON STRING ==========
    // Aplatir les listes de listes en une seule liste simple d'objets
    List<Map<String, dynamic>> flatList = [];
    if (addItemsHostController.isChecked1.value) {
      for (var subList in myNewDateAndStatusListAvailable) {
        flatList.addAll(subList);
      }
    } else {
      for (var subList in myNewDateAndStatusListNotAvailable) {
        flatList.addAll(subList);
      }
    }
    
    // Un seul jsonEncode sur la liste plate d'objets
    String availabilityDatesJson = jsonEncode(flatList);
    print('📤 [DATE_FORMAT] Format final envoyé: $availabilityDatesJson');
    
    // Extraire start_date et end_date de la liste plate
    String? startDate;
    String? endDate;
    if (flatList.isNotEmpty) {
      // Trier les dates pour trouver la première et la dernière
      List<String> dates = flatList.map((item) => item['date'] as String).toList()..sort();
      startDate = dates.first;
      endDate = dates.last;
    }
    
    // Déterminer item_id avec plusieurs fallbacks
    String? itemIdValue = initialitems?.id?.toString() ?? 
                         lastItemId?.toString() ?? 
                         addItemsHostController.itemHostId?.toString();
    
    // Validation : vérifier que item_id n'est pas null ou vide
    if (itemIdValue == null || itemIdValue.isEmpty || itemIdValue == 'null') {
      closeLoading();
      showErrorToastMessage("Erreur: L'ID du véhicule est manquant. Veuillez sélectionner un véhicule.");
      print('❌ [CALENDAR_DIAG] item_id est manquant ou invalide');
      return;
    }
    
    Map map = {
      "availability_dates": availabilityDatesJson,
      "item_id": itemIdValue,
    };
    
    // Ajouter start_date et end_date si disponibles
    if (startDate != null && endDate != null) {
      map["start_date"] = startDate;
      map["end_date"] = endDate;
    }

    // ========== APPEL API RÉEL - Sauvegarde du calendrier ==========
    print('📡 [CALENDAR_DIAG] Envoi des modifications du calendrier au backend...');
    print('📤 [CALENDAR_DIAG] item_id utilisé: $itemIdValue');
    print('📤 [CALENDAR_DIAG] Données envoyées: ${jsonEncode(map)}');
    var response = await httpPost(Config.addEditCalender, map);
    print('📥 [CALENDAR_DIAG] Réponse brute addEditCalender: ${jsonEncode(response)}');
    // ========== END APPEL API RÉEL ==========
    
    closeLoading();
    
    // ========== TRAITEMENT DE LA RÉPONSE ==========
    if (response != null) {
      // Vérifier si la réponse est un succès (status 200 ou success: true)
      bool isSuccess = (response['status'] == 200 || 
                       response['status'] == 201 || 
                       response['success'] == true);
      
      if (isSuccess) {
        // Afficher un message de succès
        showToastMessage('Calendrier mis à jour !');
        print('✅ [CALENDAR_DIAG] Calendrier mis à jour avec succès');
        
        // Vider la liste selectedDates pour nettoyer l'interface
        selectedDates.clear();
        selectedAvailableRange.clear();
        selectedNotAvailableRange.clear();
        myNewDateAndStatusListAvailable.clear();
        myNewDateAndStatusListNotAvailable.clear();
        print('🧹 [CALENDAR_DIAG] Listes vidées après succès');
        
        // Recharger le calendrier pour afficher les nouvelles dates
        print('🔄 [CALENDAR_DIAG] Rechargement du calendrier...');
        await itemDataApi();
        print('✅ [CALENDAR_DIAG] Calendrier rechargé - Les dates bloquées doivent maintenant apparaître en Rouge');
        
        // Forcer le refresh de l'UI
        setState(() {});
      } else {
        // Afficher l'erreur si la réponse n'est pas un succès
        String errorMessage = response['error'] ?? 
                             response['message'] ?? 
                             'Erreur lors de la mise à jour du calendrier';
        showErrorToastMessage(errorMessage);
      }
    } else {
      showErrorToastMessage('Erreur: Aucune réponse du serveur');
    }
  }

  Future<void> fetchDataCalendar() async {
    if (token.isEmpty) {
      return;
    }
    await itemDataApi();
  }

  bool isDateInRange(DateTime date, PickerDateRange range) {
    if (range.startDate != null && range.endDate != null) {
      return (date.isAfter(range.startDate!) ||
              date.isAtSameMomentAs(range.startDate!)) &&
          (date.isBefore(range.endDate!) ||
              date.isAtSameMomentAs(range.endDate!));
    }

    return false;
  }

  /// Fermeture sécurisée (Snackbar GetX + pop) pour éviter LateInitializationError.
  void handleBackNavigation({VoidCallback? then}) {
    safeGetBack(context: context, then: then);
  }

  @override
  Widget build(BuildContext context) {
    return showerrorWhenloginwithOtherDevice == "token not match"
        ? Center(child: showTokenExpirePlease())
        : myItemsModelHost == null
            ? calanderScreenShimmer()
            : list.isEmpty
                ? Addproperty(
                    title: "You don't have any List".tr,
                    subTitle: staticContantforHost(),
                    btnTxt: "Add New List".tr,
                    onTap: () {
                      if (showerrorWhenloginwithOtherDevice ==
                          "token not match") {
                        showErrorToastMessage("Please login again");
                        return;
                      }
                      if (checkItemPiblicationLimit.toString() == "0") {
                        showErrorToastMessage(
                            "You have reached the limit for publishing items. Please contact the admin for further assistance.");
                        return;
                      }
                      Get.to(() => const InitialHostCommonScreen());
                    },
                  )
                : Scaffold(
                    backgroundColor: notifires.getbgcolor,
                    appBar: AppBar(
                      automaticallyImplyLeading: false,
                      surfaceTintColor: notifires.getbgcolor,
                      backgroundColor: notifires.getbgcolor,
                      title: Text("Calendar".tr, style: heading2Grey1(context)),
                      centerTitle: true,
                    ),
                    body: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: notifires.getboxcolor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: notifires.getGrey3Whitecolor
                                      .withOpacity(0.1),
                                  spreadRadius: 3,
                                  blurRadius: 5,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 120,
                                    height: 120,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          12), // Image border
                                      child: SizedBox.fromSize(
                                        size: const Size.fromRadius(180),
                                        child: FadeInImage.assetNetwork(
                                          fadeInCurve: Curves.easeInCirc,
                                          placeholder:
                                              "assets/images/ezgif.com-crop.gif",
                                          height: 50,
                                          image: (initialitems
                                                      ?.frontImage?.thumbnail ??
                                                  lastItems?.frontImage
                                                      ?.thumbnail) ??
                                              '',
                                          imageErrorBuilder:
                                              (context, error, stackTrace) {
                                            return getErrorImage();
                                          },
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  Flexible(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                              initialitems?.title ??
                                                  lastItems?.title ??
                                                  "No Title".tr,
                                              style: heading3Grey1(context)),
                                          Text(
                                            initialitems?.description ??
                                                lastItems?.description ??
                                                "No Description".tr,
                                            style: regular2(context),
                                            maxLines: 2,
                                          ),
                                        ]),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      _showItemListDialog(context, list);
                                    },
                                    child: Container(
                                      width: 20,
                                      height: 55,
                                      alignment: Alignment.topCenter,
                                      child: Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 30,
                                        color: notifires.getwhiteblackcolor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Divider(
                          thickness: 2,
                          endIndent: 12,
                          indent: 12,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // First Row of Legend Items
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Avability(
                                    color: greentext,
                                    borderColor: lightsGrey,
                                  ),
                                  const SizedBox(width: 10),
                                  LabelNames(labelname: 'Booked'.tr),
                                  const SizedBox(width: 20),
                                  Avability(
                                    color: redColor,
                                    borderColor: redColor,
                                  ),
                                  const SizedBox(width: 10),
                                  LabelNames(labelname: 'Not available'.tr),
                                  const SizedBox(width: 20),
                                  Avability(
                                    color: themeColor,
                                    borderColor: notifires.getwhiteblackcolor,
                                  ),
                                  const SizedBox(width: 10),
                                  LabelNames(labelname: 'Available'.tr),
                                ],
                              ),
                              const SizedBox(
                                  height:
                                      15), // Add some spacing between the rows
                              // Second Row of Legend Items
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Avability(
                                    color: yellowColor,
                                    borderColor: yellowColor,
                                  ),
                                  const SizedBox(width: 10),
                                  LabelNames(labelname: "Selected".tr),
                                  const SizedBox(width: 20),
                                  Avability(
                                    color: greycolor.withOpacity(0.4),
                                    borderColor: greycolor.withOpacity(0.4),
                                  ),
                                  const SizedBox(width: 10),
                                  LabelNames(labelname: "Past Dates".tr),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 800,
                          child: SfDateRangePicker(
                              allowViewNavigation: false,
                              headerStyle: DateRangePickerHeaderStyle(
                                textAlign: TextAlign.start,
                                textStyle:
                                    TextStyle(fontSize: 18, color: boxcolor),
                              ),
                              monthCellStyle: DateRangePickerMonthCellStyle(
                                  blackoutDateTextStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  blackoutDatesDecoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green.shade100)),
                              controller: dateRangePickerControllers,
                              monthViewSettings:
                                  DateRangePickerMonthViewSettings(
                                viewHeaderStyle: DateRangePickerViewHeaderStyle(
                                  backgroundColor: themeColor.withOpacity(0.1),
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 12),
                                ),
                              ),
                              backgroundColor: Colors.white,
                              navigationDirection:
                                  DateRangePickerNavigationDirection.vertical,
                              navigationMode:
                                  DateRangePickerNavigationMode.scroll,
                              enableMultiView: true,
                              minDate: RollingCalendarBounds.firstDate(),
                              maxDate: RollingCalendarBounds.lastDate(),
                              enablePastDates: false,
                              onViewChanged: (args) {
                                RollingCalendarBounds.clampPickerView(
                                  args,
                                  dateRangePickerControllers,
                                );
                              },
                              view: DateRangePickerView.month,
                              selectionMode: DateRangePickerSelectionMode.range,
                              onSelectionChanged:
                                  (DateRangePickerSelectionChangedArgs args) {
                                PickerDateRange? selectedRange = args.value;

                                if (selectedRange != null) {
                                  selectedDates = [selectedRange];

                                  DateTime startDate =
                                      selectedRange.startDate ?? DateTime.now();

                                  DateTime endDate =
                                      selectedRange.endDate ?? DateTime.now();
                                  Duration totalRange =
                                      endDate.difference(startDate);

                                  List<DateTime> allDates = [];

                                  for (int i = 0; i <= totalRange.inDays; i++) {
                                    allDates
                                        .add(startDate.add(Duration(days: i)));
                                  }

                                  if (allDates.isNotEmpty) {
                                    setState(() {
                                      isDateSelected = true;
                                    });
                                  } else {
                                    setState(() {
                                      isDateSelected = false;
                                    });
                                  }
                                } else {}

                                if (selectedDates.isNotEmpty) {
                                  selectedAvailableRange = selectedDates
                                      .map((date) => {
                                            "date": date,
                                            "value": addItemsHostController
                                                    .textEditingControllerPrice
                                                    .text
                                                    .isEmpty
                                                ? "0"
                                                : addItemsHostController
                                                    .textEditingControllerPrice
                                                    .text,
                                            'status': "Available",
                                          })
                                      .toList();
                                }

                                if (selectedDates.isNotEmpty) {
                                  selectedNotAvailableRange = selectedDates
                                      .map((date) => {
                                            "date": date,
                                            "value": addItemsHostController
                                                    .textEditingControllerPrice
                                                    .text
                                                    .isEmpty
                                                ? "0"
                                                : addItemsHostController
                                                    .textEditingControllerPrice
                                                    .text,
                                            'status': "Not Available",
                                          })
                                      .toList();
                                }
                              },
                              cellBuilder: (BuildContext context,
                                  DateRangePickerCellDetails cellDetails) {
                                Color cellColor = whiteColor;
                                Color textColor = blackColor;
                                String cellPrice = '';

                                // Normaliser la date de la cellule (sans heure) pour comparaison
                                DateTime cellDateNormalized = DateTime(
                                  cellDetails.date.year,
                                  cellDetails.date.month,
                                  cellDetails.date.day,
                                );
                                
                                // Format de date pour les logs (yyyy-MM-dd)
                                String cellDateFormatted = DateFormat('yyyy-MM-dd').format(cellDateNormalized);
                                
                                // Print spécifique pour le 17 février
                                if (cellDetails.date.month == 2 && cellDetails.date.day == 17) {
                                  print('📅 [FEB_17_DEBUG] Date cellule: $cellDateFormatted');
                                  print('📅 [FEB_17_DEBUG] notAvailableDates count: ${notAvailableDates.length}');
                                  print('📅 [FEB_17_DEBUG] availableDates count: ${availableDates.length}');
                                  print('📅 [FEB_17_DEBUG] bookedDates count: ${bookedDates.length}');
                                  if (notAvailableDates.isNotEmpty) {
                                    print('📅 [FEB_17_DEBUG] Première date non disponible: ${DateFormat('yyyy-MM-dd').format(notAvailableDates.first.startDate!)}');
                                  }
                                }

                                // Fonction helper pour comparer uniquement les dates (sans heures)
                                bool isSameDate(DateTime date1, DateTime date2) {
                                  return date1.year == date2.year &&
                                         date1.month == date2.month &&
                                         date1.day == date2.day;
                                }

                                bool isNotAvailableDate = false;
                                bool isBookedDate = false;
                                bool isAvailableDate = false;
                                bool isSelectedDate = false;
                                
                                // 1. Vérifier les dates réservées (VERT)
                                isBookedDate = bookedDates.any((range) {
                                  if (range.startDate == null || range.endDate == null) return false;
                                  DateTime rangeStartNormalized = DateTime(
                                    range.startDate!.year,
                                    range.startDate!.month,
                                    range.startDate!.day,
                                  );
                                  DateTime rangeEndNormalized = DateTime(
                                    range.endDate!.year,
                                    range.endDate!.month,
                                    range.endDate!.day,
                                  );
                                  return isSameDate(cellDateNormalized, rangeStartNormalized) ||
                                         isSameDate(cellDateNormalized, rangeEndNormalized) ||
                                         (cellDateNormalized.isAfter(rangeStartNormalized) &&
                                          cellDateNormalized.isBefore(rangeEndNormalized));
                                });

                                if (isBookedDate) {
                                  cellColor = greentext;
                                  textColor = whiteColor;
                                  // Utiliser le prix réservé si disponible, sinon le prix par défaut
                                  String priceToDisplay = (bookedPrice != null && bookedPrice.toString() != "0" && bookedPrice.toString().isNotEmpty) 
                                      ? bookedPrice.toString() 
                                      : defaultVehiclePrice;
                                  cellPrice = '$currency $priceToDisplay';
                                  if (cellDetails.date.month == 2 && cellDetails.date.day == 17) {
                                    print('📅 [FEB_17_DEBUG] ✅ Date marquée en VERT (réservée)');
                                  }
                                } 
                                // 2. Vérifier si la date est disponible (BLEU)
                                else {
                                  // Check if the date is available
                                  isAvailableDate = availableDates.any((range) {
                                    if (range.startDate == null || range.endDate == null) return false;
                                    DateTime rangeStartNormalized = DateTime(
                                      range.startDate!.year,
                                      range.startDate!.month,
                                      range.startDate!.day,
                                    );
                                    DateTime rangeEndNormalized = DateTime(
                                      range.endDate!.year,
                                      range.endDate!.month,
                                      range.endDate!.day,
                                    );
                                    return isSameDate(cellDateNormalized, rangeStartNormalized) ||
                                           isSameDate(cellDateNormalized, rangeEndNormalized) ||
                                           (cellDateNormalized.isAfter(rangeStartNormalized) &&
                                            cellDateNormalized.isBefore(rangeEndNormalized));
                                  });

                                  if (isAvailableDate) {
                                    cellColor = themeColor;
                                    textColor = whiteColor;

                                    int index = availableDates.indexWhere((range) {
                                      if (range.startDate == null || range.endDate == null) return false;
                                      DateTime rangeStartNormalized = DateTime(
                                        range.startDate!.year,
                                        range.startDate!.month,
                                        range.startDate!.day,
                                      );
                                      DateTime rangeEndNormalized = DateTime(
                                        range.endDate!.year,
                                        range.endDate!.month,
                                        range.endDate!.day,
                                      );
                                      return isSameDate(cellDateNormalized, rangeStartNormalized) ||
                                             isSameDate(cellDateNormalized, rangeEndNormalized) ||
                                             (cellDateNormalized.isAfter(rangeStartNormalized) &&
                                              cellDateNormalized.isBefore(rangeEndNormalized));
                                    });

                                    // Assure-toi que la variable dateKey est formatée en yyyy-MM-dd
                                    String dateKey = DateFormat('yyyy-MM-dd').format(cellDateNormalized);
                                    
                                    // Utilise cette logique exacte pour le texte
                                    String priceToDisplay = finalCustomPricesMap[dateKey]?.toString() ?? vehicleBasePrice;
                                    
                                    // Log de rendu
                                    print('🎨 [RENDER] Date: $dateKey | Prix: $priceToDisplay');
                                    
                                    cellPrice = "$currency $priceToDisplay";
                                    print('🔵 [COLOR_DIAG] Date marquée en BLEU (disponible): $cellDateFormatted');
                                    if (cellDetails.date.month == 2 && cellDetails.date.day == 17) {
                                      print('📅 [FEB_17_DEBUG] ✅ Date marquée en BLEU (disponible)');
                                    }
                                  } 
                                  // 3. Si la date N'EST PAS dans availableDates, elle DOIT être ROUGE
                                  else {
                                    // Vérifier si c'est une date passée (on ne les colore pas en rouge)
                                    bool isPastDate = cellDateNormalized.isBefore(DateTime.now());
                                    
                                    if (!isPastDate) {
                                      // Date future qui n'est pas disponible = ROUGE
                                      cellColor = Colors.red;
                                      textColor = whiteColor;
                                      // Afficher le prix par défaut pour les dates bloquées
                                      cellPrice = "$currency $defaultVehiclePrice";
                                      print('🔴 [COLOR_DIAG] Date marquée en ROUGE (non disponible - pas dans availableDates): $cellDateFormatted');
                                      if (cellDetails.date.month == 2 && cellDetails.date.day == 17) {
                                        print('📅 [FEB_17_DEBUG] ✅ Date marquée en ROUGE (non disponible - pas dans availableDates)');
                                      }
                                    } else {
                                      // Date passée = blanc par défaut
                                      if (cellDetails.date.month == 2 && cellDetails.date.day == 17) {
                                        print('📅 [FEB_17_DEBUG] ⚠️ Date passée (blanc par défaut)');
                                      }
                                    }
                                  }
                                }

                                // 4. Vérifier si la date est sélectionnée (ORANGE) - indépendant des autres statuts
                                isSelectedDate = selectedDates.any((range) {
                                  if (range.startDate == null || range.endDate == null) return false;
                                  DateTime rangeStartNormalized = DateTime(
                                    range.startDate!.year,
                                    range.startDate!.month,
                                    range.startDate!.day,
                                  );
                                  DateTime rangeEndNormalized = DateTime(
                                    range.endDate!.year,
                                    range.endDate!.month,
                                    range.endDate!.day,
                                  );
                                  return isSameDate(cellDateNormalized, rangeStartNormalized) ||
                                         isSameDate(cellDateNormalized, rangeEndNormalized) ||
                                         (cellDateNormalized.isAfter(rangeStartNormalized) &&
                                          cellDateNormalized.isBefore(rangeEndNormalized));
                                });
                                
                                if (isSelectedDate) {
                                  cellColor = orangeColor;
                                  textColor = whiteColor;
                                  cellPrice = '';
                                }
                                
                                return Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: cellDetails.date
                                                  .isBefore(DateTime.now())
                                              ? greyColor.withOpacity(0.5)
                                              : themeColor,
                                          width: 1.5,
                                          style: BorderStyle.solid),
                                      borderRadius: BorderRadius.circular(5),
                                      color: cellColor,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          convertToLocaleDigits(
                                              cellDetails.date.day.toString()),
                                          style: TextStyle(
                                              color: cellDetails.date
                                                      .isBefore(DateTime.now())
                                                  ? whiteColor
                                                  : textColor,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          convertToLocaleDigits(
                                              cellPrice.toString()),
                                          style: smallAirBk.copyWith(
                                              fontSize: 8,
                                              color: cellDetails.date
                                                      .isBefore(DateTime.now())
                                                  ? whiteColor
                                                  : textColor,
                                              fontWeight: FontWeight.w500),
                                          textAlign: TextAlign.center,
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                    floatingActionButton: isDateSelected
                        ? SizedBox(
                            height: 50,
                            child: InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  constraints: const BoxConstraints.expand(),
                                  useRootNavigator: true,
                                  backgroundColor: notifires.getblackwhitecolor,
                                  isScrollControlled: true,
                                  useSafeArea: false,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AddPriceOnCommonCalander(
                                      selectedDates: selectedDates,
                                      onPressed: () {
                                        submitMethod(context);
                                      },
                                      selectedAvailableRange:
                                          selectedAvailableRange,
                                    );
                                  },
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                      child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.radiusExtraLarge,
                                        vertical: 11),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: themeColor),
                                        color: themeColor,
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.radiusExtraLarge)),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.edit,
                                          size: 15,
                                          color: whiteColor,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Edit'.tr,
                                          style: smallHeadigAirBd.copyWith(
                                              color: whiteColor),
                                        ),
                                      ],
                                    ),
                                  ))
                                ],
                              ),
                            ),
                          )
                        : const SizedBox(),
                    // : null,
                  );
  }

  void _showItemListDialog(BuildContext context, List<Items> list) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: notifires.getblackwhitecolor,
          surfaceTintColor: notifires.getblackwhitecolor,
          contentPadding: const EdgeInsets.only(left: 4, right: 4),
          titlePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                width: 10,
              ),
              Text(
                'Select an Item'.tr,
                style: heading1Grey1(context),
              ),
              const Spacer(),
              InkWell(
                  onTap: () {
                    handleBackNavigation();
                  },
                  child: Card(
                    elevation: 5,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: notifires.getboxcolor),
                      child: Icon(
                        size: 20,
                        Icons.close,
                        color: grey1,
                      ),
                    ),
                  ))
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    final selected = list[index];
                    handleBackNavigation(then: () {
                      if (!mounted) return;
                      setState(() {
                        initialitems = selected;
                      });
                      fetchDataCalendar();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: notifires.getboxcolor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                notifires.getGrey3Whitecolor.withOpacity(0.1),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: const Offset(
                                0, 0), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 64,
                              height: 64,
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(10), // Image border
                                child: SizedBox.fromSize(
                                  size: const Size.fromRadius(
                                      180), // Image radius
                                  child: FadeInImage.assetNetwork(
                                    fadeInCurve: Curves.easeInCirc,
                                    placeholder:
                                        "assets/images/ezgif.com-crop.gif",
                                    height: 50,
                                    image: list[index].frontImage == null
                                        ? ''
                                        : "${list[index].frontImage!.thumbnail}",
                                    imageErrorBuilder:
                                        (context, error, stackTrace) {
                                      return getErrorImage();
                                    },
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      (list[index].title ?? 'Sans titre').length > 40
                                          ? (list[index].title ?? 'Sans titre').substring(0, 39)
                                          : (list[index].title ?? 'Sans titre'),
                                      style: heading3Grey1(context)),
                                  Text(
                                    (list[index].description ?? '').length > 25
                                        ? (list[index].description ?? '').substring(0, 24)
                                        : (list[index].description ?? ''),
                                    style: regular2(context),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
