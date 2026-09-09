package com.geosun.tms.chatbot.api;

import com.geosun.tms.auth.config.OpenApiConfig;
import com.geosun.tms.auth.security.UserPrincipal;
import com.geosun.tms.chatbot.dto.request.CreateBotLinkCodeRequest;
import com.geosun.tms.chatbot.dto.response.BotIdentitiesSelfResponse;
import com.geosun.tms.chatbot.dto.response.BotLinkCodeResponse;
import com.geosun.tms.chatbot.service.ChatbotLinkService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.Objects;
import org.springframework.http.ResponseEntity;
import org.springframework.lang.NonNull;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** Self-API прив'язки чат-бота до поточної обліковки. */
@Tag(name = "User Bot Identities")
@RestController
@RequestMapping("/api/v1/users/me")
public class UserBotIdentityController {

  private final ChatbotLinkService chatbotLinkService;

  public UserBotIdentityController(ChatbotLinkService chatbotLinkService) {
    this.chatbotLinkService = chatbotLinkService;
  }

  @Operation(summary = "Create one-time bot link code")
  @SecurityRequirement(name = OpenApiConfig.BEARER_SCHEME)
  @PostMapping("/bot-link-codes")
  public BotLinkCodeResponse createLinkCode(
      @AuthenticationPrincipal @NonNull UserPrincipal principal,
      @Valid @RequestBody @NonNull CreateBotLinkCodeRequest body) {
    return chatbotLinkService.createLinkCode(
        Objects.requireNonNull(principal.getUserId()), Objects.requireNonNull(body.channel()));
  }

  @Operation(summary = "List own bot identities")
  @SecurityRequirement(name = OpenApiConfig.BEARER_SCHEME)
  @GetMapping("/bot-identities")
  public BotIdentitiesSelfResponse listIdentities(
      @AuthenticationPrincipal @NonNull UserPrincipal principal) {
    return chatbotLinkService.listIdentities(Objects.requireNonNull(principal.getUserId()));
  }

  @Operation(summary = "Unlink own bot identity for channel")
  @SecurityRequirement(name = OpenApiConfig.BEARER_SCHEME)
  @DeleteMapping("/bot-identities/{channel}")
  public ResponseEntity<Void> unlink(
      @AuthenticationPrincipal @NonNull UserPrincipal principal,
      @PathVariable("channel") @NonNull String channel) {
    chatbotLinkService.unlink(Objects.requireNonNull(principal.getUserId()), channel);
    return ResponseEntity.noContent().build();
  }
}
