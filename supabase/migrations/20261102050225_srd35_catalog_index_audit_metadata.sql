BEGIN;
UPDATE public.srd_monsters SET dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object('official_catalog_index','https://www.d20srd.org/srd/monsters/','audit_status','source_attached') WHERE COALESCE(source_status,'')<>'excluded';
UPDATE public.srd_skills SET dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object('official_catalog_index','https://www.d20srd.org/srd/skills/skillsSummary.htm','audit_status','source_attached') WHERE COALESCE(source_status,'')<>'excluded';
UPDATE public.srd_spells SET dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object('official_catalog_index','https://www.d20srd.org/srd/spells/','audit_status','source_attached') WHERE COALESCE(source_status,'')<>'excluded';
UPDATE public.srd_feats SET requisitos=COALESCE(requisitos,'{}'::jsonb)||jsonb_build_object('official_catalog_index','https://www.d20srd.org/srd/feats.htm','audit_status','source_attached') WHERE COALESCE(source_status,'')<>'excluded';
COMMIT;