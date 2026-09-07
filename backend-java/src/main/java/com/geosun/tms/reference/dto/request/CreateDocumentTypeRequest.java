package com.geosun.tms.reference.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.util.List;

public record CreateDocumentTypeRequest(
    @NotBlank @Size(max = 128) String nameUk,
    @NotBlank @Size(max = 128) String nameEn,
    @NotBlank @Size(max = 128) String nameRu,
    @NotBlank @Size(min = 2, max = 2) String countryCode,
    @NotNull @Valid List<DocumentTypeScanPageRequest> plannedScanPages,
    @Size(max = 512) String comment,
    @NotNull @Valid List<DocumentTypeFieldDefinitionRequest> fieldDefinitions) {}
