import 'dart:collection';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/controller/booking_controller.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/firebase_options.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import 'package:carvy/view/chat/conversation_screen.dart';
import 'package:carvy/view/host/bottom_bar_host.dart';
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
  OneSignal.initialize(Config.oneSiginalAppid);
  OneSignal.Notifications.requestPermission(true);
  await getFCMTokenInitialToSetThedata();
}

Future<void> getFCMTokenInitialToSetThedata() async {
  try {
    var fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await OneSignal.login(fcmToken);
      await addTagWithKey(fcmToken);
      await fetchPlayerId(fcmToken);
    }
  } catch (error) {
    //
  }
}

Future<void> getFCMToken() async {
  try {
    var fcmToken = await FirebaseMessaging.instance.getToken();
    if (token.isEmpty || token == "") {
      return;
    }
    if (fcmToken != null) {
      await OneSignal.login(fcmToken);
      await addTagWithKey(fcmToken);
      await fetchPlayerId(fcmToken);
    }
  } catch (error) {
    //
  }
}

Future<void> addTagWithKey(String token) async {
  await OneSignal.User.addTagWithKey("FCMToken", token);
}

Future<void> fetchPlayerId(fcmToken) async {
  try {
    oneSiginalplayerid = OneSignal.User.pushSubscription.id;
    GetStorage().write('oneSiginalplayerid', oneSiginalplayerid);
    if (oneSiginalplayerid != null) {
      // ========== MOCK DATA - OLD API CALL COMMENTED ==========
      // await httpGet(
      //   Config.fcmUpdate,
      //   {"fcm": fcmToken, "player_id": oneSiginalplayerid},
      // );

      // MOCK: Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // MOCK: Static success response for FCM update (no response needed, just success)
      // The function doesn't check the response, so we just simulate the delay
      // ========== END MOCK DATA ==========
      print(oneSiginalplayerid);
      print("OmneSignialid");
    } else {}
  } catch (error) {
    //
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
      if (markNotificationAsProcessed(event.notification.notificationId)) {
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
      handleNotificationClick(event.notification.additionalData!['route'],
          event.notification.additionalData);
    }
  });
}

BookingController bookingController = Get.find();
void handleNotificationClick(String? route, var data) {
  if (token.isEmpty) {
    showErrorToastMessage("Please Login first");
    return;
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
