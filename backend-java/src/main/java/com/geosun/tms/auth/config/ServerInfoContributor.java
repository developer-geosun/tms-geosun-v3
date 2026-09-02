package com.geosun.tms.auth.config;

import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.boot.actuate.info.Info;
import org.springframework.boot.actuate.info.InfoContributor;
import org.springframework.boot.info.BuildProperties;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;

/** Публічні метадані сервера: версія збірки, API v1, URL репозиторію. */
@Component
public class ServerInfoContributor implements InfoContributor {

  private static final String DEV_VERSION = "dev";

  private final AppInfoProperties appInfo;
  private final BuildProperties buildProperties;

  public ServerInfoContributor(
      AppInfoProperties appInfo, ObjectProvider<BuildProperties> buildPropertiesProvider) {
    this.appInfo = appInfo;
    this.buildProperties = buildPropertiesProvider.getIfAvailable();
  }

  @Override
  public void contribute(Info.Builder builder) {
    builder.withDetail("server", serverDetails());
  }

  @NonNull
  private Map<String, Object> serverDetails() {
    Map<String, Object> details = new LinkedHashMap<>();
    details.put("apiVersion", appInfo.apiVersion());
    details.put("repositoryUrl", appInfo.repositoryUrl());
    if (buildProperties != null) {
      details.put("version", buildProperties.getVersion());
      details.put("artifact", buildProperties.getArtifact());
      details.put("buildTime", buildProperties.getTime().toString());
    } else {
      details.put("version", DEV_VERSION);
    }
    return details;
  }
}
