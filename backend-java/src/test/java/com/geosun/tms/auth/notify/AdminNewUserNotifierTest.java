package com.geosun.tms.auth.notify;

import static org.assertj.core.api.Assertions.assertThat;

import com.geosun.tms.auth.dto.response.UserContactPhoneDto;
import com.geosun.tms.auth.dto.response.UserProfileDto;
import java.util.List;
import org.junit.jupiter.api.Test;

/** Матриця каналів і обрізання SMS для ADMIN notify. */
class AdminNewUserNotifierTest {

  @Test
  void resolveChannels_emptyProfile_fallsBackToEmail() {
    assertThat(AdminNewUserNotifier.resolveChannelNames(null)).containsExactly("EMAIL");
    assertThat(AdminNewUserNotifier.resolveChannelNames(UserProfileDto.empty()))
        .containsExactly("EMAIL");
  }

  @Test
  void resolveChannels_usesPreferredFlagsOnly() {
    UserProfileDto messengersOnly =
        new UserProfileDto(
            "A", "B", null, "INDIVIDUAL", null, List.of("MESSENGERS"), List.of(), false);
    assertThat(AdminNewUserNotifier.resolveChannelNames(messengersOnly))
        .containsExactly("MESSENGERS");

    UserProfileDto emailAndPhone =
        new UserProfileDto(
            "A",
            "B",
            null,
            "INDIVIDUAL",
            null,
            List.of("EMAIL", "PHONE"),
            List.of(
                new UserContactPhoneDto(
                    "p1", "+380501112233", true, false, false, false, false, null, null)),
            true);
    assertThat(AdminNewUserNotifier.resolveChannelNames(emailAndPhone))
        .containsExactly("EMAIL", "PHONE");
  }

  @Test
  void buildSmsText_keepsIdAndTruncatesLongEmail() {
    String longEmail = "a".repeat(200) + "@example.com";
    String sms = AdminNewUserNotifier.buildSmsText(longEmail, "user-id-1");
    assertThat(sms).startsWith("GeoSun: нова реєстрація ");
    assertThat(sms).contains(" id=user-id-1");
    assertThat(sms.length()).isLessThanOrEqualTo(160);
  }
}
