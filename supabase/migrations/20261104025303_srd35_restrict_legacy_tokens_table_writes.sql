
REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
ON TABLE public.tokens
FROM PUBLIC, anon, authenticated;

GRANT SELECT ON TABLE public.tokens TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.tokens TO service_role;
