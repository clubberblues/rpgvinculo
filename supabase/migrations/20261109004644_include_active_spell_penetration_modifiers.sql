
DO $migration$
DECLARE
  v_definition text;
  v_updated text;
  v_old_decl text := $olddecl$ v_user uuid; v_sr integer; v_total integer; v_feat_bonus integer:=0;$olddecl$;
  v_new_decl text := $newdecl$ v_user uuid; v_sr integer; v_total integer; v_feat_bonus integer:=0; v_effect_bonus integer:=0;$newdecl$;
  v_old_calc text := $oldcalc$  v_feat_bonus:=priv.srd_spell_penetration_feat_bonus(v_pending.caster_character_id);
  v_total:=p_d20+v_pending.caster_level+v_feat_bonus;$oldcalc$;
  v_new_calc text := $newcalc$  v_feat_bonus:=priv.srd_spell_penetration_feat_bonus(v_pending.caster_character_id);
  v_effect_bonus:=priv.srd_effective_modifier(v_pending.campaign_id,'character',v_pending.caster_character_id,'spell_penetration');
  v_total:=p_d20+v_pending.caster_level+v_feat_bonus+v_effect_bonus;$newcalc$;
  v_old_json text := $oldjson$'caster_level',v_pending.caster_level,'feat_bonus',v_feat_bonus$oldjson$;
  v_new_json text := $newjson$'caster_level',v_pending.caster_level,'feat_bonus',v_feat_bonus,'effect_bonus',v_effect_bonus$newjson$;
BEGIN
  SELECT pg_get_functiondef('public.srd_resolve_pending_spell_resistance(uuid,integer)'::regprocedure)
    INTO v_definition;
  IF position(v_old_decl IN v_definition)=0 OR position(v_old_calc IN v_definition)=0
     OR position(v_old_json IN v_definition)=0 THEN
    RAISE EXCEPTION 'Trechos de cálculo de penetração não encontrados; migração cancelada.';
  END IF;
  IF position(v_old_decl IN substring(v_definition FROM position(v_old_decl IN v_definition)+length(v_old_decl)))>0
     OR position(v_old_calc IN substring(v_definition FROM position(v_old_calc IN v_definition)+length(v_old_calc)))>0 THEN
    RAISE EXCEPTION 'Trecho de cálculo de penetração duplicado; migração cancelada.';
  END IF;
  v_updated:=replace(v_definition,v_old_decl,v_new_decl);
  v_updated:=replace(v_updated,v_old_calc,v_new_calc);
  v_updated:=replace(v_updated,v_old_json,v_new_json);
  EXECUTE v_updated;
END
$migration$;
