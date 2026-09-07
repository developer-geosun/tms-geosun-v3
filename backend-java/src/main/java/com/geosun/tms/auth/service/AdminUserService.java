package com.geosun.tms.auth.service;

import com.geosun.tms.auth.domain.user.Role;
import com.geosun.tms.auth.domain.user.User;
import com.geosun.tms.auth.dto.mapper.UserDtoMapper;
import com.geosun.tms.auth.dto.request.AdminUserListQuery;
import com.geosun.tms.auth.dto.response.PageResponse;
import com.geosun.tms.auth.dto.response.UserAdminDto;
import com.geosun.tms.auth.dto.response.UserProfileDto;
import com.geosun.tms.auth.exception.ApiException;
import com.geosun.tms.auth.repository.RefreshTokenRepository;
import com.geosun.tms.auth.repository.UserRepository;
import com.geosun.tms.auth.repository.UserSpecifications;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

/**
 * Адмін-операції над користувачами: список, роль, active, soft-delete, restore.
 */
@Service
public class AdminUserService {

  private static final Set<String> ALLOWED_SORT = Set.of("createdAt", "updatedAt", "email", "role");

  private final UserRepository userRepository;
  private final RefreshTokenRepository refreshTokenRepository;
  private final SuperAdminPasswordService superAdminPasswordService;
  private final UserProfileService userProfileService;

  public AdminUserService(
      UserRepository userRepository,
      RefreshTokenRepository refreshTokenRepository,
      SuperAdminPasswordService superAdminPasswordService,
      UserProfileService userProfileService) {
    this.userRepository = userRepository;
    this.refreshTokenRepository = refreshTokenRepository;
    this.superAdminPasswordService = superAdminPasswordService;
    this.userProfileService = userProfileService;
  }

  @Transactional(readOnly = true)
  public PageResponse<UserAdminDto> list(AdminUserListQuery query) {
    int page = Math.max(0, query.page());
    int size = Math.min(100, Math.max(1, query.size()));
    Boolean deleted = query.deleted() == null ? Boolean.FALSE : query.deleted();
    Sort sort = resolveSort(query.sort(), query.order());
    Page<User> result =
        userRepository.findAll(
            UserSpecifications.adminFilter(
                query.email(), query.name(), query.role(), query.active(), deleted),
            PageRequest.of(page, size, sort));
    List<String> ids =
        result.getContent().stream().map(u -> Objects.requireNonNull(u.getId())).toList();
    Map<String, UserProfileDto> profiles = userProfileService.getByUserIds(ids);
    List<UserAdminDto> content =
        result.getContent().stream()
            .map(
                user ->
                    UserDtoMapper.toAdminDto(
                        Objects.requireNonNull(user),
                        profiles.getOrDefault(user.getId(), UserProfileDto.empty())))
            .toList();
    return new PageResponse<>(
        content,
        result.getTotalElements(),
        result.getTotalPages(),
        result.getNumber(),
        result.getSize());
  }

  @Transactional(readOnly = true)
  public UserAdminDto getById(@NonNull String rawId) {
    User user = requireUser(rawId);
    return UserDtoMapper.toAdminDto(
        user, userProfileService.getByUserId(Objects.requireNonNull(user.getId())));
  }

  @Transactional
  public UserAdminDto updateRole(
      @NonNull String actorUserId,
      @NonNull String rawId,
      @NonNull Role newRole,
      String superAdminPassword) {
    User user = requireUser(rawId);
    assertNotSelf(actorUserId, user.getId());
    assertNotDeleted(user);
    if (user.getRole() == newRole) {
      return toDto(user);
    }
    if (user.getRole() == Role.ADMIN && newRole != Role.ADMIN) {
      assertNotLastActiveAdmin(user);
      // Зняття ролі ADMIN — лише після коректного пароля суперадміна
      superAdminPasswordService.requireValid(superAdminPassword);
    }
    user.setRole(newRole);
    refreshTokenRepository.revokeAllActiveByUserId(user.getId(), Instant.now());
    return toDto(userRepository.save(Objects.requireNonNull(user)));
  }

  @Transactional
  public UserAdminDto setActive(
      @NonNull String actorUserId, @NonNull String rawId, boolean active) {
    User user = requireUser(rawId);
    assertNotSelf(actorUserId, user.getId());
    assertNotDeleted(user);
    if (user.isActive() == active) {
      return toDto(user);
    }
    if (!active && user.getRole() == Role.ADMIN) {
      assertNotLastActiveAdmin(user);
    }
    user.setActive(active);
    if (!active) {
      refreshTokenRepository.revokeAllActiveByUserId(user.getId(), Instant.now());
    }
    return toDto(userRepository.save(Objects.requireNonNull(user)));
  }

  @Transactional
  public void softDelete(@NonNull String actorUserId, @NonNull String rawId) {
    User user = requireUser(rawId);
    if (user.isDeleted()) {
      return;
    }
    assertNotSelf(actorUserId, user.getId());
    if (user.getRole() == Role.ADMIN && user.isActive()) {
      assertNotLastActiveAdmin(user);
    }
    user.setDeleted(true);
    user.setDeletedAt(Instant.now());
    user.setActive(false);
    refreshTokenRepository.revokeAllActiveByUserId(user.getId(), Instant.now());
    userRepository.save(Objects.requireNonNull(user));
  }

  /**
   * Відновлення після soft-delete: знімає deleted, знову активує акаунт.
   * Ідемпотентно, якщо вже не видалений. Конфлікт email — якщо є інший активний з тим самим email.
   */
  @Transactional
  public UserAdminDto restore(@NonNull String actorUserId, @NonNull String rawId) {
    User user = requireUser(rawId);
    assertNotSelf(actorUserId, user.getId());
    if (!user.isDeleted()) {
      return toDto(user);
    }
    if (userRepository.existsByEmailAndDeletedFalse(user.getEmail())) {
      throw ApiException.conflict(
          "EMAIL_ALREADY_EXISTS", "Cannot restore: another active user already uses this email");
    }
    user.setDeleted(false);
    user.setDeletedAt(null);
    user.setActive(true);
    return toDto(userRepository.save(Objects.requireNonNull(user)));
  }

  private User requireUser(@NonNull String rawId) {
    try {
      UUID.fromString(rawId);
    } catch (IllegalArgumentException ex) {
      throw ApiException.badRequest("VALIDATION_ERROR", "Invalid user id");
    }
    return userRepository
        .findById(rawId)
        .orElseThrow(() -> ApiException.notFound("User not found"));
  }

  private void assertNotSelf(String actorUserId, String targetUserId) {
    if (actorUserId.equals(targetUserId)) {
      throw ApiException.badRequest(
          "SELF_OPERATION_FORBIDDEN", "Cannot perform this operation on your own account");
    }
  }

  private void assertNotDeleted(User user) {
    if (user.isDeleted()) {
      throw ApiException.conflict("USER_DELETED", "User is deleted");
    }
  }

  private void assertNotLastActiveAdmin(User target) {
    long activeAdmins = userRepository.countActiveByRole(Role.ADMIN);
    if (activeAdmins <= 1
        && target.getRole() == Role.ADMIN
        && target.isActive()
        && !target.isDeleted()) {
      throw ApiException.conflict(
          "LAST_ADMIN_PROTECTED", "Cannot modify the last active ADMIN account");
    }
  }

  private @NonNull Sort resolveSort(String sort, String order) {
    String property = StringUtils.hasText(sort) && ALLOWED_SORT.contains(sort) ? sort : "createdAt";
    boolean asc = "asc".equalsIgnoreCase(order);
    return Sort.by(asc ? Sort.Direction.ASC : Sort.Direction.DESC, property);
  }

  private UserAdminDto toDto(User user) {
    return UserDtoMapper.toAdminDto(
        user, userProfileService.getByUserId(Objects.requireNonNull(user.getId())));
  }
}
