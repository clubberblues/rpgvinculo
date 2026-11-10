-- This passive catalog helper is only used by SECURITY DEFINER engine code.
-- Remove its inherited PUBLIC/anon EXECUTE without changing authenticated callers.
BEGIN;
REVOKE EXECUTE ON FUNCTION priv.srd_feat_saving_throw_modifier(jsonb,text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION priv.srd_feat_saving_throw_modifier(jsonb,text) TO authenticated, service_role;
COMMIT;
