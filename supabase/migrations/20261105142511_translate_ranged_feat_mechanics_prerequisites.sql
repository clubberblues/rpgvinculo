update public.srd_feats
set mechanics = jsonb_set(
  coalesce(mechanics, '{}'::jsonb),
  '{requirements,raw}',
  to_jsonb(case id
    when 'srd35_feat_rapid_shot' then 'DES 13 e Tiro à Queima-Roupa.'
    when 'srd35_feat_far_shot' then 'Tiro à Queima-Roupa.'
    when 'srd35_feat_precise_shot' then 'Tiro à Queima-Roupa.'
    when 'srd35_feat_shot_on_the_run' then 'DES 13, Esquiva, Mobilidade, Tiro à Queima-Roupa e BBA +4.'
    when 'srd35_feat_improved_precise_shot' then 'DES 19, Tiro à Queima-Roupa, Tiro Preciso e BBA +11.'
  end),
  true
)
where id in (
  'srd35_feat_rapid_shot',
  'srd35_feat_far_shot',
  'srd35_feat_precise_shot',
  'srd35_feat_shot_on_the_run',
  'srd35_feat_improved_precise_shot'
);