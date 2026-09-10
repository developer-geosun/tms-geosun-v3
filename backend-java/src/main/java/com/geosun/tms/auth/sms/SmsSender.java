package com.geosun.tms.auth.sms;

import org.springframework.lang.NonNull;

/** Відправка SMS (v1: лише заглушка {@code none}). */
public interface SmsSender {

  /** Чи увімкнений реальний провайдер. */
  boolean enabled();

  /**
   * Надіслати SMS.
   *
   * @throws UnsupportedOperationException якщо провайдер вимкнений
   */
  void send(@NonNull String e164Phone, @NonNull String text);
}
