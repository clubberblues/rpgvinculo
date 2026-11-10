do $patch$
declare v_def text; v_old text; v_new text;
begin
  select pg_get_functiondef('public.iniciar_sequencia_ataque_iterativo_srd(bigint,text,text,text,uuid,text,text,integer)'::regprocedure) into v_def;
  v_old:='    if not exists(select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)=''array'' then v_sheet.talentos else ''[]''::jsonb end) f where f->>''id''=''ataque_poderoso'') then';
  v_new:='    if coalesce(nullif(v_sheet.atributos->>''FOR'','''')::integer,10)<13 then'||chr(10)||
         '      raise exception ''Ataque Poderoso exige Força 13 ou superior.'';'||chr(10)||
         '    end if;'||chr(10)||v_old;
  if position(v_old in v_def)=0 then
    if position('Ataque Poderoso exige Força 13 ou superior.' in v_def)=0 then raise exception 'Validação de talento Ataque Poderoso não localizada.'; end if;
  else v_def:=replace(v_def,v_old,v_new); end if;
  execute v_def;
end
$patch$;