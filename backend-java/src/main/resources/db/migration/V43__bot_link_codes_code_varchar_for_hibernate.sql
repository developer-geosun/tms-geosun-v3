-- Hibernate validate: String length=8 → VARCHAR, не CHAR.
ALTER TABLE bot_link_codes
    MODIFY COLUMN code VARCHAR(8) NOT NULL;
