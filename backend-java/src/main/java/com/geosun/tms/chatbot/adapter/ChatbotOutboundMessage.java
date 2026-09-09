package com.geosun.tms.chatbot.adapter;

import org.springframework.lang.NonNull;

/** Вихідне повідомлення бота (текст + опційна кнопка «поділитися контактом»). */
public record ChatbotOutboundMessage(
    @NonNull String externalUserId, @NonNull String text, boolean requestContact) {}
