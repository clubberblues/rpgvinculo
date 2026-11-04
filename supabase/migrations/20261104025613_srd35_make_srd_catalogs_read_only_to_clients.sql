-- SRD and audit catalogs are read-only in the client application.
-- No current ficha/mesa/lobby/dice page writes these tables directly.
-- Keep anonymous/authenticated reads and preserve service-role maintenance.
REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
ON TABLE
  public.monsters,
  public.srd_catalog_entry_audit,
  public.srd_equipment_audit,
  public.srd_feats,
  public.srd_classes,
  public.srd_equipment,
  public.srd_monsters,
  public.srd_npc_archetypes,
  public.srd_spells
FROM PUBLIC, anon, authenticated;

GRANT SELECT ON TABLE
  public.monsters,
  public.srd_catalog_entry_audit,
  public.srd_equipment_audit,
  public.srd_feats,
  public.srd_classes,
  public.srd_equipment,
  public.srd_monsters,
  public.srd_npc_archetypes,
  public.srd_spells
TO anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE
  public.monsters,
  public.srd_catalog_entry_audit,
  public.srd_equipment_audit,
  public.srd_feats,
  public.srd_classes,
  public.srd_equipment,
  public.srd_monsters,
  public.srd_npc_archetypes,
  public.srd_spells
TO service_role;
