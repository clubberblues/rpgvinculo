-- Remove legacy endpoints that generated dice results on the server.
-- Active mesa flows use the physical Dice iframe and submit the player's/manual GM results.
REVOKE EXECUTE ON FUNCTION public.iniciar_iniciativa(bigint,text[]) FROM PUBLIC,anon,authenticated;
REVOKE EXECUTE ON FUNCTION public.attack(bigint,bigint,text) FROM PUBLIC,anon,authenticated;
REVOKE EXECUTE ON FUNCTION public.roll_death_save(bigint) FROM PUBLIC,anon,authenticated;
