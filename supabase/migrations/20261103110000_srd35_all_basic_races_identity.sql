-- Generaliza a identidade inicial SRD 3.5 para as sete raças básicas.
-- Reescreve a função instalada preservando as validações de classe e de propriedade.
-- A migration aborta se a definição de origem não corresponder exatamente ao contrato auditado.
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
$new$;
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
  if v_age >= (case p_raca_id when 'humano' then 70 when 'anao' then 250 when 'elfo' then 350 when 'gnomo' then 200 when 'meio-elfo' then 125 when 'meio-orc' then 60 when 'halfling' then 100 end) then
    v_age_physical := -6; v_age_mental := 3;
  elsif v_age >= (case p_raca_id when 'humano' then 53 when 'anao' then 188 when 'elfo' then 263 when 'gnomo' then 150 when 'meio-elfo' then 93 when 'meio-orc' then 45 when 'halfling' then 75 end) then
    v_age_physical := -3; v_age_mental := 2;
  elsif v_age >= (case p_raca_id when 'humano' then 35 when 'anao' then 125 when 'elfo' then 175 when 'gnomo' then 100 when 'meio-elfo' then 62 when 'meio-orc' then 30 when 'halfling' then 50 end) then
    v_age_physical := -1; v_age_mental := 1;
  end if;
$old$;
  v_old_height_weight text := $old$
  if v_height is null or v_height < 100 or v_height > 220 then raise exception 'Altura fora do intervalo permitido (100 a 220 cm).'; end if;
  if v_weight is null or v_weight < 25 or v_weight > 250 then raise exception 'Peso fora do intervalo permitido (25 a 250 kg).'; end if;
$old$;
  v_new_height_weight text := $new$
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
$new$;
begin
  select pg_get_functiondef('public.criar_personagem_srd_completo(text,text,text,jsonb,jsonb,jsonb,jsonb)'::regprocedure)
    into v_definition;

  if position($guard$  if v_race.id <> 'anao' then
    raise exception 'Esta versão do fluxo de identidade está sendo validada para Anão.';
  end if;
$guard$ in v_definition)=0 then
    raise exception 'Migração abortada: restrição racial esperada não encontrada.';
  end if;
  v_definition := replace(v_definition,$guard$  if v_race.id <> 'anao' then
    raise exception 'Esta versão do fluxo de identidade está sendo validada para Anão.';
  end if;
$guard$,'');

  if position('  v_weight numeric;' in v_definition)=0 then
    raise exception 'Migração abortada: declaração de peso não encontrada.';
  end if;
  v_definition := replace(v_definition,'  v_weight numeric;','  v_weight numeric;'||chr(10)||'  v_height_min numeric;'||chr(10)||'  v_height_max numeric;'||chr(10)||'  v_weight_min numeric;'||chr(10)||'  v_weight_max numeric;');

  if position(v_old_age in v_definition)=0 then raise exception 'Bloco de idade inicial mudou; revisar migração.'; end if;
  v_definition := replace(v_definition,v_old_age,v_new_age);
  if position($oldmsg$    raise exception 'A idade mínima para Anão % é % anos (40 + %d6, resultado mínimo).',v_class.nome,v_min_age,v_age_dice;$oldmsg$ in v_definition)=0 then
    raise exception 'Mensagem de idade mínima mudou; revisar migração.';
  end if;
  v_definition := replace(
    v_definition,
    $oldmsg$    raise exception 'A idade mínima para Anão % é % anos (40 + %d6, resultado mínimo).',v_class.nome,v_min_age,v_age_dice;$oldmsg$,
    $newmsg$    raise exception 'A idade mínima para a raça % e classe % é % anos (idade adulta + %d6, resultado mínimo).',p_raca_id,v_class.nome,v_min_age,v_age_dice;$newmsg$
  );

  if position(v_old_aging in v_definition)=0 then raise exception 'Bloco de envelhecimento mudou; revisar migração.'; end if;
  v_definition := replace(v_definition,v_old_aging,v_new_aging);
  if position(v_old_height_weight in v_definition)=0 then raise exception 'Validação física mudou; revisar migração.'; end if;
  v_definition := replace(v_definition,v_old_height_weight,v_new_height_weight);

  execute v_definition;
end
$migration$;
