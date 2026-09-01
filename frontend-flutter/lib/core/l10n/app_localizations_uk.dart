// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'TMS GeoSun';

  @override
  String get loginTitle => 'Вхід до системи';

  @override
  String get loginSubtitle => 'Увійдіть за email та паролем';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Пароль';

  @override
  String get loginSubmit => 'Увійти';

  @override
  String get loginLoading => 'Вхід...';

  @override
  String get loginSuccess => 'Успішний вхід';

  @override
  String get loginError401 => 'Невірний email або пароль';

  @override
  String get loginError403 => 'Недостатньо прав доступу';

  @override
  String get loginErrorAccountDisabled =>
      'Акаунт деактивовано. Для активації зверніться до адміністратора.';

  @override
  String get loginErrorUserDeleted =>
      'Акаунт видалено. Для відновлення зверніться до адміністратора.';

  @override
  String get loginErrorEmailNotVerified =>
      'Доступ можливий лише після підтвердження email';

  @override
  String get loginErrorGeneric => 'Помилка входу, спробуйте ще раз';

  @override
  String get loginServiceUnavailable =>
      'Сервіс тимчасово недоступний. Спробуйте пізніше.';

  @override
  String get loginEmailRequired => 'Введіть email';

  @override
  String get loginEmailInvalid => 'Невірний формат email';

  @override
  String get loginPasswordRequired => 'Введіть пароль';

  @override
  String get loginPasswordMinLength =>
      'Пароль має містити щонайменше 8 символів';

  @override
  String get homeTitle => 'Головна';

  @override
  String get homeWelcome => 'Ви увійшли як';

  @override
  String get homeRoleLabel => 'Роль';

  @override
  String get homeLogout => 'Вийти';

  @override
  String get homeLogoutLoading => 'Вихід...';

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String get settingsAppearanceTitle => 'Оформлення';

  @override
  String get settingsButtonLabel => 'Налаштування';

  @override
  String get settingsLanguageSection => 'Мова';

  @override
  String get settingsThemeModeSection => 'Режим';

  @override
  String get settingsAccentColorSection => 'Акцентний колір';

  @override
  String get themeModeLight => 'Світла';

  @override
  String get themeModeSystem => 'Системна';

  @override
  String get themeModeDark => 'Темна';

  @override
  String get languageUkShort => 'УК';

  @override
  String get languageEnShort => 'EN';

  @override
  String get languageRuShort => 'RU';

  @override
  String get languageUkrainian => 'Українська';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Русский';

  @override
  String get themeAzureBlue => 'Azure & Blue';

  @override
  String get themeRoseRed => 'Rose & Red';

  @override
  String get themeMagentaViolet => 'Magenta & Violet';

  @override
  String get themeCyanOrange => 'Cyan & Orange';
}
