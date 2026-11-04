
create or replace function public.criar_personagem_srd_completo(
  p_nome text,
  p_raca_id text,
  p_classe_id text,
  p_atributos jsonb,
  p_pericias jsonb,
  p_talentos jsonb,
  p_identidade jsonb
)
returns text
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
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
  -- A tendência do Clérigo será validada junto da escolha de divindade, na etapa própria da classe.

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
$function$;

revoke all on function public.criar_personagem_srd_completo(text,text,text,jsonb,jsonb,jsonb,jsonb) from public;
grant execute on function public.criar_personagem_srd_completo(text,text,text,jsonb,jsonb,jsonb,jsonb) to authenticated;
