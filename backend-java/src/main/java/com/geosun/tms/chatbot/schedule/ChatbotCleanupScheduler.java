package com.geosun.tms.chatbot.schedule;

import com.geosun.tms.chatbot.config.ChatbotProperties;
import com.geosun.tms.chatbot.repository.BotMessageLogRepository;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Objects;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/** Видалення старих рядків bot_message_log за retention. */
@Component
public class ChatbotCleanupScheduler {

  private static final Logger log = LoggerFactory.getLogger(ChatbotCleanupScheduler.class);

  private final ChatbotProperties chatbotProperties;
  private final BotMessageLogRepository botMessageLogRepository;

  public ChatbotCleanupScheduler(
      ChatbotProperties chatbotProperties, BotMessageLogRepository botMessageLogRepository) {
    this.chatbotProperties = chatbotProperties;
    this.botMessageLogRepository = botMessageLogRepository;
  }

  @Scheduled(cron = "${app.cleanup.cron}")
  @Transactional
  public void purgeOldMessageLogs() {
    int days = Math.max(1, chatbotProperties.getCleanupRetentionDays());
    Instant cutoff = Instant.now().minus(days, ChronoUnit.DAYS);
    int deleted = botMessageLogRepository.deleteByCreatedAtBefore(Objects.requireNonNull(cutoff));
    if (deleted > 0) {
      log.info("Deleted {} bot_message_log rows older than {} days", deleted, days);
    }
  }
}
