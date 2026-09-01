/// Правило пароля як на backend: мін. 8 символів, латинська літера та цифра.
final passwordComplexityPattern = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');

bool meetsPasswordPolicy(String password) {
  return passwordComplexityPattern.hasMatch(password);
}
