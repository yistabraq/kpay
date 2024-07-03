-- Create "rbac_realms" table
CREATE TABLE "public"."rbac_realms" (
  "id" character varying(100) NOT NULL,
  "description" text NULL,
  "created_by" uuid NULL,
  "created_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_by" uuid NULL,
  "updated_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id")
);
