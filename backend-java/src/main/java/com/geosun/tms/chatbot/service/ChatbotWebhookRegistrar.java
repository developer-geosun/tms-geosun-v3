package com.geosun.tms.chatbot.service;

import com.geosun.tms.chatbot.adapter.TelegramChannelAdapter;
import com.geosun.tms.chatbot.client.TelegramApiClient;
import com.geosun.tms.chatbot.config.ChatbotProperties;
import java.util.Objects;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

/** Реєстрація Telegram webhook після старту застосунку. */
@Component
public class ChatbotWebhookRegistrar {

  private static final Logger log = LoggerFactory.getLogger(ChatbotWebhookRegistrar.class);

  private final ChatbotProperties properties;
  private final TelegramChannelAdapter telegramChannelAdapter;
  private final TelegramApiClient telegramApiClient;

  public ChatbotWebhookRegistrar(
      ChatbotProperties properties,
      TelegramChannelAdapter telegramChannelAdapter,
      TelegramApiClient telegramApiClient) {
    this.properties = properties;
    this.telegramChannelAdapter = telegramChannelAdapter;
    this.telegramApiClient = telegramApiClient;
  }

  @EventListener(ApplicationReadyEvent.class)
  public void registerOnReady() {
    if (!telegramChannelAdapter.enabled()) {
      return;
    }
    String base = properties.getPublicBaseUrl();
    if (!StringUtils.hasText(base)) {
      log.info("Telegram webhook registration skipped: publicBaseUrl is empty");
      return;
    }
    String normalized = base.endsWith("/") ? base.substring(0, base.length() - 1) : base;
    String url = normalized + "/api/v1/webhooks/telegram";
    String secret = Objects.requireNonNull(properties.getTelegram().getSecretToken());
    try {
      telegramApiClient.setWebhook(Objects.requireNonNull(url), secret);
    } catch (Exception ex) {
      log.error("Failed to register Telegram webhook: {}", ex.getMessage());
    }
  }
}
