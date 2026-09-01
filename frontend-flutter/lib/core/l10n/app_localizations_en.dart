// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TMS GeoSun';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle => 'Use email and password to continue';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginLoading => 'Signing in...';

  @override
  String get loginSuccess => 'Signed in successfully';

  @override
  String get loginError401 => 'Invalid email or password';

  @override
  String get loginError403 => 'You do not have enough permissions';

  @override
  String get loginErrorAccountDisabled =>
      'Account is deactivated. Contact an administrator to reactivate it.';

  @override
  String get loginErrorUserDeleted =>
      'Account has been deleted. Contact an administrator to restore it.';

  @override
  String get loginErrorEmailNotVerified =>
      'Access is available only after email confirmation';

  @override
  String get loginErrorGeneric => 'Sign in failed, please try again';

  @override
  String get loginServiceUnavailable =>
      'Service is temporarily unavailable. Please try again later.';

  @override
  String get loginEmailRequired => 'Enter email';

  @override
  String get loginEmailInvalid => 'Invalid email format';

  @override
  String get loginPasswordRequired => 'Enter password';

  @override
  String get loginPasswordMinLength => 'Password must be at least 8 characters';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeWelcome => 'Signed in as';

  @override
  String get homeRoleLabel => 'Role';

  @override
  String get homeLogout => 'Sign out';

  @override
  String get homeLogoutLoading => 'Signing out...';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearanceTitle => 'Appearance';

  @override
  String get settingsButtonLabel => 'Settings';

  @override
  String get settingsLanguageSection => 'Language';

  @override
  String get settingsThemeModeSection => 'Mode';

  @override
  String get settingsAccentColorSection => 'Accent color';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get languageUkShort => 'UK';

  @override
  String get languageEnShort => 'EN';

  @override
  String get languageRuShort => 'RU';

  @override
  String get languageUkrainian => 'Ukrainian';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Russian';

  @override
  String get themeAzureBlue => 'Azure & Blue';

  @override
  String get themeRoseRed => 'Rose & Red';

  @override
  String get themeMagentaViolet => 'Magenta & Violet';

  @override
  String get themeCyanOrange => 'Cyan & Orange';
}
