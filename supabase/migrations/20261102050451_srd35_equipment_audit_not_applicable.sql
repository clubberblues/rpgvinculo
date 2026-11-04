BEGIN;
ALTER TABLE public.srd_equipment_audit DROP CONSTRAINT IF EXISTS srd_equipment_audit_audit_status_check;
ALTER TABLE public.srd_equipment_audit ADD CONSTRAINT srd_equipment_audit_audit_status_check CHECK (audit_status IN ('ready_for_manual_review','needs_data_fix','manual_verified','not_applicable_or_unspecified'));
UPDATE public.srd_equipment_audit SET audit_status='not_applicable_or_unspecified',audit_notes='O SRD não informa ou não se aplica a este campo; valor não foi inventado. Fonte e demais metadados permanecem para revisão manual.' WHERE audit_status='ready_for_manual_review' AND (audit_notes LIKE '%Preço/peso ausentes%' OR audit_notes LIKE '%Peso não informado%' OR audit_notes LIKE '%Preço não informado%');
COMMIT;