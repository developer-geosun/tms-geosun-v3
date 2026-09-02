package com.geosun.tms.auth.config;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class AppEmailPropertiesTest {

  @Test
  void buildsVerificationAndResetLinksFromAppBase() {
    AppEmailProperties properties = new AppEmailProperties();
    properties.setAngularAppBaseUrl("https://example.com/tms-geosun-v3/");
    properties.setFlutterAppBaseUrl("https://example.com/tms-geosun-v3/flutter/");

    assertThat(properties.buildVerificationLink(AppClient.ANGULAR, "tok en"))
        .isEqualTo("https://example.com/tms-geosun-v3/verify-email?token=tok+en");
    assertThat(properties.buildPasswordResetLink(AppClient.FLUTTER, "abc"))
        .isEqualTo("https://example.com/tms-geosun-v3/flutter/reset-password?token=abc");
    assertThat(properties.resolveAppBaseUrl(AppClient.FLUTTER))
        .isEqualTo("https://example.com/tms-geosun-v3/flutter");
    assertThat(properties.resolveClientDisplayName(AppClient.FLUTTER)).isEqualTo("Flutter");
    assertThat(properties.resolveSiteUrl()).isEqualTo("https://www.geosun.net.ua");
    assertThat(properties.resolveTelegramUrl()).isEqualTo("https://t.me/+380984894118");
  }

  @Test
  void usesLocalDefaultsWhenBaseUrlBlank() {
    AppEmailProperties properties = new AppEmailProperties();
    properties.setAngularAppBaseUrl("  ");
    properties.setFlutterAppBaseUrl(null);

    assertThat(properties.buildVerificationLink(AppClient.ANGULAR, "a"))
        .isEqualTo("http://localhost:4200/verify-email?token=a");
    assertThat(properties.buildPasswordResetLink(AppClient.FLUTTER, "b"))
        .isEqualTo("http://localhost:4300/reset-password?token=b");
  }
}
