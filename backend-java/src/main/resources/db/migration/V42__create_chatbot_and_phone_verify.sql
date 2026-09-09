-- Чат-бот: прив'язка Telegram + верифікація телефону (v1).
-- UUID одразу VARCHAR(36) для Hibernate validate.

ALTER TABLE user_contact_phones
    ADD COLUMN phone_verified TINYINT(1) NOT NULL DEFAULT 0 AFTER has_viber,
    ADD COLUMN phone_verified_at DATETIME(6) NULL AFTER phone_verified,
    ADD COLUMN phone_verified_via VARCHAR(16) NULL AFTER phone_verified_at;

CREATE TABLE bot_link_codes (
    id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    channel VARCHAR(16) NOT NULL,
    code CHAR(8) NOT NULL,
    expires_at DATETIME(6) NOT NULL,
    consumed_at DATETIME(6) NULL,
    created_at DATETIME(6) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_bot_link_codes_code (code),
    KEY idx_bot_link_codes_user_channel (user_id, channel, created_at),
    CONSTRAINT fk_bot_link_codes_user
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE bot_identities (
    id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    channel VARCHAR(16) NOT NULL,
    external_user_id VARCHAR(128) NOT NULL,
    locale VARCHAR(8) NOT NULL DEFAULT 'ua',
    status VARCHAR(16) NOT NULL,
    linked_at DATETIME(6) NULL,
    revoked_at DATETIME(6) NULL,
    updated_at DATETIME(6) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_bot_identities_user_channel (user_id, channel),
    UNIQUE KEY uk_bot_identities_channel_external (channel, external_user_id),
    KEY idx_bot_identities_status (status),
    CONSTRAINT fk_bot_identities_user
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE bot_message_log (
    id VARCHAR(36) NOT NULL,
    direction VARCHAR(8) NOT NULL,
    channel VARCHAR(16) NOT NULL,
    identity_id VARCHAR(36) NULL,
    user_id VARCHAR(36) NULL,
    event_type VARCHAR(64) NOT NULL,
    idempotency_key VARCHAR(190) NULL,
    status VARCHAR(16) NOT NULL,
    payload_preview VARCHAR(512) NULL,
    provider_error VARCHAR(256) NULL,
    attempt_count INT NOT NULL DEFAULT 0,
    created_at DATETIME(6) NOT NULL,
    sent_at DATETIME(6) NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_bot_message_log_idempotency (idempotency_key),
    KEY idx_bot_message_log_created (created_at),
    KEY idx_bot_message_log_channel_status (channel, status),
    CONSTRAINT fk_bot_message_log_identity
        FOREIGN KEY (identity_id) REFERENCES bot_identities (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
