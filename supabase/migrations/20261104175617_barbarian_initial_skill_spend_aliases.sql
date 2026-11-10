CREATE OR REPLACE FUNCTION public.criar_personagem_srd_completo(p_nome text, p_raca_id text, p_classe_id text, p_atributos jsonb, p_pericias jsonb, p_talentos jsonb, p_identidade jsonb)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare
  v_id text;
  v_race public.srd_races%rowtype;
  v_class public.srd_classes%rowtype;
  v_sex text;
  v_age integer;
  v_height numeric;
  v_weight numeric;
  v_height_min numeric;
  v_height_max numeric;
  v_weight_min numeric;
  v_weight_max numeric;
  v_alignment text;
  v_min_age integer;
  v_age_dice integer;
  v_age_physical integer := 0;
  v_age_mental integer := 0;
  v_sheet public.srd_character_sheets%rowtype;
  v_attrs jsonb;
  v_pv integer;
  v_identity jsonb;
  v_pick jsonb;
  v_feat public.srd_feats%rowtype;
  v_skill_points_spent jsonb := '{}'::jsonb;
  v_skill_spent numeric := 0;
  v_skill_budget integer := 0;
  v_specialization text;
  v_prohibited jsonb;
  v_required_prohibited integer;
  v_deity public.srd_deities%rowtype;
  v_deity_id text;
  v_cause text;
  v_char_law integer;
  v_char_good integer;
  v_deity_law integer;
  v_deity_good integer;
  v_cleric_domains text[];
  v_druid_bond text;
  v_druid_animal text;
  v_druid_domains text[];
begin
  if auth.uid() is null then
    raise exception 'É necessário estar autenticado.';
  end if;
  if jsonb_typeof(p_identidade) <> 'object' then
    raise exception 'Informe as escolhas de identidade do personagem.';
  end if;
  v_identity := p_identidade;

  select * into v_race from public.srd_races where id = p_raca_id;
  if not found then raise exception 'Raça não encontrada.'; end if;
  select * into v_class from public.srd_classes where id = p_classe_id;
  if not found then raise exception 'Classe não encontrada.'; end if;

  v_sex := lower(coalesce(v_identity->>'sexo',''));
  if v_sex not in ('masculino','feminino') then
    raise exception 'Selecione masculino ou feminino para aplicar a tabela racial de altura e peso.';
  end if;
  v_age := nullif(v_identity->>'idade','')::integer;
  v_height := nullif(v_identity->>'altura_cm','')::numeric;
  v_weight := nullif(v_identity->>'peso_kg','')::numeric;
  v_alignment := nullif(btrim(v_identity->>'tendencia'),'');
  if v_age is null or v_age < 1 then raise exception 'Informe uma idade válida.'; end if;
  if p_raca_id='humano' and v_sex='masculino' then v_height_min:=165;v_height_max:=210;v_weight_min:=62;v_weight_max:=140;
  elsif p_raca_id='humano' then v_height_min:=150;v_height_max:=195;v_weight_min:=44;v_weight_max:=122;
  elsif p_raca_id='anao' and v_sex='masculino' then v_height_min:=130;v_height_max:=145;v_weight_min:=67;v_weight_max:=113;
  elsif p_raca_id='anao' then v_height_min:=125;v_height_max:=140;v_weight_min:=52;v_weight_max:=98;
  elsif p_raca_id='elfo' and v_sex='masculino' then v_height_min:=150;v_height_max:=175;v_weight_min:=43;v_weight_max:=78;
  elsif p_raca_id='elfo' then v_height_min:=150;v_height_max:=175;v_weight_min:=41;v_weight_max:=76;
  elsif p_raca_id='gnomo' and v_sex='masculino' then v_height_min:=95;v_height_max:=110;v_weight_min:=20.5;v_weight_max:=20.5;
  elsif p_raca_id='gnomo' then v_height_min:=90;v_height_max:=105;v_weight_min:=17.5;v_weight_max:=17.5;
  elsif p_raca_id='meio-elfo' and v_sex='masculino' then v_height_min:=160;v_height_max:=195;v_weight_min:=52;v_weight_max:=114;
  elsif p_raca_id='meio-elfo' then v_height_min:=150;v_height_max:=185;v_weight_min:=42;v_weight_max:=104;
  elsif p_raca_id='meio-orc' and v_sex='masculino' then v_height_min:=170;v_height_max:=215;v_weight_min:=67;v_weight_max:=145;
  elsif p_raca_id='meio-orc' then v_height_min:=150;v_height_max:=195;v_weight_min:=47;v_weight_max:=125;
  elsif p_raca_id='halfling' and v_sex='masculino' then v_height_min:=85;v_height_max:=100;v_weight_min:=15.5;v_weight_max:=15.5;
  elsif p_raca_id='halfling' then v_height_min:=80;v_height_max:=95;v_weight_min:=12.5;v_weight_max:=12.5;
  else raise exception 'Não há tabela física para esta combinação de raça e sexo.'; end if;
  if v_height is null or v_height < v_height_min or v_height > v_height_max then
    raise exception 'Altura fora do intervalo da tabela racial (% a % cm).',v_height_min,v_height_max;
  end if;
  if v_weight is null or v_weight < v_weight_min or v_weight > v_weight_max then
    raise exception 'Peso fora do intervalo da tabela racial (% a % kg).',v_weight_min,v_weight_max;
  end if;
  if v_alignment not in ('Leal e Bom','Neutro e Bom','Caótico e Bom','Leal e Neutro','Neutro','Caótico e Neutro','Leal e Mau','Neutro e Mau','Caótico e Mau') then
    raise exception 'Selecione uma tendência válida.';
  end if;

  v_age_dice := case
    when v_class.id in ('barbaro','ladino','feiticeiro') then
      case p_raca_id when 'humano' then 1 when 'anao' then 3 when 'elfo' then 4 when 'gnomo' then 4 when 'meio-elfo' then 1 when 'meio-orc' then 1 when 'halfling' then 2 end
    when v_class.id in ('bardo','guerreiro','paladino','ranger') then
      case p_raca_id when 'humano' then 1 when 'anao' then 5 when 'elfo' then 6 when 'gnomo' then 6 when 'meio-elfo' then 2 when 'meio-orc' then 1 when 'halfling' then 3 end
    else
      case p_raca_id when 'humano' then 2 when 'anao' then 7 when 'elfo' then 10 when 'gnomo' then 9 when 'meio-elfo' then 3 when 'meio-orc' then 2 when 'halfling' then 4 end
  end;
  if v_age_dice is null then
    raise exception 'Raça ou classe sem tabela de idade inicial SRD 3.5.';
  end if;
  v_min_age := case p_raca_id when 'humano' then 15 when 'anao' then 40 when 'elfo' then 110 when 'gnomo' then 40 when 'meio-elfo' then 20 when 'meio-orc' then 14 when 'halfling' then 20 end + v_age_dice;
  if v_age < v_min_age then
    raise exception 'A idade mínima para a raça % e classe % é % anos (idade adulta + %d6, resultado mínimo).',p_raca_id,v_class.nome,v_min_age,v_age_dice;
  end if;

  if v_class.id in ('barbaro','bardo') and left(v_alignment,4)='Leal' then
    raise exception 'A classe % não pode ser Leal.',v_class.nome;
  elsif v_class.id='druida' and v_alignment not in ('Neutro e Bom','Leal e Neutro','Neutro','Caótico e Neutro','Neutro e Mau') then
    raise exception 'O Druida deve possuir uma tendência neutra.';
  elsif v_class.id='monge' and left(v_alignment,4)<>'Leal' then
    raise exception 'O Monge deve possuir uma tendência Leal.';
  elsif v_class.id='paladino' and v_alignment<>'Leal e Bom' then
    raise exception 'O Paladino deve ser Leal e Bom.';
  end if;
  if v_class.id='ranger' then
    if coalesce(v_identity->>'ranger_favored_enemy','') not in (
      'aberration','animal','construct','dragon','elemental','fey','giant','magical_beast',
      'monstrous_humanoid','ooze','plant','undead','vermin',
      'humanoid_aquatic','humanoid_dwarf','humanoid_elf','humanoid_gnoll','humanoid_gnome',
      'humanoid_goblinoid','humanoid_halfling','humanoid_human','humanoid_orc','humanoid_reptilian',
      'outsider_air','outsider_chaotic','outsider_earth','outsider_evil','outsider_fire',
      'outsider_good','outsider_lawful','outsider_native','outsider_water'
    ) then
      raise exception 'Escolha um inimigo predileto válido para o Patrulheiro.';
    end if;
  else
    v_identity := jsonb_set(v_identity,'{ranger_favored_enemy}','""'::jsonb,true);
  end if;


  if v_class.id in ('mago','feiticeiro') then
    if coalesce(v_identity->>'familiar_id','') not in
      ('','snake_small_viper','cat','lizard','rat','badger','owl','raven','hawk','bat','toad') then
      raise exception 'Escolha um familiar básico válido para Mago ou Feiticeiro.';
    end if;
  else
    v_identity := jsonb_set(v_identity,'{familiar_id}','""'::jsonb,true);
  end if;

  if v_class.id='druida' then
    v_druid_bond := coalesce(nullif(v_identity->>'druid_nature_bond',''),'companion');
    v_druid_animal := nullif(v_identity->>'druid_animal_companion_id','');
    select array_agg(value order by ordinality) into v_druid_domains
      from jsonb_array_elements_text(coalesce(v_identity->'druid_domain_ids','[]'::jsonb)) with ordinality as x(value,ordinality);
    if v_druid_bond='companion' then
      if v_druid_animal is null or v_druid_animal not in ('badger','camel','dire_rat','dog','dog_riding','eagle','hawk','horse_light','owl','pony','snake_small_viper','snake_medium_viper','wolf') then
        raise exception 'Escolha um companheiro animal básico permitido para o Druida de 1º nível.';
      end if;
      if not exists(select 1 from public.srd_monsters where id=v_druid_animal and tipo='Animal' and source_status='verified_srd') then
        raise exception 'O companheiro animal escolhido não está disponível no catálogo verificado.';
      end if;
      if coalesce(cardinality(v_druid_domains),0)<>0 then raise exception 'O Druida que escolhe companheiro animal não recebe domínio inicial.'; end if;
      v_identity := jsonb_set(v_identity,'{druid_nature_bond}','"companion"'::jsonb,true);
      v_identity := jsonb_set(v_identity,'{druid_animal_companion_id}',to_jsonb(v_druid_animal),true);
      v_identity := jsonb_set(v_identity,'{druid_domain_ids}','[]'::jsonb,true);
    elsif v_druid_bond='domain' then
      if v_druid_animal is not null then raise exception 'A escolha de domínio substitui o companheiro animal inicial.'; end if;
      if coalesce(cardinality(v_druid_domains),0)<>1 or v_druid_domains[1] not in ('air','animal','earth','fire','plant','water') then
        raise exception 'Escolha exatamente um domínio druídico válido.';
      end if;
      v_identity := jsonb_set(v_identity,'{druid_nature_bond}','"domain"'::jsonb,true);
      v_identity := jsonb_set(v_identity,'{druid_animal_companion_id}','""'::jsonb,true);
      v_identity := jsonb_set(v_identity,'{druid_domain_ids}',to_jsonb(v_druid_domains),true);
    else
      raise exception 'Escolha companheiro animal ou domínio para o vínculo com a natureza.';
    end if;
  else
    v_identity := jsonb_set(v_identity,'{druid_nature_bond}','"none"'::jsonb,true);
    v_identity := jsonb_set(v_identity,'{druid_animal_companion_id}','""'::jsonb,true);
    v_identity := jsonb_set(v_identity,'{druid_domain_ids}','[]'::jsonb,true);
  end if;

  if v_class.id='clerigo' then
    select array_agg(value order by ordinality) into v_cleric_domains
      from jsonb_array_elements_text(coalesce(v_identity->'cleric_domain_ids','[]'::jsonb)) with ordinality as x(value,ordinality);
    if coalesce(cardinality(v_cleric_domains),0)<>2 or v_cleric_domains[1]=v_cleric_domains[2] then
      raise exception 'Escolha dois domínios diferentes para o Clérigo.';
    end if;
    if (select count(*) from public.srd_domains where domain_id=any(v_cleric_domains))<>2 then
      raise exception 'Um dos domínios escolhidos não existe no catálogo.';
    end if;
    v_deity_id := nullif(v_identity->>'cleric_deity_id','');
    v_cause := nullif(btrim(v_identity->>'cleric_cause'),'');
    if coalesce(v_identity->>'cleric_source','deity')='deity' then
      if v_deity_id is null then raise exception 'Escolha uma divindade para o Clérigo.'; end if;
      select * into v_deity from public.srd_deities where deity_id=v_deity_id;
      if not found then raise exception 'Divindade não encontrada no catálogo.'; end if;
      if cardinality(v_deity.racial_races)>0 and not (p_raca_id=any(v_deity.racial_races)) then
        raise exception 'Esta divindade racial não aceita clérigos da raça escolhida.';
      end if;
      if not (v_cleric_domains[1]=any(v_deity.domains) and v_cleric_domains[2]=any(v_deity.domains)) then
        raise exception 'Os domínios escolhidos não pertencem à divindade selecionada.';
      end if;
      v_char_law := case v_alignment when 'Leal e Bom' then 1 when 'Leal e Neutro' then 1 when 'Leal e Mau' then 1 when 'Caótico e Bom' then -1 when 'Caótico e Neutro' then -1 when 'Caótico e Mau' then -1 else 0 end;
      v_char_good := case v_alignment when 'Leal e Bom' then 1 when 'Neutro e Bom' then 1 when 'Caótico e Bom' then 1 when 'Leal e Mau' then -1 when 'Neutro e Mau' then -1 when 'Caótico e Mau' then -1 else 0 end;
      v_deity_law := case v_deity.alignment when 'Leal e Bom' then 1 when 'Leal e Neutro' then 1 when 'Leal e Mau' then 1 when 'Caótico e Bom' then -1 when 'Caótico e Neutro' then -1 when 'Caótico e Mau' then -1 else 0 end;
      v_deity_good := case v_deity.alignment when 'Leal e Bom' then 1 when 'Neutro e Bom' then 1 when 'Caótico e Bom' then 1 when 'Leal e Mau' then -1 when 'Neutro e Mau' then -1 when 'Caótico e Mau' then -1 else 0 end;
      if abs(v_char_law-v_deity_law)+abs(v_char_good-v_deity_good)>1 then
        raise exception 'A tendência do Clérigo deve ser igual ou estar a um passo da tendência da divindade.';
      end if;
      if v_deity_id='st_cuthbert' and v_alignment not in ('Leal e Bom','Leal e Neutro') then
        raise exception 'Clérigos de St. Cuthbert devem ser Leais e Bons ou Leais e Neutros.';
      end if;
      v_identity := jsonb_set(v_identity,'{cleric_source}','"deity"'::jsonb,true);
      v_identity := jsonb_set(v_identity,'{cleric_cause}','""'::jsonb,true);
    elsif coalesce(v_identity->>'cleric_source','')='cause' then
      if v_cause is null then raise exception 'Descreva a causa ou ideal que concede poder ao Clérigo.'; end if;
      v_identity := jsonb_set(v_identity,'{cleric_deity_id}','""'::jsonb,true);
    else
      raise exception 'Escolha uma divindade ou uma causa/ideal para o Clérigo.';
    end if;
  else
    v_identity := jsonb_set(v_identity,'{cleric_source}','"none"'::jsonb,true);
    v_identity := jsonb_set(v_identity,'{cleric_deity_id}','""'::jsonb,true);
    v_identity := jsonb_set(v_identity,'{cleric_cause}','""'::jsonb,true);
  end if;

  if v_age >= (case p_raca_id when 'humano' then 70 when 'anao' then 250 when 'elfo' then 350 when 'gnomo' then 200 when 'meio-elfo' then 125 when 'meio-orc' then 60 when 'halfling' then 100 end) then
    v_age_physical := -6; v_age_mental := 3;
  elsif v_age >= (case p_raca_id when 'humano' then 53 when 'anao' then 188 when 'elfo' then 263 when 'gnomo' then 150 when 'meio-elfo' then 93 when 'meio-orc' then 45 when 'halfling' then 75 end) then
    v_age_physical := -3; v_age_mental := 2;
  elsif v_age >= (case p_raca_id when 'humano' then 35 when 'anao' then 125 when 'elfo' then 175 when 'gnomo' then 100 when 'meio-elfo' then 62 when 'meio-orc' then 30 when 'halfling' then 50 end) then
    v_age_physical := -1; v_age_mental := 1;
  end if;

  if v_class.id='barbaro' then
    if jsonb_typeof(v_identity->'alfabetizado')<>'boolean' then
      raise exception 'Informe se o Bárbaro deseja gastar 2 pontos de perícia para aprender a ler e escrever.';
    end if;
  else
    v_identity := jsonb_set(v_identity,'{alfabetizado}','true'::jsonb,true);
  end if;

  if v_class.id='mago' then
    v_specialization := nullif(v_identity->>'wizard_specialization','');
    v_prohibited := coalesce(v_identity->'wizard_prohibited_schools','[]'::jsonb);
    if jsonb_typeof(v_prohibited)<>'array' then
      raise exception 'Informe a lista de escolas proibidas do Mago.';
    end if;
    if v_specialization='universalista' then
      if jsonb_array_length(v_prohibited)<>0 then raise exception 'O Mago Universalista não possui escolas proibidas.'; end if;
    elsif v_specialization in ('abjuration','conjuration','divination','enchantment','evocation','illusion','necromancy','transmutation') then
      v_required_prohibited := case when v_specialization='divination' then 1 else 2 end;
      if jsonb_array_length(v_prohibited)<>v_required_prohibited then
        raise exception 'A especialização escolhida exige % escola(s) proibida(s).',v_required_prohibited;
      end if;
      if exists (
        select 1 from jsonb_array_elements_text(v_prohibited) x(value)
         where x.value not in ('abjuration','conjuration','divination','enchantment','evocation','illusion','necromancy','transmutation')
            or x.value=v_specialization
      ) then raise exception 'Escola proibida inválida ou igual à escola de especialização.'; end if;
      if (select count(*) from jsonb_array_elements_text(v_prohibited)) <>
         (select count(distinct value) from jsonb_array_elements_text(v_prohibited) t(value)) then
        raise exception 'Não repita escolas proibidas.';
      end if;
    else
      raise exception 'Escolha a escola de especialização ou Universalista.';
    end if;
  else
    v_identity := jsonb_set(v_identity,'{wizard_specialization}','"universalista"'::jsonb,true);
    v_identity := jsonb_set(v_identity,'{wizard_prohibited_schools}','[]'::jsonb,true);
  end if;

  IF p_talentos IS NULL OR jsonb_typeof(p_talentos)<>'array' THEN
    RAISE EXCEPTION 'Os talentos precisam ser enviados como uma lista.';
  END IF;
  FOR v_pick IN SELECT value FROM jsonb_array_elements(p_talentos) LOOP
    IF jsonb_typeof(v_pick)<>'object' OR NULLIF(BTRIM(v_pick->>'id'),'') IS NULL THEN
      RAISE EXCEPTION 'Cada escolha de talento precisa de um ID válido.';
    END IF;
    SELECT f.* INTO v_feat FROM public.srd_feats f WHERE f.id=v_pick->>'id';
    IF NOT FOUND THEN RAISE EXCEPTION 'Talento não encontrado: %.',v_pick->>'id'; END IF;
    IF COALESCE(v_feat.requisitos->>'type','General')<>'General' THEN
      RAISE EXCEPTION '% não é um talento geral disponível na criação básica.',v_feat.nome;
    END IF;
  END LOOP;

  -- Cria apenas o registro-base. A idade é aplicada antes das validações
  -- de perícias e talentos, para que o servidor use os atributos finais.
  v_id := public.criar_personagem_srd(p_nome,p_raca_id,p_classe_id,p_atributos);
  SELECT * INTO v_sheet FROM public.srd_character_sheets
   WHERE character_id::text=v_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha recém-criada não encontrada.'; END IF;

  v_attrs := jsonb_build_object(
    'FOR', greatest(1,(v_sheet.atributos->>'FOR')::integer+v_age_physical),
    'DES', greatest(1,(v_sheet.atributos->>'DES')::integer+v_age_physical),
    'CON', greatest(1,(v_sheet.atributos->>'CON')::integer+v_age_physical),
    'INT', greatest(1,(v_sheet.atributos->>'INT')::integer+v_age_mental),
    'SAB', greatest(1,(v_sheet.atributos->>'SAB')::integer+v_age_mental),
    'CAR', greatest(1,(v_sheet.atributos->>'CAR')::integer+v_age_mental)
  );

  v_pv := greatest(1,v_class.dado_vida+floor((((v_attrs->>'CON')::numeric-10)/2))::integer);

  update public.srd_character_sheets
     set identidade = v_identity,
         atributos = v_attrs,
         pv_atual = v_pv,
         pv_max = v_pv
   where character_id=v_sheet.character_id;
  update public.characters set idade=v_age where id=v_sheet.character_id;

  -- Agora as regras consultam os atributos finais, já com idade e raça.
  PERFORM public.salvar_pericias_srd(v_id,p_pericias);
  PERFORM public.salvar_talentos_srd(v_id,p_talentos);

  SELECT * INTO v_sheet FROM public.srd_character_sheets
   WHERE character_id=v_sheet.character_id FOR UPDATE;

  SELECT COALESCE(
    jsonb_object_agg(
      skill.key,
      to_jsonb(
        (skill.value #>> '{}')::numeric *
        CASE
          WHEN skill.key='srd35_skill_speak_language' OR EXISTS (
            SELECT 1
              FROM jsonb_array_elements_text(COALESCE(v_class.pericias_classe,'[]'::jsonb)) AS class_skill(name)
             WHERE public.srd35_normalizar_parametro_talento(class_skill.name)=public.srd35_normalizar_parametro_talento(sk.nome)
                OR (public.srd35_normalizar_parametro_talento(class_skill.name)='saltar' AND sk.id='atletismo')
                OR (
                  public.srd35_normalizar_parametro_talento(class_skill.name)='conhecimentoqualquer'
                  AND sk.nome ILIKE 'Conhecimento%'
                )
          ) THEN 1 ELSE 2
        END
      )
    ),
    '{}'::jsonb
  )
    INTO v_skill_points_spent
    FROM jsonb_each(
      CASE WHEN jsonb_typeof(v_sheet.pericias)='object'
           THEN v_sheet.pericias ELSE '{}'::jsonb END
    ) AS skill(key,value)
    JOIN public.srd_skills sk
      ON sk.id=skill.key
      OR (skill.key LIKE 'srd35_skill_oficio_%' AND sk.id='oficio')
      OR (skill.key LIKE 'srd35_skill_profissao_%' AND sk.id='profissao')
   WHERE jsonb_typeof(skill.value)='number';

  INSERT INTO public.srd_character_class_levels
    (character_id,class_id,class_level,taken_at_character_level,hit_points_gained,skill_points_spent)
  VALUES
    (v_sheet.character_id,v_class.id,GREATEST(1,COALESCE(v_sheet.nivel,1)),1,v_sheet.pv_max,v_skill_points_spent)
  ON CONFLICT (character_id,class_id) DO UPDATE
    SET class_level=EXCLUDED.class_level,
        taken_at_character_level=COALESCE(public.srd_character_class_levels.taken_at_character_level,1),
        hit_points_gained=EXCLUDED.hit_points_gained,
        skill_points_spent=EXCLUDED.skill_points_spent;

  IF v_class.id='barbaro' AND (v_identity->>'alfabetizado')::boolean THEN
    SELECT COALESCE(SUM((entry.value #>> '{}')::numeric),0)
      INTO v_skill_spent
      FROM public.srd_character_class_levels cl
      CROSS JOIN LATERAL jsonb_each(cl.skill_points_spent) entry
     WHERE cl.character_id=v_sheet.character_id AND cl.class_id=v_class.id;
    v_skill_budget := GREATEST(1,v_class.pericias_por_nivel+FLOOR((((v_attrs->>'INT')::numeric-10)/2))::integer)*4;
    IF v_skill_spent+2>v_skill_budget THEN
      RAISE EXCEPTION 'O Bárbaro precisa reservar 2 pontos para alfabetização; orçamento % e gasto em perícias %.',v_skill_budget,v_skill_spent;
    END IF;
  END IF;

  return v_id;
end;
$function$
