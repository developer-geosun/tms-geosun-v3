package com.geosun.tms.auth.config;

import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.boot.actuate.info.Info;
import org.springframework.boot.actuate.info.InfoContributor;
import org.springframework.boot.info.BuildProperties;
import org.springframework.boot.info.GitProperties;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;

/** Публічні метадані сервера: версія збірки, API v1, URL репозиторію. */
@Component
public class ServerInfoContributor implements InfoContributor {

  private static final String DEV_VERSION = "dev";

  private final AppInfoProperties appInfo;
  private final BuildProperties buildProperties;
  private final GitProperties gitProperties;

  public ServerInfoContributor(
      AppInfoProperties appInfo,
      ObjectProvider<BuildProperties> buildPropertiesProvider,
      ObjectProvider<GitProperties> gitPropertiesProvider) {
    this.appInfo = appInfo;
    this.buildProperties = buildPropertiesProvider.getIfAvailable();
    this.gitProperties = gitPropertiesProvider.getIfAvailable();
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
      putCommitDetails(details);
    } else {
      details.put("version", DEV_VERSION);
      details.put("commit", DEV_VERSION);
    }
    return details;
  }

  private void putCommitDetails(Map<String, Object> details) {
    if (gitProperties != null) {
      String commit = gitProperties.getShortCommitId();
      if (commit != null && !commit.isBlank()) {
        details.put("commit", commit);
        return;
      }
    }
    details.put("commit", DEV_VERSION);
  }
}
