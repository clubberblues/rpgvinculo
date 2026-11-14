UPDATE public.srd_class_level_features f
SET summary=CASE WHEN f.class_level=1
  THEN 'Ataque Furtivo +1d6: dano extra rolado manualmente quando o alvo perde o bônus de Destreza na CA; flanqueamento e Encontrar Armadilhas permanecem pendentes.'
  ELSE regexp_replace(f.name,'·.*$','')||': dano extra rolado manualmente quando o alvo perde o bônus de Destreza na CA; flanqueamento permanece pendente.'
  END,
  mechanics=mechanics||jsonb_build_object(
    'engine_status','partial',
    'implemented_features',
      COALESCE((SELECT jsonb_agg(DISTINCT item) FROM jsonb_array_elements_text(COALESCE(f.mechanics->'implemented_features','[]'::jsonb)) item),'[]'::jsonb)
      || jsonb_build_array('sneak_attack_manual_dice','sneak_attack_dex_denial','sneak_attack_ranged_9m','sneak_attack_critical_not_multiplied'),
    'pending_features',
      CASE WHEN f.class_level=1 THEN jsonb_build_array('sneak_attack_flanking','trapfinding')
           ELSE jsonb_build_array('sneak_attack_flanking') END
  )
WHERE f.class_id='ladino' AND COALESCE(f.mechanics->>'source_text','') ILIKE 'Sneak attack%';