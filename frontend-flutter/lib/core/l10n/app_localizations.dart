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
  /// **'Доступ можливий лише після підтвердження email'**
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

  /// No description provided for @homeTitle.
  ///
  /// In uk, this message translates to:
  /// **'Головна'**
  String get homeTitle;

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
  /// **'УК'**
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

  /// No description provided for @themeAzureBlue.
  ///
  /// In uk, this message translates to:
  /// **'Azure & Blue'**
  String get themeAzureBlue;

  /// No description provided for @themeRoseRed.
  ///
  /// In uk, this message translates to:
  /// **'Rose & Red'**
  String get themeRoseRed;

  /// No description provided for @themeMagentaViolet.
  ///
  /// In uk, this message translates to:
  /// **'Magenta & Violet'**
  String get themeMagentaViolet;

  /// No description provided for @themeCyanOrange.
  ///
  /// In uk, this message translates to:
  /// **'Cyan & Orange'**
  String get themeCyanOrange;
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
