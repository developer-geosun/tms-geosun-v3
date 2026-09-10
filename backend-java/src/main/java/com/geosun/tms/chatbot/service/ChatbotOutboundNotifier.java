package com.geosun.tms.chatbot.service;

import com.geosun.tms.chatbot.adapter.ChatbotChannelAdapter;
import com.geosun.tms.chatbot.adapter.ChatbotOutboundMessage;
import com.geosun.tms.chatbot.domain.BotIdentity;
import com.geosun.tms.chatbot.domain.BotIdentityStatus;
import com.geosun.tms.chatbot.domain.BotMessageDirection;
import com.geosun.tms.chatbot.domain.BotMessageLog;
import com.geosun.tms.chatbot.domain.BotMessageStatus;
import com.geosun.tms.chatbot.domain.ChatbotChannel;
import com.geosun.tms.chatbot.repository.BotIdentityRepository;
import com.geosun.tms.chatbot.repository.BotMessageLogRepository;
import java.time.Instant;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Мінімальний outbound для доменних подій (v1: {@code USER_REGISTERED}).
 */
@Service
public class ChatbotOutboundNotifier {

  public static final String EVENT_USER_REGISTERED = "USER_REGISTERED";

  private static final Logger log = LoggerFactory.getLogger(ChatbotOutboundNotifier.class);

  private final BotIdentityRepository botIdentityRepository;
  private final BotMessageLogRepository botMessageLogRepository;
  private final Map<ChatbotChannel, ChatbotChannelAdapter> adaptersByChannel;

  public ChatbotOutboundNotifier(
      BotIdentityRepository botIdentityRepository,
      BotMessageLogRepository botMessageLogRepository,
      List<ChatbotChannelAdapter> adapters) {
    this.botIdentityRepository = botIdentityRepository;
    this.botMessageLogRepository = botMessageLogRepository;
    Map<ChatbotChannel, ChatbotChannelAdapter> map = new EnumMap<>(ChatbotChannel.class);
    for (ChatbotChannelAdapter adapter : adapters) {
      map.put(adapter.channel(), adapter);
    }
    this.adaptersByChannel = Map.copyOf(map);
  }

  /**
   * Надіслати повідомлення на всі ACTIVE-прив'язки користувача.
   *
   * @return кількість успішних SENT
   */
  @Transactional
  public int notifyUserRegistered(
      @NonNull String recipientUserId, @NonNull String newUserId, @NonNull String messageText) {
    String adminId = Objects.requireNonNull(recipientUserId);
    String registeredId = Objects.requireNonNull(newUserId);
    String text = Objects.requireNonNull(messageText);

    List<BotIdentity> identities =
        botIdentityRepository.findByUserIdAndStatus(adminId, BotIdentityStatus.ACTIVE);
    if (identities.isEmpty()) {
      log.info("admin_notify_messenger_skipped_no_identity adminId={}", adminId);
      return 0;
    }

    int sent = 0;
    for (BotIdentity identity : identities) {
      ChatbotChannel channel = identity.getChannel();
      String idempotencyKey =
          EVENT_USER_REGISTERED + "|" + registeredId + "|" + adminId + "|" + channel.name();
      if (botMessageLogRepository.existsByIdempotencyKey(idempotencyKey)) {
        continue;
      }
      ChatbotChannelAdapter adapter = adaptersByChannel.get(channel);
      if (adapter == null || !adapter.enabled()) {
        log.info("admin_notify_messenger_channel_disabled adminId={} channel={}", adminId, channel);
        continue;
      }
      if (channel == ChatbotChannel.WHATSAPP) {
        // Шаблон Meta ще не заведений — вільний текст поза 24h window заборонений.
        log.info("admin_notify_whatsapp_template_missing adminId={}", adminId);
        continue;
      }
      if (sendAndLog(adapter, identity, text, idempotencyKey)) {
        sent++;
      }
    }
    return sent;
  }

  private boolean sendAndLog(
      ChatbotChannelAdapter adapter, BotIdentity identity, String text, String idempotencyKey) {
    BotMessageStatus status = BotMessageStatus.SENT;
    String providerError = null;
    try {
      adapter.send(
          new ChatbotOutboundMessage(
              Objects.requireNonNull(identity.getExternalUserId()),
              Objects.requireNonNull(text),
              false));
    } catch (Exception ex) {
      status = BotMessageStatus.FAILED;
      providerError = truncate(ex.getMessage(), 256);
      log.warn("admin_notify_messenger_failed: {}", ex.getMessage());
    }
    BotMessageLog row = new BotMessageLog();
    row.setDirection(BotMessageDirection.OUT);
    row.setChannel(adapter.channel());
    row.setIdentityId(identity.getId());
    row.setUserId(identity.getUserId());
    row.setEventType(EVENT_USER_REGISTERED);
    row.setIdempotencyKey(idempotencyKey);
    row.setStatus(status);
    row.setPayloadPreview(truncate(text, 512));
    row.setProviderError(providerError);
    row.setAttemptCount(1);
    if (status == BotMessageStatus.SENT) {
      row.setSentAt(Instant.now());
    }
    try {
      botMessageLogRepository.save(Objects.requireNonNull(row));
    } catch (DataIntegrityViolationException ex) {
      // Унікальний idempotency_key — повторне повідомлення ігноруємо.
      log.info("admin_notify_messenger_duplicate_skipped key={}", idempotencyKey);
      return false;
    }
    if (status == BotMessageStatus.SENT) {
      log.info(
          "admin_notify_messenger_queued adminId={} channel={}",
          identity.getUserId(),
          adapter.channel());
      return true;
    }
    return false;
  }

  private static String truncate(String value, int max) {
    if (value == null) {
      return null;
    }
    if (value.length() <= max) {
      return value;
    }
    return value.substring(0, max);
  }
}
