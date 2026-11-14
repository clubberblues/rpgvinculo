
do $patch$
declare v_def text; nl text:=chr(10); v_marker text; v_insert text;
begin
 v_def:=pg_get_functiondef('priv.srd_expire_barbarian_rage_on_round_change()'::regprocedure);
 v_marker:='  RETURN NEW;'||nl||'END;'||nl||'$function$';
 v_insert:=
 '  FOR v_rage IN'||nl||
 '    SELECT effect_instance_id, target_id'||nl||
 '      FROM public.srd_campaign_effects'||nl||
 '     WHERE campaign_id=NEW.id'||nl||
 '       AND target_kind=''token'''||nl||
 '       AND active=true'||nl||
 '       AND effect_data->>''source_feature''=''barbarian_rage'''||nl||
 '       AND expires_round IS NOT NULL'||nl||
 '       AND expires_round <= v_new_round'||nl||
 '     ORDER BY effect_instance_id'||nl||
 '     FOR UPDATE'||nl||
 '  LOOP'||nl||
 '    v_result := priv.srd_end_barbarian_rage_token(NEW.id,v_rage.target_id,true);'||nl||
 '    IF COALESCE((v_result->>''ended'')::boolean,false) THEN'||nl||
 '      PERFORM priv.log(NEW.id,''CLASS_FEATURE'',jsonb_build_object('||nl||
 '        ''feature_key'',''barbarian_rage'','||nl||
 '        ''action'',''expire'','||nl||
 '        ''token_id'',v_rage.target_id,'||nl||
 '        ''effect_instance_id'',v_rage.effect_instance_id,'||nl||
 '        ''round'',v_new_round,'||nl||
 '        ''rage_hp_removed'',v_result->''rage_hp_removed'','||nl||
 '        ''fatigue_applied'',v_result->''fatigue_applied'''||nl||
 '      ));'||nl||
 '    END IF;'||nl||
 '  END LOOP;'||nl||nl||v_marker;
 if position(v_marker in v_def)=0 then raise exception 'Não foi possível localizar o final do gatilho de expiração de Fúria.'; end if;
 if position('target_kind=''token''' in v_def)>0 then raise exception 'O gatilho já contém expiração de Fúria para tokens; nenhuma alteração aplicada.'; end if;
 v_def:=replace(v_def,v_marker,v_insert);
 execute v_def;
end
$patch$;
