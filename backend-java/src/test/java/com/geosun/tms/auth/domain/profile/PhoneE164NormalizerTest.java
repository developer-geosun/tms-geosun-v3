package com.geosun.tms.auth.domain.profile;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.api.Test;

class PhoneE164NormalizerTest {

  @Test
  void normalizesSpacesAndDashes() {
    assertThat(PhoneE164Normalizer.normalize("+380 67-111-22-33")).isEqualTo("+380671112233");
  }

  @Test
  void rejectsWithoutPlus() {
    assertThatThrownBy(() -> PhoneE164Normalizer.normalize("380671112233"))
        .isInstanceOf(IllegalArgumentException.class);
  }

  @Test
  void masksForLog() {
    assertThat(PhoneE164Normalizer.maskForLog("+380671112233")).contains("*****");
  }
}
