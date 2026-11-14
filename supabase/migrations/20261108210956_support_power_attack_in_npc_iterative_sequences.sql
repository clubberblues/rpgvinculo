
DO $migration$
DECLARE
  v_def text;
  v_old text;
  v_new text;
BEGIN
  v_def:=pg_get_functiondef('priv.npc_iniciar_ataque_iterativo_impl(bigint,text,text,text,uuid,text,text)'::regprocedure);
  v_old:=$old$CREATE OR REPLACE FUNCTION priv.npc_iniciar_ataque_iterativo_impl(p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text DEFAULT NULL::text)$old$;
  v_new:=$new$CREATE OR REPLACE FUNCTION priv.npc_iniciar_ataque_iterativo_impl(p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text, p_power_attack_penalty integer)$new$;
  IF position(v_old in v_def)=0 THEN RAISE EXCEPTION 'Assinatura de início NPC não corresponde ao esperado.'; END IF;
  v_def:=replace(v_def,v_old,v_new);

  v_old:=' v_action jsonb;';
  v_new:=v_old||E'\n v_power_attack_penalty integer:=coalesce(p_power_attack_penalty,0);';
  IF position(v_old in v_def)=0 THEN RAISE EXCEPTION 'Declarações do início NPC mudaram.'; END IF;
  v_def:=replace(v_def,v_old,v_new);

  v_old:=$old$ if v_weapon is null then raise exception 'A instância selecionada não está equipada nesta mão.'; end if;
 if p_attack_type='atk-corpo' and coalesce(v_weapon->'details'->>'weapon_melee','true')='false' then$old$;
  v_new:=$new$ if v_weapon is null then raise exception 'A instância selecionada não está equipada nesta mão.'; end if;
 if v_power_attack_penalty<0 OR v_power_attack_penalty>coalesce((v_profile->>'base_attack_bonus')::integer,0) then
  raise exception 'Penalidade de Ataque Poderoso deve ficar entre 0 e o BBA atual.';
 end if;
 if v_power_attack_penalty>0 then
  if p_attack_type<>'atk-corpo' then raise exception 'Ataque Poderoso só pode ser usado em ataques corpo a corpo.'; end if;
  if coalesce((v_profile->>'power_attack_available')::boolean,false) is not true
     or coalesce((v_profile->>'strength')::integer,0)<13 then
   raise exception 'Ataque Poderoso exige o talento e Força 13.';
  end if;
  if coalesce((v_weapon->'details'->>'weapon_light')::boolean,false) then
   raise exception 'Ataque Poderoso não pode ser usado com arma leve.';
  end if;
 end if;
 if p_attack_type='atk-corpo' and coalesce(v_weapon->'details'->>'weapon_melee','true')='false' then$new$;
  IF position(v_old in v_def)=0 THEN RAISE EXCEPTION 'Ponto de validação da arma no início NPC mudou.'; END IF;
  v_def:=replace(v_def,v_old,v_new);

  v_old:=$old$  weapon_instance_id,weapon_hand_slot,weapon_end,base_attack_bonus,attacks_total,
  round_number,turn_index,created_by
 ) values (
  p_campaign_id,p_actor_token_id,v_actor_character_id,p_target_token_id,p_attack_type,
  p_weapon_instance_id,p_weapon_hand_slot,p_weapon_end,
  (v_profile->>'base_attack_bonus')::integer,(v_profile->>'attacks_total')::smallint,
  greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,1)),
  (v_campaign.combat_data->>'current_turn')::integer,v_user
 ) returning * into v_sequence;$old$;
  v_new:=$new$  weapon_instance_id,weapon_hand_slot,weapon_end,power_attack_penalty,base_attack_bonus,attacks_total,
  round_number,turn_index,created_by
 ) values (
  p_campaign_id,p_actor_token_id,v_actor_character_id,p_target_token_id,p_attack_type,
  p_weapon_instance_id,p_weapon_hand_slot,p_weapon_end,v_power_attack_penalty,
  (v_profile->>'base_attack_bonus')::integer,(v_profile->>'attacks_total')::smallint,
  greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,1)),
  (v_campaign.combat_data->>'current_turn')::integer,v_user
 ) returning * into v_sequence;$new$;
  IF position(v_old in v_def)=0 THEN RAISE EXCEPTION 'Insert da sequência NPC mudou.'; END IF;
  v_def:=replace(v_def,v_old,v_new);
  EXECUTE v_def;

  EXECUTE $wrapper$
    CREATE OR REPLACE FUNCTION public.iniciar_ataque_iterativo_npc_srd(
      p_campaign_id bigint,p_actor_token_id text,p_target_token_id text,
      p_attack_type text,p_weapon_instance_id uuid,p_weapon_hand_slot text,
      p_weapon_end text,p_power_attack_penalty integer
    ) RETURNS jsonb
    LANGUAGE sql
    SECURITY INVOKER
    SET search_path TO ''
    AS $fn$ SELECT priv.npc_iniciar_ataque_iterativo_impl($1,$2,$3,$4,$5,$6,$7,$8); $fn$
  $wrapper$;
  REVOKE ALL ON FUNCTION public.iniciar_ataque_iterativo_npc_srd(bigint,text,text,text,uuid,text,text,integer) FROM PUBLIC,anon;
  GRANT EXECUTE ON FUNCTION public.iniciar_ataque_iterativo_npc_srd(bigint,text,text,text,uuid,text,text,integer) TO authenticated;
  REVOKE ALL ON FUNCTION priv.npc_iniciar_ataque_iterativo_impl(bigint,text,text,text,uuid,text,text,integer) FROM PUBLIC,anon,authenticated;
END
$migration$;
