UPDATE public.srd_equipment
SET detalhes = COALESCE(detalhes, '{}'::jsonb) || jsonb_build_object('weapon_finesse_eligible', TRUE)
WHERE categoria = 'arma' AND id = ANY (ARRAY['adaga','foice','maca_leve','espada_curta','kukri','machadinha','martelo_leve','picareta_leve','kama','nunchaku','sai','siangham','rapieira','chicote','corrente_espinhosa']);