-- Verify srd35_feat_brew_potion against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 288-298.'
WHERE id = 'srd35_feat_brew_potion';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 288-298; Brew Potion requires caster level 3; creates potions of known spells up to 3rd level targeting creatures, with one-day crafting and cost rules. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_brew_potion';