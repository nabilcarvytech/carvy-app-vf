import 'package:get/get.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/view/auth/email_update_screen.dart';
import 'package:carvy/view/auth/forget_password_screen.dart';
import 'package:carvy/view/auth/google_update_screen.dart';
import 'package:carvy/view/auth/login_screen.dart';
import 'package:carvy/view/auth/otp_screen.dart';
import 'package:carvy/view/auth/phone_update_screen.dart';
import 'package:carvy/view/auth/sign_up_screen.dart';
import 'package:carvy/view/auth/success_change_password.dart';
import 'package:carvy/view/auth/user_google_sign_up_screen.dart';
import 'package:carvy/view/auth/agency_registration_screen.dart';
import 'package:carvy/view/auth/agency_registration_pending_screen.dart';
import 'package:carvy/view/auth/agency_sign_up_screen.dart';
import 'package:carvy/view/home/client_home_screen.dart';
import 'package:carvy/view/booking/my_booking_screen.dart';
import 'package:carvy/view/booking/booking_success_page.dart';
import 'package:carvy/view/booking/e_reciept.dart';
import 'package:carvy/view/booking/payment_screen.dart';
import 'package:carvy/view/booking/vehicle/vehicle_booking_summary_screen.dart';
import 'package:carvy/view/home/top_categories.dart';
import 'package:carvy/view/host/bottom_bar_host.dart';
import 'package:carvy/view/host/hostsearch/host_search_screen.dart';
import 'package:carvy/view/host/orders/orders_screen.dart';
import 'package:carvy/view/host/wallet/bank_account_host.dart';
import 'package:carvy/view/host/wallet/host_wallet.dart';
import 'package:carvy/view/itemdetail/vehicle/reviews/item_review_screen.dart';
import 'package:carvy/view/itemdetail/vehicle/vehicle_check_availability_screen.dart';
import 'package:carvy/view/itemdetail/vehicle/view_on_map_screen.dart';
import 'package:carvy/view/myaccount/change_currency_screen.dart';
import 'package:carvy/view/myaccount/change_password_screen.dart';
import 'package:carvy/view/myaccount/my_profile_screen.dart';
import 'package:carvy/view/myaccount/publicProfile/public_profile_review_screen.dart';
import 'package:carvy/view/myaccount/static_page_screen.dart';
import 'package:carvy/view/myaccount/account_screen.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import 'package:carvy/view/onBoarding/vehicle/vehicle_on_boarding_screen.dart';
import 'package:carvy/view/payments/wallet_screen.dart';
import 'package:carvy/view/search/after_search.dart';
import 'package:carvy/view/splash/initial_screen.dart';
import 'package:carvy/view/splash/language_selection_screen.dart';
import 'package:carvy/view/splash/user_role_selection_screen.dart';
import '../view/auth/reset_password_screen.dart';
import '../view/itemdetail/vehicle/vehicle_detail_screen.dart';
import '../view/myaccount/publicProfile/public_profile_screen.dart';
import '../view/myaccount/setting_screen.dart';
import '../view/home/location_screen.dart';
import '../view/home/recommendation_screen.dart';
import '../view/myaccount/ticket/ticket_create_screen.dart';
import '../view/myaccount/ticket/ticket_first_screen.dart';
import '../view/search/search_screen.dart';

class WebRoutes {
  static String initial = "/";
  static String loginScreen = "/loginScreen";
  static String otpScreen = "/otpScreen";
  static String signUpScreen = "/signUpScreen";
  static String homeMain = "/HomeMain";
  static String changePasswordScreen = "/changePasswordScreen";
  static String forgetPasswordScreen = "/forgetPasswordScreen";
  static String googleUpdateScreen = "/googleUpdateScreen";
  static String phoneUpdateScreen = "/phoneUpdateScreen";
  static String userGoogleSignUpScreen = "/userGoogleSignUpScreen";
  static String bottomBarScreen = "/BottomBarScreen";
  static String myBooking = "/MyBooking";
  static String settingScreen = "/SettingScreen";
  static String yourReview = "/YourReview";
  static String conversationScreen = "/conversationScreen";
  static String recommendationScreen = "/RecommendationScreen";
  static String checkavailabilityScreen = "/CheckAvailability";
  static String walletScreen = "/WalletScreen";
  static String ticketCreateScreen = "/TicketCreateScreen";
  static String ticketReplyScreen = "/TicketReplyScreen";
  static String ticketFirstScreen = "/TicketFirstScreen";
  static String serachScreen = "/SerachScreen";
  static String locationScreen = "/LocationScreen";
  static String publicProfile = "/PublicProfile";
  static String deleteConfirmationDialog = "/DeleteConfirmationDialog";
  static String emailUpdateScreen = "/emailUpdateScreen";
  static String filterScreen = "/filterScreen";
  static String accountScreen = "/AccountScreen";
  static String privacyPolicyScreen = "/privacyPolicyScreen";
  static String aboutUsScreen = "/aboutUsScreen";
  static String giveUsFeedback = "/giveUsFeedback";
  static String getHelpScreen = "/getHelpScreen";
  static String resetPasswordScreen = "/resetPasswordScreen";
  static String vehicleDetailScreen = "/VehicleDetailSScreen";
  static String vehicleOnboardingScreen = "/vehicleOnboardingScreen";
  static String buttomHost = "/buttomHost";
  static String myprofile = "/myprofile";
  static String successChangeScreen = "/successChangeScreen";
  static String getItemDetails = "/getItemDetails";
  static String topCategory = "/topCategory";
  static String subCategory = "/subCategory";
  static String afterSearch = "/afterSearch";
  static String viewOnMapScreen = "/viewOnMapScreen";
  static String reviewScreen = "/reviewScreen";
  static String fullMapScreen = "/fullMapScreen";
  static String vehicleCheckAvailability = "/vehicleCheckAvailability";
  static String vehicleBookingSummaryScreen = "/vehicleBookingSummaryScreen";
  static String paymentScreen = "/paymentScreen";
  static String paymentSuccessScreen = "/paymentSuccessScreen";
  static String publicProfileReviewScreen = "/publicProfileReviewScreen";
  static String customerEreciept = "/customerEreciept";
  static String orderScreen = "/orderScreen";
  static String hostWallet = "/hostWallet";
  static String addbanckAccount = "/addbanckAccount";
  static String staticPages = "/staticPages";
  static String changeCurrency = "/changeCurrency";
  static String hostSearch = "/hostSearch";
  static String languageSelectionScreen = "/languageSelectionScreen";
  static String userRoleSelectionScreen = "/userRoleSelectionScreen";
  static String agencyRegistrationScreen = "/agencyRegistrationScreen";
  static String agencySignUpScreen = "/agencySignUpScreen";
  static String agencyRegistrationPendingScreen = "/agencyRegistrationPendingScreen";
  static String clientHomeScreen = "/clientHomeScreen";
}

final getPagesforweb = [
  GetPage(name: WebRoutes.initial, page: () => const InitialScreen()),
  GetPage(
      name: WebRoutes.languageSelectionScreen,
      page: () => const LanguageSelectionScreen()),
  GetPage(
      name: WebRoutes.userRoleSelectionScreen,
      page: () => const UserRoleSelectionScreen()),
  GetPage(
      name: WebRoutes.agencyRegistrationScreen,
      page: () => const AgencyRegistrationScreen()),
  GetPage(
      name: WebRoutes.agencySignUpScreen,
      page: () => const AgencySignUpScreen()),
  GetPage(
      name: WebRoutes.agencyRegistrationPendingScreen,
      page: () => const AgencyRegistrationPendingScreen()),
  GetPage(
      name: WebRoutes.clientHomeScreen,
      page: () => const ClientHomeScreen()),
  GetPage(name: WebRoutes.signUpScreen, page: () => const SignUp()),
  GetPage(
      name: WebRoutes.homeMain, page: () => const HomeMain(initialIndex: 0)),
  GetPage(name: WebRoutes.loginScreen, page: () => const LoginScreen()),
  GetPage(
      name: WebRoutes.phoneUpdateScreen, page: () => const PhoneUpdateScreen()),
  GetPage(
      name: WebRoutes.userGoogleSignUpScreen,
      page: () => const UserGoogleSignUpScreen()),
  GetPage(name: WebRoutes.otpScreen, page: () => const OtpScreen()),
  GetPage(
      name: WebRoutes.resetPasswordScreen,
      page: () => const ResetPasswordScreen()),
  GetPage(
      name: WebRoutes.changePasswordScreen,
      page: () => const ChangePasswordScreen()),
  GetPage(name: WebRoutes.googleUpdateScreen, page: () => const GoogleUpdate()),
  GetPage(
      name: WebRoutes.forgetPasswordScreen, page: () => const ForgetPassword()),
  GetPage(
      name: WebRoutes.myBooking,
      page: () => MyBooking(
            fromPropBooking: false,
          )),
  GetPage(name: WebRoutes.settingScreen, page: () => const SettingScreen()),
  GetPage(name: WebRoutes.yourReview, page: () => const YourReview()),
  GetPage(name: WebRoutes.walletScreen, page: () => const WalletScreen()),
  GetPage(
      name: WebRoutes.recommendationScreen, page: () => RecommendationScreen()),
  GetPage(
      name: WebRoutes.ticketCreateScreen,
      page: () => const TicketCreateScreen()),
  GetPage(
      name: WebRoutes.ticketFirstScreen, page: () => const TicketFirstScreen()),
  GetPage(name: WebRoutes.locationScreen, page: () => const LocationScreen()),
  GetPage(name: WebRoutes.publicProfile, page: () => const PublicProfile()),
  GetPage(
      name: WebRoutes.deleteConfirmationDialog,
      page: () => const DeleteConfirmationDialogs()),
  GetPage(
      name: WebRoutes.emailUpdateScreen, page: () => const EmailUpdateScreen()),
  GetPage(name: WebRoutes.accountScreen, page: () => const AccountScreen()),
  GetPage(
      name: WebRoutes.giveUsFeedback,
      page: () => StaticPage(data: "Give Us Feedback".tr)),
  GetPage(
      name: WebRoutes.privacyPolicyScreen,
      page: () =>
          StaticPage(data: "Terms of Service for Users & Privacy Policy".tr)),
  GetPage(
      name: WebRoutes.aboutUsScreen,
      page: () => StaticPage(data: "About Us".tr)),
  GetPage(
      name: WebRoutes.getHelpScreen,
      page: () => StaticPage(data: "Get Help".tr)),
  GetPage(name: WebRoutes.myprofile, page: () => const MyProfile()),
  GetPage(
      name: WebRoutes.successChangeScreen,
      page: () => const SuccessChangePassword()),
  GetPage(
      name: WebRoutes.vehicleOnboardingScreen,
      page: () => const VehicleOnBoardingScreen()),
  GetPage(
      name: WebRoutes.buttomHost,
      page: () => const BottomHost(
            initialIndex: 0,
          )),
  GetPage(name: WebRoutes.getItemDetails, page: () => VehicleDetailSScreen()),
  GetPage(name: WebRoutes.topCategory, page: () => const TopCategories()),
  GetPage(name: WebRoutes.afterSearch, page: () => AfterSearch()),
  GetPage(name: WebRoutes.viewOnMapScreen, page: () => const ViewOnMapScreen()),
  GetPage(name: WebRoutes.reviewScreen, page: () => const YourReview()),
  GetPage(name: WebRoutes.fullMapScreen, page: () => const FullMapScreen()),
  GetPage(
      name: WebRoutes.vehicleCheckAvailability,
      page: () => const VehicleCheckAvailability()),
  GetPage(
      name: WebRoutes.vehicleBookingSummaryScreen,
      page: () => const VehicleBookingSummary()),
  GetPage(name: WebRoutes.paymentScreen, page: () => const PaymentScreen()),
  GetPage(
      name: WebRoutes.paymentSuccessScreen,
      page: () => const BookingSuccessPage()),
  GetPage(
      name: WebRoutes.publicProfileReviewScreen,
      page: () => const PublicProfileReviewScreen()),
  GetPage(name: WebRoutes.customerEreciept, page: () => const EReceiptScreen()),
  GetPage(name: WebRoutes.orderScreen, page: () => const OrdersScreen()),
  GetPage(name: WebRoutes.hostWallet, page: () => const HostWallet()),
  GetPage(
      name: WebRoutes.addbanckAccount,
      page: () => const AddBankAccountScreen()),
  GetPage(
      name: WebRoutes.staticPages,
      page: () => StaticPage(data: "Terms of Service for Vehicle Owner".tr)),
  GetPage(name: WebRoutes.changeCurrency, page: () => const ChangeCurrency()),
  GetPage(name: WebRoutes.hostSearch, page: () => const HostSearchScreen()),
];
