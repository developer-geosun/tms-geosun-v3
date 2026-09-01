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
  String get snackbarClose => 'Закрити';

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
      'Email ще не підтверджено. Перевірте пошту (і папку «Спам»), відкрийте посилання з листа та повторіть вхід.';

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
  String get loginNoAccount => 'Ще не маєте акаунта?';

  @override
  String get loginForgotPassword => 'Забули пароль?';

  @override
  String get authRegister => 'Реєстрація';

  @override
  String get authLogin => 'Увійти';

  @override
  String get registerTitle => 'Створити акаунт';

  @override
  String get registerSubtitle => 'Зареєструйтеся за email та паролем';

  @override
  String get registerConfirmPassword => 'Підтвердіть пароль';

  @override
  String get registerPasswordRule =>
      'Пароль має містити щонайменше одну літеру та одну цифру';

  @override
  String get registerPasswordMismatch => 'Паролі не збігаються';

  @override
  String get registerSubmit => 'Зареєструватися';

  @override
  String get registerLoading => 'Створення акаунта...';

  @override
  String get registerSuccess =>
      'Акаунт успішно створено. Перевірте пошту для підтвердження email';

  @override
  String get registerError409 => 'Користувач з таким email вже існує';

  @override
  String get registerError429 => 'Занадто багато спроб, спробуйте пізніше';

  @override
  String get registerErrorGeneric => 'Помилка реєстрації, перевірте дані';

  @override
  String get registerHaveAccount => 'Вже маєте акаунт?';

  @override
  String get forgotPasswordTitle => 'Відновлення пароля';

  @override
  String get forgotPasswordSubtitle =>
      'Вкажіть email — надішлемо посилання для скидання пароля';

  @override
  String get forgotPasswordSubmit => 'Надіслати посилання';

  @override
  String get forgotPasswordLoading => 'Надсилаємо...';

  @override
  String get forgotPasswordSuccess =>
      'Якщо акаунт існує, ми надіслали лист із посиланням для скидання пароля';

  @override
  String get forgotPasswordErrorGeneric =>
      'Не вдалося надіслати лист. Спробуйте пізніше';

  @override
  String get forgotPasswordBackToLogin => 'Повернутися до входу';

  @override
  String get resetPasswordTitle => 'Новий пароль';

  @override
  String get resetPasswordSubtitle => 'Введіть новий пароль для акаунта';

  @override
  String get resetPasswordResolvingAccount => 'Перевіряємо посилання...';

  @override
  String get resetPasswordPassword => 'Новий пароль';

  @override
  String get resetPasswordSubmit => 'Зберегти пароль';

  @override
  String get resetPasswordLoading => 'Збереження...';

  @override
  String get resetPasswordSuccess =>
      'Пароль оновлено. Увійдіть з новим паролем';

  @override
  String get resetPasswordMissingToken =>
      'Посилання для скидання пароля відсутнє або пошкоджене';

  @override
  String get resetPasswordRequestAgain => 'Запитати нове посилання';

  @override
  String get resetPasswordErrorInvalid => 'Посилання недійсне або застаріле';

  @override
  String get resetPasswordErrorGeneric =>
      'Не вдалося оновити пароль. Спробуйте пізніше';

  @override
  String get verifyEmailTitle => 'Підтвердження email';

  @override
  String get verifyEmailSubtitle => 'Перевіряємо посилання підтвердження';

  @override
  String get verifyEmailLoading => 'Підтверджуємо email...';

  @override
  String get verifyEmailSuccess => 'Email підтверджено. Можна увійти';

  @override
  String get verifyEmailInvalid =>
      'Посилання підтвердження недійсне або застаріле';

  @override
  String get verifyEmailError =>
      'Не вдалося підтвердити email. Спробуйте пізніше';

  @override
  String get verifyEmailToLogin => 'Перейти до входу';

  @override
  String get homeTitle => 'Головна';

  @override
  String get navHome => 'Головна';

  @override
  String get navDirectories => 'Довідники';

  @override
  String get directoryCountries => 'Довідник країн';

  @override
  String get directoryCurrencies => 'Довідник валют';

  @override
  String get directoryExchangeRates => 'Довідник курсів валют';

  @override
  String get directoryBack => 'Назад до довідників';

  @override
  String get directorySearch => 'Пошук';

  @override
  String get directoryClearSearch => 'Очистити пошук';

  @override
  String get directoryRefresh => 'Оновити';

  @override
  String get directoryEmpty => 'Записів не знайдено';

  @override
  String get directoryLoadFailed => 'Не вдалося завантажити довідник';

  @override
  String get directoryAccessDenied =>
      'Недостатньо прав для перегляду довідника';

  @override
  String get directoryCodeAlpha2 => 'ISO-2';

  @override
  String get directoryCodeAlpha3 => 'ISO-3';

  @override
  String get directoryName => 'Назва';

  @override
  String get directoryNameUk => 'Назва (UA)';

  @override
  String get directoryNameEn => 'Назва (EN)';

  @override
  String get directoryNameRu => 'Назва (RU)';

  @override
  String get directoryCurrencyCode => 'Код';

  @override
  String get directoryCurrencyName => 'Назва';

  @override
  String get directoryCurrencyActive => 'Активна';

  @override
  String get directoryCurrencyInactive => 'Неактивна';

  @override
  String get directoryNbuUnits => 'Од. НБУ';

  @override
  String get directoryRatePerUnit => 'Курс UAH/од.';

  @override
  String get directoryRateDate => 'Дата курсу';

  @override
  String get directoryLoadRates => 'Показати курси';

  @override
  String get directorySyncNbu => 'Оновити курси НБУ';

  @override
  String get directorySyncing => 'Синхронізація...';

  @override
  String get directorySyncSuccess => 'Курси НБУ оновлено';

  @override
  String get directorySyncFailed => 'Не вдалося оновити курси НБУ';

  @override
  String get directoryRatesLoadFailed => 'Не вдалося завантажити курси на дату';

  @override
  String get directoryRatesEmpty =>
      'Курси НБУ ще не завантажені. Натисніть «Оновити курси НБУ».';

  @override
  String directoryRatesSnapshot(String rateDate, String fetchedAt) {
    return 'Курси НБУ на $rateDate (оновлено: $fetchedAt)';
  }

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
  String get languageUkShort => 'UA';

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
  String get themeIndigo => 'Індиго';

  @override
  String get themeEmerald => 'Смарагд';

  @override
  String get themeAmber => 'Бурштин';

  @override
  String get themeRaspberry => 'Малина';
}
