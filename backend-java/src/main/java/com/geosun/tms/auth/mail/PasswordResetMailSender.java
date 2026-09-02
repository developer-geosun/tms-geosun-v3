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

/**
 * Відправка листа з посиланням для скидання пароля (без логування токена).
 */
@Component
public class PasswordResetMailSender {
  private static final String TEMPLATE_LINK = "{{RESET_LINK}}";
  private static final String MAIL_SUBJECT = "Скидання пароля / Password reset / Сброс пароля";
  private static final Resource PLAIN_TEMPLATE_RESOURCE =
      new ClassPathResource("mail/password-reset-email.txt");
  private static final Resource HTML_TEMPLATE_RESOURCE =
      new ClassPathResource("mail/password-reset-email.html");

  private final JavaMailSender mailSender;
  private final AppEmailProperties emailProperties;
  private final AuthMailComposer mailComposer;

  public PasswordResetMailSender(
      JavaMailSender mailSender,
      AppEmailProperties emailProperties,
      AuthMailComposer mailComposer) {
    this.mailSender = mailSender;
    this.emailProperties = emailProperties;
    this.mailComposer = mailComposer;
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
          mailComposer.fill(
              mailComposer.readTemplate(Objects.requireNonNull(PLAIN_TEMPLATE_RESOURCE)),
              client,
              TEMPLATE_LINK,
              resetLink);
      String htmlBody =
          mailComposer.fill(
              mailComposer.readTemplate(Objects.requireNonNull(HTML_TEMPLATE_RESOURCE)),
              client,
              TEMPLATE_LINK,
              resetLink);
      helper.setText(plainBody, htmlBody);
      mailComposer.addInlineBranding(helper);
    } catch (MessagingException | IOException ex) {
      throw new MailPreparationException("Failed to prepare password reset email", ex);
    }
    mailSender.send(message);
  }
}
