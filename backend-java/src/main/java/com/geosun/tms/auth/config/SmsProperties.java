package com.geosun.tms.auth.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * Налаштування SMS-транспорту (app.sms.*). У v1 провайдер {@code none}.
 */
@ConfigurationProperties(prefix = "app.sms")
public class SmsProperties {

  private boolean enabled = false;

  /** Код провайдера: {@code none} або майбутній вендор. */
  private String provider = "none";

  public boolean isEnabled() {
    return enabled;
  }

  public void setEnabled(boolean enabled) {
    this.enabled = enabled;
  }

  public String getProvider() {
    return provider;
  }

  public void setProvider(String provider) {
    this.provider = provider;
  }

  /** Чи можна реально надсилати SMS. */
  public boolean isSendCapable() {
    return enabled && provider != null && !"none".equalsIgnoreCase(provider.trim());
  }
}
