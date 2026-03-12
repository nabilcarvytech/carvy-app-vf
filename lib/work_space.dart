import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/controller/add_address_controller.dart';
import 'package:carvy/controller/add_bank_account_controller.dart';
import 'package:carvy/controller/auth_controller.dart';
import 'package:carvy/controller/profile_controller.dart';
import 'package:carvy/controller/push_notifications.dart';
import 'package:carvy/controller/search_controller.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/view/auth/google_update_screen.dart';
import 'package:carvy/view/auth/login_screen.dart';
import 'controller/general_controller.dart';
import 'controller/global_scope_controller.dart';
import 'package:carvy/model/my_items_model.dart';
import 'customwidget/custom_active_module_id_widget.dart';
import 'customwidget/project_color.dart';
import 'model/login_model.dart';

var webPlateForm = kIsWeb;
bool checkUpdateStep1 = false;
bool handleBoackfromPayment = false;
bool handleDirectBooking = false;
bool checkUpdateStep2 = false;
bool connectionLost = false;
bool openOtpAfterImageSubmit = false;
bool otpSheetOpened = false;
bool bookingAgrinmentVendor = false;
bool bookingAgrinmentVendor2 = false;
bool handleSearchFordetail = false;
bool bookingAgrinmentuser = false;
bool bookingAgrinmentUser2 = false;
AddAddressController addAddressController = Get.find();
String currency = "";
String? paymentStatus = "";
Locale? globallanguage;
// ValueNotifier pour forcer la reconstruction de l'application quand la langue change
final ValueNotifier<Locale> localeNotifier =
    ValueNotifier<Locale>(const Locale('en', 'US'));
dynamic maxPriceRange;
dynamic minPricerange;
dynamic showerrorWhenloginwithOtherDevice = "";
int currentTabIndexforLocation = 0;

enum ScreenMode { add, edit }

bool darkMode = GetStorage().read("getDarkValue") ?? false;
String bearerToken = GetStorage().read("bearerToken") ?? "";

enum EditOptions { op1, op2, op3 }

SearchControllerHome filterController = Get.find();
setdefultData() {
  addAddressController.preventDate.value = true;
  late SearchControllerHome searchController = Get.find();
  bookingController.selectedStartTime.value =
      searchController.startTimeSearch.value;
  bookingController.selectedEndTime.value =
      searchController.endTimeSearch.value;
  bookingController.startDate.value =
      generalScopeController.startDateCustomDate.value;
  bookingController.endDate.value =
      generalScopeController.endDateCustomDate.value;
  DateTime parsedStart =
      DateFormat('yyyy-MM-dd').parse(bookingController.startDate.value);
  DateTime parsedEnd =
      DateFormat('yyyy-MM-dd').parse(bookingController.endDate.value);
  bookingController.dateRangePickerController.selectedRange =
      PickerDateRange(parsedStart, parsedEnd);
}

bool handlelogin = false;
dynamic showhideItemType = "";
dynamic showHidePopularRegion = "";
dynamic showHideNrarYou = "";
dynamic showHideMake = "";
dynamic showHideMustView = "";
dynamic showHideBecomeHost = "";
dynamic showhidedistance = "";
dynamic digitalsingnature = "";
dynamic internalVehicleImage = "";
dynamic kycenable = "";
dynamic checkItemPiblicationLimit = "";
String? slatsearch = "";
String? sLongSearch = "";
String token = "";
dynamic oneSiginalplayerid = GetStorage().read('oneSiginalplayerid') ?? "";
dynamic userId = GetStorage().read('userIdGlobal') ?? "";
String deviceTokenForNotifications = "";
LoginModel? loginModel;
String latitudeGlobal = GetStorage().read('latitudeGlobal') ?? "";
String longitudeGlobal = GetStorage().read('longitudeGlobal') ?? "";
String? identityBase64;
Items? item;
Items? initialitems;
GeneralController generalController = Get.find();
GlobalScopeController generalScopeController = Get.find();
Map<String, dynamic> itemInfoDetails = {};
Map<String, dynamic> bookingMetaList = {};
bool isInboxOpen = false;
bool isChatOpen = false;
bool handleBackonBooking = false;
bool handleLoginBack = false;
final List locale = [
  {'name': 'English', 'locale': const Locale('en', 'US')},
  {'name': 'Spanish', 'locale': const Locale('es', 'ES')},
  {'name': 'French', 'locale': const Locale('fr', 'FR')},
  // {'name': 'Thailand', 'locale': const Locale('th', 'TH')},
  {'name': 'Arabic', 'locale': const Locale('ar', 'AR')}
];

updateLanguage(Locale locale) {
  Get.back();

  Get.updateLocale(locale);
}

extension StringExtension on String {
  String get capitalizeFirst {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

DateTime now = DateTime.now();
String timeZoneOffset = now.timeZoneOffset.toString();
final database = FirebaseDatabase.instance.ref().child("users");
String appName = "Carvy";
getUserDataLocallyToHandleTheState() async {
  AuthController authController = Get.find();
  authController.getUserLocation();
  if (await GetStorage().read("UserData") != null) {
    String data = await GetStorage().read("UserData");

    if (data.isNotEmpty) {
      try {
        var json = jsonDecode(data);
        loginModel = LoginModel.fromJson(json);
        
        // Mettre à jour le rôle dans AuthController
        authController.setLoginModel(loginModel!);

        if (loginModel!.data != null) {
          if (loginModel!.data!.token != null) {
            token = loginModel!.data!.token!;
          }
          if (loginModel!.data!.firstName != null) {
            profileController.myName.value = loginModel!.data!.firstName!;
          }
          if (loginModel!.data!.defaultCountry != null &&
              loginModel!.data!.defaultCountry.toString().isNotEmpty) {
            profileController.defaultCountry.value =
                loginModel!.data!.defaultCountry;
          }
          if (loginModel!.data!.phoneCountry != null) {
            profileController.selectedCountry.value =
                loginModel!.data!.phoneCountry!;
          }
          if (loginModel!.data!.phoneCountry != null) {
            profileController.selectedCountry.value =
                loginModel!.data!.phoneCountry!;
          }
          if (loginModel!.data!.birthdate != null) {
            profileController.textEditingProfileControllerDOB.text =
                loginModel!.data!.birthdate!;
          }
          if (loginModel!.data!.intro != null) {
            profileController.textEditingProfileControllerDescription.text =
                loginModel!.data!.intro!;
          }
          if (loginModel!.data!.langauge != null) {
            profileController.textEditingProfileControllerLangauge.text =
                loginModel!.data!.langauge!;
          }

          if (loginModel!.data!.id != null) {
            userId = loginModel!.data!.id!;
            GetStorage().write('userIdGlobal', userId);
            print(userId);
            database.child(userId.toString()).set({
              "userId": userId.toString(),
              "playerId": oneSiginalplayerid ?? "null",
            });
          }
          if (loginModel!.data!.profileImage != null &&
              loginModel!.data!.profileImage!['url'] != null) {
            profileController.myImage.value =
                loginModel!.data!.profileImage!['url'];
          }
          if (loginModel!.data!.token == null) {
            // Sécurisation : Vérifier que le contexte est disponible avant d'afficher le toast
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Get.context != null) {
                showErrorToastMessage("Token now found! login again".tr);
              }
            });
          } else if (loginModel!.data!.phone == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Get.context != null) {
                showErrorToastMessage("Complete Your Profile".tr);
                try {
                  Get.to(() => const GoogleUpdate());
                } catch (e) {
                  debugPrint('⚠️ [WORK_SPACE] Erreur lors de la navigation: $e');
                }
              }
            });
          }
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Get.context != null) {
              showErrorToastMessage("Token now found! login again".tr);
            }
          });
        }
      } catch (e) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.context != null) {
            showErrorToastMessage("Token now found! login again".tr);
          }
        });
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.context != null) {
          showErrorToastMessage("Token now found! login again".tr);
        }
      });
    }
  }
  // Sécurisation : Appeler getFCMToken de manière asynchrone sans bloquer
  // Utiliser un délai pour éviter les appels trop tôt au démarrage
  Future.delayed(const Duration(milliseconds: 500), () {
    try {
      getFCMToken();
    } catch (e) {
      debugPrint('⚠️ [WORK_SPACE] Erreur lors de l\'appel getFCMToken: $e');
      // Ne pas bloquer l'application si getFCMToken échoue
    }
  });
}

AddBankAccount addbankAccountController = Get.find();

Future logout() async {
  clearAllController();
  Get.offAll(() => const LoginScreen());
}

Future clearAllController() async {
  SearchControllerHome filterController = Get.find();
  AuthController authController = Get.find();
  ProfileController profileController = Get.find();
  AddBankAccount addbankAccountController = Get.find();
  filterController.globalItemType.value = '0';
  profileController.selectedCountry.value =
      profileController.selectedCountryReset.value;
  profileController.defaultCountry.value =
      profileController.defaultCountryReset.value;
  profileController.textEditingProfileControllerFirstName.clear();
  profileController.textEditingProfileControllerlastName.clear();
  profileController.textEditingProfileControllerPhoneNumber.clear();
  profileController.textEditingProfileControllerEmail.clear();
  profileController.textEditingProfileControllerDOB.clear();
  profileController.textEditingProfileControllerLangauge.clear();
  profileController.textEditingProfileControllerDescription.clear();
  profileController.textEditingProfileControllerPassword.clear();
  profileController.textEditingProfileControllerPhoneCountry.clear();
  profileController.textEditingProfileControllerCheckEmail.clear();
  profileController.textEditingPhoneUpdateController.clear();
  profileController.firetnameControllerSocialMedialogin.clear();
  profileController.lastnameControllerSocialMedialogin.clear();
  profileController.emailControllerSocialMedialogin.clear();
  authController.textEditingControllerEmail.clear();
  authController.textEditingControllerPass.clear();
  authController.textEditingSignUpControllerFirstName.clear();
  authController.textEditingSignUpControllerEmail.clear();
  authController.textEditingSignUpControllerPassword.clear();
  authController.textEditingSingUpControllerPhoneNumber.clear();
  authController.textEditingSingUpControllerlastName.clear();
  authController.textEditingSingUpControllerDOB.clear();
  authController.textEditingForgetPasswordControllerEmail.clear();
  authController.textEditingOtpController.clear();
  authController.textEditingControllerNewPassword.clear();
  authController.textEditingResetControllerNewPassword.clear();
  authController.textEditingResetControllerConfirmPassword.clear();
  authController.textEditingControllerConfirmPassword.clear();
  authController.textEditingControllerOldPassword.clear();
  authController.becomeLeadFirstName.clear();
  authController.becomeLeadLastname.clear();
  authController.becomeLeadEmail.clear();
  authController.becomeLeadPhoneNumber.clear();
  authController.becomeLeadFulladdress.clear();
  authController.companyName.clear();
  authController.selectedImag = "".obs;
  authController.selectedImagyoBecomeAhostbase64 = '';
  authController.selectlettobecomeHost = "";
  authController.selectlongTibecomeHost = "";
  authController.selectLegalForm = "";
  authController.selectIdentityType = "";
  authController.identityimageforWeb = null;
  currency = "";
  profileController.myName.value = "";
  profileController.myImage.value = "";
  showhideItemType = "";
  showHidePopularRegion = "";
  showHideNrarYou = "";
  showHideMake = "";
  showHideMustView = "";
  showHideBecomeHost = "";
  bool defaultDarkMode = false;
  loginModel = null;

  // Sauvegarder la langue avant d'effacer
  var savedLanValue = GetStorage().read("lanValue");
  var savedLCode = GetStorage().read("lCode");

  GetStorage().write("getDarkValue", defaultDarkMode);
  notifires.setIsDark = defaultDarkMode;
  token = "";
  GetStorage().erase();

  // Restaurer la langue après l'effacement
  if (savedLanValue != null) {
    GetStorage().write("lanValue", savedLanValue);
  }
  if (savedLCode != null) {
    GetStorage().write("lCode", savedLCode);
  }

  // Mettre à jour la locale si elle était sauvegardée, sinon utiliser anglais
  if (savedLanValue != null &&
      savedLanValue is int &&
      savedLanValue >= 0 &&
      savedLanValue < locale.length) {
    Locale savedLocale = locale[savedLanValue]['locale'] as Locale;
    globallanguage = savedLocale;
    Get.updateLocale(savedLocale);
    localeNotifier.value = savedLocale;
  } else {
    Get.updateLocale(const Locale('en', 'US'));
  }

  isHostMode.value = false;
  GetStorage().write("lType", "en_US");
  activeModuleId.value = 2;
  generalScopeController.textEditingControllerCity.clear();
  await FirebaseAuth.instance.signOut();
  addbankAccountController.clearAccountPreviousData();
  generalController.currentIndex.value = 0;
  generalController.currentIndexHost.value = 0;
  addbankAccountController.clearAccountPreviousData();
  filterController.clearFilter();
}

void navigateToUrl({
  required String endpoint,
  required Map<String, String> queryParams,
  required Widget Function(String url) pageBuilder,
  bool showToastOnError = true,
}) {
  String dynamicBaseUrl = Config.baseurl.replaceAll("/api/v1/", "");

  String queryString = queryParams.entries
      .map((entry) =>
          "${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}")
      .join("&");

  String url = "$dynamicBaseUrl$endpoint?$queryString";

  if (queryParams.values.any((value) => value.isEmpty)) {
    if (showToastOnError) {
      showErrorToastMessage("Please provide all required parameters.".tr);
    }
  } else {
    Get.to(pageBuilder(url));
  }
}

String convertToLocaleDigits(String input) {
  final locale = Get.locale?.languageCode ?? 'en';

  if (locale.startsWith('ar')) {
    // works for ar, ar_SA, ar_AE...
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }

  return input;
}

String getMonthName(int month, {String locale = 'en'}) {
  const englishMonths = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  const arabicMonths = [
    "يناير",
    "فبراير",
    "مارس",
    "أبريل",
    "مايو",
    "يونيو",
    "يوليو",
    "أغسطس",
    "سبتمبر",
    "أكتوبر",
    "نوفمبر",
    "ديسمبر"
  ];

  if (locale.startsWith("ar")) {
    return arabicMonths[month - 1];
  }
  return englishMonths[month - 1];
}

class DateTimeFormatter {
  static String to24HourFormat(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '';

    try {
      final dateTime = DateFormat("dd-MM-yyyy hh:mm a").parse(dateTimeStr);
      final formattedDate = DateFormat("dd-MM-yyyy").format(dateTime);
      final formattedTime = DateFormat("HH:mm").format(dateTime);
      return "$formattedDate $formattedTime";
    } catch (e) {
      return dateTimeStr;
    }
  }
}

class TimeFormatter {
  static String to24Hour(String? time) {
    if (time == null || time.isEmpty) return '';
    try {
      final dateTime = DateFormat("hh:mm a").parse(time);
      return DateFormat("HH:mm").format(dateTime);
    } catch (e) {
      return time;
    }
  }
}

String getWeekdayName(int weekday, {String locale = 'en'}) {
  const englishWeekdays = [
    'Mon', // Monday
    'Tue', // Tuesday
    'Wed', // Wednesday
    'Thu', // Thursday
    'Fri', // Friday
    'Sat', // Saturday
    'Sun', // Sunday
  ];

  const arabicWeekdays = [
    'إثنين', // Monday (short for الإثنين)
    'ثلاثاء', // Tuesday (short for الثلاثاء)
    'أربعاء', // Wednesday (short for الأربعاء)
    'خميس', // Thursday (short for الخميس)
    'جمعة', // Friday (short for الجمعة)
    'سبت', // Saturday (short for السبت)
    'أحد', // Sunday (short for الأحد)
  ];

  if (locale.startsWith('ar')) {
    return arabicWeekdays[weekday - 1];
  }
  return englishWeekdays[weekday - 1];
}
