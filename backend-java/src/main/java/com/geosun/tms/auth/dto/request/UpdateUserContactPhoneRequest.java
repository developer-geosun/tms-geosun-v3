package com.geosun.tms.auth.dto.request;

/** Елемент phones[] у PUT профілю. */
public record UpdateUserContactPhoneRequest(
    String id, String phone, Boolean primary, Boolean telegram, Boolean whatsapp, Boolean viber) {}
