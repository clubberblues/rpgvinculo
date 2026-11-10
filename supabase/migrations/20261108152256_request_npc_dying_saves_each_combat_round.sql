
UPDATE priv.srd_condition_engine_rules
SET flags=COALESCE(flags,'{}'::jsonb)||jsonb_build_object(
  'helpless',true,'loses_dex_ac',true,'coup_de_grace_vulnerable',true
),updated_at=now()
WHERE condition_id IN ('dying','stable') AND enabled=true;

DO $migration$
DECLARE
  v_def text;
  v_anchor text;
  v_insert text;
  v_count integer;
BEGIN
  v_def:=pg_get_functiondef('public.avancar_turno(bigint)'::regprocedure);
  v_anchor:='  v_current_actor:=v_order->v_next;';
  v_insert:= $code$
  IF v_next=0 THEN
    DECLARE
      v_npc_dying_ids text[];
      v_npc_dying_targets jsonb;
    BEGIN
      SELECT array_agg(DISTINCT t.token->>'id' ORDER BY t.token->>'id')
        INTO v_npc_dying_ids
      FROM public.campaigns c
      CROSS JOIN LATERAL jsonb_array_elements(
        CASE WHEN jsonb_typeof(c.cba_data->'tokens')='array' THEN c.cba_data->'tokens' ELSE '[]'::jsonb END
      ) t(token)
      JOIN public.srd_campaign_conditions cc
        ON cc.campaign_id=c.id AND cc.target_kind='token'
       AND cc.target_id=t.token->>'id'
       AND cc.condition_id='dying' AND cc.active=true
      WHERE c.id=p_campaign_id
        AND t.token->>'tipo'='npc'
        AND NULLIF(t.token->>'sourceCharacterId','') ~ '^[0-9]+$'
        AND COALESCE(t.token->>'id','')<>''
        AND COALESCE(t.token->>'hp','') ~ '^-?[0-9]{1,6}$'
        AND (t.token->>'hp')::integer BETWEEN -9 AND -1
        AND COALESCE(NULLIF(cc.notes->>'last_resolved_round','')::integer,0)<v_round;

      IF COALESCE(cardinality(v_npc_dying_ids),0)>0 THEN
        SELECT jsonb_agg(jsonb_build_object(
          'token_id',t.token->>'id',
          'name',COALESCE(t.token->>'nome',t.token->>'name','NPC'),
          'source_character_id',t.token->>'sourceCharacterId',
          'pv',(t.token->>'hp')::integer
        ) ORDER BY t.token->>'id')
        INTO v_npc_dying_targets
        FROM public.campaigns c
        CROSS JOIN LATERAL jsonb_array_elements(
          CASE WHEN jsonb_typeof(c.cba_data->'tokens')='array' THEN c.cba_data->'tokens' ELSE '[]'::jsonb END
        ) t(token)
        WHERE c.id=p_campaign_id AND t.token->>'tipo'='npc'
          AND t.token->>'id'=ANY(v_npc_dying_ids);

        INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
        VALUES(
          p_campaign_id,'test_request','PUBLIC',
          jsonb_build_object(
            'tipo','Estabilização (D100)',
            'npc_alvos',to_jsonb(v_npc_dying_ids),
            'mestre','Sistema','mestre_id',auth.uid(),
            'request_id',gen_random_uuid()::text,
            'resolution_type','npc_dying_save',
            'detalhes',COALESCE(v_npc_dying_targets,'[]'::jsonb)
          )
        );
        v_next_data:=v_next_data||jsonb_build_object('npc_dying_saves',COALESCE(v_npc_dying_targets,'[]'::jsonb));
      ELSE
        v_next_data:=v_next_data||jsonb_build_object('npc_dying_saves','[]'::jsonb);
      END IF;
    END;
  END IF;

$code$||v_anchor;
  v_count:=(length(v_def)-length(replace(v_def,v_anchor,'')))/length(v_anchor);
  IF v_count<>1 THEN RAISE EXCEPTION 'Ponto de integração da estabilização de NPCs no avanço de turno não é único: %.',v_count; END IF;
  EXECUTE replace(v_def,v_anchor,v_insert);
END;
$migration$;
