package com.geosun.tms.chatbot.adapter;

import com.geosun.tms.chatbot.domain.ChatbotChannel;
import java.util.List;
import org.springframework.lang.NonNull;

/** Канальний адаптер месенджера: вхід webhook, вихід текст/кнопки, перевірка підпису. */
public interface ChatbotChannelAdapter {

  @NonNull
  ChatbotChannel channel();

  boolean enabled();

  /** Перевірка підпису / secret; false → 401, тіло не парсити далі. */
  boolean verifyWebhook(@NonNull ChatbotWebhookRequest raw);

  @NonNull
  List<ChatbotInboundEvent> parse(@NonNull ChatbotWebhookRequest raw);

  void send(@NonNull ChatbotOutboundMessage message);
}
