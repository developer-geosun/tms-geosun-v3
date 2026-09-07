package com.geosun.tms.auth.domain.profile;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class EdrpouChecksumTest {

  @Test
  void acceptsKnownEdrpou8() {
    // Відомий валідний ЄДРПОУ (перша гілка ваг)
    assertThat(EdrpouChecksum.isValid("14360570")).isTrue();
  }

  @Test
  void acceptsEdrpou8WithSecondaryWeights() {
    // Підібрано так, щоб перша сума % 11 >= 10
    String digits7 = findSecondaryPathPrefix();
    int check = computeEdrpouCheck(digits7);
    assertThat(EdrpouChecksum.isValid(digits7 + check)).isTrue();
  }

  @Test
  void rejectsWrongLength() {
    assertThat(EdrpouChecksum.isValid("1234567")).isFalse();
    assertThat(EdrpouChecksum.isValid("123456789")).isFalse();
    assertThat(EdrpouChecksum.isValid("12345678901")).isFalse();
  }

  @Test
  void acceptsValidRnokpp10() {
    String body = "328930958";
    int k = computeRnokppCheck(body);
    assertThat(k).isBetween(0, 9);
    assertThat(EdrpouChecksum.isValid(body + k)).isTrue();
  }

  @Test
  void rejectsRnokppWhenKEquals10() {
    String body = findRnokppBodyWithK10();
    assertThat(EdrpouChecksum.isValid(body + "0")).isFalse();
  }

  @Test
  void normalizesSeparators() {
    assertThat(EdrpouChecksum.normalizeDigits("14-360 570")).isEqualTo("14360570");
    assertThat(EdrpouChecksum.isValid("14-360-570")).isTrue();
  }

  private static String findSecondaryPathPrefix() {
    int[] w1 = {1, 2, 3, 4, 5, 6, 7};
    for (int n = 1_000_000; n < 9_999_999; n++) {
      String d = String.format("%07d", n);
      int sum = 0;
      for (int i = 0; i < 7; i++) {
        sum += Character.getNumericValue(d.charAt(i)) * w1[i];
      }
      if (sum % 11 >= 10) {
        return d;
      }
    }
    throw new IllegalStateException("no secondary prefix");
  }

  private static int computeEdrpouCheck(String digits7) {
    int[] w1 = {1, 2, 3, 4, 5, 6, 7};
    int sum = 0;
    for (int i = 0; i < 7; i++) {
      sum += Character.getNumericValue(digits7.charAt(i)) * w1[i];
    }
    int k = sum % 11;
    if (k < 10) {
      return k;
    }
    int[] w2 = {3, 4, 5, 6, 7, 8, 9};
    sum = 0;
    for (int i = 0; i < 7; i++) {
      sum += Character.getNumericValue(digits7.charAt(i)) * w2[i];
    }
    k = sum % 11;
    return k < 10 ? k : 0;
  }

  private static int computeRnokppCheck(String digits9) {
    int[] w = {-1, 5, 7, 9, 4, 6, 10, 5, 7};
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += Character.getNumericValue(digits9.charAt(i)) * w[i];
    }
    return Math.floorMod(sum, 11);
  }

  private static String findRnokppBodyWithK10() {
    for (long n = 100_000_000L; n < 100_500_000L; n++) {
      String d = String.format("%09d", n);
      if (computeRnokppCheck(d) == 10) {
        return d;
      }
    }
    throw new IllegalStateException("no k==10 body");
  }
}
