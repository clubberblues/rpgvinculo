CREATE INDEX IF NOT EXISTS srd_pending_spell_resolution_condition_break_idx
  ON priv.srd_pending_spell_resolutions(condition_break_instance_id)
  WHERE condition_break_instance_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS srd_pending_spell_resolution_condition_idx
  ON priv.srd_pending_spell_resolutions(condition_id)
  WHERE condition_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS srd_pending_spell_resolution_spell_idx
  ON priv.srd_pending_spell_resolutions(spell_id);