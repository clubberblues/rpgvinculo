CREATE OR REPLACE FUNCTION public.criar_mago_ficha_original_v2(p_nome text, p_raca_id text, p_atributos_base jsonb, p_pericias jsonb, p_talentos jsonb, p_identidade jsonb, p_magias_primeiro_circulo text[], p_idiomas text[], p_equipamentos jsonb, p_ficha jsonb)
 RETURNS bigint
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare
  v_user uuid := auth.uid();
  v_class public.srd_classes%rowtype;
  v_race public.srd_races%rowtype;
  v_sheet public.srd_character_sheets%rowtype;
  v_character_id text;
  v_identity jsonb;
  v_specialization text;
  v_prohibited jsonb;
  v_required_prohibited integer;
  v_int_score integer;
  v_spell_capacity integer;
  v_selected_count integer;
  v_valid_selected_count integer;
  v_cantrips text[];
  v_known_spells text[];
  v_spell_state jsonb;
  v_skill_points_spent jsonb := '{}'::jsonb;
begin
  if v_user is null then
    raise exception 'É necessário estar autenticado.';
  end if;

  if nullif(btrim(p_nome), '') is null or char_length(btrim(p_nome)) not between 2 and 40 then
    raise exception 'O nome do personagem deve ter entre 2 e 40 caracteres.';
  end if;
  if jsonb_typeof(p_atributos_base) <> 'object'
     or jsonb_typeof(p_pericias) <> 'object'
     or jsonb_typeof(p_talentos) <> 'array'
     or jsonb_typeof(p_identidade) <> 'object'
     or jsonb_typeof(p_equipamentos) <> 'array'
     or jsonb_typeof(p_ficha) <> 'object'
     or p_ficha->>'version' <> '2'
     or jsonb_typeof(p_ficha->'fields') <> 'object' then
    raise exception 'Dados da ficha original do Mago incompletos ou em formato inválido.';
  end if;
  if p_idiomas is null then
    raise exception 'Informe a lista de idiomas (pode estar vazia).';
  end if;
  if p_magias_primeiro_circulo is null then
    raise exception 'Informe as magias iniciais de 1º círculo.';
  end if;
  if exists (
    select 1 from jsonb_array_elements(p_equipamentos) item
    where jsonb_typeof(item.value) <> 'object'
       or nullif(btrim(item.value->>'nome'), '') is null
  ) then
    raise exception 'Cada equipamento precisa ter um nome.';
  end if;

  select * into v_class
  from public.srd_classes
  where id = 'mago' and class_key = 'wizard';
  if not found then
    raise exception 'A classe Mago não está configurada no catálogo SRD.';
  end if;

  select * into v_race
  from public.srd_races
  where id = nullif(btrim(p_raca_id), '');
  if not found then
    raise exception 'Raça SRD não encontrada.';
  end if;

  v_specialization := coalesce(nullif(btrim(p_identidade->>'wizard_specialization'), ''), 'universalista');
  v_prohibited := coalesce(p_identidade->'wizard_prohibited_schools', '[]'::jsonb);
  if jsonb_typeof(v_prohibited) <> 'array' then
    raise exception 'A lista de escolas proibidas deve ser uma lista.';
  end if;

  if v_specialization = 'universalista' then
    if jsonb_array_length(v_prohibited) <> 0 then
      raise exception 'O Mago Universalista não possui escolas proibidas.';
    end if;
  elsif v_specialization in ('abjuration','conjuration','divination','enchantment','evocation','illusion','necromancy','transmutation') then
    v_required_prohibited := case when v_specialization = 'divination' then 1 else 2 end;
    if jsonb_array_length(v_prohibited) <> v_required_prohibited then
      raise exception 'A especialização escolhida exige % escola(s) proibida(s).', v_required_prohibited;
    end if;
    if exists (
      select 1
      from jsonb_array_elements_text(v_prohibited) x(value)
      where x.value not in ('abjuration','conjuration','divination','enchantment','evocation','illusion','necromancy','transmutation')
         or x.value = v_specialization
    ) then
      raise exception 'Escola proibida inválida ou igual à escola de especialização.';
    end if;
    if (select count(*) from jsonb_array_elements_text(v_prohibited))
       <> (select count(distinct value) from jsonb_array_elements_text(v_prohibited) t(value)) then
      raise exception 'Não repita escolas proibidas.';
    end if;
  else
    raise exception 'Escolha uma escola de especialização válida ou Universalista.';
  end if;

  -- Cria somente o registro-base e aplica a regra de atributos/ajustes raciais.
  -- A interface antiga de criação não é chamada.
  v_character_id := public.criar_personagem_srd(
    btrim(p_nome), v_race.id, v_class.id, p_atributos_base
  );

  select * into v_sheet
  from public.srd_character_sheets
  where character_id::text = v_character_id
  for update;
  if not found then
    raise exception 'Não foi possível recuperar a ficha recém-criada.';
  end if;

  v_int_score := (v_sheet.atributos->>'INT')::integer;
  v_spell_capacity := greatest(3, 3 + floor((v_int_score - 10)::numeric / 2)::integer);
  v_selected_count := cardinality(p_magias_primeiro_circulo);

  if v_selected_count <> v_spell_capacity then
    raise exception 'Com Inteligência %, o Mago deve escolher exatamente % magia(s) de 1º círculo.', v_int_score, v_spell_capacity;
  end if;
  if v_selected_count <> (
    select count(distinct spell_id) from unnest(p_magias_primeiro_circulo) as picked(spell_id)
  ) then
    raise exception 'Não repita magias no grimório inicial.';
  end if;

  select count(*)::integer into v_valid_selected_count
  from unnest(p_magias_primeiro_circulo) as picked(spell_id)
  join public.srd_spells sp on sp.id = picked.spell_id
  where sp.circulo = 1
    and public._srd35_spell_class_ok(sp.classes, 'wizard')
    and public._srd35_spell_level_for_class(sp.nivel, 'wizard', sp.circulo) = 1
    and not coalesce(public._srd35_school_key(sp.escola) = any(array(
      select jsonb_array_elements_text(v_prohibited)
    )), false);

  if v_valid_selected_count <> v_selected_count then
    raise exception 'Uma ou mais magias escolhidas não pertencem ao 1º círculo do Mago ou estão em escola proibida.';
  end if;

  select coalesce(array_agg(sp.id order by sp.id), array[]::text[])
    into v_cantrips
  from public.srd_spells sp
  where public._srd35_spell_level_for_class(sp.nivel, 'wizard', sp.circulo) = 0
    and public._srd35_spell_class_ok(sp.classes, 'wizard')
    and not coalesce(public._srd35_school_key(sp.escola) = any(array(
      select jsonb_array_elements_text(v_prohibited)
    )), false);

  v_known_spells := coalesce(v_cantrips, array[]::text[]) || p_magias_primeiro_circulo;

  v_identity := (p_identidade - 'ficha_mago_v2' - 'wizard_specialization' - 'wizard_prohibited_schools' - 'idiomas_livres')
    || jsonb_build_object(
      'wizard_specialization', v_specialization,
      'wizard_prohibited_schools', v_prohibited,
      'idiomas_livres', to_jsonb(p_idiomas),
      'ficha_mago_v2', p_ficha,
      'sheet_schema_version', 2,
      'character_creation_source', 'original_mage_sheet_v2',
      'class_id', v_class.id,
      'race_id', v_race.id
    );

  update public.srd_character_sheets
  set identidade = v_identity,
      idiomas_conhecidos = jsonb_build_object(
        'automaticos', '[]'::jsonb,
        'bonus_inteligencia', '[]'::jsonb,
        'comprados_falar_idioma', '[]'::jsonb,
        'livres', to_jsonb(p_idiomas)
      ),
      equipamento_inicial = jsonb_build_object(
        'version', 1,
        'source', 'original_mage_sheet_v2',
        'items', p_equipamentos
      ),
      pericias_treinadas = coalesce((
        select jsonb_agg(key order by key)
        from jsonb_each(p_pericias) e(key,value)
        where jsonb_typeof(value) = 'number' and (value #>> '{}')::numeric > 0
      ), '[]'::jsonb)
  where character_id = v_sheet.character_id;

  if nullif(p_identidade->>'idade', '') is not null
     and (p_identidade->>'idade') ~ '^[0-9]{1,3}$' then
    update public.characters
    set idade = (p_identidade->>'idade')::integer
    where id = v_sheet.character_id and user_id = v_user;
  end if;

  -- Regras de perícias e talentos existentes são chamadas como validadores de domínio,
  -- não como fluxo ou interface de criação antiga.
  perform public.salvar_pericias_srd(v_character_id, p_pericias);
  perform public.salvar_talentos_srd(v_character_id, p_talentos);

  select * into v_sheet
  from public.srd_character_sheets
  where character_id = v_sheet.character_id;

  select coalesce(jsonb_object_agg(
    skill.key,
    to_jsonb(
      (skill.value #>> '{}')::numeric *
      case
        when skill.key = 'srd35_skill_speak_language' or exists (
          select 1
          from jsonb_array_elements_text(coalesce(v_class.pericias_classe, '[]'::jsonb)) as class_skill(name)
          where public.srd35_normalizar_parametro_talento(class_skill.name)
              = public.srd35_normalizar_parametro_talento(sk.nome)
             or (
               public.srd35_normalizar_parametro_talento(class_skill.name) = 'conhecimentoqualquer'
               and sk.nome ilike 'Conhecimento%'
             )
        ) then 1 else 2
      end
    )
  ), '{}'::jsonb)
  into v_skill_points_spent
  from jsonb_each(coalesce(v_sheet.pericias, '{}'::jsonb)) as skill(key,value)
  join public.srd_skills sk
    on sk.id = skill.key
    or (skill.key like 'srd35_skill_oficio_%' and sk.id = 'oficio')
    or (skill.key like 'srd35_skill_profissao_%' and sk.id = 'profissao')
  where jsonb_typeof(skill.value) = 'number';

  insert into public.srd_character_class_levels
    (character_id, class_id, class_level, taken_at_character_level, hit_points_gained, skill_points_spent)
  values
    (v_sheet.character_id, v_class.id, 1, 1, v_sheet.pv_max, v_skill_points_spent)
  on conflict (character_id, class_id) do nothing;

  v_spell_state := jsonb_build_object(
    'version', 1,
    'conhecidas', to_jsonb(v_known_spells),
    'preparadas', '[]'::jsonb,
    'usos', '{}'::jsonb,
    'aprendidas_por_nivel', '{}'::jsonb
  );

  -- Registra o grimório inicial; nenhuma magia é preparada e nenhum espaço diário é gasto.
  perform public.salvar_grimorio_srd(v_character_id, v_spell_state);

  insert into public.srd_character_spellbook (character_id, class_id, spell_id, source_note)
  select v_sheet.character_id, v_class.id, spell_id, 'Grimório inicial — ficha original v2'
  from unnest(v_known_spells) as spells(spell_id)
  on conflict (character_id, class_id, spell_id) do nothing;

  insert into public.srd_character_known_spells (character_id, class_id, spell_id, learned_at_character_level, source_note)
  select v_sheet.character_id, v_class.id, spell_id, 1, 'Grimório inicial — ficha original v2'
  from unnest(v_known_spells) as spells(spell_id)
  on conflict (character_id, class_id, spell_id) do nothing;

  update public.srd_character_sheets
  set magias_conhecidas = to_jsonb(v_known_spells)
  where character_id = v_sheet.character_id;

  return v_sheet.character_id;
end;
$function$

REVOKE ALL ON FUNCTION public.criar_mago_ficha_original_v2(text,text,jsonb,jsonb,jsonb,jsonb,text[],text[],jsonb,jsonb) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.criar_mago_ficha_original_v2(text,text,jsonb,jsonb,jsonb,jsonb,text[],text[],jsonb,jsonb) FROM anon;
GRANT EXECUTE ON FUNCTION public.criar_mago_ficha_original_v2(text,text,jsonb,jsonb,jsonb,jsonb,text[],text[],jsonb,jsonb) TO authenticated;
