import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/view/auth/agency_sign_up_screen.dart';
import 'package:carvy/work_space.dart';

/// Écran d'inscription pour les agences
/// Redirige vers l'écran d'inscription multi-étapes pour les agences
class AgencyRegistrationScreen extends StatelessWidget {
  const AgencyRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Rediriger vers l'écran d'inscription multi-étapes pour les agences
    if (webPlateForm) {
      Get.toNamed(WebRoutes.agencySignUpScreen);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.to(() => const AgencySignUpScreen());
      });
    }

    // Afficher un écran de chargement pendant la redirection
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: vehicalThemColor,
        ),
      ),
    );
  }
}
