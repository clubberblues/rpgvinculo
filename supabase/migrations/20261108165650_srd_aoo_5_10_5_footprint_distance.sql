
create or replace function priv.srd_grid_footprint_distance_ft(
  p_ax integer,p_ay integer,p_asize integer,
  p_bx integer,p_by integer,p_bsize integer
) returns integer
language sql immutable strict
set search_path=pg_catalog,pg_temp
as $function$
  with gaps as (
    select greatest(0,p_bx-(p_ax+p_asize-1),p_ax-(p_bx+p_bsize-1)) dx,
           greatest(0,p_by-(p_ay+p_asize-1),p_ay-(p_by+p_bsize-1)) dy
  )
  select (greatest(dx,dy)*5 + floor(least(dx,dy)::numeric/2)*5)::integer
  from gaps;
$function$;
revoke all on function priv.srd_grid_footprint_distance_ft(integer,integer,integer,integer,integer,integer) from public,anon,authenticated;

do $patch$
declare v_def text; v_old text; v_new text;
begin
  v_def:=pg_get_functiondef('public.srd_detectar_saida_alcance_ameacado_srd(bigint,text,integer,integer)'::regprocedure);
  v_old:=$old$
      ceil(e.reach_ft/5.0)::integer-1 as reach_gap,
      min(path.i) filter (where
        greatest(0,greatest(e.gx-(path.px+v_size),path.px-(e.gx+e.footprint))) <= ceil(e.reach_ft/5.0)::integer-1
        and greatest(0,greatest(e.gy-(path.py+v_size),path.py-(e.gy+e.footprint))) <= ceil(e.reach_ft/5.0)::integer-1
      ) as first_threatened_step,
      max(path.i) filter (where
        greatest(0,greatest(e.gx-(path.px+v_size),path.px-(e.gx+e.footprint))) <= ceil(e.reach_ft/5.0)::integer-1
        and greatest(0,greatest(e.gy-(path.py+v_size),path.py-(e.gy+e.footprint))) <= ceil(e.reach_ft/5.0)::integer-1
      ) as last_threatened_step,
$old$;
  v_new:=$new$
      min(path.i) filter (where
        priv.srd_grid_footprint_distance_ft(path.px,path.py,v_size,e.gx,e.gy,e.footprint) <= e.reach_ft
      ) as first_threatened_step,
      max(path.i) filter (where
        priv.srd_grid_footprint_distance_ft(path.px,path.py,v_size,e.gx,e.gy,e.footprint) <= e.reach_ft
      ) as last_threatened_step,
$new$;
  if strpos(v_def,v_old)=0 then raise exception 'Trecho antigo de distância não encontrado; nenhuma alteração aplicada.'; end if;
  v_def:=replace(v_def,v_old,v_new);
  v_def:=replace(v_def,
    $old$'reach_gap_squares',reach_gap,$old$,
    $new$'reach_distance_rule','D&D 3.5 diagonal 5-10-5',$new$);
  execute v_def;
end;
$patch$;
