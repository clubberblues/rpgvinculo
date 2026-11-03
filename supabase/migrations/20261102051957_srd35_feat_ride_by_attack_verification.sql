-- Verify srd35_feat_ride_by_attack against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 1255-1266.'
WHERE id = 'srd35_feat_ride_by_attack';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 1255-1266; Ride-By Attack requires Ride 1 rank and Mounted Combat; mounted charge allows movement before and after attack without provoking from target. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_ride_by_attack';