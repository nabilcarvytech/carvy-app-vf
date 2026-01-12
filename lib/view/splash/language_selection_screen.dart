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
import 'user_role_selection_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

// Modèle de données pour les langues
class LanguageItem {
  final String name;
  final String flag;
  final Locale locale;
  final int originalIndex;

  LanguageItem({
    required this.name,
    required this.flag,
    required this.locale,
    required this.originalIndex,
  });
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  Locale? selectedLocale;
  late List<LanguageItem> languages;

  @override
  void initState() {
    super.initState();

    debugPrint('=== Language Selection Screen Init ===');
    
    // Créer la liste des langues avec drapeaux et noms endonymes
    languages = [
      LanguageItem(
        name: 'Français',
        flag: '🇫🇷',
        locale: const Locale('fr', 'FR'),
        originalIndex: locale.indexWhere((l) {
          Locale loc = l['locale'] as Locale;
          return loc.languageCode == 'fr' && loc.countryCode == 'FR';
        }),
      ),
      LanguageItem(
        name: 'English',
        flag: '🇺🇸',
        locale: const Locale('en', 'US'),
        originalIndex: locale.indexWhere((l) {
          Locale loc = l['locale'] as Locale;
          return loc.languageCode == 'en' && loc.countryCode == 'US';
        }),
      ),
      LanguageItem(
        name: 'العربية',
        flag: '🇲🇦',
        locale: const Locale('ar', 'AR'),
        originalIndex: locale.indexWhere((l) {
          Locale loc = l['locale'] as Locale;
          return loc.languageCode == 'ar' && loc.countryCode == 'AR';
        }),
      ),
      LanguageItem(
        name: 'Español',
        flag: '🇪🇸',
        locale: const Locale('es', 'ES'),
        originalIndex: locale.indexWhere((l) {
          Locale loc = l['locale'] as Locale;
          return loc.languageCode == 'es' && loc.countryCode == 'ES';
        }),
      ),
    ];

    // Filtrer les langues non trouvées (originalIndex == -1)
    languages = languages.where((lang) => lang.originalIndex != -1).toList();

    debugPrint('Languages count: ${languages.length}');
    for (var lang in languages) {
      debugPrint('  - ${lang.name} ${lang.flag} (index: ${lang.originalIndex})');
    }

    // Vérifier si une langue a déjà été sélectionnée
    var savedLanguage = getData.read("lanValue");
    debugPrint('Saved language index: $savedLanguage');
    
    if (savedLanguage != null && savedLanguage is int) {
      // Trouver la langue correspondante dans notre liste
      int foundIndex = languages.indexWhere((lang) => lang.originalIndex == savedLanguage);
      if (foundIndex != -1) {
        selectedLocale = languages[foundIndex].locale;
        debugPrint('Found saved language: ${languages[foundIndex].name}');
      } else {
        // Par défaut, sélectionner la première langue
        if (languages.isNotEmpty) {
          selectedLocale = languages[0].locale;
        }
      }
    } else {
      // Par défaut, sélectionner la première langue
      if (languages.isNotEmpty) {
        selectedLocale = languages[0].locale;
      }
    }
    
    debugPrint('Initial selectedLocale: $selectedLocale');
    debugPrint('======================================');
  }

  void _continueToOnboarding() async {
    if (selectedLocale == null) {
      debugPrint('⚠️ No language selected');
      return;
    }

    debugPrint('=== Continue to Onboarding ===');
    debugPrint('Selected locale: ${selectedLocale!.languageCode}_${selectedLocale!.countryCode}');

    // Trouver l'index réel dans la liste locale originale
    LanguageItem? selectedLanguage = languages.firstWhere(
      (lang) => lang.locale.languageCode == selectedLocale!.languageCode &&
          lang.locale.countryCode == selectedLocale!.countryCode,
      orElse: () => languages.first,
    );
    
    int realIndex = selectedLanguage.originalIndex;
    debugPrint('Mapped real index: $realIndex');
    debugPrint('Locale name: ${selectedLanguage.name}');

    // Sauvegarder AVANT updateLanguage
    debugPrint('Saving lanValue: $realIndex');
    save("lanValue", realIndex);

    // Vérifier la sauvegarde immédiatement
    var savedValue = getData.read("lanValue");
    debugPrint('Verified saved lanValue: $savedValue (should be $realIndex)');

    // Mettre à jour la langue globale
    globallanguage = selectedLocale!;
    save("lCode", globallanguage.toString());
    debugPrint('Saved lCode: ${getData.read("lCode")}');
    debugPrint('globallanguage set to: $globallanguage');

    // Mettre à jour la locale dans GetX
    debugPrint('Updating GetX locale...');
    
    // Mettre à jour globallanguage AVANT Get.updateLocale
    globallanguage = selectedLocale!;
    
    // Mettre à jour le ValueNotifier pour forcer la reconstruction de l'application
    localeNotifier.value = selectedLocale!;
    
    Get.updateLocale(selectedLocale!);
    
    // Forcer la mise à jour de toute l'application
    Get.forceAppUpdate();
    
    debugPrint('GetX locale updated to: ${Get.locale}');
    debugPrint('globallanguage updated to: $globallanguage');

    // Vérifier que tout est correct
    debugPrint('Final check:');
    debugPrint('  - lanValue in storage: ${getData.read("lanValue")}');
    debugPrint('  - lCode in storage: ${getData.read("lCode")}');
    debugPrint('  - globallanguage: $globallanguage');
    debugPrint('  - Get.locale: ${Get.locale}');
    debugPrint('==============================');

    // Attendre un peu pour que la mise à jour soit prise en compte
    await Future.delayed(const Duration(milliseconds: 100));

    // Rediriger vers la sélection de rôle - Get.offNamed va reconstruire avec la nouvelle locale
    if (webPlateForm) {
      Get.offNamed(WebRoutes.userRoleSelectionScreen);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const UserRoleSelectionScreen(),
        ),
      );
    }
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
                      "Select Your Language",
                      style: heading1(context).copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: notifires.getwhiteblackcolor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Choose your preferred language to continue",
                      style: heading2Grey1(context),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 50),
                    // Liste des langues avec ListTile
                    Expanded(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: languages.length,
                        physics: const BouncingScrollPhysics(),
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final language = languages[index];
                          final isSelected = selectedLocale?.languageCode == language.locale.languageCode &&
                              selectedLocale?.countryCode == language.locale.countryCode;
                          
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedLocale = language.locale;
                              });
                            },
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
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: Text(
                                  language.flag,
                                  style: const TextStyle(
                                    fontSize: 24,
                                  ),
                                ),
                                title: Text(
                                  language.name,
                                  style: heading2(context).copyWith(
                                    color: notifires.getwhiteblackcolor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: Radio<Locale>(
                                  value: language.locale,
                                  groupValue: selectedLocale,
                                  activeColor: vehicalThemColor,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedLocale = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            // Bouton Continue fixé en bas
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
                  text: "Continue",
                  backgroundColor: vehicalThemColor,
                  onPressed: _continueToOnboarding,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
