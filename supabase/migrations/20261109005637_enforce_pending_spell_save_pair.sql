ALTER TABLE priv.srd_pending_spell_resolutions
  ADD CONSTRAINT srd_pending_spell_save_pair_check
  CHECK ((save_type IS NULL) = (save_dc IS NULL));