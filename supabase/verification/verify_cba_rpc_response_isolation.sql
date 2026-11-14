-- Run after 20261112160000_filter_player_damage_rpc_results.sql.
-- Verifies that client RPC names are wrappers and internal implementations
-- are not directly executable by authenticated/anonymous API roles.
DO $verify$
DECLARE
  v_public regprocedure;
  v_private regprocedure;
  v_name text;
  v_signature text;
  v_def text;
BEGIN
  FOR v_name, v_signature IN
    SELECT * FROM (VALUES
      ('aplicar_dano_token_ataque_srd_v2','bigint,text,text,integer,integer,integer,text,text,integer'),
      ('aplicar_dano_token_ataque_srd_v2','bigint,text,text,integer,integer,integer,text,text,integer,integer,integer'),
      ('alterar_pv_token_cba','bigint,text,integer,integer'),
      ('equipar_item_token_srd','bigint,text,text,boolean'),
      ('srd_configurar_perfil_combate_token_srd','bigint,text,text,integer'),
      ('conjurar_magia_dano_multialvo_srd','text,text,smallint,text[],integer[]'),
      ('usar_habilidade_classe_srd','text,text,text,integer'),
      ('srd_finalizar_movimento_aoo_pendente_srd','bigint,uuid'),
      ('avancar_turno','bigint'),
      ('consumir_acao_turno_srd','bigint,text,text'),
      ('conjurar_magia_com_acao_srd_manual','text,text,smallint,text,integer[]'),
      ('conjurar_magia_com_acao_srd_multialvo_v3','text,text,smallint,text[],integer[]'),
      ('usar_imposicao_maos_mortos_vivos_srd','text,text,integer,integer'),
      ('registrar_iniciativa_d20','bigint,text,integer'),
      ('conjurar_missil_magico_srd_manual','text,text,smallint,text,integer[]')
    ) AS x(name, signature)
  LOOP
    v_public := to_regprocedure('public.'||v_name||'('||v_signature||')');
    v_private := to_regprocedure('priv.'||v_name||'('||v_signature||')');
    IF v_public IS NULL OR v_private IS NULL THEN
      RAISE EXCEPTION 'Missing public wrapper or private implementation: %.%',v_name,v_signature;
    END IF;
    IF NOT has_function_privilege('authenticated',v_public,'EXECUTE') THEN
      RAISE EXCEPTION 'authenticated cannot execute public wrapper: %.%',v_name,v_signature;
    END IF;
    IF has_function_privilege('anon',v_public,'EXECUTE') THEN
      RAISE EXCEPTION 'anon can execute public wrapper: %.%',v_name,v_signature;
    END IF;
    IF has_function_privilege('authenticated',v_private,'EXECUTE')
       OR has_function_privilege('anon',v_private,'EXECUTE') THEN
      RAISE EXCEPTION 'Client can bypass filtered wrapper: priv.%.%',v_name,v_signature;
    END IF;
    SELECT pg_get_functiondef(v_public::oid) INTO v_def;
    IF position('cba_filter_rpc_result' in v_def)=0 THEN
      RAISE EXCEPTION 'Public wrapper does not filter its JSONB result: %.%',v_name,v_signature;
    END IF;
  END LOOP;
END
$verify$;

SELECT 'CBA mutation RPC result isolation verified' AS result;
