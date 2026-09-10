package com.geosun.tms.chatbot.service;

import org.springframework.lang.NonNull;

/**
 * Українські тексти відповідей бота (v1: лише locale ua).
 */
public final class ChatbotMessages {

  private ChatbotMessages() {}

  public static final String HELP =
      """
      Команди бота GeoSun TMS:
      /start — початок / меню
      /help — ця підказка
      /unlink — відв'язати Telegram від обліковки

      Щоб прив'язати обліковку: відкрийте профіль на сайті, створіть код і надішліть його сюди \
      або перейдіть за deep link.
      Після прив'язки натисніть «Поділитися номером», щоб підтвердити телефон з профілю.\
      """;

  public static final String START_NEED_CODE =
      """
      Вітаю! Щоб прив'язати Telegram до обліковки GeoSun TMS, відкрийте профіль на сайті, \
      створіть код прив'язки і надішліть його сюди (або перейдіть за посиланням з кодом).
      /help — список команд.\
      """;

  public static final String START_LINKED =
      """
      Telegram уже прив'язано до вашої обліковки.
      Натисніть «Поділитися номером», щоб підтвердити телефон з профілю, або /help.\
      """;

  public static final String ASK_SHARE_CONTACT =
      """
      Прив'язку виконано. Натисніть кнопку нижче й поділіться своїм контактом Telegram, \
      щоб підтвердити номер телефону з профілю.\
      """;

  public static final String LINK_INVALID_CODE =
      "Код недійсний, прострочений або вже використаний. Створіть новий код у профілі на сайті.";

  public static final String UNLINK_OK = "Telegram відв'язано від обліковки. До побачення!";

  public static final String UNLINK_NOT_LINKED = "Прив'язки Telegram для цього чату немає.";

  public static final String CONTACT_NOT_LINKED =
      "Спочатку прив'яжіть обліковку кодом з профілю на сайті, потім поділіться контактом.";

  public static final String CONTACT_NOT_OWN =
      "Потрібно надіслати власний контакт (кнопка «Поділитися номером»), а не чужий.";

  public static final String CONTACT_PHONE_MISMATCH =
      "Номер з контакту не збігається з телефонами у вашому профілі. Перевірте профіль на сайті"
          + " і спробуйте знову. Прив'язка Telegram залишається активною.";

  public static final String CONTACT_VERIFIED =
      "Номер підтверджено. Дякуємо! Можна закрити цей чат або використати /help.";

  public static final String UNKNOWN =
      "Не зрозумів повідомлення. Надішліть код прив'язки з профілю або /help.";

  /** Текст сповіщення ADMIN про нову реєстрацію (locale ua за замовчуванням). */
  @NonNull
  public static String userRegistered(
      @NonNull String newUserEmail, @NonNull String newUserId, @NonNull String adminCardLink) {
    return "GeoSun TMS: нова реєстрація.\nEmail: "
        + newUserEmail
        + "\nId: "
        + newUserId
        + "\nКартка: "
        + adminCardLink;
  }
}
