-- Autoriza o Mestre a operar sequências de ataques iterativos de PCs.
-- O dono mantém ownership; a autorização é validada por campanha e personagem.
-- Depende de priv.srd_can_control_campaign_character(bigint,text).
BEGIN;

DO $migration$
DECLARE
  v_signature text;
  v_definition text;
  v_count integer;
  v_item record;
  v_character_guard text := 'priv.srd_can_control_campaign_character(ch.campaign_id, ch.id::text)';
BEGIN
  IF to_regprocedure('priv.srd_can_control_campaign_character(bigint,text)') IS NULL THEN
    RAISE EXCEPTION 'Missing priv.srd_can_control_campaign_character(bigint,text).';
  END IF;

  FOR v_item IN
    SELECT *
      FROM (VALUES
        ('priv.iniciar_sequencia_ataque_iterativo_srd_5_impl(bigint,text,text,text,uuid)', 'ch\.user_id\s*=\s*v_user', false),
        ('public.resolver_ataque_iterativo_srd(bigint,uuid)', 'ch\.user_id\s*=\s*v_user', true),
        ('public.confirmar_critico_ataque_iterativo_srd(bigint,uuid,integer)', 'ch\.user_id\s*=\s*v_user', true),
        ('public.aplicar_dano_ataque_iterativo_srd(bigint,uuid,integer[],uuid)', 'ch\.user_id\s*=\s*v_user', true),
        ('public.aplicar_dano_ataque_iterativo_srd(bigint,uuid,integer[],uuid,integer[])', 'ch\.user_id\s*=\s*v_user', true),
        ('public.consultar_sequencia_ataque_iterativo_pendente_srd(bigint,text)', 'm\.user_id\s*=\s*v_user', false),
        ('public.registrar_rolagem_ataque_iterativo_srd(bigint,uuid,integer,uuid)', 'm\.user_id\s*=\s*v_user', true)
      ) AS targets(signature, character_pattern, remove_creator_guard)
  LOOP
    v_signature := v_item.signature;
    IF to_regprocedure(v_signature) IS NULL THEN
      RAISE EXCEPTION 'Required attack-control function is missing: %', v_signature;
    END IF;

    SELECT pg_get_functiondef(to_regprocedure(v_signature)) INTO v_definition;

    v_count := regexp_count(v_definition, v_item.character_pattern, 1, 'i');
    IF v_count <> 1 THEN
      RAISE EXCEPTION 'Expected exactly one ownership guard in %, found %.', v_signature, v_count;
    END IF;
    v_definition := regexp_replace(v_definition, v_item.character_pattern, v_character_guard, 'gi');

    IF v_item.remove_creator_guard THEN
      IF v_signature LIKE 'public.registrar_rolagem_%' THEN
        v_count := regexp_count(v_definition,
          'if\s+v_sequence\.created_by\s*<>\s*v_user\s+then\s+raise exception ''[^'']*'';\s*end if;', 1, 'i');
        IF v_count <> 1 THEN
          RAISE EXCEPTION 'Expected one sequence creator guard in %, found %.', v_signature, v_count;
        END IF;
        v_definition := regexp_replace(v_definition,
          'if\s+v_sequence\.created_by\s*<>\s*v_user\s+then\s+raise exception ''[^'']*'';\s*end if;',
          '', 'gi');
      ELSE
        v_count := regexp_count(v_definition,
          'if\s+v_seq\.created_by\s*<>\s*v_user\s+then\s+raise exception ''[^'']*'';\s*end if;', 1, 'i');
        IF v_count <> 1 THEN
          RAISE EXCEPTION 'Expected one sequence creator guard in %, found %.', v_signature, v_count;
        END IF;
        v_definition := regexp_replace(v_definition,
          'if\s+v_seq\.created_by\s*<>\s*v_user\s+then\s+raise exception ''[^'']*'';\s*end if;',
          '', 'gi');
      END IF;
    END IF;

    IF v_signature LIKE 'public.consultar_sequencia_%' THEN
      v_count := regexp_count(v_definition, 's\.created_by\s*=\s*v_user', 1, 'i');
      IF v_count <> 1 THEN
        RAISE EXCEPTION 'Expected one sequence visibility filter in %, found %.', v_signature, v_count;
      END IF;
      v_definition := regexp_replace(v_definition, 's\.created_by\s*=\s*v_user',
        'priv.srd_can_control_campaign_character(s.campaign_id, s.actor_character_id::text)', 'gi');
    END IF;

    EXECUTE v_definition;
  END LOOP;
END
$migration$;

COMMIT;
