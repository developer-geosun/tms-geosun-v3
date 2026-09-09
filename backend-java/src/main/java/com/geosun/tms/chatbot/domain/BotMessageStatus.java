package com.geosun.tms.chatbot.domain;

/** Статус доставки / обробки повідомлення бота. */
public enum BotMessageStatus {
  PENDING,
  SENT,
  FAILED,
  RECEIVED,
  IGNORED
}
