-- Create the rbac_realms table
CREATE TABLE IF NOT EXISTS rbac_realms (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  description TEXT,
  created_by UUID,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



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

CREATE TABLE IF NOT EXISTS rbac_license_policies (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  organization_id VARCHAR(36) NOT NULL,
  name VARCHAR(36) NOT NULL,
  description TEXT,
  effective_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expired_at TIMESTAMP NOT NULL,
  created_by VARCHAR(36),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_by VARCHAR(36),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT rbac_license_policies_org_fk FOREIGN KEY (organization_id)
        REFERENCES rbac_organizations(id)
);

CREATE INDEX IF NOT EXISTS rbac_license_policies_name_ndx ON rbac_license_policies(name);
CREATE INDEX IF NOT EXISTS rbac_license_policies_org_ndx ON rbac_license_policies(organization_id);
-- create the rbac_groups table
CREATE TABLE IF NOT EXISTS rbac_groups (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  parent_id VARCHAR(36),
  organization_id VARCHAR(36) NOT NULL,
  name VARCHAR(150) NOT NULL,
  description TEXT,
  created_by VARCHAR(36),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_by VARCHAR(36),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT rbac_group_parent_fk FOREIGN KEY (parent_id)
        REFERENCES rbac_groups(id),
  CONSTRAINT rbac_group_org_fk FOREIGN KEY (organization_id)
        REFERENCES rbac_organizations(id)
);

CREATE UNIQUE INDEX IF NOT EXISTS rbac_groups_name_ndx ON rbac_groups(name, organization_id);
CREATE INDEX IF NOT EXISTS rbac_groups_parent_ndx ON rbac_groups(parent_id, organization_id);


-- create rbac_principals table
CREATE TABLE IF NOT EXISTS rbac_principals (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  organization_id VARCHAR(36) NOT NULL,
  username VARCHAR(150) NOT NULL,
  description TEXT,
  created_by VARCHAR(36),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_by VARCHAR(36),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT rbac_principal_org_fk FOREIGN KEY (organization_id)
        REFERENCES rbac_organizations(id)
);

CREATE UNIQUE INDEX IF NOT EXISTS rbac_principals_name_ndx ON rbac_principals(username, organization_id);

CREATE TABLE IF NOT EXISTS rbac_group_principals (
  group_id VARCHAR(36) NOT NULL,
  principal_id VARCHAR(36) NOT NULL,
  created_by VARCHAR(36),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_by VARCHAR(36),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT rbac_group_principals_group_fk FOREIGN KEY (group_id)
        REFERENCES rbac_groups(id),
  CONSTRAINT rbac_group_principals_principal_fk FOREIGN KEY (principal_id)
        REFERENCES rbac_principals(id),
  PRIMARY KEY (group_id, principal_id)
);

CREATE UNIQUE INDEX IF NOT EXISTS rbac_group_principals_ndx ON rbac_group_principals(group_id, principal_id);


--creates rbac_roles table
CREATE TABLE IF NOT EXISTS rbac_roles (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  parent_id VARCHAR(36),
  realm_id VARCHAR(100) NOT NULL,
  organization_id VARCHAR(36) NOT NULL,
  name VARCHAR(150) NOT NULL,
  description TEXT,
  created_by VARCHAR(36),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_by VARCHAR(36),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT rbac_role_parent_fk FOREIGN KEY (parent_id)
        REFERENCES rbac_roles(id),
  CONSTRAINT rbac_role_realm_fk FOREIGN KEY (realm_id)
        REFERENCES rbac_realms(id),
  CONSTRAINT rbac_role_org_fk FOREIGN KEY (organization_id)
        REFERENCES rbac_organizations(id)
);

CREATE UNIQUE INDEX IF NOT EXISTS rbac_roles_name_ndx ON rbac_roles(name, realm_id, organization_id);
CREATE INDEX IF NOT EXISTS rbac_roles_parent_ndx ON rbac_roles(parent_id, realm_id, organization_id);

CREATE TABLE IF NOT EXISTS rbac_role_roleables (
  role_id VARCHAR(36) NOT NULL,
  roleable_id VARCHAR(36) NOT NULL,
  roleable_type VARCHAR(50) NOT NULL,
  role_constraints TEXT,
  effective_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expired_at TIMESTAMP NOT NULL,
  created_by VARCHAR(36),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_by VARCHAR(36),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT rbac_role_roleables_role_fk FOREIGN KEY (role_id)
        REFERENCES rbac_roles(id),
  PRIMARY KEY (role_id, roleable_id, roleable_type)
);

CREATE UNIQUE INDEX IF NOT EXISTS rbac_role_roleables_ndx ON rbac_role_roleables(role_id, roleable_id, roleable_type);


-- CREATE rbac_resources table
CREATE TABLE IF NOT EXISTS rbac_resources (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  realm_id VARCHAR(100) NOT NULL,
  resource_name VARCHAR(50) NOT NULL,
  description TEXT,
  allowable_actions TEXT,
  created_by VARCHAR(36),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_by VARCHAR(36),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT rbac_resources_realm_fk FOREIGN KEY (realm_id)
        REFERENCES rbac_realms(id)
);

CREATE UNIQUE INDEX IF NOT EXISTS rbac_resources_type_ndx ON rbac_resources(realm_id, resource_name);

CREATE TABLE IF NOT EXISTS rbac_resource_instances (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  resource_id VARCHAR(36) NOT NULL,
  license_policy_id VARCHAR(36) NOT NULL,
  scope VARCHAR(100) NOT NULL,
  ref_id VARCHAR(100) NOT NULL,
  status VARCHAR(50) NOT NULL,
  description TEXT,
  created_by UUID,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT rbac_resource_instances_policy_fk FOREIGN KEY (license_policy_id)
        REFERENCES rbac_license_policies(id),
  CONSTRAINT rbac_resource_instances_resource_fk FOREIGN KEY (resource_id)
        REFERENCES rbac_resources(id)
);

-- Create a trigger function to set the default value for the status column
CREATE OR REPLACE FUNCTION set_default_status()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status IS NULL THEN
    NEW.status := 'INFLIGHT';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger that calls the trigger function before insert
CREATE TRIGGER set_default_status_trigger
BEFORE INSERT ON rbac_resource_instances
FOR EACH ROW
EXECUTE FUNCTION set_default_status();

 

CREATE INDEX IF NOT EXISTS rbac_resource_insts_policy_ndx ON rbac_resource_instances(resource_id, license_policy_id, scope);
CREATE UNIQUE INDEX IF NOT EXISTS rbac_resource_insts_ref_ndx ON rbac_resource_instances(resource_id, license_policy_id, scope, ref_id);

CREATE TABLE IF NOT EXISTS rbac_resource_quotas (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  resource_id VARCHAR(36) NOT NULL,
  license_policy_id VARCHAR(36) NOT NULL,
  scope VARCHAR(100) NOT NULL,
  max_value INTEGER NOT NULL DEFAULT 0,
  effective_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expired_at TIMESTAMP NOT NULL,
  created_by VARCHAR(36),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_by VARCHAR(36),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT rbac_resource_instances_policy_fk FOREIGN KEY (license_policy_id)
        REFERENCES rbac_license_policies(id),
  CONSTRAINT rbac_resource_quotas_resources_fk FOREIGN KEY (resource_id)
        REFERENCES rbac_resources(id)
);

CREATE UNIQUE INDEX IF NOT EXISTS rbac_resources_quotas_ref_ndx ON rbac_resource_quotas(resource_id, scope, license_policy_id);
CREATE INDEX IF NOT EXISTS rbac_resources_quotas_date_ndx ON rbac_resource_quotas(resource_id, license_policy_id, scope, effective_at, expired_at);


-- create rbac_claims table
CREATE TABLE IF NOT EXISTS rbac_claims (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  realm_id VARCHAR(100) NOT NULL,
  resource_id VARCHAR(36) NOT NULL,
  action VARCHAR(100) NOT NULL,
  effect VARCHAR(50) DEFAULT 'Allow',
  description TEXT,
  created_by VARCHAR(36),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_by VARCHAR(36),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT rbac_claims_claim_fk FOREIGN KEY (realm_id)
        REFERENCES rbac_realms(id),
  CONSTRAINT rbac_claims_resource_fk FOREIGN KEY (resource_id)
        REFERENCES rbac_resources(id)
);

CREATE UNIQUE INDEX IF NOT EXISTS rbac_claims_resource_ndx ON rbac_claims(realm_id, resource_id, action);

CREATE TABLE IF NOT EXISTS rbac_claim_claimables(
  claim_id VARCHAR(36) NOT NULL,
  claimable_id VARCHAR(36) NOT NULL,
  claimable_type VARCHAR(100) NOT NULL,
  scope VARCHAR(200) NOT NULL,
  claim_constraints TEXT,
  effective_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expired_at TIMESTAMP NOT NULL,
  created_by VARCHAR(36),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_by VARCHAR(36),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT rbac_claim_claimables_claim_fk FOREIGN KEY (claim_id)
        REFERENCES rbac_claims(id),
  PRIMARY KEY (claim_id, claimable_id, claimable_type)
);

CREATE INDEX IF NOT EXISTS rbac_claim_claimables_ndx ON rbac_claim_claimables(claim_id, claimable_id, claimable_type);
CREATE INDEX IF NOT EXISTS rbac_claim_claimables_date_ndx ON rbac_claim_claimables(claim_id, claimable_id, claimable_type, effective_at, expired_at);

-- create audit tables
CREATE TABLE IF NOT EXISTS rbac_audit_records (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  message TEXT NOT NULL,
  action VARCHAR(100),
  context TEXT,
  created_by VARCHAR(36),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- create licences table

CREATE TABLE IF NOT EXISTS rbac_audit_records (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  message TEXT NOT NULL,
  action VARCHAR(100),
  context TEXT,
  created_by VARCHAR(36),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);