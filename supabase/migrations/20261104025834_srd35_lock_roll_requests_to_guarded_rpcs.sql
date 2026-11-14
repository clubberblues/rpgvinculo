
-- Roll requests are created and answered by guarded SECURITY DEFINER RPCs.
-- Do not allow clients to rewrite request ownership, dice, or results directly.
REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
ON TABLE public.roll_requests
FROM PUBLIC, anon, authenticated;

GRANT SELECT ON TABLE public.roll_requests TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.roll_requests TO service_role;
