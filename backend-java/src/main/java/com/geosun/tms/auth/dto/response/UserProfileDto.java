package com.geosun.tms.auth.dto.response;

import java.util.List;

/** Профіль облікового запису (відповідь GET/PUT і вкладення в public/admin DTO). */
public record UserProfileDto(
    String lastName,
    String firstName,
    String patronymic,
    String personType,
    String legalEntityEdrpou,
    List<String> preferredChannels,
    List<UserContactPhoneDto> phones,
    boolean profileComplete) {

  /** Порожній профіль для користувача без рядка в user_profiles. */
  public static UserProfileDto empty() {
    return new UserProfileDto(null, null, null, null, null, List.of(), List.of(), false);
  }
}
