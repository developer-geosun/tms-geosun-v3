package com.geosun.tms.chatbot.integration;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.geosun.tms.auth.TmsGeosunBackendJavaApplication;
import java.util.Objects;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.lang.NonNull;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

/** Канал вимкнено за замовчуванням у test profile — webhook без доменної обробки. */
@SpringBootTest(classes = TmsGeosunBackendJavaApplication.class)
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class ChatbotTelegramDisabledIntegrationTest {

  @Autowired private MockMvc mockMvc;

  @MockBean private JavaMailSender javaMailSender;

  @Test
  void webhook_whenDisabled_returns200_withoutSecret() throws Exception {
    mockMvc
        .perform(
            post("/api/v1/webhooks/telegram")
                .contentType(jsonContentType())
                .content("{\"update_id\":1}"))
        .andExpect(status().isOk());
  }

  @NonNull
  private static MediaType jsonContentType() {
    return Objects.requireNonNull(MediaType.APPLICATION_JSON);
  }
}
