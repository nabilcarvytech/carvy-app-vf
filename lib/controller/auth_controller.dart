import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:location/location.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/api/data_store.dart';
import 'package:carvy/controller/global_scope_controller.dart';
import 'package:carvy/controller/push_notifications.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/model/change_phone_model.dart';
import 'package:carvy/model/check_mobile_model.dart';
import 'package:carvy/model/forgot_pass_model.dart';
import 'package:carvy/model/login_model.dart';
import 'package:carvy/model/reset_pass_model.dart';
import 'package:carvy/view/auth/google_update_screen.dart';
import 'package:carvy/view/auth/login_screen.dart';
import 'package:carvy/view/auth/otp_screen.dart';
import 'package:carvy/view/auth/success_change_password.dart';
import 'package:carvy/view/myaccount/my_profile_screen.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import 'package:carvy/view/host/bottom_bar_host.dart';
import 'package:carvy/view/host/switch_splash_screen.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/work_space.dart';
import 'package:carvy/services/auth_service.dart';
import 'package:carvy/service/onesignal_service.dart';
import '../helper/http_service.dart';
import '../view/auth/reset_password_screen.dart';

class AuthController extends GetxController implements GetxService {
  // Variable pour gérer le mode host (vendor) ou user
  // Note: Cette variable est synchronisée avec la variable globale isHostMode
  // définie dans custom_active_module_id_widget.dart et accessible via work_space.dart
  var isHostMode = false.obs;
  
  // Variable pour stocker le rôle de l'utilisateur (vendor, user, host, etc.)
  RxString userRole = ''.obs;
  
  late TextEditingController textEditingControllerEmail;
  late TextEditingController textEditingControllerPass;
  late TextEditingController textEditingSignUpControllerFirstName;
  late TextEditingController textEditingSignUpControllerEmail;
  late TextEditingController textEditingSignUpControllerPassword;
  late TextEditingController textEditingSingUpControllerPhoneNumber;
  late TextEditingController textEditingSingUpControllerlastName;
  late TextEditingController textEditingSingUpControllerDOB;
  late TextEditingController textEditingForgetPasswordControllerEmail;
  late TextEditingController textEditingOtpController;
  late TextEditingController textEditingControllerNewPassword;
  late TextEditingController textEditingResetControllerNewPassword;
  late TextEditingController textEditingResetControllerConfirmPassword;
  late TextEditingController textEditingControllerConfirmPassword;
  late TextEditingController textEditingControllerOldPassword;
  bool shouldLogout = false;
  
  // Initialiser isHostMode et userRole depuis le stockage au démarrage
  @override
  void onInit() {
    super.onInit();
    isHostMode.value = GetStorage().read('isHostMode') ?? false;
    
    // Récupérer le LoginModel depuis le stockage si l'utilisateur est déjà connecté
    try {
      // Essayer d'abord de lire depuis 'user_data' (nouvelle clé)
      var data = GetStorage().read('user_data');
      LoginModel? storedModel;
      
      if (data != null) {
        print('✅ [AUTH_CONTROLLER] Données trouvées dans user_data');
        try {
          // Si data est déjà un Map, l'utiliser directement, sinon le décoder
          Map<String, dynamic> userDataJson;
          if (data is Map) {
            userDataJson = Map<String, dynamic>.from(data);
          } else if (data is String) {
            userDataJson = jsonDecode(data);
          } else {
            throw Exception('Format de données inattendu: ${data.runtimeType}');
          }
          
          loginModel = LoginModel.fromJson(userDataJson);
          storedModel = loginModel;
          print('✅ [AUTH_CONTROLLER] LoginModel créé depuis user_data');
        } catch (e) {
          print('⚠️ [AUTH_CONTROLLER] Erreur lors du parsing de user_data: $e');
        }
      }
      
      // Fallback : essayer de lire depuis 'UserData' (ancienne clé) si user_data n'existe pas
      if (storedModel == null) {
        String? userDataString = GetStorage().read('UserData');
        if (userDataString != null && userDataString.isNotEmpty) {
          print('✅ [AUTH_CONTROLLER] Données trouvées dans UserData (fallback)');
          var userDataJson = jsonDecode(userDataString);
          storedModel = LoginModel.fromJson(userDataJson);
          loginModel = storedModel;
        }
      }
      
      // Mettre à jour le rôle explicitement depuis le modèle stocké
      if (storedModel != null) {
        userRole.value = storedModel.data?.role ?? '';
        debugPrint('✅ [AUTH_CONTROLLER] LoginModel loaded from storage');
        debugPrint('🔍 DEBUG ROLE: Current user role is: ${userRole.value}');
        
        // Forcer le rafraîchissement du rôle après le chargement du stockage
        refreshUserRole();
      } else {
        userRole.value = '';
        debugPrint('⚠️ [AUTH_CONTROLLER] Aucun modèle trouvé dans le stockage');
        debugPrint('🔍 DEBUG ROLE: Current user role is: ${userRole.value}');
      }
    } catch (e, stackTrace) {
      userRole.value = '';
      debugPrint('⚠️ [AUTH_CONTROLLER] Error loading user role from storage: $e');
      debugPrint('🔍 DEBUG ROLE: Current user role is: ${userRole.value}');
      debugPrint('🔍 DEBUG ROLE: StackTrace: $stackTrace');
    }
  }
  
  // Méthode pour afficher une alerte si l'utilisateur n'est pas connecté
  void loginAlert(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: notifires.getbgcolor,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'You are not Login yet'.tr,
                  textAlign: TextAlign.center,
                  style: heading3(context).copyWith(
                    color: notifires.getwhiteblackcolor,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Please login to continue'.tr,
                  textAlign: TextAlign.center,
                  style: regular2(context).copyWith(
                    color: notifires.getGrey3Whitecolor,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Cancel".tr,
                      style: regular2(context).copyWith(
                        color: notifires.getGrey3Whitecolor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      handlelogin = true;
                      if (webPlateForm) {
                        Get.toNamed(WebRoutes.loginScreen);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      }
                    },
                    child: Text(
                      "Login".tr,
                      style: regular2(context).copyWith(
                        color: getColorBasedOnActiveModuleid(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  AuthController() {
    textEditingControllerEmail = TextEditingController();
    textEditingControllerPass = TextEditingController();
    textEditingSignUpControllerEmail = TextEditingController();
    textEditingSignUpControllerFirstName = TextEditingController();
    textEditingSignUpControllerPassword = TextEditingController();
    textEditingSingUpControllerPhoneNumber = TextEditingController();
    textEditingSingUpControllerDOB = TextEditingController();
    textEditingSingUpControllerlastName = TextEditingController();
    textEditingForgetPasswordControllerEmail = TextEditingController();
    textEditingOtpController = TextEditingController();
    textEditingControllerNewPassword = TextEditingController();
    textEditingControllerConfirmPassword = TextEditingController();
    textEditingControllerOldPassword = TextEditingController();
    textEditingResetControllerNewPassword = TextEditingController();
    textEditingResetControllerConfirmPassword = TextEditingController();
  }

  RxBool isValidEmail = false.obs;
  RxBool isResendLoading = false.obs;
  RxString newpassword = ''.obs;

  // 🛡️ [GOOGLE_AUTH] Verrou de concurrence anti-double-clic / double-exécution.
  // Tant que `true`, tout nouvel appel à `googleLogin` ou `prefillSignUpFormFromGoogle`
  // est ignoré (évite la double pop-up et l'erreur fantôme [16] Canceled).
  final RxBool isGoogleAuthLoading = false.obs;

  // --- Inscription wizard (multi-étapes) ---
  final RxBool registerWizardTermsAccepted = false.obs;
  final RxBool registerWizardPhoneCodeSent = false.obs;
  final RxInt registerWizardResendSeconds = 0.obs;
  final RxString phoneError = ''.obs;
  final RxString registerWizardEmailError = ''.obs;
  /// `true` = Agence (vendor), `false` = Client.
  /// Wizard « Créer un compte » : inscription client uniquement (pas d’étape Agence/Client dans le PageView).
  /// Les agences utilisent un autre flux ; reste à `false` pour `role: user` et navigation `HomeMain`.
  final RxBool registerWizardIsAgency = false.obs;
  final RxBool registerWizardSubmitting = false.obs;
  /// `true` tant que l’utilisateur est sur [RegisterWizardScreen] (OTP → [NavPageView]).
  final RxBool registerWizardEmbarked = false.obs;
  Timer? _registerWizardResendTimer;

  /// Date de naissance choisie à l'inscription (client).
  DateTime? signUpSelectedBirthDate;

  /// Valeur `birthdate` envoyée à l'API (yyyy-MM-dd).
  String get signUpBirthdateForApi {
    if (signUpSelectedBirthDate != null) {
      return DateFormat('yyyy-MM-dd').format(signUpSelectedBirthDate!);
    }
    return textEditingSingUpControllerDOB.text.trim();
  }

  Future<void> pickSignUpBirthDate(BuildContext context) async {
    final now = DateTime.now();
    final DateTime maxDate = DateTime(now.year - 18, now.month, now.day);
    DateTime initialDate =
        signUpSelectedBirthDate ?? DateTime(2000, now.month, now.day);
    if (initialDate.isAfter(maxDate)) {
      initialDate = maxDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: maxDate,
      initialDatePickerMode: DatePickerMode.year,
      locale: Get.locale,
    );

    if (picked != null) {
      signUpSelectedBirthDate = picked;
      textEditingSingUpControllerDOB.text =
          DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  void clearSignUpBirthDate() {
    signUpSelectedBirthDate = null;
    textEditingSingUpControllerDOB.clear();
  }

  void toggleRegisterWizardTerms() {
    registerWizardTermsAccepted.toggle();
  }

  void resetRegisterWizardFlow() {
    registerWizardTermsAccepted.value = false;
    registerWizardPhoneCodeSent.value = false;
    registerWizardResendSeconds.value = 0;
    phoneError.value = '';
    registerWizardEmailError.value = '';
    registerWizardIsAgency.value = false;
    registerWizardSubmitting.value = false;
    clearSignUpBirthDate();
    textEditingOtpController.clear();
    _registerWizardResendTimer?.cancel();
    _registerWizardResendTimer = null;
  }

  void startRegisterWizardResendCountdown([int seconds = 60]) {
    _registerWizardResendTimer?.cancel();
    registerWizardResendSeconds.value = seconds;
    _registerWizardResendTimer =
        Timer.periodic(const Duration(seconds: 1), (t) {
      if (registerWizardResendSeconds.value <= 1) {
        t.cancel();
        registerWizardResendSeconds.value = 0;
      } else {
        registerWizardResendSeconds.value--;
      }
    });
  }

  bool _isDuplicateEmailMessage(String message) {
    final m = message.toLowerCase();
    return m.contains('duplicate entry') ||
        m.contains('email already') ||
        m.contains('already used') ||
        m.contains('already in use');
  }

  String _extractApiError(dynamic response) {
    if (response is Map) {
      final err = response['error']?.toString();
      final msg = response['message']?.toString();
      if (err != null && err.trim().isNotEmpty) return err;
      if (msg != null && msg.trim().isNotEmpty) return msg;
    }
    return response?.toString() ?? '';
  }

  /// Réponse 409 inscription : JSON avec `field` (`email` | `phone`) et `message` (ou `error`).
  /// Retourne `true` si un 409 a été traité (messages champ ou toast de secours).
  bool _handleRegisterUserHttp409(
    dynamic responseData, {
    VoidCallback? onDuplicateEmail,
  }) {
    if (responseData is! Map) return false;
    final map = Map<String, dynamic>.from(responseData as Map);
    final statusRaw = map['status'];
    final statusCode = statusRaw is num
        ? statusRaw.toInt()
        : int.tryParse(statusRaw?.toString() ?? '');
    if (statusCode != 409) return false;

    registerWizardPhoneCodeSent.value = false;

    final field = map['field']?.toString();
    final message = (map['message'] ?? map['error'] ?? '').toString().trim();
    final msg =
        message.isNotEmpty ? message : 'Something went wrong'.tr;

    if (field == 'email') {
      registerWizardEmailError.value = msg;
      onDuplicateEmail?.call();
    } else if (field == 'phone') {
      phoneError.value = msg;
    } else {
      final err = _extractApiError(map);
      if (_isDuplicateEmailMessage(err)) {
        registerWizardEmailError.value = 'Cet email est déjà utilisé';
        onDuplicateEmail?.call();
      } else if (err.isNotEmpty) {
        showErrorToastMessage(err);
      } else {
        showErrorToastMessage(msg);
      }
    }
    return true;
  }

  Future<bool> registerWizardCheckEmailAvailability(BuildContext context) async {
    registerWizardEmailError.value = '';
    final email = textEditingSignUpControllerEmail.text.trim();
    if (email.isEmpty) return false;
    try {
      showLoading();
      final response = await httpPost(Config.checkEmail, {'email': email});
      closeLoading();

      final String apiError = _extractApiError(response);
      final bool duplicateByMessage = _isDuplicateEmailMessage(apiError);
      final bool duplicateByFlag = response is Map &&
          (response['exists'] == true ||
              (response['data'] is Map && response['data']['exists'] == true));

      if (duplicateByMessage || duplicateByFlag) {
        registerWizardEmailError.value = 'Cet email est déjà utilisé';
        return false;
      }

      if (response is Map && response['status'] != null) {
        final status = int.tryParse(response['status'].toString()) ?? 0;
        if (status >= 400) {
          registerWizardEmailError.value =
              apiError.isNotEmpty ? apiError : 'Something went wrong'.tr;
          return false;
        }
      }
      return true;
    } catch (e) {
      closeLoading();
      final msg = e.toString();
      if (_isDuplicateEmailMessage(msg)) {
        registerWizardEmailError.value = 'Cet email est déjà utilisé';
        return false;
      }
      showErrorToastMessage(msg);
      return false;
    }
  }

  Future<void> registerWizardSendPhoneCode(
    BuildContext context,
    String dialCode,
    String isoCode,
    {VoidCallback? onDuplicateEmail}
  ) async {
    phoneError.value = '';
    registerWizardEmailError.value = '';
    if (textEditingSingUpControllerPhoneNumber.text.isEmpty) {
      showErrorToastMessage('Fill valid mobile number'.tr);
      return;
    }
    final dial = dialCode.startsWith('+') ? dialCode : '+$dialCode';
    try {
      buildShowDialog(context);
      final data = await httpPost(Config.registerUser, {
        'phone': textEditingSingUpControllerPhoneNumber.text,
        'email': textEditingSignUpControllerEmail.text,
        'first_name': textEditingSignUpControllerFirstName.text,
        'password': textEditingSignUpControllerPassword.text,
        'phone_country': dial,
        'default_country': isoCode,
        'last_name': textEditingSingUpControllerlastName.text,
        'birthdate': signUpBirthdateForApi,
        'role': registerWizardIsAgency.value ? 'vendor' : 'user',
      });
      Get.back();
      if (data == null) {
        showErrorToastMessage('Something went wrong'.tr);
        return;
      }
      if (_handleRegisterUserHttp409(data, onDuplicateEmail: onDuplicateEmail)) {
        return;
      }
      final loginModel = LoginModel.fromJson(data);
      if (loginModel.status != 200) {
        final err = (loginModel.error ?? '').toString();
        if (_isDuplicateEmailMessage(err)) {
          registerWizardEmailError.value = 'Cet email est déjà utilisé';
          registerWizardPhoneCodeSent.value = false;
          onDuplicateEmail?.call();
          return;
        }
        phoneError.value = loginModel.error ?? '';
        showErrorToastMessage(loginModel.error ?? 'Error'.tr);
        return;
      }

      GetStorage().write('Remember', true);
      GetStorage().write('Firstuser', true);
      getFCMToken();
      token = loginModel.data!.token!;
      GetStorage().remove('bearerToken');
      bearerToken = '';
      userId = loginModel.data!.id!;
      try {
        await OneSignal.login(userId.toString());
        await OneSignalService.forceUpdatePlayerId();
      } catch (_) {}
      database.child(userId.toString()).set({
        'userId': userId.toString(),
        'playerId': oneSiginalplayerid ?? 'null',
      });

      registerWizardPhoneCodeSent.value = true;
      final otpVal = loginModel.data?.otpValue;
      if (otpVal != null && otpVal.isNotEmpty) {
        textEditingOtpController.text = otpVal;
      }
      startRegisterWizardResendCountdown(60);
      showToastMessage(loginModel.message ?? 'Code sent'.tr);
      update();
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      if (_isDuplicateEmailMessage(e.toString())) {
        registerWizardEmailError.value = 'Cet email est déjà utilisé';
        registerWizardPhoneCodeSent.value = false;
        onDuplicateEmail?.call();
        return;
      }
      showErrorToastMessage(e.toString());
    }
  }

  Future<void> registerWizardResendOtp(
    BuildContext context,
    String cuntryCode,
  ) async {
    isResendLoading.value = true;
    try {
      final result = await resendOtp({
        'phone': textEditingSingUpControllerPhoneNumber.text,
        'phone_country': cuntryCode,
      });
      if (result != null && result['status'] == 200) {
        showToastMessage('${result['message']}');
        if (result['data'] != null && result['data']['otp_value'] != null) {
          textEditingOtpController.text =
              '${result['data']['otp_value']}';
        }
        startRegisterWizardResendCountdown(60);
      } else if (result != null) {
        showErrorToastMessage(result['error'] ?? 'Error'.tr);
      }
    } finally {
      isResendLoading.value = false;
    }
  }

  /// Après OTP + acceptation des CGU (étape finale du wizard) : navigation home sans nouvel appel API.
  Future<void> registerWizardCompleteToHome(BuildContext context) async {
    if (!registerWizardTermsAccepted.value) return;
    if (registerWizardSubmitting.value) return;

    registerWizardSubmitting.value = true;
    try {
      final vendorFlow = registerWizardIsAgency.value;
      isHostMode.value = vendorFlow;
      GetStorage().write('isHostMode', vendorFlow);

      showToastMessage('Registration successful'.tr);
      await Future.delayed(const Duration(milliseconds: 150));

      registerWizardEmbarked.value = false;

      if (webPlateForm) {
        Get.offAllNamed(
          vendorFlow ? WebRoutes.buttomHost : WebRoutes.homeMain,
        );
      } else {
        if (vendorFlow) {
          Get.offAll(() => const BottomHost(initialIndex: 0));
        } else {
          Get.offAll(() => const NavPageView());
        }
      }
    } catch (e, st) {
      debugPrint('registerWizardCompleteToHome error: $e\n$st');
      showErrorToastMessage('Something went wrong'.tr);
    } finally {
      registerWizardSubmitting.value = false;
    }
  }

  /// OneSignal + sync backend push + FCM + RTDB (peut être lourd — après OTP wizard on le lance en arrière-plan).
  Future<void> _runPostOtpVerifiedHeavyWork() async {
    try {
      debugPrint(
          '🆔 [ONESIGNAL_DEBUG] login userId=$userId');
      await OneSignal.login(userId.toString());
      await OneSignalService.forceUpdatePlayerId();
      debugPrint(
          '🆔 [ONESIGNAL_DEBUG] pushSubscription: ${OneSignal.User.pushSubscription.id}');
    } catch (e) {
      debugPrint('❌ [OneSignal] post-OTP: $e');
    }
    try {
      await AuthService.handleAuthenticatedUser(
        authToken: token,
        userId: userId,
      );
    } catch (e) {
      debugPrint('❌ [AuthService] post-OTP: $e');
    }
    try {
      await getFCMToken();
    } catch (e) {
      debugPrint('❌ [FCM] post-OTP: $e');
    }
    try {
      database.child(userId.toString()).set({
        'userId': userId.toString(),
        'playerId': oneSiginalplayerid ?? 'null',
      });
    } catch (e) {
      debugPrint('❌ [RTDB] post-OTP: $e');
    }
  }

  verifyOtp(map) async {
    // DEBUG: Print the exact payload being sent
    print("🔵 [FLUTTER_OTP] Sending OTP verification payload:");
    print("🔵 [FLUTTER_OTP] Map keys: ${map.keys.toList()}");
    print("🔵 [FLUTTER_OTP] Full payload: $map");
    print("🔵 [FLUTTER_OTP] Phone: ${map['phone']}");
    print("🔵 [FLUTTER_OTP] Phone Country: ${map['phone_country']}");
    print("🔵 [FLUTTER_OTP] OTP Value: ${map['otp_value']}");
    print("🔵 [FLUTTER_OTP] Endpoint: ${Config.otpVerification}");

    return await httpPost(Config.otpVerification, map);
  }

  resendOtp(map) async {
    return await httpPost(Config.resendOtp, map);
  }

  resendToken(map) async {
    return await httpPost(Config.resendToken, map);
  }

  verifyResetToken(map) async {
    return await httpPost(Config.verifyResetToken, map);
  }

  checkMobileNumber(map) async {
    showLoading();
    var response = await httpPost(Config.checkMobileNumber, map);
    closeLoading();
    if (response['status'] != 200) {
      showErrorToastMessage(response['error']);
    }
    return CheckMobileModel.fromJson(response);
  }

  changeMobileNumber(map) async {
    var response = await httpPost(Config.changeMobileNumber, map);
    return ChangePhoneModel.fromJson(response);
  }

  void setLoginModel(LoginModel model) {
    loginModel = model;
    // Mettre à jour le rôle de l'utilisateur depuis le modèle
    if (model.data != null && model.data!.role != null) {
      userRole.value = model.data!.role!;
      debugPrint('✅ [AUTH_CONTROLLER] User role updated: ${userRole.value}');
      debugPrint('🔍 DEBUG ROLE: Current user role is: ${userRole.value}');
      print('🔑 [VERIF_ROLE] Valeur finale stockée : ${userRole.value}');
    } else {
      userRole.value = '';
      debugPrint('⚠️ [AUTH_CONTROLLER] User role not found in login model');
      debugPrint('🔍 DEBUG ROLE: Current user role is: ${userRole.value}');
      print('🔑 [VERIF_ROLE] Valeur finale stockée : ${userRole.value} (vide - rôle non trouvé)');
    }
  }

  /// Rafraîchit le rôle de l'utilisateur depuis loginModel
  /// Utile pour forcer la mise à jour du rôle après le chargement des données
  void refreshUserRole() {
    if (loginModel?.data?.role != null) {
      userRole.value = loginModel!.data!.role!;
      print('🎯 [ROLE_FIX] Rôle forcé à : ${userRole.value}');
      debugPrint('🎯 [ROLE_FIX] Rôle forcé à : ${userRole.value}');
    } else {
      userRole.value = '';
      print('⚠️ [ROLE_FIX] loginModel ou role est null - Rôle non disponible');
      debugPrint('⚠️ [ROLE_FIX] loginModel ou role est null - Rôle non disponible');
    }
  }

  LoginModel? getLoginModel() {
    return loginModel;
  }

  bool load = false;

  Future<void> loginMethod(
      BuildContext context, GlobalKey<FormState> formKey) async {
    try {
      if (formKey.currentState?.validate() ?? false) {
        buildShowDialog(context);
        var json = await httpPost(Config.userEmailLogin, {
          "email": textEditingControllerEmail.text,
          "password": textEditingControllerPass.text,
        });
        
        // Log des données brutes reçues
        print('📥 [LOGIN_RAW] Données reçues : $json');
        if (json['data'] != null) {
          print('📥 [LOGIN_RAW] Données data : ${json['data']}');
        }
        
        LoginModel loginModel = LoginModel.fromJson(json);
        Get.back();
        if (json["status"] == 200) {
          GetStorage().write('Remember', true);
          GetStorage().write('Firstuser', true);
          
          // Sauvegarder TOUT l'objet dans 'user_data' pour inclure le rôle
          GetStorage().write('user_data', jsonEncode(json));
          print('💾 [LOGIN] Données sauvegardées dans user_data');
          
          // Sauvegarder aussi dans 'UserData' pour compatibilité
          UserData userObj = UserData();
          userObj.saveLoginData("UserData", jsonEncode(json));
          token = loginModel.data!.token!;
          // --- FIX: FLUSH GUEST TOKEN ---
          // Clear the old Guest Bearer Token so http_service is forced to generate a new User Bearer Token.
          GetStorage().remove("bearerToken");
          bearerToken = ""; // Reset the global variable immediately
          print(
              "🧹 [Auth] Old Bearer Token flushed. Ready for User Token generation.");
          // ------------------------------
          userId = loginModel.data!.id!;
          generalController.currentIndex.value = 0;
          update();
          shouldLogout = false;
          getFCMToken();
          // Lier l'utilisateur OneSignal + synchroniser l'ID au backend.
          try {
            await AuthService.handleAuthenticatedUser(
              authToken: token,
              userId: userId,
            );
          } catch (e) {
            print('❌ [OneSignal] Erreur lors de la synchronisation OneSignal : $e');
          }
          database.child(userId.toString()).set({
            "userId": userId.toString(),
            "playerId": oneSiginalplayerid ?? "null",
          });

          setLoginModel(loginModel);
          if (handlelogin == true) {
            await generalController.fetchGeneralSettings();
            Get.back();
            filterController.setDefaultDates(
              startDateCustomDate: generalScopeController.startDateCustomDate,
              endDateCustomDate: generalScopeController.endDateCustomDate,
              startDate: filterController.startDate,
              endDates: filterController.endDates,
            );

            handlelogin = false;
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const HomeMain(initialIndex: 0)),
            );
          }
        } else if (json["status"] == 403) {
          showErrorToastMessage("Please Complete the Verification process".tr);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (builder) => OtpScreen(
                        number: loginModel.data!.phone!,
                        countryCode: loginModel.data!.phoneCountry!,
                        otpValue: loginModel.data!.resetToken!,
                        email: "",
                      )));
        } else {
          showErrorToastMessage(json["message"]);
        }
      }
    } catch (e) {}
  }

  Future<void> signUp(
    BuildContext context,
    GlobalKey<FormState> formKey,
    isChecked,
    countryDialCode,
    countryIsoCode,
  ) async {
    if (textEditingSingUpControllerPhoneNumber.text.isEmpty) {
      showErrorToastMessage("Fill valid mobile number".tr);
      return;
    }
    if (isChecked == false) {
      showErrorToastMessage("Please select Terms and Condition".tr);
      return;
    }
    if (!countryDialCode.startsWith("+")) {
      countryDialCode = '+$countryDialCode';
    }

    try {
      if (formKey.currentState!.validate() && (isChecked == true)) {
        registerWizardEmailError.value = '';
        phoneError.value = '';
        buildShowDialog(context);
        var data = await httpPost(Config.registerUser, {
          "phone": textEditingSingUpControllerPhoneNumber.text,
          "email": textEditingSignUpControllerEmail.text,
          "first_name": textEditingSignUpControllerFirstName.text,
          "password": textEditingSignUpControllerPassword.text,
          "phone_country": countryDialCode,
          "default_country": countryIsoCode,
          "last_name": textEditingSingUpControllerlastName.text,
          "birthdate": signUpBirthdateForApi,
        });

        // DEBUG: Log raw response from backend
        print("DEBUG REGISTER RESPONSE: $data");

        Get.back();
        if (data != null) {
          if (_handleRegisterUserHttp409(data)) {
            return;
          }
          LoginModel loginModel = LoginModel.fromJson(data);

          // DEBUG: Log parsed model status
          print("DEBUG: Parsed LoginModel status: ${loginModel.status}");
          print("DEBUG: LoginModel data: ${loginModel.data?.toJson()}");

          if (loginModel.status == 200) {
            print("DEBUG: Status is 200");

            // DEBUG: Check verification status
            print("DEBUG: Verified status: ${loginModel.data?.verified}");
            print("DEBUG: OTP Value: ${loginModel.data?.otpValue}");
            print("DEBUG: Token: ${loginModel.data?.token}");

            if (loginModel.data?.verified == '0' ||
                loginModel.data?.verified == null) {
              print("DEBUG: User NOT verified, should go to OTP");
            } else {
              print(
                  "DEBUG: User already verified (status: ${loginModel.data?.verified}), but still navigating to OTP screen");
            }
            GetStorage().write('Remember', true);
            GetStorage().write('Firstuser', true);

            getFCMToken();
            token = loginModel.data!.token!;
            // --- FIX: FLUSH GUEST TOKEN ---
            // Clear the old Guest Bearer Token so http_service is forced to generate a new User Bearer Token.
            GetStorage().remove("bearerToken");
            bearerToken = ""; // Reset the global variable immediately
            print(
                "🧹 [Auth] Old Bearer Token flushed. Ready for User Token generation.");
            // ------------------------------
            userId = loginModel.data!.id!;
          // Lier l'utilisateur à OneSignal avec External User ID
          try {
            print('🆔 [ONESIGNAL_DEBUG] Tentative de login pour l\'utilisateur : $userId');
            await OneSignal.login(userId.toString());
            String? pushToken = OneSignal.User.pushSubscription.id;
            print('🆔 [ONESIGNAL_DEBUG] ID de souscription actuel (PlayerID) : $pushToken');
            print('🔔 [OneSignal] ID lié pour l\'utilisateur : $userId');
            await OneSignalService.forceUpdatePlayerId();
          } catch (e) {
            print('❌ [OneSignal] Erreur lors de la liaison de l\'ID utilisateur : $e');
          }
            database.child(userId.toString()).set({
              "userId": userId.toString(),
              "playerId": oneSiginalplayerid ?? "null",
            });

            if (webPlateForm) {
              print("DEBUG: Navigating to OTP Screen (Web Platform)");
              Get.toNamed(
                WebRoutes.otpScreen,
                arguments: {
                  'number': textEditingSingUpControllerPhoneNumber.text,
                  'countryCode': "$countryDialCode",
                  'otpValue': loginModel.data!.otpValue,
                  'email': "",
                },
              );
            } else {
              print("DEBUG: Navigating to OTP Screen (Mobile Platform)");
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => OtpScreen(
                            number: textEditingSingUpControllerPhoneNumber.text,
                            countryCode: "$countryDialCode",
                            otpValue: loginModel.data!.otpValue!,
                            email: "",
                          )));
            }
          } else {
            print(
                "DEBUG: Status is NOT 200. Status: ${loginModel.status}, Error: ${loginModel.error}");
            print(
                "DEBUG: Navigating to Login/Home. Verified status is: ${loginModel.data?.verified}");
            showErrorToastMessage(loginModel.error);
          }
        } else {
          print("DEBUG: Response data is NULL - Something went wrong");
          showErrorToastMessage("Something went wrong".tr);
        }
      }
    } catch (e) {
      print("DEBUG: Exception caught in signUp: $e");
      print("DEBUG: Stack trace: ${StackTrace.current}");
      Get.back();
    }
  }

  Future<void> forgetPassword(
      BuildContext context, GlobalKey<FormState> formKey) async {
    try {
      if (formKey.currentState?.validate() ?? false) {
        buildShowDialog(context);
        var result = await httpPost(Config.forgotPassword, {
          "email": textEditingForgetPasswordControllerEmail.text,
        });
        Get.back();
        ForgotPassModel forgotPassModel = ForgotPassModel.fromJson(result);
        if (forgotPassModel.status == 200) {
          showToastMessage(forgotPassModel.message);
          if (webPlateForm) {
            Get.toNamed(
              WebRoutes.otpScreen,
              arguments: {
                'number': "",
                'countryCode': "",
                'otpValue': forgotPassModel.data!.resetToken!,
                'email': textEditingForgetPasswordControllerEmail.text,
              },
            );
          } else {
            Get.offAll(() => OtpScreen(
                  otpValue: forgotPassModel.data!.resetToken!,
                  countryCode: '',
                  number: '',
                  email: textEditingForgetPasswordControllerEmail.text,
                ));
          }
        } else {
          showToastMessage(forgotPassModel.error);
        }
      }
    } catch (e) {
      Get.back();
    }
  }

  verifyFunction(
    BuildContext context,
    GlobalKey<FormState> formKey, {
    otp,
    changeEmail,
    changeMobile,
    email,
    number,
    cuntryCode,
    defaultCountry,
    VoidCallback? onRegisterWizardPhoneVerified,
    VoidCallback? onRegisterWizardDuplicateEmail,
  }) async {
    if (otp == "") {
      showErrorToastMessage("Please fill the Otp".tr);
      return;
    }
    try {
      if (changeEmail != null) {
        showLoading();
        var response = await httpPost(
            Config.changeEmail, {"email": email, "otp_value": otp});
        closeLoading();
        update();
        if (response != null) {
          LoginModel loginModel = LoginModel.fromJson(response);
          if (loginModel.status == 200) {
            showToastMessage(loginModel.message);
            
            // Sauvegarder TOUT l'objet dans 'user_data' pour inclure le rôle
            GetStorage().write('user_data', jsonEncode(loginModel.toJson()));
            print('💾 [CHANGE_EMAIL] Données sauvegardées dans user_data');
            
            UserData userObj = UserData();
            userObj.saveLoginData("UserData", jsonEncode(loginModel.toJson()));
            generalController.currentIndex.value = 0;
            setLoginModel(loginModel);
            if (webPlateForm) {
              Get.toNamed(WebRoutes.myprofile);
            } else {
              Get.offAll(() => const MyProfile());
            }
          } else {
            showErrorToastMessage(loginModel.error);
          }
        }
        return;
      } else if (changeMobile != null) {
        Map map = {
          "phone": number,
          "phone_country": cuntryCode,
          "otp_value": otp,
          "default_country": defaultCountry,
        };
        showLoading();
        var response = await httpPost(Config.changeMobileNumber, map);
        closeLoading();
        update();
        LoginModel loginModel = LoginModel.fromJson(response);
        if (loginModel.status == 200) {
          showToastMessage(loginModel.message);
          
          // Sauvegarder TOUT l'objet dans 'user_data' pour inclure le rôle
          GetStorage().write('user_data', jsonEncode(response));
          print('💾 [CHANGE_MOBILE] Données sauvegardées dans user_data');
          
          UserData userObj = UserData();
          userObj.saveLoginData("UserData", jsonEncode(response));
          generalController.currentIndex.value = 0;
          shouldLogout = false;
          setLoginModel(loginModel);
          if (profileController.loginWithSocialMedia.value == true) {
            generalController.currentIndex.value = 0;
            update();

            if (handlelogin == true) {
              Get.back();
              Get.back();
              await generalController.fetchGeneralSettings();
              filterController.setDefaultDates(
                startDateCustomDate: generalScopeController.startDateCustomDate,
                endDateCustomDate: generalScopeController.endDateCustomDate,
                startDate: filterController.startDate,
                endDates: filterController.endDates,
              );

              handlelogin = false;
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const HomeMain(initialIndex: 0)),
              );
            }
            profileController.loginWithSocialMedia.value = false;
          } else {
            if (webPlateForm) {
              Get.toNamed(WebRoutes.myprofile);
            } else {
              Get.offAll(() => const MyProfile());
            }
          }
        } else {
          showErrorToastMessage(loginModel.error);
        }

        return;
      } else if (email.isEmpty) {
        showLoading();
        var result = await verifyOtp(
            {"phone": number, "otp_value": otp, "phone_country": cuntryCode});
        closeLoading();
        update();
        if (result != null) {
          LoginModel loginModel = LoginModel.fromJson(result);
          if (loginModel.status == 200) {
            showToastMessage(loginModel.message);

            GetStorage().write('user_data', jsonEncode(result));
            print('💾 [VERIFY_OTP] Données sauvegardées dans user_data');

            UserData userObj = UserData();
            userObj.saveLoginData("UserData", jsonEncode(result));
            token = loginModel.data!.token!;
            userId = loginModel.data!.id!;
            GetStorage().write('token', token);
            GetStorage().write('userIdGlobal', userId.toString());
            GetStorage().remove('bearerToken');
            bearerToken = '';
            setLoginModel(loginModel);
            generalController.currentIndex.value = 0;
            shouldLogout = false;

            if (onRegisterWizardPhoneVerified != null) {
              onRegisterWizardPhoneVerified();
              unawaited(_runPostOtpVerifiedHeavyWork());
              return;
            }

            await _runPostOtpVerifiedHeavyWork();

            if (webPlateForm) {
              Get.toNamed(WebRoutes.homeMain);
            } else {
              Get.offAll(() => const HomeMain(initialIndex: 0));
            }
          } else {
            final err = (loginModel.error ?? '').toString();
            if (_isDuplicateEmailMessage(err)) {
              registerWizardEmailError.value = 'Cet email est déjà utilisé';
              registerWizardPhoneCodeSent.value = false;
              onRegisterWizardDuplicateEmail?.call();
              return;
            }
            showErrorToastMessage(loginModel.error);
            textEditingOtpController.clear();
          }
        } else {
          showErrorToastMessage("Error: Null result received".tr);
        }
      } else {
        showLoading();
        var response =
            await verifyResetToken({"email": email, "reset_token": otp});
        closeLoading();
        update();
        if (response["status"] == 200) {
          ResetPassModel resetPassModel = ResetPassModel.fromJson(response);
          showToastMessage(resetPassModel.message);
          
          // Sauvegarder TOUT l'objet dans 'user_data' pour inclure le rôle
          GetStorage().write('user_data', jsonEncode(response));
          print('💾 [RESET_PASSWORD] Données sauvegardées dans user_data');
          
          UserData userObj = UserData();
          userObj.saveLoginData("UserData", jsonEncode(response));
          shouldLogout = false;

          if (webPlateForm) {
            Get.toNamed(
              WebRoutes.resetPasswordScreen,
              arguments: {
                'email': email!,
                'resetToken': otp,
              },
            );
          } else {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (builder) => ResetPasswordScreen(
                          email: email,
                          resetToken: otp,
                        )));
          }
        } else {
          showErrorToastMessage(response["error"]);
          textEditingOtpController.clear();
        }
      }
    } catch (e) {
      closeLoading();
    }
  }

  Future<void> resendNewCodeFunction(
      BuildContext context, GlobalKey<FormState> formKey,
      {otp,
      changeEmail,
      changeMobile,
      email,
      number,
      cuntryCode,
      changeMobiles}) async {
    isResendLoading.value = true;
    showLoading();
    try {
      if (changeMobiles != null) {
        var response = await httpPost(Config.checkMobileNumber, {
          "phone": changeMobiles!['phone'],
          "phone_country": changeMobiles!['phone_country'],
          "email": changeMobiles!['email']
        });
        if (response != null) {
          closeLoading();
          CheckMobileModel model = CheckMobileModel.fromJson(response);
          textEditingOtpController.text = model.data!.otp!.toString();
          changeMobiles!['otp_value'] = textEditingOtpController.text;
        }
      } else if (changeEmail != null) {
        var resultToken = await httpPost(Config.resendTokenEmailChange,
            {"email": email, "type": "email_reset"});
        if (resultToken != null) {
          closeLoading();
          if (resultToken['status'] == 200) {
            showToastMessage(resultToken['message']);
            if (resultToken['data'] != null) {
              textEditingOtpController.text =
                  resultToken['data']['reset_token'];
            }
          } else {
            showToastMessage(resultToken['success']);
          }
        }
      } else if (email.isEmpty) {
        var result =
            await resendOtp({"phone": number, "phone_country": cuntryCode});
        if (result != null) {
          closeLoading();
          if (result['status'] == 200) {
            showToastMessage("${result['message']}");
            if (result['data'] != null) {
              textEditingOtpController.text = result['data']['otp_value'];
            }
          } else {
            showToastMessage(result['error']);
          }
        }
      } else {
        var resultToken = await resendToken({"email": email});
        if (resultToken != null) {
          closeLoading();
          if (resultToken['status'] == 200) {
            showToastMessage(resultToken['message']);
            if (resultToken['data'] != null) {
              textEditingOtpController.text =
                  resultToken['data']['reset_token'];
            }
          } else {
            showToastMessage(resultToken['success']);
          }
        }
      }
    } catch (e) {
      closeLoading();
    }
    isResendLoading.value = false;
  }

  Future<void> callChangePassApi(
      BuildContext context, GlobalKey<FormState> formKey,
      {otp, email}) async {
    try {
      if (formKey.currentState?.validate() ?? false) {
        buildShowDialog(context);
        Map map = {
          "email": email,
          "reset_token": otp,
          "password": textEditingResetControllerNewPassword.text,
          "confirm_password": textEditingResetControllerConfirmPassword.text
        };

        var json = await httpPost(Config.resetPassword, map);
        Get.back();

        if (json != null) {
          ResetPassModel resetPassModel = ResetPassModel.fromJson(json);
          if (resetPassModel.status == 200) {
            showToastMessage(resetPassModel.message);
            if (webPlateForm) {
              Get.toNamed(WebRoutes.successChangeScreen);
            } else {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => const SuccessChangePassword()));
            }
          } else {
            showErrorToastMessage(resetPassModel.error);
          }
        } else {
          showErrorToastMessage("Something went wrong".tr);
        }
      }
    } catch (e) {
      Get.back();
    }
  }

  updateThePassword(BuildContext context, GlobalKey<FormState> formKey,
      {otp, email}) async {
    try {
      showLoading();
      if (formKey.currentState?.validate() ?? false) {}
      Map<String, String> postData = {
        "old_password": textEditingControllerOldPassword.text,
        "new_password": textEditingControllerNewPassword.text,
        "conf_new_password": textEditingControllerConfirmPassword.text,
      };
      var response = await httpPost(Config.updatePassword, postData);
      if (response != null) {
        if (response['status'] == 200) {
          showToastMessage(response['message']);
          closeLoading();
          Get.back();
        } else {
          showErrorToastMessage(response['error']);
          closeLoading();
        }
      }
    } catch (e) {
      closeLoading();
    }
  }

  GlobalScopeController globalScopeController = Get.find();
  void clearSocialUpdateData() {
    if (loginModel!.data!.firstName != null) {
      profileController.firetnameControllerSocialMedialogin.text =
          loginModel!.data!.firstName!;
    }
    if (loginModel!.data!.lastName != null) {
      profileController.lastnameControllerSocialMedialogin.text =
          loginModel!.data!.lastName!;
    }
    if (loginModel!.data!.email != null) {
      profileController.emailControllerSocialMedialogin.text =
          loginModel!.data!.email!;
    }
  }

  /// Remplit uniquement le formulaire d'inscription (prénom, nom, email) depuis le compte Google.
  /// N'appelle pas l'API sociale ni [signUp] — l'utilisateur valide avec « Continuer ».
  Future<void> prefillSignUpFormFromGoogle(BuildContext context) async {
    // 🛡️ [GOOGLE_AUTH] Anti-spam : on partage le MÊME verrou que `googleLogin`
    // car les deux flows ouvrent la pop-up native Google Sign-In.
    if (isGoogleAuthLoading.value) {
      debugPrint(
          '⛔ [GOOGLE_AUTH/PREFILL] Tentative ignorée : une auth Google est déjà en cours.');
      return;
    }
    isGoogleAuthLoading.value = true;
    debugPrint('🔍 [GOOGLE_AUTH/PREFILL] 1. Bouton cliqué (prefill signup)');

    final googleSignIn = GoogleSignIn.instance;
    showLoading();
    try {
      await googleSignIn.initialize(
        serverClientId: _kGoogleServerClientId,
      );
      debugPrint('🔧 [GOOGLE_AUTH/PREFILL] initialize() OK');

      // 🔍 2. Déconnexion préalable silencieuse
      debugPrint('🔍 [GOOGLE_AUTH/PREFILL] 2. Déconnexion préalable (silencieuse)');
      try {
        await googleSignIn.signOut();
      } catch (silentSignOutError) {
        debugPrint(
            '⚠️ [GOOGLE_AUTH/PREFILL] signOut() préalable a échoué silencieusement : $silentSignOutError');
      }

      // 🔍 3. authenticate() avec capture d'erreur avancée
      debugPrint('🔍 [GOOGLE_AUTH/PREFILL] 3. Lancement de signIn()');
      GoogleSignInAccount? googleUser;
      try {
        googleUser = await googleSignIn.authenticate(
          scopeHint: <String>['email', 'profile'],
        );
      } on PlatformException catch (e, st) {
        debugPrint('🚨 [GOOGLE_AUTH/PREFILL] PlatformException pendant authenticate()');
        debugPrint('🚨 [GOOGLE_AUTH/PREFILL] -> e.code    = ${e.code}');
        debugPrint('🚨 [GOOGLE_AUTH/PREFILL] -> e.message = ${e.message}');
        debugPrint('🚨 [GOOGLE_AUTH/PREFILL] -> e.details = ${e.details}');
        debugPrint('🚨 [GOOGLE_AUTH/PREFILL] -> stack     = $st');
        closeLoading();
        showErrorToastMessage(
            "Google Sign-In échoué (PlatformException ${e.code}). ${e.message ?? ''}");
        return;
      } on GoogleSignInException catch (e, st) {
        debugPrint(
            '🚨 [GOOGLE_AUTH/PREFILL] GoogleSignInException pendant authenticate()');
        debugPrint('🚨 [GOOGLE_AUTH/PREFILL] -> e.code        = ${e.code}');
        debugPrint('🚨 [GOOGLE_AUTH/PREFILL] -> e.description = ${e.description}');
        debugPrint('🚨 [GOOGLE_AUTH/PREFILL] -> e.details     = ${e.details}');
        debugPrint('🚨 [GOOGLE_AUTH/PREFILL] -> stack         = $st');
        closeLoading();
        showErrorToastMessage(
            "Connexion Google annulée ou échouée (${e.code}). ${e.description ?? ''}");
        return;
      }

      if (googleUser == null) {
        debugPrint('ℹ️ [GOOGLE_AUTH/PREFILL] Utilisateur a annulé la pop-up.');
        closeLoading();
        return;
      }

      // ✅ 4. Succès
      debugPrint(
          '✅ [GOOGLE_AUTH/PREFILL] 4. Succès: Compte récupéré -> ${googleUser.email}');

      final String email = googleUser.email;
      final String? displayName = googleUser.displayName;

      String givenName = '';
      String familyName = '';

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final Map<String, dynamic>? payload =
          idToken != null ? JwtDecoder.tryDecode(idToken) : null;
      if (payload != null) {
        final gn = payload['given_name'];
        final fn = payload['family_name'];
        if (gn is String && gn.trim().isNotEmpty) givenName = gn.trim();
        if (fn is String && fn.trim().isNotEmpty) familyName = fn.trim();
      }

      if (givenName.isEmpty &&
          familyName.isEmpty &&
          displayName != null &&
          displayName.trim().isNotEmpty) {
        final parts = displayName.trim().split(RegExp(r'\s+'));
        givenName = parts.first;
        if (parts.length > 1) {
          familyName = parts.sublist(1).join(' ');
        }
      }

      textEditingSignUpControllerFirstName.text = givenName;
      textEditingSingUpControllerlastName.text = familyName;
      textEditingSignUpControllerEmail.text = email;

      try {
        await googleSignIn.signOut();
      } catch (_) {}
      closeLoading();
      update();
    } on GoogleSignInException catch (e, st) {
      debugPrint(
          '🚨 [GOOGLE_AUTH/PREFILL] GoogleSignInException (outer): code=${e.code}, description=${e.description}, details=${e.details}');
      debugPrint('🚨 [GOOGLE_AUTH/PREFILL] stack=$st');
      closeLoading();
      showErrorToastMessage(
          "Erreur lors de la connexion Google (${e.code}): ${e.description ?? ''}");
    } on PlatformException catch (e, st) {
      debugPrint(
          '🚨 [GOOGLE_AUTH/PREFILL] PlatformException (outer): code=${e.code}, message=${e.message}, details=${e.details}');
      debugPrint('🚨 [GOOGLE_AUTH/PREFILL] stack=$st');
      closeLoading();
      showErrorToastMessage(
          "Erreur Google Sign-In (${e.code}): ${e.message ?? ''}");
    } catch (e, st) {
      debugPrint('🚨 [GOOGLE_AUTH/PREFILL] Erreur inattendue: $e');
      debugPrint('🚨 [GOOGLE_AUTH/PREFILL] stack=$st');
      closeLoading();
      showErrorToastMessage("Une erreur inattendue s'est produite: $e");
    } finally {
      isGoogleAuthLoading.value = false;
      debugPrint('🏁 [GOOGLE_AUTH/PREFILL] Verrou de concurrence relâché.');
    }
  }

  // ============================================================================
  // 🔐 [GOOGLE_AUTH] Connexion Google (google_sign_in: ^7.1.1)
  // ----------------------------------------------------------------------------
  // ⚠️ Vérification de l'instance / clientId (à relire à chaque régression) :
  //   • On utilise le singleton `GoogleSignIn.instance` (API v7.x).
  //   • `serverClientId` DOIT être le *Web Client ID* du projet
  //     Firebase / Google Cloud Console — PAS le client Android.
  //     -> Si quelqu'un a remplacé cette valeur par un Android Client ID
  //        ou un ID d'un autre projet, `authenticate()` renvoie instantanément
  //        l'erreur [16] Canceled.
  //   • Sur Android, la SHA-1 (debug ET release) du keystore courant doit
  //     être enregistrée dans Firebase Console → Project settings →
  //     Your apps → SHA fingerprints, ET le `google-services.json`
  //     régénéré + réimporté dans `android/app/`.
  //   • Si le `applicationId` (package name) a changé récemment, ou si
  //     le keystore signing a été modifié, idem : erreur [16] instantanée.
  //
  // ⚠️ RÉGRESSION DU 10/05/2026 — la cause :
  //   L'ancienne valeur "165062133214-vjalpnirifhehf3vm91ashd5f0mm19g1..."
  //   appartient à un AUTRE projet Google Cloud (project_number 165062133214),
  //   alors que le google-services.json embarqué dans android/app/ correspond
  //   au projet "carvy-test" (project_number 415377246287). Le mismatch produit
  //   un [16] Canceled instantané sur authenticate().
  //   La valeur ci-dessous est le SEUL client_type=3 (Web Client ID) listé
  //   dans google-services.json, donc le bon Web Client ID du projet courant.
  // ============================================================================
  static const String _kGoogleServerClientId =
      "415377246287-h4pscp4lgar3qtc41djpau0rbbr1u08h.apps.googleusercontent.com";

  Future<void> googleLogin(BuildContext context) async {
    // ============================================================
    // 🛡️ [GOOGLE_AUTH] 0. Verrou Anti-Spam / Concurrency
    // Empêche le double-clic ou la double-exécution du flow Google.
    // Sans ça, deux appels concurrents peuvent provoquer un
    // "Canceled [16]" instantané sur le second appel.
    // ============================================================
    if (isGoogleAuthLoading.value) {
      debugPrint(
          '⛔ [GOOGLE_AUTH] Tentative ignorée : une auth Google est déjà en cours.');
      return;
    }
    isGoogleAuthLoading.value = true;

    // 🔍 [GOOGLE_AUTH] 1. Bouton cliqué
    debugPrint('🔍 [GOOGLE_AUTH] 1. Bouton cliqué');

    final googleSignIn = GoogleSignIn.instance;
    showLoading();

    try {
      // Initialisation idempotente du singleton (v7+).
      await googleSignIn.initialize(
        serverClientId: _kGoogleServerClientId,
      );
      debugPrint(
          '🔧 [GOOGLE_AUTH] initialize() OK avec serverClientId=$_kGoogleServerClientId');

      // ============================================================
      // 🔍 [GOOGLE_AUTH] 2. Déconnexion préalable (silencieuse)
      // Au cas où une session fantôme bloquerait l'authentification.
      // On NE veut PAS qu'un échec de signOut tue le flow.
      // ============================================================
      debugPrint('🔍 [GOOGLE_AUTH] 2. Déconnexion préalable (silencieuse)');
      try {
        await googleSignIn.signOut();
        debugPrint('🧹 [GOOGLE_AUTH] signOut() préalable OK');
      } catch (silentSignOutError, silentSignOutSt) {
        debugPrint(
            '⚠️ [GOOGLE_AUTH] signOut() préalable a échoué silencieusement : $silentSignOutError');
        debugPrint('⚠️ [GOOGLE_AUTH] stack: $silentSignOutSt');
      }

      // ============================================================
      // 🔍 [GOOGLE_AUTH] 3. Lancement de signIn() / authenticate()
      // Capture d'erreur AVANCÉE :
      //   - PlatformException : remontée par le canal natif Android/iOS
      //     (contient code/message/details bruts du SDK Google).
      //   - GoogleSignInException : exception métier du package.
      // ============================================================
      debugPrint('🔍 [GOOGLE_AUTH] 3. Lancement de signIn()');

      GoogleSignInAccount? googleUser;
      try {
        googleUser = await googleSignIn.authenticate(
          scopeHint: <String>['email', 'profile'],
        );
      } on PlatformException catch (e, st) {
        debugPrint(
            '🚨 [GOOGLE_AUTH] PlatformException pendant authenticate()');
        debugPrint('🚨 [GOOGLE_AUTH] -> e.code    = ${e.code}');
        debugPrint('🚨 [GOOGLE_AUTH] -> e.message = ${e.message}');
        debugPrint('🚨 [GOOGLE_AUTH] -> e.details = ${e.details}');
        debugPrint('🚨 [GOOGLE_AUTH] -> stack     = $st');
        // L'erreur Android "[16] Canceled" arrive typiquement ici quand :
        //   - SHA-1 manquante ou mauvaise dans Firebase Console
        //   - `serverClientId` n'est pas le Web Client ID du bon projet
        //   - `google-services.json` pas régénéré après changement de SHA / package
        //   - Aucun compte Google sur l'appareil / cache Play Services corrompu
        closeLoading();
        showErrorToastMessage(
          "Google Sign-In échoué (PlatformException ${e.code}). "
          "${e.message ?? ''}",
        );
        return;
      } on GoogleSignInException catch (e, st) {
        debugPrint(
            '🚨 [GOOGLE_AUTH] GoogleSignInException pendant authenticate()');
        debugPrint('🚨 [GOOGLE_AUTH] -> e.code        = ${e.code}');
        debugPrint('🚨 [GOOGLE_AUTH] -> e.description = ${e.description}');
        debugPrint('🚨 [GOOGLE_AUTH] -> e.details     = ${e.details}');
        debugPrint('🚨 [GOOGLE_AUTH] -> stack         = $st');
        closeLoading();
        showErrorToastMessage(
          "Connexion Google annulée ou échouée (${e.code}). "
          "${e.description ?? ''}",
        );
        return;
      }

      if (googleUser == null) {
        // L'utilisateur a fermé la pop-up volontairement.
        debugPrint(
            'ℹ️ [GOOGLE_AUTH] authenticate() a retourné null (utilisateur a annulé).');
        closeLoading();
        return;
      }

      // ============================================================
      // ✅ [GOOGLE_AUTH] 4. Succès : Compte récupéré
      // ============================================================
      debugPrint(
          '✅ [GOOGLE_AUTH] 4. Succès: Compte récupéré -> ${googleUser.email}');

      final String email = googleUser.email;
      final String id = googleUser.id;
      final String displayName = googleUser.displayName ?? '';
      final String profileImage = googleUser.photoUrl ?? '';

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      debugPrint(
          '🔑 [GOOGLE_AUTH] idToken obtenu : ${idToken == null ? "NULL" : "(${idToken.length} chars)"}');

      final LoginModel socialLoginModel =
          await globalScopeController.socialLogin(
        displayName,
        email,
        id,
        profileImage,
        "google",
        idToken ?? "",
        "",
      );

      GetStorage().write('Remember', true);
      GetStorage().write('Firstuser', true);
      final UserData userObj = UserData();
      userObj.saveLoginData(
          "UserData", jsonEncode(socialLoginModel.toJson()));
      loginModel = LoginModel.fromJson(socialLoginModel.toJson());
      await getFCMToken();
      token = socialLoginModel.data!.token!;
      // --- FIX: FLUSH GUEST TOKEN ---
      GetStorage().remove("bearerToken");
      bearerToken = "";
      print(
          "🧹 [Auth] Old Bearer Token flushed. Ready for User Token generation.");
      // ------------------------------
      userId = socialLoginModel.data!.id!;
      try {
        print('🆔 [ONESIGNAL_DEBUG] Tentative de login pour l\'utilisateur : $userId');
        await OneSignal.login(userId.toString());
        String? pushToken = OneSignal.User.pushSubscription.id;
        print('🆔 [ONESIGNAL_DEBUG] ID de souscription actuel (PlayerID) : $pushToken');
        print('🔔 [OneSignal] ID lié pour l\'utilisateur : $userId');
        await OneSignalService.forceUpdatePlayerId();
      } catch (e) {
        print('❌ [OneSignal] Erreur lors de la liaison de l\'ID utilisateur : $e');
      }
      database.child(userId.toString()).set({
        "userId": userId.toString(),
        "playerId": oneSiginalplayerid ?? "null",
      });

      shouldLogout = false;
      closeLoading();
      if (socialLoginModel.data!.phone == null) {
        clearSocialUpdateData();
        if (webPlateForm) {
          Get.toNamed(WebRoutes.googleUpdateScreen);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GoogleUpdate()),
          );
        }
        return;
      }
      if (handlelogin == true) {
        Get.back();
        await generalController.fetchGeneralSettings();
        filterController.setDefaultDates(
          startDateCustomDate: generalScopeController.startDateCustomDate,
          endDateCustomDate: generalScopeController.endDateCustomDate,
          startDate: filterController.startDate,
          endDates: filterController.endDates,
        );

        handlelogin = false;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const HomeMain(initialIndex: 0)),
        );
      }

      generalController.currentIndex.value = 0;
      update();
    } on GoogleSignInException catch (e, st) {
      // Filet de sécurité (post-authenticate)
      debugPrint(
          '🚨 [GOOGLE_AUTH] GoogleSignInException (outer): code=${e.code}, description=${e.description}, details=${e.details}');
      debugPrint('🚨 [GOOGLE_AUTH] stack=$st');
      closeLoading();
      showErrorToastMessage(
          "Erreur lors de la connexion Google (${e.code}): ${e.description ?? ''}");
    } on PlatformException catch (e, st) {
      // Filet de sécurité (post-authenticate)
      debugPrint(
          '🚨 [GOOGLE_AUTH] PlatformException (outer): code=${e.code}, message=${e.message}, details=${e.details}');
      debugPrint('🚨 [GOOGLE_AUTH] stack=$st');
      closeLoading();
      showErrorToastMessage(
          "Erreur Google Sign-In (${e.code}): ${e.message ?? ''}");
    } catch (e, st) {
      debugPrint('🚨 [GOOGLE_AUTH] Erreur inattendue: $e');
      debugPrint('🚨 [GOOGLE_AUTH] stack=$st');
      closeLoading();
      showErrorToastMessage("Une erreur inattendue s'est produite: $e");
    } finally {
      isGoogleAuthLoading.value = false;
      debugPrint('🏁 [GOOGLE_AUTH] Verrou de concurrence relâché.');
    }
  }
  

  Future<void> appleLogin(BuildContext context) async {
    try {
      showLoading();
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
       

      );

      var name = credential.givenName ?? '';
      if (credential.familyName != null) {
        name += ' ${credential.familyName!}';
      }

      var email = credential.email ?? '';

      LoginModel socialLoginModel = await globalScopeController.socialLogin(
        name,
        email,
        credential.userIdentifier!,
        "",
        "apple",
        credential.identityToken!,
        credential.authorizationCode,
      );
      GetStorage().write('Remember', true);
      GetStorage().write('Firstuser', true);
      
      // Sauvegarder TOUT l'objet dans 'user_data' pour inclure le rôle
      GetStorage().write('user_data', jsonEncode(socialLoginModel.toJson()));
      print('💾 [SOCIAL_LOGIN] Données sauvegardées dans user_data');
      
      UserData userObj = UserData();
      userObj.saveLoginData("UserData", jsonEncode(socialLoginModel.toJson()));
      loginModel = LoginModel.fromJson(socialLoginModel.toJson());
      getFCMToken();
      token = socialLoginModel.data!.token!;
      // --- FIX: FLUSH GUEST TOKEN ---
      // Clear the old Guest Bearer Token so http_service is forced to generate a new User Bearer Token.
      GetStorage().remove("bearerToken");
      bearerToken = ""; // Reset the global variable immediately
      print(
          "🧹 [Auth] Old Bearer Token flushed. Ready for User Token generation.");
      // ------------------------------
      userId = socialLoginModel.data!.id!;
      // Lier l'utilisateur à OneSignal avec External User ID
      try {
        print('🆔 [ONESIGNAL_DEBUG] Tentative de login pour l\'utilisateur : $userId');
        await OneSignal.login(userId.toString());
        String? pushToken = OneSignal.User.pushSubscription.id;
        print('🆔 [ONESIGNAL_DEBUG] ID de souscription actuel (PlayerID) : $pushToken');
        print('🔔 [OneSignal] ID lié pour l\'utilisateur : $userId');
        await OneSignalService.forceUpdatePlayerId();
      } catch (e) {
        print('❌ [OneSignal] Erreur lors de la liaison de l\'ID utilisateur : $e');
      }
      database.child(userId.toString()).set({
        "userId": userId.toString(),
        "playerId": oneSiginalplayerid ?? "null",
      });

      shouldLogout = false;
      if (socialLoginModel.data!.phone == null) {
        clearSocialUpdateData();
        if (webPlateForm) {
          Get.toNamed(WebRoutes.googleUpdateScreen);
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const GoogleUpdate()));
        }

        return;
      }
      if (handlelogin == true) {
        Get.back();
        await generalController.fetchGeneralSettings();
        filterController.setDefaultDates(
          startDateCustomDate: generalScopeController.startDateCustomDate,
          endDateCustomDate: generalScopeController.endDateCustomDate,
          startDate: filterController.startDate,
          endDates: filterController.endDates,
        );

        handlelogin = false;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const HomeMain(initialIndex: 0)),
        );
      }

      generalController.currentIndex.value = 0;
    } catch (e) {
      closeLoading();
    } finally {
      closeLoading();
      update();
    }
  }

  Location location = Location();
  getUserLocation() async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      bool serviceEnabled;
      PermissionStatus permissionGranted;
      LocationData locationData;
      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }
      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      locationData = await location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        GetStorage().write('latitudeGlobal', locationData.latitude.toString());
        GetStorage()
            .write('longitudeGlobal', locationData.longitude.toString());
        latitudeGlobal = locationData.latitude.toString();
        longitudeGlobal = locationData.longitude.toString();
        update();
      } else {
        return;
      }
    } catch (e) {
      //
    }
  }

  TextEditingController becomeLeadFirstName = TextEditingController();
  TextEditingController becomeLeadLastname = TextEditingController();
  TextEditingController becomeLeadEmail = TextEditingController();
  TextEditingController becomeLeadPhoneNumber = TextEditingController();
  TextEditingController becomeLeadFulladdress = TextEditingController();
  TextEditingController companyName = TextEditingController();
  var selectedImag = "".obs;
  var selectedImagyoBecomeAhostbase64 = "";
  var selectlettobecomeHost = "";
  var selectlongTibecomeHost = "";
  var selectLegalForm = "";
  var selectIdentityType = "";
  int fileSizeThreshold = 1024 * 1024;
  int goodQuality = 85;
  int badQuality = 50;
  int maxWidth = 800;
  int maxHeight = 600;
  XFile? identityimageforWeb;
  Future<void> compressAndUploadImage(String imagePath, String source) async {
    selectedImag.value = imagePath;
    update();
    var imageFile = File(imagePath);
    int originalSize = await imageFile.length();
    int quality = originalSize > fileSizeThreshold ? badQuality : goodQuality;
    var compressedImage = await FlutterImageCompress.compressWithFile(
      imagePath,
      quality: quality,
      minWidth: maxWidth,
      minHeight: maxHeight,
    );

    int compressedSize = compressedImage!.length;
    var base64Image = base64Encode(compressedImage);
    String format = '';
    if (compressedSize > 8) {
      if (compressedImage[0] == 0xFF && compressedImage[1] == 0xD8) {
        format = 'jpeg';
      } else if (compressedImage[0] == 0x89 && compressedImage[1] == 0x50) {
        format = 'png';
      }
    }
    selectedImagyoBecomeAhostbase64 = "data:image/$format;base64,$base64Image";
  }

  sendrequesttobecomeHost(
    BuildContext context,
    String countryCode,
    GlobalKey<FormState> formKey,
    isChecked,
  ) async {
    if (formKey.currentState!.validate() && (isChecked == true)) {
      showLoading();
      Map<String, String> postData = {
        "host_status": "2",
        "first_name": becomeLeadFirstName.text,
        "last_name": becomeLeadLastname.text,
        "company_name": companyName.text.isEmpty ? "" : companyName.text,
        "email": becomeLeadEmail.text,
        "phone": becomeLeadPhoneNumber.text,
        "country_code": countryCode,
        "residency_type": selectLegalForm,
        "full_address": becomeLeadFulladdress.text,
        "identity_type": selectIdentityType,
        "identity_image": selectedImagyoBecomeAhostbase64,
      };
      try {
        var requestToBecomeHost =
            await httpPost(Config.putHostRequest, postData);
        if (requestToBecomeHost != null &&
            requestToBecomeHost["status"] == 200) {
          closeLoading();
          showToastMessage(requestToBecomeHost["message"]);
          Get.back();
        } else {
          closeLoading();
          showErrorToastMessage(requestToBecomeHost["error"]);
          Get.back();
        }
      } catch (e) {
        closeLoading();
        Get.back();
      }
    }
  }

  // Fonction pour changer de rôle (user <-> vendor)
  Future<void> switchRole(BuildContext context) async {
    if (token.isEmpty) {
      loginAlert(context);
      return;
    }

    // Vérifier si l'utilisateur est déjà un vendor/host
    final userRoleValue = userRole.value.toLowerCase().trim();
    bool isAlreadyVendor = userRoleValue == 'vendor' || userRoleValue == 'host';

    print('🔄 [SWITCH_ROLE] Rôle utilisateur: $userRoleValue');
    print('🔄 [SWITCH_ROLE] Est déjà vendor: $isAlreadyVendor');
    print('🔄 [SWITCH_ROLE] isHostMode actuel: ${this.isHostMode.value}');

    // Si l'utilisateur est déjà un vendor, on ne fait pas d'appel API
    // On change simplement la variable locale isHostMode
    if (isAlreadyVendor) {
      print('✅ [SWITCH_ROLE] Utilisateur déjà vendor - Changement local uniquement');
      
      // Inverser isHostMode
      this.isHostMode.value = !this.isHostMode.value;
      
      // Synchroniser avec la variable globale et le stockage
      GetStorage().write('isHostMode', this.isHostMode.value);
      
      // Synchroniser avec la variable globale isHostMode (accessible via work_space.dart)
      // Note: La variable globale est importée via work_space.dart qui importe custom_active_module_id_widget.dart
      // La variable globale isHostMode est déjà synchronisée car elle est réactive
      
      print('🔄 [SWITCH_ROLE] Nouveau isHostMode: ${this.isHostMode.value}');
      
      // Naviguer vers le dashboard host si on passe en mode host
      if (this.isHostMode.value) {
        if (webPlateForm) {
          Get.offAllNamed(WebRoutes.buttomHost);
        } else {
          Get.offAll(() => const BottomHost(initialIndex: 0));
        }
        print('✅ [SWITCH_ROLE] Navigation vers dashboard host');
      } else {
        // Naviguer vers le dashboard user si on sort du mode host
        if (webPlateForm) {
          Get.offAllNamed(WebRoutes.homeMain);
        } else {
          Get.offAll(() => const HomeMain(initialIndex: 0));
        }
        print('✅ [SWITCH_ROLE] Navigation vers dashboard user');
      }
      
      showToastMessage('Mode changé avec succès'.tr);
      return;
    }

    // Si l'utilisateur n'est pas encore vendor, faire l'appel API pour devenir vendor
    // Déterminer le rôle actuel basé sur isHostMode
    String currentRole = this.isHostMode.value ? 'vendor' : 'user';
    String newRole = currentRole == 'vendor' ? 'user' : 'vendor';

    print('🔄 [SWITCH_ROLE] Rôle actuel: $currentRole');
    print('🔄 [SWITCH_ROLE] Nouveau rôle: $newRole');

    showLoading();
    try {
      // Appel API pour mettre à jour le rôle dans la base de données
      // Note: Vous devrez créer cet endpoint 'switch-role' dans votre backend Node.js
      var response = await httpPost(Config.switchRole, {
        'role': newRole,
      });

      closeLoading();

      if (response != null && response['status'] == 200) {
        // Mettre à jour isHostMode localement et globalement
        bool newHostMode = newRole == 'vendor';
        this.isHostMode.value = newHostMode;
        GetStorage().write('isHostMode', newHostMode);
        // Synchroniser avec la variable globale isHostMode (accessible via work_space.dart)
        // Note: La variable globale est importée via work_space.dart qui importe custom_active_module_id_widget.dart

        // Mettre à jour le loginModel si nécessaire
        if (loginModel != null && response['data'] != null) {
          // Optionnel: mettre à jour le modèle avec les nouvelles données
          loginModel = LoginModel.fromJson(response);
          
          // Sauvegarder TOUT l'objet dans 'user_data' pour inclure le rôle
          GetStorage().write('user_data', jsonEncode(response));
          print('💾 [SWITCH_ROLE] Données sauvegardées dans user_data');
          
          UserData userObj = UserData();
          userObj.saveLoginData("UserData", jsonEncode(response));
        }

        showToastMessage(response['message'] ?? 'Rôle changé avec succès'.tr);

        // Rediriger vers le bon dashboard
        if (newHostMode) {
          if (webPlateForm) {
            Get.offAllNamed(WebRoutes.buttomHost);
          } else {
            Get.offAll(() => const BottomHost(initialIndex: 0));
          }
        } else {
          if (webPlateForm) {
            Get.offAllNamed(WebRoutes.homeMain);
          } else {
            Get.offAll(() => const HomeMain(initialIndex: 0));
          }
        }
      } else {
        showErrorToastMessage(response?['error'] ?? 'Erreur lors du changement de rôle'.tr);
      }
    } catch (e) {
      closeLoading();
      print('❌ [SWITCH_ROLE] Erreur: $e');
      // En cas d'erreur API, utiliser la logique locale existante
      // (fallback si l'endpoint n'existe pas encore)
      bool newHostMode = newRole == 'vendor';
      this.isHostMode.value = newHostMode;
      GetStorage().write('isHostMode', newHostMode);
      showToastMessage('Mode changé avec succès'.tr);
      
      // Naviguer vers le bon dashboard
      if (newHostMode) {
        if (webPlateForm) {
          Get.offAllNamed(WebRoutes.buttomHost);
        } else {
          Get.offAll(() => const BottomHost(initialIndex: 0));
        }
      } else {
        if (webPlateForm) {
          Get.offAllNamed(WebRoutes.homeMain);
        } else {
          Get.offAll(() => const HomeMain(initialIndex: 0));
        }
      }
    }
  }
}
