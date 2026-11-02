BEGIN;
UPDATE public.srd_equipment_audit
SET audit_status='ready_for_manual_review',
    audit_notes=CASE
      WHEN audit_notes LIKE '%peso ausente%' AND audit_notes LIKE '%preço ausente%' THEN 'Preço/peso ausentes ou não aplicáveis na tabela SRD; requer conferência manual da entrada original.'
      WHEN audit_notes LIKE '%peso ausente%' THEN 'Peso não informado ou não aplicável na tabela SRD; requer conferência manual da entrada original.'
      WHEN audit_notes LIKE '%preço ausente%' THEN 'Preço não informado ou não aplicável na tabela SRD; requer conferência manual da entrada original.'
      ELSE audit_notes
    END
WHERE audit_status='needs_data_fix';
COMMIT;