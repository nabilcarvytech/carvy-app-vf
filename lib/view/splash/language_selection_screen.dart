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

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  int _value = 0;

  // Ordre personnalisé : français, anglais, arabe, espagnol
  // Liste des indices dans l'ordre d'affichage souhaité
  late List<int> orderedIndices;

  @override
  void initState() {
    super.initState();

    debugPrint('=== Language Selection Screen Init ===');
    debugPrint('Locale list length: ${locale.length}');
    for (int i = 0; i < locale.length; i++) {
      Locale loc = locale[i]['locale'] as Locale;
      debugPrint(
          '  [$i] ${locale[i]['name']} - ${loc.languageCode}_${loc.countryCode}');
    }

    // Créer l'ordre personnalisé : français, anglais, arabe, espagnol
    // Trouver les indices dans la liste originale
    int frenchIndex = locale.indexWhere((l) {
      Locale loc = l['locale'] as Locale;
      return loc.languageCode == 'fr' && loc.countryCode == 'FR';
    });
    int englishIndex = locale.indexWhere((l) {
      Locale loc = l['locale'] as Locale;
      return loc.languageCode == 'en' && loc.countryCode == 'US';
    });
    int arabicIndex = locale.indexWhere((l) {
      Locale loc = l['locale'] as Locale;
      return loc.languageCode == 'ar' && loc.countryCode == 'AR';
    });
    int spanishIndex = locale.indexWhere((l) {
      Locale loc = l['locale'] as Locale;
      return loc.languageCode == 'es' && loc.countryCode == 'ES';
    });

    debugPrint(
        'Found indices: French=$frenchIndex, English=$englishIndex, Arabic=$arabicIndex, Spanish=$spanishIndex');

    // Créer la liste ordonnée des indices
    orderedIndices = [];
    if (frenchIndex != -1) orderedIndices.add(frenchIndex);
    if (englishIndex != -1) orderedIndices.add(englishIndex);
    if (arabicIndex != -1) orderedIndices.add(arabicIndex);
    if (spanishIndex != -1) orderedIndices.add(spanishIndex);

    debugPrint('Ordered indices: $orderedIndices');

    // Vérifier si une langue a déjà été sélectionnée
    var savedLanguage = getData.read("lanValue");
    debugPrint('Saved language index: $savedLanguage');
    if (savedLanguage != null && savedLanguage is int) {
      // Trouver l'index dans orderedIndices
      int foundIndex = orderedIndices.indexWhere((idx) => idx == savedLanguage);
      if (foundIndex != -1) {
        _value = foundIndex;
        debugPrint('Found saved language at display index: $_value');
      } else {
        debugPrint(
            'WARNING: Saved language index $savedLanguage not found in orderedIndices!');
      }
    }
    debugPrint('Initial _value: $_value');
    debugPrint('======================================');
  }

  void _continueToOnboarding() async {
    debugPrint('=== Continue to Onboarding ===');
    debugPrint('Selected display index (_value): $_value');

    // Obtenir l'index réel dans la liste locale originale
    int realIndex = orderedIndices[_value];
    debugPrint('Mapped real index: $realIndex');
    debugPrint('Locale name: ${locale[realIndex]['name']}');

    Locale selectedLocale = locale[realIndex]['locale'] as Locale;
    debugPrint(
        'Selected locale: ${selectedLocale.languageCode}_${selectedLocale.countryCode}');

    // Sauvegarder AVANT updateLanguage
    debugPrint('Saving lanValue: $realIndex');
    save("lanValue", realIndex);

    // Vérifier la sauvegarde immédiatement
    var savedValue = getData.read("lanValue");
    debugPrint('Verified saved lanValue: $savedValue (should be $realIndex)');

    // Mettre à jour la langue globale
    globallanguage = selectedLocale;
    save("lCode", globallanguage.toString());
    debugPrint('Saved lCode: ${getData.read("lCode")}');
    debugPrint('globallanguage set to: $globallanguage');

    // Mettre à jour la locale dans GetX
    debugPrint('Updating GetX locale...');
    
    // Mettre à jour globallanguage AVANT Get.updateLocale
    globallanguage = selectedLocale;
    
    // Mettre à jour le ValueNotifier pour forcer la reconstruction de l'application
    localeNotifier.value = selectedLocale;
    
    Get.updateLocale(selectedLocale);
    
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

    // Rediriger vers l'onboarding - Get.offNamed va reconstruire avec la nouvelle locale
    if (webPlateForm) {
      Get.offNamed(WebRoutes.vehicleOnboardingScreen);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const VehicleOnBoardingScreen(),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
              // Liste des langues - seule cette partie est scrollable
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: orderedIndices.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    int realIndex = orderedIndices[index];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _value = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: _value == index
                              ? vehicalThemColor.withOpacity(0.1)
                              : notifires.getbgcolor,
                          border: Border.all(
                            color: _value == index
                                ? vehicalThemColor
                                : notifires.getGrey3Whitecolor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          child: Row(
                            children: [
                              Text(
                                locale[realIndex]['name'],
                                style: heading2(context).copyWith(
                                  color: notifires.getwhiteblackcolor,
                                  fontWeight: _value == index
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              const Spacer(),
                              Radio(
                                value: index,
                                groupValue: _value,
                                activeColor: vehicalThemColor,
                                onChanged: (value) {
                                  setState(() {
                                    _value = index;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Spacer(),
              // Bouton continuer
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: CustomsButtons(
                  text: "Continue",
                  backgroundColor: vehicalThemColor,
                  onPressed: _continueToOnboarding,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
