package com.geosun.tms.chatbot.dto.response;

/** Статус одного каналу в адмінці. */
public record ChannelStatusDto(
    String channel, boolean enabled, boolean configured, long activeIdentities) {}
