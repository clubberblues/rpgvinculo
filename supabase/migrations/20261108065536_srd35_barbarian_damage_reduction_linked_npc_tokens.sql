
do $patch$
declare v_def text; v_old text; v_new text;
begin
 v_def:=pg_get_functiondef('priv.srd_adjust_damage(bigint,text,text,text,integer)'::regprocedure);
 v_old:=E'  IF p_target_kind=''character'' AND v_type IN (''physical'',''slashing'',''piercing'',''bludgeoning'') THEN\n'
 || E'    SELECT COALESCE(\n'
 || E'      MAX(cl.class_level) FILTER (WHERE cl.class_id=''barbaro''),\n'
 || E'      CASE WHEN sh.classe_id=''barbaro'' THEN sh.nivel ELSE 0 END\n'
 || E'    )\n'
 || E'      INTO v_class_level\n'
 || E'      FROM public.srd_character_sheets sh\n'
 || E'      LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id\n'
 || E'     WHERE sh.character_id::text=BTRIM(p_target_id)\n'
 || E'     GROUP BY sh.character_id,sh.classe_id,sh.nivel;\n'
 || E'    IF v_class_level>=7 THEN\n'
 || E'      v_class_dr:=LEAST(5,GREATEST(0,FLOOR((v_class_level-4)::numeric/3)::integer));\n'
 || E'    END IF;\n'
 || E'  END IF;\n\n'
 || E'  v_damage:=GREATEST(0,p_base_damage-v_resistance-v_class_dr);';
 v_new:=v_old;
 v_new:=v_new || E'\n  IF p_target_kind=''token'' AND v_type IN (''physical'',''slashing'',''piercing'',''bludgeoning'')\n'
 || E'     AND NULLIF(v_token->>''sourceCharacterId'','''') IS NOT NULL THEN\n'
 || E'    SELECT COALESCE(\n'
 || E'      MAX(cl.class_level) FILTER (WHERE cl.class_id=''barbaro''),\n'
 || E'      CASE WHEN sh.classe_id=''barbaro'' THEN sh.nivel ELSE 0 END\n'
 || E'    ) INTO v_class_level\n'
 || E'    FROM public.srd_character_sheets sh\n'
 || E'    LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id\n'
 || E'    WHERE sh.character_id::text=NULLIF(v_token->>''sourceCharacterId'','''')\n'
 || E'    GROUP BY sh.character_id,sh.classe_id,sh.nivel;\n'
 || E'    IF v_class_level>=7 THEN\n'
 || E'      v_class_dr:=LEAST(5,GREATEST(0,FLOOR((v_class_level-4)::numeric/3)::integer));\n'
 || E'    END IF;\n'
 || E'  END IF;\n\n'
 || E'  v_damage:=GREATEST(0,p_base_damage-v_resistance-v_class_dr);';
 if position(v_old in v_def)=0 then raise exception 'Bloco atual de redução de dano não encontrado; nenhuma alteração aplicada.'; end if;
 v_def:=replace(v_def,v_old,v_new);
 execute v_def;
end
$patch$;
