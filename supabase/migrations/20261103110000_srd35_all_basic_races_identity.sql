-- Generaliza a idade e o envelhecimento da criação SRD 3.5 para as sete raças básicas.
-- A função é reconstruída a partir da definição instalada para preservar todas as validações
-- específicas de classe já existentes. Falha explicitamente se o contrato esperado mudou.
do $migration$
declare
  v_definition text;
  v_old_age text := $old$
  v_age_dice := case
    when v_class.id in ('barbaro','ladino','feiticeiro') then 3
    when v_class.id in ('bardo','guerreiro','paladino','ranger') then 5
    else 7
  end;
  v_min_age := 40 + v_age_dice;
$old$;
  v_new_age text := $new$
  v_age_dice := case
    when p_raca_id='humano' then case when v_class.id in ('barbaro','ladino','feiticeiro') then 1 when v_class.id in ('bardo','guerreiro','paladino','ranger') then 1 else 2 end
    when p_raca_id='anao' then case when v_class.id in ('barbaro','ladino','feiticeiro') then 3 when v_class.id in ('bardo','guerreiro','paladino','ranger') then 5 else 7 end
    when p_raca_id='elfo' then case when v_class.id in ('barbaro','ladino','feiticeiro') then 4 when v_class.id in ('bardo','guerreiro','paladino','ranger') then 6 else 10 end
    when p_raca_id='gnomo' then case when v_class.id in ('barbaro','ladino','feiticeiro') then 4 when v_class.id in ('bardo','guerreiro','paladino','ranger') then 6 else 9 end
    when p_raca_id='meio-elfo' then case when v_class.id in ('barbaro','ladino','feiticeiro') then 1 when v_class.id in ('bardo','guerreiro','paladino','ranger') then 2 else 3 end
    when p_raca_id='meio-orc' then case when v_class.id in ('barbaro','ladino','feiticeiro') then 1 when v_class.id in ('bardo','guerreiro','paladino','ranger') then 1 else 2 end
    when p_raca_id='halfling' then case when v_class.id in ('barbaro','ladino','feiticeiro') then 2 when v_class.id in ('bardo','guerreiro','paladino','ranger') then 3 else 4 end
    else null
  end;
  v_min_age := (case p_raca_id when 'humano' then 15 when 'anao' then 40 when 'elfo' then 110 when 'gnomo' then 40 when 'meio-elfo' then 20 when 'meio-orc' then 14 when 'halfling' then 20 else null end) + v_age_dice;
$old$;
  v_old_aging text := $old$
  if v_age >= 250 then
    v_age_physical := -6; v_age_mental := 3;
  elsif v_age >= 188 then
    v_age_physical := -3; v_age_mental := 2;
  elsif v_age >= 125 then
    v_age_physical := -1; v_age_mental := 1;
  end if;
$old$;
  v_new_aging text := $new$
  if v_age >= (case p_raca_id when 'humano' then 70 when 'anao' then 250 when 'elfo' then 350 when 'gnomo' then 200 when 'meio-elfo' then 125 when 'meio-orc' then 60 when 'halfling' then 100 else 2147483647 end) then
    v_age_physical := -6; v_age_mental := 3;
  elsif v_age >= (case p_raca_id when 'humano' then 53 when 'anao' then 188 when 'elfo' then 263 when 'gnomo' then 150 when 'meio-elfo' then 93 when 'meio-orc' then 45 when 'halfling' then 75 else 2147483647 end) then
    v_age_physical := -3; v_age_mental := 2;
  elsif v_age >= (case p_raca_id when 'humano' then 35 when 'anao' then 125 when 'elfo' then 175 when 'gnomo' then 100 when 'meio-elfo' then 62 when 'meio-orc' then 30 when 'halfling' then 50 else 2147483647 end) then
    v_age_physical := -1; v_age_mental := 1;
  end if;
$new$;
begin
  select pg_get_functiondef('public.criar_personagem_srd_completo(text,text,text,jsonb,jsonb,jsonb,jsonb)'::regprocedure)
    into v_definition;

  if position($guard$  if v_race.id <> 'anao' then
    raise exception 'Esta versão do fluxo de identidade está sendo validada para Anão.';
  end if;
$guard$ in v_definition)=0 then
    raise exception 'Migração abortada: a restrição racial esperada não foi encontrada.';
  end if;
  v_definition := replace(v_definition,$guard$  if v_race.id <> 'anao' then
    raise exception 'Esta versão do fluxo de identidade está sendo validada para Anão.';
  end if;
$guard$,'');

  if position(v_old_age in v_definition)=0 then
    raise exception 'Migração abortada: bloco de idade inicial mudou; revisar antes de aplicar.';
  end if;
  v_definition := replace(v_definition,v_old_age,v_new_age);

  if position(v_old_aging in v_definition)=0 then
    raise exception 'Migração abortada: bloco de envelhecimento mudou; revisar antes de aplicar.';
  end if;
  v_definition := replace(v_definition,v_old_aging,v_new_aging);

  if position('v_height < 100 or v_height > 220' in v_definition)=0
     or position('v_weight < 25 or v_weight > 250' in v_definition)=0 then
    raise exception 'Migração abortada: limites de altura/peso mudaram; revisar antes de aplicar.';
  end if;
  v_definition := replace(v_definition,'v_height < 100 or v_height > 220','v_height < 50 or v_height > 300');
  v_definition := replace(v_definition,'v_weight < 25 or v_weight > 250','v_weight < 2 or v_weight > 500');

  execute v_definition;
end
$migration$;
