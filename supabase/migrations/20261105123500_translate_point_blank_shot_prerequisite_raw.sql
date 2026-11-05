update public.srd_feats
set requisitos = jsonb_set(requisitos, '{raw}', to_jsonb('Tiro à Queima-Roupa.'::text), true)
where id in ('srd35_feat_far_shot','srd35_feat_precise_shot')
  and requisitos->>'raw' = 'Point Blank Shot.';
