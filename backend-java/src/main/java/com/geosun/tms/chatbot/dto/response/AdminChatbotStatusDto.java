package com.geosun.tms.chatbot.dto.response;

import java.util.List;

/** Статус каналів чат-бота для адмінки. */
public record AdminChatbotStatusDto(boolean moduleEnabled, List<ChannelStatusDto> channels) {}
