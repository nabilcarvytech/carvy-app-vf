import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/get_data_read.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/work_space.dart';
import '../onBoarding/vehicle/vehicle_on_boarding_screen.dart';
import '../auth/agency_registration_screen.dart';
import '../auth/login_screen.dart';
import '../home/client_home_screen.dart';

class UserRoleSelectionScreen extends StatefulWidget {
  const UserRoleSelectionScreen({super.key});

  @override
  State<UserRoleSelectionScreen> createState() =>
      _UserRoleSelectionScreenState();
}

enum UserRole {
  agency,
  client,
}

class _UserRoleSelectionScreenState extends State<UserRoleSelectionScreen> {
  UserRole? selectedRole;

  @override
  void initState() {
    super.initState();
    debugPrint('=== User Role Selection Screen Init ===');
    
    // Vérifier si un rôle a déjà été sélectionné (optionnel)
    var savedRole = getData.read("selectedUserRole");
    if (savedRole != null) {
      if (savedRole == 'agency') {
        selectedRole = UserRole.agency;
      } else if (savedRole == 'client') {
        selectedRole = UserRole.client;
      }
      debugPrint('Found saved role: $savedRole');
    }
    
    debugPrint('Initial selectedRole: $selectedRole');
    debugPrint('======================================');
  }

  void _continueToNextScreen() async {
    debugPrint('🔵 [ROLE_SELECTION] Bouton Suivant cliqué');
    debugPrint('🔵 [ROLE_SELECTION] Rôle sélectionné: $selectedRole');
    
    if (selectedRole == null) {
      debugPrint('⚠️ [ROLE_SELECTION] No role selected');
      showErrorToastMessage('Veuillez sélectionner un rôle');
      return;
    }

    debugPrint('=== Continue to Next Screen ===');
    debugPrint('Selected role: $selectedRole');

    // Sauvegarder le rôle sélectionné
    save("selectedUserRole", selectedRole == UserRole.agency ? 'agency' : 'client');
    debugPrint('Saved selectedUserRole: ${getData.read("selectedUserRole")}');

    // Attendre un peu pour que la sauvegarde soit prise en compte
    await Future.delayed(const Duration(milliseconds: 100));

    // Naviguer vers l'écran approprié
    if (selectedRole == UserRole.agency) {
      // Pour Agence : naviguer vers AgencyRegistrationScreen (qui redirige vers AgencySignUpScreen)
      debugPrint('🚀 [ROLE_SELECTION] Navigating to AgencyRegistrationScreen');
      debugPrint('🚀 [ROLE_SELECTION] webPlateForm: $webPlateForm');
      if (webPlateForm) {
        debugPrint('🚀 [ROLE_SELECTION] Using Get.offNamed: ${WebRoutes.agencyRegistrationScreen}');
        Get.offNamed(WebRoutes.agencyRegistrationScreen);
      } else {
        debugPrint('🚀 [ROLE_SELECTION] Using Navigator.pushReplacement');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AgencyRegistrationScreen(),
          ),
        );
      }
    } else if (selectedRole == UserRole.client) {
      // Pour Client : naviguer vers ClientHomeScreen
      debugPrint('Navigating to ClientHomeScreen');
      if (webPlateForm) {
        Get.offNamed(WebRoutes.clientHomeScreen);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ClientHomeScreen(),
          ),
        );
      }
    }
  }

  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required UserRole role,
    required bool isSelected,
    required Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? vehicalThemColor.withOpacity(0.1)
              : notifires.getbgcolor,
          border: Border.all(
            color: isSelected
                ? vehicalThemColor
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2.0 : 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Icône
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? vehicalThemColor.withOpacity(0.15)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 28,
                color: isSelected
                    ? vehicalThemColor
                    : notifires.getwhiteblackcolor.withOpacity(0.7),
              ),
            ),
            const SizedBox(width: 16),
            // Titre et sous-titre
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: heading2(context).copyWith(
                      color: notifires.getwhiteblackcolor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: heading2Grey1(context).copyWith(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Indicateur de sélection
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected
                  ? vehicalThemColor
                  : Colors.grey.withOpacity(0.5),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            // Contenu scrollable
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    // Titre
                    Text(
                      "Qui êtes-vous ?".tr,
                      style: heading1(context).copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: notifires.getwhiteblackcolor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Choisissez votre profil pour s'inscrire".tr,
                      style: heading2Grey1(context),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 50),
                    // Cartes de sélection de rôle
                    _buildRoleCard(
                      icon: Icons.business_center,
                      title: "Agence".tr,
                      subtitle: "Je veux louer mes véhicules".tr,
                      role: UserRole.agency,
                      isSelected: selectedRole == UserRole.agency,
                      onTap: () {
                        debugPrint('🔵 [ROLE_SELECTION] Agence sélectionnée');
                        setState(() {
                          selectedRole = UserRole.agency;
                        });
                        debugPrint('🔵 [ROLE_SELECTION] Rôle sélectionné après setState: $selectedRole');
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildRoleCard(
                      icon: Icons.directions_car,
                      title: "Client".tr,
                      subtitle: "Je cherche un véhicule à louer".tr,
                      role: UserRole.client,
                      isSelected: selectedRole == UserRole.client,
                      onTap: () {
                        setState(() {
                          selectedRole = UserRole.client;
                        });
                      },
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "J'ai déjà un compte :".tr,
                    textAlign: TextAlign.center,
                    style: heading2Grey1(context).copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => Get.to(() => const LoginScreen()),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: Color(0xFF2B489A)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Se connecter",
                      style: TextStyle(
                        color: Color(0xFF2B489A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Bouton Suivant fixé en bas
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: whiteColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: CustomsButtons(
                  text: "Suivant".tr,
                  backgroundColor: selectedRole != null
                      ? vehicalThemColor
                      : Colors.grey.withOpacity(0.5),
                  onPressed: selectedRole != null ? _continueToNextScreen : () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
