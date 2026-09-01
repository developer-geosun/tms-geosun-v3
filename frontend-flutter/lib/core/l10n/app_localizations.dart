import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uk'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In uk, this message translates to:
  /// **'TMS GeoSun'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In uk, this message translates to:
  /// **'Вхід до системи'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Увійдіть за email та паролем'**
  String get loginSubtitle;

  /// No description provided for @loginEmail.
  ///
  /// In uk, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In uk, this message translates to:
  /// **'Пароль'**
  String get loginPassword;

  /// No description provided for @loginSubmit.
  ///
  /// In uk, this message translates to:
  /// **'Увійти'**
  String get loginSubmit;

  /// No description provided for @loginLoading.
  ///
  /// In uk, this message translates to:
  /// **'Вхід...'**
  String get loginLoading;

  /// No description provided for @loginSuccess.
  ///
  /// In uk, this message translates to:
  /// **'Успішний вхід'**
  String get loginSuccess;

  /// No description provided for @loginError401.
  ///
  /// In uk, this message translates to:
  /// **'Невірний email або пароль'**
  String get loginError401;

  /// No description provided for @loginError403.
  ///
  /// In uk, this message translates to:
  /// **'Недостатньо прав доступу'**
  String get loginError403;

  /// No description provided for @loginErrorAccountDisabled.
  ///
  /// In uk, this message translates to:
  /// **'Акаунт деактивовано. Для активації зверніться до адміністратора.'**
  String get loginErrorAccountDisabled;

  /// No description provided for @loginErrorUserDeleted.
  ///
  /// In uk, this message translates to:
  /// **'Акаунт видалено. Для відновлення зверніться до адміністратора.'**
  String get loginErrorUserDeleted;

  /// No description provided for @loginErrorEmailNotVerified.
  ///
  /// In uk, this message translates to:
  /// **'Email ще не підтверджено. Перевірте пошту (і папку «Спам»), відкрийте посилання з листа та повторіть вхід.'**
  String get loginErrorEmailNotVerified;

  /// No description provided for @loginErrorGeneric.
  ///
  /// In uk, this message translates to:
  /// **'Помилка входу, спробуйте ще раз'**
  String get loginErrorGeneric;

  /// No description provided for @loginServiceUnavailable.
  ///
  /// In uk, this message translates to:
  /// **'Сервіс тимчасово недоступний. Спробуйте пізніше.'**
  String get loginServiceUnavailable;

  /// No description provided for @loginEmailRequired.
  ///
  /// In uk, this message translates to:
  /// **'Введіть email'**
  String get loginEmailRequired;

  /// No description provided for @loginEmailInvalid.
  ///
  /// In uk, this message translates to:
  /// **'Невірний формат email'**
  String get loginEmailInvalid;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In uk, this message translates to:
  /// **'Введіть пароль'**
  String get loginPasswordRequired;

  /// No description provided for @loginPasswordMinLength.
  ///
  /// In uk, this message translates to:
  /// **'Пароль має містити щонайменше 8 символів'**
  String get loginPasswordMinLength;

  /// No description provided for @loginNoAccount.
  ///
  /// In uk, this message translates to:
  /// **'Ще не маєте акаунта?'**
  String get loginNoAccount;

  /// No description provided for @loginForgotPassword.
  ///
  /// In uk, this message translates to:
  /// **'Забули пароль?'**
  String get loginForgotPassword;

  /// No description provided for @authRegister.
  ///
  /// In uk, this message translates to:
  /// **'Реєстрація'**
  String get authRegister;

  /// No description provided for @authLogin.
  ///
  /// In uk, this message translates to:
  /// **'Увійти'**
  String get authLogin;

  /// No description provided for @registerTitle.
  ///
  /// In uk, this message translates to:
  /// **'Створити акаунт'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Зареєструйтеся за email та паролем'**
  String get registerSubtitle;

  /// No description provided for @registerConfirmPassword.
  ///
  /// In uk, this message translates to:
  /// **'Підтвердіть пароль'**
  String get registerConfirmPassword;

  /// No description provided for @registerPasswordRule.
  ///
  /// In uk, this message translates to:
  /// **'Пароль має містити щонайменше одну літеру та одну цифру'**
  String get registerPasswordRule;

  /// No description provided for @registerPasswordMismatch.
  ///
  /// In uk, this message translates to:
  /// **'Паролі не збігаються'**
  String get registerPasswordMismatch;

  /// No description provided for @registerSubmit.
  ///
  /// In uk, this message translates to:
  /// **'Зареєструватися'**
  String get registerSubmit;

  /// No description provided for @registerLoading.
  ///
  /// In uk, this message translates to:
  /// **'Створення акаунта...'**
  String get registerLoading;

  /// No description provided for @registerSuccess.
  ///
  /// In uk, this message translates to:
  /// **'Акаунт успішно створено. Перевірте пошту для підтвердження email'**
  String get registerSuccess;

  /// No description provided for @registerError409.
  ///
  /// In uk, this message translates to:
  /// **'Користувач з таким email вже існує'**
  String get registerError409;

  /// No description provided for @registerError429.
  ///
  /// In uk, this message translates to:
  /// **'Занадто багато спроб, спробуйте пізніше'**
  String get registerError429;

  /// No description provided for @registerErrorGeneric.
  ///
  /// In uk, this message translates to:
  /// **'Помилка реєстрації, перевірте дані'**
  String get registerErrorGeneric;

  /// No description provided for @registerHaveAccount.
  ///
  /// In uk, this message translates to:
  /// **'Вже маєте акаунт?'**
  String get registerHaveAccount;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In uk, this message translates to:
  /// **'Відновлення пароля'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Вкажіть email — надішлемо посилання для скидання пароля'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordSubmit.
  ///
  /// In uk, this message translates to:
  /// **'Надіслати посилання'**
  String get forgotPasswordSubmit;

  /// No description provided for @forgotPasswordLoading.
  ///
  /// In uk, this message translates to:
  /// **'Надсилаємо...'**
  String get forgotPasswordLoading;

  /// No description provided for @forgotPasswordSuccess.
  ///
  /// In uk, this message translates to:
  /// **'Якщо акаунт існує, ми надіслали лист із посиланням для скидання пароля'**
  String get forgotPasswordSuccess;

  /// No description provided for @forgotPasswordErrorGeneric.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося надіслати лист. Спробуйте пізніше'**
  String get forgotPasswordErrorGeneric;

  /// No description provided for @forgotPasswordBackToLogin.
  ///
  /// In uk, this message translates to:
  /// **'Повернутися до входу'**
  String get forgotPasswordBackToLogin;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In uk, this message translates to:
  /// **'Новий пароль'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Введіть новий пароль для акаунта'**
  String get resetPasswordSubtitle;

  /// No description provided for @resetPasswordResolvingAccount.
  ///
  /// In uk, this message translates to:
  /// **'Перевіряємо посилання...'**
  String get resetPasswordResolvingAccount;

  /// No description provided for @resetPasswordPassword.
  ///
  /// In uk, this message translates to:
  /// **'Новий пароль'**
  String get resetPasswordPassword;

  /// No description provided for @resetPasswordSubmit.
  ///
  /// In uk, this message translates to:
  /// **'Зберегти пароль'**
  String get resetPasswordSubmit;

  /// No description provided for @resetPasswordLoading.
  ///
  /// In uk, this message translates to:
  /// **'Збереження...'**
  String get resetPasswordLoading;

  /// No description provided for @resetPasswordSuccess.
  ///
  /// In uk, this message translates to:
  /// **'Пароль оновлено. Увійдіть з новим паролем'**
  String get resetPasswordSuccess;

  /// No description provided for @resetPasswordMissingToken.
  ///
  /// In uk, this message translates to:
  /// **'Посилання для скидання пароля відсутнє або пошкоджене'**
  String get resetPasswordMissingToken;

  /// No description provided for @resetPasswordRequestAgain.
  ///
  /// In uk, this message translates to:
  /// **'Запитати нове посилання'**
  String get resetPasswordRequestAgain;

  /// No description provided for @resetPasswordErrorInvalid.
  ///
  /// In uk, this message translates to:
  /// **'Посилання недійсне або застаріле'**
  String get resetPasswordErrorInvalid;

  /// No description provided for @resetPasswordErrorGeneric.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося оновити пароль. Спробуйте пізніше'**
  String get resetPasswordErrorGeneric;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In uk, this message translates to:
  /// **'Підтвердження email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Перевіряємо посилання підтвердження'**
  String get verifyEmailSubtitle;

  /// No description provided for @verifyEmailLoading.
  ///
  /// In uk, this message translates to:
  /// **'Підтверджуємо email...'**
  String get verifyEmailLoading;

  /// No description provided for @verifyEmailSuccess.
  ///
  /// In uk, this message translates to:
  /// **'Email підтверджено. Можна увійти'**
  String get verifyEmailSuccess;

  /// No description provided for @verifyEmailInvalid.
  ///
  /// In uk, this message translates to:
  /// **'Посилання підтвердження недійсне або застаріле'**
  String get verifyEmailInvalid;

  /// No description provided for @verifyEmailError.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося підтвердити email. Спробуйте пізніше'**
  String get verifyEmailError;

  /// No description provided for @verifyEmailToLogin.
  ///
  /// In uk, this message translates to:
  /// **'Перейти до входу'**
  String get verifyEmailToLogin;

  /// No description provided for @homeTitle.
  ///
  /// In uk, this message translates to:
  /// **'Головна'**
  String get homeTitle;

  /// No description provided for @navHome.
  ///
  /// In uk, this message translates to:
  /// **'Головна'**
  String get navHome;

  /// No description provided for @navDirectories.
  ///
  /// In uk, this message translates to:
  /// **'Довідники'**
  String get navDirectories;

  /// No description provided for @directoriesPlaceholder.
  ///
  /// In uk, this message translates to:
  /// **'Розділ «Довідники» у розробці.'**
  String get directoriesPlaceholder;

  /// No description provided for @homeWelcome.
  ///
  /// In uk, this message translates to:
  /// **'Ви увійшли як'**
  String get homeWelcome;

  /// No description provided for @homeRoleLabel.
  ///
  /// In uk, this message translates to:
  /// **'Роль'**
  String get homeRoleLabel;

  /// No description provided for @homeLogout.
  ///
  /// In uk, this message translates to:
  /// **'Вийти'**
  String get homeLogout;

  /// No description provided for @homeLogoutLoading.
  ///
  /// In uk, this message translates to:
  /// **'Вихід...'**
  String get homeLogoutLoading;

  /// No description provided for @settingsTitle.
  ///
  /// In uk, this message translates to:
  /// **'Налаштування'**
  String get settingsTitle;

  /// No description provided for @settingsAppearanceTitle.
  ///
  /// In uk, this message translates to:
  /// **'Оформлення'**
  String get settingsAppearanceTitle;

  /// No description provided for @settingsButtonLabel.
  ///
  /// In uk, this message translates to:
  /// **'Налаштування'**
  String get settingsButtonLabel;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In uk, this message translates to:
  /// **'Мова'**
  String get settingsLanguageSection;

  /// No description provided for @settingsThemeModeSection.
  ///
  /// In uk, this message translates to:
  /// **'Режим'**
  String get settingsThemeModeSection;

  /// No description provided for @settingsAccentColorSection.
  ///
  /// In uk, this message translates to:
  /// **'Акцентний колір'**
  String get settingsAccentColorSection;

  /// No description provided for @themeModeLight.
  ///
  /// In uk, this message translates to:
  /// **'Світла'**
  String get themeModeLight;

  /// No description provided for @themeModeSystem.
  ///
  /// In uk, this message translates to:
  /// **'Системна'**
  String get themeModeSystem;

  /// No description provided for @themeModeDark.
  ///
  /// In uk, this message translates to:
  /// **'Темна'**
  String get themeModeDark;

  /// No description provided for @languageUkShort.
  ///
  /// In uk, this message translates to:
  /// **'UA'**
  String get languageUkShort;

  /// No description provided for @languageEnShort.
  ///
  /// In uk, this message translates to:
  /// **'EN'**
  String get languageEnShort;

  /// No description provided for @languageRuShort.
  ///
  /// In uk, this message translates to:
  /// **'RU'**
  String get languageRuShort;

  /// No description provided for @languageUkrainian.
  ///
  /// In uk, this message translates to:
  /// **'Українська'**
  String get languageUkrainian;

  /// No description provided for @languageEnglish.
  ///
  /// In uk, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageRussian.
  ///
  /// In uk, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @themeIndigo.
  ///
  /// In uk, this message translates to:
  /// **'Індиго'**
  String get themeIndigo;

  /// No description provided for @themeEmerald.
  ///
  /// In uk, this message translates to:
  /// **'Смарагд'**
  String get themeEmerald;

  /// No description provided for @themeAmber.
  ///
  /// In uk, this message translates to:
  /// **'Бурштин'**
  String get themeAmber;

  /// No description provided for @themeRaspberry.
  ///
  /// In uk, this message translates to:
  /// **'Малина'**
  String get themeRaspberry;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
