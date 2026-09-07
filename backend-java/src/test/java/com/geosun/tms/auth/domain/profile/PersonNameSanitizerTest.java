package com.geosun.tms.auth.domain.profile;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class PersonNameSanitizerTest {

  @Test
  void titleCasesUkrainianAndLatin() {
    assertThat(PersonNameSanitizer.sanitize("горєліков")).isEqualTo("Горєліков");
    assertThat(PersonNameSanitizer.sanitize("MARY")).isEqualTo("Mary");
    assertThat(PersonNameSanitizer.sanitize("АННА-МАРІЯ")).isEqualTo("Анна-Марія");
  }

  @Test
  void stripsInvalidAndNormalizesApostrophe() {
    assertThat(PersonNameSanitizer.sanitize("max123im!")).isEqualTo("Maxim");
    assertThat(PersonNameSanitizer.sanitize("ДЕМ\u2019ЯН")).isEqualTo("Дем'ян");
    assertThat(PersonNameSanitizer.sanitize("Горёликов")).isEqualTo("Горликов");
  }
}
