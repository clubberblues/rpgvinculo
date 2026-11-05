-- Correção terminológica: nome PT-BR de Greater Two-Weapon Fighting.
update public.srd_feats
set nome_pt = 'Combater com Duas Armas Maior'
where id = 'srd35_feat_greater_two_weapon_fighting';
