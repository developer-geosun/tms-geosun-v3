package com.geosun.tms.chatbot.dto.response;

import java.util.List;

/** Список прив'язок поточного користувача. */
public record BotIdentitiesSelfResponse(List<BotIdentitySelfDto> items, boolean phoneVerifiedAny) {}
