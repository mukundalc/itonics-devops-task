-- Run this script as pgadmin
-- It creates the user that will own the new database

CREATE ROLE itonics_admin
 NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
COMMENT ON ROLE itonics_admin IS 'The role used by the CI/CD pipeline to deploy changes to the database';

CREATE USER itonics_owner LOGIN PASSWORD -- <= add a password here!
 NOSUPERUSER INHERIT CREATEDB CREATEROLE NOREPLICATION;

GRANT itonics_admin TO itonics_owner;
COMMENT ON ROLE itonics_owner IS 'Role used to deploy itonics schema changes';