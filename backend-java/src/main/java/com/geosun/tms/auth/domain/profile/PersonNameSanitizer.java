package com.geosun.tms.auth.domain.profile;

import java.util.Locale;
import java.util.Set;

/**
 * Санітизація ПІБ профілю.
 *
 * <p>Алгоритм 1:1 з Angular {@code sanitizeDriverPersonNameInput} у {@code
 * frontend-angular/src/app/pages/admin-drivers/driver-person-name.util.ts}. Водіїв не рефакторимо.
 */
public final class PersonNameSanitizer {

  private static final String LATIN = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
  private static final String UKRAINIAN =
      "АБВГҐДЕЄЖЗИІЇЙКЛМНОПРСТУФХЦЧШЩЬЮЯабвгґдеєжзиіїйклмнопрстуфхцчшщьюя";
  private static final Set<Character> APOSTROPHE_VARIANTS =
      Set.of('\'', '\u2018', '\u2019', '\u02BC', '\u02B9');
  private static final char CANONICAL_APOSTROPHE = '\'';
  private static final Set<Character> ALLOWED;
  private static final Set<Character> LETTERS;

  static {
    ALLOWED = new java.util.HashSet<>();
    LETTERS = new java.util.HashSet<>();
    for (char ch : LATIN.toCharArray()) {
      ALLOWED.add(ch);
      LETTERS.add(ch);
    }
    for (char ch : UKRAINIAN.toCharArray()) {
      ALLOWED.add(ch);
      LETTERS.add(ch);
    }
    ALLOWED.add('-');
    ALLOWED.add(CANONICAL_APOSTROPHE);
  }

  private PersonNameSanitizer() {}

  /** Залишає лише літери UKR/ENG, один дефіс підряд і апостроф. */
  public static String filterChars(String raw) {
    if (raw == null) {
      return "";
    }
    StringBuilder result = new StringBuilder(raw.length());
    for (int i = 0; i < raw.length(); i++) {
      char ch = raw.charAt(i);
      char mapped = APOSTROPHE_VARIANTS.contains(ch) ? CANONICAL_APOSTROPHE : ch;
      if (!ALLOWED.contains(mapped)) {
        continue;
      }
      if (mapped == '-' && !result.isEmpty() && result.charAt(result.length() - 1) == '-') {
        continue;
      }
      result.append(mapped);
    }
    return result.toString();
  }

  /**
   * При вводі ПІБ: зайві символи відкидаються; перша літера кожного сегмента (початок рядка та
   * після дефіса) — верхній регістр, решта — нижній (локаль uk для І/Ї/Є/Ґ).
   */
  public static String sanitize(String raw) {
    String filtered = filterChars(raw);
    if (filtered.isEmpty()) {
      return "";
    }
    Locale uk = Locale.forLanguageTag("uk");
    StringBuilder result = new StringBuilder(filtered.length());
    boolean capitalizeNext = true;
    for (int i = 0; i < filtered.length(); i++) {
      char ch = filtered.charAt(i);
      if (ch == '-') {
        result.append(ch);
        capitalizeNext = true;
        continue;
      }
      if (LETTERS.contains(ch)) {
        String s = String.valueOf(ch);
        result.append(capitalizeNext ? s.toUpperCase(uk) : s.toLowerCase(uk));
        capitalizeNext = false;
        continue;
      }
      result.append(ch);
    }
    return result.toString();
  }
}
