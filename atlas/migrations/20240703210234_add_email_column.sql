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
