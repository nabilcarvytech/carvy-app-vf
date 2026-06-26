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

/// Mettre à `true` pour confirmer un crash sémantique global au démarrage.
/// Si le crash disparaît → le problème est dans l'arbre sémantique de l'app.
const bool kExcludeSemanticsGlobally = false;

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
  // Toute l'initialisation (binding inclus) vit dans la MÊME zone.
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
      final message = details.exceptionAsString();
      if (kDebugMode && message.contains('_dependents.isEmpty')) {
        debugPrint('🐛 [NEUTRALISÉ] Assertion _dependents.isEmpty interceptée en Debug');
        debugPrint('🐛 [NEUTRALISÉ] ${details.summary}');
        return;
      }
      if (kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      } else {
        FlutterError.presentError(details);
      }
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      final message = error.toString();
      if (kDebugMode && message.contains('_dependents.isEmpty')) {
        debugPrint('🐛 [NEUTRALISÉ] _dependents.isEmpty (platform) intercepté en Debug');
        return true;
      }
      debugPrint('🔴 UNCAUGHT (platform): $error');
      if (kDebugMode) {
        debugPrint('🔴 STACKTRACE: $stack');
      }
      return true;
    };

    try {
      await _bootstrapApp();
    } catch (e, stackTrace) {
      debugPrint('🔴 ERROR: bootstrap failed: $e');
      if (kDebugMode) {
        debugPrint('🔴 STACKTRACE: $stackTrace');
      }
    }
  }, (error, stackTrace) {
    if (kDebugMode && error.toString().contains('_dependents.isEmpty')) {
      debugPrint('🐛 [NEUTRALISÉ] _dependents.isEmpty (zone) intercepté en Debug');
      return;
    }
    debugPrint('🔴 UNCAUGHT (zone): $error');
    if (kDebugMode) {
      debugPrint('🔴 STACKTRACE: $stackTrace');
    }
  });
}

Future<void> _bootstrapApp() async {
  await di.init();
  await GetStorage().initStorage;

  try {
    initializeIsHostMode();
  } catch (e) {
    debugPrint('⚠️ [MAIN] Could not initialize isHostMode: $e');
  }

  await Future.delayed(const Duration(seconds: 1));

  try {
    await firebaseInit();
  } catch (e, stackTrace) {
    debugPrint('🔴 ERROR: Firebase init failed: $e');
    if (kDebugMode) {
      debugPrint('🔴 STACKTRACE: $stackTrace');
    }
  }

  if (!kIsWeb) {
    try {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignalService.logAppIdConfigDiagnostic(source: 'DIAG_MAIN_CONFIG');
      await OneSignalService.initialize();
      try {
        await AuthService.initializeAuthenticatedSessionFromStorage();
      } catch (e) {
        debugPrint('⚠️ [MAIN] Erreur lors de la vérification du token: $e');
      }
    } catch (e, stackTrace) {
      debugPrint('🔴 ERROR: OneSignal init failed: $e');
      if (kDebugMode) {
        debugPrint('🔴 STACKTRACE: $stackTrace');
      }
    }
  }

  try {
    await initializeNotifications();
  } catch (e, stackTrace) {
    debugPrint('🔴 ERROR: Local notifications init failed: $e');
    if (kDebugMode) {
      debugPrint('🔴 STACKTRACE: $stackTrace');
    }
  }

  final Locale selectedLocale = _resolveStartupLocale();

  globallanguage = selectedLocale;
  Get.locale = selectedLocale;
  localeNotifier.value = selectedLocale;

  try {
    await initializeDateFormatting('fr_FR', null);
    final sym = _dateSymbolLocaleFor(selectedLocale);
    if (sym != 'fr_FR') {
      await initializeDateFormatting(sym, null);
    }
  } catch (e, stackTrace) {
    debugPrint('🔴 [MAIN] initializeDateFormatting failed: $e');
    if (kDebugMode) {
      debugPrint('🔴 STACKTRACE: $stackTrace');
    }
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  ErrorWidget.builder = (FlutterErrorDetails details) => Container();

  runApp(const _MyApp());

  // Après runApp : aucune mutation de locale (évite rebuild pendant la 1ʳᵉ passe sémantique).
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(
      generalController.fetchGeneralSettings().catchError(
        (Object e, StackTrace stackTrace) {
          debugPrint(
            '🔴 ERROR: main -> fetchGeneralSettings failed: $e\n$stackTrace',
          );
        },
      ),
    );
  });
}

Locale _resolveStartupLocale() {
  final lanValue = getData.read('lanValue');
  if (lanValue != null &&
      lanValue is int &&
      lanValue >= 0 &&
      lanValue < locale.length) {
    return locale[lanValue]['locale'] as Locale;
  }
  return const Locale('en', 'US');
}

class _MyApp extends StatelessWidget {
  const _MyApp();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, localeToUse, child) {
        return ScreenUtilInit(
          designSize: const Size(360, 640),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => kExcludeSemanticsGlobally
              ? ExcludeSemantics(
                  child: kIsWeb
                      ? buildWebApp(localeToUse)
                      : buildMobileApp(localeToUse),
                )
              : (kIsWeb
                  ? buildWebApp(localeToUse)
                  : buildMobileApp(localeToUse)),
        );
      },
    );
  }
}

Widget buildWebApp(Locale localeToUse) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ColorNotifires()),
    ],
    child: GetMaterialApp(
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
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ColorNotifires()),
    ],
    child: GetMaterialApp(
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
