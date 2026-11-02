-- Daily spell reset is available only through the owner/campaign/time guarded
-- long-rest RPC; the security-definer rest function calls it internally.
REVOKE ALL ON FUNCTION public.repor_magias_srd(TEXT) FROM PUBLIC,anon,authenticated;
NOTIFY pgrst,'reload schema';