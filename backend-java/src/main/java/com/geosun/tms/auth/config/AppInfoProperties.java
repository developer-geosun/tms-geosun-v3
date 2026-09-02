package com.geosun.tms.auth.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.lang.NonNull;

/** Метадані сервера для {@code GET /actuator/info}. */
@ConfigurationProperties(prefix = "app.info")
public record AppInfoProperties(@NonNull String apiVersion, @NonNull String repositoryUrl) {}
