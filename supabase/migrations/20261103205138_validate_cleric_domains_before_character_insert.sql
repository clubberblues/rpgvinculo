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
  v_alignment text;
  v_min_age integer;
  v_age_dice integer;
  v_age_physical integer := 0;
  v_age_mental integer := 0;
  v_sheet public.srd_character_sheets%rowtype;
  v_attrs jsonb;
  v_pv integer;
  v_identity jsonb;
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
  if v_race.id <> 'anao' then
    raise exception 'Esta versão do fluxo de identidade está sendo validada para Anão.';
  end if;
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
  if v_height is null or v_height < 100 or v_height > 220 then raise exception 'Altura fora do intervalo permitido (100 a 220 cm).'; end if;
  if v_weight is null or v_weight < 25 or v_weight > 250 then raise exception 'Peso fora do intervalo permitido (25 a 250 kg).'; end if;
  if v_alignment not in ('Leal e Bom','Neutro e Bom','Caótico e Bom','Leal e Neutro','Neutro','Caótico e Neutro','Leal e Mau','Neutro e Mau','Caótico e Mau') then
    raise exception 'Selecione uma tendência válida.';
  end if;

  v_age_dice := case
    when v_class.id in ('barbaro','ladino','feiticeiro') then 3
    when v_class.id in ('bardo','guerreiro','paladino','ranger') then 5
    else 7
  end;
  v_min_age := 40 + v_age_dice;
  if v_age < v_min_age then
    raise exception 'A idade mínima para Anão % é % anos (40 + %d6, resultado mínimo).',v_class.nome,v_min_age,v_age_dice;
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

  if v_age >= 250 then
    v_age_physical := -6; v_age_mental := 3;
  elsif v_age >= 188 then
    v_age_physical := -3; v_age_mental := 2;
  elsif v_age >= 125 then
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

  v_id := public.criar_personagem_srd_completo(
    p_nome,p_raca_id,p_classe_id,p_atributos,p_pericias,p_talentos
  );
  select * into v_sheet from public.srd_character_sheets
   where character_id::text=v_id for update;
  if not found then raise exception 'Ficha recém-criada não encontrada.'; end if;

  v_attrs := jsonb_build_object(
    'FOR', greatest(1,(v_sheet.atributos->>'FOR')::integer+v_age_physical),
    'DES', greatest(1,(v_sheet.atributos->>'DES')::integer+v_age_physical),
    'CON', greatest(1,(v_sheet.atributos->>'CON')::integer+v_age_physical),
    'INT', greatest(1,(v_sheet.atributos->>'INT')::integer+v_age_mental),
    'SAB', greatest(1,(v_sheet.atributos->>'SAB')::integer+v_age_mental),
    'CAR', greatest(1,(v_sheet.atributos->>'CAR')::integer+v_age_mental)
  );

  if v_class.id='barbaro' and (v_identity->>'alfabetizado')::boolean then
    select coalesce(sum((entry.value #>> '{}')::numeric),0)
      into v_skill_spent
      from public.srd_character_class_levels cl
      cross join lateral jsonb_each(cl.skill_points_spent) entry
     where cl.character_id=v_sheet.character_id and cl.class_id=v_class.id;
    v_skill_budget := greatest(1,v_class.pericias_por_nivel+floor((((v_attrs->>'INT')::numeric-10)/2))::integer)*4;
    if v_skill_spent+2>v_skill_budget then
      raise exception 'O Bárbaro precisa reservar 2 pontos para alfabetização; orçamento % e gasto em perícias %.',v_skill_budget,v_skill_spent;
    end if;
  end if;

  v_pv := greatest(1,v_class.dado_vida+floor((((v_attrs->>'CON')::numeric-10)/2))::integer);

  update public.srd_character_sheets
     set identidade = v_identity,
         atributos = v_attrs,
         pv_atual = v_pv,
         pv_max = v_pv
   where character_id=v_sheet.character_id;
  update public.characters set idade=v_age where id=v_sheet.character_id;

  return v_id;
end;
$function$
;
revoke all on function public.criar_personagem_srd_completo(text,text,text,jsonb,jsonb,jsonb,jsonb) from public;
grant execute on function public.criar_personagem_srd_completo(text,text,text,jsonb,jsonb,jsonb,jsonb) to authenticated;
