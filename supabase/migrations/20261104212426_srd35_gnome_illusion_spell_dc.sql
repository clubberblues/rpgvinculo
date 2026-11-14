DO $migration$
DECLARE
  r record;
  v_def text;
  v_new text;
  v_old text;
  v_replacement text;
BEGIN
  -- Livro do Jogador 3.5, Cap. 2: +1 na CD das ilusões conjuradas por um Gnomo.
  FOR r IN
    SELECT p.oid
      FROM pg_proc p
     WHERE p.prokind='f'
       AND p.proname IN (
         'conjurar_magia_dano_multialvo_srd',
         'conjurar_magia_efeitos_multialvo',
         'conjurar_magia_srd_manual'
       )
  LOOP
    v_def:=pg_get_functiondef(r.oid);
    v_new:=v_def;
    v_old:='v_save_dc:=CASE WHEN v_save_type IS NOT NULL THEN 10+v_spell_level+FLOOR((v_score-10)::numeric/2)::integer ELSE NULL END;';
    v_replacement:='v_save_dc:=CASE WHEN v_save_type IS NOT NULL THEN 10+v_spell_level+FLOOR((v_score-10)::numeric/2)::integer+CASE WHEN v_sheet.raca_id=''gnomo'' AND lower(COALESCE(v_spell.escola,'''') ) LIKE ''%illusion%'' THEN 1 ELSE 0 END ELSE NULL END;';
    v_new:=replace(v_new,v_old,v_replacement);

    v_old:='IF v_save_type IS NOT NULL THEN v_save_dc:=10+v_spell_level+FLOOR((v_score-10)::numeric/2)::integer; END IF;';
    v_replacement:='IF v_save_type IS NOT NULL THEN v_save_dc:=10+v_spell_level+FLOOR((v_score-10)::numeric/2)::integer+CASE WHEN v_sheet.raca_id=''gnomo'' AND lower(COALESCE(v_spell.escola,'''') ) LIKE ''%illusion%'' THEN 1 ELSE 0 END; END IF;';
    v_new:=replace(v_new,v_old,v_replacement);

    v_old:='v_save_dc:=CASE WHEN v_save_type IS NOT NULL THEN 10+v_circle+FLOOR((v_score-10)::numeric/2)::integer ELSE NULL END;';
    v_replacement:='v_save_dc:=CASE WHEN v_save_type IS NOT NULL THEN 10+v_circle+FLOOR((v_score-10)::numeric/2)::integer+CASE WHEN v_sheet.raca_id=''gnomo'' AND lower(COALESCE(v_spell.escola,'''') ) LIKE ''%illusion%'' THEN 1 ELSE 0 END ELSE NULL END;';
    v_new:=replace(v_new,v_old,v_replacement);

    IF v_new=v_def THEN
      RAISE EXCEPTION 'Não foi possível localizar cálculo de CD de resistência em %.',r.oid::regprocedure;
    END IF;
    EXECUTE v_new;
  END LOOP;
END
$migration$;