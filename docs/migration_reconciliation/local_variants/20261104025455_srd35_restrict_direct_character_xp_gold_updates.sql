-- XP and gold are game resources. Players create characters with their
-- initial values, but subsequent changes must go through guarded game RPCs.
-- The current ficha.html only updates portrait/layout fields directly;
-- XP is granted through conceder_xp_personagem_srd and item/gold operations
-- are handled by SECURITY DEFINER inventory RPCs.
REVOKE UPDATE (xp, ouro)
ON TABLE public.characters
FROM authenticated;
