
do $patch$
declare v_def text;
begin
 v_def:=pg_get_functiondef('public.srd_reservar_reacao_movimento_aoo_srd(bigint,uuid,text)'::regprocedure);
 if length(v_def)-length(replace(v_def,'''loses_dex_ac''',''))<>length('''loses_dex_ac''')*2 then
   raise exception 'Quantidade inesperada de verificações de perda de Destreza; alteração cancelada.';
 end if;
 v_def:=replace(v_def,'''loses_dex_ac''','''no_aoo''');
 execute v_def;
end;
$patch$;
