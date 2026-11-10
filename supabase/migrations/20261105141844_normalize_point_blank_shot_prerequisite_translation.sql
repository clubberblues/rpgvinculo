update public.srd_feats
set descricao_pt = replace(descricao_pt, 'Tiro Certeiro', 'Tiro à Queima-Roupa'),
    requisitos = jsonb_set(requisitos, '{raw}', to_jsonb(replace(coalesce(requisitos->>'raw',''), 'Tiro Certeiro', 'Tiro à Queima-Roupa')), true)
where id in (
 'srd35_feat_rapid_shot',
 'srd35_feat_far_shot',
 'srd35_feat_shot_on_the_run',
 'srd35_feat_improved_precise_shot'
)
and (descricao_pt like '%Tiro Certeiro%' or requisitos->>'raw' like '%Tiro Certeiro%');