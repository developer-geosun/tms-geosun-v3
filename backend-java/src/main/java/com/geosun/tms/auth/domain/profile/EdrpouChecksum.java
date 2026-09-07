package com.geosun.tms.auth.domain.profile;

/**
 * Перевірка контрольної суми коду в ЄДР: 8 цифр (ЄДРПОУ юрособи) або 10 (код ФОП / РНОКПП).
 */
public final class EdrpouChecksum {

  private static final int[] WEIGHTS_8_PRIMARY = {1, 2, 3, 4, 5, 6, 7};
  private static final int[] WEIGHTS_8_SECONDARY = {3, 4, 5, 6, 7, 8, 9};
  private static final int[] WEIGHTS_10 = {-1, 5, 7, 9, 4, 6, 10, 5, 7};

  private EdrpouChecksum() {}

  /** Залишає лише цифри з вводу. */
  public static String normalizeDigits(String raw) {
    if (raw == null) {
      return "";
    }
    StringBuilder sb = new StringBuilder(raw.length());
    for (int i = 0; i < raw.length(); i++) {
      char ch = raw.charAt(i);
      if (ch >= '0' && ch <= '9') {
        sb.append(ch);
      }
    }
    return sb.toString();
  }

  /** {@code true}, якщо код валідний (рівно 8 або 10 цифр і контрольна сума). */
  public static boolean isValid(String raw) {
    String digits = normalizeDigits(raw);
    if (digits.length() == 8) {
      return isValidEdrpou8(digits);
    }
    if (digits.length() == 10) {
      return isValidRnokpp10(digits);
    }
    return false;
  }

  private static boolean isValidEdrpou8(String digits) {
    int k = weightedSum(digits, WEIGHTS_8_PRIMARY) % 11;
    int check;
    if (k < 10) {
      check = k;
    } else {
      k = weightedSum(digits, WEIGHTS_8_SECONDARY) % 11;
      check = k < 10 ? k : 0;
    }
    return Character.getNumericValue(digits.charAt(7)) == check;
  }

  private static boolean isValidRnokpp10(String digits) {
    // Java % для від'ємних сум може дати від'ємний залишок
    int k = Math.floorMod(weightedSum(digits, WEIGHTS_10), 11);
    if (k == 10) {
      return false;
    }
    return Character.getNumericValue(digits.charAt(9)) == k;
  }

  private static int weightedSum(String digits, int[] weights) {
    int sum = 0;
    for (int i = 0; i < weights.length; i++) {
      sum += Character.getNumericValue(digits.charAt(i)) * weights[i];
    }
    return sum;
  }
}
