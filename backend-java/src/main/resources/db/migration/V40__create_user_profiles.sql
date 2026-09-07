-- Профіль облікового запису (1:1 з users) і телефони контакту.
-- Таблицю users НЕ змінюємо (немає ALTER).

CREATE TABLE user_profiles (
    user_id CHAR(36) NOT NULL,
    last_name VARCHAR(128) NULL,
    first_name VARCHAR(128) NULL,
    patronymic VARCHAR(128) NULL,
    person_type VARCHAR(32) NULL,
    legal_entity_edrpou VARCHAR(10) NULL,
    contact_via_email TINYINT(1) NOT NULL DEFAULT 0,
    contact_via_phone TINYINT(1) NOT NULL DEFAULT 0,
    contact_via_messengers TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,
    PRIMARY KEY (user_id),
    KEY idx_user_profiles_name (last_name, first_name),
    CONSTRAINT fk_user_profiles_user
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_contact_phones (
    id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    phone VARCHAR(32) NOT NULL,
    sort_order INT NOT NULL,
    is_primary TINYINT(1) NOT NULL,
    has_telegram TINYINT(1) NOT NULL DEFAULT 0,
    has_whatsapp TINYINT(1) NOT NULL DEFAULT 0,
    has_viber TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_user_contact_phones_user_phone (user_id, phone),
    KEY idx_user_contact_phones_user_id (user_id),
    CONSTRAINT fk_user_contact_phones_profile
        FOREIGN KEY (user_id) REFERENCES user_profiles (user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
