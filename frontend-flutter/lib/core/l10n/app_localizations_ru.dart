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
      'Email ещё не подтверждён. Проверьте почту (и папку «Спам»), перейдите по ссылке в письме и повторите вход.';

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
  String get loginNoAccount => 'Ещё нет аккаунта?';

  @override
  String get loginForgotPassword => 'Забыли пароль?';

  @override
  String get authRegister => 'Регистрация';

  @override
  String get authLogin => 'Войти';

  @override
  String get registerTitle => 'Создать аккаунт';

  @override
  String get registerSubtitle => 'Зарегистрируйтесь по email и паролю';

  @override
  String get registerConfirmPassword => 'Подтвердите пароль';

  @override
  String get registerPasswordRule =>
      'Пароль должен содержать минимум одну букву и одну цифру';

  @override
  String get registerPasswordMismatch => 'Пароли не совпадают';

  @override
  String get registerSubmit => 'Зарегистрироваться';

  @override
  String get registerLoading => 'Создание аккаунта...';

  @override
  String get registerSuccess =>
      'Аккаунт успешно создан. Проверьте почту для подтверждения email';

  @override
  String get registerError409 => 'Пользователь с таким email уже существует';

  @override
  String get registerError429 => 'Слишком много попыток, попробуйте позже';

  @override
  String get registerErrorGeneric => 'Ошибка регистрации, проверьте данные';

  @override
  String get registerHaveAccount => 'Уже есть аккаунт?';

  @override
  String get forgotPasswordTitle => 'Восстановление пароля';

  @override
  String get forgotPasswordSubtitle =>
      'Укажите email — отправим ссылку для сброса пароля';

  @override
  String get forgotPasswordSubmit => 'Отправить ссылку';

  @override
  String get forgotPasswordLoading => 'Отправляем...';

  @override
  String get forgotPasswordSuccess =>
      'Если аккаунт существует, мы отправили письмо со ссылкой для сброса пароля';

  @override
  String get forgotPasswordErrorGeneric =>
      'Не удалось отправить письмо. Попробуйте позже';

  @override
  String get forgotPasswordBackToLogin => 'Вернуться ко входу';

  @override
  String get resetPasswordTitle => 'Новый пароль';

  @override
  String get resetPasswordSubtitle => 'Введите новый пароль для аккаунта';

  @override
  String get resetPasswordResolvingAccount => 'Проверяем ссылку...';

  @override
  String get resetPasswordPassword => 'Новый пароль';

  @override
  String get resetPasswordSubmit => 'Сохранить пароль';

  @override
  String get resetPasswordLoading => 'Сохранение...';

  @override
  String get resetPasswordSuccess => 'Пароль обновлён. Войдите с новым паролем';

  @override
  String get resetPasswordMissingToken =>
      'Ссылка для сброса пароля отсутствует или повреждена';

  @override
  String get resetPasswordRequestAgain => 'Запросить новую ссылку';

  @override
  String get resetPasswordErrorInvalid => 'Ссылка недействительна или устарела';

  @override
  String get resetPasswordErrorGeneric =>
      'Не удалось обновить пароль. Попробуйте позже';

  @override
  String get verifyEmailTitle => 'Подтверждение email';

  @override
  String get verifyEmailSubtitle => 'Проверяем ссылку подтверждения';

  @override
  String get verifyEmailLoading => 'Подтверждаем email...';

  @override
  String get verifyEmailSuccess => 'Email подтверждён. Можно войти';

  @override
  String get verifyEmailInvalid =>
      'Ссылка подтверждения недействительна или устарела';

  @override
  String get verifyEmailError =>
      'Не удалось подтвердить email. Попробуйте позже';

  @override
  String get verifyEmailToLogin => 'Перейти ко входу';

  @override
  String get homeTitle => 'Главная';

  @override
  String get navHome => 'Главная';

  @override
  String get navDirectories => 'Справочники';

  @override
  String get directoryCountries => 'Справочник стран';

  @override
  String get directoryCurrencies => 'Справочник валют';

  @override
  String get directoryExchangeRates => 'Справочник курсов валют';

  @override
  String get directoryBack => 'Назад к справочникам';

  @override
  String get directorySearch => 'Поиск';

  @override
  String get directoryClearSearch => 'Очистить поиск';

  @override
  String get directoryRefresh => 'Обновить';

  @override
  String get directoryEmpty => 'Записи не найдены';

  @override
  String get directoryLoadFailed => 'Не удалось загрузить справочник';

  @override
  String get directoryAccessDenied =>
      'Недостаточно прав для просмотра справочника';

  @override
  String get directoryCodeAlpha2 => 'ISO-2';

  @override
  String get directoryCodeAlpha3 => 'ISO-3';

  @override
  String get directoryName => 'Название';

  @override
  String get directoryNameUk => 'Название (UA)';

  @override
  String get directoryNameEn => 'Название (EN)';

  @override
  String get directoryNameRu => 'Название (RU)';

  @override
  String get directoryCurrencyCode => 'Код';

  @override
  String get directoryCurrencyName => 'Название';

  @override
  String get directoryCurrencyActive => 'Активна';

  @override
  String get directoryCurrencyInactive => 'Неактивна';

  @override
  String get directoryNbuUnits => 'Ед. НБУ';

  @override
  String get directoryRatePerUnit => 'Курс UAH/ед.';

  @override
  String get directoryRateDate => 'Дата курса';

  @override
  String get directoryLoadRates => 'Показать курсы';

  @override
  String get directorySyncNbu => 'Обновить курсы НБУ';

  @override
  String get directorySyncing => 'Синхронизация...';

  @override
  String get directorySyncSuccess => 'Курсы НБУ обновлены';

  @override
  String get directorySyncFailed => 'Не удалось обновить курсы НБУ';

  @override
  String get directoryRatesLoadFailed => 'Не удалось загрузить курсы на дату';

  @override
  String get directoryRatesEmpty =>
      'Курсы НБУ ещё не загружены. Нажмите «Обновить курсы НБУ».';

  @override
  String directoryRatesSnapshot(String rateDate, String fetchedAt) {
    return 'Курсы НБУ на $rateDate (обновлено: $fetchedAt)';
  }

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
  String get languageUkShort => 'UA';

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
  String get themeIndigo => 'Индиго';

  @override
  String get themeEmerald => 'Смарагд';

  @override
  String get themeAmber => 'Бурштин';

  @override
  String get themeRaspberry => 'Малина';
}
