UPDATE public.campaigns
SET state='EXPLORACAO'
WHERE state='COMBATE'
  AND COALESCE((combat_data->>'active')::boolean,false) IS NOT TRUE;