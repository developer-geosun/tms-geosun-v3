package com.geosun.tms.chatbot.dto.response;

import java.time.Instant;

/** Відповідь із кодом прив'язки та deep link. */
public record BotLinkCodeResponse(
    String channel, String code, Instant expiresAt, String deepLink) {}
