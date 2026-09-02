package com.geosun.tms.auth.mail;

import static org.assertj.core.api.Assertions.assertThat;

import com.geosun.tms.auth.config.AppClient;
import com.geosun.tms.auth.config.AppEmailProperties;
import jakarta.mail.internet.MimeMessage;
import java.nio.charset.StandardCharsets;
import java.util.Properties;
import org.junit.jupiter.api.Test;
import org.springframework.core.io.ClassPathResource;
import org.springframework.mail.javamail.MimeMessageHelper;

class AuthMailComposerTest {

  @Test
  void fillsVerificationHtmlWithLanguageBlocksAndBranding() throws Exception {
    AuthMailComposer composer = new AuthMailComposer(new AppEmailProperties());
    String html =
        composer.fill(
            composer.readTemplate(new ClassPathResource("mail/verification-email.html")),
            AppClient.ANGULAR,
            "{{VERIFICATION_LINK}}",
            "https://example.com/verify-email?token=abc");

    assertThat(html).contains(">UA<").contains(">EN<").contains(">RU<");
    assertThat(html)
        .contains("Підтвердити email")
        .contains("Verify email")
        .contains("Подтвердить email");
    assertThat(html).contains("https://example.com/verify-email?token=abc");
    assertThat(html).contains("cid:geosun-logo").contains("cid:icon-telegram");
    assertThat(html).contains("https://www.geosun.net.ua");
    assertThat(html).contains("+380(98)4894118").contains("tel:+380984894118");
    assertThat(html).contains("https://viber.me/380984894118");
    assertThat(html).doesNotContain("{{");
  }

  @Test
  void fillsPasswordResetPlainTextWithSocialLinks() throws Exception {
    AuthMailComposer composer = new AuthMailComposer(new AppEmailProperties());
    String plain =
        composer.fill(
            composer.readTemplate(new ClassPathResource("mail/password-reset-email.txt")),
            AppClient.ANGULAR,
            "{{RESET_LINK}}",
            "https://example.com/reset-password?token=xyz");

    assertThat(plain).contains("UA").contains("EN").contains("RU");
    assertThat(plain).contains("https://example.com/reset-password?token=xyz");
    assertThat(plain).contains("+380(98)4894118");
    assertThat(plain).contains("Telegram: https://t.me/+380984894118");
    assertThat(plain).contains("Viber: https://viber.me/380984894118");
    assertThat(plain).doesNotContain("{{");
  }

  @Test
  void attachesInlineBrandingImages() throws Exception {
    AuthMailComposer composer = new AuthMailComposer(new AppEmailProperties());
    MimeMessage message = new MimeMessage(jakarta.mail.Session.getInstance(new Properties()));
    MimeMessageHelper helper = new MimeMessageHelper(message, true, StandardCharsets.UTF_8.name());
    helper.setFrom("no-reply@example.com");
    helper.setTo("user@example.com");
    helper.setSubject("test");
    helper.setText("plain", "<p>html</p>");
    composer.addInlineBranding(helper);

    assertThat(helper.getMimeMultipart().getCount()).isEqualTo(7);
  }
}
