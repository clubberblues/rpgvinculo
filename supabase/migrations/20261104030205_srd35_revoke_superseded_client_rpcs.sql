
-- Current clients use the v2/v3 SRD and CBA endpoints. Revoke direct client
-- access to superseded RPCs; SECURITY DEFINER owners can still call them
-- internally where compatibility code requires it.
REVOKE EXECUTE ON FUNCTION public.add_monster_to_scene(bigint,text,integer,integer)
FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.adicionar_token_cba(bigint,jsonb)
FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.combat_set_turn(bigint)
FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.concluir_avanco_nivel_personagem_srd(bigint,text,integer,jsonb,jsonb,text)
FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.conjurar_magia_com_acao_srd_multialvo(text,text,smallint,text[])
FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.conjurar_magia_srd_manual(text,text,smallint,text,integer[])
FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.conjurar_magia_srd_multialvo_v3(text,text,smallint,text[],integer[])
FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.criar_personagem_srd(text,text,text,jsonb)
FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.end_combat(bigint)
FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.lobby_list()
FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.scene_config(bigint,text,integer,integer)
FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.send_chat(bigint,text,text)
FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.start_combat(bigint)
FROM PUBLIC, anon, authenticated;
