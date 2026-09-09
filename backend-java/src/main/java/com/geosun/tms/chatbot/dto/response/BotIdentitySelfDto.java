package com.geosun.tms.chatbot.dto.response;

import java.time.Instant;

/** Прив'язка бота для self-API (без externalUserId). */
public record BotIdentitySelfDto(
    String channel, String status, String locale, Instant linkedAt, boolean phoneVerified) {}
