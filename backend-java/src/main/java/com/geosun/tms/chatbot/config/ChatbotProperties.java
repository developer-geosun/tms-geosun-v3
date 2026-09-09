package com.geosun.tms.chatbot.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.context.properties.NestedConfigurationProperty;

/**
 * Конфігурація чат-ботів (app.chatbot.*). За замовчуванням усе вимкнено.
 */
@ConfigurationProperties(prefix = "app.chatbot")
public class ChatbotProperties {

  /** Глобальний вимикач модуля. */
  private boolean enabled = false;

  /** Публічний HTTPS base URL бекенду для setWebhook (без trailing slash). */
  private String publicBaseUrl = "";

  /** Скільки днів зберігати bot_message_log. */
  private int cleanupRetentionDays = 90;

  @NestedConfigurationProperty private final Telegram telegram = new Telegram();

  public boolean isEnabled() {
    return enabled;
  }

  public void setEnabled(boolean enabled) {
    this.enabled = enabled;
  }

  public String getPublicBaseUrl() {
    return publicBaseUrl;
  }

  public void setPublicBaseUrl(String publicBaseUrl) {
    this.publicBaseUrl = publicBaseUrl;
  }

  public int getCleanupRetentionDays() {
    return cleanupRetentionDays;
  }

  public void setCleanupRetentionDays(int cleanupRetentionDays) {
    this.cleanupRetentionDays = cleanupRetentionDays;
  }

  public Telegram getTelegram() {
    return telegram;
  }

  /** Налаштування Telegram Bot API. */
  public static class Telegram {

    private boolean enabled = false;

    private String botToken = "";

    private String secretToken = "";

    private String botUsername = "";

    private int timeoutMillis = 10000;

    public boolean isEnabled() {
      return enabled;
    }

    public void setEnabled(boolean enabled) {
      this.enabled = enabled;
    }

    public String getBotToken() {
      return botToken;
    }

    public void setBotToken(String botToken) {
      this.botToken = botToken;
    }

    public String getSecretToken() {
      return secretToken;
    }

    public void setSecretToken(String secretToken) {
      this.secretToken = secretToken;
    }

    public String getBotUsername() {
      return botUsername;
    }

    public void setBotUsername(String botUsername) {
      this.botUsername = botUsername;
    }

    public int getTimeoutMillis() {
      return timeoutMillis;
    }

    public void setTimeoutMillis(int timeoutMillis) {
      this.timeoutMillis = timeoutMillis;
    }
  }
}
