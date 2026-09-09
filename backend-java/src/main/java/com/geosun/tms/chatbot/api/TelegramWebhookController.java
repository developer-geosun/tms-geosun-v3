package com.geosun.tms.chatbot.api;

import com.geosun.tms.auth.infrastructure.web.ClientIpResolver;
import com.geosun.tms.chatbot.adapter.ChatbotWebhookRequest;
import com.geosun.tms.chatbot.service.ChatbotWebhookService;
import io.swagger.v3.oas.annotations.Hidden;
import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.util.Collections;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import org.springframework.http.ResponseEntity;
import org.springframework.lang.NonNull;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** Публічний webhook Telegram (без JWT). */
@Hidden
@RestController
@RequestMapping("/api/v1/webhooks")
public class TelegramWebhookController {

  private final ChatbotWebhookService chatbotWebhookService;
  private final ClientIpResolver clientIpResolver;

  public TelegramWebhookController(
      ChatbotWebhookService chatbotWebhookService, ClientIpResolver clientIpResolver) {
    this.chatbotWebhookService = chatbotWebhookService;
    this.clientIpResolver = clientIpResolver;
  }

  @PostMapping("/telegram")
  public ResponseEntity<Void> telegram(@NonNull HttpServletRequest request) throws IOException {
    byte[] body = request.getInputStream().readAllBytes();
    Map<String, String> headers = new HashMap<>();
    Enumeration<String> names = request.getHeaderNames();
    if (names != null) {
      for (String name : Collections.list(names)) {
        headers.put(name, request.getHeader(name));
      }
    }
    String ip = clientIpResolver.resolve(request);
    chatbotWebhookService.handleTelegram(
        new ChatbotWebhookRequest(
            Objects.requireNonNull(Collections.unmodifiableMap(headers)),
            Objects.requireNonNull(body),
            ip));
    return ResponseEntity.ok().build();
  }
}
