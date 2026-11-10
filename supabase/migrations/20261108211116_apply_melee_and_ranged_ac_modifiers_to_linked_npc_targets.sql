
DO $migration$
DECLARE
 v_def text;
 v_old text;
 v_new text;
BEGIN
 v_def:=pg_get_functiondef('priv.npc_resolver_ataque_iterativo_impl(bigint,uuid)'::regprocedure);
 v_old:=$old$    v_ca:=nullif(v_player_ac->>'final_ac','')::integer;
    if v_ca is null then raise exception 'Não foi possível calcular a CA atual da ficha SRD vinculada ao NPC alvo.'; end if;
    if v_actor_is_giant then$old$;
 v_new:=$new$    v_ca:=nullif(v_player_ac->>'final_ac','')::integer;
    if v_ca is null then raise exception 'Não foi possível calcular a CA atual da ficha SRD vinculada ao NPC alvo.'; end if;
    v_ca:=v_ca+case when v_seq.attack_type='atk-corpo'
      then priv.srd_effective_modifier(p_campaign_id,'token',v_seq.target_token_id,'ac_melee')
      else priv.srd_effective_modifier(p_campaign_id,'token',v_seq.target_token_id,'ac_ranged') end;
    if v_actor_is_giant then$new$;
 IF position(v_old in v_def)=0 THEN RAISE EXCEPTION 'Bloco de CA NPC vinculado não encontrado para adicionar modificador situacional.'; END IF;
 v_def:=replace(v_def,v_old,v_new);
 EXECUTE v_def;
END
$migration$;
