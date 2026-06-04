class Config {
  static const googleKey = "AIzaSyCnn79a9P4jSVI2OoUBMTyfQDXWerEdGqs";
  //static const googleKey = "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";
  static const String oneSiginalAppid = '849877b4-f438-495e-8ccd-62f016aaa09c';
  //static const String oneSiginalApiKey ='os_v2_app_qsmhpnhuhbev5dgnmlybnkvatqcckvlx27yei5nl2dsodym3ogtcporczydtoahqxfhab6qixogr2o4qtl5p7vttac56wlbr2j43kqa';
  // ========== OLD LARAVEL BACKEND (COMMENTED) ==========
//static const String baseurl = 'https://admin.carvy.tech/api/v1/';
  //static const String baseurlForBearer = 'https://admin.carvy.tech/api/';

  // ========== NEW NODE.JS BACKEND (LOCAL DEVELOPMENT) ==========
  //static const String baseurl = 'http://10.0.2.2:5000/api/v1/';
  //static const String baseurlForBearer = 'http://10.0.2.2:5000/api/v1/';
  //static const String baseurl = 'https://carvy.tech/api/v1/';
  //static const String baseurlForBearer = 'https://carvy.tech/api/v1/';
  static const String baseurl = 'https://carvy.tech/api/v1/';
  static const String baseurlForBearer = 'https://carvy.tech/api/v1/';
  // URL de base sans /v1 pour les routes admin (upload, vehicles, etc.)
  static String get baseUrlWithoutV1 => baseurl.replaceAll('/api/v1/', '/api/');
  static const String bookingImageBaseUrl = 'https://carvy.tech/uploads/bookings/';
  //static const String baseurl = 'https://admin.carvy.tech/api/v1/';
  //static const String baseurl = 'https://admin.carvy.tech/api/v1/';

  // Apparemment tu utilises ça pour les tokens ou les images ?
  //static const String baseurlForBearer = 'https://carvy.tech/api/v1/';
  //atic const String baseurlForBearer = 'https://admin.carvy.tech/api/v1/';
  //static const String baseurlForBearer = 'https://carvy.tech/api/v1/';

  static const String secretKey = '49382716504938271650493827165049';
  static const String registerUser = 'userRegister';
  static const String verifyEmailOtp = 'auth/verify-email-otp';
  static const String resendEmailOtp = 'auth/resend-email-otp';
  static const String requestPhoneOtp = 'auth/request-phone-otp';
  static const String verifyPhoneOtp = 'auth/verify-phone-otp';
  static const String socialLogin = 'social-login';
  static const String verifyResetToken = 'verify-reset-token';
  static const String featuredItems = 'featuredItems';
  static const String userEmailLogin = 'user-email-login';
  static const String forgotPassword = 'forgot-password';
  static const String resetPassword = 'reset-password';
  static const String otpVerification = 'otp-verification';
  static const String resendOtp = 'resend-otp';
  static const String resendToken = 'resend-token';
  static const String homeDataApi = 'vehicles/home-data';
  static const String getItemRules = 'get-item-rules';
  static const String getItemDetails = 'getItemDetails';
  static const String yourLocation = 'your-locations';
  static const String checkBookingAvailability = 'check-booking-availability';
  static const String itemBookingDate = 'itemBookingDate';
  static const String addtowishlist = 'add-to-wishlist';
  static const String getWishlist = 'get-wishlist';
  static const String removeToWishlist = 'remove-from-wishlist';
  static const String checkCouponCode = 'CheckCoupon';
  static const String bookItem = 'book-item';
  static const String getgeneralSettings = 'get-general-settings';
  static const String bookingpaymentsuccess = 'booking-payment-success';
  static const String getItemsByLocation = 'getItemsByLocation';
  static const String amenities = 'amenities';
  static const String itemsType = 'get-all-categories';
  // 1. Mise à jour de l'URL : change makeType pour qu'il pointe vers : vehicle-reference/makes
  static const String makeType = 'vehicle-reference/makes';
  
  // ========== VEHICLE REFERENCE ROUTES (Node.js Backend) - Routes publiques ==========
  // Utiliser baseurlForBearer sans /v1 pour les routes admin
  static String get adminBaseUrl => baseurlForBearer.replaceAll('/api/v1/', '/api/');
  static const String vehicleReferenceMakes = 'vehicle-reference/makes';
  static const String vehicleReferenceModels = 'vehicle-reference/models';
  static const String vehicleReferenceFuelTypes = 'vehicle-reference/fuel-types';
  static const String vehicleReferenceTypes = 'vehicle-reference/types';
  static const String vehicleReferenceOdometers = 'vehicle-reference/odometers';
  static const String vehicleReferenceRegions = 'vehicle-reference/regions';
  static const String vehicleReferenceLocations = 'vehicle-reference/locations';
  static const String vehicleReferenceFeatures = 'vehicle-reference/features';
  static const String vehicleReferenceCancellationPolicies = 'vehicle-reference/cancellation-policies';
  static const String vehicleReferenceRules = 'vehicle-reference/rules';
  static const String itemSearch = 'item-search';
  static const String staticPage = 'static-page';
  static const String getmessages = 'getmessages';
  static const String conversations = 'conversations';
  static const String upcommingRecord = 'booking-record';
  static const String vendorbookingRecord = 'vendor-booking-record';
  static const String editProfile = 'edit-profile';
  static const String uploadProfileImage = 'upload-profile-image';
  static const String searchCities = 'searchCities';
  static const String bedTypes = 'bedTypes';
  static const String myItems = 'my-items';
  static const String hostDashBoard = 'get-vendor-dashboard-record';
  static const String insertItem = 'insert-item';
  static const String editItem = 'edit-item';
  static const String getCancellationPolicies = 'get-cancellation-policies';
  static const String deleteItem = 'deleteItem';
  static const String requestDeletion = 'request-deletion';
  static const String getCancelReasons = 'get-cancel-reasons';
  static const String cancelBookingByUser = 'cancel-booking-by-user';
  static const String cancelBookingByHost = 'cancel-booking-by-host';
  static const String confirmBookingByHost = 'confirm-booking-by-host';
  static const String contactUs = 'contactUs';
  static const String getUserThreads = 'getUserThreads';
  static const String createSupportTicket = 'createSupportTicket';
  static const String replyToSupportTicket = 'replyToSupportTicket';
  static const String getReplyThreads = 'getReplyThreads';
  static const String giveReviewByUser = 'give-review-by-user';
  static const String giveReviewByHost = 'give-review-by-host';
  static const String latestmessage = 'latestmessage';
  static const String checkMobileNumber = 'check-mobile-number';
  static const String changeMobileNumber = 'change-mobile-number';
  static const String getItemPrices = 'get-item-prices';
  static const String getUserWallet = 'get-user-wallet';
  static const String updatePassword = 'update-password';
  // Legacy alias kept for old call-sites; routed to the unified endpoint.
  static const String fcmUpdate = 'update-onesignal-id';
  static const String updateOneSignalId = 'update-onesignal-id';
  static const String getItemReviews = 'get-item-reviews';
  static const String closeSupportTicket = 'closeSupportTicket';
  static const String deleteAccount = 'deleteAccount';
  static const String getVendorWallet = 'get-vendor-wallet';
  static const String getVendorWalletTransactions =
      'get-vendor-wallet-transactions';
  static const String getPayoutTransactions = 'get-payout-transactions';
  static const String insertPayout = 'insert-payout';
  static const String getUserWalletTransactions = 'getUserWalletTransactions';
  static const String getUserProfile = 'get-user-profile';
  static const String getVendorItemReviews = 'get-vendor-item-reviews';
  static const String getUseritems = 'get-user-items';
  static const String insertBankAccount = 'insert-bank-account';
  static const String getBankAccount = 'get-bank-account';
  static const String checkEmail = 'check-email';
  static const String changeEmail = 'change-email';
  static const String requestEmailChangeOtp = 'request-email-change-otp';
  static const String emailSmsNotification = 'emailSmsNotification';
  static const String addEditItemImage = 'add-update-item-image';
  static const String addEditCalender = 'add-editCalender';
  static const String getMakesModel = 'get-makes-model';
  static const String vechileOdometer = 'vechile-odometer';
  static const String odometerModelYear = 'odometerModelYear';
  static const String odometermannual = 'odometer-manual';
  static const String getItemDates = 'get-item-dates';
  static const String nearbyItems = 'nearbyItems';
  static const String getHostStatus = 'get-host-status';
  static const String putHostRequest = 'put-host-request';
  static const String switchRole = 'switch-role';
  static const String getCurrencyDetails = 'getCurrencyDetails';
  static const String updateItemDeliveredStatus =
      'update-item-delivered-status';
  static const String updateItemReceivedStatus = 'update-item-received-status';
  static const String updateItemReturnedStatus = 'update-item-returned-status';
  static const String markBookingReturnedDirect =
      'mark-booking-returned-direct';
  static const String submitReview = 'submit-review';
  static const String vendorReviews = 'vendor-reviews';
  static const String fuelType = 'get-vehicle-fuel-types';
  static const String saveDoorStepAddress = 'save-door-step-address';
  static const String getDoorStepAddress = 'get-door-step-address';
  static const String getKYCDetails = 'get-kyc-details';
  static const String addKycforCustomer = 'add-kyc-for-customer';
  static const String getVendorEarings = 'get-vendor-earings';
  static const String getPayoutType = 'get-payout-types';
  static const String getPayoutMethod = 'get-payout-methods';
  static const String addPaymentMethod = 'update-payout-method';
  static const String addInteriorImage = 'add-interior-image';
  static const String generateToken = 'generate-token';
  static const String uploadSignature = 'upload-digital-signature';
  static const String getDigitalSingnature = 'get-digital-signature';
  static const String getPaymentMethods = 'payment-methods';
  static const String uploadImages = 'upload/images';
  static const String uploadDocuments = 'upload/documents';

  /// Chat admin (`httpGetAdmin` : [adminBaseUrl] + path → `.../api/chat/...`).
  static const String chatInboxPath = 'chat/inbox';

  static String chatHistoryPath(String historyId) =>
      'chat/history/${Uri.encodeComponent(historyId)}';

  /// Résolution conversation (Mongo) à partir d’un `bookingId` — Node `GET .../api/chat/...`.
  /// Si l’endpoint n’existe pas encore, l’appel échoue silencieusement et on garde le fallback booking.
  static String chatConversationForBookingPath(String bookingId) =>
      'chat/conversation-for-booking/${Uri.encodeComponent(bookingId)}';

  /// POST multipart champ `file` — URL : [baseUrlWithoutV1] + [uploadApi].
  static const String uploadApi = 'upload';

  /// POST multipart champ `avatar` — URL : [baseUrlWithoutV1] + [uploadAvatar].
  static const String uploadAvatar = 'user/avatar';

  static const String submitVehicle = 'vehicles';
  /// Brouillon wizard ajout véhicule — GET/POST/DELETE `${baseUrlWithoutV1}` + cette clé.
  static const String vehicleDraft = 'vehicles/draft';
  static const String myVehicles = 'vehicles/owner';
  static const String getVehicleDetails = 'vehicles'; // GET /api/v1/vehicles/:id
  
  /// Construit une URL complète pour une image à partir d'un chemin éventuellement relatif.
  /// - Retourne une chaîne vide si `imagePath` est nul ou vide.
  /// - Si `imagePath` est déjà une URL complète (http/https), elle est renvoyée telle quelle.
  /// - Sinon, on la concatène avec le domaine de base dérivé de `baseurl`.
  static String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }

    // Si l'URL est déjà complète, on la retourne telle quelle
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    // Extraire le domaine de base à partir de `baseurl`
    // ex: https://carvy.tech/api/v1/ -> https://carvy.tech
    final String baseDomain =
        baseurl.replaceAll('/api/v1/', '').replaceAll('/api/', '');

    // Normaliser le chemin pour éviter les doubles slashs
    String normalizedPath = imagePath;
    if (normalizedPath.startsWith('/')) {
      normalizedPath = normalizedPath.substring(1);
    }

    return '$baseDomain/$normalizedPath';
  }
}
