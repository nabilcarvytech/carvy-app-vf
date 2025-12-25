# Authentication API Specification

**Source:** `lib/controller/auth_controller.dart`  
**Base URL:** `https://admin.carvy.tech/api/v1/`  
**Total Endpoints:** 15

---

## 1. User Email Login

* **Flutter Endpoint:** `Config.userEmailLogin`
* **Method:** POST
* **Expected URL:** `/api/v1/user-email-login`
* **Function:** `loginMethod()`

* **Request Body (Parameters sent by Flutter):**

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

* **Expected Response JSON:**

```json
{
  "status": 200,
  "message": "Login successful",
  "error": "",
  "data": {
    "id": 123,
    "first_name": "John",
    "middle": null,
    "last_name": "Doe",
    "email": "user@example.com",
    "phone": "+1234567890",
    "phone_country": "+1",
    "default_country": "US",
    "intro": null,
    "langauge": "en",
    "country": "USA",
    "wallet": "0.00",
    "otp_value": null,
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "reset_token": null,
    "verified": "1",
    "login_type": "email",
    "birthdate": "1990-01-01",
    "social_id": null,
    "status": "1",
    "created_at": "2024-01-01T00:00:00.000Z",
    "updated_at": "2024-01-01T00:00:00.000Z",
    "package_id": null,
    "fcm": null,
    "device_id": null,
    "identity_image": null,
    "profile_image": null,
    "sms_notification": "1",
    "email_notification": "1",
    "push_notification": "1",
    "firebase_auth": null
  }
}
```

**Special Cases:**
- `status: 403` → User needs OTP verification. Response includes `phone`, `phone_country`, and `reset_token` (OTP value).
- `status: 200` → Login successful, user is authenticated.

---

## 2. Register User

* **Flutter Endpoint:** `Config.registerUser`
* **Method:** POST
* **Expected URL:** `/api/v1/userRegister`
* **Function:** `signUp()`

* **Request Body (Parameters sent by Flutter):**

```json
{
  "phone": "1234567890",
  "email": "user@example.com",
  "first_name": "John",
  "password": "password123",
  "phone_country": "+1",
  "default_country": "US",
  "last_name": "Doe",
  "birthdate": "1990-01-01"
}
```

* **Expected Response JSON:**

```json
{
  "status": 200,
  "message": "Registration successful",
  "error": "",
  "data": {
    "id": 123,
    "first_name": "John",
    "middle": null,
    "last_name": "Doe",
    "email": "user@example.com",
    "phone": "1234567890",
    "phone_country": "+1",
    "default_country": "US",
    "intro": null,
    "langauge": null,
    "country": null,
    "wallet": null,
    "otp_value": "123456",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "reset_token": null,
    "verified": "0",
    "login_type": "email",
    "birthdate": "1990-01-01",
    "social_id": null,
    "status": "1",
    "created_at": "2024-01-01T00:00:00.000Z",
    "updated_at": "2024-01-01T00:00:00.000Z",
    "package_id": null,
    "fcm": null,
    "device_id": null,
    "identity_image": null,
    "profile_image": null,
    "sms_notification": null,
    "email_notification": null,
    "push_notification": null,
    "firebase_auth": null
  }
}
```

**Note:** After successful registration, Flutter redirects to OTP screen. The `otp_value` field contains the OTP code for verification.

---

## 3. Forgot Password

* **Flutter Endpoint:** `Config.forgotPassword`
* **Method:** POST
* **Expected URL:** `/api/v1/forgot-password`
* **Function:** `forgetPassword()`

* **Request Body (Parameters sent by Flutter):**

```json
{
  "email": "user@example.com"
}
```

* **Expected Response JSON:**

```json
{
  "status": 200,
  "message": "Password reset token sent successfully",
  "error": "",
  "data": {
    "reset_token": "123456"
  }
}
```

**Note:** The `reset_token` is used as OTP for password reset verification.

---

## 4. OTP Verification

* **Flutter Endpoint:** `Config.otpVerification`
* **Method:** POST
* **Expected URL:** `/api/v1/otp-verification`
* **Function:** `verifyOtp()`

* **Request Body (Parameters sent by Flutter):**

```json
{
  "phone": "1234567890",
  "otp_value": "123456",
  "phone_country": "+1"
}
```

* **Expected Response JSON:**

```json
{
  "status": 200,
  "message": "OTP verified successfully",
  "error": "",
  "data": {
    "id": 123,
    "first_name": "John",
    "middle": null,
    "last_name": "Doe",
    "email": "user@example.com",
    "phone": "1234567890",
    "phone_country": "+1",
    "default_country": "US",
    "intro": null,
    "langauge": null,
    "country": null,
    "wallet": null,
    "otp_value": "0",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "reset_token": null,
    "verified": "1",
    "login_type": "email",
    "birthdate": "1990-01-01",
    "social_id": null,
    "status": "1",
    "created_at": "2024-01-01T00:00:00.000Z",
    "updated_at": "2024-01-01T00:00:00.000Z",
    "package_id": null,
    "fcm": null,
    "device_id": null,
    "identity_image": null,
    "profile_image": null,
    "sms_notification": null,
    "email_notification": null,
    "push_notification": null,
    "firebase_auth": null
  }
}
```

---

## 5. Resend OTP

* **Flutter Endpoint:** `Config.resendOtp`
* **Method:** POST
* **Expected URL:** `/api/v1/resend-otp`
* **Function:** `resendOtp()`

* **Request Body (Parameters sent by Flutter):**

```json
{
  "phone": "1234567890",
  "phone_country": "+1"
}
```

* **Expected Response JSON:**

```json
{
  "status": 200,
  "message": "OTP resent successfully",
  "error": "",
  "data": {
    "otp_value": "654321"
  }
}
```

---

## 6. Resend Token (Email Reset)

* **Flutter Endpoint:** `Config.resendToken`
* **Method:** POST
* **Expected URL:** `/api/v1/resend-token`
* **Function:** `resendToken()`

* **Request Body (Parameters sent by Flutter):**

```json
{
  "email": "user@example.com"
}
```

* **Expected Response JSON:**

```json
{
  "status": 200,
  "message": "Reset token resent successfully",
  "error": "",
  "data": {
    "reset_token": "987654"
  }
}
```

**Note:** Used for password reset flow when user requests a new reset token.

---

## 7. Verify Reset Token

* **Flutter Endpoint:** `Config.verifyResetToken`
* **Method:** POST
* **Expected URL:** `/api/v1/verify-reset-token`
* **Function:** `verifyResetToken()`

* **Request Body (Parameters sent by Flutter):**

```json
{
  "email": "user@example.com",
  "reset_token": "123456"
}
```

* **Expected Response JSON:**

```json
{
  "status": 200,
  "message": "Reset token verified successfully",
  "error": "",
  "data": {
    "email": "user@example.com",
    "reset_token": "123456"
  }
}
```

**Note:** After successful verification, Flutter redirects to reset password screen.

---

## 8. Reset Password

* **Flutter Endpoint:** `Config.resetPassword`
* **Method:** POST
* **Expected URL:** `/api/v1/reset-password`
* **Function:** `callChangePassApi()`

* **Request Body (Parameters sent by Flutter):**

```json
{
  "email": "user@example.com",
  "reset_token": "123456",
  "password": "newPassword123",
  "confirm_password": "newPassword123"
}
```

* **Expected Response JSON:**

```json
{
  "status": 200,
  "message": "Password reset successfully",
  "error": "",
  "data": {
    "email": "user@example.com",
    "reset_token": "123456"
  }
}
```

---

## 9. Update Password

* **Flutter Endpoint:** `Config.updatePassword`
* **Method:** POST
* **Expected URL:** `/api/v1/update-password`
* **Function:** `updateThePassword()`
* **Authentication:** Required (Bearer Token)

* **Request Body (Parameters sent by Flutter):**

```json
{
  "old_password": "oldPassword123",
  "new_password": "newPassword123",
  "conf_new_password": "newPassword123"
}
```

* **Expected Response JSON:**

```json
{
  "status": 200,
  "message": "Password updated successfully",
  "error": ""
}
```

---

## 10. Check Mobile Number

* **Flutter Endpoint:** `Config.checkMobileNumber`
* **Method:** POST
* **Expected URL:** `/api/v1/check-mobile-number`
* **Function:** `checkMobileNumber()`

* **Request Body (Parameters sent by Flutter):**

```json
{
  "phone": "1234567890",
  "phone_country": "+1",
  "email": "user@example.com"
}
```

* **Expected Response JSON:**

```json
{
  "status": 200,
  "message": "Mobile number checked successfully",
  "error": "",
  "data": {
    "phone": "1234567890",
    "phone_country": "+1",
    "otp": "123456"
  }
}
```

**Note:** Used when changing mobile number. Returns OTP for verification.

---

## 11. Change Mobile Number

* **Flutter Endpoint:** `Config.changeMobileNumber`
* **Method:** POST
* **Expected URL:** `/api/v1/change-mobile-number`
* **Function:** `changeMobileNumber()`
* **Authentication:** Required (Bearer Token)

* **Request Body (Parameters sent by Flutter):**

```json
{
  "phone": "9876543210",
  "phone_country": "+1",
  "otp_value": "123456",
  "default_country": "US"
}
```

* **Expected Response JSON:**

```json
{
  "status": 200,
  "message": "Mobile number changed successfully",
  "error": "",
  "data": {
    "id": 123,
    "first_name": "John",
    "middle": null,
    "last_name": "Doe",
    "email": "user@example.com",
    "phone": "9876543210",
    "phone_country": "+1",
    "default_country": "US",
    "wallet": null,
    "otp_value": "0",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "reset_token": null,
    "verified": "1",
    "login_type": "email",
    "birthdate": "1990-01-01",
    "social_id": null,
    "status": "1",
    "created_at": "2024-01-01T00:00:00.000Z",
    "updated_at": "2024-01-01T00:00:00.000Z",
    "package_id": null,
    "fcm": null,
    "device_id": null,
    "profile_image": null,
    "media": []
  }
}
```

---

## 12. Change Email

* **Flutter Endpoint:** `Config.changeEmail`
* **Method:** POST
* **Expected URL:** `/api/v1/change-email`
* **Function:** `verifyFunction()` (with `changeEmail` parameter)
* **Authentication:** Required (Bearer Token)

* **Request Body (Parameters sent by Flutter):**

```json
{
  "email": "newemail@example.com",
  "otp_value": "123456"
}
```

* **Expected Response JSON:**

```json
{
  "status": 200,
  "message": "Email changed successfully",
  "error": "",
  "data": {
    "id": 123,
    "first_name": "John",
    "middle": null,
    "last_name": "Doe",
    "email": "newemail@example.com",
    "phone": "1234567890",
    "phone_country": "+1",
    "default_country": "US",
    "intro": null,
    "langauge": null,
    "country": null,
    "wallet": null,
    "otp_value": "0",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "reset_token": null,
    "verified": "1",
    "login_type": "email",
    "birthdate": "1990-01-01",
    "social_id": null,
    "status": "1",
    "created_at": "2024-01-01T00:00:00.000Z",
    "updated_at": "2024-01-01T00:00:00.000Z",
    "package_id": null,
    "fcm": null,
    "device_id": null,
    "identity_image": null,
    "profile_image": null,
    "sms_notification": null,
    "email_notification": null,
    "push_notification": null,
    "firebase_auth": null
  }
}
```

---

## 13. Resend Token for Email Change

* **Flutter Endpoint:** `Config.resendTokenEmailChange`
* **Method:** POST
* **Expected URL:** `/api/v1/resend-token-email-change`
* **Function:** `resendNewCodeFunction()` (with `changeEmail` parameter)
* **Authentication:** Required (Bearer Token)

* **Request Body (Parameters sent by Flutter):**

```json
{
  "email": "newemail@example.com",
  "type": "email_reset"
}
```

* **Expected Response JSON:**

```json
{
  "status": 200,
  "message": "Reset token resent successfully",
  "error": "",
  "data": {
    "reset_token": "987654"
  }
}
```

**Note:** The `reset_token` is used as OTP for email change verification.

---

## 14. Social Login

* **Flutter Endpoint:** `Config.socialLogin`
* **Method:** POST
* **Expected URL:** `/api/v1/social-login`
* **Function:** `globalScopeController.socialLogin()`

* **Request Body (Parameters sent by Flutter):**

```json
{
  "displayName": "John Doe",
  "email": "user@example.com",
  "id": "google_user_id_123456",
  "profile_image": "https://example.com/profile.jpg",
  "login_type": "google",
  "identityToken": "eyJhbGciOiJSUzI1NiIs...",
  "authorizationCode": "auth_code_123"
}
```

**Note:** 
- `login_type` can be `"google"` or `"apple"`
- For Google: `identityToken` and `authorizationCode` may be empty strings
- For Apple: `identityToken` and `authorizationCode` are required

* **Expected Response JSON:**

```json
{
  "status": 200,
  "message": "Social login successful",
  "error": "",
  "data": {
    "id": 123,
    "first_name": "John",
    "middle": null,
    "last_name": "Doe",
    "email": "user@example.com",
    "phone": null,
    "phone_country": null,
    "default_country": null,
    "intro": null,
    "langauge": null,
    "country": null,
    "wallet": null,
    "otp_value": null,
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "reset_token": null,
    "verified": "1",
    "login_type": "google",
    "birthdate": null,
    "social_id": "google_user_id_123456",
    "status": "1",
    "created_at": "2024-01-01T00:00:00.000Z",
    "updated_at": "2024-01-01T00:00:00.000Z",
    "package_id": null,
    "fcm": null,
    "device_id": null,
    "identity_image": null,
    "profile_image": {
      "url": "https://example.com/profile.jpg"
    },
    "sms_notification": null,
    "email_notification": null,
    "push_notification": null,
    "firebase_auth": null
  }
}
```

**Special Cases:**
- If `phone` is `null` → Flutter redirects to profile update screen to collect phone number
- If `phone` is present → User is logged in directly

---

## 15. Put Host Request (Become a Host)

* **Flutter Endpoint:** `Config.putHostRequest`
* **Method:** POST
* **Expected URL:** `/api/v1/put-host-request`
* **Function:** `sendrequesttobecomeHost()`
* **Authentication:** Required (Bearer Token)

* **Request Body (Parameters sent by Flutter):**

```json
{
  "host_status": "2",
  "first_name": "John",
  "last_name": "Doe",
  "company_name": "My Company Inc",
  "email": "host@example.com",
  "phone": "1234567890",
  "country_code": "+1",
  "residency_type": "individual",
  "full_address": "123 Main Street, City, State, ZIP",
  "identity_type": "passport",
  "identity_image": "data:image/jpeg;base64,/9j/4AAQSkZJRg..."
}
```

**Note:** 
- `identity_image` is a base64-encoded image string with data URI format: `data:image/{format};base64,{base64_string}`
- `host_status: "2"` indicates a pending host request
- `residency_type` can be `"individual"` or `"company"`
- `identity_type` can be `"passport"`, `"id_card"`, `"driver_license"`, etc.
- `company_name` can be empty string if `residency_type` is `"individual"`

* **Expected Response JSON:**

```json
{
  "status": 200,
  "message": "Host request submitted successfully",
  "error": ""
}
```

---

## Common Response Structure

All endpoints follow this common response structure:

```json
{
  "status": 200 | 403 | 400 | 500,
  "message": "Success or error message",
  "error": "Error message (if status != 200)",
  "data": { ... }
}
```

**Status Codes:**
- `200` → Success
- `403` → Forbidden (e.g., user needs OTP verification)
- `400` → Bad Request (validation errors)
- `500` → Internal Server Error

---

## Authentication Headers

For authenticated endpoints, include:

```
Authorization: Bearer {token}
```

Where `{token}` is the JWT token received from login/registration endpoints.

---

## Notes for Node.js Implementation

1. **Token Generation:** All login/registration endpoints must return a JWT token in `data.token`
2. **OTP Management:** OTPs should be time-limited (typically 5-10 minutes)
3. **Password Hashing:** Use bcrypt or similar for password hashing
4. **Email Verification:** Consider implementing email verification flow
5. **Phone Verification:** OTP verification is mandatory for phone numbers
6. **Social Login:** Verify social tokens (Google/Apple) before creating/updating user
7. **Host Request:** Store identity images securely and validate file formats
8. **Error Handling:** Always return consistent error format with `status`, `message`, and `error` fields

