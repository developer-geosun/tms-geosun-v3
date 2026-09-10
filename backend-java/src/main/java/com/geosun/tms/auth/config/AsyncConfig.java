package com.geosun.tms.auth.config;

import java.util.concurrent.Executor;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.core.task.SyncTaskExecutor;
import org.springframework.lang.NonNull;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

/**
 * Async для afterCommit-сповіщень; у профілі {@code test} — синхронний executor.
 */
@Configuration
@EnableAsync
@EnableConfigurationProperties({UserRegisteredNotifyProperties.class, SmsProperties.class})
public class AsyncConfig {

  public static final String ADMIN_NOTIFY_EXECUTOR = "adminNotifyExecutor";

  @Bean(name = ADMIN_NOTIFY_EXECUTOR)
  @Profile("!test")
  @NonNull
  public Executor adminNotifyExecutor() {
    ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
    executor.setCorePoolSize(2);
    executor.setMaxPoolSize(4);
    executor.setQueueCapacity(200);
    executor.setThreadNamePrefix("admin-notify-");
    executor.initialize();
    return executor;
  }

  @Bean(name = ADMIN_NOTIFY_EXECUTOR)
  @Profile("test")
  @NonNull
  public Executor adminNotifyExecutorSync() {
    return new SyncTaskExecutor();
  }
}
