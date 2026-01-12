import 'package:flutter/material.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import 'package:carvy/view/onBoarding/vehicle/vehicle_on_boarding_screen.dart';
import 'package:carvy/helper/get_data_read.dart';
import 'package:carvy/work_space.dart';

/// Écran d'accueil client
/// Redirige vers HomeMain si l'utilisateur est connecté, sinon vers l'onboarding
class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Vérifier si l'utilisateur est connecté (a des données utilisateur sauvegardées)
    var userData = getData.read("UserData");
    bool isLoggedIn = userData != null && userData.toString().isNotEmpty;

    // Si l'utilisateur n'est pas connecté, rediriger vers l'onboarding puis login
    // Sinon, afficher HomeMain
    if (!isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const VehicleOnBoardingScreen(),
          ),
        );
      });
      // Afficher un écran de chargement pendant la redirection
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: vehicalThemColor,
          ),
        ),
      );
    }

    // HomeMain est l'écran principal du client
    return const HomeMain(initialIndex: 0);
  }
}
