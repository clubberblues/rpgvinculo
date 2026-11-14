do $patch$
declare v_def text; v_old text; v_new text;
begin
  select pg_get_functiondef('public.aplicar_dano_ataque_iterativo_srd(bigint,uuid,integer[],uuid)'::regprocedure) into v_def;

  v_old:='  if not found then raise exception ''Sequência não encontrada.''; end if;';
  v_new:=v_old||chr(10)||'  if v_seq.status<>''active'' then raise exception ''A sequência de ataques não está mais ativa.''; end if;';
  if position(v_old in v_def)=0 and position('v_seq.status<>''active''' in v_def)=0 then
    raise exception 'Validação do estado da sequência não localizada.';
  end if;
  if position(v_old in v_def)>0 then v_def:=replace(v_def,v_old,v_new); end if;

  v_old:='  if not exists ('||chr(10)||
    '    select 1 from public.srd_character_weapon_instances wi'||chr(10)||
    '    where wi.instance_id=v_seq.weapon_instance_id and wi.character_id=v_seq.actor_character_id::text'||chr(10)||
    '      and wi.equipado is true and wi.hand_slot=v_seq.weapon_hand_slot'||chr(10)||
    '  ) then raise exception ''A arma não está mais equipada na mão vinculada.''; end if;';
  v_new:=v_old||chr(10)||
    '  if not exists ('||chr(10)||
    '    select 1 from public.srd_character_equipment ce'||chr(10)||
    '    join public.srd_character_weapon_instances wi on wi.instance_id=v_seq.weapon_instance_id'||chr(10)||
    '    where ce.character_id=v_seq.actor_character_id::text and ce.equipment_id=wi.equipment_id'||chr(10)||
    '      and ce.equipado is true and ce.hand_slot=v_seq.weapon_hand_slot'||chr(10)||
    '  ) then raise exception ''Inventário e instância da arma ficaram inconsistentes antes do dano.''; end if;';
  if position(v_old in v_def)=0 and position('Inventário e instância da arma ficaram inconsistentes antes do dano.' in v_def)=0 then
    raise exception 'Validação de equipamento não localizada.';
  end if;
  if position(v_old in v_def)>0 then v_def:=replace(v_def,v_old,v_new); end if;
  execute v_def;
end
$patch$;