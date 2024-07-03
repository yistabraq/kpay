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


CREATE TABLE IF NOT EXISTS rbac_organizations (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  parent_id VARCHAR(36),
  name VARCHAR(150) NOT NULL,
  url VARCHAR(200) NOT NULL,
  description TEXT,
  created_by VARCHAR(36),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_by VARCHAR(36),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT rbac_organizations_parent_fk FOREIGN KEY (parent_id)
        REFERENCES rbac_organizations(id)
);

CREATE UNIQUE INDEX IF NOT EXISTS rbac_organizations_name_ndx ON rbac_organizations(name);
CREATE UNIQUE INDEX IF NOT EXISTS rbac_organizations_parent_ndx ON rbac_organizations(parent_id);
INSERT INTO rbac_organizations VALUES('00000000-0000-0000-0000-000000000000', NULL, 'default', 'http://default', 'Default', '00000000-0000-0000-0000-000000000000', CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000000', CURRENT_TIMESTAMP);
