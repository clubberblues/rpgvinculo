-- Preserve the explicit authenticated/service_role grants while removing
-- inherited PUBLIC/anon EXECUTE from this passive catalog helper.
BEGIN;
REVOKE EXECUTE ON FUNCTION priv.srd_feat_saving_throw_modifier(jsonb,text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION priv.srd_feat_saving_throw_modifier(jsonb,text) TO authenticated, service_role;
COMMIT;
