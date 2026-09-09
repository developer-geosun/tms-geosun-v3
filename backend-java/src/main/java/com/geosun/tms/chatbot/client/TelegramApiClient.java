package com.geosun.tms.chatbot.client;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.geosun.tms.auth.exception.ApiException;
import com.geosun.tms.chatbot.config.ChatbotProperties;
import java.util.Objects;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

/**
 * Клієнт Telegram Bot API (лише host api.telegram.org, без SDK).
 */
@Component
public class TelegramApiClient {

  private static final Logger log = LoggerFactory.getLogger(TelegramApiClient.class);
  private static final String API_HOST = "https://api.telegram.org";

  private final ChatbotProperties properties;
  private final ObjectMapper objectMapper;
  private final RestTemplate restTemplate;

  public TelegramApiClient(
      RestTemplateBuilder restTemplateBuilder,
      ChatbotProperties properties,
      ObjectMapper objectMapper) {
    this.properties = properties;
    this.objectMapper = objectMapper;
    int timeout = properties.getTelegram().getTimeoutMillis();
    this.restTemplate =
        restTemplateBuilder
            .setConnectTimeout(java.time.Duration.ofMillis(timeout))
            .setReadTimeout(java.time.Duration.ofMillis(timeout))
            .build();
  }

  /** Реєстрація webhook URL із secret_token. */
  public void setWebhook(@NonNull String url, @NonNull String secretToken) {
    ObjectNode body = objectMapper.createObjectNode();
    body.put("url", url);
    body.put("secret_token", secretToken);
    postJson("setWebhook", body);
    log.info("Telegram setWebhook OK for url={}", url);
  }

  /**
   * Надсилає текстове повідомлення; за потреби — reply keyboard із request_contact.
   */
  public void sendMessage(@NonNull String chatId, @NonNull String text, boolean requestContact) {
    ObjectNode body = objectMapper.createObjectNode();
    body.put("chat_id", chatId);
    body.put("text", text);
    if (requestContact) {
      ObjectNode button = objectMapper.createObjectNode();
      button.put("text", "Поділитися номером");
      button.put("request_contact", true);
      ObjectNode keyboard = objectMapper.createObjectNode();
      keyboard.putArray("keyboard").add(objectMapper.createArrayNode().add(button));
      keyboard.put("resize_keyboard", true);
      keyboard.put("one_time_keyboard", true);
      body.set("reply_markup", keyboard);
    } else {
      ObjectNode remove = objectMapper.createObjectNode();
      remove.put("remove_keyboard", true);
      body.set("reply_markup", remove);
    }
    postJson("sendMessage", body);
  }

  private void postJson(@NonNull String method, @NonNull ObjectNode body) {
    String token = properties.getTelegram().getBotToken();
    if (!StringUtils.hasText(token)) {
      throw ApiException.serviceUnavailable(
          "CHATBOT_PROVIDER_ERROR", "Telegram bot token is not configured");
    }
    String url = API_HOST + "/bot" + token + "/" + method;
    HttpHeaders headers = new HttpHeaders();
    headers.setContentType(Objects.requireNonNull(MediaType.APPLICATION_JSON));
    try {
      ResponseEntity<JsonNode> response =
          restTemplate.postForEntity(
              Objects.requireNonNull(url), new HttpEntity<>(body, headers), JsonNode.class);
      JsonNode respBody = response.getBody();
      if (respBody == null || !respBody.path("ok").asBoolean(false)) {
        String desc =
            respBody == null ? "empty body" : respBody.path("description").asText("error");
        throw ApiException.serviceUnavailable("CHATBOT_PROVIDER_ERROR", "Telegram API: " + desc);
      }
    } catch (RestClientException ex) {
      throw ApiException.serviceUnavailable(
          "CHATBOT_PROVIDER_ERROR", "Telegram API call failed: " + ex.getMessage());
    }
  }
}
