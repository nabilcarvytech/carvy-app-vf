
import 'package:get/get.dart';

String? validateEmail(String value) {
  if (!value.isEmail) {
    return 'Please enter valid email'.tr;
  }
  return null;
}

bool isValidName(String value) {
  if (value.isEmpty) {
    return false;
  }
  if (!RegExp(r'^[A-Za-z ]+$').hasMatch(value)) {
    return false;
  }
  return true;
}

String? validatePassword(String value) {
  // print(value);
  if (value.isEmpty) {
    return 'Please enter valid Password'.tr;
  }

  return null;
}

String? requiredvalidat(String value) {
  // print(value);
  if (value.isEmpty) {
    return 'Please enter the note'.tr;
  }

  return null;
}



String? requiredUpi(String value) {
  // print(value);
  if (value.isEmpty) {
    return 'Please enter the Upi ID'.tr;
  }

  return null;
}
String? validatesPassword(String? value) {
  String patternUppercase = r'(?=.*?[A-Z])';
  String patternLowercase = r'(?=.*?[a-z])';
  String patternDigits = r'(?=.*?[0-9])';
  String patternSpecialCharacter = r'(?=.*?[!@#\$&*~])';
  String patternMinLength = r'.{8,}';

  RegExp regexUppercase = RegExp(patternUppercase);
  RegExp regexLowercase = RegExp(patternLowercase);
  RegExp regexDigits = RegExp(patternDigits);
  RegExp regexSpecialCharacter = RegExp(patternSpecialCharacter);
  RegExp regexMinLength = RegExp(patternMinLength);

  String errorMessage = 'Password must have:'.tr;
  bool isValid = true;

  if (!regexUppercase.hasMatch(value!)) {
    isValid = false;
    errorMessage += '\n- ${'At least 1 uppercase letter'.tr}';
  }
  if (!regexLowercase.hasMatch(value)) {
    isValid = false;
    errorMessage += '\n- ${'At least 1 lowercase letter'.tr}';
  }
  if (!regexDigits.hasMatch(value)) {
    isValid = false;
    errorMessage += '\n- ${'At least 1 number'.tr}';
  }
  if (!regexSpecialCharacter.hasMatch(value)) {
    isValid = false;
    errorMessage += '\n- ${'At least 1 special character'.tr} (!@#\$&*~)';
  }
  if (!regexMinLength.hasMatch(value)) {
    isValid = false;
    errorMessage += '\n- ${'Minimum 8 characters'.tr}';
  }
  return isValid ? null : errorMessage;







}
class ValidationService {
  static bool isNumeric(String value) {
    return double.tryParse(value) != null;
  }

  static bool isNotEmpty(String value) {
    return value.isNotEmpty;
  }

  static void validateAndNavigate({
    final String? title,
    final String? area,
    final String? description,
    final Function(String)? showErrorToastMessage,
    final Function()? navigateToNextScreen,
  }) {
    if (!isNotEmpty(title!)) {
      showErrorToastMessage!("The items name field is required".tr);
      return;
    }

    if (!isNumeric(area!)) {
      showErrorToastMessage!("The Area field must be a valid number".tr);
      return;
    }

    if (!isNotEmpty(description!)) {
      showErrorToastMessage!("The description field is required".tr);
      return;
    }

    navigateToNextScreen!();
  }
}



//for password caluclate-----------
class PasswordStrengthResult {
  final double strengthPercentage;
  final bool isStrong;

  PasswordStrengthResult(this.strengthPercentage, this.isStrong);
}

PasswordStrengthResult calculatePasswordStrength(String password) {
  // Define rules for password strength
  int minLength = 8;

  // Initialize scores and counters
  int totalScore = 0;
  int lengthScore = 0;
  int upperCaseScore = 0;
  int lowerCaseScore = 0;
  int digitsScore = 0;
  int specialCharsScore = 0;

  // Score based on length
  if (password.length >= minLength) {
    lengthScore = 1;
  }

  // Score based on upper case characters
  RegExp upperCaseRegex = RegExp(r'[A-Z]');
  if (upperCaseRegex.hasMatch(password)) {
    upperCaseScore = 1;
  }

  // Score based on lower case characters
  RegExp lowerCaseRegex = RegExp(r'[a-z]');
  if (lowerCaseRegex.hasMatch(password)) {
    lowerCaseScore = 1;
  }

  // Score based on digits
  RegExp digitsRegex = RegExp(r'\d');
  if (digitsRegex.hasMatch(password)) {
    digitsScore = 1;
  }

  // Score based on special characters
  RegExp specialCharsRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
  if (specialCharsRegex.hasMatch(password)) {
    specialCharsScore = 1;
  }

  // Calculate total score
  totalScore = lengthScore + upperCaseScore + lowerCaseScore + digitsScore + specialCharsScore;

  // Calculate strength percentage
  double strengthPercentage = (totalScore / 5) * 100; // Assuming 5 rules in total

  // Check if password is strong
  bool isStrong = strengthPercentage >= 80; // You can adjust this threshold according to your requirements

  return PasswordStrengthResult(strengthPercentage, isStrong);
}
