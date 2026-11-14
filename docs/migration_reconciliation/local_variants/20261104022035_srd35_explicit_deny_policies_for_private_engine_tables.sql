ALTER TABLE priv.srd_condition_engine_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE priv.srd_pending_spell_resolutions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS srd_condition_engine_rules_deny_all ON priv.srd_condition_engine_rules;
CREATE POLICY srd_condition_engine_rules_deny_all
ON priv.srd_condition_engine_rules
FOR ALL TO public
USING (false)
WITH CHECK (false);

DROP POLICY IF EXISTS srd_pending_spell_resolutions_deny_all ON priv.srd_pending_spell_resolutions;
CREATE POLICY srd_pending_spell_resolutions_deny_all
ON priv.srd_pending_spell_resolutions
FOR ALL TO public
USING (false)
WITH CHECK (false);

REVOKE ALL ON TABLE priv.srd_condition_engine_rules FROM PUBLIC, anon, authenticated;
REVOKE ALL ON TABLE priv.srd_pending_spell_resolutions FROM PUBLIC, anon, authenticated;
