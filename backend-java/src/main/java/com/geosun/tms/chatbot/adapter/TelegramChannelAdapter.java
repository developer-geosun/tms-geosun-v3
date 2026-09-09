package com.geosun.tms.chatbot.adapter;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.geosun.tms.chatbot.client.TelegramApiClient;
import com.geosun.tms.chatbot.config.ChatbotProperties;
import com.geosun.tms.chatbot.domain.ChatbotChannel;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Locale;
import java.util.Objects;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

/**
 * Адаптер Telegram Bot API: перевірка secret, парсинг Update, sendMessage.
 */
@Component
public class TelegramChannelAdapter implements ChatbotChannelAdapter {

  private static final Logger log = LoggerFactory.getLogger(TelegramChannelAdapter.class);
  private static final String SECRET_HEADER = "X-Telegram-Bot-Api-Secret-Token";

  private final ChatbotProperties properties;
  private final TelegramApiClient telegramApiClient;
  private final ObjectMapper objectMapper;

  public TelegramChannelAdapter(
      ChatbotProperties properties,
      TelegramApiClient telegramApiClient,
      ObjectMapper objectMapper) {
    this.properties = properties;
    this.telegramApiClient = telegramApiClient;
    this.objectMapper = objectMapper;
  }

  @Override
  @NonNull
  public ChatbotChannel channel() {
    return ChatbotChannel.TELEGRAM;
  }

  @Override
  public boolean enabled() {
    ChatbotProperties.Telegram tg = properties.getTelegram();
    return properties.isEnabled()
        && tg.isEnabled()
        && StringUtils.hasText(tg.getBotToken())
        && StringUtils.hasText(tg.getSecretToken());
  }

  @Override
  public boolean verifyWebhook(@NonNull ChatbotWebhookRequest raw) {
    String expected = properties.getTelegram().getSecretToken();
    if (!StringUtils.hasText(expected)) {
      return false;
    }
    String actual = headerIgnoreCase(raw.headers(), SECRET_HEADER);
    return expected.equals(actual);
  }

  @Override
  @NonNull
  public List<ChatbotInboundEvent> parse(@NonNull ChatbotWebhookRequest raw) {
    try {
      JsonNode root = objectMapper.readTree(raw.body());
      JsonNode message = root.path("message");
      if (message.isMissingNode() || message.isNull()) {
        return Objects.requireNonNull(List.of());
      }
      JsonNode chat = message.path("chat");
      String chatId = textOrNull(chat, "id");
      if (!StringUtils.hasText(chatId)) {
        return Objects.requireNonNull(List.of());
      }

      String text = textOrNull(message, "text");
      String command = null;
      if (StringUtils.hasText(text)) {
        String trimmed = text.trim();
        if (trimmed.startsWith("/")) {
          String first = trimmed.split("\\s+", 2)[0];
          int at = first.indexOf('@');
          command = (at > 0 ? first.substring(1, at) : first.substring(1)).toLowerCase(Locale.ROOT);
        }
      }

      String contactPhone = null;
      String contactTelegramUserId = null;
      JsonNode contact = message.path("contact");
      if (!contact.isMissingNode() && !contact.isNull()) {
        contactPhone = textOrNull(contact, "phone_number");
        JsonNode userIdNode = contact.get("user_id");
        if (userIdNode != null && !userIdNode.isNull()) {
          contactTelegramUserId = userIdNode.asText();
        }
      }

      String eventType = contactPhone != null ? "CONTACT" : (command != null ? "COMMAND" : "TEXT");
      return Objects.requireNonNull(
          List.of(
              new ChatbotInboundEvent(
                  Objects.requireNonNull(chatId),
                  text,
                  command,
                  contactPhone,
                  contactTelegramUserId,
                  Objects.requireNonNull(eventType))));
    } catch (Exception ex) {
      log.warn("Telegram webhook parse failed: {}", ex.getMessage());
      throw new IllegalArgumentException("WEBHOOK_PARSE_FAILED", ex);
    }
  }

  @Override
  public void send(@NonNull ChatbotOutboundMessage message) {
    telegramApiClient.sendMessage(
        Objects.requireNonNull(message.externalUserId()),
        Objects.requireNonNull(message.text()),
        message.requestContact());
  }

  private static String headerIgnoreCase(java.util.Map<String, String> headers, String name) {
    if (headers == null || headers.isEmpty()) {
      return null;
    }
    for (var e : headers.entrySet()) {
      if (e.getKey() != null && e.getKey().equalsIgnoreCase(name)) {
        return e.getValue();
      }
    }
    return null;
  }

  private static String textOrNull(JsonNode node, String field) {
    if (node == null || !node.has(field) || node.get(field).isNull()) {
      return null;
    }
    JsonNode v = node.get(field);
    if (v.isNumber()) {
      return v.asText();
    }
    String t = v.asText();
    return StringUtils.hasText(t) ? t : null;
  }

  /** Прев'ю тіла для журналу (обрізане, без секретів). */
  @NonNull
  public static String previewBody(byte[] body) {
    if (body == null || body.length == 0) {
      return "";
    }
    String s = new String(body, StandardCharsets.UTF_8);
    return Objects.requireNonNull(s.length() <= 512 ? s : s.substring(0, 512));
  }
}
