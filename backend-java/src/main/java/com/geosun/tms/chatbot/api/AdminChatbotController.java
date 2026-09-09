package com.geosun.tms.chatbot.api;

import com.geosun.tms.auth.config.OpenApiConfig;
import com.geosun.tms.auth.dto.response.PageResponse;
import com.geosun.tms.auth.security.UserPrincipal;
import com.geosun.tms.chatbot.dto.response.AdminBotIdentityDto;
import com.geosun.tms.chatbot.dto.response.AdminChatbotStatusDto;
import com.geosun.tms.chatbot.service.ChatbotAdminService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.Objects;
import org.springframework.lang.NonNull;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** Адмін API статусу каналів і списку прив'язок. */
@Tag(name = "Admin Chatbots")
@RestController
@RequestMapping("/api/v1/admin/chatbots")
@PreAuthorize("hasAnyRole('ADMIN','MANAGER')")
public class AdminChatbotController {

  private final ChatbotAdminService chatbotAdminService;

  public AdminChatbotController(ChatbotAdminService chatbotAdminService) {
    this.chatbotAdminService = chatbotAdminService;
  }

  @Operation(summary = "Chatbot channels status")
  @SecurityRequirement(name = OpenApiConfig.BEARER_SCHEME)
  @GetMapping("/status")
  public AdminChatbotStatusDto status() {
    return chatbotAdminService.status();
  }

  @Operation(summary = "List bot identities")
  @SecurityRequirement(name = OpenApiConfig.BEARER_SCHEME)
  @GetMapping("/identities")
  public PageResponse<AdminBotIdentityDto> identities(
      @AuthenticationPrincipal @NonNull UserPrincipal principal,
      @RequestParam(name = "page", defaultValue = "0") int page,
      @RequestParam(name = "size", defaultValue = "20") int size,
      @RequestParam(name = "channel", required = false) String channel) {
    return chatbotAdminService.listIdentities(
        page, size, channel, Objects.requireNonNull(principal.getRole()));
  }
}
