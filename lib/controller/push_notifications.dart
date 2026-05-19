import 'dart:collection';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/controller/auth_controller.dart';
import 'package:carvy/controller/booking_controller.dart';
import 'package:carvy/controller/kyc_controller.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/firebase_options.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import 'package:carvy/view/chat/conversation_screen.dart';
import 'package:carvy/view/host/bottom_bar_host.dart';
import 'package:carvy/view/review/review_popup_widget.dart';
import 'package:carvy/work_space.dart';

late AndroidNotificationChannel channel;
bool isFlutterLocalNotificationsInitialized = false;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
bool isOneSignalListenerAdded = false;
final Set<String> processedNotificationIds = HashSet<String>();
bool markNotificationAsProcessed(String? notificationId) {
  if (notificationId == null) return false;
  if (processedNotificationIds.contains(notificationId)) {
    return false;
  }
  processedNotificationIds.add(notificationId);
  return true;
}

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotificationfromFirebase(RemoteMessage message) async {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: 'launch_background',
        ),
      ),
    );
  }
}

Future<void> showOneSignalNotification(OSNotification notification) async {
  final AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    channel.id,
    channel.name,
    channelDescription: channel.description,
    importance: Importance.max,
    priority: Priority.high,
    icon: 'launch_background',
  );

  const DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  String payloadData = jsonEncode({
    'route': 'desired_route',
    'data': notification.additionalData,
  });

  try {
    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformChannelSpecifics,
      payload: payloadData,
    );
  } catch (e) {
    //
  }
}

Future<void> firebaseInit() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    // print(e);
  }
  try {
    await FirebaseMessaging.instance
        .requestPermission(sound: true, alert: true);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingHandler);
  } catch (e) {
    //
  }
}

Future<void> _firebaseMessagingHandler(RemoteMessage message) async {
  if (message.messageId != null) {
    _handleMessage(message);
  }
}

void _handleMessage(RemoteMessage message) {
  dynamic messageKeyData = message.data['message_key'];
  if (messageKeyData is String) {
    try {
      messageKeyData = jsonDecode(messageKeyData);
    } catch (e) {
      return;
    }
  }
  if (messageKeyData is Map<String, dynamic>) {}
}

Future<void> setupOneSignal() async {
  print('🕵️‍♂️ [FLUTTER START] setupOneSignal() appelé');
  try {
    print('🔔 [ONESIGNAL_DEBUG] App ID utilisé : ${Config.oneSiginalAppid}');
    
    // Configurer le niveau de log en mode debug
    if (kDebugMode) {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      print('✅ [ONESIGNAL_DEBUG] Log level set to verbose');
    }
    
    // Initialiser OneSignal avec gestion d'erreur
    try {
      OneSignal.initialize(Config.oneSiginalAppid);
      print('✅ [ONESIGNAL_DEBUG] OneSignal initialized');
    } catch (e) {
      print('❌ [ONESIGNAL_DEBUG] Error initializing OneSignal: $e');
      rethrow;
    }
    
    // Demander la permission de manière asynchrone sans bloquer
    OneSignal.Notifications.requestPermission(true).then((value) {
      print('🔔 [ONESIGNAL_DEBUG] Permission acceptée : $value');
    }).catchError((error) {
      print('⚠️ [ONESIGNAL_DEBUG] Error requesting permission: $error');
      // Ne pas rethrow ici car la permission peut être refusée sans casser l'app
    });
    
    // Attendre un peu avant de récupérer le token FCM
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Récupérer le token FCM avec gestion d'erreur
    await getFCMTokenInitialToSetThedata();
    
    // FORCE UPDATE: Vérifier si l'utilisateur est déjà connecté au lancement
    try {
      String? storedToken = GetStorage().read('token');
      if (storedToken != null && storedToken.isNotEmpty) {
        print('🚀 [SETUP] Utilisateur déjà connecté, mise à jour forcée du Player ID...');
        // Initialiser la variable globale token pour que fetchPlayerId puisse l'utiliser
        token = storedToken;
        print('🔑 [SETUP] Token global initialisé depuis le storage');
        
        // Petit délai pour laisser OneSignal s'initialiser complètement
        Future.delayed(const Duration(seconds: 2), () async {
          try {
            // Récupérer le FCM token (fetchPlayerId nécessite un FCM token, pas un token d'auth)
            var fcmToken = await FirebaseMessaging.instance.getToken();
            if (fcmToken != null && fcmToken.isNotEmpty) {
              print('✅ [SETUP] FCM Token récupéré, envoi du Player ID au backend...');
              await fetchPlayerId(fcmToken);
              print('✅ [SETUP] Player ID envoyé au backend avec succès');
            } else {
              print('⚠️ [SETUP] FCM Token est null, impossible d\'envoyer le Player ID');
            }
          } catch (e, stackTrace) {
            print('❌ [SETUP] Erreur lors de la mise à jour forcée du Player ID: $e');
            print('❌ [SETUP] StackTrace: $stackTrace');
            // Ne pas bloquer l'application en cas d'erreur
          }
        });
      } else {
        print('ℹ️ [SETUP] Pas de token utilisateur, attente du login.');
      }
    } catch (e) {
      print('⚠️ [SETUP] Erreur lors de la vérification du token: $e');
      // Ne pas bloquer l'application
    }
  } catch (e, stackTrace) {
    print('❌ [ONESIGNAL_DEBUG] Error in setupOneSignal: $e');
    print('❌ [ONESIGNAL_DEBUG] StackTrace: $stackTrace');
    // Ne pas rethrow ici : on veut que l'app continue même si OneSignal échoue
  }
}

Future<void> getFCMTokenInitialToSetThedata() async {
  try {
    var fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      print('✅ [ONESIGNAL_DEBUG] FCM Token retrieved: ${fcmToken.substring(0, 20)}...');
      try {
        await OneSignal.login(fcmToken);
        print('✅ [ONESIGNAL_DEBUG] OneSignal login successful');
      } catch (e) {
        print('⚠️ [ONESIGNAL_DEBUG] Error logging in to OneSignal: $e');
        // Continuer même si le login échoue
      }
      
      try {
        await addTagWithKey(fcmToken);
        print('✅ [ONESIGNAL_DEBUG] Tag added successfully');
      } catch (e) {
        print('⚠️ [ONESIGNAL_DEBUG] Error adding tag: $e');
        // Continuer même si l'ajout de tag échoue
      }
      
      try {
        await fetchPlayerId(fcmToken);
        print('✅ [ONESIGNAL_DEBUG] Player ID fetched successfully');
      } catch (e) {
        print('⚠️ [ONESIGNAL_DEBUG] Error fetching player ID: $e');
        // Continuer même si la récupération du Player ID échoue
      }
    } else {
      print('⚠️ [ONESIGNAL_DEBUG] FCM Token is null');
    }
  } catch (error, stackTrace) {
    print('❌ [ONESIGNAL_DEBUG] Error in getFCMTokenInitialToSetThedata: $error');
    print('❌ [ONESIGNAL_DEBUG] StackTrace: $stackTrace');
    // Ne pas rethrow : on veut que l'app continue même si le token FCM ne peut pas être récupéré
  }
}

// ⚠️ DÉSACTIVATION TEMPORAIRE : Éviter les appels FCM répétitifs qui causent "Permission denied"
// Cette fonction sera réactivée une fois le problème de thread résolu
Future<void> getFCMToken() async {
  try {
    // Vérifier si le token existe déjà pour éviter les appels répétitifs
    final existingToken = GetStorage().read('fcmToken');
    if (existingToken != null && existingToken.isNotEmpty) {
      debugPrint('🔕 [FCM] Token déjà existant, skip de l\'appel répétitif');
      return;
    }
    
    var fcmToken = await FirebaseMessaging.instance.getToken();
    if (token.isEmpty || token == "") {
      return;
    }
    if (fcmToken != null) {
      // Sauvegarder le token pour éviter les appels répétitifs
      GetStorage().write('fcmToken', fcmToken);
      await OneSignal.login(fcmToken);
      await addTagWithKey(fcmToken);
      await fetchPlayerId(fcmToken);
    }
  } catch (error) {
    debugPrint('❌ [FCM] Erreur dans getFCMToken: $error');
    // Ne pas rethrow pour éviter les crashes
  }
}

Future<void> addTagWithKey(String token) async {
  await OneSignal.User.addTagWithKey("FCMToken", token);
}

// Fonction de secours pour forcer l'envoi de l'ID avant une action critique (ex: réservation)
Future<void> ensurePlayerIdIsSynced() async {
  try {
    print('🛡️ [FORCE SYNC] Vérification pré-réservation...');
    
    // 1. Récupération de l'ID (avec retry rapide)
    var id = OneSignal.User.pushSubscription.id;
    int retries = 0;
    while ((id == null || id.isEmpty) && retries < 3) {
      print('⏳ [FORCE SYNC] Tentative ${retries + 1}/3 pour récupérer l\'ID...');
      await Future.delayed(const Duration(milliseconds: 500));
      id = OneSignal.User.pushSubscription.id;
      retries++;
    }
    
    if (id == null || id.isEmpty) {
      print('⚠️ [FORCE SYNC] Impossible de récupérer l\'ID OneSignal (Mobile).');
      return;
    }
    
    // 2. Vérifier si le token utilisateur existe
    String? storedToken = GetStorage().read('token');
    if (storedToken == null || storedToken.isEmpty) {
      print('⚠️ [FORCE SYNC] Token utilisateur manquant, impossible d\'envoyer l\'ID');
      return;
    }
    
    // 3. Initialiser la variable globale token pour que l'appel API fonctionne
    // Import de la variable globale token depuis work_space.dart
    token = storedToken;
    
    // 4. Récupérer le FCM token et envoyer l'ID au backend
    try {
      var fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        print('🚀 [FORCE SYNC] Envoi immédiat de l\'ID: $id');
        // Utiliser la même méthode que fetchPlayerId mais avec l'ID déjà récupéré
        // On peut soit appeler fetchPlayerId directement, soit faire l'appel API ici
        // Pour éviter la double récupération de l'ID, on fait l'appel API directement
        try {
          await httpPost(
            Config.fcmUpdate,
            {"fcm": fcmToken, "player_id": id},
          );
          print('✅ [FORCE SYNC] ID envoyé avec succès au backend');
        } catch (apiError) {
          print('❌ [FORCE SYNC] Erreur lors de l\'envoi de l\'ID: $apiError');
          // Ne pas bloquer le processus de réservation en cas d'erreur
        }
      } else {
        print('⚠️ [FORCE SYNC] FCM Token est null, impossible d\'envoyer l\'ID');
      }
    } catch (e) {
      print('❌ [FORCE SYNC] Erreur lors de la récupération du FCM token: $e');
    }
  } catch (e) {
    print('❌ [FORCE SYNC] Erreur silencieuse : $e');
    // Ne pas bloquer le processus de réservation en cas d'erreur
  }
}

Future<void> fetchPlayerId(fcmToken) async {
  try {
    // ========== LOGS DE DÉBOGAGE VERBEUX ==========
    print('🕵️‍♂️ [FLUTTER FETCH] fetchPlayerId appelé avec token: ${token.isEmpty ? "VIDE" : "${token.substring(0, token.length > 10 ? 10 : token.length)}..."}');
    print('🔑 [DEBUG FLUTTER] Token Auth actuel: ${GetStorage().read("token")}');
    print('🔑 [DEBUG FLUTTER] Token global (work_space): ${token.isEmpty ? "VIDE" : "${token.substring(0, token.length > 20 ? 20 : token.length)}..."}');
    
    // Sécurité Token : Vérifier si userToken est vide avant d'appeler l'API
    // Import de la variable globale token depuis work_space.dart
    if (token.isEmpty || token == "") {
      print('⚠️ [OneSignal] Token utilisateur vide, skip de l\'appel fcmUpdate');
      print('⚠️ [OneSignal] L\'application continue vers le Dashboard sans bloquer');
      return;
    }
    
    // Récupération de l'ID OneSignal avec logique de retry détaillée
    print('🏁 [DEBUG] Démarrage de la récupération ID...');
    
    // Vérifier le statut actuel
    var status = OneSignal.User.pushSubscription.optedIn;
    var id = OneSignal.User.pushSubscription.id;
    print('🧐 [DEBUG] Statut initial - OptedIn: $status, ID: $id');
    
    int retries = 0;
    while ((id == null || id.isEmpty) && retries < 10) {
      retries++;
      print('⏳ [DEBUG] Tentative $retries/10 : ID est toujours vide...');
      await Future.delayed(const Duration(seconds: 1));
      id = OneSignal.User.pushSubscription.id;
      print('🔍 [DEBUG] Après attente de 1 seconde, ID récupéré: ${id ?? "NULL"}');
    }
    
    if (id == null || id.isEmpty) {
      print('💀 [DEBUG] ÉCHEC TOTAL : Impossible de récupérer l\'ID après 10 secondes.');
      print('💀 [DEBUG] Le code s\'arrête ici - return sans envoyer au backend');
      // C'est ici que ça s'arrête !
      return;
    }
    
    print('🎉 [DEBUG] SUCCÈS ! ID trouvé : $id');
    print('📱 [FLUTTER ONESIGNAL] ID récupéré du SDK: $id');
    oneSiginalplayerid = id;
    GetStorage().write('oneSiginalplayerid', oneSiginalplayerid);
    print('💾 [DEBUG] ID sauvegardé dans le storage');
    
    if (id != null && id.isNotEmpty) {
      print('🚀 [FLUTTER SEND] Envoi vers API...');
      // Envoi du Player ID vers le backend Node.js
      print('📤 [OneSignal] Envoi du Player ID au backend...');
      print('📤 [OneSignal] FCM Token: ${fcmToken.substring(0, 20)}...');
      print('📤 [OneSignal] Player ID: $oneSiginalplayerid');
      
      // ========== LOGS AVANT L'APPEL HTTP ==========
      print('🚀 [FLUTTER SEND] Envoi vers ${Config.fcmUpdate} | Body: {"player_id": "$id"}');
      print('📦 [DEBUG FLUTTER] Body complet: {"fcm": "$fcmToken", "player_id": "$id"}');
      print('🌐 [DEBUG FLUTTER] URL complète sera: ${Config.baseurl}${Config.fcmUpdate}');
      
      try {
        // Utilisation de httpPost pour mettre à jour le token FCM et le Player ID
        // Éviter le blocage : Même si l'appel échoue, l'application continue
        var response = await httpPost(
          Config.fcmUpdate,
          {"fcm": fcmToken, "player_id": id},
        );
        
        // ========== LOGS APRÈS LA RÉPONSE ==========
        print('✅ [DEBUG FLUTTER] Réponse du serveur reçue');
        print('📊 [DEBUG FLUTTER] Type de réponse: ${response.runtimeType}');
        if (response is Map) {
          print('📊 [DEBUG FLUTTER] Status: ${response['status'] ?? response['ResponseCode'] ?? 'N/A'}');
          print('📊 [DEBUG FLUTTER] Message: ${response['message'] ?? response['ResponseMsg'] ?? 'N/A'}');
          if (response['error'] != null) {
            print('❌ [DEBUG FLUTTER] Erreur: ${response['error']}');
          }
        } else {
          print('📊 [DEBUG FLUTTER] Réponse complète: $response');
        }
        print('✅ [OneSignal] Player ID envoyé avec succès au backend');
      } catch (apiError) {
        print('❌ [OneSignal] Erreur lors de l\'envoi du Player ID: $apiError');
        print('❌ [DEBUG FLUTTER] Exception détaillée: $apiError');
        print('⚠️ [OneSignal] L\'application continue vers le Dashboard malgré l\'erreur');
        // On continue même en cas d'erreur pour ne pas bloquer l'application
      }
      
      print('📱 [OneSignal] Player ID récupéré: $oneSiginalplayerid');
    } else {
      print('❌ [DEBUG FLUTTER] STOP: L\'ID est null, on n\'envoie rien.');
      print('⚠️ [OneSignal] Player ID est null, impossible d\'envoyer au backend');
    }
  } catch (error) {
    print('❌ [OneSignal] Erreur lors de la récupération du Player ID: $error');
    print('❌ [DEBUG FLUTTER] Exception dans fetchPlayerId: $error');
    // Ne pas rethrow pour éviter les crashes
  }
}

Future<void> showNotification() async {
  FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
    generalController.msgUpdater.value = true;
    if (!isChatOpen) {
      showFlutterNotificationfromFirebase(event);
    }
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
  await setupFlutterNotifications();
  if (!isOneSignalListenerAdded) {
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      print('📩 [ONESIGNAL_DEBUG] Notification reçue en premier plan : ${event.notification.body}');
      print('📩 [ONESIGNAL_DEBUG] Titre : ${event.notification.title}');
      print('📩 [ONESIGNAL_DEBUG] Données additionnelles : ${event.notification.additionalData}');
      
      // ========== INTERCEPTION DES NOTIFICATIONS REVIEW_REQUEST ==========
      final additionalData = event.notification.additionalData;
      if (additionalData != null && additionalData['type'] == 'REVIEW_REQUEST') {
        print('⭐ [REVIEW] Notification REVIEW_REQUEST détectée');
        print('⭐ [REVIEW] Booking ID: ${additionalData['booking_id']}');
        print('⭐ [REVIEW] Vendor ID: ${additionalData['vendor_id']}');
        
        // Empêcher l'affichage de la bannière système
        event.preventDefault();
        
        // Récupérer le contexte global (Get.context si on utilise GetX)
        BuildContext? context = Get.context;
        
        if (context != null) {
          // Afficher le BottomSheet d'avis
          showReviewRequestNotificationBottomSheet(context, additionalData);
          print('✅ [REVIEW] BottomSheet d\'avis affiché');
        } else {
          print('⚠️ [REVIEW] Contexte non disponible, impossible d\'afficher le BottomSheet');
        }
        
        // Ne pas continuer le traitement de cette notification
        return;
      }
      // ========== FIN INTERCEPTION REVIEW_REQUEST ==========
      
      if (markNotificationAsProcessed(event.notification.notificationId)) {
        // Intercepter le signal : Vérifier si la notification est liée au KYC
        final notification = event.notification;
        final title = notification.title?.toLowerCase() ?? '';
        
        // Détecter une notification KYC : vérifier le titre ou les données additionnelles
        bool isKycNotification = false;
        
        // Vérification 1 : Titre contient des mots-clés liés au KYC
        if (title.contains('validé') || 
            title.contains('verifié') || 
            title.contains('verification') ||
            title.contains('kyc') ||
            title.contains('permis') ||
            title.contains('approuvé') ||
            title.contains('rejeté') ||
            title.contains('approved') ||
            title.contains('rejected') ||
            title.contains('pending')) {
          isKycNotification = true;
          print('🔔 [KYC] Notification KYC détectée via le titre: $title');
        }
        
        // Vérification 2 : Tag type: 'kyc_update' dans les données additionnelles
        if (additionalData != null && additionalData['type'] == 'kyc_update') {
          isKycNotification = true;
          print('🔔 [KYC] Notification KYC détectée via additionalData.type: kyc_update');
        }
        
        // Vérification 3 : Route ou action liée au KYC
        if (additionalData != null && 
            (additionalData['route'] == 'kyc' || 
             additionalData['action'] == 'kyc_update')) {
          isKycNotification = true;
          print('🔔 [KYC] Notification KYC détectée via route/action: ${additionalData['route'] ?? additionalData['action']}');
        }
        
        // Rafraîchir le Controller : Si c'est une notification KYC, mettre à jour le statut
        if (isKycNotification) {
          try {
            // Log du rôle avant l'appel KYC
            try {
              AuthController? authController = Get.find<AuthController>();
              print('🔍 [DEBUG] Statut du rôle avant crash: ${authController.userRole.value}');
            } catch (e) {
              print('⚠️ [DEBUG] AuthController non trouvé: $e');
            }
            
            print('🔄 [KYC] Rafraîchissement du statut KYC en cours...');
            Get.find<KycController>().getUserKycData();
            print('✅ [KYC] Statut KYC rafraîchi avec succès');
          } catch (e, stackTrace) {
            print('❌ [KYC] Erreur lors du rafraîchissement du statut KYC: $e');
            print('❌ [KYC] StackTrace: $stackTrace');
            // On continue même en cas d'erreur pour afficher la notification
          }
        }
        
        if (!isChatOpen) {
          showOneSignalNotification(event.notification);
        }
      }
      event.preventDefault();
    });
    isOneSignalListenerAdded = true;
  }
  OneSignal.Notifications.addClickListener((event) {
    if (markNotificationAsProcessed(event.notification.notificationId)) {
      // Extraire les données additionnelles de la notification
      final notification = event.notification;
      final additionalData = notification.additionalData;
      
      // Log pour le debug
      print('🔔 Notification cliquée avec données : $additionalData');
      
      // Gestion spécifique pour les notifications de type 'new_booking'
      if (additionalData != null && additionalData['type'] == 'new_booking') {
        String? bookingId = additionalData['bookingId']?.toString();
        if (bookingId != null && bookingId.isNotEmpty) {
          print('🔔 [OneSignal] Notification new_booking reçue pour bookingId: $bookingId');
          
          // Vérifier si l'utilisateur est connecté
          if (token.isEmpty) {
            showErrorToastMessage("Please Login first");
            return;
          }
          
          // Naviguer vers l'écran des commandes du vendeur (BottomHost)
          // Les nouvelles réservations sont généralement dans l'onglet "Upcoming"
          // Note: Pour naviguer directement vers HostEreciept (écran de détails),
          // il faudrait faire un appel API pour récupérer les détails de la réservation
          // avec le bookingId, puis naviguer vers HostEreciept avec l'objet Bookings complet
          isHostMode.value = true;
          Get.to(() => const BottomHost(initialIndex: 2));
          generalController.currentIndexHost.value = 2;
          generalController.tabControllerHost.index = 2;
          bookingController.tabIndexOfMybooking = 0; // Onglet "Upcoming"
          
          print('✅ [OneSignal] Navigation vers l\'écran des commandes vendeur pour bookingId: $bookingId');
          return;
        } else {
          print('⚠️ [OneSignal] bookingId manquant dans les données de notification');
        }
      }
      
      // Vérifier si c'est une notification KYC et rafraîchir le statut
      bool isKycNotification = false;
      
      // Vérifier les données additionnelles pour détecter une notification KYC
      if (additionalData != null) {
        if (additionalData['type'] == 'kyc_update' ||
            additionalData['route'] == 'kyc' ||
            additionalData['action'] == 'kyc_update') {
          isKycNotification = true;
        }
      }
      
      // Rafraîchir le statut KYC si nécessaire
      if (isKycNotification) {
        try {
          // Log du rôle avant l'appel KYC
          try {
            AuthController? authController = Get.find<AuthController>();
            print('🔍 [DEBUG] Statut du rôle avant crash: ${authController.userRole.value}');
          } catch (e) {
            print('⚠️ [DEBUG] AuthController non trouvé: $e');
          }
          
          print('🔄 [KYC] Rafraîchissement du statut KYC après clic sur notification...');
          Get.find<KycController>().getUserKycData();
          print('✅ [KYC] Statut KYC rafraîchi avec succès');
        } catch (e, stackTrace) {
          print('❌ [KYC] Erreur lors du rafraîchissement du statut KYC: $e');
          print('❌ [KYC] StackTrace: $stackTrace');
        }
      }
      
      // Appeler la fonction de gestion des notifications existante
      if (additionalData != null && additionalData['route'] != null) {
        handleNotificationClick(additionalData['route'], additionalData);
      }
    }
  });
}

BookingController bookingController = Get.find();
void handleNotificationClick(String? route, var data) {
  if (token.isEmpty) {
    showErrorToastMessage("Please Login first");
    return;
  }
  
  // Gestion spécifique pour BOOKING_CONFIRMED
  if (data != null && data is Map) {
    String? notificationType = data['type']?.toString();
    if (notificationType == 'BOOKING_CONFIRMED') {
      String? bookingId = data['bookingId']?.toString();
      if (bookingId != null && bookingId.isNotEmpty) {
        print('🔔 [OneSignal] Notification BOOKING_CONFIRMED reçue pour bookingId: $bookingId');
        // Naviguer vers l'écran de réservations (l'utilisateur pourra ensuite cliquer sur la réservation)
        Get.to(const HomeMain(initialIndex: 2));
        generalController.currentIndex.value = 2;
        generalController.tabController.index = 2;
        bookingController.tabIndexOfMybooking = 0; // Onglet "Upcoming" pour les réservations confirmées
        return;
      }
    }
  }
  
  if (route != null) {
    if (route == "inbox") {}
    if (data!["vendorNotification"] == 0) {
      if (route == "booking") {
        Get.to(const HomeMain(initialIndex: 2));
        generalController.currentIndex.value = 2;
        generalController.tabController.index = 2;
        if (data!["status"] == "Declined" || data!["status"] == "Cancelled") {
          bookingController.tabIndexOfMybooking = 2;
        } else if ((data!["status"] == "Pending" ||
            data!["status"] == "Confirmed")) {
          bookingController.tabIndexOfMybooking = 0;
        }
      } else if (route == "review") {
        Get.to(const HomeMain(initialIndex: 2));
        generalController.currentIndex.value = 2;
        generalController.tabController.index = 2;
        bookingController.tabIndexOfMybooking = 1;
      }
    } else if (data!["vendorNotification"] == 1) {
      if (route == "booking") {
        isHostMode.value = true;
        Get.to(const BottomHost(initialIndex: 2));
        generalController.currentIndexHost.value = 2;
        generalController.tabControllerHost.index = 2;
        if (data!["status"] == "Declined" || data!["status"] == "Cancelled") {
          bookingController.tabIndexOfMybooking = 2;
        } else if ((data!["status"] == "Pending" ||
            data!["status"] == "Confirmed")) {
          bookingController.tabIndexOfMybooking = 0;
        }
      } else if (route == "review") {
        isHostMode.value = true;
        Get.to(const BottomHost(initialIndex: 2));
        generalController.currentIndexHost.value = 2;
        generalController.tabControllerHost.index = 2;
        bookingController.tabIndexOfMybooking = 1;
      }
    }
  }
}

Future<void> initializeNotifications() async {
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('launch_background');
  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {
      if (notificationResponse.payload != null) {
        try {
          final Map<String, dynamic> data =
              jsonDecode(notificationResponse.payload!);
          handleNotificationClick(data["route"], data);
        } catch (e) {
          //
        }
      }
    },
  );
}
