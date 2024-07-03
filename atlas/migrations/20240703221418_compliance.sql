-- Create "rbac_realms" table
CREATE TABLE "public"."rbac_realms" (
  "id" character varying(36) NOT NULL,
  "description" text NULL,
  "created_by" uuid NULL,
  "created_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_by" uuid NULL,
  "updated_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id")
);
-- Create "set_default_status" function
CREATE FUNCTION "public"."set_default_status" () RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.status IS NULL THEN
    NEW.status := 'INFLIGHT';
  END IF;
  RETURN NEW;
END;
$$;
-- Create "rbac_audit_records" table
CREATE TABLE "public"."rbac_audit_records" (
  "id" character varying(36) NOT NULL,
  "message" text NOT NULL,
  "action" character varying(100) NULL,
  "context" text NULL,
  "created_by" character varying(36) NULL,
  "created_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id")
);
-- Create "rbac_resources" table
CREATE TABLE "public"."rbac_resources" (
  "id" character varying(36) NOT NULL,
  "realm_id" character varying(100) NOT NULL,
  "resource_name" character varying(50) NOT NULL,
  "description" text NULL,
  "allowable_actions" text NULL,
  "created_by" character varying(36) NULL,
  "created_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_by" character varying(36) NULL,
  "updated_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "rbac_resources_realm_fk" FOREIGN KEY ("realm_id") REFERENCES "public"."rbac_realms" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "rbac_resources_type_ndx" to table: "rbac_resources"
CREATE UNIQUE INDEX "rbac_resources_type_ndx" ON "public"."rbac_resources" ("realm_id", "resource_name");
-- Create "rbac_organizations" table
CREATE TABLE "public"."rbac_organizations" (
  "id" character varying(36) NOT NULL,
  "parent_id" character varying(36) NULL,
  "name" character varying(150) NOT NULL,
  "url" character varying(200) NOT NULL,
  "description" text NULL,
  "created_by" character varying(36) NULL,
  "created_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_by" character varying(36) NULL,
  "updated_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "rbac_organizations_parent_fk" FOREIGN KEY ("parent_id") REFERENCES "public"."rbac_organizations" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "rbac_organizations_name_ndx" to table: "rbac_organizations"
CREATE UNIQUE INDEX "rbac_organizations_name_ndx" ON "public"."rbac_organizations" ("name");
-- Create index "rbac_organizations_parent_ndx" to table: "rbac_organizations"
CREATE UNIQUE INDEX "rbac_organizations_parent_ndx" ON "public"."rbac_organizations" ("parent_id");
-- Create "rbac_license_policies" table
CREATE TABLE "public"."rbac_license_policies" (
  "id" character varying(36) NOT NULL,
  "organization_id" character varying(36) NOT NULL,
  "name" character varying(36) NOT NULL,
  "description" text NULL,
  "effective_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "expired_at" timestamp NOT NULL,
  "created_by" character varying(36) NULL,
  "created_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_by" character varying(36) NULL,
  "updated_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "rbac_license_policies_org_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."rbac_organizations" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "rbac_license_policies_name_ndx" to table: "rbac_license_policies"
CREATE INDEX "rbac_license_policies_name_ndx" ON "public"."rbac_license_policies" ("name");
-- Create index "rbac_license_policies_org_ndx" to table: "rbac_license_policies"
CREATE INDEX "rbac_license_policies_org_ndx" ON "public"."rbac_license_policies" ("organization_id");
-- Create "rbac_resource_instances" table
CREATE TABLE "public"."rbac_resource_instances" (
  "id" character varying(36) NOT NULL,
  "resource_id" character varying(36) NOT NULL,
  "license_policy_id" character varying(36) NOT NULL,
  "scope" character varying(100) NOT NULL,
  "ref_id" character varying(100) NOT NULL,
  "status" character varying(50) NOT NULL,
  "description" text NULL,
  "created_by" uuid NULL,
  "created_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_by" uuid NULL,
  "updated_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "rbac_resource_instances_policy_fk" FOREIGN KEY ("license_policy_id") REFERENCES "public"."rbac_license_policies" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "rbac_resource_instances_resource_fk" FOREIGN KEY ("resource_id") REFERENCES "public"."rbac_resources" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "rbac_resource_insts_policy_ndx" to table: "rbac_resource_instances"
CREATE INDEX "rbac_resource_insts_policy_ndx" ON "public"."rbac_resource_instances" ("resource_id", "license_policy_id", "scope");
-- Create index "rbac_resource_insts_ref_ndx" to table: "rbac_resource_instances"
CREATE UNIQUE INDEX "rbac_resource_insts_ref_ndx" ON "public"."rbac_resource_instances" ("resource_id", "license_policy_id", "scope", "ref_id");
-- Create trigger "set_default_status_trigger"
CREATE TRIGGER "set_default_status_trigger" BEFORE INSERT ON "public"."rbac_resource_instances" FOR EACH ROW EXECUTE FUNCTION "public"."set_default_status"();
-- Create "rbac_claims" table
CREATE TABLE "public"."rbac_claims" (
  "id" character varying(36) NOT NULL,
  "realm_id" character varying(100) NOT NULL,
  "resource_id" character varying(36) NOT NULL,
  "action" character varying(100) NOT NULL,
  "effect" character varying(50) NULL DEFAULT 'Allow',
  "description" text NULL,
  "created_by" character varying(36) NULL,
  "created_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_by" character varying(36) NULL,
  "updated_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "rbac_claims_claim_fk" FOREIGN KEY ("realm_id") REFERENCES "public"."rbac_realms" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "rbac_claims_resource_fk" FOREIGN KEY ("resource_id") REFERENCES "public"."rbac_resources" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "rbac_claims_resource_ndx" to table: "rbac_claims"
CREATE UNIQUE INDEX "rbac_claims_resource_ndx" ON "public"."rbac_claims" ("realm_id", "resource_id", "action");
-- Create "rbac_claim_claimables" table
CREATE TABLE "public"."rbac_claim_claimables" (
  "claim_id" character varying(36) NOT NULL,
  "claimable_id" character varying(36) NOT NULL,
  "claimable_type" character varying(100) NOT NULL,
  "scope" character varying(200) NOT NULL,
  "claim_constraints" text NULL,
  "effective_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "expired_at" timestamp NOT NULL,
  "created_by" character varying(36) NULL,
  "created_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_by" character varying(36) NULL,
  "updated_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("claim_id", "claimable_id", "claimable_type"),
  CONSTRAINT "rbac_claim_claimables_claim_fk" FOREIGN KEY ("claim_id") REFERENCES "public"."rbac_claims" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "rbac_claim_claimables_date_ndx" to table: "rbac_claim_claimables"
CREATE INDEX "rbac_claim_claimables_date_ndx" ON "public"."rbac_claim_claimables" ("claim_id", "claimable_id", "claimable_type", "effective_at", "expired_at");
-- Create index "rbac_claim_claimables_ndx" to table: "rbac_claim_claimables"
CREATE INDEX "rbac_claim_claimables_ndx" ON "public"."rbac_claim_claimables" ("claim_id", "claimable_id", "claimable_type");
-- Create "rbac_groups" table
CREATE TABLE "public"."rbac_groups" (
  "id" character varying(36) NOT NULL,
  "parent_id" character varying(36) NULL,
  "organization_id" character varying(36) NOT NULL,
  "name" character varying(150) NOT NULL,
  "description" text NULL,
  "created_by" character varying(36) NULL,
  "created_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_by" character varying(36) NULL,
  "updated_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "rbac_group_org_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."rbac_organizations" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "rbac_group_parent_fk" FOREIGN KEY ("parent_id") REFERENCES "public"."rbac_groups" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "rbac_groups_name_ndx" to table: "rbac_groups"
CREATE UNIQUE INDEX "rbac_groups_name_ndx" ON "public"."rbac_groups" ("name", "organization_id");
-- Create index "rbac_groups_parent_ndx" to table: "rbac_groups"
CREATE INDEX "rbac_groups_parent_ndx" ON "public"."rbac_groups" ("parent_id", "organization_id");
-- Create "rbac_principals" table
CREATE TABLE "public"."rbac_principals" (
  "id" character varying(36) NOT NULL,
  "organization_id" character varying(36) NOT NULL,
  "username" character varying(150) NOT NULL,
  "description" text NULL,
  "created_by" character varying(36) NULL,
  "created_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_by" character varying(36) NULL,
  "updated_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "rbac_principal_org_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."rbac_organizations" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "rbac_principals_name_ndx" to table: "rbac_principals"
CREATE UNIQUE INDEX "rbac_principals_name_ndx" ON "public"."rbac_principals" ("username", "organization_id");
-- Create "rbac_group_principals" table
CREATE TABLE "public"."rbac_group_principals" (
  "group_id" character varying(36) NOT NULL,
  "principal_id" character varying(36) NOT NULL,
  "created_by" character varying(36) NULL,
  "created_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_by" character varying(36) NULL,
  "updated_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("group_id", "principal_id"),
  CONSTRAINT "rbac_group_principals_group_fk" FOREIGN KEY ("group_id") REFERENCES "public"."rbac_groups" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "rbac_group_principals_principal_fk" FOREIGN KEY ("principal_id") REFERENCES "public"."rbac_principals" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "rbac_group_principals_ndx" to table: "rbac_group_principals"
CREATE UNIQUE INDEX "rbac_group_principals_ndx" ON "public"."rbac_group_principals" ("group_id", "principal_id");
-- Create "rbac_resource_quotas" table
CREATE TABLE "public"."rbac_resource_quotas" (
  "id" character varying(36) NOT NULL,
  "resource_id" character varying(36) NOT NULL,
  "license_policy_id" character varying(36) NOT NULL,
  "scope" character varying(100) NOT NULL,
  "max_value" integer NOT NULL DEFAULT 0,
  "effective_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "expired_at" timestamp NOT NULL,
  "created_by" character varying(36) NULL,
  "created_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_by" character varying(36) NULL,
  "updated_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "rbac_resource_instances_policy_fk" FOREIGN KEY ("license_policy_id") REFERENCES "public"."rbac_license_policies" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "rbac_resource_quotas_resources_fk" FOREIGN KEY ("resource_id") REFERENCES "public"."rbac_resources" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "rbac_resources_quotas_date_ndx" to table: "rbac_resource_quotas"
CREATE INDEX "rbac_resources_quotas_date_ndx" ON "public"."rbac_resource_quotas" ("resource_id", "license_policy_id", "scope", "effective_at", "expired_at");
-- Create index "rbac_resources_quotas_ref_ndx" to table: "rbac_resource_quotas"
CREATE UNIQUE INDEX "rbac_resources_quotas_ref_ndx" ON "public"."rbac_resource_quotas" ("resource_id", "scope", "license_policy_id");
-- Create "rbac_roles" table
CREATE TABLE "public"."rbac_roles" (
  "id" character varying(36) NOT NULL,
  "parent_id" character varying(36) NULL,
  "realm_id" character varying(100) NOT NULL,
  "organization_id" character varying(36) NOT NULL,
  "name" character varying(150) NOT NULL,
  "description" text NULL,
  "created_by" character varying(36) NULL,
  "created_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_by" character varying(36) NULL,
  "updated_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "rbac_role_org_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."rbac_organizations" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "rbac_role_parent_fk" FOREIGN KEY ("parent_id") REFERENCES "public"."rbac_roles" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "rbac_role_realm_fk" FOREIGN KEY ("realm_id") REFERENCES "public"."rbac_realms" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "rbac_roles_name_ndx" to table: "rbac_roles"
CREATE UNIQUE INDEX "rbac_roles_name_ndx" ON "public"."rbac_roles" ("name", "realm_id", "organization_id");
-- Create index "rbac_roles_parent_ndx" to table: "rbac_roles"
CREATE INDEX "rbac_roles_parent_ndx" ON "public"."rbac_roles" ("parent_id", "realm_id", "organization_id");
-- Create "rbac_role_roleables" table
CREATE TABLE "public"."rbac_role_roleables" (
  "role_id" character varying(36) NOT NULL,
  "roleable_id" character varying(36) NOT NULL,
  "roleable_type" character varying(50) NOT NULL,
  "role_constraints" text NULL,
  "effective_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "expired_at" timestamp NOT NULL,
  "created_by" character varying(36) NULL,
  "created_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_by" character varying(36) NULL,
  "updated_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("role_id", "roleable_id", "roleable_type"),
  CONSTRAINT "rbac_role_roleables_role_fk" FOREIGN KEY ("role_id") REFERENCES "public"."rbac_roles" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "rbac_role_roleables_ndx" to table: "rbac_role_roleables"
CREATE UNIQUE INDEX "rbac_role_roleables_ndx" ON "public"."rbac_role_roleables" ("role_id", "roleable_id", "roleable_type");
