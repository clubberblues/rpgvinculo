
ALTER TABLE priv.srd_aoo_reaction_ledger
  ADD COLUMN IF NOT EXISTS combat_phase text NOT NULL DEFAULT 'normal';
ALTER TABLE priv.srd_aoo_reaction_ledger
  ADD CONSTRAINT srd_aoo_reaction_ledger_combat_phase_check
  CHECK (combat_phase IN ('surprise_round','normal'));

ALTER TABLE priv.srd_aoo_reaction_ledger
 DROP CONSTRAINT IF EXISTS srd_aoo_reaction_ledger_campaign_id_combat_round_actor_toke_key;
ALTER TABLE priv.srd_aoo_reaction_ledger
 DROP CONSTRAINT IF EXISTS srd_aoo_reaction_ledger_campaign_id_combat_round_actor_tok_key1;
ALTER TABLE priv.srd_aoo_reaction_ledger
 ADD CONSTRAINT srd_aoo_reaction_ledger_phase_trigger_uq
 UNIQUE(campaign_id,combat_phase,combat_round,actor_token_id,trigger_key);
ALTER TABLE priv.srd_aoo_reaction_ledger
 ADD CONSTRAINT srd_aoo_reaction_ledger_phase_ordinal_uq
 UNIQUE(campaign_id,combat_phase,combat_round,actor_token_id,reaction_number);

DO $patch$
DECLARE v_def text; v_new text;
BEGIN
 SELECT pg_get_functiondef('public.srd_reservar_ataque_oportunidade_srd(bigint,text,text,boolean)'::regprocedure) INTO v_def;
 v_new:=replace(v_def,'  v_round integer;','  v_round integer;'||E'\n  v_phase text;');
 v_new:=replace(v_new,
   '  v_round:=greatest(1,(v_combat->>''round'')::integer);',
   '  v_phase:=CASE WHEN coalesce(v_combat->''surprise''->>''phase'','''')=''surprise_round'' THEN ''surprise_round'' ELSE ''normal'' END;'||E'\n  v_round:=greatest(1,(v_combat->>''round'')::integer);');
 v_new:=replace(v_new,
   'WHERE campaign_id=p_campaign_id AND combat_round=v_round'||E'\n    AND actor_token_id=btrim(p_actor_token_id) AND trigger_key=btrim(p_trigger_key);',
   'WHERE campaign_id=p_campaign_id AND combat_phase=v_phase AND combat_round=v_round'||E'\n    AND actor_token_id=btrim(p_actor_token_id) AND trigger_key=btrim(p_trigger_key);');
 v_new:=replace(v_new,
   'WHERE campaign_id=p_campaign_id AND combat_round=v_round'||E'\n    AND actor_token_id=btrim(p_actor_token_id);',
   'WHERE campaign_id=p_campaign_id AND combat_phase=v_phase AND combat_round=v_round'||E'\n    AND actor_token_id=btrim(p_actor_token_id);');
 v_new:=replace(v_new,
   'campaign_id,combat_round,actor_token_id,trigger_key,reaction_number,max_reactions',
   'campaign_id,combat_phase,combat_round,actor_token_id,trigger_key,reaction_number,max_reactions');
 v_new:=replace(v_new,
   'p_campaign_id,v_round,btrim(p_actor_token_id),btrim(p_trigger_key),v_used+1,v_limit',
   'p_campaign_id,v_phase,v_round,btrim(p_actor_token_id),btrim(p_trigger_key),v_used+1,v_limit');
 IF v_new=v_def OR position('v_phase text' in v_new)=0 OR position('combat_phase=v_phase' in v_new)=0 OR position('p_campaign_id,v_phase,v_round' in v_new)=0 THEN
   RAISE EXCEPTION 'Falha ao aplicar a separação de fase ao ledger AOO.';
 END IF;
 EXECUTE v_new;
END;
$patch$;
REVOKE ALL ON priv.srd_aoo_reaction_ledger FROM PUBLIC, anon, authenticated;
