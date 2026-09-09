package com.geosun.tms.chatbot.config;

import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Configuration;

/** Підключення властивостей модуля чат-бота. */
@Configuration
@EnableConfigurationProperties(ChatbotProperties.class)
public class ChatbotConfig {}
