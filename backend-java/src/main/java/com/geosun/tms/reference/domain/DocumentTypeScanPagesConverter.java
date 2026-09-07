package com.geosun.tms.reference.domain;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import java.util.ArrayList;
import java.util.List;

/** Серіалізує {@link List}<{@link DocumentTypeScanPage}> у JSON для колонки planned_scan_pages. */
@Converter(autoApply = false)
public class DocumentTypeScanPagesConverter
    implements AttributeConverter<List<DocumentTypeScanPage>, String> {

  private static final ObjectMapper MAPPER = new ObjectMapper();
  private static final TypeReference<List<DocumentTypeScanPage>> TYPE = new TypeReference<>() {};

  @Override
  public String convertToDatabaseColumn(List<DocumentTypeScanPage> attribute) {
    if (attribute == null || attribute.isEmpty()) {
      return "[]";
    }
    try {
      return MAPPER.writeValueAsString(attribute);
    } catch (Exception ex) {
      throw new IllegalStateException("Failed to serialize document type scan pages", ex);
    }
  }

  @Override
  public List<DocumentTypeScanPage> convertToEntityAttribute(String dbData) {
    if (dbData == null || dbData.isBlank()) {
      return new ArrayList<>();
    }
    try {
      List<DocumentTypeScanPage> parsed = MAPPER.readValue(dbData, TYPE);
      return parsed == null ? new ArrayList<>() : new ArrayList<>(parsed);
    } catch (Exception ex) {
      throw new IllegalStateException("Failed to deserialize document type scan pages", ex);
    }
  }
}
