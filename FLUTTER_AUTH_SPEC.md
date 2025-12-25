# Flutter Authentication API Specification

**Document Version:** 1.0  
**Date:** 2025-01-XX  
**Purpose:** Complete API specification for Node.js backend implementation

---

## Base URL

- **Base URL:** `https://admin.carvy.tech/api/v1/`
- **Base URL (Bearer):** `https://admin.carvy.tech/api/`

---

## Common Response Structure

All endpoints follow this structure:

```json
{
  "status": 200,
  "message": "Success message",
  "error": "",
  "data": { ... }
}
```

**Status Codes:**
- `200` = Success
- `403` = Verification required (for login)
- Other = Error (check `error` field)

---

## 1. User Email Login

**Endpoint:** `user-email-login`  
**Method:** POST  
**URL:** `/api/v1/user-email-login`

### Request Parameters

```json
{
  "email": "user@example.com",
  "password": "userpassword"
}
```

### Expected Response (Success - Status 200)

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
    "intro": "User bio",
    "langauge": "en",
    "country": "USA",
    "wallet": "100.00",
    "otp_value": "0",
    "token": "ETqJnTf3z4MWaBgpFt6KUIlSMpisdnjJlMhws4GRYcJNEnBwxL9b2PfSqNk5HRcFRlDUb4hqQnLJf0JMvvY4LLhzfXhApm26X5VTtdAiazKryf965Y75m2qH",
    "reset_token": "0",
    "verified": "1",
    "login_type": "email",
    "birthdate": "1990-01-01",
    "social_id": null,
    "status": "1",
    "created_at": "2023-01-01T00:00:00.000Z",
    "updated_at": "2023-01-01T00:00:00.000Z",
    "package_id": null,
    "fcm": null,
    "device_id": null,
    "identity_image": null,
    "profile_image": {
      "id": 1,
      "url": "https://example.com/profile.jpg",
      "thumbnail": "https://example.com/profile-thumb.jpg",
      "preview": "https://example.com/profile-preview.jpg"
    },
    "sms_notification": "1",
    "email_notification": "1",
    "push_notification": "1",
    "firebase_auth": null
  }
}
```

### Expected Response (Verification Required - Status 403)

```json
{
  "status": 403,
  "message": "Please Complete the Verification process",
  "error": "",
  "data": {
    "id": 123,
    "phone": "+1234567890",
    "phone_country": "+1",
    "reset_token": "123456"
  }
}
```

**Flutter Behavior:**
- If `status == 200`: Navigate to home, save token, set `userId`
- If `status == 403`: Navigate to OTP screen with `phone`, `phone_country`, and `reset_token`
- Otherwise: Show error message

---

## 2. User Registration

**Endpoint:** `userRegister`  
**Method:** POST  
**URL:** `/api/v1/userRegister`

### Request Parameters

```json
{
  "phone": "1234567890",
  "email": "user@example.com",
  "first_name": "John",
  "password": "userpassword",
  "phone_country": "+1",
  "default_country": "US",
  "last_name": "Doe",
  "birthdate": "1990-01-01"
}
```

### Expected Response (Success - Status 200)

```json
{
  "status": 200,
  "message": "Registration successful",
  "error": "",
  "data": {
    "id": 123,
    "first_name": "John",
    "last_name": "Doe",
    "email": "user@example.com",
    "phone": "1234567890",
    "phone_country": "+1",
    "default_country": "US",
    "otp_value": "123456",
    "token": "ETqJnTf3z4MWaBgpFt6KUIlSMpisdnjJlMhws4GRYcJNEnBwxL9b2PfSqNk5HRcFRlDUb4hqQnLJf0JMvvY4LLhzfXhApm26X5VTtdAiazKryf965Y75m2qH",
    "verified": "0",
    "status": "1",
    "created_at": "2023-01-01T00:00:00.000Z",
    "updated_at": "2023-01-01T00:00:00.000Z"
  }
}
```

**Flutter Behavior:**
- Navigate to OTP screen with `phone`, `phone_country`, and `otp_value`
- Save token and userId

---

## 3. Forgot Password

**Endpoint:** `forgot-password`  
**Method:** POST  
**URL:** `/api/v1/forgot-password`

### Request Parameters

```json
{
  "email": "user@example.com"
}
```

### Expected Response (Success - Status 200)

```json
{
  "status": 200,
  "message": "Reset token sent to email",
  "error": "",
  "data": {
    "reset_token": "123456"
  }
}
```

**Flutter Behavior:**
- Navigate to OTP screen with `email` and `reset_token`

---

## 4. OTP Verification

**Endpoint:** `otp-verification`  
**Method:** POST  
**URL:** `/api/v1/otp-verification`

### Request Parameters

```json
{
  "phone": "1234567890",
  "otp_value": "123456",
  "phone_country": "+1"
}
```

### Expected Response (Success - Status 200)

```json
{
  "status": 200,
  "message": "OTP verified successfully",
  "error": "",
  "data": {
    "id": 123,
    "first_name": "John",
    "last_name": "Doe",
    "email": "user@example.com",
    "phone": "1234567890",
    "phone_country": "+1",
    "token": "ETqJnTf3z4MWaBgpFt6KUIlSMpisdnjJlMhws4GRYcJNEnBwxL9b2PfSqNk5HRcFRlDUb4hqQnLJf0JMvvY4LLhzfXhApm26X5VTtdAiazKryf965Y75m2qH",
    "verified": "1",
    "status": "1"
  }
}
```

**Flutter Behavior:**
- Navigate to home screen
- Save token and userId

---

## 5. Resend OTP

**Endpoint:** `resend-otp`  
**Method:** POST  
**URL:** `/api/v1/resend-otp`

### Request Parameters

```json
{
  "phone": "1234567890",
  "phone_country": "+1"
}
```

### Expected Response (Success - Status 200)

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

**Flutter Behavior:**
- Auto-fill OTP field with `data.otp_value`

---

## 6. Resend Reset Token (Email)

**Endpoint:** `resend-token`  
**Method:** POST  
**URL:** `/api/v1/resend-token`

### Request Parameters

```json
{
  "email": "user@example.com"
}
```

### Expected Response (Success - Status 200)

```json
{
  "status": 200,
  "message": "Reset token resent successfully",
  "error": "",
  "data": {
    "reset_token": "654321"
  }
}
```

**Flutter Behavior:**
- Auto-fill OTP field with `data.reset_token`

---

## 7. Verify Reset Token

**Endpoint:** `verify-reset-token`  
**Method:** POST  
**URL:** `/api/v1/verify-reset-token`

### Request Parameters

```json
{
  "email": "user@example.com",
  "reset_token": "123456"
}
```

### Expected Response (Success - Status 200)

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

**Flutter Behavior:**
- Navigate to reset password screen with `email` and `reset_token`

---

## 8. Reset Password

**Endpoint:** `reset-password`  
**Method:** POST  
**URL:** `/api/v1/reset-password`

### Request Parameters

```json
{
  "email": "user@example.com",
  "reset_token": "123456",
  "password": "newpassword",
  "confirm_password": "newpassword"
}
```

### Expected Response (Success - Status 200)

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

**Flutter Behavior:**
- Navigate to success screen

---

## 9. Update Password (Change Password)

**Endpoint:** `update-password`  
**Method:** POST  
**URL:** `/api/v1/update-password`  
**Authentication:** Required (Bearer token)

### Request Parameters

```json
{
  "old_password": "oldpassword",
  "new_password": "newpassword",
  "conf_new_password": "newpassword"
}
```

### Expected Response (Success - Status 200)

```json
{
  "status": 200,
  "message": "Password updated successfully",
  "error": ""
}
```

**Flutter Behavior:**
- Show success message and navigate back

---

## 10. Check Mobile Number

**Endpoint:** `check-mobile-number`  
**Method:** POST  
**URL:** `/api/v1/check-mobile-number`

### Request Parameters

```json
{
  "phone": "1234567890",
  "phone_country": "+1",
  "email": "user@example.com"
}
```

### Expected Response (Success - Status 200)

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

**Flutter Behavior:**
- Navigate to OTP screen with `phone`, `phone_country`, and `otp`

---

## 11. Change Mobile Number

**Endpoint:** `change-mobile-number`  
**Method:** POST  
**URL:** `/api/v1/change-mobile-number`  
**Authentication:** Required (Bearer token)

### Request Parameters

```json
{
  "phone": "9876543210",
  "phone_country": "+1",
  "otp_value": "123456",
  "default_country": "US"
}
```

### Expected Response (Success - Status 200)

```json
{
  "status": 200,
  "message": "Mobile number changed successfully",
  "error": "",
  "data": {
    "id": 123,
    "first_name": "John",
    "last_name": "Doe",
    "email": "user@example.com",
    "phone": "9876543210",
    "phone_country": "+1",
    "token": "ETqJnTf3z4MWaBgpFt6KUIlSMpisdnjJlMhws4GRYcJNEnBwxL9b2PfSqNk5HRcFRlDUb4hqQnLJf0JMvvY4LLhzfXhApm26X5VTtdAiazKryf965Y75m2qH",
    "verified": "1",
    "status": "1"
  }
}
```

**Flutter Behavior:**
- Update user data and navigate to profile or home

---

## 12. Change Email

**Endpoint:** `change-email`  
**Method:** POST  
**URL:** `/api/v1/change-email`  
**Authentication:** Required (Bearer token)

### Request Parameters

```json
{
  "email": "newemail@example.com",
  "otp_value": "123456"
}
```

### Expected Response (Success - Status 200)

```json
{
  "status": 200,
  "message": "Email changed successfully",
  "error": "",
  "data": {
    "id": 123,
    "first_name": "John",
    "last_name": "Doe",
    "email": "newemail@example.com",
    "token": "ETqJnTf3z4MWaBgpFt6KUIlSMpisdnjJlMhws4GRYcJNEnBwxL9b2PfSqNk5HRcFRlDUb4hqQnLJf0JMvvY4LLhzfXhApm26X5VTtdAiazKryf965Y75m2qH",
    "verified": "1",
    "status": "1"
  }
}
```

**Flutter Behavior:**
- Update user data and navigate to profile

---

## 13. Resend Token for Email Change

**Endpoint:** `resend-token-email-change`  
**Method:** POST  
**URL:** `/api/v1/resend-token-email-change`  
**Authentication:** Required (Bearer token)

### Request Parameters

```json
{
  "email": "newemail@example.com",
  "type": "email_reset"
}
```

### Expected Response (Success - Status 200)

```json
{
  "status": 200,
  "message": "Reset token sent successfully",
  "error": "",
  "data": {
    "reset_token": "654321"
  }
}
```

**Flutter Behavior:**
- Auto-fill OTP field with `data.reset_token`

---

## 14. Social Login

**Endpoint:** `social-login`  
**Method:** POST  
**URL:** `/api/v1/social-login`

### Request Parameters

```json
{
  "displayName": "John Doe",
  "email": "user@gmail.com",
  "id": "107712950302300274578",
  "profile_image": "https://example.com/profile.jpg",
  "login_type": "google",
  "identityToken": "eyJhbGciOiJSUzI1NiIs...",
  "authorizationCode": "c1234567890"
}
```

**Note:** For Apple login, `identityToken` and `authorizationCode` are required. For Google, they may be empty strings.

### Expected Response (Success - Status 200)

```json
{
  "status": 200,
  "message": "Social login successful",
  "error": "",
  "data": {
    "id": 123,
    "first_name": "John",
    "last_name": "Doe",
    "email": "user@gmail.com",
    "phone": null,
    "phone_country": null,
    "default_country": null,
    "otp_value": "0",
    "token": "ETqJnTf3z4MWaBgpFt6KUIlSMpisdnjJlMhws4GRYcJNEnBwxL9b2PfSqNk5HRcFRlDUb4hqQnLJf0JMvvY4LLhzfXhApm26X5VTtdAiazKryf965Y75m2qH",
    "reset_token": "0",
    "verified": "1",
    "login_type": "google",
    "birthdate": null,
    "social_id": "107712950302300274578",
    "status": "1",
    "created_at": "2023-01-01T00:00:00.000Z",
    "updated_at": "2023-01-01T00:00:00.000Z",
    "package_id": null,
    "fcm": null,
    "device_id": null,
    "profile_image": {
      "id": 1,
      "url": "https://example.com/profile.jpg",
      "thumbnail": "https://example.com/profile-thumb.jpg",
      "preview": "https://example.com/profile-preview.jpg"
    }
  }
}
```

**Flutter Behavior:**
- If `data.phone == null`: Navigate to "Update Profile" screen to collect phone number
- Otherwise: Navigate to home screen
- Save token and userId

---

## 15. Become a Host Request

**Endpoint:** `put-host-request`  
**Method:** POST  
**URL:** `/api/v1/put-host-request`  
**Authentication:** Required (Bearer token)

### Request Parameters

```json
{
  "host_status": "2",
  "first_name": "John",
  "last_name": "Doe",
  "company_name": "My Company",
  "email": "host@example.com",
  "phone": "1234567890",
  "country_code": "+1",
  "residency_type": "individual",
  "full_address": "123 Main St, City, Country",
  "identity_type": "passport",
  "identity_image": "data:image/jpeg;base64,/9j/4AAQSkZJRg..."
}
```

**Note:** `identity_image` is a base64-encoded image string (data URI format).

### Expected Response (Success - Status 200)

```json
{
  "status": 200,
  "message": "Host request submitted successfully",
  "error": ""
}
```

**Flutter Behavior:**
- Show success message and navigate back

---

## Important Notes for Node.js Implementation

### 1. Token Management
- All authenticated endpoints require a `Bearer` token in the `Authorization` header
- Token format: `Authorization: Bearer <token>`
- Token is returned in `data.token` for login/registration endpoints

### 2. Status Codes
- `200` = Success
- `403` = Verification required (for login)
- Other numeric codes = Error (check `error` field)

### 3. Response Structure
- Always include `status`, `message`, `error`, and `data` fields
- `error` should be empty string `""` on success
- `data` can be an object or null

### 4. User Data Fields
- `id`: Numeric user ID
- `token`: Authentication token (JWT or similar)
- `verified`: "1" = verified, "0" = not verified
- `status`: "1" = active, "0" = inactive
- `otp_value`: OTP code (string, "0" if not applicable)
- `reset_token`: Password reset token (string, "0" if not applicable)

### 5. Profile Image Structure
```json
{
  "id": 1,
  "url": "https://example.com/image.jpg",
  "thumbnail": "https://example.com/image-thumb.jpg",
  "preview": "https://example.com/image-preview.jpg"
}
```

### 6. Phone Number Format
- `phone`: Numeric string (no spaces, no dashes)
- `phone_country`: Country code with `+` prefix (e.g., "+1", "+212")
- `default_country`: ISO country code (e.g., "US", "MA")

### 7. Date Format
- All dates in ISO 8601 format: `"2023-01-01T00:00:00.000Z"`
- Birthdate: `"1990-01-01"` (YYYY-MM-DD)

### 8. Social Login Types
- `"google"`: Google Sign-In
- `"apple"`: Apple Sign-In

### 9. Host Status Values
- `"0"`: Not a host
- `"1"`: Active host
- `"2"`: Pending host request

---

## Error Handling

All endpoints should return errors in this format:

```json
{
  "status": 400,
  "message": "Error message",
  "error": "Detailed error description",
  "data": null
}
```

**Common Error Scenarios:**
- Invalid credentials → Status 401
- User not found → Status 404
- Validation errors → Status 400
- Server errors → Status 500

---

**End of Specification**


