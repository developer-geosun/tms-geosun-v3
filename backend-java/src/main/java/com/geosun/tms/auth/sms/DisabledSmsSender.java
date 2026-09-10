package com.geosun.tms.auth.sms;

import com.geosun.tms.auth.config.SmsProperties;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;

/** SMS-заглушка: провайдер {@code none} / вимкнений — відправка неможлива. */
@Component
public class DisabledSmsSender implements SmsSender {

  private final SmsProperties smsProperties;

  public DisabledSmsSender(SmsProperties smsProperties) {
    this.smsProperties = smsProperties;
  }

  @Override
  public boolean enabled() {
    return smsProperties.isSendCapable();
  }

  @Override
  public void send(@NonNull String e164Phone, @NonNull String text) {
    throw new UnsupportedOperationException(
        "SMS provider is not configured (app.sms.provider=none)");
  }
}
