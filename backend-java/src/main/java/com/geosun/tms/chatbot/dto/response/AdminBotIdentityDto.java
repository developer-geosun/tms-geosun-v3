package com.geosun.tms.chatbot.dto.response;

import java.time.Instant;

/** Рядок прив'язки в адмінському списку (external id може бути замаскований). */
public record AdminBotIdentityDto(
    String id,
    String userId,
    String channel,
    String externalUserId,
    String locale,
    String status,
    Instant linkedAt,
    Instant revokedAt) {}
