-- Private game-state tables are accessible only to authenticated users.
-- RLS remains the row-level authorization layer for signed-in users.
-- Revoke the broad legacy anon grants as defense in depth.
REVOKE ALL PRIVILEGES ON TABLE
  public.campaign_log,
  public.character_talents,
  public.combat_state,
  public.monster_instances,
  public.scenes,
  public.srd_cba_token_equipment,
  public.srd_character_equipment,
  public.srd_character_sheets,
  public.srd_starting_packages,
  public.tokens,
  public.vinculo_character_notes
FROM anon;
