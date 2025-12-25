# API Inventory - Flutter App Migration Status

Ce document liste tous les appels HTTP dans l'application Flutter, classés par statut (MOCKED ou LIVE).

**Légende:**
- ✅ **MOCKED**: Appel HTTP commenté, remplacé par des données statiques
- 🔴 **LIVE**: Appel HTTP actif, nécessite une implémentation Node.js immédiate
- 🟡 **EXTERNAL**: Appel vers une API externe (Google Maps, etc.) - Ne nécessite pas de migration

---

## 📊 Résumé Global

| Statut | Nombre | Pourcentage |
| :--- | :--- | :--- |
| ✅ MOCKED | ~85 | ~70% |
| 🔴 LIVE | ~35 | ~30% |
| 🟡 EXTERNAL | ~5 | ~5% |

---

## 🔴 LIVE APIs (Nécessitent une implémentation Node.js immédiate)

### Authentication & User Management

| File Path | Endpoint Name | Status | Line Number | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `lib/controller/auth_controller.dart` | `Config.otpVerification` | 🔴 LIVE | 71 | Authentication - OTP Verification |
| `lib/controller/auth_controller.dart` | `Config.resendOtp` | 🔴 LIVE | 75 | Authentication - Resend OTP |
| `lib/controller/auth_controller.dart` | `Config.resendToken` | 🔴 LIVE | 79 | Authentication - Resend Token |
| `lib/controller/auth_controller.dart` | `Config.verifyResetToken` | 🔴 LIVE | 83 | Authentication - Verify Reset Token |
| `lib/controller/auth_controller.dart` | `Config.checkMobileNumber` | 🔴 LIVE | 88 | User Management - Check Mobile |
| `lib/controller/auth_controller.dart` | `Config.changeMobileNumber` | 🔴 LIVE | 97 | User Management - Change Mobile |
| `lib/controller/auth_controller.dart` | `Config.userEmailLogin` | 🔴 LIVE | 116 | Authentication - Email Login |
| `lib/controller/auth_controller.dart` | `Config.registerUser` | 🔴 LIVE | 197 | Authentication - User Registration |
| `lib/controller/auth_controller.dart` | `Config.forgotPassword` | 🔴 LIVE | 260 | Authentication - Forgot Password |
| `lib/controller/auth_controller.dart` | `Config.changeEmail` | 🔴 LIVE | 312 | User Management - Change Email |
| `lib/controller/auth_controller.dart` | `Config.resendTokenEmailChange` | 🔴 LIVE | 480 | User Management - Resend Email Token |
| `lib/controller/auth_controller.dart` | `Config.resetPassword` | 🔴 LIVE | 542 | Authentication - Reset Password |
| `lib/controller/auth_controller.dart` | `Config.updatePassword` | 🔴 LIVE | 579 | User Management - Update Password |
| `lib/controller/auth_controller.dart` | `Config.putHostRequest` | 🔴 LIVE | 904 | Host Management - Become Host Request |

### Social Login & Global Scope

| File Path | Endpoint Name | Status | Line Number | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `lib/controller/global_scope_controller.dart` | `Config.conversations` | 🔴 LIVE | 36 | Chat - Get Conversations |
| `lib/controller/global_scope_controller.dart` | `Config.latestmessage` | 🔴 LIVE | 45 | Chat - Get Latest Messages |
| `lib/controller/global_scope_controller.dart` | `Config.socialLogin` | 🔴 LIVE | 61 | Authentication - Social Login (Google/Facebook) |

### Booking Management (User Side)

| File Path | Endpoint Name | Status | Line Number | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `lib/view/booking/payment_screen.dart` | `Config.bookingpaymentsuccess` | 🔴 LIVE | 117 | Booking - Payment Success Verification |
| `lib/view/booking/up_comming_trip.dart` | `Config.upcommingRecord` | 🔴 LIVE | 35 | Booking - Get Upcoming Bookings |
| `lib/view/booking/previous_trip_screen.dart` | `Config.upcommingRecord` | 🔴 LIVE | 41 | Booking - Get Previous Bookings |
| `lib/view/booking/liveBooking.dart` | `Config.upcommingRecord` | 🔴 LIVE | 34 | Booking - Get Live Bookings |
| `lib/view/booking/cancelled_trip_screen.dart` | `Config.upcommingRecord` | 🔴 LIVE | 32 | Booking - Get Cancelled Bookings |
| `lib/view/booking/vehicle_photoes_booking.dart` | `Config.addInteriorImage` | 🔴 LIVE | 169 | Booking - Upload Interior Photos |

### User Actions (Reviews, Wishlist, Cancel)

| File Path | Endpoint Name | Status | Line Number | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `lib/utils/common_widget.dart` | `Config.getCancelReasons` | 🔴 LIVE | 952 | Booking - Get Cancel Reasons (User) |
| `lib/utils/common_widget.dart` | `Config.cancelBookingByUser` | 🔴 LIVE | 1037 | Booking - Cancel Booking (User) |
| `lib/utils/common_widget.dart` | `Config.getItemDetails` | 🔴 LIVE | 1956 | Vehicle - Get Item Details (User Context) |
| `lib/utils/common_widget.dart` | `Config.getItemDetails` | 🔴 LIVE | 2046 | Vehicle - Get Item Details (User Context) |
| `lib/utils/common_widget.dart` | `Config.giveReviewByUser` | 🔴 LIVE | 4109 | Reviews - Give Review (User) |
| `lib/view/wishlist/wish_list_screen.dart` | `Config.getWishlist` | 🔴 LIVE | 42 | Wishlist - Get Wishlist |
| `lib/controller/wish_list_controller.dart` | `Config.addtowishlist` | 🔴 LIVE | 17 | Wishlist - Add to Wishlist |
| `lib/controller/wish_list_controller.dart` | `Config.removeToWishlist` | 🔴 LIVE | 40 | Wishlist - Remove from Wishlist |
| `lib/view/itemdetail/vehicle/reviews/item_review_screen.dart` | `Config.getItemReviews` | 🔴 LIVE | 34 | Reviews - Get Item Reviews |

### Host Actions

| File Path | Endpoint Name | Status | Line Number | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `lib/view/host/host_e_receipt.dart` | `Config.confirmBookingByHost` | 🔴 LIVE | 390 | Host Orders - Confirm Booking |

### Profile & Settings

| File Path | Endpoint Name | Status | Line Number | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `lib/controller/profile_controller.dart` | `Config.editProfile` | 🔴 LIVE | 151 | Profile - Edit Profile |
| `lib/controller/profile_controller.dart` | `Config.checkEmail` | 🔴 LIVE | 181 | Profile - Check Email Availability |
| `lib/controller/profile_controller.dart` | `Config.uploadProfileImage` | 🔴 LIVE | 435 | Profile - Upload Profile Image |
| `lib/controller/publix_profile_controller.dart` | `Config.getUserProfile` | 🔴 LIVE | 18 | Profile - Get User Profile |
| `lib/controller/publix_profile_controller.dart` | `Config.getVendorItemReviews` | 🔴 LIVE | 21 | Profile - Get Vendor Item Reviews |
| `lib/controller/publix_profile_controller.dart` | `Config.getUseritems` | 🔴 LIVE | 23 | Profile - Get User Items |
| `lib/controller/publix_profile_controller.dart` | `Config.getVendorItemReviews` | 🔴 LIVE | 38 | Profile - Get Vendor Item Reviews (Pagination) |

### Support Tickets

| File Path | Endpoint Name | Status | Line Number | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `lib/controller/ticket_controller.dart` | `Config.getReplyThreads` | 🔴 LIVE | 13 | Support - Get Reply Threads |
| `lib/controller/ticket_controller.dart` | `Config.getUserThreads` | 🔴 LIVE | 18 | Support - Get User Threads |
| `lib/controller/ticket_controller.dart` | `Config.getUserThreads` | 🔴 LIVE | 25 | Support - Get User Threads (Pagination) |
| `lib/controller/ticket_controller.dart` | `Config.createSupportTicket` | 🔴 LIVE | 33 | Support - Create Support Ticket |
| `lib/view/myaccount/ticket/ticket_reply_screen.dart` | `Config.getReplyThreads` | 🔴 LIVE | 48 | Support - Get Reply Threads |
| `lib/view/myaccount/ticket/ticket_reply_screen.dart` | `Config.replyToSupportTicket` | 🔴 LIVE | 61 | Support - Reply to Ticket |
| `lib/view/myaccount/ticket/ticket_reply_screen.dart` | `Config.closeSupportTicket` | 🔴 LIVE | 302 | Support - Close Ticket |

### Digital Signature

| File Path | Endpoint Name | Status | Line Number | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `lib/view/digitalsignatuecommon/digital_singnature.dart` | `Config.uploadSignature` | 🔴 LIVE | 172 | Digital Signature - Upload Signature |

### Payment & Wallet (User Side)

| File Path | Endpoint Name | Status | Line Number | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `lib/controller/add_bank_account_controller.dart` | `Config.getPayoutType` | 🔴 LIVE | 48 | Payment - Get Payout Types |
| `lib/controller/add_bank_account_controller.dart` | `Config.getPayoutMethod` | 🔴 LIVE | 67 | Payment - Get Payout Methods |
| `lib/controller/add_bank_account_controller.dart` | `Config.addPaymentMethod` | 🔴 LIVE | 152 | Payment - Add Payment Method (Note: Mocked in payment_method_screen.dart but LIVE here) |

### KYC (Know Your Customer)

| File Path | Endpoint Name | Status | Line Number | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `lib/controller/kyc_controller.dart` | `Config.getKYCDetails` | 🔴 LIVE | 113 | KYC - Get KYC Details |
| `lib/controller/kyc_controller.dart` | `Config.addKycforCustomer` | 🔴 LIVE | 428 | KYC - Upload KYC Documents |

### Notifications

| File Path | Endpoint Name | Status | Line Number | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `lib/controller/notification_controller.dart` | `Config.emailSmsNotification` | 🔴 LIVE | 44 | Notifications - Email Notification Settings |
| `lib/controller/notification_controller.dart` | `Config.emailSmsNotification` | 🔴 LIVE | 74 | Notifications - Email Notification Settings |
| `lib/controller/notification_controller.dart` | `Config.emailSmsNotification` | 🔴 LIVE | 104 | Notifications - SMS Notification Settings |

### Static Pages

| File Path | Endpoint Name | Status | Line Number | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `lib/controller/static_controller.dart` | `Config.staticPage` | 🔴 LIVE | 13-42 | Static Pages - Get Static Content (Multiple IDs) |

---

## ✅ MOCKED APIs (Déjà migrées - Données statiques)

### Home & Navigation

| File Path | Endpoint Name | Status | Line Number | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `lib/controller/home_controller.dart` | `Config.makeType` | ✅ MOCKED | 54 | Home - Get Makes (Commented) |
| `lib/controller/home_controller.dart` | `Config.itemsType` | ✅ MOCKED | 140 | Home - Get Item Types (Commented) |
| `lib/controller/home_controller.dart` | `Config.nearbyItems` | ✅ MOCKED | 206 | Home - Get Nearby Items (Commented) |
| `lib/controller/home_controller.dart` | `Config.getCurrencyDetails` | ✅ MOCKED | 292 | Home - Get Currency Details (Commented) |
| `lib/controller/home_controller.dart` | `Config.itemsType` | ✅ MOCKED | 342 | Home - Get Item Types (Commented) |
| `lib/controller/home_controller.dart` | `Config.homeDataApi` | ✅ MOCKED | 411 | Home - Get Home Data (Commented) |
| `lib/view/home/recommendation_screen.dart` | `Config.getUseritems` | ✅ MOCKED | 68 | Home - Get User Items (Commented) |
| `lib/view/home/recommendation_screen.dart` | `Config.featuredItems` | ✅ MOCKED | 71 | Home - Get Featured Items (Commented) |
| `lib/view/home/recommendation_screen.dart` | `Config.nearbyItems` | ✅ MOCKED | 73 | Home - Get Nearby Items (Commented) |
| `lib/view/home/recommendation_screen.dart` | `Config.getItemsByLocation` | ✅ MOCKED | 78 | Home - Get Items by Location (Commented) |

### Search & Filtering

| File Path | Endpoint Name | Status | Line Number | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `lib/controller/search_controller.dart` | `Config.amenities` | ✅ MOCKED | 466 | Search - Get Amenities (Commented) |
| `lib/controller/search_controller.dart` | `Config.vechileOdometer` | ✅ MOCKED | 535 | Search - Get Odometer (Commented) |
| `lib/controller/search_controller.dart` | `Config.fuelType` | ✅ MOCKED | 581 | Search - Get Fuel Types (Commented) |
| `lib/controller/search_controller.dart` | `Config.odometermannual` | ✅ MOCKED | 626 | Search - Get Transmission (Commented) |
| `lib/controller/search_controller.dart` | `Config.makeType` | ✅ MOCKED | 668 | Search - Get Makes (Commented) |
| `lib/controller/search_controller.dart` | `Config.itemSearch` | ✅ MOCKED | 1036 | Search - Item Search (Commented) |

### Vehicle Details

| File Path | Endpoint Name | Status | Line Number | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `lib/controller/items_detail_controller.dart` | `Config.getItemDetails` | ✅ MOCKED | 33 | Vehicle Details - Get Item Details (Commented) |

### Booking Process

| File Path | Endpoint Name | Status | Line Number | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `lib/controller/booking_controller.dart` | `Config.checkBookingAvailability` | ✅ MOCKED | 121 | Booking - Check Availability (Commented) |
| `lib/controller/booking_controller.dart` | `Config.itemBookingDate` | ✅ MOCKED | 211 | Booking - Get Item Booking Dates (Commented) |
| `lib/controller/booking_controller.dart` | `Config.getItemPrices` | ✅ MOCKED | 358 | Booking - Get Item Prices (Commented) |
| `lib/controller/booking_controller.dart` | `Config.getUserWallet` | ✅ MOCKED | 431 | Booking - Get User Wallet (Commented) |
| `lib/controller/booking_controller.dart` | `Config.bookItem` | ✅ MOCKED | 640 | Booking - Book Item (Commented) |
| `lib/controller/booking_controller.dart` | `Config.getItemDates` | ✅ MOCKED | 1385 | Booking - Get Item Dates (Commented) |
| `lib/controller/booking_controller.dart` | `Config.updateItemReceivedStatus` | ✅ MOCKED | 1459 | Booking - Update Received Status (Commented) |
| `lib/controller/booking_controller.dart` | `Config.updateItemReturnedStatus` | ✅ MOCKED | 1506 | Booking - Update Returned Status (Commented) |
| `lib/controller/booking_controller.dart` | `Config.getDigitalSingnature` | ✅ MOCKED | 1599 | Booking - Get Digital Signature (Commented) |
| `lib/controller/booking_controller.dart` | `Config.updateItemDeliveredStatus` | ✅ MOCKED | 1658 | Booking - Update Delivered Status (Commented) |
| `lib/view/booking/booking_success_page.dart` | `Config.bookingpaymentsuccess` | ✅ MOCKED | 38 | Booking - Payment Success (Commented) |

### Host - Vehicle Management

| File Path | Endpoint Name | Status | Line Number | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `lib/controller/add_items_host_controller.dart` | `Config.odometermannual` | ✅ MOCKED | 226 | Host - Get Transmission (Commented) |
| `lib/controller/add_items_host_controller.dart` | `Config.vechileOdometer` | ✅ MOCKED | 268 | Host - Get Odometer (Commented) |
| `lib/controller/add_items_host_controller.dart` | `Config.fuelType` | ✅ MOCKED | 310 | Host - Get Fuel Types (Commented) |
| `lib/controller/add_items_host_controller.dart` | `Config.itemsType` | ✅ MOCKED | 366 | Host - Get Item Types (Commented) |
| `lib/controller/add_items_host_controller.dart` | `Config.amenities` | ✅ MOCKED | 404 | Host - Get Amenities (Commented) |
| `lib/controller/add_items_host_controller.dart` | `Config.getMakesModel` | ✅ MOCKED | 481 | Host - Get Makes & Models (Commented) |
| `lib/controller/add_items_host_controller.dart` | `Config.getMakesModel` | ✅ MOCKED | 542 | Host - Get Makes & Models (Filtered) (Commented) |
| `lib/controller/add_items_host_controller.dart` | `Config.getMakesModel` | ✅ MOCKED | 613 | Host - Get Makes & Models (Filtered) (Commented) |
| `lib/controller/add_items_host_controller.dart` | `Config.yourLocation` | ✅ MOCKED | 680 | Host - Get Locations (Commented) |
| `lib/controller/add_items_host_controller.dart` | `Config.getCancellationPolicies` | ✅ MOCKED | 759 | Host - Get Cancellation Policies (Commented) |
| `lib/controller/add_items_host_controller.dart` | `Config.getItemRules` | ✅ MOCKED | 824 | Host - Get Item Rules (Commented) |
| `lib/controller/add_items_host_controller.dart` | `Config.insertItem` | ✅ MOCKED | 1165 | Host - Insert Item (Commented) |
| `lib/controller/add_items_host_controller.dart` | `Config.editItem` | ✅ MOCKED | 1231 | Host - Edit Item (Commented) |
| `lib/controller/add_items_host_controller.dart` | `Config.addEditItemImage` | ✅ MOCKED | 1285 | Host - Add/Edit Item Images (Commented) |
| `lib/view/host/dash_board_screen.dart` | `Config.myItems` | ✅ MOCKED | 78 | Host - Get My Items (Commented) |
| `lib/view/host/dash_board_screen.dart` | `Config.hostDashBoard` | ✅ MOCKED | 288 | Host - Get Dashboard (Commented) |
| `lib/view/host/dash_board_screen.dart` | `Config.deleteItem` | ✅ MOCKED | 408 | Host - Delete Item (Commented) |
| `lib/view/host/hostsearch/host_search_screen.dart` | `Config.myItems` | ✅ MOCKED | 48 | Host - Get My Items (Search) (Commented) |
| `lib/view/host/hostsearch/host_search_screen.dart` | `Config.deleteItem` | ✅ MOCKED | 240 | Host - Delete Item (Search) (Commented) |

### Host - Calendar Management

| File Path | Endpoint Name | Status | Line Number | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `lib/view/host/calender/calendar_common_screen.dart` | `Config.myItems` | ✅ MOCKED | 73 | Host Calendar - Get My Items (Commented) |
| `lib/view/host/calender/calendar_common_screen.dart` | `Config.getItemDates` | ✅ MOCKED | 184 | Host Calendar - Get Item Dates (Commented) |
| `lib/view/host/calender/calendar_common_screen.dart` | `Config.addEditCalender` | ✅ MOCKED | 387 | Host Calendar - Add/Edit Calendar (Commented) |
| `lib/view/host/calender/edit_calander_third_step_common.dart` | `Config.getItemDates` | ✅ MOCKED | 195 | Host Calendar - Get Item Dates (Commented) |
| `lib/view/host/calender/edit_calander_third_step_common.dart` | `Config.addEditCalender` | ✅ MOCKED | 156 | Host Calendar - Add/Edit Calendar (Commented) |

### Host - Dashboard & Orders

| File Path | Endpoint Name | Status | Line Number | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `lib/view/host/orders/upcoming_orders.dart` | `Config.vendorbookingRecord` | ✅ MOCKED | 40 | Host Orders - Get Upcoming (Commented) |
| `lib/view/host/orders/live_orders.dart` | `Config.vendorbookingRecord` | ✅ MOCKED | 39 | Host Orders - Get Live (Commented) |
| `lib/view/host/orders/previous_orders.dart` | `Config.vendorbookingRecord` | ✅ MOCKED | 44 | Host Orders - Get Previous (Commented) |
| `lib/view/host/orders/cancel_orders.dart` | `Config.vendorbookingRecord` | ✅ MOCKED | 38 | Host Orders - Get Cancelled (Commented) |
| `lib/view/host/common_widget_host.dart` | `Config.getCancelReasons` | ✅ MOCKED | 2005 | Host Orders - Get Cancel Reasons (Commented) |
| `lib/view/host/common_widget_host.dart` | `Config.cancelBookingByHost` | ✅ MOCKED | 2131 | Host Orders - Cancel Booking (Commented) |
| `lib/view/host/common_widget_host.dart` | `Config.updateItemDeliveredStatus` | ✅ MOCKED | 2239 | Host Orders - Update Delivered Status (Commented) |
| `lib/view/host/common_widget_host.dart` | `Config.updateItemReturnedStatus` | ✅ MOCKED | 2278 | Host Orders - Update Returned Status (Commented) |
| `lib/view/host/common_widget_host.dart` | `Config.getItemDetails` | ✅ MOCKED | 2967 | Host Orders - Get Item Details (Commented) |
| `lib/view/host/common_widget_host.dart` | `Config.confirmBookingByHost` | ✅ MOCKED | 3091 | Host Orders - Confirm Booking (Commented) |
| `lib/view/host/common_widget_host.dart` | `Config.getItemDetails` | ✅ MOCKED | 3243 | Host Orders - Get Item Details (Commented) |
| `lib/view/host/common_widget_host.dart` | `Config.getItemDetails` | ✅ MOCKED | 3367 | Host Orders - Get Item Details (Commented) |
| `lib/view/host/common_widget_host.dart` | `Config.giveReviewByHost` | ✅ MOCKED | 4166 | Host Orders - Give Review (Commented) |
| `lib/view/host/host_e_receipt.dart` | `Config.getCancelReasons` | ✅ MOCKED | 118 | Host Orders - Get Cancel Reasons (Commented) |
| `lib/view/host/host_e_receipt.dart` | `Config.cancelBookingByHost` | ✅ MOCKED | 235 | Host Orders - Cancel Booking (Commented) |

### Host - Wallet & Financials

| File Path | Endpoint Name | Status | Line Number | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `lib/view/host/wallet/host_wallet.dart` | `Config.getVendorWallet` | ✅ MOCKED | 38 | Host Wallet - Get Wallet (Commented) |
| `lib/view/host/wallet/host_wallet.dart` | `Config.getVendorWalletTransactions` | ✅ MOCKED | 67 | Host Wallet - Get Transactions (Commented) |
| `lib/view/host/wallet/host_earning.dart` | `Config.getVendorEarings` | ✅ MOCKED | 71 | Host Wallet - Get Earnings (Commented) |
| `lib/view/host/wallet/payout_screen.dart` | `Config.getPayoutTransactions` | ✅ MOCKED | 71 | Host Wallet - Get Payout Transactions (Commented) |
| `lib/view/host/wallet/payout_screen.dart` | `Config.insertPayout` | ✅ MOCKED | 669 | Host Wallet - Insert Payout (Commented) |
| `lib/view/host/wallet/payment_method_screen.dart` | `Config.addPaymentMethod` | ✅ MOCKED | 180 | Host Wallet - Add Payment Method (Commented) |

### User Wallet

| File Path | Endpoint Name | Status | Line Number | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `lib/view/payments/wallet_screen.dart` | `Config.getUserWallet` | ✅ MOCKED | 43 | User Wallet - Get Wallet (Commented) |
| `lib/view/payments/wallet_screen.dart` | `Config.getUserWalletTransactions` | ✅ MOCKED | 67 | User Wallet - Get Transactions (Commented) |

---

## 🟡 EXTERNAL APIs (Google Maps, etc. - Pas de migration nécessaire)

| File Path | API | Status | Line Number | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `lib/controller/add_items_host_controller.dart` | Google Places API | 🟡 EXTERNAL | 1369 | Google Places - Search Places |
| `lib/controller/add_items_host_controller.dart` | Google Geocoding API | 🟡 EXTERNAL | 1431 | Google Geocoding - Reverse Geocode |
| `lib/controller/add_items_host_controller.dart` | Google Places API | 🟡 EXTERNAL | 1456 | Google Places - Place Details |
| `lib/controller/search_controller.dart` | Google Places API | 🟡 EXTERNAL | 1228 | Google Places - Autocomplete |
| `lib/controller/search_controller.dart` | Google Geocoding API | 🟡 EXTERNAL | 1238 | Google Geocoding - Geocode Address |
| `lib/controller/search_controller.dart` | Google Maps API | 🟡 EXTERNAL | 1370 | Google Maps - Static Map Image |
| `lib/controller/search_controller.dart` | Google Maps API | 🟡 EXTERNAL | 1388 | Google Maps - Static Map Image |
| `lib/view/digitalsignatuecommon/digital_singnature.dart` | HTTP GET (Image URLs) | 🟡 EXTERNAL | 274 | Download Signature Images |
| `lib/view/digitalsignatuecommon/digital_singnature.dart` | HTTP GET (Image URLs) | 🟡 EXTERNAL | 295 | Download Vehicle Images |

---

## 📋 Statistiques par Module

### Authentication Module
- **Total:** 14 endpoints
- **LIVE:** 14 (100%)
- **MOCKED:** 0
- **Note:** Intentionnellement laissé LIVE pour connexion directe Node.js

### Booking Module (User Side)
- **Total:** 11 endpoints
- **LIVE:** 6 (55%)
- **MOCKED:** 5 (45%)

### Host Module
- **Total:** ~45 endpoints
- **LIVE:** 1 (2%)
- **MOCKED:** ~44 (98%)

### Profile & Settings
- **Total:** 8 endpoints
- **LIVE:** 8 (100%)
- **MOCKED:** 0

### Support Tickets
- **Total:** 5 endpoints
- **LIVE:** 5 (100%)
- **MOCKED:** 0

### Wishlist
- **Total:** 3 endpoints
- **LIVE:** 3 (100%)
- **MOCKED:** 0

### Reviews
- **Total:** 3 endpoints
- **LIVE:** 2 (67%)
- **MOCKED:** 1 (33%)

---

## 🎯 Priorités d'Implémentation Node.js

### 🔴 PRIORITÉ 1 (Critique - Fonctionnalités Core)
1. **Authentication** (14 endpoints) - Déjà identifié comme LIVE
2. **Booking Management - User Side** (6 endpoints)
   - `Config.bookingpaymentsuccess`
   - `Config.upcommingRecord` (4 occurrences)
   - `Config.addInteriorImage`
3. **User Actions** (8 endpoints)
   - `Config.getCancelReasons` (User)
   - `Config.cancelBookingByUser`
   - `Config.getItemDetails` (User Context - 2 occurrences)
   - `Config.giveReviewByUser`
   - `Config.getWishlist`
   - `Config.addtowishlist`
   - `Config.removeToWishlist`
   - `Config.getItemReviews`

### 🟠 PRIORITÉ 2 (Important - Fonctionnalités Secondaires)
4. **Profile & Settings** (8 endpoints)
5. **Support Tickets** (5 endpoints)
6. **Social Login & Chat** (3 endpoints)
7. **Digital Signature** (1 endpoint)
8. **Payment Methods** (3 endpoints)
9. **KYC** (2 endpoints)
10. **Notifications** (3 endpoints)
11. **Static Pages** (Multiple IDs)

### 🟡 PRIORITÉ 3 (Moins Urgent)
12. **Host Actions** (1 endpoint restant)
   - `Config.confirmBookingByHost` (dans `host_e_receipt.dart` ligne 390)

---

## 📝 Notes Importantes

1. **`http_service.dart`** contient les fonctions `httpGet` et `httpPost` qui sont utilisées partout. Ces fonctions contiennent également des mocks pour certains endpoints.

2. **Les appels Google Maps/Places** ne nécessitent pas de migration - ils utilisent directement l'API Google.

3. **Les appels HTTP directs** (`http.get`, `http.post`) pour télécharger des images ne nécessitent pas de migration - ce sont des appels vers des URLs d'images.

4. **Certains endpoints peuvent être appelés depuis plusieurs fichiers** - chaque occurrence est listée séparément.

5. **Le fichier `booking_success_page.dart`** a `Config.bookingpaymentsuccess` commenté (ligne 38), mais `payment_screen.dart` l'a encore LIVE (ligne 117).

---

**Date de création:** $(date)
**Dernière mise à jour:** Après audit complet de la migration

