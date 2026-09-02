package com.geosun.tms.auth.mail;

import com.geosun.tms.auth.config.AppClient;
import com.geosun.tms.auth.config.AppEmailProperties;
import jakarta.mail.MessagingException;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Objects;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.lang.NonNull;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Component;
import org.springframework.util.StreamUtils;

/**
 * Спільне заповнення шаблонів auth-листів і вкладення логотипа / іконок соцмереж.
 */
@Component
public class AuthMailComposer {
  private static final String PLACEHOLDER_HEADER = "{{BRANDING_HEADER}}";
  private static final String PLACEHOLDER_FOOTER = "{{BRANDING_FOOTER}}";
  private static final String PLACEHOLDER_FOOTER_TEXT = "{{BRANDING_FOOTER_TEXT}}";
  private static final String PLACEHOLDER_CLIENT_NAME = "{{CLIENT_NAME}}";
  private static final String PLACEHOLDER_APP_URL = "{{APP_URL}}";
  private static final String PLACEHOLDER_SITE_URL = "{{SITE_URL}}";
  private static final String PLACEHOLDER_TELEGRAM_URL = "{{TELEGRAM_URL}}";
  private static final String PLACEHOLDER_WHATSAPP_URL = "{{WHATSAPP_URL}}";
  private static final String PLACEHOLDER_VIBER_URL = "{{VIBER_URL}}";
  private static final String PLACEHOLDER_FACEBOOK_URL = "{{FACEBOOK_URL}}";

  private static final List<InlineImage> INLINE_IMAGES =
      List.of(
          new InlineImage("geosun-logo", "mail/images/geosun-logo.png"),
          new InlineImage("icon-web", "mail/images/icon-web.png"),
          new InlineImage("icon-telegram", "mail/images/icon-telegram.png"),
          new InlineImage("icon-whatsapp", "mail/images/icon-whatsapp.png"),
          new InlineImage("icon-viber", "mail/images/icon-viber.png"),
          new InlineImage("icon-facebook", "mail/images/icon-facebook.png"));

  private final AppEmailProperties emailProperties;
  private final String brandingHeader;
  private final String brandingFooter;
  private final String brandingFooterText;

  public AuthMailComposer(AppEmailProperties emailProperties) {
    this.emailProperties = emailProperties;
    try {
      this.brandingHeader = readTemplate(new ClassPathResource("mail/branding-header.html"));
      this.brandingFooter = readTemplate(new ClassPathResource("mail/branding-footer.html"));
      this.brandingFooterText = readTemplate(new ClassPathResource("mail/branding-footer.txt"));
    } catch (IOException ex) {
      throw new IllegalStateException("Cannot load mail branding fragments", ex);
    }
  }

  @NonNull
  public String readTemplate(@NonNull Resource resource) throws IOException {
    try (var inputStream = resource.getInputStream()) {
      var utf8 = StandardCharsets.UTF_8;
      if (utf8 == null) {
        throw new IllegalStateException("UTF-8 charset must be available");
      }
      return Objects.requireNonNull(StreamUtils.copyToString(inputStream, utf8));
    }
  }

  @NonNull
  public String fill(
      @NonNull String template,
      @NonNull AppClient client,
      @NonNull String linkPlaceholder,
      @NonNull String link) {
    Objects.requireNonNull(template);
    Objects.requireNonNull(client);
    Objects.requireNonNull(linkPlaceholder);
    Objects.requireNonNull(link);
    return Objects.requireNonNull(
        template
            .replace(PLACEHOLDER_HEADER, brandingHeader)
            .replace(PLACEHOLDER_FOOTER, brandingFooter)
            .replace(PLACEHOLDER_FOOTER_TEXT, brandingFooterText)
            .replace(linkPlaceholder, link)
            .replace(PLACEHOLDER_CLIENT_NAME, emailProperties.resolveClientDisplayName(client))
            .replace(PLACEHOLDER_APP_URL, emailProperties.resolveAppBaseUrl(client))
            .replace(PLACEHOLDER_SITE_URL, emailProperties.resolveSiteUrl())
            .replace(PLACEHOLDER_TELEGRAM_URL, emailProperties.resolveTelegramUrl())
            .replace(PLACEHOLDER_WHATSAPP_URL, emailProperties.resolveWhatsappUrl())
            .replace(PLACEHOLDER_VIBER_URL, emailProperties.resolveViberUrl())
            .replace(PLACEHOLDER_FACEBOOK_URL, emailProperties.resolveFacebookUrl()));
  }

  public void addInlineBranding(@NonNull MimeMessageHelper helper) throws MessagingException {
    Objects.requireNonNull(helper);
    for (InlineImage image : INLINE_IMAGES) {
      helper.addInline(image.contentId(), new ClassPathResource(image.classpath()));
    }
  }

  private record InlineImage(@NonNull String contentId, @NonNull String classpath) {}
}
