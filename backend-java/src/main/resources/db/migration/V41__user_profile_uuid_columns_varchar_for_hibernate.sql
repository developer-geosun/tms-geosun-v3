-- Hibernate при ddl-auto=validate очікує VARCHAR(36) для String id, а V40 створив CHAR(36) — узгоджуємо типи.

SET @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE user_contact_phones
    MODIFY COLUMN id VARCHAR(36) NOT NULL,
    MODIFY COLUMN user_id VARCHAR(36) NOT NULL;

ALTER TABLE user_profiles
    MODIFY COLUMN user_id VARCHAR(36) NOT NULL;

SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
