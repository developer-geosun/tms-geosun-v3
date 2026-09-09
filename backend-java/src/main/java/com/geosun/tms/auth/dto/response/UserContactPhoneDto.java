package com.geosun.tms.auth.dto.response;

import java.time.Instant;

/** Телефон у профілі користувача. */
public record UserContactPhoneDto(
    String id,
    String phone,
    boolean primary,
    boolean telegram,
    boolean whatsapp,
    boolean viber,
    boolean verified,
    Instant verifiedAt,
    String verifiedVia) {}
