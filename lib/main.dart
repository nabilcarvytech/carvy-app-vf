import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:carvy/controller/push_notifications.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/get_data_read.dart';
import 'package:carvy/work_space.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/locale_string.dart';
import 'package:carvy/service/onesignal_service.dart';
import 'package:carvy/services/auth_service.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/view/splash/initial_screen.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'helper/get_di.dart' as di;
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Identifiant `intl` pour [initializeDateFormatting] (ex. fr_FR, en_US).
const List<Locale> kAppSupportedLocales = [
  Locale('fr', 'FR'),
  Locale('en', 'US'),
  Locale('es', 'ES'),
  Locale('ar', 'AR'),
];

const List<LocalizationsDelegate<dynamic>> kAppLocalizationsDelegates = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

String _dateSymbolLocaleFor(Locale l) {
  final c = l.countryCode;
  if (c != null && c.isNotEmpty) return '${l.languageCode}_$c';
  switch (l.languageCode) {
    case 'fr':
      return 'fr_FR';
    case 'en':
      return 'en_US';
    case 'es':
      return 'es_ES';
    case 'ar':
      return 'ar';
    default:
      return 'fr_FR';
  }
}

void main() {
  // S'assurer que le binding Flutter est initialisé AVANT tout
  WidgetsFlutterBinding.ensureInitialized();

  // NE PAS silencier les erreurs Flutter : on les loggue et on les remonte dans la zone
  FlutterError.onError = (FlutterErrorDetails details) {
    // Log dans la console (visible avec flutter logs / adb logcat)
    FlutterError.dumpErrorToConsole(details);
    // Remonter dans la zone courante pour que runZonedGuarded puisse aussi les capter
    Zone.current.handleUncaughtError(
      details.exception,
      details.stack ?? StackTrace.empty,
    );
  };

  // Zone globale qui attrape toutes les erreurs non gérées (sync + async)
  runZonedGuarded(() async {
    try {
      // ========== INITIALISATION SÉCURISÉE ==========
      await di.init();
      await GetStorage().initStorage;
      
      // Initialiser isHostMode après que GetStorage soit prêt
      try {
        initializeIsHostMode();
        debugPrint('✅ [MAIN] isHostMode initialized successfully');
      } catch (e) {
        debugPrint('⚠️ [MAIN] Could not initialize isHostMode: $e');
      }

      // Ajouter un délai pour permettre au système de se stabiliser avant d'initialiser OneSignal
      // Cela évite les crashes liés à l'initialisation trop rapide
      await Future.delayed(const Duration(seconds: 1));

      // Initialisation de Firebase : ne JAMAIS bloquer l'UI
      try {
        await firebaseInit();
        debugPrint('✅ [MAIN] Firebase initialized successfully');
      } catch (e, stackTrace) {
        debugPrint('🔴 ERROR: Firebase init failed: $e');
        debugPrint('🔴 STACKTRACE: $stackTrace');
        // Ne pas rethrow ici : on veut quand même atteindre runApp()
      }

      // Initialisation de OneSignal : séparée avec gestion d'erreur détaillée
      // Déplacée après le délai pour éviter les crashes au démarrage
      if (!kIsWeb) {
        try {
          debugPrint('🔔 [MAIN] Starting OneSignal initialization...');
          debugPrint(
              '🚨 [DIAG_MAIN] Niveau verbeux SDK + audit App ID (main) puis init service');
          OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
          OneSignalService.logAppIdConfigDiagnostic(source: 'DIAG_MAIN_CONFIG');
          await OneSignalService.initialize();
          debugPrint(
              '🚨 [DIAG_MAIN] Observateur pushSubscription actif (logs [DIAG_FCM]/[DIAG_ONESIGNAL]/[DIAG_PERM] depuis OneSignalService)');
          debugPrint('✅ [MAIN] OneSignal initialized successfully');
          
          // Vérification au démarrage : si l'utilisateur est déjà connecté, synchroniser OneSignal
          try {
            await AuthService.initializeAuthenticatedSessionFromStorage();
          } catch (e) {
            debugPrint('⚠️ [MAIN] Erreur lors de la vérification du token: $e');
            // Ne pas bloquer l'application
          }
        } catch (e, stackTrace) {
          debugPrint('🔴 ERROR: OneSignal init failed: $e');
          debugPrint('🔴 STACKTRACE: $stackTrace');
          // Ne pas rethrow ici : on veut quand même atteindre runApp()
          // L'application peut fonctionner sans OneSignal
        }
      }

      // Initialisation des notifications locales : séparée avec gestion d'erreur
      try {
        await initializeNotifications();
        debugPrint('✅ [MAIN] Local notifications initialized successfully');
      } catch (e, stackTrace) {
        debugPrint('🔴 ERROR: Local notifications init failed: $e');
        debugPrint('🔴 STACKTRACE: $stackTrace');
        // Ne pas rethrow ici : on veut quand même atteindre runApp()
      }

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

      // Données de symboles de date pour DateFormat.yMMMEd etc. (évite LocaleDataException)
      try {
        await initializeDateFormatting('fr_FR', null);
        final sym = _dateSymbolLocaleFor(selectedLocale);
        if (sym != 'fr_FR') {
          await initializeDateFormatting(sym, null);
        }
        debugPrint('✅ [MAIN] initializeDateFormatting ok (fr_FR + $sym)');
      } catch (e, stackTrace) {
        debugPrint('🔴 [MAIN] initializeDateFormatting failed: $e');
        debugPrint('🔴 STACKTRACE: $stackTrace');
      }

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
        debugPrint(
            'PostFrame: Get.locale countryCode: ${Get.locale?.countryCode}');

        try {
          await generalController.fetchGeneralSettings();
        } catch (e, stackTrace) {
          debugPrint(
              '🔴 ERROR: main -> fetchGeneralSettings failed: $e\n$stackTrace');
        }
      });

      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      // Configuration de la barre de statut transparente
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ));

      ErrorWidget.builder = (FlutterErrorDetails details) {
        // En production, on montre juste un Container vide pour ne pas choquer l'utilisateur.
        return Container();
      };

      try {
        await initializeDateFormatting('fr_FR', null);
        debugPrint('✅ [MAIN] initializeDateFormatting(fr_FR) avant runApp');
      } catch (e, stackTrace) {
        debugPrint('🔴 [MAIN] initializeDateFormatting(fr_FR) avant runApp: $e');
        debugPrint('🔴 STACKTRACE: $stackTrace');
      }

      runApp(
        _MyApp(initialLocale: selectedLocale),
      );
    } catch (e, stackTrace) {
      // Catch global pour tout ce qui se passe dans main()
      debugPrint('🔴 ERROR: main() top-level error: $e');
      debugPrint('🔴 STACKTRACE: $stackTrace');
    }
  }, (error, stackTrace) {
    // Handler de la zone : toute erreur non interceptée finira ici
    debugPrint('🔴 UNCAUGHT (zone): $error');
    debugPrint('🔴 STACKTRACE: $stackTrace');
  });
}

class _MyApp extends StatefulWidget {
  final Locale initialLocale;

  const _MyApp({required this.initialLocale});

  @override
  State<_MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<_MyApp> {
  // Locale courante : initialisée une seule fois dans initState, mise à jour uniquement via le listener
  late Locale _currentLocale;

  @override
  void initState() {
    super.initState();
    // Initialiser la locale UNE SEULE FOIS au démarrage
    _currentLocale = widget.initialLocale;
    localeNotifier.value = widget.initialLocale;
    globallanguage = widget.initialLocale;
    Get.locale = widget.initialLocale;
    Get.updateLocale(widget.initialLocale);

    debugPrint(
        '✅ _MyApp initState: Locale initialized to ${_currentLocale.languageCode}_${_currentLocale.countryCode}');

    // Écouter les changements de locale (seulement si elle change depuis l'extérieur, pas depuis build())
    localeNotifier.addListener(_onLocaleChanged);
  }

  void _onLocaleChanged() {
    if (mounted && localeNotifier.value != _currentLocale) {
      debugPrint(
          '🔄 _MyApp: Locale changed from ${_currentLocale.languageCode} to ${localeNotifier.value.languageCode}');
      setState(() {
        _currentLocale = localeNotifier.value;
        globallanguage = localeNotifier.value;
        Get.locale = localeNotifier.value;
        Get.updateLocale(localeNotifier.value);
      });
    }
  }

  @override
  void dispose() {
    localeNotifier.removeListener(_onLocaleChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // CRITIQUE: build() doit être PUR - aucune lecture de storage, aucune mise à jour de state
    // On utilise uniquement _currentLocale qui est mise à jour via setState() dans le listener
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, localeToUse, child) {
        // Utiliser la locale du ValueNotifier (qui est synchronisée avec _currentLocale via le listener)
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
  // CRITIQUE: build() doit être PUR - pas de mise à jour de state ici
  // Get.locale et globallanguage sont déjà synchronisés dans initState() et _onLocaleChanged()
  // Ne PAS appeler Get.updateLocale() ici car cela peut déclencher des rebuilds infinis

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ColorNotifires()),
    ],
    child: GetMaterialApp(
      // Key stable : ne change que si la locale change vraiment (via setState dans _onLocaleChanged)
      key: ValueKey(
          'app_web_${localeToUse.languageCode}_${localeToUse.countryCode}'),
      theme: ThemeData(fontFamily: 'Gilroy Regular'),
      localizationsDelegates: kAppLocalizationsDelegates,
      supportedLocales: kAppSupportedLocales,
      builder: (context, child) {
        return BotToastInit()(context, child);
      },
      navigatorObservers: [BotToastNavigatorObserver()],
      debugShowCheckedModeBanner: false,
      getPages: getPagesforweb,
      translations: LocaleString(),
      locale: localeToUse,
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
  // CRITIQUE: build() doit être PUR - pas de mise à jour de state ici
  // Get.locale et globallanguage sont déjà synchronisés dans initState() et _onLocaleChanged()
  // Ne PAS appeler Get.updateLocale() ici car cela peut déclencher des rebuilds infinis

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ColorNotifires()),
    ],
    child: GetMaterialApp(
      // Key stable : ne change que si la locale change vraiment (via setState dans _onLocaleChanged)
      key: ValueKey(
          'app_mobile_${localeToUse.languageCode}_${localeToUse.countryCode}'),
      theme: ThemeData(fontFamily: 'Gilroy Regular'),
      localizationsDelegates: kAppLocalizationsDelegates,
      supportedLocales: kAppSupportedLocales,
      builder: (context, child) {
        return BotToastInit()(context, child);
      },
      navigatorObservers: [BotToastNavigatorObserver()],
      debugShowCheckedModeBanner: false,
      getPages: getPagesforweb,
      translations: LocaleString(),
      locale: localeToUse,
      fallbackLocale: const Locale('en', 'US'),
      home: const InitialScreen(),
    ),
  );
}
