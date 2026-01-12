-- Mail Server Database Schema
-- PostgreSQL 17
-- Purpose: Virtual mail server authentication and routing
--
-- This schema supports:
-- - Virtual domains (multiple domains on one server)
-- - Virtual users (email accounts)
-- - Virtual aliases (email forwarding)
--
-- Password hashing: SHA512-CRYPT (Dovecot/Postfix compatible)

-- Enable pgcrypto extension for password hashing
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Virtual Domains Table
-- Stores all mail domains handled by this server
CREATE TABLE IF NOT EXISTS virtual_domains (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Indexes
    CONSTRAINT virtual_domains_name_check CHECK (name ~ '^[a-z0-9.-]+$')
);

CREATE INDEX IF NOT EXISTS idx_virtual_domains_name ON virtual_domains(name);

COMMENT ON TABLE virtual_domains IS 'Mail domains handled by this server';
COMMENT ON COLUMN virtual_domains.name IS 'Domain name (e.g., example.com)';

-- Virtual Users Table
-- Stores email accounts with passwords and quotas
CREATE TABLE IF NOT EXISTS virtual_users (
    id SERIAL PRIMARY KEY,
    domain_id INTEGER NOT NULL REFERENCES virtual_domains(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    quota INTEGER DEFAULT 1024,  -- Quota in MB (default 1GB)
    enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT virtual_users_email_check CHECK (email ~ '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
    CONSTRAINT virtual_users_quota_check CHECK (quota > 0)
);

CREATE INDEX IF NOT EXISTS idx_virtual_users_email ON virtual_users(email);
CREATE INDEX IF NOT EXISTS idx_virtual_users_domain_id ON virtual_users(domain_id);
CREATE INDEX IF NOT EXISTS idx_virtual_users_enabled ON virtual_users(enabled);

COMMENT ON TABLE virtual_users IS 'Email user accounts with authentication';
COMMENT ON COLUMN virtual_users.email IS 'Full email address (user@domain.com)';
COMMENT ON COLUMN virtual_users.password IS 'SHA512-CRYPT hashed password';
COMMENT ON COLUMN virtual_users.quota IS 'Mailbox quota in megabytes';
COMMENT ON COLUMN virtual_users.enabled IS 'Account enabled/disabled flag';

-- Virtual Aliases Table
-- Stores email forwarding rules
CREATE TABLE IF NOT EXISTS virtual_aliases (
    id SERIAL PRIMARY KEY,
    domain_id INTEGER NOT NULL REFERENCES virtual_domains(id) ON DELETE CASCADE,
    source VARCHAR(255) NOT NULL,
    destination VARCHAR(255) NOT NULL,
    enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT virtual_aliases_source_check CHECK (source ~ '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
    CONSTRAINT virtual_aliases_destination_check CHECK (destination ~ '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
    CONSTRAINT virtual_aliases_unique_source UNIQUE(source, enabled)
);

CREATE INDEX IF NOT EXISTS idx_virtual_aliases_source ON virtual_aliases(source);
CREATE INDEX IF NOT EXISTS idx_virtual_aliases_destination ON virtual_aliases(destination);
CREATE INDEX IF NOT EXISTS idx_virtual_aliases_domain_id ON virtual_aliases(domain_id);
CREATE INDEX IF NOT EXISTS idx_virtual_aliases_enabled ON virtual_aliases(enabled);

COMMENT ON TABLE virtual_aliases IS 'Email forwarding and alias rules';
COMMENT ON COLUMN virtual_aliases.source IS 'Original email address (alias)';
COMMENT ON COLUMN virtual_aliases.destination IS 'Target email address (where to forward)';
COMMENT ON COLUMN virtual_aliases.enabled IS 'Alias enabled/disabled flag';

-- Function: Verify password
-- Used by Dovecot for authentication
CREATE OR REPLACE FUNCTION verify_password(check_email VARCHAR, check_password VARCHAR)
RETURNS BOOLEAN AS $$
DECLARE
    stored_password VARCHAR;
    is_valid BOOLEAN;
BEGIN
    -- Get stored password hash
    SELECT password INTO stored_password
    FROM virtual_users
    WHERE email = check_email AND enabled = TRUE;
    
    -- If user not found or disabled
    IF stored_password IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Verify password using crypt
    is_valid := (stored_password = crypt(check_password, stored_password));
    
    RETURN is_valid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION verify_password IS 'Verify user password for authentication';

-- Function: Update timestamp on row modification
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Auto-update updated_at on virtual_users
CREATE TRIGGER update_virtual_users_updated_at
    BEFORE UPDATE ON virtual_users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- View: User mailbox info (for Dovecot)
CREATE OR REPLACE VIEW user_mailbox_info AS
SELECT 
    vu.email,
    vu.password,
    vu.quota,
    vd.name as domain,
    CONCAT('/var/mail/vmail/', vd.name, '/', SPLIT_PART(vu.email, '@', 1), '/') as maildir_path
FROM virtual_users vu
JOIN virtual_domains vd ON vu.domain_id = vd.id
WHERE vu.enabled = TRUE;

COMMENT ON VIEW user_mailbox_info IS 'Combined user and mailbox information for Dovecot';

-- Grant usage on sequences (needed for service users)
GRANT USAGE ON SEQUENCE virtual_domains_id_seq TO PUBLIC;
GRANT USAGE ON SEQUENCE virtual_users_id_seq TO PUBLIC;
GRANT USAGE ON SEQUENCE virtual_aliases_id_seq TO PUBLIC;

-- Display schema summary
DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Mail Server Database Schema Created';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    RAISE NOTICE 'Tables created:';
    RAISE NOTICE '  - virtual_domains (mail domains)';
    RAISE NOTICE '  - virtual_users (email accounts)';
    RAISE NOTICE '  - virtual_aliases (email forwarding)';
    RAISE NOTICE '';
    RAISE NOTICE 'Functions created:';
    RAISE NOTICE '  - verify_password() (authentication helper)';
    RAISE NOTICE '';
    RAISE NOTICE 'Views created:';
    RAISE NOTICE '  - user_mailbox_info (Dovecot mailbox info)';
    RAISE NOTICE '';
    RAISE NOTICE 'Next step: Create service users and set permissions';
    RAISE NOTICE '========================================';
END $$;
