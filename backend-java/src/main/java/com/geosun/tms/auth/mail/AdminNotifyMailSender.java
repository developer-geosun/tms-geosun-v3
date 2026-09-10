package com.geosun.tms.auth.mail;

import com.geosun.tms.auth.config.AppClient;
import com.geosun.tms.auth.config.AppEmailProperties;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Objects;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.lang.NonNull;
import org.springframework.mail.MailException;
import org.springframework.mail.MailPreparationException;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Component;

/**
 * Лист ADMIN про нову реєстрацію (без пароля / verification token).
 */
@Component
public class AdminNotifyMailSender {
  private static final String TEMPLATE_LINK = "{{ADMIN_CARD_LINK}}";
  private static final String MAIL_SUBJECT =
      "Нова реєстрація / New registration / Новая регистрация";
  private static final Resource PLAIN_TEMPLATE_RESOURCE =
      new ClassPathResource("mail/admin-user-registered.txt");
  private static final Resource HTML_TEMPLATE_RESOURCE =
      new ClassPathResource("mail/admin-user-registered.html");

  private final JavaMailSender mailSender;
  private final AppEmailProperties emailProperties;
  private final AuthMailComposer mailComposer;

  public AdminNotifyMailSender(
      JavaMailSender mailSender,
      AppEmailProperties emailProperties,
      AuthMailComposer mailComposer) {
    this.mailSender = mailSender;
    this.emailProperties = emailProperties;
    this.mailComposer = mailComposer;
  }

  public void sendNewUserRegistered(
      @NonNull String adminEmail,
      @NonNull String newUserId,
      @NonNull String newUserEmail,
      @NonNull Instant createdAt)
      throws MailException {
    String toAddress = Objects.requireNonNull(adminEmail);
    String userId = Objects.requireNonNull(newUserId);
    String userEmail = Objects.requireNonNull(newUserEmail);
    Instant at = Objects.requireNonNull(createdAt);
    String fromAddress = emailProperties.getFrom();
    if (fromAddress == null) {
      throw new NullPointerException("from address must not be null");
    }
    String cardLink = emailProperties.buildAdminUserCardLink(userId);
    String createdAtText = Objects.requireNonNull(at.toString());
    MimeMessage message = mailSender.createMimeMessage();
    try {
      MimeMessageHelper helper =
          new MimeMessageHelper(message, true, StandardCharsets.UTF_8.name());
      helper.setFrom(fromAddress);
      helper.setTo(toAddress);
      helper.setSubject(MAIL_SUBJECT);
      String plainBody =
          fillUserPlaceholders(
              mailComposer.fill(
                  mailComposer.readTemplate(Objects.requireNonNull(PLAIN_TEMPLATE_RESOURCE)),
                  AppClient.ANGULAR,
                  TEMPLATE_LINK,
                  cardLink),
              userEmail,
              userId,
              createdAtText);
      String htmlBody =
          fillUserPlaceholders(
              mailComposer.fill(
                  mailComposer.readTemplate(Objects.requireNonNull(HTML_TEMPLATE_RESOURCE)),
                  AppClient.ANGULAR,
                  TEMPLATE_LINK,
                  cardLink),
              userEmail,
              userId,
              createdAtText);
      helper.setText(Objects.requireNonNull(plainBody), Objects.requireNonNull(htmlBody));
      mailComposer.addInlineBranding(helper);
    } catch (MessagingException | IOException ex) {
      throw new MailPreparationException("Failed to prepare admin registration notify email", ex);
    }
    mailSender.send(message);
  }

  @NonNull
  private static String fillUserPlaceholders(
      @NonNull String body,
      @NonNull String newUserEmail,
      @NonNull String newUserId,
      @NonNull String createdAt) {
    return Objects.requireNonNull(
        body.replace("{{NEW_USER_EMAIL}}", newUserEmail)
            .replace("{{NEW_USER_ID}}", newUserId)
            .replace("{{CREATED_AT}}", createdAt));
  }
}
