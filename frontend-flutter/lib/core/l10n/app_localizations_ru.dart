// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'TMS GeoSun';

  @override
  String get loginTitle => 'Вход в систему';

  @override
  String get loginSubtitle => 'Войдите по email и паролю';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Пароль';

  @override
  String get loginSubmit => 'Войти';

  @override
  String get loginLoading => 'Вход...';

  @override
  String get loginSuccess => 'Успешный вход';

  @override
  String get loginError401 => 'Неверный email или пароль';

  @override
  String get loginError403 => 'Недостаточно прав доступа';

  @override
  String get loginErrorAccountDisabled =>
      'Аккаунт деактивирован. Для активации обратитесь к администратору.';

  @override
  String get loginErrorUserDeleted =>
      'Аккаунт удалён. Для возобновления обратитесь к администратору.';

  @override
  String get loginErrorEmailNotVerified =>
      'Доступ возможен только после подтверждения email';

  @override
  String get loginErrorGeneric => 'Ошибка входа, попробуйте снова';

  @override
  String get loginServiceUnavailable =>
      'Сервис временно недоступен. Попробуйте позже.';

  @override
  String get loginEmailRequired => 'Введите email';

  @override
  String get loginEmailInvalid => 'Неверный формат email';

  @override
  String get loginPasswordRequired => 'Введите пароль';

  @override
  String get loginPasswordMinLength =>
      'Пароль должен содержать не менее 8 символов';

  @override
  String get homeTitle => 'Главная';

  @override
  String get homeWelcome => 'Вы вошли как';

  @override
  String get homeRoleLabel => 'Роль';

  @override
  String get homeLogout => 'Выйти';

  @override
  String get homeLogoutLoading => 'Выход...';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsAppearanceTitle => 'Оформление';

  @override
  String get settingsButtonLabel => 'Настройки';

  @override
  String get settingsLanguageSection => 'Язык';

  @override
  String get settingsThemeModeSection => 'Режим';

  @override
  String get settingsAccentColorSection => 'Акцентный цвет';

  @override
  String get themeModeLight => 'Светлая';

  @override
  String get themeModeSystem => 'Системная';

  @override
  String get themeModeDark => 'Тёмная';

  @override
  String get languageUkShort => 'УК';

  @override
  String get languageEnShort => 'EN';

  @override
  String get languageRuShort => 'RU';

  @override
  String get languageUkrainian => 'Украинский';

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
