import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/auth/login_screen.dart';
import 'package:carvy/work_space.dart';

/// Écran de confirmation affiché après l'inscription d'une agence
/// Indique que l'inscription est en attente de validation
class AgencyRegistrationPendingScreen extends StatelessWidget {
  const AgencyRegistrationPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          // Rediriger vers l'écran de connexion
          if (webPlateForm) {
            Get.offAllNamed(WebRoutes.loginScreen);
          } else {
            Get.offAll(() => LoginScreen());
          }
        }
      },
      child: Scaffold(
        backgroundColor: notifires.getbgcolor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: Dimensions.containerWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icône de succès
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: acentColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle_outline,
                          size: 80,
                          color: acentColor,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Titre
                      Text(
                        'Inscription Envoyée !',
                        style: heading1(context),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      // Message
                      Text(
                        'Votre demande d\'inscription a été envoyée avec succès.',
                        style: regular2(context).copyWith(
                          color: notifires.getGrey3Whitecolor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Votre compte est en attente de validation par notre équipe.',
                        style: regular2(context).copyWith(
                          color: notifires.getGrey3Whitecolor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      // Informations supplémentaires
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: notifires.getBoxColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: acentColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Vous recevrez un email de confirmation une fois votre compte validé.',
                                    style: regular3(context),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: acentColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Le délai de validation est généralement de 24 à 48 heures.',
                                    style: regular3(context),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Bouton pour retourner à la connexion
                      CustomsButtons(
                        text: 'Retour à la connexion',
                        backgroundColor: acentColor,
                        onPressed: () {
                          if (webPlateForm) {
                            Get.offAllNamed(WebRoutes.loginScreen);
                          } else {
                            Get.offAll(() => LoginScreen());
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
