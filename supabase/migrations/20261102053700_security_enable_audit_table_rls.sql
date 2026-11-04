-- Protect audit metadata tables with the same public-read contract as SRD catalogs.
ALTER TABLE public.srd_catalog_entry_audit ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.srd_equipment_audit ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS srd_catalog_entry_audit_read ON public.srd_catalog_entry_audit;
CREATE POLICY srd_catalog_entry_audit_read
  ON public.srd_catalog_entry_audit
  FOR SELECT TO anon, authenticated
  USING (true);

DROP POLICY IF EXISTS srd_equipment_audit_read ON public.srd_equipment_audit;
CREATE POLICY srd_equipment_audit_read
  ON public.srd_equipment_audit
  FOR SELECT TO anon, authenticated
  USING (true);