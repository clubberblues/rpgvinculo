UPDATE public.srd_skills
SET source_status='verified_srd',
    srd_source_url='https://www.d20srd.org/srd/skills/intimidate.htm',
    source_notes='Conferência individual concluída no d20 SRD Skills, linhas 37-44.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_lines','37-44',
      'verified_srd_name','Intimidate',
      'verification_summary','Intimidação segue Intimidate do SRD, incluindo mudança de comportamento e desmoralização.',
      'engine_status','needs_implementation'
    )
WHERE id='intimidacao';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Conferido no d20 SRD Skills, linhas 37-44; Intimidação segue Intimidate do SRD, incluindo mudança de comportamento e desmoralização. Implementação do motor ainda pendente.'
WHERE catalog_key='skills' AND entry_id='intimidacao';