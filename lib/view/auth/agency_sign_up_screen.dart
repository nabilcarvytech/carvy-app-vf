import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:provider/provider.dart';
import 'package:carvy/controller/agency_controller.dart';
import 'package:carvy/controller/profile_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/form_validation.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/auth/login_screen.dart';
import 'package:carvy/view/splash/user_role_selection_screen.dart';
import 'package:carvy/work_space.dart';

class AgencySignUpScreen extends StatefulWidget {
  const AgencySignUpScreen({super.key});

  @override
  State<AgencySignUpScreen> createState() => _AgencySignUpScreenState();
}

class _AgencySignUpScreenState extends State<AgencySignUpScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Form Keys
  final GlobalKey<FormState> _step1FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _step2FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _step3FormKey = GlobalKey<FormState>();

  // Controllers
  late AgencyController agencyController;
  ProfileController profileController = Get.find();

  @override
  void initState() {
    super.initState();
    // Initialiser ou récupérer le AgencyController
    try {
      agencyController = Get.find<AgencyController>();
    } catch (e) {
      agencyController = Get.put(AgencyController());
    }
    // Initialiser le pays par défaut à Maroc (+212)
    profileController.defaultCountry.value = 'MA';
    profileController.selectedCountry.value = '+212';
  }

  final List<String> _legalForms = [
    'SARL',
    'SA',
    'SNC',
    'EURL',
    'Auto-entrepreneur',
    'Autre'
  ];

  final List<String> _timeSlots = [
    '09:00-12:00',
    '12:00-15:00',
    '15:00-18:00'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    // Les controllers sont gérés par AgencyController
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_step1FormKey.currentState!.validate()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentStep = 1;
        });
      }
    } else if (_currentStep == 1) {
      if (_step2FormKey.currentState!.validate()) {
        if (agencyController.selectedLegalForm.value.isEmpty) {
          Get.snackbar(
            'Erreur',
            'Veuillez sélectionner une forme légale',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
        if (agencyController.agencyLogo.value == null) {
          Get.snackbar(
            'Erreur',
            'Veuillez sélectionner un logo pour l\'agence',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentStep = 2;
        });
      }
    } else if (_currentStep == 2) {
      if (agencyController.selectedDate.value == null ||
          agencyController.selectedTimeSlot.value.isEmpty) {
        Get.snackbar(
          'Erreur',
          'Veuillez sélectionner une date et un créneau horaire',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep = 3;
      });
    } else if (_currentStep == 3) {
      _submitForm();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    }
  }

  void _goBackToRegistrationType() {
    if (Navigator.canPop(context)) {
      Get.back();
    } else {
      Get.off(() => const UserRoleSelectionScreen());
    }
  }

  void _submitForm() {
    // Appeler la méthode submitRegistration du controller
    agencyController.submitRegistration();
  }

  Future<void> _pickLogo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        // Afficher un indicateur de chargement pendant la compression
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );
        await agencyController.setAgencyLogo(image);
        Get.back();
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Erreur',
        'Erreur lors de la sélection de l\'image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  bool _isWeekday(DateTime date) {
    return date.weekday >= 1 && date.weekday <= 5;
  }

  DateTime _getNextWeekday(DateTime startDate) {
    DateTime date = startDate;
    while (!_isWeekday(date)) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_currentStep > 0) {
          _previousStep();
        } else {
          _goBackToRegistrationType();
        }
      },
      child: Scaffold(
        backgroundColor: notifires.getbgcolor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: notifires.getwhiteblackcolor,
            ),
            onPressed: () {
              if (_currentStep > 0) {
                _previousStep();
              } else {
                _goBackToRegistrationType();
              }
            },
          ),
          title: Text(
            'Inscription Agence',
            style: heading1(context),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Indicateur de progression
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: List.generate(
                  _totalSteps,
                  (index) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        right: index < _totalSteps - 1 ? 8 : 0,
                      ),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? acentColor
                            : notifires.getGrey4Whitecolor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Contenu des étapes
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ],
              ),
            ),
            // Boutons de navigation
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: CustomsButtons(
                        text: 'Précédent',
                        backgroundColor: notifires.getBoxColor,
                        textColor: notifires.getwhiteblackcolor,
                        onPressed: _previousStep,
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 10),
                  Expanded(
                    child: Obx(() {
                      // Afficher un CircularProgressIndicator si on est à l'étape 4 et que isLoading est vrai
                      if (_currentStep == 3 && agencyController.isLoading.value) {
                        return Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: acentColor.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                              strokeWidth: 2.5,
                            ),
                          ),
                        );
                      }
                      return CustomsButtons(
                        text: _currentStep == 3 ? 'Envoyer' : 'Continuer',
                        backgroundColor: acentColor,
                        onPressed: agencyController.isLoading.value ? () {} : () => _nextStep(),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Étape 1 : Identité du Gérant
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _step1FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Étape 1 : Identité du Gérant',
              style: heading1(context),
            ),
            const SizedBox(height: 10),
            Text(
              'Veuillez remplir vos informations personnelles',
              style: regular2(context).copyWith(
                color: notifires.getGrey3Whitecolor,
              ),
            ),
            const SizedBox(height: 30),
            TextFieldRefs(
              inputAlignment: TextAlign.start,
              txt: 'Prénom *',
              icons: Icon(
                Icons.person_2_outlined,
                color: acentColor,
              ),
              textEditingControllerCommon: agencyController.firstNameController,
              inputType: TextInputType.name,
              validator: (value) {
                if (!isValidName(value!)) {
                  return 'Le prénom est invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFieldRefs(
              inputAlignment: TextAlign.start,
              txt: 'Nom de famille *',
              icons: Icon(
                Icons.person_2_outlined,
                color: acentColor,
              ),
              textEditingControllerCommon: agencyController.lastNameController,
              inputType: TextInputType.name,
              validator: (value) {
                if (!isValidName(value!)) {
                  return 'Le nom est invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFieldRefs(
              inputAlignment: TextAlign.start,
              txt: 'Adresse email *',
              icons: Icon(
                Icons.mail,
                color: acentColor,
              ),
              textEditingControllerCommon: agencyController.emailController,
              inputType: TextInputType.emailAddress,
              validator: (value) {
                return validateEmail(value!);
              },
            ),
            const SizedBox(height: 20),
            IntelPhoneFieldRefs(
              defultcountry: 'MA',
              textEditingControllerCommons: agencyController.phoneController,
              oncountryChanged: (number) {
                agencyController.phoneController.clear();
                profileController.selectedCountry.value = number.dialCode;
                profileController.defaultCountry.value = number.code;
              },
              onChanged: (value) {
                int expectedLength = phoneLengths[
                        profileController.defaultCountry.value] ??
                    9;
                if (value!.number.length > expectedLength) {
                  agencyController.phoneController.text =
                      value.number.substring(0, expectedLength);
                  agencyController.phoneController.selection = TextSelection.fromPosition(
                    TextPosition(offset: agencyController.phoneController.text.length),
                  );
                }
                return null;
              },
              validator: (phoneNumber) {
                if (phoneNumber == null || phoneNumber.number.isEmpty) {
                  return 'Veuillez entrer votre numéro de téléphone';
                }
                int expectedLength =
                    phoneLengths[phoneNumber.countryISOCode] ?? 9;
                if (phoneNumber.number.length != expectedLength) {
                  return 'Le numéro doit contenir $expectedLength chiffres';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomTextFields(
              txt: 'Mot de passe *',
              textEditingControllerCommon: agencyController.passwordController,
              validator: (value) {
                return validatesPassword(value!);
              },
            ),
            const SizedBox(height: 30),
            // Lien vers la connexion
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Vous avez déjà un compte ? ',
                    style: regular2(context).copyWith(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Get.to(() => const LoginScreen());
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      child: Text(
                        'Se connecter',
                        style: regular2(context).copyWith(
                          fontSize: 16,
                          color: const Color(0xFF2B489A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Étape 2 : Informations Agence
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _step2FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Étape 2 : Informations Agence',
              style: heading1(context),
            ),
            const SizedBox(height: 10),
            Text(
              'Renseignez les informations de votre agence',
              style: regular2(context).copyWith(
                color: notifires.getGrey3Whitecolor,
              ),
            ),
            const SizedBox(height: 30),
            TextFieldRefs(
              inputAlignment: TextAlign.start,
              txt: 'Nom de l\'entreprise *',
              icons: Icon(
                Icons.business,
                color: acentColor,
              ),
              textEditingControllerCommon: agencyController.companyNameController,
              inputType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le nom de l\'entreprise est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Dropdown pour la forme légale
            Container(
              decoration: BoxDecoration(
                color: notifires.getBoxColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: notifires.getBoxColor),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Obx(() => DropdownButtonFormField<String>(
                value: agencyController.selectedLegalForm.value.isEmpty
                    ? null
                    : agencyController.selectedLegalForm.value,
                decoration: InputDecoration(
                  labelText: 'Forme légale *',
                  labelStyle: regular3(context),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.description,
                    color: acentColor,
                  ),
                ),
                style: regular2(context),
                dropdownColor: notifires.getBoxColor,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: notifires.getGrey3Whitecolor,
                ),
                items: _legalForms.map((String form) {
                  return DropdownMenuItem<String>(
                    value: form,
                    child: Text(form),
                  );
                }).toList(),
                onChanged: (String? value) {
                  agencyController.setSelectedLegalForm(value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une forme légale';
                  }
                  return null;
                },
              )),
            ),
            const SizedBox(height: 20),
            TextFieldRefs(
              inputAlignment: TextAlign.start,
              txt: 'Adresse du siège social *',
              icons: Icon(
                Icons.location_on,
                color: acentColor,
              ),
              textEditingControllerCommon: agencyController.addressController,
              inputType: TextInputType.streetAddress,
              maxlines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'L\'adresse est requise';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Sélection du logo
            Text(
              'Logo de l\'agence *',
              style: heading3(context),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickLogo,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: notifires.getBoxColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: notifires.getGrey4Whitecolor,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Obx(() => agencyController.agencyLogo.value != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(agencyController.agencyLogo.value!.path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 50,
                            color: notifires.getGrey3Whitecolor,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Appuyez pour sélectionner un logo',
                            style: regular3(context).copyWith(
                              color: notifires.getGrey3Whitecolor,
                            ),
                          ),
                        ],
                      )),
              ),
            ),
            Obx(() => agencyController.agencyLogo.value == null
                ? Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      'Le logo est requis',
                      style: regular(context).copyWith(color: pc1),
                    ),
                  )
                : const SizedBox.shrink()),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  'Le logo est requis',
                  style: regular(context).copyWith(color: pc1),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Étape 3 : Appel de Validation
  Widget _buildStep3() {
    final DateTime today = DateTime.now();
    final DateTime nextWeekday = _getNextWeekday(today);
    final List<DateTime> availableDates = [];
    
    // Générer les 4 prochains jours ouvrables
    DateTime currentDate = nextWeekday;
    for (int i = 0; i < 4; i++) {
      while (!_isWeekday(currentDate)) {
        currentDate = currentDate.add(const Duration(days: 1));
      }
      availableDates.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Étape 3 : Appel de Validation',
            style: heading1(context),
          ),
          const SizedBox(height: 10),
          Text(
            'Sélectionnez une date et un créneau horaire pour votre appel de validation',
            style: regular2(context).copyWith(
              color: notifires.getGrey3Whitecolor,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Sélectionner une date *',
            style: heading3(context),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: availableDates.map((date) {
              return Obx(() {
                final bool isSelected = agencyController.selectedDate.value != null &&
                    agencyController.selectedDate.value!.year == date.year &&
                    agencyController.selectedDate.value!.month == date.month &&
                    agencyController.selectedDate.value!.day == date.day;
                return GestureDetector(
                  onTap: () {
                    agencyController.setSelectedDate(date);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? acentColor
                          : notifires.getBoxColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? acentColor
                            : notifires.getGrey4Whitecolor,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _getDayName(date.weekday),
                          style: regular3(context).copyWith(
                            color: isSelected
                                ? whiteColor
                                : notifires.getGrey3Whitecolor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${date.day}/${date.month}',
                          style: heading3(context).copyWith(
                            color: isSelected
                                ? whiteColor
                                : notifires.getwhiteblackcolor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            }).toList(),
          ),
          const SizedBox(height: 30),
          Text(
            'Sélectionner un créneau horaire *',
            style: heading3(context),
          ),
          const SizedBox(height: 15),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: _timeSlots.map((slot) {
              return SlotCard(
                slot: slot,
                selectedSlot: agencyController.selectedTimeSlot,
                onTap: () {
                  agencyController.setSelectedTimeSlot(slot);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Étape 4 : Révision & Envoi
  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Étape 4 : Révision & Envoi',
            style: heading1(context),
          ),
          const SizedBox(height: 10),
          Text(
            'Vérifiez vos informations avant de soumettre',
            style: regular2(context).copyWith(
              color: notifires.getGrey3Whitecolor,
            ),
          ),
          const SizedBox(height: 30),
            _buildReviewSection(
            'Identité du Gérant',
            [
              _buildReviewItem('Prénom', agencyController.firstNameController.text),
              _buildReviewItem('Nom', agencyController.lastNameController.text),
              _buildReviewItem('Email', agencyController.emailController.text),
              _buildReviewItem(
                'Téléphone',
                '+${profileController.selectedCountry.value} ${agencyController.phoneController.text}',
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildReviewSection(
            'Informations Agence',
            [
              _buildReviewItem('Nom de l\'entreprise', agencyController.companyNameController.text),
              _buildReviewItem('Forme légale', agencyController.selectedLegalForm.value),
              _buildReviewItem('Adresse', agencyController.addressController.text),
              Obx(() => agencyController.agencyLogo.value != null
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Logo :',
                            style: regular3(context).copyWith(
                              color: notifires.getGrey3Whitecolor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(agencyController.agencyLogo.value!.path),
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
          const SizedBox(height: 20),
          _buildReviewSection(
            'Appel de Validation',
            [
              _buildReviewItem(
                'Date',
                agencyController.selectedDate.value != null
                    ? '${_getDayName(agencyController.selectedDate.value!.weekday)} ${agencyController.selectedDate.value!.day}/${agencyController.selectedDate.value!.month}/${agencyController.selectedDate.value!.year}'
                    : '',
              ),
              _buildReviewItem('Créneau horaire', agencyController.selectedTimeSlot.value),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildReviewSection(String title, List<Widget> items) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: notifires.getBoxColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: heading2(context),
          ),
          const SizedBox(height: 15),
          ...items,
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label :',
              style: regular3(context).copyWith(
                color: notifires.getGrey3Whitecolor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: regular2(context),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[weekday - 1];
  }
}

/// Widget pour afficher un créneau horaire avec style amélioré
class SlotCard extends StatelessWidget {
  final String slot;
  final RxString selectedSlot;
  final VoidCallback onTap;

  const SlotCard({
    super.key,
    required this.slot,
    required this.selectedSlot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: false);
    return Obx(() {
      final bool selected = selectedSlot.value == slot;
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: selected ? acentColor : notifires.getBoxColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? acentColor
                  : notifires.getGrey4Whitecolor.withOpacity(0.3),
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: acentColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              slot,
              style: heading3(context).copyWith(
                color: selected
                    ? whiteColor
                    : notifires.getwhiteblackcolor,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    });
  }
}
