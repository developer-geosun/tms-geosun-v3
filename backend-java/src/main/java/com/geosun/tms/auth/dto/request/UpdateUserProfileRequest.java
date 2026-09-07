package com.geosun.tms.auth.dto.request;

import java.util.List;

/** Тіло PUT профілю (self і admin). */
public record UpdateUserProfileRequest(
    String lastName,
    String firstName,
    String patronymic,
    String personType,
    String legalEntityEdrpou,
    List<String> preferredChannels,
    List<UpdateUserContactPhoneRequest> phones) {}
