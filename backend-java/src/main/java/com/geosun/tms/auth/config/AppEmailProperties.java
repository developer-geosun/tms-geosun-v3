package com.geosun.tms.auth.config;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Objects;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.lang.NonNull;
import org.springframework.util.StringUtils;

/**
 * Параметри листів верифікації та скидання пароля (app.email.*).
 * Посилання в листах ведуть на frontend клієнта, який ініціював запит.
 */
@ConfigurationProperties(prefix = "app.email")
public class AppEmailProperties {

  private static final String DEFAULT_ANGULAR_APP_BASE_URL = "http://localhost:4200";
  private static final String DEFAULT_FLUTTER_APP_BASE_URL = "http://localhost:4300";
  private static final String DEFAULT_SITE_URL = "https://www.geosun.net.ua";
  private static final String DEFAULT_TELEGRAM_URL = "https://t.me/+380984894118";
  private static final String DEFAULT_WHATSAPP_URL = "https://wa.me/380984894118";
  private static final String DEFAULT_VIBER_URL = "viber://chat?number=%2B380984894118";
  private static final String DEFAULT_FACEBOOK_URL =
      "https://www.facebook.com/profile.php?id=100063988064019";
  private static final String VERIFY_EMAIL_PATH = "/verify-email";
  private static final String RESET_PASSWORD_PATH = "/reset-password";

  private String from = "no-reply@example.com";

  private long verificationExpiresSeconds = 86400;

  private long passwordResetExpiresSeconds = 3600;

  /** Базовий URL Angular-застосунку без шляху фічі. */
  private String angularAppBaseUrl = DEFAULT_ANGULAR_APP_BASE_URL;

  /** Базовий URL Flutter-застосунку без шляху фічі. */
  private String flutterAppBaseUrl = DEFAULT_FLUTTER_APP_BASE_URL;

  /** Сайт компанії GeoSun (логотип і кнопка WWW у листах). */
  private String siteUrl = DEFAULT_SITE_URL;

  private String telegramUrl = DEFAULT_TELEGRAM_URL;

  private String whatsappUrl = DEFAULT_WHATSAPP_URL;

  private String viberUrl = DEFAULT_VIBER_URL;

  private String facebookUrl = DEFAULT_FACEBOOK_URL;

  public String getFrom() {
    return from;
  }

  public void setFrom(String from) {
    this.from = from;
  }

  public long getVerificationExpiresSeconds() {
    return verificationExpiresSeconds;
  }

  public void setVerificationExpiresSeconds(long verificationExpiresSeconds) {
    this.verificationExpiresSeconds = verificationExpiresSeconds;
  }

  public long getPasswordResetExpiresSeconds() {
    return passwordResetExpiresSeconds;
  }

  public void setPasswordResetExpiresSeconds(long passwordResetExpiresSeconds) {
    this.passwordResetExpiresSeconds = passwordResetExpiresSeconds;
  }

  public String getAngularAppBaseUrl() {
    return angularAppBaseUrl;
  }

  public void setAngularAppBaseUrl(String angularAppBaseUrl) {
    this.angularAppBaseUrl = angularAppBaseUrl;
  }

  public String getFlutterAppBaseUrl() {
    return flutterAppBaseUrl;
  }

  public void setFlutterAppBaseUrl(String flutterAppBaseUrl) {
    this.flutterAppBaseUrl = flutterAppBaseUrl;
  }

  public String getSiteUrl() {
    return siteUrl;
  }

  public void setSiteUrl(String siteUrl) {
    this.siteUrl = siteUrl;
  }

  public String getTelegramUrl() {
    return telegramUrl;
  }

  public void setTelegramUrl(String telegramUrl) {
    this.telegramUrl = telegramUrl;
  }

  public String getWhatsappUrl() {
    return whatsappUrl;
  }

  public void setWhatsappUrl(String whatsappUrl) {
    this.whatsappUrl = whatsappUrl;
  }

  public String getViberUrl() {
    return viberUrl;
  }

  public void setViberUrl(String viberUrl) {
    this.viberUrl = viberUrl;
  }

  public String getFacebookUrl() {
    return facebookUrl;
  }

  public void setFacebookUrl(String facebookUrl) {
    this.facebookUrl = facebookUrl;
  }

  /** Базовий URL застосунку клієнта (без завершального слеша). */
  @NonNull
  public String resolveAppBaseUrl(@NonNull AppClient client) {
    Objects.requireNonNull(client);
    String configured = client == AppClient.FLUTTER ? flutterAppBaseUrl : angularAppBaseUrl;
    String fallback =
        client == AppClient.FLUTTER ? DEFAULT_FLUTTER_APP_BASE_URL : DEFAULT_ANGULAR_APP_BASE_URL;
    String raw =
        StringUtils.hasText(configured) ? Objects.requireNonNull(configured.trim()) : fallback;
    return stripTrailingSlash(raw);
  }

  /** Назва клієнта для тіла листа (Angular / Flutter). */
  @NonNull
  public String resolveClientDisplayName(@NonNull AppClient client) {
    return Objects.requireNonNull(Objects.requireNonNull(client).displayName());
  }

  /** Сайт компанії для логотипа та кнопки WWW. */
  @NonNull
  public String resolveSiteUrl() {
    return resolveOrDefault(siteUrl, DEFAULT_SITE_URL);
  }

  @NonNull
  public String resolveTelegramUrl() {
    return resolveOrDefault(telegramUrl, DEFAULT_TELEGRAM_URL);
  }

  @NonNull
  public String resolveWhatsappUrl() {
    return resolveOrDefault(whatsappUrl, DEFAULT_WHATSAPP_URL);
  }

  @NonNull
  public String resolveViberUrl() {
    return resolveOrDefault(viberUrl, DEFAULT_VIBER_URL);
  }

  @NonNull
  public String resolveFacebookUrl() {
    return resolveOrDefault(facebookUrl, DEFAULT_FACEBOOK_URL);
  }

  /** Повне посилання верифікації email для клієнта. */
  @NonNull
  public String buildVerificationLink(@NonNull AppClient client, @NonNull String rawToken) {
    return buildActionLink(client, VERIFY_EMAIL_PATH, rawToken);
  }

  /** Повне посилання скидання пароля для клієнта. */
  @NonNull
  public String buildPasswordResetLink(@NonNull AppClient client, @NonNull String rawToken) {
    return buildActionLink(client, RESET_PASSWORD_PATH, rawToken);
  }

  @NonNull
  private String buildActionLink(
      @NonNull AppClient client, @NonNull String path, @NonNull String rawToken) {
    String token = Objects.requireNonNull(rawToken);
    String url = resolveAppBaseUrl(client) + path;
    String delimiter = url.contains("?") ? "&" : "?";
    return url + delimiter + "token=" + URLEncoder.encode(token, StandardCharsets.UTF_8);
  }

  @NonNull
  private static String stripTrailingSlash(@NonNull String value) {
    String trimmed = value.trim();
    while (trimmed.endsWith("/")) {
      trimmed = trimmed.substring(0, trimmed.length() - 1);
    }
    return trimmed;
  }

  @NonNull
  private static String resolveOrDefault(String configured, @NonNull String fallback) {
    if (StringUtils.hasText(configured)) {
      return Objects.requireNonNull(configured.trim());
    }
    return fallback;
  }
}
