-- Census PostgreSQL 16 privilege audit; execute as a read-capable audit role.
-- psql -v ON_ERROR_STOP=1 -f database/security/verify.sql
DO $audit$
DECLARE runtime_name text;
DECLARE rel record;
BEGIN
 FOR runtime_name IN SELECT unnest(ARRAY['census_api_runtime','census_worker_runtime']) LOOP
  IF has_schema_privilege(runtime_name,'census_private','USAGE')
     OR has_schema_privilege(runtime_name,'census_private','CREATE')
     OR has_schema_privilege(runtime_name,'census_api','CREATE')
     OR has_schema_privilege(runtime_name,'public','CREATE')
  THEN RAISE EXCEPTION 'Unsafe schema access: %',runtime_name; END IF;
  FOR rel IN SELECT c.oid FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
             WHERE n.nspname='census_private' AND c.relkind IN ('r','p','v','m','f')
  LOOP
   IF has_table_privilege(runtime_name,rel.oid,'SELECT')
      OR has_table_privilege(runtime_name,rel.oid,'INSERT')
      OR has_table_privilege(runtime_name,rel.oid,'UPDATE')
      OR has_table_privilege(runtime_name,rel.oid,'DELETE')
      OR has_table_privilege(runtime_name,rel.oid,'TRUNCATE')
   THEN RAISE EXCEPTION 'Direct private table access: %',runtime_name; END IF;
  END LOOP;
 END LOOP;
END $audit$;
-- This audit is a partial baseline, NOT production privilege certification.
-- Add effective routine allowlist, PUBLIC grants, default ACL, role inheritance,
-- RLS and SECURITY DEFINER search_path checks before enabling production access.
