-- Census PostgreSQL 16 privilege baseline. Run as controlled migration administrator.
-- SECURITY BOUNDARY: no runtime access to private tables. Does not implement
-- authenticated per-principal tenant context or production-ready stored functions.
BEGIN;
DO $$
BEGIN
 IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='census_owner') THEN CREATE ROLE census_owner NOLOGIN NOINHERIT; END IF;
 IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='census_api_runtime') THEN CREATE ROLE census_api_runtime LOGIN NOINHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOBYPASSRLS; END IF;
 IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='census_worker_runtime') THEN CREATE ROLE census_worker_runtime LOGIN NOINHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOBYPASSRLS; END IF;
END $$;
-- Credentials must be set out-of-band; never embed passwords in SQL or Git.
CREATE SCHEMA IF NOT EXISTS census_private AUTHORIZATION census_owner;
CREATE SCHEMA IF NOT EXISTS census_api AUTHORIZATION census_owner;
CREATE SCHEMA IF NOT EXISTS census_security AUTHORIZATION census_owner;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA census_private, census_api, census_security FROM PUBLIC;
REVOKE ALL ON SCHEMA census_private, census_api, census_security FROM census_api_runtime, census_worker_runtime;
GRANT USAGE ON SCHEMA census_api TO census_api_runtime, census_worker_runtime;
REVOKE ALL ON ALL TABLES IN SCHEMA census_private FROM PUBLIC, census_api_runtime, census_worker_runtime;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA census_private FROM PUBLIC, census_api_runtime, census_worker_runtime;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA census_api, census_private, census_security FROM PUBLIC, census_api_runtime, census_worker_runtime;
REVOKE ALL ON ALL PROCEDURES IN SCHEMA census_api, census_private, census_security FROM PUBLIC, census_api_runtime, census_worker_runtime;
-- PostgreSQL grants EXECUTE on new functions to PUBLIC by default.\n-- Revoke this globally for objects created by census_owner; a per-schema\n-- REVOKE alone does not cancel a global default grant.\nALTER DEFAULT PRIVILEGES FOR ROLE census_owner REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;\n-- Defaults apply to objects subsequently created by census_owner.
ALTER DEFAULT PRIVILEGES FOR ROLE census_owner IN SCHEMA census_private
 REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE census_owner IN SCHEMA census_private
 REVOKE ALL ON SEQUENCES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE census_owner IN SCHEMA census_private
 REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE census_owner IN SCHEMA census_api
 REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE census_owner IN SCHEMA census_security
 REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
-- No blanket grants. Future routines require explicit GRANT EXECUTE on exact signatures.
COMMIT;
