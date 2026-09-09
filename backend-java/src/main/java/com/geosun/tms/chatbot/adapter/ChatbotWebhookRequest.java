package com.geosun.tms.chatbot.adapter;

import java.util.Map;
import org.springframework.lang.NonNull;
import org.springframework.lang.Nullable;

/** Сирий HTTP-запит webhook (байти тіла до JSON-парсингу). */
public record ChatbotWebhookRequest(
    @NonNull Map<String, String> headers, @NonNull byte[] body, @Nullable String clientIp) {}
