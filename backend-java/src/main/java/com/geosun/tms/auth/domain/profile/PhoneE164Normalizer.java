package com.geosun.tms.auth.domain.profile;

/**
 * Нормалізація телефону до E.164: лише {@code +} і цифри, max 32.
 *
 * <p>Паттерн як {@link com.geosun.tms.auth.domain.EmailNormalizer}.
 */
public final class PhoneE164Normalizer {

  public static final int MAX_LENGTH = 32;

  private PhoneE164Normalizer() {}

  /**
   * Повертає нормалізований номер ({@code +} і цифри).
   *
   * @throws IllegalArgumentException якщо порожньо, без цифр, без {@code +} або довше MAX_LENGTH
   */
  public static String normalize(String raw) {
    if (raw == null || raw.isBlank()) {
      throw new IllegalArgumentException("Phone is required");
    }
    StringBuilder sb = new StringBuilder(raw.length());
    for (int i = 0; i < raw.length(); i++) {
      char ch = raw.charAt(i);
      if (ch == '+' && sb.isEmpty()) {
        sb.append('+');
      } else if (ch >= '0' && ch <= '9') {
        sb.append(ch);
      }
    }
    if (sb.length() < 2 || sb.charAt(0) != '+') {
      throw new IllegalArgumentException("Phone must be E.164 (+ and digits)");
    }
    boolean hasDigit = false;
    for (int i = 1; i < sb.length(); i++) {
      if (sb.charAt(i) >= '0' && sb.charAt(i) <= '9') {
        hasDigit = true;
        break;
      }
    }
    if (!hasDigit) {
      throw new IllegalArgumentException("Phone must contain digits");
    }
    if (sb.length() > MAX_LENGTH) {
      throw new IllegalArgumentException("Phone exceeds max length");
    }
    return sb.toString();
  }

  /** Маска для логів: {@code +380*****1234}. */
  public static String maskForLog(String phone) {
    if (phone == null || phone.length() < 6) {
      return "****";
    }
    int keepStart = Math.min(4, phone.length());
    int keepEnd = Math.min(4, phone.length() - keepStart);
    String start = phone.substring(0, keepStart);
    String end = phone.substring(phone.length() - keepEnd);
    return start + "*****" + end;
  }
}
