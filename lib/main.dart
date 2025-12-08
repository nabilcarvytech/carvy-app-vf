import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:carvy/controller/push_notifications.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/get_data_read.dart';
import 'package:carvy/work_space.dart';
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
  await di.init();
  await GetStorage().initStorage;
  if (!kIsWeb) {
    await setupOneSignal();
  }
  await firebaseInit();
  await initializeNotifications();
  // Charger la langue AVANT de créer l'application
  debugPrint('=== Main.dart: Loading Language ===');
  var lanValue = getData.read("lanValue");
  debugPrint(
      'Read lanValue from storage: $lanValue (type: ${lanValue.runtimeType})');
  debugPrint('Locale list length: ${locale.length}');

  // Afficher toutes les langues disponibles
  for (int i = 0; i < locale.length; i++) {
    Locale loc = locale[i]['locale'] as Locale;
    debugPrint(
        '  [$i] ${locale[i]['name']} - ${loc.languageCode}_${loc.countryCode}');
  }

  Locale selectedLocale;
  if (lanValue != null &&
      lanValue is int &&
      lanValue >= 0 &&
      lanValue < locale.length) {
    selectedLocale = locale[lanValue]['locale'] as Locale;
    debugPrint(
        'Selected locale from storage: ${selectedLocale.languageCode}_${selectedLocale.countryCode} (index: $lanValue)');
  } else {
    selectedLocale = const Locale('en', 'US');
    debugPrint('No valid language found, using default: en_US');
  }

  // Initialiser globallanguage AVANT de créer GetMaterialApp
  globallanguage = selectedLocale;

  // Initialiser le ValueNotifier avec la locale chargée
  localeNotifier.value = selectedLocale;

  // CRITIQUE: Définir Get.locale AVANT runApp pour que GetX l'utilise
  Get.locale = selectedLocale;

  debugPrint('globallanguage initialized to: $globallanguage');
  debugPrint(
      'Selected locale: ${selectedLocale.languageCode}_${selectedLocale.countryCode}');
  debugPrint(
      'Get.locale set to: ${Get.locale?.languageCode}_${Get.locale?.countryCode}');
  debugPrint('GetMaterialApp will use locale: $selectedLocale');
  debugPrint('===================================');

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    // S'assurer que la locale est bien mise à jour dans GetX après le premier frame
    Get.updateLocale(selectedLocale);
    globallanguage = selectedLocale;
    localeNotifier.value = selectedLocale;
    debugPrint('PostFrame: GetX locale updated to: ${Get.locale}');
    debugPrint('PostFrame: globallanguage updated to: $globallanguage');
    debugPrint(
        'PostFrame: Get.locale languageCode: ${Get.locale?.languageCode}');
    debugPrint('PostFrame: Get.locale countryCode: ${Get.locale?.countryCode}');

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
    _MyApp(initialLocale: selectedLocale),
  );
}

class _MyApp extends StatefulWidget {
  final Locale initialLocale;

  const _MyApp({required this.initialLocale});

  @override
  State<_MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<_MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialiser le ValueNotifier avec la locale initiale
    localeNotifier.value = widget.initialLocale;
    globallanguage = widget.initialLocale;
    Get.locale = widget.initialLocale;

    // Écouter les changements de locale
    localeNotifier.addListener(_onLocaleChanged);
  }

  void _onLocaleChanged() {
    if (mounted) {
      setState(() {
        globallanguage = localeNotifier.value;
        Get.locale = localeNotifier.value;
      });
    }
  }

  @override
  void dispose() {
    localeNotifier.removeListener(_onLocaleChanged);
    super.dispose();
  }

  Locale _getLocaleFromStorage() {
    var lanValue = getData.read("lanValue");
    debugPrint('_MyApp: Reading locale from storage, lanValue: $lanValue');
    debugPrint('_MyApp: Locale list length: ${locale.length}');
    for (int i = 0; i < locale.length; i++) {
      Locale loc = locale[i]['locale'] as Locale;
      debugPrint(
          '_MyApp:   [$i] ${locale[i]['name']} - ${loc.languageCode}_${loc.countryCode}');
    }

    if (lanValue != null &&
        lanValue is int &&
        lanValue >= 0 &&
        lanValue < locale.length) {
      Locale selectedLocale = locale[lanValue]['locale'] as Locale;
      debugPrint(
          '_MyApp: Found locale in storage: ${selectedLocale.languageCode}_${selectedLocale.countryCode} (index: $lanValue)');
      debugPrint('_MyApp: Locale name: ${locale[lanValue]['name']}');
      return selectedLocale;
    }

    debugPrint(
        '_MyApp: No valid locale in storage, using initial: ${widget.initialLocale.languageCode}_${widget.initialLocale.countryCode}');
    return widget.initialLocale;
  }

  @override
  Widget build(BuildContext context) {
    // Toujours recharger la locale depuis le stockage pour s'assurer qu'elle est à jour
    Locale currentLocale = _getLocaleFromStorage();

    // Mettre à jour le ValueNotifier si la locale a changé
    if (localeNotifier.value != currentLocale) {
      localeNotifier.value = currentLocale;
    }

    // Utiliser la valeur du ValueNotifier pour forcer la reconstruction
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, localeToUse, child) {
        // Mettre à jour globallanguage et Get.locale
        globallanguage = localeToUse;
        Get.locale = localeToUse;

        debugPrint(
            '_MyApp build: Using locale ${localeToUse.languageCode}_${localeToUse.countryCode}');
        debugPrint(
            '_MyApp build: Get.locale is ${Get.locale?.languageCode}_${Get.locale?.countryCode}');
        debugPrint(
            '_MyApp build: globallanguage is ${globallanguage?.languageCode}_${globallanguage?.countryCode}');

        return ScreenUtilInit(
          designSize: const Size(360, 640),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) =>
              kIsWeb ? buildWebApp(localeToUse) : buildMobileApp(localeToUse),
        );
      },
    );
  }
}

Widget buildWebApp(Locale localeToUse) {
  debugPrint(
      'buildWebApp called with locale: ${localeToUse.languageCode}_${localeToUse.countryCode}');
  debugPrint(
      'Get.locale before buildWebApp: ${Get.locale?.languageCode}_${Get.locale?.countryCode}');

  // S'assurer que Get.locale est synchronisé AVANT de créer GetMaterialApp
  Get.locale = localeToUse;
  globallanguage = localeToUse;

  // Forcer GetX à utiliser cette locale
  Get.updateLocale(localeToUse);

  debugPrint(
      'Get.locale after sync: ${Get.locale?.languageCode}_${Get.locale?.countryCode}');
  debugPrint(
      'Locale key format: ${localeToUse.languageCode}_${localeToUse.countryCode}');
  debugPrint(
      'Will use locale: ${localeToUse.languageCode}_${localeToUse.countryCode}');

  // Test de traduction pour vérifier
  try {
    // Vérifier les clés disponibles dans LocaleString
    LocaleString localeString = LocaleString();
    debugPrint('Available translation keys: ${localeString.keys.keys}');
    debugPrint(
        'Current locale key format: ${localeToUse.languageCode}_${localeToUse.countryCode}');

    String testTranslation = 'User not exist'.tr;
    debugPrint('Test translation "User not exist": $testTranslation');

    // Vérifier si Get.locale correspond
    debugPrint('Get.locale: ${Get.locale}');
    debugPrint('Get.locale?.languageCode: ${Get.locale?.languageCode}');
    debugPrint('Get.locale?.countryCode: ${Get.locale?.countryCode}');
  } catch (e) {
    debugPrint('Error getting translation: $e');
  }

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ColorNotifires()),
    ],
    child: GetMaterialApp(
      key: ValueKey(
          'app_${localeToUse.languageCode}_${localeToUse.countryCode}'), // Key unique pour forcer la reconstruction
      theme: ThemeData(fontFamily: 'Gilroy Regular'),
      builder: (context, child) {
        return BotToastInit()(context, child);
      },
      navigatorObservers: [BotToastNavigatorObserver()],
      debugShowCheckedModeBanner: false,
      getPages: getPagesforweb,
      translations: LocaleString(),
      locale: localeToUse, // Utiliser directement localeToUse
      fallbackLocale: const Locale('en', 'US'),
      initialRoute: WebRoutes.initial,
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => const NotFoundPage(),
      ),
    ),
  );
}

Widget buildMobileApp(Locale localeToUse) {
  debugPrint(
      'buildMobileApp called with locale: ${localeToUse.languageCode}_${localeToUse.countryCode}');
  debugPrint(
      'Get.locale before buildMobileApp: ${Get.locale?.languageCode}_${Get.locale?.countryCode}');

  // S'assurer que Get.locale est synchronisé AVANT de créer GetMaterialApp
  Get.locale = localeToUse;
  globallanguage = localeToUse;

  // Forcer GetX à utiliser cette locale
  Get.updateLocale(localeToUse);

  debugPrint(
      'Get.locale after sync: ${Get.locale?.languageCode}_${Get.locale?.countryCode}');
  debugPrint(
      'Locale key format: ${localeToUse.languageCode}_${localeToUse.countryCode}');
  debugPrint(
      'Will use locale: ${localeToUse.languageCode}_${localeToUse.countryCode}');

  // Test de traduction pour vérifier
  try {
    // Vérifier les clés disponibles dans LocaleString
    LocaleString localeString = LocaleString();
    debugPrint('Available translation keys: ${localeString.keys.keys}');
    debugPrint(
        'Current locale key format: ${localeToUse.languageCode}_${localeToUse.countryCode}');

    String testTranslation = 'User not exist'.tr;
    debugPrint('Test translation "User not exist": $testTranslation');

    // Vérifier si Get.locale correspond
    debugPrint('Get.locale: ${Get.locale}');
    debugPrint('Get.locale?.languageCode: ${Get.locale?.languageCode}');
    debugPrint('Get.locale?.countryCode: ${Get.locale?.countryCode}');
  } catch (e) {
    debugPrint('Error getting translation: $e');
  }

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ColorNotifires()),
    ],
    child: GetMaterialApp(
      key: ValueKey(
          'app_${localeToUse.languageCode}_${localeToUse.countryCode}'), // Key unique pour forcer la reconstruction
      theme: ThemeData(fontFamily: 'Gilroy Regular'),
      builder: (context, child) {
        return BotToastInit()(context, child);
      },
      navigatorObservers: [BotToastNavigatorObserver()],
      debugShowCheckedModeBanner: false,
      getPages: getPagesforweb,
      translations: LocaleString(),
      locale: localeToUse, // Utiliser directement localeToUse
      fallbackLocale: const Locale('en', 'US'),
      home: const InitialScreen(),
    ),
  );
}
