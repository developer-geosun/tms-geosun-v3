package com.geosun.tms.auth.mail;

import com.geosun.tms.auth.config.AppClient;
import com.geosun.tms.auth.config.AppEmailProperties;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Objects;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.lang.NonNull;
import org.springframework.mail.MailException;
import org.springframework.mail.MailPreparationException;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Component;
import org.springframework.util.StreamUtils;

/**
 * Відправка листа з посиланням для скидання пароля (без логування токена).
 */
@Component
public class PasswordResetMailSender {
  private static final String TEMPLATE_LINK = "{{RESET_LINK}}";
  private static final String TEMPLATE_CLIENT_NAME = "{{CLIENT_NAME}}";
  private static final String TEMPLATE_APP_URL = "{{APP_URL}}";
  private static final String MAIL_SUBJECT = "Password reset / Сброс пароля / Скидання пароля";
  private static final Resource PLAIN_TEMPLATE_RESOURCE =
      new ClassPathResource("mail/password-reset-email.txt");
  private static final Resource HTML_TEMPLATE_RESOURCE =
      new ClassPathResource("mail/password-reset-email.html");

  private final JavaMailSender mailSender;
  private final AppEmailProperties emailProperties;

  public PasswordResetMailSender(JavaMailSender mailSender, AppEmailProperties emailProperties) {
    this.mailSender = mailSender;
    this.emailProperties = emailProperties;
  }

  public void sendPasswordResetEmail(
      String toAddress, String rawToken, @NonNull AppClient appClient) throws MailException {
    if (toAddress == null) {
      throw new NullPointerException("toAddress must not be null");
    }
    if (rawToken == null) {
      throw new NullPointerException("rawToken must not be null");
    }
    AppClient client = Objects.requireNonNull(appClient);
    String fromAddress = emailProperties.getFrom();
    if (fromAddress == null) {
      throw new NullPointerException("from address must not be null");
    }
    String resetLink = emailProperties.buildPasswordResetLink(client, rawToken);
    MimeMessage message = mailSender.createMimeMessage();
    try {
      MimeMessageHelper helper =
          new MimeMessageHelper(message, true, StandardCharsets.UTF_8.name());
      helper.setFrom(fromAddress);
      helper.setTo(toAddress);
      helper.setSubject(MAIL_SUBJECT);
      String plainBody =
          fillTemplate(
              Objects.requireNonNull(readTemplate(PLAIN_TEMPLATE_RESOURCE)), resetLink, client);
      String htmlBody =
          fillTemplate(
              Objects.requireNonNull(readTemplate(HTML_TEMPLATE_RESOURCE)), resetLink, client);
      if (plainBody == null || htmlBody == null) {
        throw new MailPreparationException("Password reset email body must not be null");
      }
      helper.setText(plainBody, htmlBody);
    } catch (MessagingException | IOException ex) {
      throw new MailPreparationException("Failed to prepare password reset email", ex);
    }
    mailSender.send(message);
  }

  @NonNull
  private String fillTemplate(
      @NonNull String template, @NonNull String resetLink, @NonNull AppClient client) {
    return Objects.requireNonNull(
        template
            .replace(TEMPLATE_LINK, resetLink)
            .replace(TEMPLATE_CLIENT_NAME, emailProperties.resolveClientDisplayName(client))
            .replace(TEMPLATE_APP_URL, emailProperties.resolveAppBaseUrl(client)));
  }

  @NonNull
  private static String readTemplate(Resource resource) throws IOException {
    try (var inputStream = resource.getInputStream()) {
      var utf8 = StandardCharsets.UTF_8;
      if (utf8 == null) {
        throw new IllegalStateException("UTF-8 charset must be available");
      }
      return Objects.requireNonNull(StreamUtils.copyToString(inputStream, utf8));
    }
  }
}
