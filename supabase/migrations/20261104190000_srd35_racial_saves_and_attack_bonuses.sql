DO $migration$
DECLARE
  v_def text;
  v_new text;
  v_old text;
  v_replacement text;
  r record;
BEGIN
  -- D&D 3.5 Livro do Jogador: bônus raciais nos testes de resistência.
  v_def := pg_get_functiondef('priv.srd_saving_throw_bonus(bigint,text,text,text,text)'::regprocedure);
  v_old := $old$
  -- Dwarf racial resistance: +2 on saves against poison and spells/spell-like effects.
  IF p_target_kind='character'
     AND v_sheet.raca_id='anao'
     AND (
       lower(COALESCE(p_context,'')) LIKE '%poison%'
       OR lower(COALESCE(p_context,'')) LIKE '%spell%'
     ) THEN
    v_bonus:=v_bonus+2;
  END IF;
$old$;
  v_replacement := $new$
  -- D&D 3.5 Livro do Jogador, Cap. 2: resistências raciais.
  IF p_target_kind='character' THEN
    -- Anão: +2 contra venenos e magias/efeitos similares a magia.
    IF v_sheet.raca_id='anao'
       AND (lower(COALESCE(p_context,'')) LIKE '%poison%'
         OR lower(COALESCE(p_context,'')) LIKE '%spell%') THEN
      v_bonus:=v_bonus+2;
    END IF;
    -- Halfling: +1 em todos os testes de resistência; +2 moral adicional contra medo.
    IF v_sheet.raca_id='halfling' THEN
      v_bonus:=v_bonus+1;
      IF lower(COALESCE(p_context,'')) LIKE '%fear%' THEN
        v_bonus:=v_bonus+2;
      END IF;
    END IF;
    -- Elfo e meio-elfo: +2 contra magias/efeitos de Encantamento.
    IF v_sheet.raca_id IN ('elfo','meio_elfo')
       AND lower(COALESCE(p_context,'')) LIKE '%enchantment%' THEN
      v_bonus:=v_bonus+2;
    END IF;
    -- Gnomo: +2 contra ilusões.
    IF v_sheet.raca_id='gnomo'
       AND lower(COALESCE(p_context,'')) LIKE '%illusion%' THEN
      v_bonus:=v_bonus+2;
    END IF;
  END IF;
$new$;
  IF position(v_old in v_def)>0 THEN
    v_new:=replace(v_def,v_old,v_replacement);
    EXECUTE v_new;
  ELSIF position('D&D 3.5 Livro do Jogador, Cap. 2: resistências raciais.' in v_def)=0 THEN
    RAISE EXCEPTION 'Não foi possível localizar o bloco racial esperado em srd_saving_throw_bonus; migração interrompida.';
  END IF;

  -- A resolução de resistência de magia precisa identificar a escola Ilusão,
  -- para que o bônus do Gnomo seja aplicado no mesmo teste manual de d20.
  v_def := pg_get_functiondef('public.srd_resolve_pending_spell_save(uuid,integer)'::regprocedure);
  v_old := $old$CASE WHEN COALESCE(v_school,'') LIKE '%enchant%' THEN 'enchantment' END$old$;
  v_replacement := $new$CASE WHEN COALESCE(v_school,'') LIKE '%enchant%' THEN 'enchantment' END,
    CASE WHEN COALESCE(v_school,'') LIKE '%illusion%' THEN 'illusion' END$new$;
  IF position(v_old in v_def)>0 THEN
    EXECUTE replace(v_def,v_old,v_replacement);
  ELSIF position('THEN ''illusion'' END' in v_def)=0 THEN
    RAISE EXCEPTION 'Não foi possível incluir contexto de Ilusão na resolução de magias.';
  END IF;

  -- Testes de resistência solicitados pelo Mestre também aceitam contexto de Ilusão.
  v_def := pg_get_functiondef('public.srd_resolve_requested_saving_throw_srd(bigint,text,text,integer)'::regprocedure);
  v_old := $old$IF v_context NOT IN ('','trap','poison','spell','enchantment','fear','fear,enchantment','spell,enchantment','spell,fear','spell,fear,enchantment') THEN$old$;
  v_replacement := $new$IF v_context<>'' AND NOT (string_to_array(v_context,',') <@ ARRAY['trap','poison','spell','enchantment','fear','illusion']) THEN$new$;
  IF position(v_old in v_def)>0 THEN
    EXECUTE replace(v_def,v_old,v_replacement);
  ELSIF position('string_to_array(v_context' in v_def)=0 THEN
    RAISE EXCEPTION 'Não foi possível atualizar a lista de contextos de resistência.';
  END IF;

  -- Bônus de ataque racial: o servidor deve validar o mesmo total que a mesa
  -- apresenta. Anão: +1 contra orcs/goblinóides. Gnomo: +1 contra kobolds/goblinóides.
  FOR r IN
    SELECT p.oid
      FROM pg_proc p
      JOIN pg_namespace n ON n.oid=p.pronamespace
     WHERE n.nspname='public'
       AND p.proname='aplicar_dano_token_ataque_srd_v2'
       AND p.prokind='f'
  LOOP
    v_def:=pg_get_functiondef(r.oid);
    v_new:=v_def;
    v_new:=replace(v_new,
      'v_expected_bonus INTEGER;',
      'v_expected_bonus INTEGER; v_racial_attack_bonus INTEGER:=0; v_target_traits TEXT;');
    v_old:='v_expected_bonus:=v_bab+v_ability_mod+v_size_modifier+v_weapon_focus-v_power_penalty-v_range_penalty-v_weapon_proficiency_penalty;';
    v_replacement:=$attack$
v_target_traits:=lower(concat_ws(' ',
  v_target->>'nome',v_target->>'detalhe',
  v_target->'monsterStats'->>'tipo',v_target->'monsterStats'->>'subtipo',
  v_target->'monsterStats'->>'subtype',v_target->'monsterStats'->>'subtypes',
  v_target->'monsterStats'->>'type',v_target->'monsterStats'->>'creature_type',
  v_target->'monsterStats'->>'race_id',v_target->>'creature_type'
));
IF v_sheet.raca_id='anao'
   AND v_target_traits ~ '(orc|goblin|hobgoblin|bugbear|goblinoid)' THEN
  v_racial_attack_bonus:=1;
ELSIF v_sheet.raca_id='gnomo'
   AND v_target_traits ~ '(kobold|goblin|hobgoblin|bugbear|goblinoid)' THEN
  v_racial_attack_bonus:=1;
END IF;
v_expected_bonus:=v_bab+v_ability_mod+v_size_modifier+v_weapon_focus-v_power_penalty-v_range_penalty-v_weapon_proficiency_penalty+v_racial_attack_bonus;
$attack$;
    IF position(v_old in v_new)>0 THEN
      v_new:=replace(v_new,v_old,v_replacement);
    ELSIF position('v_racial_attack_bonus' in v_new)=0 THEN
      RAISE EXCEPTION 'Não foi possível alinhar o bônus racial no overload %.',r.oid::regprocedure;
    END IF;
    IF v_new<>v_def THEN EXECUTE v_new; END IF;
  END LOOP;
END
$migration$;