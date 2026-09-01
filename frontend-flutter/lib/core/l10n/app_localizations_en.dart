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
      'Email is not confirmed yet. Check your inbox (and Spam), open the link in the message, then sign in again.';

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
  String get loginNoAccount => 'Don\'t have an account yet?';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get authRegister => 'Sign up';

  @override
  String get authLogin => 'Sign in';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerSubtitle => 'Register with your email and password';

  @override
  String get registerConfirmPassword => 'Confirm password';

  @override
  String get registerPasswordRule =>
      'Password must contain at least one letter and one digit';

  @override
  String get registerPasswordMismatch => 'Passwords do not match';

  @override
  String get registerSubmit => 'Sign up';

  @override
  String get registerLoading => 'Creating account...';

  @override
  String get registerSuccess =>
      'Account created successfully. Check your inbox to verify your email';

  @override
  String get registerError409 => 'User with this email already exists';

  @override
  String get registerError429 => 'Too many attempts, please try later';

  @override
  String get registerErrorGeneric =>
      'Registration failed, please check your data';

  @override
  String get registerHaveAccount => 'Already have an account?';

  @override
  String get forgotPasswordTitle => 'Reset password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email and we will send a reset link';

  @override
  String get forgotPasswordSubmit => 'Send reset link';

  @override
  String get forgotPasswordLoading => 'Sending...';

  @override
  String get forgotPasswordSuccess =>
      'If an account exists, we sent an email with a password reset link';

  @override
  String get forgotPasswordErrorGeneric =>
      'Unable to send the email. Please try again later';

  @override
  String get forgotPasswordBackToLogin => 'Back to sign in';

  @override
  String get resetPasswordTitle => 'New password';

  @override
  String get resetPasswordSubtitle => 'Enter a new password for the account';

  @override
  String get resetPasswordResolvingAccount => 'Validating reset link...';

  @override
  String get resetPasswordPassword => 'New password';

  @override
  String get resetPasswordSubmit => 'Save password';

  @override
  String get resetPasswordLoading => 'Saving...';

  @override
  String get resetPasswordSuccess =>
      'Password updated. Sign in with your new password';

  @override
  String get resetPasswordMissingToken =>
      'Password reset link is missing or damaged';

  @override
  String get resetPasswordRequestAgain => 'Request a new link';

  @override
  String get resetPasswordErrorInvalid =>
      'Reset link is invalid or has expired';

  @override
  String get resetPasswordErrorGeneric =>
      'Unable to update password. Please try again later';

  @override
  String get verifyEmailTitle => 'Confirm email';

  @override
  String get verifyEmailSubtitle => 'We are checking the confirmation link';

  @override
  String get verifyEmailLoading => 'Confirming email...';

  @override
  String get verifyEmailSuccess => 'Email confirmed. You can sign in';

  @override
  String get verifyEmailInvalid =>
      'Confirmation link is invalid or has expired';

  @override
  String get verifyEmailError =>
      'Unable to confirm email. Please try again later';

  @override
  String get verifyEmailToLogin => 'Go to sign in';

  @override
  String get homeTitle => 'Home';

  @override
  String get navHome => 'Home';

  @override
  String get navDirectories => 'Directories';

  @override
  String get directoryCountries => 'Countries directory';

  @override
  String get directoryCurrencies => 'Currencies directory';

  @override
  String get directoryExchangeRates => 'Exchange rates directory';

  @override
  String get directoryBack => 'Back to directories';

  @override
  String get directorySearch => 'Search';

  @override
  String get directoryClearSearch => 'Clear search';

  @override
  String get directoryRefresh => 'Refresh';

  @override
  String get directoryEmpty => 'No records found';

  @override
  String get directoryLoadFailed => 'Failed to load the directory';

  @override
  String get directoryAccessDenied =>
      'You do not have permission to view this directory';

  @override
  String get directoryCodeAlpha2 => 'ISO-2';

  @override
  String get directoryCodeAlpha3 => 'ISO-3';

  @override
  String get directoryName => 'Name';

  @override
  String get directoryNameUk => 'Name (UA)';

  @override
  String get directoryNameEn => 'Name (EN)';

  @override
  String get directoryNameRu => 'Name (RU)';

  @override
  String get directoryCurrencyCode => 'Code';

  @override
  String get directoryCurrencyName => 'Name';

  @override
  String get directoryCurrencyActive => 'Active';

  @override
  String get directoryCurrencyInactive => 'Inactive';

  @override
  String get directoryNbuUnits => 'NBU units';

  @override
  String get directoryRatePerUnit => 'Rate UAH/unit';

  @override
  String get directoryRateDate => 'Rate date';

  @override
  String get directoryLoadRates => 'Show rates';

  @override
  String get directorySyncNbu => 'Refresh NBU rates';

  @override
  String get directorySyncing => 'Syncing...';

  @override
  String get directorySyncSuccess => 'NBU rates updated';

  @override
  String get directorySyncFailed => 'Failed to update NBU rates';

  @override
  String get directoryRatesLoadFailed =>
      'Failed to load rates for the selected date';

  @override
  String get directoryRatesEmpty =>
      'NBU rates are not loaded yet. Tap “Refresh NBU rates”.';

  @override
  String directoryRatesSnapshot(String rateDate, String fetchedAt) {
    return 'NBU rates on $rateDate (updated: $fetchedAt)';
  }

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
  String get languageUkShort => 'UA';

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
  String get themeIndigo => 'Indigo';

  @override
  String get themeEmerald => 'Emerald';

  @override
  String get themeAmber => 'Amber';

  @override
  String get themeRaspberry => 'Raspberry';
}
