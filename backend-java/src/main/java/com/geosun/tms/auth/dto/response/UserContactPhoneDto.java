package com.geosun.tms.auth.dto.response;

/** Телефон у профілі користувача. */
public record UserContactPhoneDto(
    String id, String phone, boolean primary, boolean telegram, boolean whatsapp, boolean viber) {}
