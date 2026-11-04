-- The active VTT uses local manual dice and campaign_log test requests.
-- No current mesa/dice/ficha/lobby page calls these legacy roll_requests RPCs.
REVOKE EXECUTE ON FUNCTION public.ask_roll(bigint,uuid,text,text,text,integer,text)
FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.answer_roll(bigint,integer)
FROM PUBLIC, anon, authenticated;
