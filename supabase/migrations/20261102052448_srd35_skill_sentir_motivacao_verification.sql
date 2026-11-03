UPDATE public.srd_skills
SET source_status='verified_srd',
    srd_source_url='https://www.d20srd.org/srd/skills/senseMotive.htm',
    source_notes='Conferência individual concluída no d20 SRD Skills, linhas 37-84.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_lines','37-84',
      'verified_srd_name','Sense Motive',
      'verification_summary','Sentir Motivação segue Sense Motive do SRD, incluindo hunch, encantamento e mensagens secretas.',
      'engine_status','needs_implementation'
    )
WHERE id='sentir_motivacao';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Conferido no d20 SRD Skills, linhas 37-84; Sentir Motivação segue Sense Motive do SRD, incluindo hunch, encantamento e mensagens secretas. Implementação do motor ainda pendente.'
WHERE catalog_key='skills' AND entry_id='sentir_motivacao';