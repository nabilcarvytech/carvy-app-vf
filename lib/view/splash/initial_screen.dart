import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:carvy/controller/kyc_controller.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/helper/get_data_read.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import 'package:carvy/view/splash/splash_screen.dart';
import 'package:carvy/work_space.dart';
import '../../customwidget/custom_active_module_id_widget.dart';
import '../host/bottom_bar_host.dart';
import '../onBoarding/vehicle/vehicle_on_boarding_screen.dart';
import 'language_selection_screen.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  // Ne pas initialiser directement avec Get.find() pour éviter les crashes
  // si GetX n'est pas encore prêt
  KycController? kycController;

  /// Pour éviter les doubles navigations en cas de timeout / data lente
  bool _navigationDone = false;

  @override
  void initState() {
    super.initState();
    // Initialiser le contrôleur de manière sécurisée
    try {
      kycController = Get.find<KycController>();
    } catch (e) {
      debugPrint('⚠️ [INITIAL_SCREEN] KycController not found yet: $e');
      // Le contrôleur sera disponible plus tard via Get.lazyPut
    }
    // Lancer le flux de splash dès que possible
    _startSplashFlow();
  }

  /// Démarre le flux de navigation du splash avec une "Safety Timer"
  Future<void> _startSplashFlow() async {
    debugPrint('🚀 Splash: Navigation started');

    try {
      // Temps de splash "normal" basé sur Firstuser
      final initialDelay = Duration(
        seconds: getData.read('Firstuser') == null ? 3 : 2,
      );

      // Future représentant le travail de préparation (ici, simple délai)
      Future<void> dataLoading = Future<void>.delayed(initialDelay);

      // Timeout dur de 5 secondes : quoi qu'il arrive, on ne reste pas bloqué
      const timeout = Duration(seconds: 5);

      await Future.any([
        dataLoading,
        Future<void>.delayed(timeout),
      ]);

      if (!mounted || _navigationDone) {
        return;
      }

      _navigationDone = true;
      _navigateToNextScreen();

      debugPrint('🏁 Splash: Navigation finished');
    } catch (e, stackTrace) {
      debugPrint('🔴 ERROR: Splash flow failed: $e');
      debugPrint('🔴 STACKTRACE: $stackTrace');
      // En cas d'erreur imprévue, tenter au moins d'aller vers l'écran de login / onboarding
      if (mounted && !_navigationDone) {
        _navigationDone = true;
        _navigateToNextScreen();
      }
    }
  }

  /// Logique de décision de la prochaine page (langue / onboarding / home / host)
  void _navigateToNextScreen() {
    try {
      // Vérifier si la langue a été choisie
      var lanValue = getData.read("lanValue");
      bool languageSelected = lanValue != null &&
          lanValue is int &&
          lanValue >= 0 &&
          lanValue < locale.length;

      if (!languageSelected) {
        debugPrint('ℹ️ Splash: Language not selected, going to LanguageSelection');
        // Rediriger vers la sélection de langue si elle n'a pas été choisie
        if (webPlateForm) {
          Get.offNamed(WebRoutes.languageSelectionScreen);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LanguageSelectionScreen(),
            ),
          );
        }
        return;
      }

      debugPrint('ℹ️ Splash: Language already selected, continuing normal flow');

      // Si la langue est choisie, continuer avec le flux normal
      final bool isFirstUser = getData.read('Firstuser') != true;

      // Vérifier isHostMode de manière sécurisée
      // S'assurer que GetStorage est initialisé et que isHostMode est prêt
      bool hostModeValue = false;
      try {
        // Utiliser la valeur de isHostMode (initialisée dans main.dart après GetStorage)
        hostModeValue = isHostMode.value;
        debugPrint('ℹ️ [INITIAL_SCREEN] isHostMode value: $hostModeValue');
      } catch (e) {
        // En cas d'erreur, lire directement depuis GetStorage comme fallback
        try {
          hostModeValue = GetStorage().read('isHostMode') ?? false;
          debugPrint('ℹ️ [INITIAL_SCREEN] Fallback: reading isHostMode from storage: $hostModeValue');
        } catch (e2) {
          debugPrint('⚠️ [INITIAL_SCREEN] Error reading isHostMode: $e2, defaulting to false');
          hostModeValue = false;
        }
      }

      if (webPlateForm) {
        if (isFirstUser) {
          debugPrint('ℹ️ Splash: Web first user, going to VehicleOnBoardingScreen');
          Get.offNamed(WebRoutes.vehicleOnboardingScreen);
        } else {
          if (hostModeValue == true) {
            debugPrint('ℹ️ Splash: Web host mode, going to BottomHost');
            Get.offNamed(WebRoutes.buttomHost);
          } else {
            debugPrint('ℹ️ Splash: Web normal user, going to HomeMain');
            Get.offNamed(WebRoutes.homeMain);
          }
        }
      } else {
        if (isFirstUser) {
          debugPrint('ℹ️ Splash: Mobile first user, going to VehicleOnBoardingScreen');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const VehicleOnBoardingScreen(),
            ),
          );
        } else {
          if (hostModeValue == true) {
            debugPrint('ℹ️ Splash: Mobile host mode, going to BottomHost');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const BottomHost(initialIndex: 0),
              ),
            );
          } else {
            debugPrint('ℹ️ Splash: Mobile normal user, going to HomeMain');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeMain(initialIndex: 0),
              ),
            );
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('🔴 ERROR: _navigateToNextScreen failed: $e');
      debugPrint('🔴 STACKTRACE: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    // IMPORTANT : aucune logique asynchrone / setState ici pour éviter les boucles
    // Sécurisation : Vérifier que le Provider est disponible avant de l'utiliser
    try {
      notifires = Provider.of<ColorNotifires>(context, listen: false);
    } catch (e) {
      debugPrint('⚠️ [INITIAL_SCREEN] ColorNotifires Provider not found: $e');
      // Utiliser une valeur par défaut si le Provider n'est pas disponible
      // Le Provider sera disponible après le premier frame
    }
    return Scaffold(
      backgroundColor: themeColor,
      body: const SplashScreen(),
    );
  }
}
