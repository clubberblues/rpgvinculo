CREATE OR REPLACE FUNCTION priv.descanso_longo_npc_vinculado_srd_impl(p_campaign_id bigint,p_token_id text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $function$
DECLARE
 v_campaign public.campaigns%ROWTYPE; v_token jsonb; v_tokens jsonb;
 v_token_count integer; v_token_index bigint;
 v_character public.characters%ROWTYPE; v_sheet public.srd_character_sheets%ROWTYPE;
 v_level integer; v_hp integer; v_max integer; v_new_hp integer; v_last_rest timestamptz;
 v_spell_state jsonb; v_class_key text; v_conditions_removed integer:=0; v_changed integer:=0;
 v_rage_end jsonb;
BEGIN
 IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
   RAISE EXCEPTION 'Somente o Mestre autenticado pode realizar o descanso de NPCs.';
 END IF;
 SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
 IF UPPER(COALESCE(v_campaign.state,''))='COMBATE' THEN RAISE EXCEPTION 'Não é possível realizar descanso longo durante combate.'; END IF;
 v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END;
 SELECT count(*)::integer,min(t.ordinality) INTO v_token_count,v_token_index
 FROM jsonb_array_elements(v_tokens) WITH ORDINALITY t(token,ordinality)
 WHERE t.token->>'id'=BTRIM(p_token_id) AND t.token->>'tipo'='npc';
 IF v_token_count<>1 THEN RAISE EXCEPTION 'Token NPC não encontrado ou duplicado.'; END IF;
 v_token:=v_tokens->(v_token_index::integer-1);
 IF NULLIF(v_token->>'sourceCharacterId','') IS NULL THEN RAISE EXCEPTION 'Este NPC não possui ficha SRD de origem vinculada.'; END IF;
 SELECT * INTO v_character FROM public.characters WHERE id::text=v_token->>'sourceCharacterId' FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Ficha de origem do NPC não encontrada.'; END IF;
 SELECT * INTO v_sheet FROM public.srd_character_sheets WHERE character_id=v_character.id FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD de origem não encontrada.'; END IF;
 v_last_rest:=v_sheet.magias_descanso_em;
 IF v_last_rest IS NOT NULL AND v_last_rest>clock_timestamp()-INTERVAL '8 hours' THEN
   RAISE EXCEPTION 'O descanso longo exige 8 horas entre descansos.';
 END IF;
 v_level:=GREATEST(1,COALESCE(v_sheet.nivel,1));
 v_rage_end:=priv.srd_end_barbarian_rage_token(p_campaign_id,BTRIM(p_token_id),true);
 SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
 v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END;
 SELECT count(*)::integer,min(t.ordinality) INTO v_token_count,v_token_index
 FROM jsonb_array_elements(v_tokens) WITH ORDINALITY t(token,ordinality)
 WHERE t.token->>'id'=BTRIM(p_token_id) AND t.token->>'tipo'='npc';
 IF v_token_count<>1 THEN RAISE EXCEPTION 'Token NPC deixou de ser único durante o descanso.'; END IF;
 v_token:=v_tokens->(v_token_index::integer-1);
 IF COALESCE(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' OR COALESCE(v_token->>'hp','') !~ '^[0-9]{1,6}$' THEN
   RAISE EXCEPTION 'PV atuais ou máximos do token são inválidos.';
 END IF;
 v_max:=(v_token->>'maxHp')::integer; v_hp:=(v_token->>'hp')::integer;
 v_new_hp:=LEAST(v_max,v_hp+v_level);
 v_spell_state:=COALESCE(v_sheet.magias_preparadas,'{"version":1,"conhecidas":[],"preparadas":[],"usos":{}}'::jsonb);
 IF jsonb_typeof(v_spell_state->'preparadas')<>'array' THEN RAISE EXCEPTION 'Estado de magias da ficha de NPC inválido.'; END IF;
 SELECT COALESCE(NULLIF(cls.class_key,''),public._srd35_class_key(cls.nome)) INTO v_class_key
 FROM public.srd_classes cls WHERE cls.id=v_sheet.classe_id;
 IF v_class_key IS NULL THEN RAISE EXCEPTION 'Classe da ficha de NPC não foi resolvida.'; END IF;
 SELECT jsonb_build_object(
   'version',1,'conhecidas',COALESCE(v_spell_state->'conhecidas','[]'::jsonb),
   'preparadas',COALESCE(jsonb_agg(jsonb_set(e.value,'{expended}','false'::jsonb,true) ORDER BY e.ord),'[]'::jsonb),
   'dominio_preparadas',COALESCE((SELECT jsonb_agg(jsonb_set(d.value,'{expended}','false'::jsonb,true) ORDER BY d.ord)
     FROM jsonb_array_elements(COALESCE(v_spell_state->'dominio_preparadas','[]'::jsonb)) WITH ORDINALITY d(value,ord)),'[]'::jsonb),
   'usos',CASE WHEN v_class_key IN ('sorcerer','bard') THEN '{}'::jsonb ELSE COALESCE(v_spell_state->'usos','{}'::jsonb) END
 ) INTO v_spell_state FROM jsonb_array_elements(v_spell_state->'preparadas') WITH ORDINALITY e(value,ord);
 UPDATE public.srd_character_feature_resources SET uses_spent=0,resource_spent=0,last_reset_at=clock_timestamp()
 WHERE character_id=v_character.id;
 UPDATE public.srd_character_sheets SET pv_atual=v_new_hp,pv_max=v_max,magias_preparadas=v_spell_state,magias_descanso_em=clock_timestamp()
 WHERE character_id=v_character.id;
 UPDATE public.srd_campaign_conditions SET active=false
 WHERE campaign_id=p_campaign_id AND target_kind='token' AND target_id=BTRIM(p_token_id)
   AND active AND condition_id IN ('fatigued','exhausted');
 GET DIAGNOSTICS v_conditions_removed=ROW_COUNT;
 UPDATE public.srd_campaign_conditions SET active=false
 WHERE campaign_id=p_campaign_id AND target_kind='character' AND target_id=v_character.id::text
   AND active AND condition_id IN ('fatigued','exhausted');
 GET DIAGNOSTICS v_changed=ROW_COUNT;
 v_conditions_removed:=v_conditions_removed+v_changed;
 v_token:=v_token||jsonb_build_object('hp',v_new_hp,'maxHp',v_max);
 SELECT COALESCE(jsonb_agg(CASE WHEN t.ordinality=v_token_index THEN v_token ELSE t.token END ORDER BY t.ordinality),'[]'::jsonb)
 INTO v_tokens FROM jsonb_array_elements(v_tokens) WITH ORDINALITY t(token,ordinality);
 UPDATE public.campaigns SET cba_data=COALESCE(cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens) WHERE id=p_campaign_id;
 PERFORM priv.log(p_campaign_id,'NPC_LONG_REST',jsonb_build_object(
   'token_id',BTRIM(p_token_id),'character_id',v_character.id,'character_name',v_token->>'nome',
   'healing',v_new_hp-v_hp,'hp',v_new_hp,'max_hp',v_max,'class_resources_reset',true));
 RETURN jsonb_build_object('ok',true,'token_id',BTRIM(p_token_id),'character_id',v_character.id::text,
   'character_name',COALESCE(v_character.nome,v_token->>'nome'),'pv_atual',v_new_hp,'pv_max',v_max,
   'cura',v_new_hp-v_hp,'magias_repostas',true,'recursos_classe_repostos',true,
   'condicoes_removidas',v_conditions_removed,'furia_encerrada',COALESCE((v_rage_end->>'ended')::boolean,false),
   'descanso_em',clock_timestamp(),'cba_data',(SELECT cba_data FROM public.campaigns WHERE id=p_campaign_id));
END;
$function$;
REVOKE ALL ON FUNCTION priv.descanso_longo_npc_vinculado_srd_impl(bigint,text) FROM PUBLIC,anon;
GRANT USAGE ON SCHEMA priv TO authenticated;
GRANT EXECUTE ON FUNCTION priv.descanso_longo_npc_vinculado_srd_impl(bigint,text) TO authenticated;
CREATE OR REPLACE FUNCTION public.descanso_longo_npc_vinculado_srd(p_campaign_id bigint,p_token_id text)
RETURNS jsonb
LANGUAGE sql
SECURITY INVOKER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $function$
 SELECT priv.descanso_longo_npc_vinculado_srd_impl(p_campaign_id,p_token_id);
$function$;
REVOKE ALL ON FUNCTION public.descanso_longo_npc_vinculado_srd(bigint,text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.descanso_longo_npc_vinculado_srd(bigint,text) TO authenticated;