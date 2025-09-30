import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:carvy/controller/push_notifications.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/get_data_read.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/locale_string.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/view/splash/initial_screen.dart';
import 'package:carvy/work_space.dart';
import 'helper/get_di.dart' as di;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await di.init();
  await GetStorage().initStorage;

  if (!kIsWeb) {
    await setupOneSignal();
  }
  await firebaseInit();
  await initializeNotifications();

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    var lanValue = GetStorage().read("lanValue");
    Locale selectedLocale;
    if (lanValue != null &&
        lanValue is int &&
        lanValue >= 0 &&
        lanValue < locale.length) {
      selectedLocale = locale[lanValue]['locale'] as Locale;
    } else {
      selectedLocale = const Locale('en', 'US');
    }
    await updateLanguage(selectedLocale);
    globallanguage = selectedLocale;

    try {
      await generalController.fetchGeneralSettings();
    } catch (e, stackTrace) {
      debugPrint('main: Error fetching general settings: $e\n$stackTrace');
    }
  });

  FlutterError.onError = (FlutterErrorDetails details) {};

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    ScreenUtilInit(
      designSize: const Size(360, 640),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => kIsWeb ? buildWebApp() : buildMobileApp(),
    ),
  );
}

Widget buildWebApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ColorNotifires()),
    ],
    child: GetMaterialApp(
      theme: ThemeData(fontFamily: 'Gilroy Regular'),
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      debugShowCheckedModeBanner: false,
      getPages: getPagesforweb,
      translations: LocaleString(),
      locale: globallanguage ?? const Locale('en', 'US'),
      initialRoute: WebRoutes.initial,
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => const NotFoundPage(),
      ),
    ),
  );
}

Widget buildMobileApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ColorNotifires()),
    ],
    child: GetMaterialApp(
      theme: ThemeData(fontFamily: 'Gilroy Regular'),
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      debugShowCheckedModeBanner: false,
      getPages: getPagesforweb,
      translations: LocaleString(),
      locale: globallanguage ?? const Locale('en', 'US'),
      home: const InitialScreen(),
    ),
  );
}
