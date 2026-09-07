-- Скидання довідника видів документів і seed UA-каталогу (5 видів).
-- planned_scan_pages: INT → JSON; додано comment (MRZ-стандарт).

DELETE FROM document_types;

ALTER TABLE document_types
    MODIFY COLUMN planned_scan_pages JSON NOT NULL;

ALTER TABLE document_types
    ADD COLUMN `comment` VARCHAR(512) NOT NULL DEFAULT '' AFTER field_definitions;

-- Спільні сторінки лицьова/зворотна для 4 видів (не книжковий паспорт).
-- INSERT 1: Національний паспорт (книжка) — planned_scan_pages = []
INSERT INTO document_types (
    id, name_uk, name_en, name_ru, country_code, planned_scan_pages, field_definitions, `comment`,
    is_deleted, deleted_at, created_at, updated_at
) VALUES (
    'c2000000-0000-4000-8000-000000000001',
    CONVERT(UNHEX('D09FD0B0D181D0BFD0BED180D18220D0B3D180D0BED0BCD0B0D0B4D18FD0BDD0B8D0BDD0B020D0A3D0BAD180D0B0D197D0BDD0B82028D0BAD0BDD0B8D0B6D0BAD0BED0B2D0B8D0B929') USING utf8mb4),
    'National passport (booklet)',
    CONVERT(UNHEX('D09DD0B0D186D0B8D0BED0BDD0B0D0BBD18CD0BDD18BD0B920D0BFD0B0D181D0BFD0BED180D1822028D0BAD0BDD0B8D0B6D0BAD0B029') USING utf8mb4),
    'UA',
    CAST('[]' AS JSON),
    JSON_ARRAY(
        JSON_OBJECT(
            'key', 'passportSeries',
            'nameUk', CONVERT(UNHEX('D0A1D0B5D180D196D18F') USING utf8mb4),
            'nameEn', 'Series',
            'nameRu', CONVERT(UNHEX('D0A1D0B5D180D0B8D18F') USING utf8mb4),
            'required', TRUE
        ),
        JSON_OBJECT(
            'key', 'passportNumber',
            'nameUk', CONVERT(UNHEX('D09DD0BED0BCD0B5D180') USING utf8mb4),
            'nameEn', 'Number',
            'nameRu', CONVERT(UNHEX('D09DD0BED0BCD0B5D180') USING utf8mb4),
            'required', TRUE
        ),
        JSON_OBJECT(
            'key', 'lastName',
            'nameUk', CONVERT(UNHEX('D09FD180D196D0B7D0B2D0B8D189D0B5') USING utf8mb4),
            'nameEn', 'Last name',
            'nameRu', CONVERT(UNHEX('D0A4D0B0D0BCD0B8D0BBD0B8D18F') USING utf8mb4),
            'required', TRUE
        ),
        JSON_OBJECT(
            'key', 'firstName',
            'nameUk', CONVERT(UNHEX('D086D0BC27D18F') USING utf8mb4),
            'nameEn', 'First name',
            'nameRu', CONVERT(UNHEX('D098D0BCD18F') USING utf8mb4),
            'required', TRUE
        ),
        JSON_OBJECT(
            'key', 'patronymic',
            'nameUk', CONVERT(UNHEX('D09FD0BE20D0B1D0B0D182D18CD0BAD0BED0B2D196') USING utf8mb4),
            'nameEn', 'Patronymic',
            'nameRu', CONVERT(UNHEX('D09ED182D187D0B5D181D182D0B2D0BE') USING utf8mb4),
            'required', FALSE
        ),
        JSON_OBJECT(
            'key', 'issuedOn',
            'nameUk', CONVERT(UNHEX('D094D0B0D182D0B020D0B2D0B8D0B4D0B0D187D196') USING utf8mb4),
            'nameEn', 'Issue date',
            'nameRu', CONVERT(UNHEX('D094D0B0D182D0B020D0B2D18BD0B4D0B0D187D0B8') USING utf8mb4),
            'required', TRUE
        ),
        JSON_OBJECT(
            'key', 'issuedBy',
            'nameUk', CONVERT(UNHEX('D09AD0B8D0BC20D0B2D0B8D0B4D0B0D0BDD0B8D0B9') USING utf8mb4),
            'nameEn', 'Issued by',
            'nameRu', CONVERT(UNHEX('D09AD0B5D0BC20D0B2D18BD0B4D0B0D0BD') USING utf8mb4),
            'required', TRUE
        ),
        JSON_OBJECT(
            'key', 'expiresOn',
            'nameUk', CONVERT(UNHEX('D094D196D0B9D181D0BDD0B8D0B920D0B4D0BE') USING utf8mb4),
            'nameEn', 'Valid until',
            'nameRu', CONVERT(UNHEX('D094D0B5D0B9D181D182D0B2D0B8D182D0B5D0BBD0B5D0BD20D0B4D0BE') USING utf8mb4),
            'required', FALSE
        )
    ),
    CONVERT(UNHEX('D0BDD0B5D0BCD0B0D194204943414F204D525A2028D0BAD0BDD0B8D0B6D0BAD0BED0B2D0B8D0B920D0B2D0BDD183D182D180D196D188D0BDD196D0B920D0BFD0B0D181D0BFD0BED180D18229') USING utf8mb4),
    FALSE, NULL, CURRENT_TIMESTAMP(6), CURRENT_TIMESTAMP(6)
);

-- INSERT 2: ID-картка
INSERT INTO document_types (
    id, name_uk, name_en, name_ru, country_code, planned_scan_pages, field_definitions, `comment`,
    is_deleted, deleted_at, created_at, updated_at
) VALUES (
    'c2000000-0000-4000-8000-000000000002',
    CONVERT(UNHEX('49442DD0BAD0B0D180D182D0BAD0B0') USING utf8mb4),
    'ID card',
    CONVERT(UNHEX('49442DD0BAD0B0D180D182D0BED187D0BAD0B0') USING utf8mb4),
    'UA',
    JSON_ARRAY(
        JSON_OBJECT(
            'key', '1',
            'legendEn', 'front',
            'legendUa', CONVERT(UNHEX('D0BBD0B8D186D18CD0BED0B2D0B020D181D182D0BED180D0BED0BDD0B0') USING utf8mb4),
            'legendRu', CONVERT(UNHEX('D0BBD0B8D186D0B5D0B2D0B0D18F20D181D182D0BED180D0BED0BDD0B0') USING utf8mb4)
        ),
        JSON_OBJECT(
            'key', '2',
            'legendEn', 'back',
            'legendUa', CONVERT(UNHEX('D0B7D0B2D0BED180D0BED182D0BDD0B020D181D182D0BED180D0BED0BDD0B0') USING utf8mb4),
            'legendRu', CONVERT(UNHEX('D0BED0B1D180D0B0D182D0BDD0B0D18F20D181D182D0BED180D0BED0BDD0B0') USING utf8mb4)
        )
    ),
    JSON_ARRAY(
        JSON_OBJECT(
            'key', 'documentNumber',
            'nameUk', CONVERT(UNHEX('D09DD0BED0BCD0B5D18020D0B4D0BED0BAD183D0BCD0B5D0BDD182D0B0') USING utf8mb4),
            'nameEn', 'Document number',
            'nameRu', CONVERT(UNHEX('D09DD0BED0BCD0B5D18020D0B4D0BED0BAD183D0BCD0B5D0BDD182D0B0') USING utf8mb4),
            'required', TRUE
        ),
        JSON_OBJECT(
            'key', 'recordNumber',
            'nameUk', CONVERT(UNHEX('D097D0B0D0BFD0B8D18120E284962028D0A3D09DD097D0A029') USING utf8mb4),
            'nameEn', 'Record No.',
            'nameRu', CONVERT(UNHEX('D097D0B0D0BFD0B8D181D18C20E28496') USING utf8mb4),
            'required', TRUE
        ),
        JSON_OBJECT(
            'key', 'lastName',
            'nameUk', CONVERT(UNHEX('D09FD180D196D0B7D0B2D0B8D189D0B5') USING utf8mb4),
            'nameEn', 'Last name',
            'nameRu', CONVERT(UNHEX('D0A4D0B0D0BCD0B8D0BBD0B8D18F') USING utf8mb4),
            'required', TRUE
        ),
        JSON_OBJECT(
            'key', 'firstName',
            'nameUk', CONVERT(UNHEX('D086D0BC27D18F') USING utf8mb4),
            'nameEn', 'First name',
            'nameRu', CONVERT(UNHEX('D098D0BCD18F') USING utf8mb4),
            'required', TRUE
        ),
        JSON_OBJECT(
            'key', 'patronymic',
            'nameUk', CONVERT(UNHEX('D09FD0BE20D0B1D0B0D182D18CD0BAD0BED0B2D196') USING utf8mb4),
            'nameEn', 'Patronymic',
            'nameRu', CONVERT(UNHEX('D09ED182D187D0B5D181D182D0B2D0BE') USING utf8mb4),
            'required', FALSE
        ),
        JSON_OBJECT(
            'key', 'issuedOn',
            'nameUk', CONVERT(UNHEX('D094D0B0D182D0B020D0B2D0B8D0B4D0B0D187D196') USING utf8mb4),
            'nameEn', 'Issue date',
            'nameRu', CONVERT(UNHEX('D094D0B0D182D0B020D0B2D18BD0B4D0B0D187D0B8') USING utf8mb4),
            'required', TRUE
        ),
        JSON_OBJECT(
            'key', 'expiresOn',
            'nameUk', CONVERT(UNHEX('D094D196D0B9D181D0BDD0B8D0B920D0B4D0BE') USING utf8mb4),
            'nameEn', 'Valid until',
            'nameRu', CONVERT(UNHEX('D094D0B5D0B9D181D182D0B2D0B8D182D0B5D0BBD0B5D0BD20D0B4D0BE') USING utf8mb4),
            'required', TRUE
        ),
        JSON_OBJECT(
            'key', 'issuedBy',
            'nameUk', CONVERT(UNHEX('D09AD0B8D0BC20D0B2D0B8D0B4D0B0D0BDD0B8D0B9') USING utf8mb4),
            'nameEn', 'Issued by',
            'nameRu', CONVERT(UNHEX('D09AD0B5D0BC20D0B2D18BD0B4D0B0D0BD') USING utf8mb4),
            'required', TRUE
        )
    ),
    CONVERT(UNHEX('4943414F203933303320544431202833C397333029') USING utf8mb4),
    FALSE, NULL, CURRENT_TIMESTAMP(6), CURRENT_TIMESTAMP(6)
);

-- INSERT 3: Закордонний паспорт
INSERT INTO document_types (
    id, name_uk, name_en, name_ru, country_code, planned_scan_pages, field_definitions, `comment`,
    is_deleted, deleted_at, created_at, updated_at
) VALUES (
    'c2000000-0000-4000-8000-000000000003',
    CONVERT(UNHEX('D097D0B0D0BAD0BED180D0B4D0BED0BDD0BDD0B8D0B920D0BFD0B0D181D0BFD0BED180D182') USING utf8mb4),
    'International passport',
    CONVERT(UNHEX('D097D0B0D0B3D180D0B0D0BDD0B8D187D0BDD18BD0B920D0BFD0B0D181D0BFD0BED180D182') USING utf8mb4),
    'UA',
    JSON_ARRAY(
        JSON_OBJECT(
            'key', '1',
            'legendEn', 'front',
            'legendUa', CONVERT(UNHEX('D0BBD0B8D186D18CD0BED0B2D0B020D181D182D0BED180D0BED0BDD0B0') USING utf8mb4),
            'legendRu', CONVERT(UNHEX('D0BBD0B8D186D0B5D0B2D0B0D18F20D181D182D0BED180D0BED0BDD0B0') USING utf8mb4)
        ),
        JSON_OBJECT(
            'key', '2',
            'legendEn', 'back',
            'legendUa', CONVERT(UNHEX('D0B7D0B2D0BED180D0BED182D0BDD0B020D181D182D0BED180D0BED0BDD0B0') USING utf8mb4),
            'legendRu', CONVERT(UNHEX('D0BED0B1D180D0B0D182D0BDD0B0D18F20D181D182D0BED180D0BED0BDD0B0') USING utf8mb4)
        )
    ),
    JSON_ARRAY(
        JSON_OBJECT(
            'key', 'passportNumber',
            'nameUk', CONVERT(UNHEX('D09DD0BED0BCD0B5D18020D0BFD0B0D181D0BFD0BED180D182D0B0') USING utf8mb4),
            'nameEn', 'Passport number',
            'nameRu', CONVERT(UNHEX('D09DD0BED0BCD0B5D18020D0BFD0B0D181D0BFD0BED180D182D0B0') USING utf8mb4),
            'required', TRUE
        ),
        JSON_OBJECT(
            'key', 'lastName',
            'nameUk', CONVERT(UNHEX('D09FD180D196D0B7D0B2D0B8D189D0B5') USING utf8mb4),
            'nameEn', 'Last name',
            'nameRu', CONVERT(UNHEX('D0A4D0B0D0BCD0B8D0BBD0B8D18F') USING utf8mb4),
            'required', TRUE
        ),
        JSON_OBJECT(
            'key', 'firstName',
            'nameUk', CONVERT(UNHEX('D086D0BC27D18F') USING utf8mb4),
            'nameEn', 'First name',
            'nameRu', CONVERT(UNHEX('D098D0BCD18F') USING utf8mb4),
            'required', TRUE
        ),
        JSON_OBJECT(
            'key', 'issuedOn',
            'nameUk', CONVERT(UNHEX('D094D0B0D182D0B020D0B2D0B8D0B4D0B0D187D196') USING utf8mb4),
            'nameEn', 'Issue date',
            'nameRu', CONVERT(UNHEX('D094D0B0D182D0B020D0B2D18BD0B4D0B0D187D0B8') USING utf8mb4),
            'required', TRUE
        ),
        JSON_OBJECT(
            'key', 'expiresOn',
            'nameUk', CONVERT(UNHEX('D094D196D0B9D181D0BDD0B8D0B920D0B4D0BE') USING utf8mb4),
            'nameEn', 'Valid until',
            'nameRu', CONVERT(UNHEX('D094D0B5D0B9D181D182D0B2D0B8D182D0B5D0BBD0B5D0BD20D0B4D0BE') USING utf8mb4),
            'required', TRUE
        ),
        JSON_OBJECT(
            'key', 'issuedBy',
            'nameUk', CONVERT(UNHEX('D09AD0B8D0BC20D0B2D0B8D0B4D0B0D0BDD0B8D0B9') USING utf8mb4),
            'nameEn', 'Issued by',
            'nameRu', CONVERT(UNHEX('D09AD0B5D0BC20D0B2D18BD0B4D0B0D0BD') USING utf8mb4),
            'required', TRUE
        )
    ),
    CONVERT(UNHEX('4943414F203933303320544433202832C397343429') USING utf8mb4),
    FALSE, NULL, CURRENT_TIMESTAMP(6), CURRENT_TIMESTAMP(6)
);

-- INSERT 4: Посвідчення водія
INSERT INTO document_types (
    id, name_uk, name_en, name_ru, country_code, planned_scan_pages, field_definitions, `comment`,
    is_deleted, deleted_at, created_at, updated_at
) VALUES (
    'c2000000-0000-4000-8000-000000000004',
    CONVERT(UNHEX('D09FD0BED181D0B2D196D0B4D187D0B5D0BDD0BDD18F20D0B2D0BED0B4D196D18F') USING utf8mb4),
    'Driver''s license',
    CONVERT(UNHEX('D092D0BED0B4D0B8D182D0B5D0BBD18CD181D0BAD0BED0B520D183D0B4D0BED181D182D0BED0B2D0B5D180D0B5D0BDD0B8D0B5') USING utf8mb4),
    'UA',
    JSON_ARRAY(
        JSON_OBJECT(
            'key', '1',
            'legendEn', 'front',
            'legendUa', CONVERT(UNHEX('D0BBD0B8D186D18CD0BED0B2D0B020D181D182D0BED180D0BED0BDD0B0') USING utf8mb4),
            'legendRu', CONVERT(UNHEX('D0BBD0B8D186D0B5D0B2D0B0D18F20D181D182D0BED180D0BED0BDD0B0') USING utf8mb4)
        ),
        JSON_OBJECT(
            'key', '2',
            'legendEn', 'back',
            'legendUa', CONVERT(UNHEX('D0B7D0B2D0BED180D0BED182D0BDD0B020D181D182D0BED180D0BED0BDD0B0') USING utf8mb4),
            'legendRu', CONVERT(UNHEX('D0BED0B1D180D0B0D182D0BDD0B0D18F20D181D182D0BED180D0BED0BDD0B0') USING utf8mb4)
        )
    ),
    JSON_ARRAY(
        JSON_OBJECT(
            'key', 'licenseNumber',
            'nameUk', CONVERT(UNHEX('D09DD0BED0BCD0B5D18020D0BFD0BED181D0B2D196D0B4D187D0B5D0BDD0BDD18F') USING utf8mb4),
            'nameEn', 'License number',
            'nameRu', CONVERT(UNHEX('D09DD0BED0BCD0B5D18020D183D0B4D0BED181D182D0BED0B2D0B5D180D0B5D0BDD0B8D18F') USING utf8mb4),
            'required', TRUE
        ),
        JSON_OBJECT(
            'key', 'licenseCategories',
            'nameUk', CONVERT(UNHEX('D09AD0B0D182D0B5D0B3D0BED180D196D197') USING utf8mb4),
            'nameEn', 'Categories',
            'nameRu', CONVERT(UNHEX('D09AD0B0D182D0B5D0B3D0BED180D0B8D0B8') USING utf8mb4),
            'required', TRUE
        ),
        JSON_OBJECT(
            'key', 'licenseIssuedOn',
            'nameUk', CONVERT(UNHEX('D094D0B0D182D0B020D0B2D0B8D0B4D0B0D187D196') USING utf8mb4),
            'nameEn', 'Issue date',
            'nameRu', CONVERT(UNHEX('D094D0B0D182D0B020D0B2D18BD0B4D0B0D187D0B8') USING utf8mb4),
            'required', TRUE
        ),
        JSON_OBJECT(
            'key', 'licenseExpiresOn',
            'nameUk', CONVERT(UNHEX('D094D196D0B9D181D0BDD0B520D0B4D0BE') USING utf8mb4),
            'nameEn', 'Valid until',
            'nameRu', CONVERT(UNHEX('D094D0B5D0B9D181D182D0B2D183D0B5D18220D0B4D0BE') USING utf8mb4),
            'required', TRUE
        ),
        JSON_OBJECT(
            'key', 'lastName',
            'nameUk', CONVERT(UNHEX('D09FD180D196D0B7D0B2D0B8D189D0B5') USING utf8mb4),
            'nameEn', 'Last name',
            'nameRu', CONVERT(UNHEX('D0A4D0B0D0BCD0B8D0BBD0B8D18F') USING utf8mb4),
            'required', TRUE
        ),
        JSON_OBJECT(
            'key', 'firstName',
            'nameUk', CONVERT(UNHEX('D086D0BC27D18F') USING utf8mb4),
            'nameEn', 'First name',
            'nameRu', CONVERT(UNHEX('D098D0BCD18F') USING utf8mb4),
            'required', TRUE
        )
    ),
    CONVERT(UNHEX('D0BDD0B5D0BCD0B0D194204943414F204D525A') USING utf8mb4),
    FALSE, NULL, CURRENT_TIMESTAMP(6), CURRENT_TIMESTAMP(6)
);

-- INSERT 5: Свідоцтво про реєстрацію ТЗ
INSERT INTO document_types (
    id, name_uk, name_en, name_ru, country_code, planned_scan_pages, field_definitions, `comment`,
    is_deleted, deleted_at, created_at, updated_at
) VALUES (
    'c2000000-0000-4000-8000-000000000005',
    CONVERT(UNHEX('D0A1D0B2D196D0B4D0BED186D182D0B2D0BE20D0BFD180D0BE20D180D0B5D194D181D182D180D0B0D186D196D18E20D0A2D097') USING utf8mb4),
    'Vehicle registration certificate',
    CONVERT(UNHEX('D0A1D0B2D0B8D0B4D0B5D182D0B5D0BBD18CD181D182D0B2D0BE20D0BE20D180D0B5D0B3D0B8D181D182D180D0B0D186D0B8D0B820D0A2D0A1') USING utf8mb4),
    'UA',
    JSON_ARRAY(
        JSON_OBJECT(
            'key', '1',
            'legendEn', 'front',
            'legendUa', CONVERT(UNHEX('D0BBD0B8D186D18CD0BED0B2D0B020D181D182D0BED180D0BED0BDD0B0') USING utf8mb4),
            'legendRu', CONVERT(UNHEX('D0BBD0B8D186D0B5D0B2D0B0D18F20D181D182D0BED180D0BED0BDD0B0') USING utf8mb4)
        ),
        JSON_OBJECT(
            'key', '2',
            'legendEn', 'back',
            'legendUa', CONVERT(UNHEX('D0B7D0B2D0BED180D0BED182D0BDD0B020D181D182D0BED180D0BED0BDD0B0') USING utf8mb4),
            'legendRu', CONVERT(UNHEX('D0BED0B1D180D0B0D182D0BDD0B0D18F20D181D182D0BED180D0BED0BDD0B0') USING utf8mb4)
        )
    ),
    JSON_ARRAY(
        JSON_OBJECT(
            'key', 'registrationSeries',
            'nameUk', CONVERT(UNHEX('D0A1D0B5D180D196D18F20D181D0B2D196D0B4D0BED186D182D0B2D0B0') USING utf8mb4),
            'nameEn', 'Registration series',
            'nameRu', CONVERT(UNHEX('D0A1D0B5D180D0B8D18F20D181D0B2D0B8D0B4D0B5D182D0B5D0BBD18CD181D182D0B2D0B0') USING utf8mb4),
            'required', TRUE
        ),
        JSON_OBJECT(
            'key', 'registrationNumber',
            'nameUk', CONVERT(UNHEX('D09DD0BED0BCD0B5D18020D181D0B2D196D0B4D0BED186D182D0B2D0B0') USING utf8mb4),
            'nameEn', 'Registration number',
            'nameRu', CONVERT(UNHEX('D09DD0BED0BCD0B5D18020D181D0B2D0B8D0B4D0B5D182D0B5D0BBD18CD181D182D0B2D0B0') USING utf8mb4),
            'required', TRUE
        ),
        JSON_OBJECT(
            'key', 'vin',
            'nameUk', 'VIN',
            'nameEn', 'VIN',
            'nameRu', 'VIN',
            'required', TRUE
        ),
        JSON_OBJECT(
            'key', 'plateNumber',
            'nameUk', CONVERT(UNHEX('D0A0D0B5D194D181D182D180D0B0D186D196D0B9D0BDD0B8D0B920D0BDD0BED0BCD0B5D180') USING utf8mb4),
            'nameEn', 'Plate number',
            'nameRu', CONVERT(UNHEX('D0A0D0B5D0B3D0B8D181D182D180D0B0D186D0B8D0BED0BDD0BDD18BD0B920D0BDD0BED0BCD0B5D180') USING utf8mb4),
            'required', TRUE
        ),
        JSON_OBJECT(
            'key', 'issuedOn',
            'nameUk', CONVERT(UNHEX('D094D0B0D182D0B020D0B2D0B8D0B4D0B0D187D196') USING utf8mb4),
            'nameEn', 'Issue date',
            'nameRu', CONVERT(UNHEX('D094D0B0D182D0B020D0B2D18BD0B4D0B0D187D0B8') USING utf8mb4),
            'required', FALSE
        )
    ),
    CONVERT(UNHEX('D0BDD0B5D0BCD0B0D194204943414F204D525A') USING utf8mb4),
    FALSE, NULL, CURRENT_TIMESTAMP(6), CURRENT_TIMESTAMP(6)
);
