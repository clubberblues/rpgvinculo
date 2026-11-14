DO $migration$
DECLARE
  v_definition text;
  v_old text := $old$
  v_target_traits:=lower(concat_ws(' ',v_target->>'nome',v_target->>'detalhe',
    v_target->'monsterStats'->>'tipo',v_target->'monsterStats'->>'subtipo',
    v_target->'monsterStats'->>'type',v_target->'monsterStats'->>'creature_type'));
  if v_race.id='anao' and v_target_traits ~ '(^|[^a-z])(orc|goblin|hobgoblin|bugbear|goblinoid)([^a-z]|$)' then v_racial_bonus:=1; end if;$old$;
  v_new text := $new$
  v_target_race:=lower(coalesce(nullif(v_target->>'raca_id',''),
    nullif(v_target->>'race_id',''),nullif(v_target->'monsterStats'->>'race_id','')));
  if v_target->>'tipo'='player' then
    select lower(sh.raca_id::text) into v_target_race
      from public.srd_character_sheets sh
     where sh.character_id::text=v_attack.target_token_id;
  elsif v_target->>'tipo'='npc' and nullif(v_target->>'sourceCharacterId','') is not null then
    select lower(sh.raca_id::text) into v_target_race
      from public.srd_character_sheets sh
     where sh.character_id::text=v_target->>'sourceCharacterId';
  end if;
  v_target_traits:=lower(concat_ws(' ',v_target->>'nome',v_target->>'detalhe',
    v_target->'monsterStats'->>'tipo',v_target->'monsterStats'->>'subtipo',
    v_target->'monsterStats'->>'type',v_target->'monsterStats'->>'creature_type',
    v_target_race));
  if v_race.id='anao' and v_target_traits ~ '(^|[^a-z])(orc|goblin|hobgoblin|bugbear|goblinoid)([^a-z]|$)' then v_racial_bonus:=1; end if;$new$;
BEGIN
  v_definition:=pg_get_functiondef('public.srd_resolver_ataque_oportunidade_srd(bigint,uuid)'::regprocedure);
  IF position(v_old in v_definition)=0 THEN
    RAISE EXCEPTION 'Bloco de bônus racial não encontrado; migration abortada.';
  END IF;
  IF (length(v_definition)-length(replace(v_definition,v_old,'')))/length(v_old) <> 1 THEN
    RAISE EXCEPTION 'Bloco de bônus racial não é único; migration abortada.';
  END IF;
  v_definition:=replace(v_definition,v_old,v_new);
  EXECUTE v_definition;
END
$migration$;