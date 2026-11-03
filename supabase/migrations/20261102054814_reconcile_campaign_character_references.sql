UPDATE public.campaigns c
SET combat_data = jsonb_set(
  COALESCE(c.combat_data,'{}'::jsonb),
  '{expected_character_ids}',
  COALESCE((
    SELECT jsonb_agg(ch.id::text ORDER BY ch.id)
    FROM public.characters ch
    JOIN public.members m
      ON m.campaign_id=ch.campaign_id
     AND m.user_id=ch.user_id
     AND m.role='PLAYER'
    WHERE ch.campaign_id=c.id
  ),'[]'::jsonb),
  true
),
cba_data = jsonb_set(
  COALESCE(c.cba_data,'{}'::jsonb),
  '{tokens}',
  COALESCE((
    SELECT jsonb_agg(t ORDER BY ord)
    FROM jsonb_array_elements(CASE WHEN jsonb_typeof(c.cba_data->'tokens')='array' THEN c.cba_data->'tokens' ELSE '[]'::jsonb END)
         WITH ORDINALITY AS e(t,ord)
    WHERE NOT (
      COALESCE(t->>'tipo','')='player'
      AND NOT EXISTS (
        SELECT 1 FROM public.characters ch
        WHERE ch.campaign_id=c.id AND ch.id::text=t->>'id'
      )
    )
  ),'[]'::jsonb),
  true
)
WHERE c.combat_data IS NOT NULL OR c.cba_data IS NOT NULL;