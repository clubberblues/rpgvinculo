-- Assertions for the canonical D&D 3.5 grid footprint helper.
INSERT INTO public.campaigns(id,cba_data)
VALUES
(1,jsonb_build_object('tokens',jsonb_build_array(
  jsonb_build_object('id','fine','size','Fine'),
  jsonb_build_object('id','diminutive','size','Diminutive'),
  jsonb_build_object('id','tiny','size','Tiny'),
  jsonb_build_object('id','small','size','Small'),
  jsonb_build_object('id','medium','size','Medium'),
  jsonb_build_object('id','large','size','Large'),
  jsonb_build_object('id','huge','size','Huge'),
  jsonb_build_object('id','enorme','size','Enorme'),
  jsonb_build_object('id','gargantuan','size','Gargantuan'),
  jsonb_build_object('id','imenso','size','Imenso'),
  jsonb_build_object('id','colossal','size','Colossal'),
  jsonb_build_object('id','colossal-key','key','colossal-key','size','Colossal'),
  jsonb_build_object('id','unknown','size','unknown-size')
))),
(2,jsonb_build_object('tokens',jsonb_build_array(
  jsonb_build_object('id','duplicate','size','Large'),
  jsonb_build_object('id','duplicate','size','Small')
))),
(3,jsonb_build_object('tokens',jsonb_build_array(
  jsonb_build_object('id','player-linked','tipo','player','sourceCharacterId','linked-character')
)));

INSERT INTO public.srd_races(id,tamanho) VALUES ('colossal-race','Colossal');
INSERT INTO public.srd_character_sheets(character_id,raca_id) VALUES ('linked-character','colossal-race');

DO $test$
DECLARE
  item record;
  actual integer;
  duplicate_rejected boolean := false;
BEGIN
  FOR item IN
    SELECT * FROM (VALUES
      ('fine',1),
      ('diminutive',1),
      ('tiny',1),
      ('small',1),
      ('medium',1),
      ('large',2),
      ('huge',3),
      ('enorme',3),
      ('gargantuan',4),
      ('imenso',4),
      ('colossal',6),
      ('unknown',1)
    ) AS expected(token_id,footprint)
  LOOP
    actual := priv.srd_token_grid_footprint(1,item.token_id);
    IF actual IS DISTINCT FROM item.footprint THEN
      RAISE EXCEPTION 'Footprint incorreto para %: esperado %, recebido %',
        item.token_id,item.footprint,actual;
    END IF;
  END LOOP;

  actual := priv.srd_token_grid_footprint(1,'colossal-key');
  IF actual IS DISTINCT FROM 6 THEN
    RAISE EXCEPTION 'Lookup por key deveria retornar footprint 6; recebeu %',actual;
  END IF;

  actual := priv.srd_token_grid_footprint(3,'player-linked');
  IF actual IS DISTINCT FROM 6 THEN
    RAISE EXCEPTION 'Fallback de raça do jogador deveria retornar footprint 6; recebeu %',actual;
  END IF;

  BEGIN
    PERFORM priv.srd_token_grid_footprint(2,'duplicate');
  EXCEPTION WHEN OTHERS THEN
    duplicate_rejected := true;
  END;
  IF NOT duplicate_rejected THEN
    RAISE EXCEPTION 'Token duplicado deveria ser rejeitado pelo helper.';
  END IF;
END
$test$;

SELECT 'footprint helper assertions passed' AS result;
