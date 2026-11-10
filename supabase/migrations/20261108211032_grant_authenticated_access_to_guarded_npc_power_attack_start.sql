
GRANT EXECUTE ON FUNCTION priv.npc_iniciar_ataque_iterativo_impl(bigint,text,text,text,uuid,text,text,integer) TO authenticated;
REVOKE ALL ON FUNCTION priv.npc_iniciar_ataque_iterativo_impl(bigint,text,text,text,uuid,text,text,integer) FROM PUBLIC,anon;
