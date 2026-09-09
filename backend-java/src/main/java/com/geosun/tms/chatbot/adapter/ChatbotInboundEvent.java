package com.geosun.tms.chatbot.adapter;

import org.springframework.lang.NonNull;
import org.springframework.lang.Nullable;

/** Канонічна вхідна подія після парсингу канального payload. */
public record ChatbotInboundEvent(
    @NonNull String externalUserId,
    @Nullable String text,
    @Nullable String command,
    @Nullable String contactPhone,
    @Nullable String contactTelegramUserId,
    @NonNull String rawEventType) {}
