package com.geosun.tms.chatbot.service;

import com.geosun.tms.auth.exception.ApiException;
import com.geosun.tms.auth.ratelimit.RateLimitService;
import com.geosun.tms.chatbot.adapter.ChatbotChannelAdapter;
import com.geosun.tms.chatbot.adapter.ChatbotInboundEvent;
import com.geosun.tms.chatbot.adapter.ChatbotWebhookRequest;
import com.geosun.tms.chatbot.adapter.TelegramChannelAdapter;
import com.geosun.tms.chatbot.domain.BotMessageDirection;
import com.geosun.tms.chatbot.domain.BotMessageLog;
import com.geosun.tms.chatbot.domain.BotMessageStatus;
import com.geosun.tms.chatbot.domain.ChatbotChannel;
import com.geosun.tms.chatbot.repository.BotMessageLogRepository;
import java.util.List;
import java.util.Objects;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Обробка HTTP webhook: rate limit, verify, parse, делегування в {@link ChatbotEngine}.
 */
@Service
public class ChatbotWebhookService {

  private static final Logger log = LoggerFactory.getLogger(ChatbotWebhookService.class);

  private final RateLimitService rateLimitService;
  private final TelegramChannelAdapter telegramChannelAdapter;
  private final ChatbotEngine chatbotEngine;
  private final BotMessageLogRepository botMessageLogRepository;

  public ChatbotWebhookService(
      RateLimitService rateLimitService,
      TelegramChannelAdapter telegramChannelAdapter,
      ChatbotEngine chatbotEngine,
      BotMessageLogRepository botMessageLogRepository) {
    this.rateLimitService = rateLimitService;
    this.telegramChannelAdapter = telegramChannelAdapter;
    this.chatbotEngine = chatbotEngine;
    this.botMessageLogRepository = botMessageLogRepository;
  }

  /**
   * Повертає {@code true}, якщо запит прийнято (200). Викидає 401/429 при відмові.
   * Якщо канал вимкнено — тихо 200 без доменної обробки.
   */
  @Transactional
  public void handleTelegram(@NonNull ChatbotWebhookRequest raw) {
    rateLimitService.checkChatbotWebhook(raw.clientIp() == null ? "unknown" : raw.clientIp());

    ChatbotChannelAdapter adapter = telegramChannelAdapter;
    if (!adapter.enabled()) {
      log.info("chatbot_webhook_ok channel=TELEGRAM skipped=channel_disabled");
      return;
    }

    if (!adapter.verifyWebhook(raw)) {
      log.warn("chatbot_webhook_rejected channel=TELEGRAM reason=bad_secret");
      throw ApiException.unauthorized("UNAUTHORIZED", "Invalid webhook secret");
    }

    List<ChatbotInboundEvent> events;
    try {
      events = adapter.parse(raw);
    } catch (IllegalArgumentException ex) {
      logParseFailed(TelegramChannelAdapter.previewBody(raw.body()));
      log.info("chatbot_webhook_ok channel=TELEGRAM skipped=parse_failed");
      return;
    }

    for (ChatbotInboundEvent event : events) {
      chatbotEngine.process(adapter, Objects.requireNonNull(event));
    }
    log.info("chatbot_webhook_ok channel=TELEGRAM events={}", events.size());
  }

  private void logParseFailed(String preview) {
    BotMessageLog row = new BotMessageLog();
    row.setDirection(BotMessageDirection.IN);
    row.setChannel(ChatbotChannel.TELEGRAM);
    row.setEventType("WEBHOOK_PARSE_FAILED");
    row.setStatus(BotMessageStatus.IGNORED);
    row.setPayloadPreview(preview);
    row.setAttemptCount(0);
    botMessageLogRepository.save(Objects.requireNonNull(row));
  }
}
