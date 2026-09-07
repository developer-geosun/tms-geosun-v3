package com.geosun.tms.auth.api;

import com.geosun.tms.auth.config.OpenApiConfig;
import com.geosun.tms.auth.dto.request.UpdateUserProfileRequest;
import com.geosun.tms.auth.dto.response.UserProfileDto;
import com.geosun.tms.auth.security.UserPrincipal;
import com.geosun.tms.auth.service.UserProfileService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.lang.NonNull;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** Self-service профіль поточного користувача. */
@Tag(name = "User Profile")
@RestController
@RequestMapping("/api/v1/users/me/profile")
public class UserProfileController {

  private final UserProfileService userProfileService;

  public UserProfileController(UserProfileService userProfileService) {
    this.userProfileService = userProfileService;
  }

  @Operation(summary = "Get own profile")
  @SecurityRequirement(name = OpenApiConfig.BEARER_SCHEME)
  @GetMapping
  public UserProfileDto get(@AuthenticationPrincipal @NonNull UserPrincipal principal) {
    return userProfileService.getByUserId(principal.getUserId());
  }

  @Operation(summary = "Replace own profile and phones")
  @SecurityRequirement(name = OpenApiConfig.BEARER_SCHEME)
  @PutMapping
  public UserProfileDto put(
      @AuthenticationPrincipal @NonNull UserPrincipal principal,
      @Valid @RequestBody @NonNull UpdateUserProfileRequest body) {
    return userProfileService.putSelf(principal.getUserId(), body);
  }
}
