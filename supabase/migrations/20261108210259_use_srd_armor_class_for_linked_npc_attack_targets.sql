
DO $migration$
DECLARE
  v_def text;
  v_old text;
  v_new text;
BEGIN
  v_def:=pg_get_functiondef('priv.npc_resolver_ataque_iterativo_impl(bigint,uuid)'::regprocedure);
  IF position('v_player_ac jsonb' in v_def)=0 THEN
    v_old:='  v_target_loses_dex boolean := false;';
    v_new:=v_old||E'\n  v_player_ac jsonb;';
    IF position(v_old in v_def)=0 THEN RAISE EXCEPTION 'Declaração do resolvedor NPC mudou; nenhuma alteração aplicada.'; END IF;
    v_def:=replace(v_def,v_old,v_new);
  END IF;

  v_old:=$old$  if v_target->>'tipo'='player' then
    v_player_ac:=public.srd_calcular_ca_personagem_srd(p_campaign_id,v_seq.target_token_id,'normal',v_actor_is_giant);
    v_ca:=nullif(v_player_ac->>'final_ac','')::integer;
    if v_ca is null then raise exception 'Não foi possível calcular a CA do personagem alvo.'; end if;
  else
    v_ca_text:=coalesce(v_target->>'ac',v_target->'monsterStats'->>'ca');
    if coalesce(v_ca_text,'') !~ '^[0-9]{1,3}$' then raise exception 'O alvo não possui CA numérica válida.'; end if;
    v_ca:=v_ca_text::integer+v_effect_ac;
  end if;$old$;
  v_new:=$new$  if v_target->>'tipo'='player' then
    v_player_ac:=public.srd_calcular_ca_personagem_srd(p_campaign_id,v_seq.target_token_id,'normal',v_actor_is_giant);
    v_ca:=nullif(v_player_ac->>'final_ac','')::integer;
    if v_ca is null then raise exception 'Não foi possível calcular a CA do personagem alvo.'; end if;
  elsif v_target->>'tipo'='npc' AND NULLIF(v_target->>'sourceCharacterId','') IS NOT NULL then
    v_player_ac:=priv.srd_calcular_ca_alvo_campanha_srd(
      p_campaign_id,v_target->>'sourceCharacterId','normal'
    );
    v_ca:=nullif(v_player_ac->>'final_ac','')::integer;
    if v_ca is null then raise exception 'Não foi possível calcular a CA atual da ficha SRD vinculada ao NPC alvo.'; end if;
    if v_actor_is_giant then
      SELECT sh.raca_id::text INTO v_target_race
      FROM public.srd_character_sheets sh
      WHERE sh.character_id::text=v_target->>'sourceCharacterId';
      IF v_target_race IN ('anao','gnomo')
         AND NOT COALESCE((v_player_ac->>'dexterity_lost')::boolean,false) THEN
        v_ca:=v_ca+4;
      END IF;
    end if;
  else
    v_ca_text:=coalesce(v_target->>'ac',v_target->'monsterStats'->>'ca');
    if coalesce(v_ca_text,'') !~ '^[0-9]{1,3}$' then raise exception 'O alvo não possui CA numérica válida.'; end if;
    v_ca:=v_ca_text::integer+v_effect_ac;
  end if;$new$;
  IF position(v_old in v_def)=0 THEN RAISE EXCEPTION 'Bloco de CA do resolvedor NPC mudou; nenhuma alteração aplicada.'; END IF;
  v_def:=replace(v_def,v_old,v_new);
  EXECUTE v_def;
END
$migration$;
