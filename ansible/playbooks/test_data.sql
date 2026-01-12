-- Test Data for Mail Server
-- Creates sample domain, users, and aliases for testing
--
-- Test Domain: testdomain.local
-- Test Users: testuser1, testuser2, admin
-- Test Alias: alias@testdomain.local → testuser1@testdomain.local

-- Insert test domain
INSERT INTO virtual_domains (name)
VALUES ('testdomain.local')
ON CONFLICT (name) DO NOTHING;

-- Get domain ID
DO $$
DECLARE
    test_domain_id INTEGER;
BEGIN
    SELECT id INTO test_domain_id FROM virtual_domains WHERE name = 'testdomain.local';
    
    -- Insert test users with hashed passwords
    -- Password for testuser1@testdomain.local: TestPass123!
    INSERT INTO virtual_users (domain_id, email, password, quota, enabled)
    VALUES (
        test_domain_id,
        'testuser1@testdomain.local',
        crypt('TestPass123!', gen_salt('bf', 10)),
        1024,  -- 1GB quota
        TRUE
    )
    ON CONFLICT (email) DO UPDATE
    SET password = EXCLUDED.password;
    
    -- Password for testuser2@testdomain.local: TestPass456!
    INSERT INTO virtual_users (domain_id, email, password, quota, enabled)
    VALUES (
        test_domain_id,
        'testuser2@testdomain.local',
        crypt('TestPass456!', gen_salt('bf', 10)),
        2048,  -- 2GB quota
        TRUE
    )
    ON CONFLICT (email) DO UPDATE
    SET password = EXCLUDED.password;
    
    -- Password for admin@testdomain.local: AdminPass789!
    INSERT INTO virtual_users (domain_id, email, password, quota, enabled)
    VALUES (
        test_domain_id,
        'admin@testdomain.local',
        crypt('AdminPass789!', gen_salt('bf', 10)),
        5120,  -- 5GB quota
        TRUE
    )
    ON CONFLICT (email) DO UPDATE
    SET password = EXCLUDED.password;
    
    -- Insert test alias: alias@testdomain.local → testuser1@testdomain.local
    INSERT INTO virtual_aliases (domain_id, source, destination, enabled)
    VALUES (
        test_domain_id,
        'alias@testdomain.local',
        'testuser1@testdomain.local',
        TRUE
    )
    ON CONFLICT (source, enabled) DO UPDATE
    SET destination = EXCLUDED.destination;
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Test Data Inserted';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    RAISE NOTICE 'Test Domain: testdomain.local';
    RAISE NOTICE '';
    RAISE NOTICE 'Test Users:';
    RAISE NOTICE '  testuser1@testdomain.local (password: TestPass123!, quota: 1GB)';
    RAISE NOTICE '  testuser2@testdomain.local (password: TestPass456!, quota: 2GB)';
    RAISE NOTICE '  admin@testdomain.local (password: AdminPass789!, quota: 5GB)';
    RAISE NOTICE '';
    RAISE NOTICE 'Test Alias:';
    RAISE NOTICE '  alias@testdomain.local → testuser1@testdomain.local';
    RAISE NOTICE '';
    RAISE NOTICE 'Verify with:';
    RAISE NOTICE '  SELECT email, quota, enabled FROM virtual_users;';
    RAISE NOTICE '  SELECT source, destination FROM virtual_aliases;';
    RAISE NOTICE '';
    RAISE NOTICE 'Test authentication:';
    RAISE NOTICE '  SELECT verify_password(''testuser1@testdomain.local'', ''TestPass123!'');';
    RAISE NOTICE '========================================';
END $$;
