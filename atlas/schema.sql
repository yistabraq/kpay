-- Create the rbac_realms table
CREATE TABLE IF NOT EXISTS rbac_realms (
  id VARCHAR(100) NOT NULL PRIMARY KEY,
  description TEXT,
  created_by UUID,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert a row into the rbac_realms table
INSERT INTO rbac_realms (id, description, created_by, created_at, updated_by, updated_at)
VALUES ('default', 'Default Realm', '00000000-0000-0000-0000-000000000000', CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000000', CURRENT_TIMESTAMP);
