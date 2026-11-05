CREATE TABLE IF NOT EXISTS public.srd_character_weapon_instances (
 instance_id uuid PRIMARY KEY DEFAULT gen_random_uuid(), character_id text NOT NULL,
 equipment_id text NOT NULL REFERENCES public.srd_equipment(id) ON DELETE RESTRICT,
 equipado boolean NOT NULL DEFAULT false, hand_slot text,
 created_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT srd_character_weapon_instances_hand_slot_check CHECK (hand_slot IS NULL OR hand_slot IN ('main_hand','off_hand'))
);
CREATE TABLE IF NOT EXISTS public.srd_cba_token_weapon_instances (
 instance_id uuid PRIMARY KEY DEFAULT gen_random_uuid(), campaign_id bigint NOT NULL REFERENCES public.campaigns(id) ON DELETE CASCADE,
 token_id text NOT NULL, equipment_id text NOT NULL REFERENCES public.srd_equipment(id) ON DELETE RESTRICT,
 equipado boolean NOT NULL DEFAULT false, hand_slot text,
 created_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT srd_cba_token_weapon_instances_hand_slot_check CHECK (hand_slot IS NULL OR hand_slot IN ('main_hand','off_hand'))
);
CREATE UNIQUE INDEX IF NOT EXISTS srd_character_weapon_instances_one_per_hand ON public.srd_character_weapon_instances(character_id,hand_slot) WHERE equipado=true AND hand_slot IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS srd_cba_token_weapon_instances_one_per_hand ON public.srd_cba_token_weapon_instances(campaign_id,token_id,hand_slot) WHERE equipado=true AND hand_slot IS NOT NULL;
CREATE INDEX IF NOT EXISTS srd_character_weapon_instances_owner_idx ON public.srd_character_weapon_instances(character_id,equipment_id);
CREATE INDEX IF NOT EXISTS srd_cba_token_weapon_instances_owner_idx ON public.srd_cba_token_weapon_instances(campaign_id,token_id,equipment_id);
INSERT INTO public.srd_character_weapon_instances(character_id,equipment_id,equipado,hand_slot)
SELECT held.character_id,held.equipment_id,held.equipado AND serial.n=1,CASE WHEN held.equipado AND serial.n=1 THEN COALESCE(held.hand_slot,'main_hand') ELSE NULL END
FROM public.srd_character_equipment held JOIN public.srd_equipment gear ON gear.id=held.equipment_id
CROSS JOIN LATERAL generate_series(1,LEAST(GREATEST(held.quantidade,1),99)) serial(n)
WHERE public.srd35_equipment_slot(gear.categoria,gear.nome)='arma'
AND NOT EXISTS (SELECT 1 FROM public.srd_character_weapon_instances i WHERE i.character_id=held.character_id AND i.equipment_id=held.equipment_id);
INSERT INTO public.srd_cba_token_weapon_instances(campaign_id,token_id,equipment_id,equipado,hand_slot)
SELECT held.campaign_id,held.token_id,held.equipment_id,held.equipado AND serial.n=1,CASE WHEN held.equipado AND serial.n=1 THEN COALESCE(held.hand_slot,'main_hand') ELSE NULL END
FROM public.srd_cba_token_equipment held JOIN public.srd_equipment gear ON gear.id=held.equipment_id
CROSS JOIN LATERAL generate_series(1,LEAST(GREATEST(held.quantidade,1),99)) serial(n)
WHERE public.srd35_equipment_slot(gear.categoria,gear.nome)='arma'
AND NOT EXISTS (SELECT 1 FROM public.srd_cba_token_weapon_instances i WHERE i.campaign_id=held.campaign_id AND i.token_id=held.token_id AND i.equipment_id=held.equipment_id);
ALTER TABLE public.srd_character_weapon_instances ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.srd_cba_token_weapon_instances ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS srd_character_weapon_instances_select ON public.srd_character_weapon_instances;
CREATE POLICY srd_character_weapon_instances_select ON public.srd_character_weapon_instances FOR SELECT TO authenticated USING (
 EXISTS (SELECT 1 FROM public.characters ch WHERE ch.id::text=character_id AND (ch.user_id=(SELECT auth.uid()) OR public.my_role(ch.campaign_id)='GM'))
);
DROP POLICY IF EXISTS srd_cba_token_weapon_instances_select ON public.srd_cba_token_weapon_instances;
CREATE POLICY srd_cba_token_weapon_instances_select ON public.srd_cba_token_weapon_instances FOR SELECT TO authenticated USING (
 EXISTS (SELECT 1 FROM public.members m WHERE m.campaign_id=campaign_id AND m.user_id=(SELECT auth.uid()) AND m.role='GM')
);
REVOKE ALL ON public.srd_character_weapon_instances,public.srd_cba_token_weapon_instances FROM PUBLIC,anon;
GRANT SELECT ON public.srd_character_weapon_instances,public.srd_cba_token_weapon_instances TO authenticated;