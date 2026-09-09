package com.geosun.tms.chatbot.dto.request;

import jakarta.validation.constraints.NotBlank;

/** Запит на створення одноразового коду прив'язки. */
public record CreateBotLinkCodeRequest(@NotBlank String channel) {}
