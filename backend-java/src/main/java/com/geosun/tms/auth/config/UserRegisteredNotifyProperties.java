package com.geosun.tms.auth.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * Прапорець сповіщення ADMIN про нову реєстрацію (app.notifications.user-registered.*).
 */
@ConfigurationProperties(prefix = "app.notifications.user-registered")
public class UserRegisteredNotifyProperties {

  /** Майстер-вимикач хука після register. */
  private boolean enabled = true;

  public boolean isEnabled() {
    return enabled;
  }

  public void setEnabled(boolean enabled) {
    this.enabled = enabled;
  }
}
