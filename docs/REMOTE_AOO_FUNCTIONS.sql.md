# Definições SQL remotas — subsistema de Ataques de Oportunidade e Movimento Pendente

> Exportação de leitura de `pg_get_functiondef` no Supabase remoto em 2026-11-09. Contém definições atuais do banco, não o histórico de migrations. Não executar este documento como migration: owners, grants, dependências, constraints e ordem de criação precisam ser reconciliados primeiro.

## Inventário

- Funções exportadas: 37.
- SECURITY DEFINER: 28.
- SECURITY INVOKER: 9.
- Tamanho total dos corpos: 142664 caracteres.
- Todas as funções consultadas têm search_path explícito; SECURITY DEFINER incluem `pg_temp` por último.

| Assinatura | Segurança | search_path | MD5 |
|---|---|---|---|
| `priv.srd_aoo_require_blind_concealment_roll()` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `1669bd6e269520fa5e2dcb7499b4057e` |
| `priv.srd_cancelar_movimento_aoo_pendente_impl(p_campaign_id bigint, p_pending_id uuid)` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `ee1753fd8f8ad3e6c968942f42816125` |
| `priv.srd_confusion_aoo_engaged(p_campaign_id bigint, p_actor_token_id text, p_actor_character_id text, p_mover_token_id text)` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `94e8a45d2e8ca3745420a1f12f937f8c` |
| `priv.srd_encerrar_reacao_aoo_pendente_impl(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_cancel_attack boolean)` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `5cae44f8906a5b12952720e39d76f6cb` |
| `priv.srd_guard_aoo_cannot_attack()` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `0ff70ee88e3cc734581db3df022f0409` |
| `priv.srd_guard_pending_aoo_movement()` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `9a9a41aa24a8ee42393daaa1ecc1ec37` |
| `priv.srd_iniciar_derrubar_com_aoo_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_defender_firm_ground boolean, p_trip_using_weapon boolean)` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `2ab33685b041ef930b6ae7e2b48e3991` |
| `priv.srd_registrar_ocultacao_ataque_oportunidade_impl(p_campaign_id bigint, p_attack_id uuid, p_manual_d100 integer)` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `43cb67bd4552bd98181d8d367850ff90` |
| `priv.srd_reservar_ataque_oportunidade_impl(p_campaign_id bigint, p_actor_token_id text, p_trigger_key text, p_actor_flat_footed boolean)` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `4c9a7d64f8d098ae43a7bfc42beffce4` |
| `priv.srd_reservar_reacao_movimento_aoo_impl(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `3775a7763a3ed392bacb2250504a9a24` |
| `priv.srd_resolver_derrubar_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_attacker_d20 integer, p_defender_d20 integer, p_defender_firm_ground boolean)` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `5bf3be6185cbd49939f07ff35c540afc` |
| `priv.srd_resolver_levantar_caido_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid)` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `fa34c68e20bb6b03fb13b1d11c09c523` |
| `priv.srd_validate_aoo_pending_movement_preview()` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `aca15b8ef5fd809cbd20b69adf8f01be` |
| `public.srd_aplicar_dano_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_attack_id uuid, p_damage_rolls integer[], p_idempotency_key uuid)` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `e2673e828af60a967204f327bd6e3f28` |
| `public.srd_aplicar_dano_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_damage_rolls integer[], p_idempotency_key uuid)` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `7a2e372249a04ccb3230aaec95ed89ef` |
| `public.srd_cancelar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)` | INVOKER | `search_path=pg_catalog, public, priv, pg_temp` | `2a9aa9d725069c8b19f7afab96f3b17a` |
| `public.srd_confirmar_critico_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_confirmation_d20 integer)` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `84f2806567a32d263acaa9a820b1696c` |
| `public.srd_consultar_armas_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `c7270f541fe8293592d933cf9ed753a3` |
| `public.srd_consultar_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid)` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `f1ddcca1cda00b5b060045fab96d21f5` |
| `public.srd_consultar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `b3e6ea933e228678ee6dd6f1aca089e5` |
| `public.srd_encerrar_reacao_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_cancel_attack boolean)` | INVOKER | `search_path=pg_catalog, public, priv, pg_temp` | `0c1cd6771a68caf6d49e69af7dd45978` |
| `public.srd_finalizar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `17fb9a9259675bf9d1c2278135ff2394` |
| `public.srd_iniciar_ataque_oportunidade_desarmado_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid)` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `b891864a3d8c80653feeafb54d9a4dfe` |
| `public.srd_iniciar_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid)` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `44c3145a7e5dc696e5e5643fb0a6b1ce` |
| `public.srd_iniciar_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid, p_natural_attack_index integer)` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `b12188da9c009734f31a553849756ccf` |
| `public.srd_iniciar_ataque_oportunidade_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text)` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `a641aab6e59793b2bf5b09cc290746db` |
| `public.srd_iniciar_derrubar_com_aoo_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_defender_firm_ground boolean, p_trip_using_weapon boolean)` | INVOKER | `search_path=public, priv, pg_temp` | `bfced6e0a1cec2ec606ff65dc64e9a2c` |
| `public.srd_listar_ataques_naturais_oportunidade_srd(p_campaign_id bigint, p_reactor_token_id text)` | INVOKER | `search_path=pg_catalog, public, priv, pg_temp` | `f9399cd730c4cfea4c66706207d2ffea` |
| `public.srd_listar_movimentos_aoo_pendentes_srd(p_campaign_id bigint)` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `5ab451a12deb204eea23de23bca1d8cf` |
| `public.srd_registrar_ocultacao_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_manual_d100 integer)` | INVOKER | `search_path=pg_catalog, public, priv, pg_temp` | `a2b55e84b7c44ed4b1b703254c4cc229` |
| `public.srd_registrar_rolagem_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_manual_d20 integer, p_idempotency_key uuid)` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `950703066647366f6336bffb82e7f7d4` |
| `public.srd_reservar_ataque_oportunidade_srd(p_campaign_id bigint, p_actor_token_id text, p_trigger_key text, p_actor_flat_footed boolean)` | INVOKER | `search_path=pg_catalog, public, priv, pg_temp` | `55f3d2fded1997d551aea8f163409603` |
| `public.srd_reservar_reacao_movimento_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)` | INVOKER | `search_path=pg_catalog, public, priv, pg_temp` | `c72562f95bbe3da5134f29a383011e77` |
| `public.srd_resolver_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid)` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `80a04e98b926307fe74bcbc34c963e7f` |
| `public.srd_resolver_derrubar_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_attacker_d20 integer, p_defender_d20 integer, p_defender_firm_ground boolean)` | INVOKER | `search_path=public, priv, pg_temp` | `14034f46a624a140d274163c2da73e37` |
| `public.srd_resolver_levantar_caido_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid)` | INVOKER | `search_path=public, priv, pg_temp` | `a43d163405b49ee3ca459241c0177a43` |
| `public.srd_solicitar_movimento_com_aoo_srd(p_campaign_id bigint, p_mover_token_id text, p_destination_x integer, p_destination_y integer, p_controller text)` | DEFINER | `search_path=pg_catalog, public, priv, pg_temp` | `38c1ffad22be8fe01381770a2bdb06b3` |

## Definições atuais

### `priv.srd_aoo_require_blind_concealment_roll()`

```sql
CREATE OR REPLACE FUNCTION priv.srd_aoo_require_blind_concealment_roll()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
begin
  if new.status='awaiting_damage'
     and old.status is distinct from 'awaiting_miss_chance'
     and not (coalesce(new.resolution_data,'{}'::jsonb) ? 'concealment_d100') then
    if priv.srd_condition_has_flag(new.campaign_id,'token',new.actor_token_id,'opponents_total_concealment')
       or (new.actor_character_id is not null and
         priv.srd_condition_has_flag(new.campaign_id,'character',new.actor_character_id::text,'opponents_total_concealment')) then
      new.resolution_data:=coalesce(new.resolution_data,'{}'::jsonb)||jsonb_build_object(
        'concealment_required',true,
        'concealment_miss_chance',50,
        'concealment_source','opponents_total_concealment',
        'concealment_pending_status','awaiting_damage'
      );
      new.status:='awaiting_miss_chance';
    end if;
  end if;
  return new;
end;
$function$

```

### `priv.srd_cancelar_movimento_aoo_pendente_impl(p_campaign_id bigint, p_pending_id uuid)`

```sql
CREATE OR REPLACE FUNCTION priv.srd_cancelar_movimento_aoo_pendente_impl(p_campaign_id bigint, p_pending_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare v_pending priv.srd_aoo_pending_movements%rowtype; v_reactions jsonb;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode cancelar o movimento pendente.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where pending_id=p_pending_id and campaign_id=p_campaign_id for update;
  if not found then raise exception 'Movimento pendente não encontrado.'; end if;
  if v_pending.status not in ('waiting_reactions','ready_to_commit') then
    raise exception 'Este movimento não está mais pendente.';
  end if;
  update priv.srd_aoo_attacks set status='cancelled'
  where pending_id=p_pending_id
    and status in ('awaiting_attack_roll','awaiting_critical_confirmation','awaiting_miss_chance','awaiting_damage');
  select coalesce(jsonb_agg(
    case when r.value->>'status' in ('waiting','reserved','attack_started','hit_pending_damage')
      then r.value||jsonb_build_object('status','skipped','skip_reason','movement_cancelled')
      else r.value end order by r.ordinality),'[]'::jsonb)
  into v_reactions
  from jsonb_array_elements(v_pending.pending_reactions) with ordinality r(value,ordinality);
  update priv.srd_aoo_pending_movements
  set status='cancelled',pending_reactions=v_reactions,cancelled_at=now(),updated_at=now()
  where pending_id=p_pending_id;
  return jsonb_build_object('cancelled',true,'pending_id',p_pending_id,
    'mover_token_id',v_pending.mover_token_id,'reactions',v_reactions);
end;
$function$

```

### `priv.srd_confusion_aoo_engaged(p_campaign_id bigint, p_actor_token_id text, p_actor_character_id text, p_mover_token_id text)`

```sql
CREATE OR REPLACE FUNCTION priv.srd_confusion_aoo_engaged(p_campaign_id bigint, p_actor_token_id text, p_actor_character_id text, p_mover_token_id text)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
 with current_round as (
   select greatest(0,coalesce(nullif(combat_data->>'round','')::integer,0)) round_no
   from public.campaigns where id=p_campaign_id
 )
 select exists(
   select 1 from public.srd_attack_sequences s,current_round r
   where s.campaign_id=p_campaign_id
     and s.round_number between greatest(0,r.round_no-1) and r.round_no
     and (
       (p_actor_character_id is not null and s.actor_character_id::text=p_actor_character_id
          and s.target_token_id=p_mover_token_id)
       or
       (p_mover_token_id ~ '^[0-9]+$' and s.actor_character_id::text=p_mover_token_id
          and s.target_token_id=p_actor_token_id)
     )
 ) or exists(
   select 1 from public.srd_npc_attack_sequences s,current_round r
   where s.campaign_id=p_campaign_id
     and s.round_number between greatest(0,r.round_no-1) and r.round_no
     and (
       (s.actor_token_id=p_actor_token_id and s.target_token_id=p_mover_token_id)
       or (s.actor_token_id=p_mover_token_id and s.target_token_id=p_actor_token_id)
     )
 );
$function$

```

### `priv.srd_encerrar_reacao_aoo_pendente_impl(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_cancel_attack boolean)`

```sql
CREATE OR REPLACE FUNCTION priv.srd_encerrar_reacao_aoo_pendente_impl(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_cancel_attack boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_idx bigint;
  v_reaction jsonb;
  v_attack priv.srd_aoo_attacks%rowtype;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode encerrar uma reação pendente.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id for update;
  if not found or v_pending.status<>'waiting_reactions' then
    raise exception 'Movimento não está aguardando reações.';
  end if;
  select ordinality,value into v_idx,v_reaction
  from jsonb_array_elements(v_pending.pending_reactions) with ordinality
  where value->>'reactor_token_id'=btrim(p_reactor_token_id) limit 1;
  if v_reaction is null then raise exception 'Reação não encontrada neste movimento.'; end if;
  if v_reaction->>'status' in ('attack_started','hit_pending_damage') then
    if not p_cancel_attack then
      raise exception 'O ataque já começou; resolva-o ou autorize explicitamente seu cancelamento.';
    end if;
    select * into v_attack from priv.srd_aoo_attacks
    where attack_id=(v_reaction->>'attack_id')::uuid and campaign_id=p_campaign_id for update;
    if not found or v_attack.status not in ('awaiting_attack_roll','awaiting_critical_confirmation','awaiting_miss_chance','awaiting_damage') then
      raise exception 'Ataque não pode ser cancelado neste estado.';
    end if;
    update priv.srd_aoo_attacks set status='cancelled' where attack_id=v_attack.attack_id;
  elsif v_reaction->>'status' not in ('waiting','reserved') then
    raise exception 'Esta reação já foi encerrada.';
  end if;
  update priv.srd_aoo_pending_movements
  set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_idx-1)::text],
      v_reaction||jsonb_build_object('status','skipped','skip_reason',case
        when v_reaction->>'status' in ('reserved','attack_started','hit_pending_damage')
          then 'gm_cancelled_after_reservation' else 'gm_declined_reaction' end),
      false),updated_at=now()
  where pending_id=p_pending_id;
  return jsonb_build_object('closed',true,'pending_id',p_pending_id,
    'reactor_token_id',p_reactor_token_id,'reaction_spent',
    (v_reaction->>'status') in ('reserved','attack_started','hit_pending_damage'));
end;
$function$

```

### `priv.srd_guard_aoo_cannot_attack()`

```sql
CREATE OR REPLACE FUNCTION priv.srd_guard_aoo_cannot_attack()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
begin
  if new.status in ('awaiting_attack_roll','awaiting_critical_confirmation','awaiting_miss_chance','awaiting_damage') then
    if priv.srd_condition_has_flag(new.campaign_id,'token',new.actor_token_id,'cannot_attack')
      or (new.actor_character_id is not null and
        priv.srd_condition_has_flag(new.campaign_id,'character',new.actor_character_id::text,'cannot_attack')) then
      raise exception 'A condição atual impede realizar este ataque de oportunidade.';
    end if;
  end if;
  return new;
end;
$function$

```

### `priv.srd_guard_pending_aoo_movement()`

```sql
CREATE OR REPLACE FUNCTION priv.srd_guard_pending_aoo_movement()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_old_token jsonb;
  v_new_token jsonb;
  v_commit_id text;
begin
  if new.cba_data is not distinct from old.cba_data then return new; end if;
  select * into v_pending
  from priv.srd_aoo_pending_movements p
  where p.campaign_id=new.id
    and p.status in ('waiting_reactions','ready_to_commit')
  order by p.created_at desc limit 1;
  if not found then return new; end if;

  select t into v_old_token
  from jsonb_array_elements(case when jsonb_typeof(old.cba_data->'tokens')='array'
    then old.cba_data->'tokens' else '[]'::jsonb end) t
  where t->>'id'=v_pending.mover_token_id or t->>'key'=v_pending.mover_token_id
  limit 1;
  select t into v_new_token
  from jsonb_array_elements(case when jsonb_typeof(new.cba_data->'tokens')='array'
    then new.cba_data->'tokens' else '[]'::jsonb end) t
  where t->>'id'=v_pending.mover_token_id or t->>'key'=v_pending.mover_token_id
  limit 1;

  v_commit_id:=current_setting('app.srd_aoo_pending_commit',true);

  if v_old_token is not null and v_new_token is null
     and v_commit_id is distinct from v_pending.pending_id::text then
    raise exception 'Remoção do token bloqueada: há um movimento aguardando resolução de ataques de oportunidade.';
  end if;

  if v_old_token is not null and v_new_token is not null
     and ((v_old_token->>'gridX') is distinct from (v_new_token->>'gridX')
       or (v_old_token->>'gridY') is distinct from (v_new_token->>'gridY')) then
    if v_commit_id is distinct from v_pending.pending_id::text then
      raise exception 'Movimento bloqueado: há um ataque de oportunidade pendente de resolução.';
    end if;
  end if;
  return new;
end;
$function$

```

### `priv.srd_iniciar_derrubar_com_aoo_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_defender_firm_ground boolean, p_trip_using_weapon boolean)`

```sql
CREATE OR REPLACE FUNCTION priv.srd_iniciar_derrubar_com_aoo_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_defender_firm_ground boolean DEFAULT false, p_trip_using_weapon boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_campaign public.campaigns%ROWTYPE;
  v_combat jsonb;
  v_order jsonb;
  v_actor jsonb;
  v_calc jsonb;
  v_attacker jsonb;
  v_defender jsonb;
  v_round integer;
  v_turn integer;
  v_pending_id uuid:=gen_random_uuid();
  v_distance integer;
  v_reach integer:=5;
  v_profile jsonb;
  v_character_id bigint;
  v_reach_match text[];
  v_reaction_status text:='waiting';
  v_trigger text;
  v_has_threatening_weapon boolean:=false;
  v_has_unarmed_threat boolean:=false;
  v_size_rank integer:=4;
  v_base_reach integer:=5;
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode preparar a reação de Derrubar.';
  END IF;
  IF NULLIF(BTRIM(p_attacker_token_id),'') IS NULL OR NULLIF(BTRIM(p_defender_token_id),'') IS NULL
     OR BTRIM(p_attacker_token_id)=BTRIM(p_defender_token_id) THEN
    RAISE EXCEPTION 'Atacante e defensor precisam ser tokens diferentes.';
  END IF;
  SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND OR upper(coalesce(v_campaign.state,''))<>'COMBATE'
     OR coalesce(v_campaign.combat_data->>'active','false')<>'true' THEN
    RAISE EXCEPTION 'A iniciativa precisa estar ativa.';
  END IF;
  v_combat:=v_campaign.combat_data;
  IF coalesce(v_combat->'surprise'->>'phase','normal')='surprise_round' THEN
    RAISE EXCEPTION 'Derrubar não pode ser iniciado durante a rodada surpresa.';
  END IF;
  IF coalesce(v_combat->>'current_turn','') !~ '^[0-9]+$' THEN
    RAISE EXCEPTION 'Turno atual inválido.';
  END IF;
  v_turn:=(v_combat->>'current_turn')::integer;
  v_order:=CASE WHEN jsonb_typeof(v_combat->'turn_order')='array' THEN v_combat->'turn_order' ELSE '[]'::jsonb END;
  v_actor:=v_order->v_turn;
  IF v_actor->>'id' IS DISTINCT FROM BTRIM(p_attacker_token_id) THEN
    RAISE EXCEPTION 'O atacante precisa estar no turno ativo.';
  END IF;
  IF EXISTS (SELECT 1 FROM priv.srd_aoo_pending_movements
    WHERE campaign_id=p_campaign_id AND status IN ('waiting_reactions','ready_to_commit')) THEN
    RAISE EXCEPTION 'Já existe outra reação de oportunidade pendente nesta campanha.';
  END IF;
  v_calc:=public.srd_consultar_modificadores_manobra_srd(
    p_campaign_id,p_attacker_token_id,p_defender_token_id,'trip',
    coalesce(p_defender_firm_ground,false),coalesce(p_trip_using_weapon,false)
  );
  IF v_calc->>'aoo_status'<>'provokes' THEN
    RAISE EXCEPTION 'Esta tentativa não exige a fila de reação de Derrubar; consulte os modificadores e resolva pelo fluxo normal.';
  END IF;

  SELECT t INTO v_attacker FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
   WHERE t->>'id'=BTRIM(p_attacker_token_id) OR t->>'key'=BTRIM(p_attacker_token_id) LIMIT 1;
  SELECT t INTO v_defender FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
   WHERE t->>'id'=BTRIM(p_defender_token_id) OR t->>'key'=BTRIM(p_defender_token_id) LIMIT 1;
  IF v_attacker IS NULL OR v_defender IS NULL THEN
    RAISE EXCEPTION 'Atacante ou defensor não está na cena.';
  END IF;
  IF coalesce(v_attacker->>'gridX','') !~ '^[0-9]{1,3}$' OR coalesce(v_attacker->>'gridY','') !~ '^[0-9]{1,3}$'
     OR coalesce(v_defender->>'gridX','') !~ '^[0-9]{1,3}$' OR coalesce(v_defender->>'gridY','') !~ '^[0-9]{1,3}$' THEN
    RAISE EXCEPTION 'A posição de um dos tokens não é válida para medir alcance.';
  END IF;

  v_distance:=priv.srd_grid_footprint_distance_ft(
    (v_defender->>'gridX')::integer,(v_defender->>'gridY')::integer,
    priv.srd_token_grid_footprint(p_campaign_id,p_defender_token_id),
    (v_attacker->>'gridX')::integer,(v_attacker->>'gridY')::integer,
    priv.srd_token_grid_footprint(p_campaign_id,p_attacker_token_id)
  );
  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,BTRIM(p_defender_token_id));
  v_character_id:=NULLIF(v_profile->>'character_id','')::bigint;
  v_size_rank:=coalesce(nullif(v_profile->>'size_rank','')::integer,4);
  v_base_reach:=CASE
    WHEN v_size_rank>=8 THEN 30
    WHEN v_size_rank=7 THEN 20
    WHEN v_size_rank=6 THEN 15
    WHEN v_size_rank=5 THEN 10
    ELSE 5
  END;

  IF v_character_id IS NOT NULL THEN
    SELECT coalesce(bool_or(
      coalesce((eq.detalhes->>'threatens_squares')::boolean,true)
      AND v_distance BETWEEN
        CASE
          WHEN coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5)>5 AND v_size_rank>4
            THEN v_base_reach+5
          ELSE greatest(5,coalesce(nullif(eq.detalhes->>'threat_min_ft','')::integer,5))
        END
        AND CASE
          WHEN coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5)>5 AND v_size_rank>4
            THEN coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5)*greatest(1,v_base_reach/5)
          ELSE greatest(coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5),v_base_reach)
        END
    ),false),
    coalesce(max(
      CASE
        WHEN coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5)>5 AND v_size_rank>4
          THEN coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5)*greatest(1,v_base_reach/5)
        ELSE greatest(coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5),v_base_reach)
      END
    ),v_base_reach)
      INTO v_has_threatening_weapon,v_reach
      FROM public.srd_character_weapon_instances wi
      JOIN public.srd_equipment eq ON eq.id=wi.equipment_id
      JOIN public.srd_character_equipment ce
        ON ce.character_id=wi.character_id AND ce.equipment_id=wi.equipment_id
       AND ce.equipado IS TRUE AND ce.hand_slot=wi.hand_slot
     WHERE wi.character_id=v_character_id::text AND wi.equipado IS TRUE
       AND wi.hand_slot IN ('main_hand','off_hand')
       AND coalesce(eq.detalhes->>'weapon_melee','true')<>'false';
    IF NOT v_has_threatening_weapon THEN
      SELECT coalesce(cl.class_key='monk',false) OR EXISTS (
        SELECT 1
        FROM jsonb_array_elements(
          CASE WHEN jsonb_typeof(sh.talentos)='array' THEN sh.talentos ELSE '[]'::jsonb END
        ) feat
        WHERE lower(concat_ws(' ',feat->>'id',feat->>'nome',feat->>'name')) ~
          '(ataque_desarmado_aprimorado|srd35_feat_improved_unarmed_strike|improved_unarmed_strike|ataque desarmado aprimorado|improved unarmed strike)'
      )
      INTO v_has_unarmed_threat
      FROM public.srd_character_sheets sh
      JOIN public.srd_classes cl ON cl.id=sh.classe_id
      WHERE sh.character_id=v_character_id;

      IF v_has_unarmed_threat AND v_distance BETWEEN 5 AND v_base_reach THEN
        v_has_threatening_weapon:=true;
        v_reach:=v_base_reach;
      ELSE
        v_reaction_status:='ineligible';
      END IF;
    END IF;
  ELSE
    v_reach:=greatest(v_base_reach,coalesce(nullif(v_defender->>'melee_reach_ft','')::integer,5));
    v_reach_match:=regexp_match(
      coalesce(v_defender->'monsterStats'->>'espaco_alcance',v_defender->'monsterStats'->>'space_reach',''),
      '([0-9]+)[[:space:]]*ft[^0-9]*([0-9]+)','i'
    );
    IF v_reach_match IS NOT NULL THEN v_reach:=greatest(v_reach,v_reach_match[2]::integer); END IF;
    IF v_distance>v_reach THEN v_reaction_status:='ineligible'; END IF;
  END IF;

  v_round:=greatest(1,coalesce(nullif(v_combat->>'round','')::integer,1));
  v_trigger:='trip:'||v_pending_id::text;
  INSERT INTO priv.srd_aoo_pending_movements(
    pending_id,campaign_id,mover_token_id,movement_controller,destination_x,destination_y,
    origin_x,origin_y,combat_round,current_turn,turn_actor_id,threats,pending_reactions,
    status,created_by
  ) VALUES (
    v_pending_id,p_campaign_id,BTRIM(p_attacker_token_id),'gm',
    (v_attacker->>'gridX')::integer,(v_attacker->>'gridY')::integer,
    (v_attacker->>'gridX')::integer,(v_attacker->>'gridY')::integer,
    v_round,v_turn,BTRIM(p_attacker_token_id),
    jsonb_build_array(jsonb_build_object('maneuver_event','trip','defender_token_id',BTRIM(p_defender_token_id),
      'defender_firm_ground',coalesce(p_defender_firm_ground,false),'distance_ft',v_distance,'reach_ft',v_reach)),
    jsonb_build_array(jsonb_build_object('reactor_token_id',BTRIM(p_defender_token_id),'trigger_key',v_trigger,
      'status',v_reaction_status,'reason',CASE WHEN v_reaction_status='ineligible' THEN 'no_equipped_weapon_threatens_trigger_square' END,
      'threat',jsonb_build_object('last_threatened_step',0,'maneuver_event','trip'))),
    'waiting_reactions',auth.uid()
  );
  RETURN jsonb_build_object('pending',true,'pending_id',v_pending_id,'maneuver','trip',
    'attacker_token_id',BTRIM(p_attacker_token_id),'defender_token_id',BTRIM(p_defender_token_id),
    'reaction_status',v_reaction_status,'distance_ft',v_distance,'reach_ft',v_reach);
END;
$function$

```

### `priv.srd_registrar_ocultacao_ataque_oportunidade_impl(p_campaign_id bigint, p_attack_id uuid, p_manual_d100 integer)`

```sql
CREATE OR REPLACE FUNCTION priv.srd_registrar_ocultacao_ataque_oportunidade_impl(p_campaign_id bigint, p_attack_id uuid, p_manual_d100 integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_attack priv.srd_aoo_attacks%rowtype;
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_next_status text;
  v_reaction_index integer;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode registrar a chance de falha por ocultação.';
  end if;
  if p_manual_d100 is null or p_manual_d100 not between 1 and 100 then
    raise exception 'A chance de falha exige um resultado D100 físico entre 1 e 100.';
  end if;
  select * into v_attack from priv.srd_aoo_attacks
  where campaign_id=p_campaign_id and attack_id=p_attack_id for update;
  if not found or v_attack.created_by<>auth.uid() then
    raise exception 'Ataque não encontrado ou sem autorização.';
  end if;
  if v_attack.status<>'awaiting_miss_chance' then
    if v_attack.resolution_data ? 'concealment_d100'
       and (v_attack.resolution_data->>'concealment_d100')::integer=p_manual_d100 then
      return jsonb_build_object('attack_id',p_attack_id,'status',v_attack.status,
        'miss_chance',50,'d100',p_manual_d100,
        'missed',coalesce((v_attack.resolution_data->>'concealment_missed')::boolean,false),
        'replayed',true);
    end if;
    raise exception 'Este ataque não aguarda a rolagem de ocultação.';
  end if;
  if coalesce(v_attack.resolution_data->>'concealment_miss_chance','')<>'50'
     or coalesce(v_attack.resolution_data->>'concealment_pending_status','')<>'awaiting_damage' then
    raise exception 'Os dados de ocultação do ataque são inválidos.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=v_attack.pending_id for update;
  if not found or v_pending.status<>'waiting_reactions' then
    raise exception 'O movimento que originou o ataque não está mais pendente.';
  end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
    or coalesce(v_campaign.combat_data->>'active','false')<>'true'
    or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
    or coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn then
    raise exception 'O combate avançou antes da rolagem de ocultação.';
  end if;
  v_next_status:=case when p_manual_d100<=50 then 'miss' else 'awaiting_damage' end;
  update priv.srd_aoo_attacks
  set status=v_next_status,
      resolution_data=resolution_data||jsonb_build_object(
        'concealment_d100',p_manual_d100,
        'concealment_missed',(p_manual_d100<=50),
        'concealment_resolved_at',now()
      ),
      resolved_at=case when p_manual_d100<=50 then now() else resolved_at end
  where attack_id=p_attack_id returning * into v_attack;
  select (e.ordinality-1)::integer into v_reaction_index
  from jsonb_array_elements(v_pending.pending_reactions) with ordinality e(value,ordinality)
  where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1;
  if v_reaction_index is null then raise exception 'A reação vinculada ao ataque não foi encontrada.'; end if;
  update priv.srd_aoo_pending_movements p
  set pending_reactions=jsonb_set(p.pending_reactions,ARRAY[v_reaction_index::text],
    (p.pending_reactions->v_reaction_index)||jsonb_build_object(
      'status',case when p_manual_d100<=50 then 'miss' else 'hit_pending_damage' end,
      'concealment_d100',p_manual_d100,'concealment_missed',(p_manual_d100<=50)
    ),false),updated_at=now()
  where p.pending_id=v_attack.pending_id;
  return jsonb_build_object('attack_id',p_attack_id,'status',v_next_status,
    'd100',p_manual_d100,'miss_chance',50,'missed',(p_manual_d100<=50),'replayed',false);
end;
$function$

```

### `priv.srd_reservar_ataque_oportunidade_impl(p_campaign_id bigint, p_actor_token_id text, p_trigger_key text, p_actor_flat_footed boolean)`

```sql
CREATE OR REPLACE FUNCTION priv.srd_reservar_ataque_oportunidade_impl(p_campaign_id bigint, p_actor_token_id text, p_trigger_key text, p_actor_flat_footed boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_combat jsonb;
  v_round integer;
  v_phase text;
  v_profile jsonb;
  v_character_id bigint;
  v_feats jsonb := '[]'::jsonb;
  v_has_combat_reflexes boolean := false;
  v_dex_mod integer := 0;
  v_limit integer := 1;
  v_used integer := 0;
  v_existing priv.srd_aoo_reaction_ledger%rowtype;
  v_new priv.srd_aoo_reaction_ledger%rowtype;
  v_token jsonb;
  v_stats jsonb;
  v_monster_feats text;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode autorizar e registrar uma reação de ataque de oportunidade.';
  end if;
  if nullif(btrim(p_actor_token_id),'') is null
     or nullif(btrim(p_trigger_key),'') is null
     or length(p_trigger_key)>160 then
    raise exception 'Identificador do combatente ou do evento provocador inválido.';
  end if;

  select combat_data into v_combat
  from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce((select state from public.campaigns where id=p_campaign_id),''))<>'COMBATE'
     or coalesce((v_combat->>'active')::boolean,false) is not true then
    raise exception 'A iniciativa precisa estar ativa para registrar uma reação.';
  end if;
  if coalesce(v_combat->>'round','') !~ '^[0-9]+$' then
    raise exception 'A rodada atual é inválida.';
  end if;
  v_phase:=case when coalesce(v_combat->'surprise'->>'phase','')='surprise_round'
    then 'surprise_round' else 'normal' end;
  v_round:=greatest(1,(v_combat->>'round')::integer);

  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,btrim(p_actor_token_id));
  if v_profile is null or (v_profile->>'character_id' is null and v_profile->>'size_rank' is null) then
    raise exception 'Não foi possível validar o combatente que pretende reagir.';
  end if;
  if coalesce(v_profile->>'dexterity_modifier','') ~ '^-?[0-9]+$' then
    v_dex_mod:=(v_profile->>'dexterity_modifier')::integer;
  end if;
  v_character_id:=nullif(v_profile->>'character_id','')::bigint;

  if v_character_id is not null then
    select coalesce(talentos,'[]'::jsonb) into v_feats
    from public.srd_character_sheets where character_id=v_character_id;
    v_has_combat_reflexes:=exists(
      select 1 from jsonb_array_elements(
        case when jsonb_typeof(v_feats)='array' then v_feats else '[]'::jsonb end
      ) f
      where lower(coalesce(f->>'id','')) in
        ('reflexos_de_combate','combat_reflexes','srd35_feat_combat_reflexes')
        or lower(coalesce(f->>'nome','')) in ('reflexos de combate','combat reflexes')
    );
  else
    select t into v_token
    from public.campaigns c,
      lateral jsonb_array_elements(case when jsonb_typeof(c.cba_data->'tokens')='array'
        then c.cba_data->'tokens' else '[]'::jsonb end) t
    where c.id=p_campaign_id and (t->>'id'=btrim(p_actor_token_id) or t->>'key'=btrim(p_actor_token_id))
    limit 1;
    if v_token is null then raise exception 'Token reator não existe mais na cena.'; end if;
    v_stats:=coalesce(v_token->'monsterStats','{}'::jsonb);
    v_monster_feats:=concat_ws(',',
      nullif(v_stats->>'feats',''),
      nullif(v_stats->>'talentos',''),
      nullif(v_stats->'dados_tecnicos'->'statblock'->>'feats',''),
      nullif(v_stats->'dados_tecnicos'->>'feats','')
    );
    v_has_combat_reflexes:=coalesce(v_monster_feats,'') ~*
      '(^|[,;[:space:]])combat[[:space:]]+reflexesb?([,;[:space:]]|$)';
  end if;

  if p_actor_flat_footed and not v_has_combat_reflexes then
    raise exception 'Este combatente está surpreso/desprevenido e não possui Reflexos de Combate para reagir.';
  end if;
  if v_has_combat_reflexes then
    v_limit:=1+greatest(0,v_dex_mod);
  end if;

  select * into v_existing
  from priv.srd_aoo_reaction_ledger
  where campaign_id=p_campaign_id and combat_phase=v_phase and combat_round=v_round
    and actor_token_id=btrim(p_actor_token_id) and trigger_key=btrim(p_trigger_key);
  if found then
    return jsonb_build_object('reserved',true,'duplicate',true,
      'reaction_id',v_existing.reaction_id,'round',v_round,
      'used',v_existing.reaction_number,'limit',v_existing.max_reactions,
      'combat_reflexes',v_has_combat_reflexes,'dexterity_modifier',v_dex_mod);
  end if;

  select count(*)::integer into v_used
  from priv.srd_aoo_reaction_ledger
  where campaign_id=p_campaign_id and combat_phase=v_phase and combat_round=v_round
    and actor_token_id=btrim(p_actor_token_id);
  if v_used>=v_limit then
    raise exception 'Limite de ataques de oportunidade atingido nesta rodada (%/%).',v_used,v_limit;
  end if;

  insert into priv.srd_aoo_reaction_ledger(
    campaign_id,combat_phase,combat_round,actor_token_id,trigger_key,reaction_number,max_reactions
  ) values (
    p_campaign_id,v_phase,v_round,btrim(p_actor_token_id),btrim(p_trigger_key),v_used+1,v_limit
  ) returning * into v_new;

  return jsonb_build_object('reserved',true,'duplicate',false,
    'reaction_id',v_new.reaction_id,'round',v_round,
    'used',v_new.reaction_number,'limit',v_limit,
    'combat_reflexes',v_has_combat_reflexes,'dexterity_modifier',v_dex_mod,
    'flat_footed_allowed',v_has_combat_reflexes);
end;
$function$

```

### `priv.srd_reservar_reacao_movimento_aoo_impl(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)`

```sql
CREATE OR REPLACE FUNCTION priv.srd_reservar_reacao_movimento_aoo_impl(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_profile jsonb;
  v_character_id text;
  v_confused_engagement boolean:=false;
  v_token_type text;
  v_flat_footed boolean:=false;
  v_has_combat_reflexes boolean:=false;
  v_disabled boolean:=false;
  v_index bigint;
  v_reaction jsonb;
  v_reactor_token jsonb;
  v_trigger text;
  v_reservation jsonb;
  v_updated jsonb;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode autorizar a reação.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id for update;
  if not found or v_pending.status<>'waiting_reactions' then raise exception 'Movimento não está aguardando reações.'; end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
    or coalesce(v_campaign.combat_data->>'active','false')<>'true'
    or coalesce(v_campaign.combat_data->>'round','') !~ '^[0-9]+$'
    or greatest(1,(v_campaign.combat_data->>'round')::integer)<>v_pending.combat_round
    or coalesce(v_campaign.combat_data->>'current_turn','') !~ '^[0-9]+$'
    or (v_campaign.combat_data->>'current_turn')::integer<>v_pending.current_turn then
    raise exception 'O combate avançou desde a solicitação; o movimento precisa ser reavaliado.';
  end if;
  select ordinality,value into v_index,v_reaction
  from jsonb_array_elements(v_pending.pending_reactions) with ordinality
  where coalesce(value->>'reactor_token_id','')=btrim(p_reactor_token_id) limit 1;
  if v_reaction is null then raise exception 'Este token não está entre os combatentes ameaçadores detectados.'; end if;
  if v_reaction->>'status'='reserved' then
    return jsonb_build_object('reserved',true,'duplicate',true,
      'reservation_id',v_reaction->>'reservation_id','pending_id',p_pending_id,
      'reactor_token_id',p_reactor_token_id);
  end if;
  if v_reaction->>'status'<>'waiting' then raise exception 'Esta reação já foi processada.'; end if;
  select t->>'tipo' into v_token_type
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=btrim(p_reactor_token_id) or t->>'key'=btrim(p_reactor_token_id) limit 1;
  if v_token_type is null then raise exception 'Token reator não existe mais na cena.'; end if;
  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,btrim(p_reactor_token_id));
  v_character_id:=v_profile->>'character_id';

  v_confused_engagement:=priv.srd_condition_has_flag(
    p_campaign_id,'token',btrim(p_reactor_token_id),'no_aoo_against_unengaged');
  if nullif(v_character_id,'') is not null then
    v_confused_engagement:=v_confused_engagement or priv.srd_condition_has_flag(
      p_campaign_id,'character',v_character_id,'no_aoo_against_unengaged');
  end if;
  if v_confused_engagement and not priv.srd_confusion_aoo_engaged(
    p_campaign_id,btrim(p_reactor_token_id),v_character_id,v_pending.mover_token_id) then
    update priv.srd_aoo_pending_movements
    set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_index-1)::text],
      v_reaction||jsonb_build_object('status','ineligible','reason','confused_target_not_engaged'),
      false),updated_at=now()
    where pending_id=p_pending_id;
    return jsonb_build_object('reserved',false,'ineligible',true,
      'reason','confused_target_not_engaged','reactor_token_id',p_reactor_token_id);
  end if;

  v_disabled :=
    priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'no_actions')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'helpless')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'stunned')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'unconscious')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dying')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'stable')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dead')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'no_threaten_squares')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'cannot_attack');
  if v_character_id is not null then
    v_disabled:=v_disabled
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_actions')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'helpless')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'stunned')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'unconscious')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'dying')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'stable')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'dead')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_threaten_squares')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'cannot_attack');
  end if;
  if v_disabled then
    update priv.srd_aoo_pending_movements
    set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_index-1)::text],
      v_reaction||jsonb_build_object('status','ineligible','reason','reactor_condition_prevents_aoo'),
      false),updated_at=now()
    where pending_id=p_pending_id;
    return jsonb_build_object('reserved',false,'ineligible',true,
      'reason','reactor_condition_prevents_aoo','reactor_token_id',p_reactor_token_id);
  end if;

  v_flat_footed:=priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'no_aoo');
  if v_character_id is not null then
    v_flat_footed:=v_flat_footed
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_aoo');
  end if;
  if v_flat_footed then
    if v_character_id is not null then
      select exists(
        select 1 from public.srd_character_sheets sh
        cross join lateral jsonb_array_elements(
          case when jsonb_typeof(sh.talentos)='array' then sh.talentos else '[]'::jsonb end
        ) feat
        where sh.character_id::text=v_character_id
          and (lower(coalesce(feat->>'id','')) in
            ('reflexos_de_combate','combat_reflexes','srd35_feat_combat_reflexes')
            or lower(coalesce(feat->>'nome','')) in ('reflexos de combate','combat reflexes'))
      ) into v_has_combat_reflexes;
    else
      select t into v_reactor_token
      from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
      where t->>'id'=btrim(p_reactor_token_id) or t->>'key'=btrim(p_reactor_token_id) limit 1;
      v_has_combat_reflexes:=concat_ws(',',
        v_reactor_token->'monsterStats'->>'feats',
        v_reactor_token->'monsterStats'->>'talentos',
        v_reactor_token->'monsterStats'->'dados_tecnicos'->'statblock'->>'feats',
        v_reactor_token->'monsterStats'->'dados_tecnicos'->>'feats'
      ) ~* '(^|[,;[:space:]])combat[[:space:]]+reflexesb?([,;[:space:]]|$)';
    end if;
    if not v_has_combat_reflexes then
      update priv.srd_aoo_pending_movements
      set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_index-1)::text],
        v_reaction||jsonb_build_object('status','ineligible',
          'reason','flat_footed_without_combat_reflexes'),false),updated_at=now()
      where pending_id=p_pending_id;
      return jsonb_build_object('reserved',false,'ineligible',true,
        'reason','flat_footed_without_combat_reflexes','reactor_token_id',p_reactor_token_id);
    end if;
  end if;

  v_trigger:=v_reaction->>'trigger_key';
  v_reservation:=public.srd_reservar_ataque_oportunidade_srd(
    p_campaign_id,btrim(p_reactor_token_id),v_trigger,v_flat_footed);
  v_updated:=v_reaction||jsonb_build_object(
    'status','reserved','reservation_id',v_reservation->>'reaction_id',
    'reservation_number',v_reservation->'used','reservation_limit',v_reservation->'limit',
    'flat_footed',v_flat_footed);
  update priv.srd_aoo_pending_movements
  set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_index-1)::text],v_updated,false),
      updated_at=now()
  where pending_id=p_pending_id;
  return jsonb_build_object('reserved',true,
    'duplicate',coalesce((v_reservation->>'duplicate')::boolean,false),
    'reservation',v_reservation,'pending_id',p_pending_id,
    'reactor_token_id',p_reactor_token_id,'reaction',v_updated);
end;
$function$

```

### `priv.srd_resolver_derrubar_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_attacker_d20 integer, p_defender_d20 integer, p_defender_firm_ground boolean)`

```sql
CREATE OR REPLACE FUNCTION priv.srd_resolver_derrubar_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_attacker_d20 integer, p_defender_d20 integer, p_defender_firm_ground boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE v_pending priv.srd_aoo_pending_movements%ROWTYPE; v_defender text; v_result jsonb;
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode concluir Derrubar após a reação.';
  END IF;
  SELECT * INTO v_pending FROM priv.srd_aoo_pending_movements
   WHERE campaign_id=p_campaign_id AND pending_id=p_pending_id FOR UPDATE;
  IF NOT FOUND OR v_pending.status<>'waiting_reactions'
     OR NOT (v_pending.threats @> jsonb_build_array(jsonb_build_object('maneuver_event','trip'))) THEN
    RAISE EXCEPTION 'Evento de Derrubar aguardando reação não encontrado.';
  END IF;
  IF EXISTS (SELECT 1 FROM jsonb_array_elements(v_pending.pending_reactions) r
    WHERE r->>'status' IN ('waiting','reserved','attack_started','hit_pending_damage')) THEN
    RAISE EXCEPTION 'Ainda existem reações de oportunidade não resolvidas.';
  END IF;
  v_defender:=v_pending.pending_reactions->0->>'reactor_token_id';
  PERFORM set_config('app.srd_trip_aoo_pending_id',p_pending_id::text,true);
  v_result:=public.srd_resolver_derrubar_srd(
    p_campaign_id,v_pending.mover_token_id,v_defender,p_attacker_d20,p_defender_d20,
    false,p_defender_firm_ground,false
  );
  PERFORM set_config('app.srd_trip_aoo_pending_id','',true);
  RETURN v_result;
EXCEPTION WHEN OTHERS THEN
  PERFORM set_config('app.srd_trip_aoo_pending_id','',true);
  RAISE;
END;
$function$

```

### `priv.srd_resolver_levantar_caido_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid)`

```sql
CREATE OR REPLACE FUNCTION priv.srd_resolver_levantar_caido_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_pending priv.srd_aoo_pending_movements%ROWTYPE;
  v_campaign public.campaigns%ROWTYPE;
  v_token jsonb; v_count integer;
  v_round integer; v_actions jsonb; v_by jsonb; v_token_actions jsonb;
  v_key text; v_condition_count integer; v_profile jsonb; v_character_id text;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  SELECT * INTO v_pending FROM priv.srd_aoo_pending_movements
  WHERE campaign_id=p_campaign_id AND pending_id=p_pending_id FOR UPDATE;
  IF NOT FOUND OR v_pending.status<>'waiting_reactions'
     OR NOT (v_pending.threats @> '[{"standing_event":"stand_up"}]'::jsonb) THEN
    RAISE EXCEPTION 'Levantamento pendente não encontrado.';
  END IF;
  IF EXISTS(SELECT 1 FROM jsonb_array_elements(v_pending.pending_reactions) r
    WHERE r->>'status' IN ('waiting','reserved','attack_started','hit_pending_damage')) THEN
    RAISE EXCEPTION 'Resolva todas as reações de oportunidade antes de concluir o levantamento.';
  END IF;
  SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND OR upper(coalesce(v_campaign.state,''))<>'COMBATE'
     OR coalesce(v_campaign.combat_data->>'active','false')<>'true'
     OR greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
     OR coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn THEN
    RAISE EXCEPTION 'O combate avançou; o levantamento precisa ser reavaliado.';
  END IF;
  SELECT count(*)::integer,(array_agg(t))[1] INTO v_count,v_token
  FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  WHERE t->>'id'=v_pending.mover_token_id OR t->>'key'=v_pending.mover_token_id;
  IF v_count<>1 THEN RAISE EXCEPTION 'Token do levantamento ausente ou duplicado.'; END IF;
  IF public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' AND NOT (
    v_token->>'tipo'='player' AND EXISTS(
      SELECT 1 FROM public.characters ch WHERE ch.id::text=v_pending.mover_token_id
        AND ch.campaign_id=p_campaign_id AND ch.user_id=auth.uid()
    )
  ) THEN RAISE EXCEPTION 'Somente o Mestre ou o jogador dono do personagem pode concluir o levantamento.'; END IF;
  IF priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'no_actions')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'no_move')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'dying')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'stable')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'dead')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'unconscious')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'helpless') THEN
    RAISE EXCEPTION 'O alvo não pode levantar-se após as reações.';
  END IF;
  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,v_pending.mover_token_id);
  v_character_id:=v_profile->>'character_id';
  IF v_character_id IS NOT NULL AND (
    priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_actions')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_move')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'dying')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'stable')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'dead')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'unconscious')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'helpless')
  ) THEN
    RAISE EXCEPTION 'A ficha do personagem não permite levantar-se.';
  END IF;
  IF NOT EXISTS(SELECT 1 FROM public.srd_campaign_conditions
    WHERE campaign_id=p_campaign_id AND target_kind='token'
      AND target_id IN (v_pending.mover_token_id,coalesce(v_token->>'key',v_token->>'id'))
      AND condition_id='prone' AND active=true) THEN
    RAISE EXCEPTION 'O alvo não está mais Caído.';
  END IF;

  v_round:=v_pending.combat_round;
  v_actions:=v_campaign.combat_data->'action_economy';
  IF jsonb_typeof(v_actions)='object' AND coalesce(v_actions->>'round','')=v_round::text
     AND jsonb_typeof(v_actions->'by_character')='object' THEN
    v_by:=v_actions->'by_character';
  ELSE v_by:='{}'::jsonb; END IF;
  v_key:=v_pending.mover_token_id;
  v_token_actions:=CASE WHEN jsonb_typeof(v_by->v_key)='object' THEN v_by->v_key ELSE '{}'::jsonb END;
  IF coalesce((v_token_actions->>'movimento')::boolean,false) THEN
    RAISE EXCEPTION 'A ação de movimento deste combatente já foi usada.';
  END IF;
  IF priv.srd_condition_has_flag(p_campaign_id,'token',v_key,'one_move_or_standard')
     AND coalesce((v_token_actions->>'padrao')::boolean,false) THEN
    RAISE EXCEPTION 'As condições impedem gastar movimento depois de uma ação padrão.';
  END IF;
  v_token_actions:=v_token_actions||jsonb_build_object('movimento',true);
  v_by:=jsonb_set(v_by,ARRAY[v_key],v_token_actions,true);
  v_actions:=jsonb_build_object('round',v_round,'by_character',v_by);
  UPDATE public.campaigns SET combat_data=coalesce(combat_data,'{}'::jsonb)||
    jsonb_build_object('action_economy',v_actions) WHERE id=p_campaign_id;

  UPDATE public.srd_campaign_conditions SET active=false
  WHERE campaign_id=p_campaign_id AND target_kind='token'
    AND target_id IN (v_pending.mover_token_id,coalesce(v_token->>'key',v_token->>'id'))
    AND condition_id='prone' AND active=true;
  UPDATE priv.srd_aoo_pending_movements SET status='committed',committed_at=now(),updated_at=now()
  WHERE pending_id=p_pending_id AND campaign_id=p_campaign_id;
  PERFORM priv.log(p_campaign_id,'COMBAT_CONDITION',jsonb_build_object(
    'condition','prone','action','removed','reason','stand_up',
    'token_id',v_pending.mover_token_id,'action_consumed','movimento',
    'round',v_round,'reactions',v_pending.pending_reactions
  ));
  RETURN jsonb_build_object('ok',true,'stood_up',true,'token_id',v_pending.mover_token_id,
    'action_consumed','movimento','round',v_round,'reactions',v_pending.pending_reactions);
END;
$function$

```

### `priv.srd_validate_aoo_pending_movement_preview()`

```sql
CREATE OR REPLACE FUNCTION priv.srd_validate_aoo_pending_movement_preview()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare v_preview jsonb;
begin
  perform set_config('app.srd_aoo_pending_commit',new.pending_id::text,true);
  begin
    if new.movement_controller='player' then
      v_preview:=public.mover_token_player_cba(
        new.campaign_id,new.mover_token_id,new.destination_x,new.destination_y
      );
    else
      v_preview:=public.mover_token_gm_cba_srd(
        new.campaign_id,new.mover_token_id,new.destination_x,new.destination_y
      );
    end if;
    raise exception using errcode='P0001',message='__SRD_AOO_PREVIEW_ROLLBACK__';
  exception when others then
    if sqlerrm='__SRD_AOO_PREVIEW_ROLLBACK__' then
      null;
    else
      raise;
    end if;
  end;
  return new;
end;
$function$

```

### `public.srd_aplicar_dano_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_attack_id uuid, p_damage_rolls integer[], p_idempotency_key uuid)`

```sql
CREATE OR REPLACE FUNCTION public.srd_aplicar_dano_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_attack_id uuid, p_damage_rolls integer[], p_idempotency_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_attack priv.srd_aoo_attacks%rowtype;
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_target jsonb;
  v_tokens jsonb;
  v_scene jsonb;
  v_idx bigint;
  v_count integer;
  v_expr text;
  v_dice integer;
  v_faces integer;
  v_flat integer:=0;
  v_mult integer:=1;
  v_roll integer:=0;
  v_raw integer;
  v_final integer;
  v_hp integer;
  v_max integer;
  v_new_hp integer;
  v_type text;
  i integer;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then raise exception 'Somente o Mestre pode aplicar dano.'; end if;
  if p_idempotency_key is null or p_damage_rolls is null or cardinality(p_damage_rolls)<1
    or cardinality(p_damage_rolls)>30 or array_position(p_damage_rolls,null) is not null
    or exists(select 1 from unnest(p_damage_rolls) x where x<1 or x>1000) then
    raise exception 'Resultados de dano inválidos.';
  end if;
  select * into v_attack from priv.srd_aoo_attacks
  where campaign_id=p_campaign_id and attack_id=p_attack_id for update;
  if not found or v_attack.created_by<>auth.uid() or v_attack.actor_character_id is not null then
    raise exception 'Ataque natural não encontrado ou sem autorização.';
  end if;
  if v_attack.status='damage_applied' and v_attack.damage_idempotency_key=p_idempotency_key then
    return jsonb_build_object('attack_id',p_attack_id,'status','damage_applied','damage_applied',v_attack.damage_applied,'replayed',true);
  end if;
  if v_attack.status<>'awaiting_damage' then raise exception 'Ataque natural não está pronto para receber dano.'; end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where pending_id=v_attack.pending_id and campaign_id=p_campaign_id for update;
  if not found or v_pending.status<>'waiting_reactions' then raise exception 'Movimento pendente não está ativo.'; end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
    or coalesce(v_campaign.combat_data->>'active','false')<>'true'
    or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
    or coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn then
    raise exception 'A iniciativa mudou antes do dano.';
  end if;
  v_expr:=coalesce(v_attack.resolution_data->>'damage_expression',v_attack.resolution_data->>'weapon_damage');
  if v_expr !~ '^[0-9]+d[0-9]+([+-][0-9]+)?$' then raise exception 'Expressão de dano natural inválida: %.',v_expr; end if;
  v_dice:=substring(v_expr from '^([0-9]+)d')::integer;
  v_faces:=substring(v_expr from 'd([0-9]+)')::integer;
  v_flat:=coalesce(nullif(substring(v_expr from 'd[0-9]+([+-][0-9]+)$'),'')::integer,0);
  v_mult:=case when v_attack.is_critical then coalesce(nullif(v_attack.resolution_data->>'critical_multiplier','')::integer,2) else 1 end;
  if v_dice<1 or v_dice>10 or v_faces<2 or v_faces>100 or v_mult<1 or v_mult>5
    or cardinality(p_damage_rolls)<>v_dice*v_mult then raise exception 'Quantidade de dados não corresponde ao dano natural.'; end if;
  for i in 1..cardinality(p_damage_rolls) loop
    if p_damage_rolls[i]>v_faces then raise exception 'Resultado excede d%.',v_faces; end if;
    v_roll:=v_roll+p_damage_rolls[i];
  end loop;
  v_raw:=greatest(0,v_roll+v_flat+priv.srd_effective_modifier(p_campaign_id,'token',v_attack.actor_token_id,'damage')
    +v_flat*greatest(0,v_mult-1));
  v_type:=lower(coalesce(v_attack.resolution_data->>'damage_type','physical'));
  v_type:=case v_type when 'cortante' then 'slashing' when 'perfurante' then 'piercing'
    when 'impacto' then 'bludgeoning' else v_type end;

  select count(*)::integer,min(t.ordinality) into v_count,v_idx
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) with ordinality t(token,ordinality)
  where t.token->>'id'=v_attack.target_token_id and t.token->>'tipo' in ('player','npc','monstro');
  if v_count<>1 then raise exception 'Alvo ausente ou duplicado.'; end if;
  v_tokens:=case when jsonb_typeof(v_campaign.cba_data->'tokens')='array' then v_campaign.cba_data->'tokens' else '[]'::jsonb end;
  v_target:=v_tokens->(v_idx::integer-1);
  if v_target->>'tipo'='player' then
    select pv_atual,pv_max into v_hp,v_max from public.srd_character_sheets
    where character_id::text=v_attack.target_token_id for update;
    if not found or v_max is null or v_max<1 then raise exception 'PV do alvo inválidos.'; end if;
    v_final:=priv.srd_adjust_damage(p_campaign_id,'character',v_attack.target_token_id,v_type,v_raw);
    v_new_hp:=greatest(-10,least(v_max,coalesce(v_hp,v_max)-v_final));
    update public.srd_character_sheets set pv_atual=v_new_hp where character_id::text=v_attack.target_token_id;
    perform priv.srd_sync_character_vital_condition(v_attack.target_token_id,v_new_hp,false);
  else
    if coalesce(v_target->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' then raise exception 'PV máximo do alvo inválido.'; end if;
    v_max:=(v_target->>'maxHp')::integer;
    v_hp:=case when coalesce(v_target->>'hp','') ~ '^-?[0-9]{1,6}$' then (v_target->>'hp')::integer else v_max end;
    v_final:=priv.srd_adjust_damage(p_campaign_id,'token',v_attack.target_token_id,v_type,v_raw);
    v_new_hp:=greatest(-10,least(v_max,v_hp-v_final));
  end if;
  v_target:=v_target||jsonb_build_object('hp',v_new_hp,'maxHp',v_max);
  v_scene:=coalesce(v_campaign.cba_data,'{}'::jsonb)||jsonb_build_object('tokens',jsonb_set(v_tokens,ARRAY[(v_idx-1)::text],v_target,false));
  update public.campaigns set cba_data=v_scene where id=p_campaign_id;
  perform priv.srd_sync_linked_npc_token_vitals(p_campaign_id,v_attack.target_token_id,v_new_hp,v_max);
  update priv.srd_aoo_attacks set status='damage_applied',damage_rolls=p_damage_rolls,
    damage_applied=v_final,damage_idempotency_key=p_idempotency_key,damage_applied_at=now(),
    resolution_data=resolution_data||jsonb_build_object('damage_roll_sum',v_roll,'damage_raw',v_raw,
      'damage_final',v_final,'critical_multiplier_applied',v_mult)
  where attack_id=p_attack_id returning * into v_attack;
  update priv.srd_aoo_pending_movements p
  set pending_reactions=jsonb_set(p.pending_reactions,ARRAY[
    (select (e.ordinality-1)::text from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
     where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1)
  ],(
    select e.value||jsonb_build_object('status','damage_applied','damage_applied',v_final)
    from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
    where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1
  ),false),updated_at=now() where p.pending_id=v_attack.pending_id;
  return jsonb_build_object('attack_id',p_attack_id,'status','damage_applied','damage_applied',v_final,
    'target_hp',v_new_hp,'target_max_hp',v_max,'damage_expression',v_expr,'damage_rolls',p_damage_rolls,
    'critical',v_attack.is_critical,'critical_multiplier',v_mult,'replayed',false);
end;
$function$

```

### `public.srd_aplicar_dano_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_damage_rolls integer[], p_idempotency_key uuid)`

```sql
CREATE OR REPLACE FUNCTION public.srd_aplicar_dano_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_damage_rolls integer[], p_idempotency_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_attack priv.srd_aoo_attacks%rowtype;
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_sheet public.srd_character_sheets%rowtype;
  v_race public.srd_races%rowtype;
  v_weapon public.srd_equipment%rowtype;
  v_target jsonb;
  v_tokens jsonb;
  v_scene jsonb;
  v_target_idx bigint;
  v_target_count integer;
  v_expr text;
  v_dice integer;
  v_faces integer;
  v_mult integer:=1;
  v_roll_sum integer:=0;
  v_str_bonus integer:=0;
  v_damage_bonus integer:=0;
  v_critical_static integer:=0;
  v_specialization integer:=0;
  v_raw integer:=0;
  v_final integer:=0;
  v_damage_type text;
  v_hp integer;
  v_max_hp integer;
  v_new_hp integer;
  v_idem uuid;
  i integer;
  v_end_meta jsonb;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode aplicar dano de ataque de oportunidade.';
  end if;
  if p_idempotency_key is null or p_damage_rolls is null
     or cardinality(p_damage_rolls)<1 or cardinality(p_damage_rolls)>30
     or array_position(p_damage_rolls,null) is not null
     or exists(select 1 from unnest(p_damage_rolls) x where x<1 or x>1000) then
    raise exception 'Resultados de dano inválidos.';
  end if;
  select * into v_attack from priv.srd_aoo_attacks
  where attack_id=p_attack_id and campaign_id=p_campaign_id for update;
  if not found or v_attack.created_by<>auth.uid() then raise exception 'Ataque não encontrado ou sem autorização.'; end if;
  if v_attack.damage_idempotency_key=p_idempotency_key and v_attack.status='damage_applied' then
    return jsonb_build_object('attack_id',p_attack_id,'status','damage_applied',
      'damage_applied',v_attack.damage_applied,'replayed',true);
  end if;
  if v_attack.status<>'awaiting_damage' then raise exception 'Ataque ainda não está pronto para receber dano.'; end if;

  select * into v_pending from priv.srd_aoo_pending_movements
  where pending_id=v_attack.pending_id and campaign_id=p_campaign_id for update;
  if not found or v_pending.status<>'waiting_reactions' then raise exception 'Movimento pendente não está ativo.'; end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
     or coalesce(v_campaign.combat_data->>'active','false')<>'true'
     or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
     or coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn then
    raise exception 'A iniciativa mudou antes da aplicação do dano.';
  end if;

  select * into v_sheet from public.srd_character_sheets where character_id=v_attack.actor_character_id;
  select * into v_race from public.srd_races where id=v_sheet.raca_id;
  select * into v_weapon from public.srd_equipment eq
  join public.srd_character_weapon_instances wi on wi.equipment_id=eq.id
  where wi.instance_id=v_attack.weapon_instance_id
    and wi.character_id=v_attack.actor_character_id::text
    and wi.equipado is true and wi.hand_slot=v_attack.weapon_hand_slot;
  if not found then raise exception 'Arma não está mais equipada.'; end if;

  v_end_meta:=case when v_attack.weapon_end='off' then coalesce(v_weapon.detalhes->'weapon_end_off','{}'::jsonb)
    when v_attack.weapon_end='main' then coalesce(v_weapon.detalhes->'weapon_end_main','{}'::jsonb)
    else '{}'::jsonb end;
  v_expr:=coalesce(
    case when lower(coalesce(v_race.tamanho,'')) in ('pequeno','small')
      then v_end_meta->>'damage_small' else v_end_meta->>'damage_medium' end,
    case when lower(coalesce(v_race.tamanho,'')) in ('pequeno','small')
      then v_weapon.detalhes->>'damage_small' else v_weapon.detalhes->>'damage_medium' end,
    v_weapon.dano
  );
  if v_expr !~ '^[0-9]+d[0-9]+$' then
    raise exception 'Expressão de dano não normalizada: %.',coalesce(v_expr,'vazia');
  end if;
  v_dice:=split_part(v_expr,'d',1)::integer;
  v_faces:=split_part(v_expr,'d',2)::integer;
  if v_dice<1 or v_dice>10 or v_faces<2 or v_faces>100 then
    raise exception 'Expressão de dano fora dos limites suportados.';
  end if;
  v_mult:=case when v_attack.is_critical
    then coalesce(nullif(v_attack.resolution_data->>'critical_multiplier','')::integer,2) else 1 end;
  if v_mult<1 or v_mult>5 then raise exception 'Multiplicador crítico inválido.'; end if;
  if cardinality(p_damage_rolls)<>v_dice*v_mult then
    raise exception 'A arma exige % resultados de dano (% dados x multiplicador %).',v_dice*v_mult,v_dice,v_mult;
  end if;
  for i in 1..cardinality(p_damage_rolls) loop
    if p_damage_rolls[i]>v_faces then raise exception 'Resultado excede o dado d%.',v_faces; end if;
    v_roll_sum:=v_roll_sum+p_damage_rolls[i];
  end loop;

  v_damage_bonus:=priv.srd_effective_modifier(p_campaign_id,'token',v_attack.actor_token_id,'damage');
  v_str_bonus:=floor((coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10)
    +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.actor_token_id,'strength')-10)::numeric/2)::integer;
  if v_attack.weapon_hand_slot='off_hand' then
    v_str_bonus:=floor(v_str_bonus/2.0)::integer;
  elsif coalesce((v_weapon.detalhes->>'weapon_two_handed')::boolean,false)
    and not coalesce((v_weapon.detalhes->>'weapon_double')::boolean,false) then
    v_str_bonus:=floor(v_str_bonus*1.5)::integer;
  end if;
  v_damage_bonus:=v_damage_bonus+v_str_bonus;
  v_critical_static:=v_str_bonus;
  select coalesce(sum(case f->>'id'
    when 'srd35_feat_weapon_specialization' then 2
    when 'srd35_feat_greater_weapon_specialization' then 2 else 0 end),0)::integer
  into v_specialization
  from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
  where f->>'id' in ('srd35_feat_weapon_specialization','srd35_feat_greater_weapon_specialization')
    and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))
      =public.srd35_normalizar_parametro_talento(v_weapon.nome);
  v_damage_bonus:=v_damage_bonus+v_specialization;
  v_critical_static:=v_critical_static+v_specialization;

  v_raw:=greatest(0,v_roll_sum+v_damage_bonus+(v_critical_static*greatest(0,v_mult-1)));
  v_damage_type:=lower(coalesce(v_end_meta->>'damage_type',v_weapon.tipo_dano,'bludgeoning'));
  v_damage_type:=case v_damage_type when 'cortante' then 'slashing'
    when 'perfurante' then 'piercing' when 'impacto' then 'bludgeoning'
    when 'cortante/perfurante' then 'physical' when 'impacto/perfurante' then 'physical'
    else v_damage_type end;

  select count(*)::integer,min(t.ordinality) into v_target_count,v_target_idx
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) with ordinality t(token,ordinality)
  where t.token->>'id'=v_attack.target_token_id and t.token->>'tipo' in ('player','npc','monstro');
  if v_target_count<>1 then raise exception 'Alvo ausente ou duplicado na cena.'; end if;
  v_tokens:=case when jsonb_typeof(v_campaign.cba_data->'tokens')='array' then v_campaign.cba_data->'tokens' else '[]'::jsonb end;
  v_target:=v_tokens->(v_target_idx::integer-1);
  if v_target->>'tipo'='player' then
    select sh.pv_atual,sh.pv_max into v_hp,v_max_hp
    from public.srd_character_sheets sh where sh.character_id::text=v_attack.target_token_id for update;
    if not found or v_max_hp is null or v_max_hp<1 then raise exception 'Ficha alvo sem PV válidos.'; end if;
    v_final:=priv.srd_adjust_damage(p_campaign_id,'character',v_attack.target_token_id,v_damage_type,v_raw);
    v_new_hp:=greatest(-10,least(v_max_hp,coalesce(v_hp,v_max_hp)-v_final));
    update public.srd_character_sheets set pv_atual=v_new_hp where character_id::text=v_attack.target_token_id;
    perform priv.srd_sync_character_vital_condition(v_attack.target_token_id,v_new_hp,false);
  else
    if coalesce(v_target->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' then raise exception 'PV máximo do alvo inválido.'; end if;
    v_max_hp:=(v_target->>'maxHp')::integer;
    v_hp:=case when coalesce(v_target->>'hp','') ~ '^-?[0-9]{1,6}$' then (v_target->>'hp')::integer else v_max_hp end;
    v_final:=priv.srd_adjust_damage(p_campaign_id,'token',v_attack.target_token_id,v_damage_type,v_raw);
    v_new_hp:=greatest(-10,least(v_max_hp,v_hp-v_final));
  end if;
  v_target:=v_target||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp);
  v_scene:=coalesce(v_campaign.cba_data,'{}'::jsonb)||jsonb_build_object(
    'tokens',jsonb_set(v_tokens,ARRAY[(v_target_idx-1)::text],v_target,false));
  update public.campaigns set cba_data=v_scene where id=p_campaign_id;
  perform priv.srd_sync_linked_npc_token_vitals(p_campaign_id,v_attack.target_token_id,v_new_hp,v_max_hp);

  update priv.srd_aoo_attacks set status='damage_applied',damage_rolls=p_damage_rolls,
    damage_applied=v_final,damage_idempotency_key=p_idempotency_key,damage_applied_at=now(),
    resolution_data=resolution_data||jsonb_build_object('damage_expression',v_expr,
      'damage_roll_sum',v_roll_sum,'damage_bonus',v_damage_bonus,'damage_raw',v_raw,
      'damage_final',v_final,'critical_multiplier_applied',v_mult,'damage_type',v_damage_type)
  where attack_id=p_attack_id returning * into v_attack;

  update priv.srd_aoo_pending_movements p
  set pending_reactions=jsonb_set(p.pending_reactions,ARRAY[
    (select (e.ordinality-1)::text from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
     where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1)
  ],(
    select e.value||jsonb_build_object('status','damage_applied','damage_applied',v_final)
    from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
    where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1
  ),false),updated_at=now()
  where p.pending_id=v_attack.pending_id;

  return jsonb_build_object('attack_id',p_attack_id,'status','damage_applied',
    'damage_applied',v_final,'target_hp',v_new_hp,'target_max_hp',v_max_hp,
    'damage_expression',v_expr,'damage_rolls',p_damage_rolls,
    'critical',v_attack.is_critical,'critical_multiplier',v_mult,'replayed',false);
end;
$function$

```

### `public.srd_cancelar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)`

```sql
CREATE OR REPLACE FUNCTION public.srd_cancelar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$ select priv.srd_cancelar_movimento_aoo_pendente_impl(p_campaign_id,p_pending_id); $function$

```

### `public.srd_confirmar_critico_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_confirmation_d20 integer)`

```sql
CREATE OR REPLACE FUNCTION public.srd_confirmar_critico_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_confirmation_d20 integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_attack priv.srd_aoo_attacks%rowtype;
  v_bonus integer;
  v_total integer;
  v_confirmed boolean;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode confirmar o crítico.';
  end if;
  if p_confirmation_d20 not between 1 and 20 then raise exception 'Confirmação crítica exige d20 físico válido.'; end if;
  select * into v_attack from priv.srd_aoo_attacks
  where attack_id=p_attack_id and campaign_id=p_campaign_id for update;
  if not found or v_attack.created_by<>auth.uid() then raise exception 'Ataque não encontrado ou sem autorização.'; end if;
  if v_attack.status<>'awaiting_critical_confirmation' then
    if v_attack.resolution_data ? 'critical_confirmation_d20'
       and (v_attack.resolution_data->>'critical_confirmation_d20')::integer=p_confirmation_d20 then
      return jsonb_build_object('attack_id',p_attack_id,'status',v_attack.status,
        'is_critical',v_attack.is_critical,'replayed',true);
    end if;
    raise exception 'Este ataque não aguarda confirmação crítica ou recebeu outra rolagem.';
  end if;
  v_bonus:=v_attack.attack_total-v_attack.manual_d20;
  v_total:=p_confirmation_d20+v_bonus;
  v_confirmed:=p_confirmation_d20=20 or (p_confirmation_d20<>1 and v_total>=v_attack.target_ac);
  update priv.srd_aoo_attacks set
    critical_confirmation_d20=p_confirmation_d20,is_critical=v_confirmed,
    status='awaiting_damage',
    resolution_data=resolution_data||jsonb_build_object(
      'critical_confirmation_d20',p_confirmation_d20,
      'critical_confirmation_total',v_total,'critical_confirmed',v_confirmed
    )
  where attack_id=p_attack_id returning * into v_attack;
  update priv.srd_aoo_pending_movements p
  set pending_reactions=jsonb_set(p.pending_reactions,ARRAY[
    (select (e.ordinality-1)::text from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
     where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1)
  ],(
    select e.value||jsonb_build_object('status','hit_pending_damage','critical',v_confirmed)
    from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
    where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1
  ),false),updated_at=now()
  where p.pending_id=v_attack.pending_id;
  return jsonb_build_object('attack_id',p_attack_id,'status','awaiting_damage',
    'critical_confirmed',v_confirmed,'confirmation_total',v_total,
    'damage_expression',v_attack.resolution_data->>'weapon_damage');
end;
$function$

```

### `public.srd_consultar_armas_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)`

```sql
CREATE OR REPLACE FUNCTION public.srd_consultar_armas_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_reaction jsonb;
  v_profile jsonb;
  v_character_id bigint;
  v_weapons jsonb;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode consultar armas para a reação.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id;
  if not found or v_pending.status<>'waiting_reactions' then
    raise exception 'Movimento pendente não encontrado ou encerrado.';
  end if;
  select value into v_reaction
  from jsonb_array_elements(v_pending.pending_reactions)
  where value->>'reactor_token_id'=btrim(p_reactor_token_id)
    and value->>'status'='reserved'
  limit 1;
  if v_reaction is null then raise exception 'O combatente ainda não possui reação reservada.'; end if;
  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,btrim(p_reactor_token_id));
  v_character_id:=nullif(v_profile->>'character_id','')::bigint;
  if v_character_id is null then
    return jsonb_build_object('eligible_for_automated_attack',false,
      'reason','unlinked_creature_requires_gm_adjudication','weapons','[]'::jsonb);
  end if;
  select coalesce(jsonb_agg(jsonb_build_object(
    'instance_id',wi.instance_id,'equipment_id',eq.id,
    'name',eq.nome,'hand_slot',wi.hand_slot,'damage',eq.dano,
    'critical',coalesce(eq.detalhes->>'critical',eq.critico,'x2'),
    'weapon_end_main',eq.detalhes->'weapon_end_main',
    'weapon_end_off',eq.detalhes->'weapon_end_off',
    'weapon_double',coalesce((eq.detalhes->>'weapon_double')::boolean,false),
    'weapon_reach_ft',coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5),
    'weapon_threat_min_ft',coalesce(nullif(eq.detalhes->>'threat_min_ft','')::integer,5),
    'weapon_threatens_squares',coalesce((eq.detalhes->>'threatens_squares')::boolean,true),
    'damage_type',eq.tipo_dano
  ) order by case wi.hand_slot when 'main_hand' then 1 else 2 end,eq.nome),'[]'::jsonb)
  into v_weapons
  from public.srd_character_weapon_instances wi
  join public.srd_equipment eq on eq.id=wi.equipment_id
  join public.srd_character_equipment ce
    on ce.character_id=v_character_id::text and ce.equipment_id=wi.equipment_id
    and ce.equipado is true and ce.hand_slot=wi.hand_slot
  where wi.character_id=v_character_id::text and wi.equipado is true
    and wi.hand_slot in ('main_hand','off_hand')
    and coalesce(eq.detalhes->>'weapon_melee','true')<>'false'
    and coalesce((eq.detalhes->>'threatens_squares')::boolean,true) IS TRUE;
  return jsonb_build_object('eligible_for_automated_attack',jsonb_array_length(v_weapons)>0,
    'character_id',v_character_id,'weapons',v_weapons,
    'note',case when jsonb_array_length(v_weapons)=0
      then 'Sem arma corpo a corpo equipada; a resolução manual pelo Mestre ainda é necessária.'
      else null end);
end;
$function$

```

### `public.srd_consultar_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid)`

```sql
CREATE OR REPLACE FUNCTION public.srd_consultar_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare v_attack priv.srd_aoo_attacks%rowtype;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode consultar ataques de oportunidade.';
  end if;
  select * into v_attack from priv.srd_aoo_attacks
  where campaign_id=p_campaign_id and attack_id=p_attack_id;
  if not found then raise exception 'Ataque de oportunidade não encontrado.'; end if;
  return jsonb_build_object(
    'attack_id',v_attack.attack_id,'pending_id',v_attack.pending_id,
    'reaction_id',v_attack.reaction_id,
    'actor_token_id',v_attack.actor_token_id,'target_token_id',v_attack.target_token_id,
    'weapon_instance_id',v_attack.weapon_instance_id,
    'weapon_hand_slot',v_attack.weapon_hand_slot,'weapon_end',v_attack.weapon_end,
    'status',v_attack.status,'manual_d20',v_attack.manual_d20,
    'attack_total',v_attack.attack_total,'target_ac',v_attack.target_ac,
    'critical_confirmation_d20',v_attack.critical_confirmation_d20,
    'is_critical',v_attack.is_critical,'damage_rolls',v_attack.damage_rolls,
    'damage_applied',v_attack.damage_applied,
    'resolution_data',v_attack.resolution_data,
    'created_at',v_attack.created_at,'resolved_at',v_attack.resolved_at,
    'damage_applied_at',v_attack.damage_applied_at
  );
end;
$function$

```

### `public.srd_consultar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)`

```sql
CREATE OR REPLACE FUNCTION public.srd_consultar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare v_pending priv.srd_aoo_pending_movements%rowtype;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode consultar movimentos aguardando ataques de oportunidade.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id;
  if not found then raise exception 'Movimento pendente não encontrado.'; end if;
  return jsonb_build_object(
    'pending_id',v_pending.pending_id,'status',v_pending.status,
    'mover_token_id',v_pending.mover_token_id,
    'movement_controller',v_pending.movement_controller,
    'origin',jsonb_build_array(v_pending.origin_x,v_pending.origin_y),
    'destination',jsonb_build_array(v_pending.destination_x,v_pending.destination_y),
    'round',v_pending.combat_round,'current_turn',v_pending.current_turn,
    'turn_actor_id',v_pending.turn_actor_id,
    'threats',v_pending.threats,'pending_reactions',v_pending.pending_reactions,
    'created_at',v_pending.created_at
  );
end;
$function$

```

### `public.srd_encerrar_reacao_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_cancel_attack boolean)`

```sql
CREATE OR REPLACE FUNCTION public.srd_encerrar_reacao_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_cancel_attack boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$ select priv.srd_encerrar_reacao_aoo_pendente_impl(p_campaign_id,p_pending_id,p_reactor_token_id,p_cancel_attack); $function$

```

### `public.srd_finalizar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)`

```sql
CREATE OR REPLACE FUNCTION public.srd_finalizar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_preview jsonb;
  v_remaining integer;
  v_user uuid:=auth.uid();
begin
  if v_user is null then raise exception 'É necessário estar autenticado.'; end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id for update;
  if not found or v_pending.status<>'waiting_reactions' then raise exception 'Movimento pendente não está ativo.'; end if;

  if public.my_role(p_campaign_id) is distinct from 'GM'
     and (v_pending.movement_controller='gm' or v_user<>v_pending.created_by) then
    raise exception 'Somente o Mestre ou o jogador que solicitou o movimento pode concluí-lo.';
  end if;

  if exists(
    select 1 from jsonb_array_elements(v_pending.pending_reactions) r
    where coalesce(r->>'status','') not in ('ineligible','skipped','miss','damage_applied')
  ) then
    raise exception 'Ainda existem reações de oportunidade sem estado terminal válido.';
  end if;

  if exists(
    select 1 from priv.srd_aoo_attacks a
    where a.pending_id=p_pending_id and a.campaign_id=p_campaign_id
      and a.status not in ('miss','damage_applied','cancelled')
  ) then
    raise exception 'Ainda existe um ataque de oportunidade sem resolução completa.';
  end if;

  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
     or coalesce(v_campaign.combat_data->>'active','false')<>'true'
     or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
     or coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn then
    raise exception 'O combate avançou; solicite uma nova movimentação.';
  end if;
  if not exists(select 1 from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
    where (t->>'id'=v_pending.mover_token_id or t->>'key'=v_pending.mover_token_id)
      and coalesce(t->>'gridX','')=v_pending.origin_x::text
      and coalesce(t->>'gridY','')=v_pending.origin_y::text) then
    raise exception 'A posição original do token mudou; movimento não pode ser concluído.';
  end if;

  perform set_config('app.srd_aoo_pending_commit',p_pending_id::text,true);
  if v_pending.movement_controller='player' and v_user=v_pending.created_by
     and public.my_role(p_campaign_id) is distinct from 'GM' then
    v_preview:=public.mover_token_player_cba(
      p_campaign_id,v_pending.mover_token_id,v_pending.destination_x,v_pending.destination_y);
  else
    v_preview:=public.mover_token_gm_cba_srd(
      p_campaign_id,v_pending.mover_token_id,v_pending.destination_x,v_pending.destination_y);
  end if;

  update priv.srd_aoo_pending_movements set status='committed',
    committed_at=now(),updated_at=now() where pending_id=p_pending_id;
  perform set_config('app.srd_aoo_pending_commit','',true);
  return jsonb_build_object('committed',true,'pending_id',p_pending_id,
    'mover_token_id',v_pending.mover_token_id,
    'destination',jsonb_build_array(v_pending.destination_x,v_pending.destination_y),
    'movement_result',v_preview);
end;
$function$

```

### `public.srd_iniciar_ataque_oportunidade_desarmado_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid)`

```sql
CREATE OR REPLACE FUNCTION public.srd_iniciar_ataque_oportunidade_desarmado_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_reaction jsonb;
  v_index bigint;
  v_ledger priv.srd_aoo_reaction_ledger%rowtype;
  v_profile jsonb;
  v_token jsonb;
  v_target jsonb;
  v_count integer;
  v_character_id bigint;
  v_sheet public.srd_character_sheets%rowtype;
  v_class public.srd_classes%rowtype;
  v_race public.srd_races%rowtype;
  v_level integer;
  v_bab integer:=0;
  v_str integer;
  v_str_mod integer;
  v_size text;
  v_size_mod integer:=0;
  v_damage_dice text:='1d3';
  v_damage_expr text;
  v_attack_bonus integer;
  v_racial_bonus integer:=0;
  v_target_traits text;
  v_reach integer;
  v_steps integer;
  v_step integer;
  v_tx integer;
  v_ty integer;
  v_dx integer;
  v_dy integer;
  v_distance integer;
  v_attack_id uuid;
  v_has_improved_unarmed boolean:=false;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode iniciar um ataque desarmado de oportunidade.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id for update;
  if not found or v_pending.status<>'waiting_reactions' then raise exception 'Movimento não está aguardando reações.'; end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
    or coalesce(v_campaign.combat_data->>'active','false')<>'true'
    or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
    or coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn then
    raise exception 'O combate ou turno mudou desde a solicitação do movimento.';
  end if;
  select ordinality,value into v_index,v_reaction
  from jsonb_array_elements(v_pending.pending_reactions) with ordinality
  where value->>'reactor_token_id'=btrim(p_reactor_token_id) limit 1;
  if v_reaction is null or v_reaction->>'status'<>'reserved'
    or v_reaction->>'reservation_id' is distinct from p_reaction_id::text then
    raise exception 'O combatente não possui reação reservada para este movimento.';
  end if;
  select * into v_ledger from priv.srd_aoo_reaction_ledger
  where reaction_id=p_reaction_id and campaign_id=p_campaign_id
    and actor_token_id=btrim(p_reactor_token_id) and combat_round=v_pending.combat_round for update;
  if not found then raise exception 'Reserva de reação não encontrada.'; end if;

  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,btrim(p_reactor_token_id));
  v_character_id:=nullif(v_profile->>'character_id','')::bigint;
  if v_character_id is null then raise exception 'Ataque desarmado automatizado exige ficha SRD vinculada.'; end if;
  select * into v_sheet from public.srd_character_sheets where character_id=v_character_id;
  if not found then raise exception 'Ficha SRD do combatente não encontrada.'; end if;
  select * into v_class from public.srd_classes where id=v_sheet.classe_id;
  select * into v_race from public.srd_races where id=v_sheet.raca_id;
  if not found then raise exception 'Raça do combatente não encontrada.'; end if;

  SELECT coalesce(v_class.class_key='monk',false) OR EXISTS (
    SELECT 1
    FROM jsonb_array_elements(
      CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::jsonb END
    ) feat
    WHERE lower(concat_ws(' ',feat->>'id',feat->>'nome',feat->>'name')) ~
      '(ataque_desarmado_aprimorado|srd35_feat_improved_unarmed_strike|improved_unarmed_strike|ataque desarmado aprimorado|improved unarmed strike)'
  ) INTO v_has_improved_unarmed;

  IF NOT v_has_improved_unarmed THEN
    RAISE EXCEPTION 'Ataque de Oportunidade desarmado exige Ataque Desarmado Aprimorado ou níveis de Monge.';
  END IF;
  if priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'no_actions')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'helpless')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'stunned')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'unconscious')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dying')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'stable')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dead')
    or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id::text,'no_actions')
    or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id::text,'helpless')
    or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id::text,'stunned')
    or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id::text,'unconscious')
    or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id::text,'dying')
    or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id::text,'stable')
    or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id::text,'dead') then
    raise exception 'A condição atual impede o ataque desarmado.';
  end if;

  v_level:=greatest(1,coalesce(v_sheet.nivel,1));
  select coalesce(sum(case lower(coalesce(cl.bab_progression,''))
    when 'good' then lv.class_level when 'bom' then lv.class_level
    when 'average' then floor(3*lv.class_level/4.0)::integer
    when 'medium' then floor(3*lv.class_level/4.0)::integer
    when 'medio' then floor(3*lv.class_level/4.0)::integer
    when 'poor' then floor(lv.class_level/2.0)::integer
    when 'ruim' then floor(lv.class_level/2.0)::integer else 0 end),0)::integer
  into v_bab from public.srd_character_class_levels lv
  join public.srd_classes cl on cl.id=lv.class_id where lv.character_id=v_character_id;
  if not exists(select 1 from public.srd_character_class_levels lv where lv.character_id=v_character_id) then
    v_bab:=case lower(coalesce(v_class.bab_progression,''))
      when 'good' then v_level when 'bom' then v_level
      when 'average' then floor(3*v_level/4.0)::integer
      when 'medium' then floor(3*v_level/4.0)::integer
      when 'medio' then floor(3*v_level/4.0)::integer
      when 'poor' then floor(v_level/2.0)::integer
      when 'ruim' then floor(v_level/2.0)::integer else 0 end;
  end if;

  v_str:=coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10)
    +priv.srd_effective_modifier(p_campaign_id,'token',btrim(p_reactor_token_id),'strength');
  v_str_mod:=floor((v_str-10)::numeric/2)::integer;
  v_size:=lower(public.srd35_normalizar_parametro_talento(coalesce(v_race.tamanho,'medio')));
  v_size_mod:=case when v_size like 'fine%' or v_size like 'minusculo%' then 8
    when v_size like 'diminutive%' or v_size like 'diminuto%' then 4
    when v_size like 'tiny%' or v_size like 'miudo%' then 2
    when v_size like 'small%' or v_size like 'pequeno%' then 1
    when v_size like 'large%' or v_size like 'grande%' then -1
    when v_size like 'huge%' or v_size like 'enorme%' then -2
    when v_size like 'gargantuan%' or v_size like 'imenso%' then -4
    when v_size like 'colossal%' then -8 else 0 end;
  v_damage_dice:=case when v_size like 'fine%' or v_size like 'diminutive%' or v_size like 'tiny%'
      or v_size like 'minusculo%' or v_size like 'diminuto%' or v_size like 'miudo%' then '1d2'
    when v_size like 'small%' or v_size like 'pequeno%' then '1d2'
    when v_size like 'large%' or v_size like 'grande%' then '1d4'
    when v_size like 'huge%' or v_size like 'enorme%' then '1d6'
    when v_size like 'gargantuan%' or v_size like 'imenso%' then '1d8'
    when v_size like 'colossal%' then '2d6' else '1d3' end;
  v_damage_expr:=v_damage_dice||case when v_str_mod>0 then '+'||v_str_mod::text when v_str_mod<0 then v_str_mod::text else '' end;
  select count(*)::integer,(array_agg(t))[1] into v_count,v_token
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=btrim(p_reactor_token_id) or t->>'key'=btrim(p_reactor_token_id);
  if v_count<>1 then raise exception 'Token atacante ausente ou duplicado.'; end if;
  select count(*)::integer,(array_agg(t))[1] into v_count,v_target
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=v_pending.mover_token_id or t->>'key'=v_pending.mover_token_id;
  if v_count<>1 then raise exception 'Alvo do movimento ausente ou duplicado.'; end if;
  v_target_traits:=lower(concat_ws(' ',v_target->>'nome',v_target->>'detalhe',
    v_target->'monsterStats'->>'tipo',v_target->'monsterStats'->>'subtipo',
    v_target->'monsterStats'->>'type',v_target->'monsterStats'->>'creature_type',
    (SELECT lower(sh.raca_id::text) FROM public.srd_character_sheets sh
      WHERE sh.character_id::text=CASE
        WHEN v_target->>'tipo'='player' THEN v_target->>'id'
        WHEN v_target->>'tipo'='npc' THEN v_target->>'sourceCharacterId'
        ELSE NULL END LIMIT 1)));
  if v_race.id='anao' and v_target_traits ~ '(^|[^a-z])(orc|goblin|hobgoblin|bugbear|goblinoid(e)?)([^a-z]|$)' then v_racial_bonus:=1; end if;
  v_attack_bonus:=v_bab+v_str_mod+v_size_mod+v_racial_bonus;

  v_steps:=greatest(abs(v_pending.destination_x-v_pending.origin_x),abs(v_pending.destination_y-v_pending.origin_y));
  v_step:=greatest(0,coalesce(nullif(v_reaction->'threat'->>'last_threatened_step','')::integer,0));
  v_tx:=case when v_steps=0 then v_pending.origin_x else round(v_pending.origin_x+(v_pending.destination_x-v_pending.origin_x)::numeric*v_step/v_steps)::integer end;
  v_ty:=case when v_steps=0 then v_pending.origin_y else round(v_pending.origin_y+(v_pending.destination_y-v_pending.origin_y)::numeric*v_step/v_steps)::integer end;
  if coalesce(v_token->>'gridX','') !~ '^[0-9]{1,3}$' or coalesce(v_token->>'gridY','') !~ '^[0-9]{1,3}$' then
    raise exception 'Posição do atacante inválida.';
  end if;
  v_distance:=priv.srd_grid_footprint_distance_ft(
    (v_token->>'gridX')::integer,(v_token->>'gridY')::integer,
    priv.srd_token_grid_footprint(p_campaign_id,p_reactor_token_id),
    v_tx,v_ty,priv.srd_token_grid_footprint(p_campaign_id,v_pending.mover_token_id));
  v_reach:=coalesce(nullif(v_token->>'melee_reach_ft','')::integer,5);
  if v_distance>v_reach then raise exception 'O alvo está fora do alcance do ataque desarmado.'; end if;

  insert into priv.srd_aoo_attacks(campaign_id,pending_id,reaction_id,actor_token_id,target_token_id,
    actor_character_id,weapon_instance_id,weapon_hand_slot,created_by,resolution_data)
  values(p_campaign_id,p_pending_id,p_reaction_id,btrim(p_reactor_token_id),v_pending.mover_token_id,
    null,null,'natural',auth.uid(),jsonb_build_object(
      'weapon_name','Ataque desarmado','weapon_damage',v_damage_expr,'damage_expression',v_damage_expr,
      'monster_attack_bonus',v_attack_bonus,'critical_threat_minimum',20,'critical_multiplier',2,
      'damage_type','bludgeoning','source_character_id',v_character_id,
      'base_attack_bonus',v_bab,'strength_modifier',v_str_mod,'size_modifier',v_size_mod,
      'racial_bonus',v_racial_bonus,'trigger_x',v_tx,'trigger_y',v_ty
    )) returning attack_id into v_attack_id;
  update priv.srd_aoo_pending_movements
  set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_index-1)::text],
    v_reaction||jsonb_build_object('status','attack_started','attack_id',v_attack_id),false),updated_at=now()
  where pending_id=p_pending_id;
  return jsonb_build_object('started',true,'attack_id',v_attack_id,'weapon_name','Ataque desarmado',
    'damage_expression',v_damage_expr,'attack_bonus',v_attack_bonus,'awaiting_manual_d20',true,'action_economy_cost',0);
end;
$function$

```

### `public.srd_iniciar_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid)`

```sql
CREATE OR REPLACE FUNCTION public.srd_iniciar_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_reaction jsonb;
  v_index bigint;
  v_ledger priv.srd_aoo_reaction_ledger%rowtype;
  v_profile jsonb;
  v_token jsonb;
  v_target jsonb;
  v_count integer;
  v_attack_text text;
  v_match text[];
  v_bonus integer;
  v_damage_expr text;
  v_damage_type text;
  v_reach integer;
  v_steps integer;
  v_step integer;
  v_tx integer;
  v_ty integer;
  v_dx integer;
  v_dy integer;
  v_distance integer;
  v_attack_id uuid;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode iniciar um ataque natural de oportunidade.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id for update;
  if not found or v_pending.status<>'waiting_reactions' then raise exception 'Movimento não está aguardando reações.'; end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
    or coalesce(v_campaign.combat_data->>'active','false')<>'true'
    or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
    or coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn then
    raise exception 'O combate ou turno mudou desde a solicitação do movimento.';
  end if;
  select ordinality,value into v_index,v_reaction
  from jsonb_array_elements(v_pending.pending_reactions) with ordinality
  where value->>'reactor_token_id'=btrim(p_reactor_token_id) limit 1;
  if v_reaction is null or v_reaction->>'status'<>'reserved'
    or v_reaction->>'reservation_id' is distinct from p_reaction_id::text then
    raise exception 'O combatente não possui reação reservada para este movimento.';
  end if;
  select * into v_ledger from priv.srd_aoo_reaction_ledger
  where reaction_id=p_reaction_id and campaign_id=p_campaign_id
    and actor_token_id=btrim(p_reactor_token_id) and combat_round=v_pending.combat_round for update;
  if not found then raise exception 'Reserva de reação não encontrada.'; end if;

  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,btrim(p_reactor_token_id));
  if nullif(v_profile->>'character_id','') is not null then
    raise exception 'Este combatente possui ficha vinculada; use o fluxo de arma equipada.';
  end if;
  select count(*)::integer,(array_agg(t))[1] into v_count,v_token
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=btrim(p_reactor_token_id) or t->>'key'=btrim(p_reactor_token_id);
  if v_count<>1 or v_token->>'tipo' not in ('monstro','npc') then
    raise exception 'O fluxo natural é exclusivo de NPCs e monstros sem ficha SRD vinculada.';
  end if;
  if priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'no_actions')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'helpless')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'stunned')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'unconscious')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dying')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'stable')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dead') then
    raise exception 'A condição atual impede o ataque de oportunidade.';
  end if;
  v_attack_text:=coalesce(nullif(v_token->'monsterStats'->>'ataques',''),
    nullif(v_token->'monsterStats'->'dados_tecnicos'->'statblock'->>'attack',''),
    nullif(v_token->'monsterStats'->>'full_attack',''),
    nullif(v_token->'monsterStats'->'dados_tecnicos'->>'full_attack',''));
  v_match:=regexp_match(coalesce(v_attack_text,''),
    '([+-]?[0-9]+)[[:space:]]+melee[[:space:]]+\(([0-9]+d[0-9]+)([+-][0-9]+)?\)','i');
  if v_match is null then raise exception 'O bloco de estatísticas não contém ataque corpo a corpo legível.'; end if;
  v_bonus:=v_match[1]::integer;
  v_damage_expr:=v_match[2]||coalesce(v_match[3],'');
  v_damage_type:=lower(coalesce(v_token->'monsterStats'->>'tipo_dano','physical'));
  v_match:=regexp_match(coalesce(v_token->>'melee_reach_ft',v_token->'monsterStats'->>'espaco_alcance',
    v_token->'monsterStats'->'dados_tecnicos'->'statblock'->>'space_reach',''),'([0-9]+)[[:space:]]*ft\.?/[[:space:]]*([0-9]+)','i');
  v_reach:=coalesce(nullif(v_token->>'melee_reach_ft','')::integer,
    case when v_match is not null then v_match[2]::integer end,5);

  v_steps:=greatest(abs(v_pending.destination_x-v_pending.origin_x),abs(v_pending.destination_y-v_pending.origin_y));
  v_step:=greatest(0,coalesce(nullif(v_reaction->'threat'->>'last_threatened_step','')::integer,0));
  v_tx:=case when v_steps=0 then v_pending.origin_x else round(v_pending.origin_x+(v_pending.destination_x-v_pending.origin_x)::numeric*v_step/v_steps)::integer end;
  v_ty:=case when v_steps=0 then v_pending.origin_y else round(v_pending.origin_y+(v_pending.destination_y-v_pending.origin_y)::numeric*v_step/v_steps)::integer end;
  select count(*)::integer,(array_agg(t))[1] into v_count,v_target
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=v_pending.mover_token_id or t->>'key'=v_pending.mover_token_id;
  if v_count<>1 then raise exception 'Alvo do movimento não existe ou está duplicado.'; end if;
  if coalesce(v_token->>'gridX','') !~ '^[0-9]{1,3}$' or coalesce(v_token->>'gridY','') !~ '^[0-9]{1,3}$' then
    raise exception 'Posição do atacante inválida.';
  end if;
  v_distance:=priv.srd_grid_footprint_distance_ft(
    (v_token->>'gridX')::integer,(v_token->>'gridY')::integer,
    priv.srd_token_grid_footprint(p_campaign_id,p_reactor_token_id),
    v_tx,v_ty,priv.srd_token_grid_footprint(p_campaign_id,v_pending.mover_token_id));
  if v_distance>v_reach then raise exception 'O alvo está fora do alcance do ataque natural.'; end if;

  insert into priv.srd_aoo_attacks(campaign_id,pending_id,reaction_id,actor_token_id,target_token_id,
    actor_character_id,weapon_instance_id,weapon_hand_slot,created_by,resolution_data)
  values(p_campaign_id,p_pending_id,p_reaction_id,btrim(p_reactor_token_id),v_pending.mover_token_id,
    null,null,'natural',auth.uid(),jsonb_build_object(
      'weapon_name','Ataque natural','weapon_damage',v_damage_expr,'damage_expression',v_damage_expr,
      'monster_attack_bonus',v_bonus,'critical_threat_minimum',20,'critical_multiplier',2,
      'damage_type',v_damage_type,'source_attack_text',v_attack_text,'trigger_x',v_tx,'trigger_y',v_ty
    )) returning attack_id into v_attack_id;
  update priv.srd_aoo_pending_movements
  set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_index-1)::text],
    v_reaction||jsonb_build_object('status','attack_started','attack_id',v_attack_id),false),updated_at=now()
  where pending_id=p_pending_id;
  return jsonb_build_object('started',true,'attack_id',v_attack_id,'weapon_name','Ataque natural',
    'damage_expression',v_damage_expr,'attack_bonus',v_bonus,'awaiting_manual_d20',true,'action_economy_cost',0);
end;
$function$

```

### `public.srd_iniciar_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid, p_natural_attack_index integer)`

```sql
CREATE OR REPLACE FUNCTION public.srd_iniciar_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid, p_natural_attack_index integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_catalog jsonb; v_selected jsonb; v_started jsonb; v_attack_id uuid;
  v_damage_type text; v_attack_text text;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode iniciar um ataque natural de oportunidade.';
  end if;
  if p_natural_attack_index is null or p_natural_attack_index<1 then
    raise exception 'Selecione um grupo de ataque natural válido.';
  end if;
  v_catalog:=public.srd_listar_ataques_naturais_oportunidade_srd(p_campaign_id,btrim(p_reactor_token_id));
  if coalesce((v_catalog->>'available')::boolean,false) is not true then
    raise exception 'O token não possui ataques naturais catalogados: %',
      coalesce(v_catalog->>'reason','sem ataque natural válido');
  end if;
  select a.value into v_selected from jsonb_array_elements(coalesce(v_catalog->'attacks','[]'::jsonb)) a(value)
  where (a.value->>'index')::integer=p_natural_attack_index
    and coalesce((a.value->>'parse_supported')::boolean,false)
    and coalesce((a.value->>'is_natural')::boolean,false) limit 1;
  if v_selected is null then raise exception 'O grupo selecionado não existe ou não é um ataque natural suportado.'; end if;
  v_started:=public.srd_iniciar_ataque_oportunidade_monstro_srd(
    p_campaign_id,p_pending_id,p_reactor_token_id,p_reaction_id);
  v_attack_id:=nullif(v_started->>'attack_id','')::uuid;
  if v_attack_id is null then raise exception 'O fluxo legado não retornou um ataque válido.'; end if;
  v_attack_text:=v_catalog->>'source_text';
  select lower(coalesce(t->'monsterStats'->>'tipo_dano','physical')) into v_damage_type
  from public.campaigns c,lateral jsonb_array_elements(coalesce(c.cba_data->'tokens','[]'::jsonb)) t
  where c.id=p_campaign_id and (t->>'id'=btrim(p_reactor_token_id) or t->>'key'=btrim(p_reactor_token_id))
  limit 1;
  update priv.srd_aoo_attacks
  set resolution_data=resolution_data||jsonb_build_object(
    'weapon_name',v_selected->>'name','natural_attack_index',p_natural_attack_index,
    'natural_attack_count',coalesce(nullif(v_selected->>'count','')::integer,1),
    'weapon_damage',v_selected->>'damage_expression','damage_expression',v_selected->>'damage_expression',
    'monster_attack_bonus',coalesce(nullif(v_selected->>'attack_bonus','')::integer,0),
    'natural_attack_bonus_progression',v_selected->>'attack_bonus_progression',
    'natural_attack_group_text',v_selected->>'attack_group_text',
    'natural_attack_additional_effect',v_selected->>'additional_effect',
    'natural_attack_source_text',v_attack_text,'natural_attack_selected',true,
    'damage_type',coalesce(v_damage_type,'physical'),
    'critical_threat_minimum',coalesce(nullif(v_selected->>'critical_threat_minimum','')::integer,20),
    'critical_multiplier',coalesce(nullif(v_selected->>'critical_multiplier','')::integer,2)
  )
  where attack_id=v_attack_id and campaign_id=p_campaign_id and created_by=auth.uid()
    and status='awaiting_attack_roll';
  if not found then raise exception 'Ataque não está mais aguardando rolagem manual.'; end if;
  return v_started||jsonb_build_object(
    'attack_id',v_attack_id,'weapon_name',v_selected->>'name',
    'natural_attack_index',p_natural_attack_index,
    'natural_attack_count',coalesce(nullif(v_selected->>'count','')::integer,1),
    'damage_expression',v_selected->>'damage_expression',
    'attack_bonus',coalesce(nullif(v_selected->>'attack_bonus','')::integer,0),
    'critical_threat_minimum',coalesce(nullif(v_selected->>'critical_threat_minimum','')::integer,20),
    'critical_multiplier',coalesce(nullif(v_selected->>'critical_multiplier','')::integer,2),
    'additional_effect',v_selected->>'additional_effect',
    'selected_natural_attack',v_selected,'awaiting_manual_d20',true
  );
end;
$function$

```

### `public.srd_iniciar_ataque_oportunidade_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text)`

```sql
CREATE OR REPLACE FUNCTION public.srd_iniciar_ataque_oportunidade_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_reaction jsonb;
  v_reaction_index bigint;
  v_ledger priv.srd_aoo_reaction_ledger%rowtype;
  v_token jsonb;
  v_token_count integer;
  v_profile jsonb;
  v_character_id bigint;
  v_sheet public.srd_character_sheets%rowtype;
  v_instance public.srd_character_weapon_instances%rowtype;
  v_weapon public.srd_equipment%rowtype;
  v_attack_id uuid;
  v_reach integer;
  v_steps integer;
  v_step integer;
  v_trigger_x integer;
  v_trigger_y integer;
  v_dx integer;
  v_dy integer;
  v_distance integer;
  v_size_rank integer:=4;
  v_base_reach integer:=5;
  v_min_reach integer:=5;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode iniciar um ataque de oportunidade.';
  end if;
  if p_weapon_hand_slot not in ('main_hand','off_hand') then
    raise exception 'Mão da arma inválida.';
  end if;
  if p_weapon_end is not null and p_weapon_end not in ('main','off') then
    raise exception 'Extremidade da arma inválida.';
  end if;

  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id for update;
  if not found or v_pending.status<>'waiting_reactions' then
    raise exception 'Movimento não está aguardando reação.';
  end if;

  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
    or coalesce(v_campaign.combat_data->>'active','false')<>'true'
    or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
    or coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn then
    raise exception 'O combate ou turno mudou desde a solicitação do movimento.';
  end if;

  select ordinality,value into v_reaction_index,v_reaction
  from jsonb_array_elements(v_pending.pending_reactions) with ordinality
  where coalesce(value->>'reactor_token_id','')=btrim(p_reactor_token_id)
  limit 1;
  if v_reaction is null or v_reaction->>'status'<>'reserved'
     or v_reaction->>'reservation_id' is distinct from p_reaction_id::text then
    raise exception 'O combatente não possui reação reservada para este movimento.';
  end if;

  select * into v_ledger from priv.srd_aoo_reaction_ledger
  where reaction_id=p_reaction_id and campaign_id=p_campaign_id
    and actor_token_id=btrim(p_reactor_token_id)
    and combat_round=v_pending.combat_round for update;
  if not found then raise exception 'Reserva de reação não encontrada no ledger.'; end if;

  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,btrim(p_reactor_token_id));
  v_character_id:=nullif(v_profile->>'character_id','')::bigint;
  v_size_rank:=coalesce(nullif(v_profile->>'size_rank','')::integer,4);
  v_base_reach:=CASE
    WHEN v_size_rank>=8 THEN 30
    WHEN v_size_rank=7 THEN 20
    WHEN v_size_rank=6 THEN 15
    WHEN v_size_rank=5 THEN 10
    ELSE 5
  END;
  if v_character_id is null then
    raise exception 'Ataque de oportunidade automatizado requer ficha SRD vinculada. Criaturas sem ficha vinculada ainda precisam de resolução manual do Mestre.';
  end if;
  select * into v_sheet from public.srd_character_sheets
  where character_id=v_character_id;
  if not found then raise exception 'Ficha SRD do combatente não encontrada.'; end if;

  if priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'no_actions')
     or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'helpless')
     or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'stunned')
     or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'unconscious')
     or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dying')
     or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'stable')
     or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dead') then
    raise exception 'O combatente não pode realizar ataques de oportunidade devido à sua condição.';
  end if;

  select count(*)::integer,(array_agg(t))[1] into v_token_count,v_token
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=btrim(p_reactor_token_id) or t->>'key'=btrim(p_reactor_token_id);
  if v_token_count<>1 then raise exception 'Token reator ausente ou duplicado.'; end if;

  select * into v_instance from public.srd_character_weapon_instances
  where instance_id=p_weapon_instance_id and character_id=v_character_id::text
    and equipado is true and hand_slot=p_weapon_hand_slot for share;
  if not found then raise exception 'A arma não está equipada na mão informada.'; end if;
  if not exists(select 1 from public.srd_character_equipment ce
    where ce.character_id=v_character_id::text and ce.equipment_id=v_instance.equipment_id
      and ce.equipado is true and ce.hand_slot=p_weapon_hand_slot) then
    raise exception 'A instância e o inventário da arma estão inconsistentes.';
  end if;
  select * into v_weapon from public.srd_equipment where id=v_instance.equipment_id;
  if not found or coalesce(v_weapon.detalhes->>'weapon_melee','true')='false' then
    raise exception 'A arma selecionada não é uma arma corpo a corpo válida.';
  end if;
  if coalesce((v_weapon.detalhes->>'weapon_double')::boolean,false) and p_weapon_end is null then
    raise exception 'Selecione a extremidade da arma dupla.';
  end if;

  v_steps:=greatest(abs(v_pending.destination_x-v_pending.origin_x),
                    abs(v_pending.destination_y-v_pending.origin_y));
  v_step:=greatest(0,coalesce(nullif(v_reaction->'threat'->>'last_threatened_step','')::integer,0));
  v_trigger_x:=case when v_steps=0 then v_pending.origin_x
    else round(v_pending.origin_x+(v_pending.destination_x-v_pending.origin_x)::numeric*v_step/v_steps)::integer end;
  v_trigger_y:=case when v_steps=0 then v_pending.origin_y
    else round(v_pending.origin_y+(v_pending.destination_y-v_pending.origin_y)::numeric*v_step/v_steps)::integer end;
  v_distance:=priv.srd_grid_footprint_distance_ft(
    (v_token->>'gridX')::integer,(v_token->>'gridY')::integer,
    priv.srd_token_grid_footprint(p_campaign_id,p_reactor_token_id),
    v_trigger_x,v_trigger_y,priv.srd_token_grid_footprint(p_campaign_id,v_pending.mover_token_id));

  IF coalesce(nullif(v_weapon.detalhes->>'reach_ft','')::integer,5)>5 AND v_size_rank>4 THEN
    v_min_reach:=v_base_reach+5;
    v_reach:=coalesce(nullif(v_weapon.detalhes->>'reach_ft','')::integer,5)*greatest(1,v_base_reach/5);
  ELSE
    v_min_reach:=greatest(5,coalesce(nullif(v_weapon.detalhes->>'threat_min_ft','')::integer,5));
    v_reach:=greatest(v_base_reach,coalesce(nullif(v_weapon.detalhes->>'reach_ft','')::integer,
      nullif(v_token->>'melee_reach_ft','')::integer,5));
  END IF;
  if coalesce((v_weapon.detalhes->>'threatens_squares')::boolean,true) IS NOT TRUE THEN
    raise exception 'A arma selecionada não ameaça quadrados e não pode realizar ataques de oportunidade.';
  end if;
  if v_distance < v_min_reach
     OR v_distance>v_reach then
    raise exception 'O alvo não está em um quadrado ameaçado pela arma selecionada.';
  end if;

  insert into priv.srd_aoo_attacks(
    campaign_id,pending_id,reaction_id,actor_token_id,target_token_id,
    actor_character_id,weapon_instance_id,weapon_hand_slot,weapon_end,created_by,
    resolution_data
  ) values (
    p_campaign_id,p_pending_id,p_reaction_id,btrim(p_reactor_token_id),
    v_pending.mover_token_id,v_character_id,p_weapon_instance_id,
    p_weapon_hand_slot,p_weapon_end,auth.uid(),
    jsonb_build_object('trigger_x',v_trigger_x,'trigger_y',v_trigger_y,
      'weapon_name',v_weapon.nome,'weapon_damage',v_weapon.dano,
      'weapon_critical',coalesce(v_weapon.detalhes->>'critical',v_weapon.critico,'x2'),
      'weapon_details',v_weapon.detalhes)
  ) returning attack_id into v_attack_id;

  update priv.srd_aoo_pending_movements
  set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_reaction_index-1)::text],
    v_reaction||jsonb_build_object('status','attack_started','attack_id',v_attack_id),
    false),updated_at=now()
  where pending_id=p_pending_id;

  return jsonb_build_object('started',true,'attack_id',v_attack_id,
    'pending_id',p_pending_id,'reactor_token_id',p_reactor_token_id,
    'target_token_id',v_pending.mover_token_id,'weapon_name',v_weapon.nome,
    'weapon_damage',v_weapon.dano,'trigger_position',jsonb_build_array(v_trigger_x,v_trigger_y),
    'awaiting_manual_d20',true,'action_economy_cost',0);
end;
$function$

```

### `public.srd_iniciar_derrubar_com_aoo_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_defender_firm_ground boolean, p_trip_using_weapon boolean)`

```sql
CREATE OR REPLACE FUNCTION public.srd_iniciar_derrubar_com_aoo_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_defender_firm_ground boolean DEFAULT false, p_trip_using_weapon boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
  SELECT priv.srd_iniciar_derrubar_com_aoo_srd(
    p_campaign_id,p_attacker_token_id,p_defender_token_id,
    p_defender_firm_ground,p_trip_using_weapon
  );
$function$

```

### `public.srd_listar_ataques_naturais_oportunidade_srd(p_campaign_id bigint, p_reactor_token_id text)`

```sql
CREATE OR REPLACE FUNCTION public.srd_listar_ataques_naturais_oportunidade_srd(p_campaign_id bigint, p_reactor_token_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_campaign public.campaigns%rowtype;
  v_token jsonb;
  v_count integer;
  v_profile jsonb;
  v_attack_text text;
  v_all jsonb;
  v_attacks jsonb;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode consultar ataques naturais de oportunidade.';
  end if;
  if nullif(btrim(p_reactor_token_id),'') is null then raise exception 'Token atacante obrigatório.'; end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id;
  if not found then raise exception 'Campanha não encontrada.'; end if;
  select count(*)::integer,(array_agg(t))[1] into v_count,v_token
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=btrim(p_reactor_token_id) or t->>'key'=btrim(p_reactor_token_id);
  if v_count<>1 then raise exception 'Token ausente ou duplicado na cena.'; end if;
  if v_token->>'tipo' not in ('npc','monstro') then raise exception 'A consulta é destinada a NPCs e monstros.'; end if;
  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,btrim(p_reactor_token_id));
  if nullif(v_profile->>'character_id','') is not null then
    return jsonb_build_object('available',false,'reason','linked_character_requires_character_attack_catalog',
      'source_character_id',v_profile->>'character_id','attacks','[]'::jsonb);
  end if;
  v_attack_text:=coalesce(
    nullif(v_token->'monsterStats'->>'ataques',''),
    nullif(v_token->'monsterStats'->'dados_tecnicos'->'statblock'->>'full_attack',''),
    nullif(v_token->'monsterStats'->>'full_attack',''),
    nullif(v_token->'monsterStats'->'dados_tecnicos'->'statblock'->>'attack',''),
    nullif(v_token->'monsterStats'->>'attack',''));
  v_all:=priv.srd_parse_natural_attack_list(v_attack_text);
  select coalesce(jsonb_agg(a.value order by (a.value->>'index')::integer),'[]'::jsonb)
    into v_attacks from jsonb_array_elements(v_all) a(value)
    where coalesce((a.value->>'is_natural')::boolean,false);
  return jsonb_build_object('available',jsonb_array_length(v_attacks)>0,
    'token_id',btrim(p_reactor_token_id),'source','monsterStats','source_text',v_attack_text,
    'attacks',v_attacks,'selection_required',jsonb_array_length(v_attacks)>1);
end;
$function$

```

### `public.srd_listar_movimentos_aoo_pendentes_srd(p_campaign_id bigint)`

```sql
CREATE OR REPLACE FUNCTION public.srd_listar_movimentos_aoo_pendentes_srd(p_campaign_id bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare v_rows jsonb;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode listar movimentos aguardando ataques de oportunidade.';
  end if;
  select coalesce(jsonb_agg(jsonb_build_object(
    'pending_id',p.pending_id,'mover_token_id',p.mover_token_id,
    'movement_controller',p.movement_controller,
    'origin',jsonb_build_array(p.origin_x,p.origin_y),
    'destination',jsonb_build_array(p.destination_x,p.destination_y),
    'round',p.combat_round,'current_turn',p.current_turn,
    'status',p.status,'threats',p.threats,
    'pending_reactions',p.pending_reactions,
    'created_at',p.created_at
  ) order by p.created_at),'[]'::jsonb)
  into v_rows
  from priv.srd_aoo_pending_movements p
  where p.campaign_id=p_campaign_id
    and p.status in ('waiting_reactions','ready_to_commit');
  return jsonb_build_object('pending_movements',v_rows);
end;
$function$

```

### `public.srd_registrar_ocultacao_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_manual_d100 integer)`

```sql
CREATE OR REPLACE FUNCTION public.srd_registrar_ocultacao_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_manual_d100 integer)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  select priv.srd_registrar_ocultacao_ataque_oportunidade_impl(
    p_campaign_id,p_attack_id,p_manual_d100
  );
$function$

```

### `public.srd_registrar_rolagem_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_manual_d20 integer, p_idempotency_key uuid)`

```sql
CREATE OR REPLACE FUNCTION public.srd_registrar_rolagem_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_manual_d20 integer, p_idempotency_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_attack priv.srd_aoo_attacks%rowtype;
  v_existing priv.srd_aoo_attacks%rowtype;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode registrar a rolagem do ataque de oportunidade.';
  end if;
  if p_manual_d20 not between 1 and 20 or p_idempotency_key is null then
    raise exception 'A rolagem exige d20 físico válido e chave de idempotência.';
  end if;
  select * into v_attack from priv.srd_aoo_attacks
  where attack_id=p_attack_id and campaign_id=p_campaign_id for update;
  if not found or v_attack.created_by<>auth.uid() then
    raise exception 'Ataque não encontrado ou sem autorização.';
  end if;
  select * into v_existing from priv.srd_aoo_attacks
  where attack_roll_idempotency_key=p_idempotency_key;
  if found then
    if v_existing.attack_id<>p_attack_id or v_existing.manual_d20<>p_manual_d20 then
      raise exception 'Chave de idempotência já utilizada em outra rolagem.';
    end if;
    return jsonb_build_object('attack_id',p_attack_id,'manual_d20',v_existing.manual_d20,'replayed',true);
  end if;
  if v_attack.status<>'awaiting_attack_roll' then
    if v_attack.manual_d20=p_manual_d20 then
      return jsonb_build_object('attack_id',p_attack_id,'manual_d20',v_attack.manual_d20,'replayed',true);
    end if;
    raise exception 'Este ataque já recebeu uma rolagem diferente.';
  end if;
  update priv.srd_aoo_attacks
  set manual_d20=p_manual_d20,attack_roll_idempotency_key=p_idempotency_key
  where attack_id=p_attack_id;
  return jsonb_build_object('attack_id',p_attack_id,'manual_d20',p_manual_d20,
    'ready_to_resolve',true,'replayed',false);
end;
$function$

```

### `public.srd_reservar_ataque_oportunidade_srd(p_campaign_id bigint, p_actor_token_id text, p_trigger_key text, p_actor_flat_footed boolean)`

```sql
CREATE OR REPLACE FUNCTION public.srd_reservar_ataque_oportunidade_srd(p_campaign_id bigint, p_actor_token_id text, p_trigger_key text, p_actor_flat_footed boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
 select priv.srd_reservar_ataque_oportunidade_impl(
   p_campaign_id,p_actor_token_id,p_trigger_key,p_actor_flat_footed
 );
$function$

```

### `public.srd_reservar_reacao_movimento_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)`

```sql
CREATE OR REPLACE FUNCTION public.srd_reservar_reacao_movimento_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
 select priv.srd_reservar_reacao_movimento_aoo_impl(
   p_campaign_id,p_pending_id,p_reactor_token_id
 );
$function$

```

### `public.srd_resolver_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid)`

```sql
CREATE OR REPLACE FUNCTION public.srd_resolver_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_attack priv.srd_aoo_attacks%rowtype;
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_actor_token jsonb;
  v_target jsonb;
  v_sheet public.srd_character_sheets%rowtype;
  v_class public.srd_classes%rowtype;
  v_race public.srd_races%rowtype;
  v_weapon public.srd_equipment%rowtype;
  v_instance public.srd_character_weapon_instances%rowtype;
  v_target_ac integer;
  v_target_ac_data jsonb;
  v_bab integer:=0;
  v_level integer:=1;
  v_score integer:=10;
  v_ability_mod integer:=0;
  v_size_mod integer:=0;
  v_focus integer:=0;
  v_prof_penalty integer:=0;
  v_racial_bonus integer:=0;
  v_effect_attack integer:=0;
  v_expected integer;
  v_total integer;
  v_attack_key text;
  v_weapon_name text;
  v_weapon_prof text;
  v_profs jsonb;
  v_proficient boolean:=false;
  v_finesse boolean:=false;
  v_target_traits text;
  v_crit_text text;
  v_crit_min integer:=20;
  v_crit_mult integer:=2;
  v_is_threat boolean:=false;
  v_status text;
  v_target_type text;
  v_actor_is_giant boolean:=false;
  v_target_race text;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode resolver ataques de oportunidade.';
  end if;
  select * into v_attack from priv.srd_aoo_attacks
  where attack_id=p_attack_id and campaign_id=p_campaign_id for update;
  if not found then raise exception 'Ataque de oportunidade não encontrado.'; end if;
  if v_attack.created_by<>auth.uid() then raise exception 'Somente o Mestre que iniciou o ataque pode resolvê-lo.'; end if;
  if v_attack.status<>'awaiting_attack_roll' or v_attack.manual_d20 is null then
    if v_attack.status in ('awaiting_critical_confirmation','awaiting_damage','miss','damage_applied') then
      return jsonb_build_object('attack_id',p_attack_id,'status',v_attack.status,
        'attack_total',v_attack.attack_total,'target_ac',v_attack.target_ac,
        'is_critical',v_attack.is_critical,'resolution_data',v_attack.resolution_data,'replayed',true);
    end if;
    raise exception 'Registre primeiro a rolagem manual do d20.';
  end if;

  select * into v_pending from priv.srd_aoo_pending_movements
  where pending_id=v_attack.pending_id and campaign_id=p_campaign_id for update;
  if not found or v_pending.status<>'waiting_reactions' then raise exception 'Movimento pendente não está mais ativo.'; end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
    or coalesce(v_campaign.combat_data->>'active','false')<>'true'
    or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
    or coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn then
    raise exception 'O combate mudou antes da resolução do ataque.';
  end if;

  select t into v_actor_token from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=v_attack.actor_token_id or t->>'key'=v_attack.actor_token_id limit 1;
  select t into v_target from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=v_attack.target_token_id or t->>'key'=v_attack.target_token_id limit 1;
  if v_actor_token is null or v_target is null then raise exception 'Atacante ou alvo saiu da cena.'; end if;

  if v_attack.actor_character_id is null then
    v_actor_is_giant:=lower(concat_ws(' ',v_actor_token->>'creature_type',
      v_actor_token->'monsterStats'->>'type',v_actor_token->'monsterStats'->>'tipo',
      v_actor_token->'monsterStats'->>'creature_type',v_actor_token->'monsterStats'->>'subtype')) ~ '(giant|gigante)';
    if v_target->>'tipo'='player' then
      v_target_ac_data:=public.srd_calcular_ca_personagem_srd(p_campaign_id,v_attack.target_token_id,'normal',v_actor_is_giant);
      v_target_ac:=nullif(v_target_ac_data->>'final_ac','')::integer
        +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac_melee');
    elsif v_target->>'tipo'='npc' AND NULLIF(v_target->>'sourceCharacterId','') IS NOT NULL then
      v_target_ac_data:=priv.srd_calcular_ca_alvo_campanha_srd(
        p_campaign_id,v_target->>'sourceCharacterId','normal'
      );
      v_target_ac:=nullif(v_target_ac_data->>'final_ac','')::integer
        +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac_melee');
      if v_actor_is_giant then
        select lower(sh.raca_id::text) into v_target_race
          from public.srd_character_sheets sh
         where sh.character_id::text=v_target->>'sourceCharacterId';
        if v_target_race in ('anao','gnomo')
           and not coalesce((v_target_ac_data->>'dexterity_lost')::boolean,false) then
          v_target_ac:=v_target_ac+4;
        end if;
      end if;
    else
      if coalesce(v_target->>'ac',v_target->'monsterStats'->>'ca','') !~ '^[0-9]{1,3}$' then
        raise exception 'O alvo não possui CA numérica válida.';
      end if;
      v_target_ac:=(coalesce(v_target->>'ac',v_target->'monsterStats'->>'ca'))::integer
        +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac')
        +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac_melee');
    end if;
    v_expected:=coalesce(nullif(v_attack.resolution_data->>'monster_attack_bonus','')::integer,0)
      +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.actor_token_id,'attack')
      +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.actor_token_id,'attack_melee');
    v_total:=v_attack.manual_d20+v_expected;
    v_crit_min:=coalesce(nullif(v_attack.resolution_data->>'critical_threat_minimum','')::integer,20);
    v_crit_mult:=coalesce(nullif(v_attack.resolution_data->>'critical_multiplier','')::integer,2);
    v_is_threat:=v_attack.manual_d20>=v_crit_min
      and (v_attack.manual_d20=20 or (v_attack.manual_d20<>1 and v_total>=v_target_ac));
    v_status:=case when v_attack.manual_d20=20 or (v_attack.manual_d20<>1 and v_total>=v_target_ac)
      then case when v_is_threat then 'awaiting_critical_confirmation' else 'awaiting_damage' end
      else 'miss' end;
    update priv.srd_aoo_attacks set status=v_status,attack_total=v_total,target_ac=v_target_ac,
      resolution_data=resolution_data||jsonb_build_object('attack_total',v_total,'target_ac',v_target_ac,
        'monster_attack_bonus',v_expected,'critical_threat',v_is_threat,'critical_threat_minimum',v_crit_min,
        'critical_multiplier',v_crit_mult,'manual_d20',v_attack.manual_d20),resolved_at=now()
    where attack_id=p_attack_id returning * into v_attack;
    update priv.srd_aoo_pending_movements p
    set pending_reactions=jsonb_set(p.pending_reactions,ARRAY[
      (select (e.ordinality-1)::text from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
       where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1)
    ],(
      select e.value||jsonb_build_object('status',case when v_status='miss' then 'miss' else 'hit_pending_damage' end)
      from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
      where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1
    ),false),updated_at=now()
    where p.pending_id=v_attack.pending_id;
    return jsonb_build_object('attack_id',p_attack_id,'status',v_status,
      'manual_d20',v_attack.manual_d20,'attack_total',v_total,'target_ac',v_target_ac,
      'critical_threat',v_is_threat,'critical_multiplier',v_crit_mult,
      'damage_expression',v_attack.resolution_data->>'damage_expression',
      'resolution_data',v_attack.resolution_data,'action_economy_cost',0);
  end if;

  select * into v_sheet from public.srd_character_sheets where character_id=v_attack.actor_character_id;
  select * into v_class from public.srd_classes where id=v_sheet.classe_id;
  select * into v_race from public.srd_races where id=v_sheet.raca_id;
  select * into v_instance from public.srd_character_weapon_instances
  where instance_id=v_attack.weapon_instance_id and character_id=v_attack.actor_character_id::text
    and equipado is true and hand_slot=v_attack.weapon_hand_slot;
  if not found or not exists(select 1 from public.srd_character_equipment ce
    where ce.character_id=v_attack.actor_character_id::text and ce.equipment_id=v_instance.equipment_id
      and ce.equipado is true and ce.hand_slot=v_attack.weapon_hand_slot) then
    raise exception 'A arma deixou de estar equipada corretamente.';
  end if;
  select * into v_weapon from public.srd_equipment where id=v_instance.equipment_id;

  v_level:=greatest(1,coalesce(v_sheet.nivel,1));
  select coalesce(sum(case lower(coalesce(cl.bab_progression,''))
    when 'good' then lv.class_level when 'bom' then lv.class_level
    when 'average' then floor(3*lv.class_level/4.0)::integer
    when 'medium' then floor(3*lv.class_level/4.0)::integer
    when 'medio' then floor(3*lv.class_level/4.0)::integer
    when 'poor' then floor(lv.class_level/2.0)::integer
    when 'ruim' then floor(lv.class_level/2.0)::integer else 0 end),0)::integer
  into v_bab from public.srd_character_class_levels lv
  join public.srd_classes cl on cl.id=lv.class_id where lv.character_id=v_attack.actor_character_id;
  if not exists(select 1 from public.srd_character_class_levels lv where lv.character_id=v_attack.actor_character_id) then
    v_bab:=case lower(coalesce(v_class.bab_progression,''))
      when 'good' then v_level when 'bom' then v_level
      when 'average' then floor(3*v_level/4.0)::integer
      when 'medium' then floor(3*v_level/4.0)::integer
      when 'medio' then floor(3*v_level/4.0)::integer
      when 'poor' then floor(v_level/2.0)::integer
      when 'ruim' then floor(v_level/2.0)::integer else 0 end;
  end if;

  v_weapon_name:=coalesce(v_weapon.detalhes->>'weapon_proficiency_name',v_weapon.nome);
  v_weapon_prof:=priv.srd_weapon_proficiency(v_weapon.detalhes,v_weapon_name);
  v_profs:=coalesce(v_class.dados_tecnicos->'proficiencias'->'armas','[]'::jsonb);
  v_proficient:=exists(select 1 from jsonb_array_elements_text(case when jsonb_typeof(v_profs)='array' then v_profs else '[]'::jsonb end) p
    where lower(btrim(p.value))='todas as armas simples e marciais' AND v_weapon_prof IN ('simple','martial')
      or public.srd35_normalizar_parametro_talento(p.value)=public.srd35_normalizar_parametro_talento(v_weapon_name)
      or (lower(btrim(p.value))='armas simples' and v_weapon_prof='simple'));
  -- Para Anões, armas com familiaridade racial são tratadas como marciais.
  if not v_proficient and v_race.id='anao' and v_weapon_prof='exotic'
     and coalesce(v_weapon.detalhes->'weapon_familiarity_race_ids','[]'::jsonb) ? 'anao' then
    v_proficient:=exists(select 1 from jsonb_array_elements_text(case when jsonb_typeof(v_profs)='array' then v_profs else '[]'::jsonb end) p
      where lower(btrim(p.value))='todas as armas simples e marciais');
  end if;
  if not v_proficient then
    v_proficient:=exists(select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
      where (f->>'id'='srd35_feat_simple_weapon_proficiency' and v_weapon_prof='simple')
        or (f->>'id' in ('srd35_feat_martial_weapon_proficiency','srd35_feat_exotic_weapon_proficiency')
          and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name)));
  end if;
  if not v_proficient then v_prof_penalty:=4; end if;

  v_finesse:=exists(select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
    where f->>'id'='srd35_feat_weapon_finesse');
  if v_finesse and coalesce(v_weapon.detalhes->>'weapon_finesse_eligible','false')='true' then
    v_attack_key:='DES'; v_score:=coalesce(nullif(v_sheet.atributos->>'DES','')::integer,10);
  else
    v_attack_key:='FOR'; v_score:=coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10);
  end if;
  v_ability_mod:=floor((v_score-10)::numeric/2)::integer;
  if lower(coalesce(v_race.tamanho,'')) in ('pequeno','small') then v_size_mod:=1;
  elsif lower(coalesce(v_race.tamanho,'')) in ('grande','large') then v_size_mod:=-1; end if;

  v_focus:=(case when exists(select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
      where f->>'id'='foco_em_arma' and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name)) then 1 else 0 end)
    +(case when exists(select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
      where f->>'id'='srd35_feat_greater_weapon_focus' and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name)) then 1 else 0 end);

  v_target_race:=lower(coalesce(nullif(v_target->>'raca_id',''),
    nullif(v_target->>'race_id',''),nullif(v_target->'monsterStats'->>'race_id','')));
  if v_target->>'tipo'='player' then
    select lower(sh.raca_id::text) into v_target_race
      from public.srd_character_sheets sh
     where sh.character_id::text=v_attack.target_token_id;
  elsif v_target->>'tipo'='npc' and nullif(v_target->>'sourceCharacterId','') is not null then
    select lower(sh.raca_id::text) into v_target_race
      from public.srd_character_sheets sh
     where sh.character_id::text=v_target->>'sourceCharacterId';
  end if;
  v_target_traits:=lower(concat_ws(' ',v_target->>'nome',v_target->>'detalhe',
    v_target->'monsterStats'->>'tipo',v_target->'monsterStats'->>'subtipo',
    v_target->'monsterStats'->>'type',v_target->'monsterStats'->>'creature_type',
    v_target_race));
  if v_race.id='anao' and v_target_traits ~ '(^|[^a-z])(orc|goblin|hobgoblin|bugbear|goblinoid(e)?)([^a-z]|$)' then v_racial_bonus:=1; end if;

  v_effect_attack:=priv.srd_effective_modifier(p_campaign_id,'token',v_attack.actor_token_id,'attack')
    +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.actor_token_id,'attack_melee')
    +floor((coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10)
      +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.actor_token_id,'strength')-10)::numeric/2)::integer
    -floor((coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10)-10)::numeric/2)::integer;

  v_actor_is_giant:=lower(concat_ws(' ',v_actor_token->>'creature_type',v_actor_token->'monsterStats'->>'type',v_actor_token->'monsterStats'->>'tipo',v_actor_token->'monsterStats'->>'creature_type',v_actor_token->'monsterStats'->>'subtype',v_actor_token->'monsterStats'->>'subtypes')) ~ '(giant|gigante)';
  if v_target->>'tipo'='player' then
    v_target_ac_data:=public.srd_calcular_ca_personagem_srd(p_campaign_id,v_attack.target_token_id,'normal',v_actor_is_giant);
    v_target_ac:=nullif(v_target_ac_data->>'final_ac','')::integer
      +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac_melee');
  elsif v_target->>'tipo'='npc' AND NULLIF(v_target->>'sourceCharacterId','') IS NOT NULL then
    v_target_ac_data:=priv.srd_calcular_ca_alvo_campanha_srd(
      p_campaign_id,v_target->>'sourceCharacterId','normal'
    );
    v_target_ac:=nullif(v_target_ac_data->>'final_ac','')::integer
      +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac_melee');
    if v_actor_is_giant then
      select lower(sh.raca_id::text) into v_target_race
        from public.srd_character_sheets sh
       where sh.character_id::text=v_target->>'sourceCharacterId';
      if v_target_race in ('anao','gnomo')
         and not coalesce((v_target_ac_data->>'dexterity_lost')::boolean,false) then
        v_target_ac:=v_target_ac+4;
      end if;
    end if;
  else
    if coalesce(v_target->>'ac',v_target->'monsterStats'->>'ca','') !~ '^[0-9]{1,3}$' then
      raise exception 'O alvo não possui CA numérica válida.';
    end if;
    v_target_ac:=(coalesce(v_target->>'ac',v_target->'monsterStats'->>'ca'))::integer
      +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac')
      +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac_melee');
  end if;
  if v_target_ac is null then raise exception 'Não foi possível calcular a CA do alvo.'; end if;

  v_expected:=v_bab+v_ability_mod+v_size_mod+v_focus+v_racial_bonus-v_prof_penalty;
  v_total:=v_attack.manual_d20+v_expected+v_effect_attack;
  v_crit_text:=coalesce(v_attack.resolution_data->>'weapon_critical',v_weapon.critico,'x2');
  if v_crit_text ~ '^[0-9]{2}(-[0-9]{2})?/x[0-9]+$' then
    v_crit_min:=split_part(v_crit_text,'-',1)::integer;
  else
    v_crit_min:=20;
  end if;
  if v_crit_min<2 or v_crit_min>20 then v_crit_min:=20; end if;
  v_crit_mult:=coalesce(nullif(regexp_replace(v_crit_text,'^.*x',''),'')::integer,2);
  if v_crit_mult<2 or v_crit_mult>5 then v_crit_mult:=2; end if;

  if v_attack.manual_d20=20 or (v_attack.manual_d20<>1 and v_total>=v_target_ac) then
    v_is_threat:=v_attack.manual_d20>=v_crit_min;
    v_status:=case when v_is_threat then 'awaiting_critical_confirmation' else 'awaiting_damage' end;
  else
    v_status:='miss';
  end if;

  update priv.srd_aoo_attacks set
    status=v_status,attack_total=v_total,target_ac=v_target_ac,
    resolution_data=resolution_data||jsonb_build_object(
      'base_attack_bonus',v_bab,'ability',v_attack_key,'ability_modifier',v_ability_mod,
      'size_modifier',v_size_mod,'weapon_focus',v_focus,'racial_bonus',v_racial_bonus,
      'proficiency_penalty',v_prof_penalty,'effect_attack_modifier',v_effect_attack,
      'attack_total',v_total,'target_ac',v_target_ac,'manual_d20',v_attack.manual_d20,
      'critical_threat_minimum',v_crit_min,'critical_multiplier',v_crit_mult,
      'critical_threat',v_is_threat
    ),resolved_at=now()
  where attack_id=p_attack_id returning * into v_attack;

  update priv.srd_aoo_pending_movements p
  set pending_reactions=jsonb_set(p.pending_reactions,ARRAY[
    (select (e.ordinality-1)::text from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
     where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1)
  ],(
    select e.value||jsonb_build_object('status',case when v_status='miss' then 'miss' else 'hit_pending_damage' end)
    from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
    where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1
  ),false),updated_at=now()
  where p.pending_id=v_attack.pending_id;

  return jsonb_build_object('attack_id',p_attack_id,'status',v_status,
    'manual_d20',v_attack.manual_d20,'attack_total',v_total,'target_ac',v_target_ac,
    'critical_threat',v_is_threat,'critical_multiplier',v_crit_mult,
    'damage_expression',v_weapon.dano,'resolution_data',v_attack.resolution_data,
    'action_economy_cost',0);
end;
$function$

```

### `public.srd_resolver_derrubar_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_attacker_d20 integer, p_defender_d20 integer, p_defender_firm_ground boolean)`

```sql
CREATE OR REPLACE FUNCTION public.srd_resolver_derrubar_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_attacker_d20 integer, p_defender_d20 integer, p_defender_firm_ground boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
  SELECT priv.srd_resolver_derrubar_apos_aoo_srd(
    p_campaign_id,p_pending_id,p_attacker_d20,p_defender_d20,p_defender_firm_ground
  );
$function$

```

### `public.srd_resolver_levantar_caido_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid)`

```sql
CREATE OR REPLACE FUNCTION public.srd_resolver_levantar_caido_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$ SELECT priv.srd_resolver_levantar_caido_apos_aoo_srd(p_campaign_id,p_pending_id); $function$

```

### `public.srd_solicitar_movimento_com_aoo_srd(p_campaign_id bigint, p_mover_token_id text, p_destination_x integer, p_destination_y integer, p_controller text)`

```sql
CREATE OR REPLACE FUNCTION public.srd_solicitar_movimento_com_aoo_srd(p_campaign_id bigint, p_mover_token_id text, p_destination_x integer, p_destination_y integer, p_controller text DEFAULT 'player'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_campaign public.campaigns%rowtype;
  v_combat jsonb;
  v_order jsonb;
  v_round integer;
  v_turn integer;
  v_actor_id text;
  v_token jsonb;
  v_token_type text;
  v_pos_x integer;
  v_pos_y integer;
  v_detection jsonb;
  v_pending_id uuid;
  v_reactions jsonb;
begin
  if auth.uid() is null then raise exception 'É necessário estar autenticado.'; end if;
  if p_controller not in ('player','gm') then raise exception 'Controlador de movimento inválido.'; end if;
  if p_controller='gm' and public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode solicitar movimento de token sob seu controle.';
  end if;

  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found then raise exception 'Campanha não encontrada.'; end if;
  v_combat:=coalesce(v_campaign.combat_data,'{}'::jsonb);
  if upper(coalesce(v_campaign.state,''))<>'COMBATE'
     or coalesce(v_combat->>'active','false')<>'true' then
    return jsonb_build_object('pending',false,'requires_aoo',false,
      'reason','combat_not_active','continue_with_existing_movement_rpc',true);
  end if;
  if coalesce(v_combat->>'round','') !~ '^[0-9]+$'
     or coalesce(v_combat->>'current_turn','') !~ '^[0-9]+$' then
    raise exception 'Rodada ou turno de combate inválido.';
  end if;
  v_round:=greatest(1,(v_combat->>'round')::integer);
  v_turn:=(v_combat->>'current_turn')::integer;
  v_order:=case when jsonb_typeof(v_combat->'turn_order')='array'
    then v_combat->'turn_order' else '[]'::jsonb end;
  if v_turn<0 or v_turn>=jsonb_array_length(v_order) then
    raise exception 'Índice do turno atual inválido.';
  end if;
  v_actor_id:=v_order->v_turn->>'id';

  select t into v_token
  from jsonb_array_elements(case when jsonb_typeof(v_campaign.cba_data->'tokens')='array'
    then v_campaign.cba_data->'tokens' else '[]'::jsonb end) t
  where t->>'id'=btrim(p_mover_token_id) or t->>'key'=btrim(p_mover_token_id)
  limit 1;
  if v_token is null then raise exception 'Token não encontrado na cena.'; end if;
  v_token_type:=v_token->>'tipo';
  if coalesce(v_token->>'gridX','') !~ '^[0-9]{1,3}$'
     or coalesce(v_token->>'gridY','') !~ '^[0-9]{1,3}$' then
    raise exception 'Posição atual do token inválida.';
  end if;
  v_pos_x:=(v_token->>'gridX')::integer;
  v_pos_y:=(v_token->>'gridY')::integer;

  if p_controller='player' then
    if v_token_type<>'player'
       or v_actor_id is distinct from btrim(p_mover_token_id)
       or not exists(select 1 from public.characters c
         where c.id::text=btrim(p_mover_token_id)
           and c.campaign_id=p_campaign_id and c.user_id=auth.uid()) then
      raise exception 'O personagem não é seu ou não está no turno ativo.';
    end if;
  else
    if v_actor_id is distinct from btrim(p_mover_token_id)
       or v_token_type not in ('npc','monstro','player') then
      raise exception 'O token não está no turno ativo ou não pode ser controlado pelo Mestre.';
    end if;
  end if;

  v_detection:=public.srd_detectar_saida_alcance_ameacado_srd(
    p_campaign_id,btrim(p_mover_token_id),p_destination_x,p_destination_y);
  if coalesce((v_detection->>'detected')::boolean,false) is not true then
    return jsonb_build_object('pending',false,'requires_aoo',false,
      'reason',coalesce(v_detection->>'reason','no_threat_detected'),
      'detection',v_detection,'continue_with_existing_movement_rpc',true);
  end if;

  if exists(select 1 from priv.srd_aoo_pending_movements
    where campaign_id=p_campaign_id and status in ('waiting_reactions','ready_to_commit')) then
    raise exception 'Já existe um movimento aguardando resolução de ataques de oportunidade nesta campanha.';
  end if;

  v_reactions:=(
    select coalesce(jsonb_agg(jsonb_build_object(
      'reactor_token_id',coalesce(x->>'token_id',x->>'token_key'),
      'trigger_key',concat('move:',p_mover_token_id,':',v_round,':',p_destination_x,':',p_destination_y,':',coalesce(x->>'token_id',x->>'token_key')),
      'status','waiting',
      'threat',x
    )),'[]'::jsonb)
    from jsonb_array_elements(coalesce(v_detection->'threats','[]'::jsonb)) x
  );
  insert into priv.srd_aoo_pending_movements(
    campaign_id,mover_token_id,movement_controller,destination_x,destination_y,
    origin_x,origin_y,combat_round,current_turn,turn_actor_id,threats,
    pending_reactions,created_by
  ) values (
    p_campaign_id,btrim(p_mover_token_id),p_controller,p_destination_x,p_destination_y,
    v_pos_x,v_pos_y,v_round,v_turn,v_actor_id,
    coalesce(v_detection->'threats','[]'::jsonb),v_reactions,auth.uid()
  ) returning pending_id into v_pending_id;

  return jsonb_build_object('pending',true,'requires_aoo',true,
    'pending_id',v_pending_id,'status','waiting_reactions',
    'round',v_round,'current_turn',v_turn,'mover_token_id',p_mover_token_id,
    'from',jsonb_build_array(v_pos_x,v_pos_y),
    'to',jsonb_build_array(p_destination_x,p_destination_y),
    'pending_reactions',v_reactions,
    'movement_committed',false);
end;
$function$

```

## Notas de auditoria

- A exportação inclui wrappers públicos INVOKER e implementações internas DEFINER, para preservar a fronteira de segurança observável.
- A existência de `pg_temp` no search_path reduz risco de shadowing temporário, mas não substitui revisão de autorização e de SQL dinâmico.
- A ordem de locks ainda precisa ser analisada em todas as rotas; a inversão já identificada entre cancelamento e resolução/aplicação de dano permanece risco de deadlock até teste concorrente em ambiente descartável.
- Comparar os fingerprints com snapshots futuros permite detectar drift do schema, mas não identifica qual migration causou a mudança.
