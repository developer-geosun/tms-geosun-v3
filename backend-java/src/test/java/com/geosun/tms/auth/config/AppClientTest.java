package com.geosun.tms.auth.config;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class AppClientTest {

  @Test
  void fromHeader_blankOrUnknown_defaultsToAngular() {
    assertThat(AppClient.fromHeader(null)).isEqualTo(AppClient.ANGULAR);
    assertThat(AppClient.fromHeader("")).isEqualTo(AppClient.ANGULAR);
    assertThat(AppClient.fromHeader("  ")).isEqualTo(AppClient.ANGULAR);
    assertThat(AppClient.fromHeader("react")).isEqualTo(AppClient.ANGULAR);
  }

  @Test
  void fromHeader_parsesFlutterCaseInsensitive() {
    assertThat(AppClient.fromHeader("flutter")).isEqualTo(AppClient.FLUTTER);
    assertThat(AppClient.fromHeader(" Flutter ")).isEqualTo(AppClient.FLUTTER);
    assertThat(AppClient.fromHeader("ANGULAR")).isEqualTo(AppClient.ANGULAR);
  }
}
