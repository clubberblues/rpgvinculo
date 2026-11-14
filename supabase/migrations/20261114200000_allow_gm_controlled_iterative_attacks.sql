-- Autoriza o Mestre a operar ataques iterativos de personagens jogadores.
-- A propriedade permanece no jogador; a helper central exige mesma campanha.
-- Depende de 20261114190000_allow_gm_character_action_economy.sql.
BEGIN;

DO $migration$
DECLARE
  v_signature text;
  v_pattern text;
  v_definition text;
  v_count integer;
  v_replacement text := 'priv.srd_can_control_campaign_character(ch.campaign_id, ch.id::text)';
  v_item record;
BEGIN
  IF to_regprocedure('priv.srd_can_control_campaign_character(bigint,text)') IS NULL THEN
    RAISE EXCEPTION 'Missing priv.srd_can_control_campaign_character(bigint,text); apply the action-economy authorization migration first.';
  END IF;

  FOR v_item IN
    SELECT *
      FROM (VALUES
        ('priv.iniciar_sequencia_ataque_iterativo_srd_5_impl(bigint,text,text,text,uuid)', 'ch'),
        ('public.resolver_ataque_iterativo_srd(bigint,uuid)', 'ch'),
        ('public.confirmar_critico_ataque_iterativo_srd(bigint,uuid,integer)', 'ch'),
        ('public.aplicar_dano_ataque_iterativo_srd(bigint,uuid,integer[],uuid)', 'ch'),
        ('public.aplicar_dano_ataque_iterativo_srd(bigint,uuid,integer[],uuid,integer[])', 'ch'),
        ('public.consultar_sequencia_ataque_iterativo_pendente_srd(bigint,text)', 'm'),
        ('public.registrar_rolagem_ataque_iterativo_srd(bigint,uuid,integer,uuid)', 'm')
      ) AS targets(signature, alias_name)
  LOOP
    v_signature := v_item.signature;
    v_pattern := CASE v_item.alias_name
      WHEN 'm' THEN 'm\.user_id\s*=\s*v_user'
      ELSE 'ch\.user_id\s*=\s*v_user'
    END;

    IF to_regprocedure(v_signature) IS NULL THEN
      RAISE EXCEPTION 'Required attack-control function is missing: %', v_signature;
    END IF;

    SELECT pg_get_functiondef(to_regprocedure(v_signature))
      INTO v_definition;

    v_count := regexp_count(v_definition, v_pattern, 1, 'i');
    IF v_count <> 1 THEN
      RAISE EXCEPTION
        'Expected exactly one owner-only guard in %, found %. Refusing to patch an unknown function body.',
        v_signature, v_count;
    END IF;

    v_definition := regexp_replace(v_definition, v_pattern, v_replacement, 'gi');
    EXECUTE v_definition;
  END LOOP;
END
$migration$;

COMMIT;
