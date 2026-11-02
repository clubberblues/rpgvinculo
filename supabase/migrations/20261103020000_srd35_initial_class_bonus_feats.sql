-- Level-1 class bonus feats, verified against the open SRD class tables:
-- Fighter: https://www.d20srd.org/srd/classes/fighter.htm
-- Wizard: https://www.d20srd.org/srd/classes/sorcererWizard.htm#wizard
-- Monk: https://www.d20srd.org/srd/classes/monk.htm
-- Monk bonus choices explicitly waive their normal prerequisites.
CREATE OR REPLACE FUNCTION public.salvar_talentos_bonus_classe_inicial_srd(
  p_character_id TEXT,
  p_talentos JSONB DEFAULT '[]'::jsonb
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_character public.characters%ROWTYPE;
  v_class public.srd_classes%ROWTYPE;
  v_feat public.srd_feats%ROWTYPE;
  v_req JSONB;
  v_existing JSONB;
  v_updated JSONB;
  v_entry JSONB;
  v_feat_id TEXT;
  v_param TEXT;
  v_class_key TEXT;
  v_expected INTEGER := 0;
  v_bab INTEGER := 0;
  v_required INTEGER;
  v_stat_key TEXT;
  v_weapon_name TEXT;
  v_weapon_details JSONB;
  v_weapon_prof TEXT;
  v_has_prof BOOLEAN;
  v_owned TEXT[] := ARRAY[]::TEXT[];
  v_added TEXT[] := ARRAY[]::TEXT[];
  v_feature TEXT;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  IF NULLIF(BTRIM(p_character_id),'') IS NULL THEN RAISE EXCEPTION 'Personagem obrigatório.'; END IF;
  IF p_talentos IS NULL OR jsonb_typeof(p_talentos)<>'array' THEN
    RAISE EXCEPTION 'Talentos bônus precisam ser enviados como uma lista JSON.';
  END IF;

  SELECT ch.* INTO v_character
    FROM public.characters ch
   WHERE ch.id::text=BTRIM(p_character_id) AND ch.user_id=auth.uid()
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou sem autorização.'; END IF;

  SELECT sh.* INTO v_sheet
    FROM public.srd_character_sheets sh
   WHERE sh.character_id=v_character.id
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha D&D 3.5 não encontrada.'; END IF;
  IF COALESCE(v_sheet.nivel,1)<>1 THEN
    RAISE EXCEPTION 'Esta operação só concede características da criação de nível 1.';
  END IF;

  SELECT cl.* INTO v_class FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Classe SRD não encontrada.'; END IF;
  v_class_key:=COALESCE(v_class.class_key,'');
  v_expected:=CASE WHEN v_class_key IN ('fighter','monk') THEN 1 ELSE 0 END;
  IF jsonb_array_length(p_talentos)<>v_expected THEN
    RAISE EXCEPTION 'A classe exige % escolha(s) de talento bônus no nível 1.',v_expected;
  END IF;

  v_existing:=CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::jsonb END;
  SELECT COALESCE(array_agg(value->>'id'),'{}'::text[]) INTO v_owned
    FROM jsonb_array_elements(v_existing) AS current(value)
   WHERE value->>'id' IS NOT NULL;

  IF v_class_key='fighter' THEN
    v_bab:=CASE
      WHEN v_class.bab_progression IN ('good','bom') THEN 1
      WHEN v_class.bab_progression IN ('average','medium','medio') THEN 0
      WHEN v_class.bab_progression IN ('poor','bad','ruim') THEN 0
      ELSE 0 END;

    v_entry:=p_talentos->0;
    IF jsonb_typeof(v_entry)<>'object' THEN RAISE EXCEPTION 'Escolha um talento bônus válido para Guerreiro.'; END IF;
    v_feat_id:=NULLIF(BTRIM(v_entry->>'id'),'');
    v_param:=BTRIM(COALESCE(v_entry->>'parametro',''));
    IF v_feat_id IS NULL THEN RAISE EXCEPTION 'Selecione o talento bônus do Guerreiro.'; END IF;
    IF v_feat_id NOT IN (
      'srd35_feat_blind_fight','srd35_feat_cleave','srd35_feat_combat_expertise',
      'srd35_feat_deflect_arrows','esquiva','srd35_feat_far_shot','srd35_feat_great_cleave',
      'srd35_feat_improved_bull_rush','srd35_feat_improved_critical','srd35_feat_improved_disarm',
      'srd35_feat_improved_feint','srd35_feat_improved_grapple','iniciativa_aprimorada',
      'srd35_feat_improved_overrun','srd35_feat_improved_precise_shot','srd35_feat_improved_shield_bash',
      'srd35_feat_improved_sunder','srd35_feat_improved_trip','srd35_feat_improved_two_weapon_fighting',
      'srd35_feat_manyshot','srd35_feat_mobility','srd35_feat_mounted_archery','srd35_feat_mounted_combat',
      'srd35_feat_point_blank_shot','ataque_poderoso','srd35_feat_precise_shot','srd35_feat_quick_draw',
      'srd35_feat_rapid_reload','srd35_feat_rapid_shot','srd35_feat_ride_by_attack',
      'srd35_feat_shot_on_the_run','srd35_feat_spring_attack','srd35_feat_spirited_charge',
      'srd35_feat_trample','srd35_feat_two_weapon_fighting','srd35_feat_weapon_finesse',
      'foco_em_arma','srd35_feat_weapon_specialization','srd35_feat_greater_weapon_focus',
      'srd35_feat_greater_weapon_specialization','srd35_feat_whirlwind_attack',
      'srd35_feat_improved_unarmed_strike','reflexos_de_combate','srd35_feat_stunning_fist'
    ) THEN RAISE EXCEPTION 'Este talento não faz parte da lista de bônus do Guerreiro.'; END IF;

    SELECT f.* INTO v_feat FROM public.srd_feats f WHERE f.id=v_feat_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Talento do catálogo não encontrado.'; END IF;
    v_req:=COALESCE(v_feat.requisitos,'{}'::jsonb);
    IF COALESCE(v_req->>'type','General')<>'General' THEN
      RAISE EXCEPTION 'O talento bônus do Guerreiro precisa ser geral.';
    END IF;
    IF v_feat.exige_parametro AND v_param='' THEN
      RAISE EXCEPTION 'Informe o parâmetro exigido por %.',v_feat.nome;
    ELSIF NOT COALESCE(v_feat.exige_parametro,false) AND v_param<>'' THEN
      RAISE EXCEPTION '% não aceita parâmetro.',v_feat.nome;
    END IF;
    IF v_feat_id=ANY(v_owned) THEN RAISE EXCEPTION 'O personagem já possui %.',v_feat.nome; END IF;

    FOR v_stat_key IN SELECT unnest(ARRAY['FOR','DES','CON','INT','SAB','CAR']) LOOP
      v_required:=COALESCE(NULLIF(v_req->>(lower(v_stat_key)||'_min'),'')::integer,0);
      IF COALESCE(NULLIF(v_sheet.atributos->>v_stat_key,'')::integer,10)<v_required THEN
        RAISE EXCEPTION '% exige % %.',v_feat.nome,v_stat_key,v_required;
      END IF;
    END LOOP;
    v_required:=COALESCE(NULLIF(v_req->>'bab_min','')::integer,0);
    IF v_bab<v_required THEN RAISE EXCEPTION '% exige BBA +%.',v_feat.nome,v_required; END IF;
    IF COALESCE(NULLIF(v_req->>'class_level_min','')::integer,0)>1
       OR (NULLIF(v_req->>'class_key_required','') IS NOT NULL AND v_req->>'class_key_required'<>'fighter') THEN
      RAISE EXCEPTION 'O nível de Guerreiro ainda não atende aos pré-requisitos de %.',v_feat.nome;
    END IF;
    FOR v_feature IN SELECT value FROM jsonb_array_elements_text(COALESCE(v_req->'feat_ids','[]'::jsonb)) AS prereq(value) LOOP
      IF NOT (v_feature=ANY(v_owned)) THEN
        RAISE EXCEPTION '% exige o talento prévio %.',v_feat.nome,v_feature;
      END IF;
    END LOOP;
    IF v_req ? 'skill_ranks' THEN
      FOR v_stat_key IN SELECT key FROM jsonb_each(v_req->'skill_ranks') LOOP
        IF COALESCE(NULLIF(v_sheet.pericias->>v_stat_key,'')::numeric,0)<COALESCE(NULLIF(v_req->'skill_ranks'->>v_stat_key,'')::numeric,0) THEN
          RAISE EXCEPTION '% exige mais graduações em %.',v_feat.nome,v_stat_key;
        END IF;
      END LOOP;
    END IF;
    IF v_param<>'' AND COALESCE(v_req->>'parameter_type','') IN ('weapon','weapon_martial','weapon_exotic','crossbow') THEN
      SELECT e.nome,e.detalhes INTO v_weapon_name,v_weapon_details
        FROM public.srd_equipment e
       WHERE e.categoria='arma'
         AND public.srd35_normalizar_parametro_talento(e.nome)=public.srd35_normalizar_parametro_talento(v_param)
       LIMIT 1;
      IF NOT FOUND THEN RAISE EXCEPTION 'Arma escolhida não existe no catálogo SRD.'; END IF;
      v_weapon_prof:=COALESCE(v_weapon_details->>'weapon_proficiency','');
      IF COALESCE(v_req->>'parameter_type','')='weapon_martial' AND v_weapon_prof<>'martial' THEN
        RAISE EXCEPTION 'Escolha uma arma marcial.';
      ELSIF COALESCE(v_req->>'parameter_type','')='weapon_exotic' AND v_weapon_prof<>'exotic' THEN
        RAISE EXCEPTION 'Escolha uma arma exótica.';
      END IF;
      IF COALESCE((v_req->>'weapon_proficiency_required')::boolean,false) THEN
        v_has_prof:=EXISTS(
          SELECT 1 FROM jsonb_array_elements_text(COALESCE(v_class.dados_tecnicos->'proficiencias'->'armas','[]'::jsonb)) AS prof(value)
           WHERE public.srd35_normalizar_parametro_talento(prof.value)=public.srd35_normalizar_parametro_talento(v_weapon_name)
              OR (public.srd35_normalizar_parametro_talento(prof.value)='armassimples' AND v_weapon_prof='simple')
              OR (public.srd35_normalizar_parametro_talento(prof.value)='todasasarmassimplesemarciais' AND v_weapon_prof IN ('simple','martial'))
        );
        IF NOT v_has_prof THEN RAISE EXCEPTION 'Guerreiro não é proficiente com %.',v_weapon_name; END IF;
      END IF;
    END IF;
    v_updated:=v_existing||jsonb_build_array(jsonb_build_object('id',v_feat_id,'parametro',NULLIF(v_param,''),'origem','class_bonus'));
    v_added:=array_append(v_added,v_feat_id);

  ELSIF v_class_key='monk' THEN
    v_entry:=p_talentos->0;
    IF jsonb_typeof(v_entry)<>'object' THEN RAISE EXCEPTION 'Escolha um talento bônus válido para Monge.'; END IF;
    v_feat_id:=NULLIF(BTRIM(v_entry->>'id'),'');
    IF v_feat_id NOT IN ('srd35_feat_improved_grapple','srd35_feat_stunning_fist') THEN
      RAISE EXCEPTION 'No nível 1, Monge escolhe Agarrar Aprimorado ou Ataque Atordoante.';
    END IF;
    IF v_feat_id=ANY(v_owned) THEN RAISE EXCEPTION 'O personagem já possui esse talento.'; END IF;
    IF NOT ('srd35_feat_improved_unarmed_strike'=ANY(v_owned)) THEN
      v_updated:=v_existing||jsonb_build_array(jsonb_build_object('id','srd35_feat_improved_unarmed_strike','parametro',null,'origem','class_feature'));
      v_added:=array_append(v_added,'srd35_feat_improved_unarmed_strike');
    ELSE
      v_updated:=v_existing;
    END IF;
    v_updated:=v_updated||jsonb_build_array(jsonb_build_object('id',v_feat_id,'parametro',null,'origem','class_bonus'));
    v_added:=array_append(v_added,v_feat_id);

  ELSIF v_class_key='wizard' THEN
    IF jsonb_array_length(p_talentos)<>0 THEN RAISE EXCEPTION 'Mago recebe Escrever Pergaminho automaticamente; não escolha talento de classe aqui.'; END IF;
    IF NOT ('srd35_feat_scribe_scroll'=ANY(v_owned)) THEN
      v_updated:=v_existing||jsonb_build_array(jsonb_build_object('id','srd35_feat_scribe_scroll','parametro',null,'origem','class_feature'));
      v_added:=array_append(v_added,'srd35_feat_scribe_scroll');
    ELSE
      v_updated:=v_existing;
    END IF;
  ELSE
    IF jsonb_array_length(p_talentos)<>0 THEN RAISE EXCEPTION 'Esta classe não recebe uma escolha de talento bônus no nível 1.'; END IF;
    v_updated:=v_existing;
  END IF;

  UPDATE public.srd_character_sheets
     SET talentos=v_updated
   WHERE character_id=v_character.id;

  RETURN jsonb_build_object('character_id',v_character.id::text,'class_key',v_class_key,'added',to_jsonb(v_added),'talentos',v_updated);
END;
$$;

REVOKE ALL ON FUNCTION public.salvar_talentos_bonus_classe_inicial_srd(TEXT,JSONB) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.salvar_talentos_bonus_classe_inicial_srd(TEXT,JSONB) TO authenticated;
NOTIFY pgrst,'reload schema';
