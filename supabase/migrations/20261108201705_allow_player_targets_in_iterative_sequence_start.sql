
DO $$
DECLARE
  v_oid oid;
  v_def text;
  v_old_filter text := $old$where t.token->>'id' = btrim(p_target_token_id)
    and t.token->>'tipo' in ('npc','monstro');$old$;
  v_new_filter text := $new$where t.token->>'id' = btrim(p_target_token_id)
    and t.token->>'tipo' in ('npc','monstro','player');$new$;
  v_old_comment text := '-- O alvo precisa ser um token real de NPC/monstro da própria campanha.';
  v_new_comment text := '-- O alvo precisa ser um token único e real da própria campanha.';
  v_old_count text := $old$  if v_target_count <> 1 then
    raise exception 'O alvo NPC/monstro não foi encontrado ou está duplicado nesta campanha.';
  end if;$old$;
  v_new_count text := $new$  if v_target_count <> 1 then
    raise exception 'O alvo não foi encontrado ou está duplicado nesta campanha.';
  end if;
  if exists (
    select 1 from jsonb_array_elements(v_tokens) t(token)
    where t.token->>'id'=btrim(p_target_token_id)
      and t.token->>'tipo'='player'
  ) then
    if btrim(p_target_token_id)=btrim(p_character_id)
       or not exists (
         select 1 from public.characters ch
         join public.members m on m.campaign_id=ch.campaign_id
           and m.user_id=ch.user_id and m.role='PLAYER'
         join public.srd_character_sheets sh on sh.character_id=ch.id
         where ch.id::text=btrim(p_target_token_id)
           and ch.campaign_id=p_campaign_id
       ) then
      raise exception 'O alvo jogador não possui ficha ativa nesta campanha ou é o próprio atacante.';
    end if;
  end if;$new$;
BEGIN
  SELECT p.oid INTO v_oid
  FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
  WHERE n.nspname='priv' AND p.proname='iniciar_sequencia_ataque_iterativo_srd_5_impl';
  IF v_oid IS NULL THEN RAISE EXCEPTION 'Implementação-base de início de sequência não encontrada.'; END IF;
  v_def:=pg_get_functiondef(v_oid);
  IF position(v_old_comment in v_def)=0 OR position(v_old_filter in v_def)=0 OR position(v_old_count in v_def)=0 THEN
    RAISE EXCEPTION 'Estrutura original de validação do alvo mudou; migração cancelada.';
  END IF;
  v_def:=replace(v_def,v_old_comment,v_new_comment);
  v_def:=replace(v_def,v_old_filter,v_new_filter);
  v_def:=replace(v_def,v_old_count,v_new_count);
  EXECUTE v_def;
END
$$;
