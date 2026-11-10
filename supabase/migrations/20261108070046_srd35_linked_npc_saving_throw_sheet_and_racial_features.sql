
do $patch$
declare
 v_def text; nl text:=chr(10); v_fallback text; v_linked text; v_old text;
begin
 v_def:=pg_get_functiondef('priv.srd_saving_throw_bonus(bigint,text,text,text,text)'::regprocedure);
 v_fallback:=
 '    v_save_text:=CASE v_save'||nl||
 '      WHEN ''fortitude'' THEN COALESCE(v_token->''monsterStats''->>''fortitude'',v_token->''monsterStats''->>''fort'')'||nl||
 '      WHEN ''reflex'' THEN COALESCE(v_token->''monsterStats''->>''reflexos'',v_token->''monsterStats''->>''reflex'')'||nl||
 '      ELSE COALESCE(v_token->''monsterStats''->>''vontade'',v_token->''monsterStats''->>''will'') END;'||nl||
 '    v_base:=COALESCE(NULLIF(substring(COALESCE(v_save_text,'''') FROM ''[-+]?[0-9]+''),'''')::integer,0);'||nl||
 '    v_bonus:=v_base;';
 v_linked:=
 '    IF NULLIF(v_token->>''sourceCharacterId'','''') IS NOT NULL THEN'||nl||
 '      SELECT sh.* INTO v_sheet FROM public.srd_character_sheets sh'||nl||
 '      JOIN public.characters ch ON ch.id=sh.character_id'||nl||
 '      WHERE ch.id::text=NULLIF(v_token->>''sourceCharacterId'','''');'||nl||
 '    END IF;'||nl||
 '    IF v_sheet.character_id IS NOT NULL THEN'||nl||
 '      v_ability:=CASE v_save WHEN ''fortitude'' THEN ''CON'' WHEN ''reflex'' THEN ''DES'' ELSE ''SAB'' END;'||nl||
 '      v_score:=COALESCE(NULLIF(v_sheet.atributos->>v_ability,'''')::integer,10);'||nl||
 '      v_ability_effect:=CASE v_save WHEN ''fortitude'' THEN ''constitution'' WHEN ''reflex'' THEN ''dexterity'' ELSE ''wisdom'' END;'||nl||
 '      v_score:=v_score+priv.srd_effective_modifier(p_campaign_id,''token'',BTRIM(p_target_id),v_ability_effect);'||nl||
 '      v_feats:=COALESCE(v_sheet.talentos,''[]''::jsonb);'||nl||
 '      SELECT COALESCE(sum(CASE v_save WHEN ''fortitude'' THEN pr.base_fortitude WHEN ''reflex'' THEN pr.base_reflex ELSE pr.base_will END),0)::integer'||nl||
 '        INTO v_base FROM public.srd_character_class_levels cl'||nl||
 '        JOIN public.srd_class_level_progressions pr ON pr.class_id=cl.class_id AND pr.class_level=cl.class_level'||nl||
 '       WHERE cl.character_id=v_sheet.character_id;'||nl||
 '      IF NOT EXISTS(SELECT 1 FROM public.srd_character_class_levels WHERE character_id=v_sheet.character_id) THEN'||nl||
 '        SELECT CASE v_save WHEN ''fortitude'' THEN pr.base_fortitude WHEN ''reflex'' THEN pr.base_reflex ELSE pr.base_will END'||nl||
 '          INTO v_base FROM public.srd_class_level_progressions pr'||nl||
 '         WHERE pr.class_id=v_sheet.classe_id AND pr.class_level=v_sheet.nivel;'||nl||
 '        IF v_base IS NULL THEN'||nl||
 '          SELECT CASE v_save'||nl||
 '            WHEN ''fortitude'' THEN CASE WHEN cl.fort_bom THEN floor(v_sheet.nivel/2.0)::integer+2 ELSE floor(v_sheet.nivel/3.0)::integer END'||nl||
 '            WHEN ''reflex'' THEN CASE WHEN cl.ref_bom THEN floor(v_sheet.nivel/2.0)::integer+2 ELSE floor(v_sheet.nivel/3.0)::integer END'||nl||
 '            ELSE CASE WHEN cl.von_bom THEN floor(v_sheet.nivel/2.0)::integer+2 ELSE floor(v_sheet.nivel/3.0)::integer END END'||nl||
 '            INTO v_base FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;'||nl||
 '        END IF;'||nl||
 '      END IF;'||nl||
 '      v_bonus:=COALESCE(v_base,0)+FLOOR((v_score-10)::numeric/2)::integer+priv.srd_feat_saving_throw_modifier(v_feats,v_save);'||nl||
 '    ELSE'||nl||v_fallback||nl||
 '    END IF;';
 if position(v_fallback in v_def)=0 then raise exception 'Bloco original de resistência de token não encontrado.'; end if;
 v_def:=replace(v_def,v_fallback,v_linked);

 v_def:=replace(v_def,
 '  -- D&D 3.5: Graça Divina adiciona o modificador positivo de Carisma a todos os testes de resistência a partir do 2º nível de Paladino.'||nl||
 '  IF p_target_kind=''character'' THEN',
 '  -- D&D 3.5: Graça Divina também usa a ficha vinculada quando o alvo é um NPC.'||nl||
 '  IF v_sheet.character_id IS NOT NULL THEN');
 v_def:=replace(v_def,
 '     AND p_target_kind=''character'' THEN'||nl||
 '    SELECT COALESCE(',
 '     AND v_sheet.character_id IS NOT NULL THEN'||nl||
 '    SELECT COALESCE(');
 v_def:=replace(v_def,
 '     AND p_target_kind=''character'''||nl||
 '     AND priv.srd_effect_has_flag',
 '     AND v_sheet.character_id IS NOT NULL'||nl||
 '     AND priv.srd_effect_has_flag');
 v_def:=replace(v_def,
 '     AND p_target_kind=''character'' THEN'||nl||
 '    SELECT COALESCE(',
 '     AND v_sheet.character_id IS NOT NULL THEN'||nl||
 '    SELECT COALESCE(');
 v_def:=replace(v_def,
 '  -- D&D 3.5 Livro do Jogador, Cap. 2: resistências raciais.'||nl||
 '  IF p_target_kind=''character'' THEN',
 '  -- D&D 3.5 Livro do Jogador, Cap. 2: resistências raciais para fichas e NPCs vinculados.'||nl||
 '  IF v_sheet.character_id IS NOT NULL THEN');
 if position('IF v_sheet.character_id IS NOT NULL THEN' in v_def)=0
    or position('sourceCharacterId' in v_def)=0 then
  raise exception 'Integração da ficha de origem para resistências não foi aplicada.';
 end if;
 execute v_def;
end
$patch$;
