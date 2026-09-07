package com.geosun.tms.reference.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record DocumentTypeScanPageRequest(
    @NotBlank @Size(max = 32) String key,
    @NotBlank @Size(max = 128) String legendEn,
    @NotBlank @Size(max = 128) String legendUa,
    @NotBlank @Size(max = 128) String legendRu) {}
