package com.geosun.tms.reference.dto.response;

import java.time.Instant;
import java.util.List;

public record DocumentTypeReferenceDto(
    String id,
    String nameUk,
    String nameEn,
    String nameRu,
    String countryCode,
    List<DocumentTypeScanPageDto> plannedScanPages,
    String comment,
    List<DocumentTypeFieldDefinitionDto> fieldDefinitions,
    boolean deleted,
    Instant deletedAt,
    Instant createdAt,
    Instant updatedAt) {}
