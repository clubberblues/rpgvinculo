CREATE OR REPLACE FUNCTION public.equipar_item_npc_vinculado_srd(
  p_campaign_id bigint,
  p_token_id text,
  p_equipment_id text,
  p_equipado boolean
)
RETURNS jsonb
LANGUAGE sql
SECURITY INVOKER
SET search_path = pg_catalog, public, private
AS $function$
  SELECT private.equipar_item_npc_vinculado_impl(
    p_campaign_id, p_token_id, p_equipment_id, p_equipado
  );
$function$;

CREATE OR REPLACE FUNCTION public.equipar_arma_instancia_npc_vinculado_srd(
  p_campaign_id bigint,
  p_token_id text,
  p_instance_id uuid,
  p_hand_slot text,
  p_equipado boolean
)
RETURNS jsonb
LANGUAGE sql
SECURITY INVOKER
SET search_path = pg_catalog, public, private
AS $function$
  SELECT private.equipar_arma_instancia_npc_vinculado_impl(
    p_campaign_id, p_token_id, p_instance_id, p_hand_slot, p_equipado
  );
$function$;

REVOKE ALL ON FUNCTION public.equipar_item_npc_vinculado_srd(bigint,text,text,boolean) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.equipar_arma_instancia_npc_vinculado_srd(bigint,text,uuid,text,boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.equipar_item_npc_vinculado_srd(bigint,text,text,boolean) TO authenticated;
GRANT EXECUTE ON FUNCTION public.equipar_arma_instancia_npc_vinculado_srd(bigint,text,uuid,text,boolean) TO authenticated;