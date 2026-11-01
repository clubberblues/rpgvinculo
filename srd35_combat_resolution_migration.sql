-- Vínculo · Resolução de ataques D&D 3.5 e aplicação de dano de jogador.
-- Aplicar após vtt_dnd35_final_migration.sql e srd35_action_economy_migration.sql.
-- O Mestre continua usando alterar_pv_token_cba/alterar_pv_personagem.

BEGIN;

CREATE OR REPLACE FUNCTION public.aplicar_dano_token_ataque_srd(
  p_campaign_id BIGINT,
  p_character_id TEXT,
  p_token_id TEXT,
  p_d20 INTEGER,
  p_bonus_ataque INTEGER,
  p_dano INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_user UUID := auth.uid();
  v_campaign public.campaigns%ROWTYPE;
  v_combat JSONB;
  v_order JSONB;
  v_actor JSONB;
  v_scene JSONB;
  v_tokens JSONB;
  v_target JSONB;
  v_target_count INTEGER;
  v_target_index BIGINT;
  v_ca_text TEXT;
  v_ca INTEGER;
  v_max_hp INTEGER;
  v_hp INTEGER;
  v_new_hp INTEGER;
  v_attack_total INTEGER;
  v_round INTEGER;
BEGIN
  IF v_user IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  IF p_d20 IS NULL OR p_d20 < 1 OR p_d20 > 20 THEN RAISE EXCEPTION 'Resultado de ataque inválido.'; END IF;
  IF p_bonus_ataque IS NULL OR p_bonus_ataque < -30 OR p_bonus_ataque > 60 THEN RAISE EXCEPTION 'Bônus de ataque inválido.'; END IF;
  IF p_dano IS NULL OR p_dano < 1 OR p_dano > 1000 THEN RAISE EXCEPTION 'Dano inválido.'; END IF;

  SELECT c.* INTO v_campaign FROM public.campaigns AS c WHERE c.id=p_campaign_id FOR UPDATE;
  IF NOT FOUND OR UPPER(COALESCE(v_campaign.state,'')) <> 'COMBATE' THEN
    RAISE EXCEPTION 'A campanha não está em combate.';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.characters AS ch
    JOIN public.members AS m ON m.campaign_id=ch.campaign_id AND m.user_id=ch.user_id AND m.role='PLAYER'
    WHERE ch.id::TEXT=BTRIM(p_character_id) AND ch.campaign_id=p_campaign_id AND ch.user_id=v_user
  ) THEN RAISE EXCEPTION 'A ficha atacante não pertence ao jogador nesta campanha.'; END IF;

  v_combat:=COALESCE(v_campaign.combat_data,'{}'::JSONB);
  IF COALESCE(v_combat->>'active','false') <> 'true' THEN RAISE EXCEPTION 'A iniciativa não está ativa.'; END IF;
  v_order:=CASE WHEN jsonb_typeof(v_combat->'turn_order')='array' THEN v_combat->'turn_order' ELSE '[]'::JSONB END;
  IF COALESCE(v_combat->>'current_turn','') !~ '^[0-9]+$' THEN RAISE EXCEPTION 'O turno atual é inválido.'; END IF;
  v_actor:=v_order->(v_combat->>'current_turn')::INTEGER;
  IF v_actor->>'id' IS DISTINCT FROM BTRIM(p_character_id) OR COALESCE(v_actor->>'is_monster','false')='true' THEN
    RAISE EXCEPTION 'Apenas o personagem ativo pode concluir este ataque.';
  END IF;
  v_round:=CASE WHEN COALESCE(v_combat->>'round','') ~ '^[0-9]+$' THEN GREATEST(1,(v_combat->>'round')::INTEGER) ELSE 1 END;
  IF COALESCE(v_combat->'action_economy'->>'round','')<>v_round::TEXT
     OR COALESCE(v_combat->'action_economy'->'by_character'->BTRIM(p_character_id)->>'padrao','false')<>'true' THEN
    RAISE EXCEPTION 'A ação padrão do atacante ainda não foi consumida neste turno.';
  END IF;

  v_scene:=COALESCE(v_campaign.cba_data,'{}'::JSONB);
  v_tokens:=CASE WHEN jsonb_typeof(v_scene->'tokens')='array' THEN v_scene->'tokens' ELSE '[]'::JSONB END;
  SELECT count(*)::INTEGER,min(t.ordinality),min(coalesce(t.token->>'ac',t.token->'monsterStats'->>'ca')) INTO v_target_count,v_target_index,v_ca_text
  FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS t(token,ordinality)
  WHERE t.token->>'id'=BTRIM(p_token_id) AND t.token->>'tipo' IN ('npc','monstro');
  IF v_target_count<>1 THEN RAISE EXCEPTION 'O alvo NPC/monstro não foi encontrado ou está duplicado.'; END IF;
  IF COALESCE(v_ca_text,'') !~ '[0-9]{1,3}' THEN RAISE EXCEPTION 'O token alvo precisa ter uma CA numérica.'; END IF;
  v_ca:=substring(v_ca_text from '[0-9]{1,3}')::INTEGER;
  v_attack_total:=p_d20+p_bonus_ataque;
  IF p_d20=1 OR (p_d20<>20 AND v_attack_total<v_ca) THEN RAISE EXCEPTION 'Ataque não atingiu a CA do alvo (%). Nenhum dano foi aplicado.',v_ca; END IF;

  v_target:=v_tokens->(v_target_index::INTEGER-1);
  IF COALESCE(v_target->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' THEN RAISE EXCEPTION 'O alvo não possui PV máximo configurado.'; END IF;
  v_max_hp:=(v_target->>'maxHp')::INTEGER;
  v_hp:=CASE WHEN COALESCE(v_target->>'hp','') ~ '^[0-9]{1,6}$' THEN (v_target->>'hp')::INTEGER ELSE v_max_hp END;
  v_new_hp:=GREATEST(0,LEAST(v_max_hp,v_hp-p_dano));
  v_target:=v_target||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp);
  v_scene:=v_scene||jsonb_build_object('tokens',jsonb_set(v_tokens,ARRAY[(v_target_index-1)::TEXT],v_target,FALSE));
  UPDATE public.campaigns SET cba_data=v_scene WHERE id=p_campaign_id;
  RETURN jsonb_build_object('cba_data',v_scene,'hp',v_new_hp,'max_hp',v_max_hp,'ca',v_ca,'attack_total',v_attack_total,'damage',p_dano);
END;
$$;

REVOKE ALL ON FUNCTION public.aplicar_dano_token_ataque_srd(BIGINT,TEXT,TEXT,INTEGER,INTEGER,INTEGER) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.aplicar_dano_token_ataque_srd(BIGINT,TEXT,TEXT,INTEGER,INTEGER,INTEGER) TO authenticated;

CREATE OR REPLACE FUNCTION public.consumir_acao_token_gm_srd(
  p_campaign_id BIGINT,
  p_token_id TEXT,
  p_acao TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_user UUID := auth.uid();
  v_campaign public.campaigns%ROWTYPE;
  v_combat JSONB;
  v_order JSONB;
  v_actor JSONB;
  v_action_state JSONB;
  v_by_token JSONB;
  v_token_actions JSONB;
  v_action TEXT := lower(btrim(coalesce(p_acao,'')));
  v_round INTEGER;
BEGIN
  IF v_user IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.members WHERE campaign_id=p_campaign_id AND user_id=v_user AND role='GM') THEN
    RAISE EXCEPTION 'Somente o Mestre pode coordenar os tokens controlados por ele.';
  END IF;
  IF v_action NOT IN ('padrao','movimento','rapida') THEN RAISE EXCEPTION 'Ação inválida.'; END IF;
  SELECT c.* INTO v_campaign FROM public.campaigns AS c WHERE c.id=p_campaign_id FOR UPDATE;
  IF NOT FOUND OR upper(coalesce(v_campaign.state,''))<>'COMBATE' THEN RAISE EXCEPTION 'A campanha não está em combate.'; END IF;
  v_combat:=coalesce(v_campaign.combat_data,'{}'::jsonb);
  IF coalesce(v_combat->>'active','false')<>'true' THEN RAISE EXCEPTION 'A iniciativa não está ativa.'; END IF;
  v_order:=CASE WHEN jsonb_typeof(v_combat->'turn_order')='array' THEN v_combat->'turn_order' ELSE '[]'::jsonb END;
  IF coalesce(v_combat->>'current_turn','') !~ '^[0-9]+$' THEN RAISE EXCEPTION 'O turno atual é inválido.'; END IF;
  v_actor:=v_order->(v_combat->>'current_turn')::INTEGER;
  IF v_actor->>'id' IS DISTINCT FROM btrim(p_token_id) OR coalesce(v_actor->>'is_monster','false')<>'true' THEN
    RAISE EXCEPTION 'O token não está no turno ativo do Mestre.';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t(token)
    WHERE t.token->>'id'=btrim(p_token_id)
      AND (t.token->>'tipo' IN ('npc','monstro') OR (t.token->>'tipo'='player' AND EXISTS (
        SELECT 1 FROM public.characters ch WHERE ch.id::text=btrim(p_token_id) AND ch.user_id=v_user AND ch.campaign_id=p_campaign_id
      )))
  ) THEN RAISE EXCEPTION 'Este token não é controlado pelo Mestre.'; END IF;
  v_round:=CASE WHEN coalesce(v_combat->>'round','') ~ '^[0-9]+$' THEN greatest(1,(v_combat->>'round')::INTEGER) ELSE 1 END;
  v_action_state:=v_combat->'action_economy';
  IF jsonb_typeof(v_action_state)='object' AND coalesce(v_action_state->>'round','')=v_round::text AND jsonb_typeof(v_action_state->'by_character')='object' THEN
    v_by_token:=v_action_state->'by_character';
  ELSE v_by_token:='{}'::jsonb; END IF;
  v_token_actions:=CASE WHEN jsonb_typeof(v_by_token->btrim(p_token_id))='object' THEN v_by_token->btrim(p_token_id) ELSE '{}'::jsonb END;
  IF coalesce(v_token_actions->>v_action,'false')='true' THEN RAISE EXCEPTION 'Esta ação do token já foi usada nesta rodada.'; END IF;
  v_token_actions:=v_token_actions||jsonb_build_object(v_action,true);
  v_by_token:=jsonb_set(v_by_token,ARRAY[btrim(p_token_id)],v_token_actions,true);
  v_action_state:=jsonb_build_object('round',v_round,'by_character',v_by_token);
  v_combat:=v_combat||jsonb_build_object('action_economy',v_action_state);
  UPDATE public.campaigns SET combat_data=v_combat WHERE id=p_campaign_id;
  RETURN jsonb_build_object('combat_data',v_combat,'token_id',btrim(p_token_id),'action',v_action,'round',v_round);
END;
$$;

REVOKE ALL ON FUNCTION public.consumir_acao_token_gm_srd(BIGINT,TEXT,TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.consumir_acao_token_gm_srd(BIGINT,TEXT,TEXT) TO authenticated;

COMMIT;
