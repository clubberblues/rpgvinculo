-- The current VTT stores scene tokens in campaigns.cba_data and uses
-- guarded SECURITY DEFINER RPCs. The legacy public.tokens table is not
-- written directly by the current mesa/lobby/ficha/dice frontends.
-- Remove broad direct REST writes while preserving reads and service access.
REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
ON TABLE public.tokens
FROM PUBLIC, anon, authenticated;

GRANT SELECT ON TABLE public.tokens TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.tokens TO service_role;
