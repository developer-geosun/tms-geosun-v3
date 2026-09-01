package com.geosun.tms.auth.config;

import java.util.Locale;
import org.springframework.lang.NonNull;
import org.springframework.lang.Nullable;

/**
 * Клієнт, який ініціював auth-запит (посилання в листах ведуть на його URL).
 */
public enum AppClient {
  ANGULAR("angular", "Angular"),
  FLUTTER("flutter", "Flutter");

  /** HTTP-заголовок з ідентифікатором клієнта. */
  public static final String HEADER_NAME = "X-App-Client";

  private final String headerValue;
  private final String displayName;

  AppClient(String headerValue, String displayName) {
    this.headerValue = headerValue;
    this.displayName = displayName;
  }

  public String headerValue() {
    return headerValue;
  }

  public String displayName() {
    return displayName;
  }

  /**
   * Розбирає {@code X-App-Client}. Невідоме або порожнє значення — Angular
   * (зворотна сумісність для curl / старих клієнтів).
   */
  @NonNull
  public static AppClient fromHeader(@Nullable String raw) {
    if (raw == null || raw.isBlank()) {
      return ANGULAR;
    }
    String normalized = raw.trim().toLowerCase(Locale.ROOT);
    if (FLUTTER.headerValue.equals(normalized)) {
      return FLUTTER;
    }
    return ANGULAR;
  }
}
