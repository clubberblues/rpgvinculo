-- Manual Dice endpoints must not be executable by anonymous clients.
REVOKE EXECUTE ON FUNCTION public.conjurar_magia_srd_manual(text,text,smallint,text,integer[]) FROM PUBLIC,anon;
REVOKE EXECUTE ON FUNCTION public.conjurar_magia_com_acao_srd_manual(text,text,smallint,text,integer[]) FROM PUBLIC,anon;
REVOKE EXECUTE ON FUNCTION public.conjurar_magia_srd_multialvo_v3(text,text,smallint,text[],integer[]) FROM PUBLIC,anon;
REVOKE EXECUTE ON FUNCTION public.conjurar_magia_com_acao_srd_multialvo_v3(text,text,smallint,text[],integer[]) FROM PUBLIC,anon;
REVOKE EXECUTE ON FUNCTION public.usar_pocao_cura_srd_manual(text,text,integer[]) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.conjurar_magia_srd_manual(text,text,smallint,text,integer[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.conjurar_magia_com_acao_srd_manual(text,text,smallint,text,integer[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.conjurar_magia_srd_multialvo_v3(text,text,smallint,text[],integer[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.conjurar_magia_com_acao_srd_multialvo_v3(text,text,smallint,text[],integer[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.usar_pocao_cura_srd_manual(text,text,integer[]) TO authenticated;
