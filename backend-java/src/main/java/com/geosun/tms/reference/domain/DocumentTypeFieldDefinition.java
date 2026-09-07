package com.geosun.tms.reference.domain;

/** Один елемент JSON field_definitions: ключ, назви трьома мовами, прапорець обовʼязковості. */
public record DocumentTypeFieldDefinition(
    String key, String nameUk, String nameEn, String nameRu, boolean required) {}
