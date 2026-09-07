package com.geosun.tms.reference.domain;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import java.util.ArrayList;
import java.util.List;

/** Серіалізує {@link List}<{@link DocumentTypeFieldDefinition}> у JSON для колонки field_definitions. */
@Converter(autoApply = false)
public class DocumentTypeFieldDefinitionsConverter
    implements AttributeConverter<List<DocumentTypeFieldDefinition>, String> {

  private static final ObjectMapper MAPPER = new ObjectMapper();
  private static final TypeReference<List<DocumentTypeFieldDefinition>> TYPE =
      new TypeReference<>() {};

  @Override
  public String convertToDatabaseColumn(List<DocumentTypeFieldDefinition> attribute) {
    if (attribute == null || attribute.isEmpty()) {
      return "[]";
    }
    try {
      return MAPPER.writeValueAsString(attribute);
    } catch (Exception ex) {
      throw new IllegalStateException("Failed to serialize document type field definitions", ex);
    }
  }

  @Override
  public List<DocumentTypeFieldDefinition> convertToEntityAttribute(String dbData) {
    if (dbData == null || dbData.isBlank()) {
      return new ArrayList<>();
    }
    try {
      // Відсутній ключ required у старому JSON читаємо як false.
      JsonNode root = MAPPER.readTree(dbData);
      if (root == null || !root.isArray()) {
        return new ArrayList<>();
      }
      List<DocumentTypeFieldDefinition> result = new ArrayList<>();
      for (JsonNode node : root) {
        String key = textOrEmpty(node, "key");
        String nameUk = textOrEmpty(node, "nameUk");
        String nameEn = textOrEmpty(node, "nameEn");
        String nameRu = textOrEmpty(node, "nameRu");
        boolean required = node.hasNonNull("required") && node.get("required").asBoolean(false);
        result.add(new DocumentTypeFieldDefinition(key, nameUk, nameEn, nameRu, required));
      }
      return result;
    } catch (Exception ex) {
      try {
        List<DocumentTypeFieldDefinition> parsed = MAPPER.readValue(dbData, TYPE);
        return parsed == null ? new ArrayList<>() : new ArrayList<>(parsed);
      } catch (Exception nested) {
        throw new IllegalStateException(
            "Failed to deserialize document type field definitions", ex);
      }
    }
  }

  private static String textOrEmpty(JsonNode node, String field) {
    JsonNode value = node.get(field);
    return value == null || value.isNull() ? "" : value.asText();
  }
}
