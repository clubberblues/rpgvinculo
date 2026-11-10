create or replace function public.srd_validar_uso_pericia_srd(p_character_id text,p_skill_id text)
returns jsonb
language plpgsql
security definer
set search_path=pg_catalog,public,pg_temp
as $$
declare
  v_character public.characters%rowtype;
  v_skill public.srd_skills%rowtype;
  v_rage_active boolean:=false;
  v_blocked boolean:=false;
  v_reason text;
  v_rogue_level integer:=0;
  v_trapfinding boolean:=false;
  v_linked_campaign_ids bigint[]:='{}'::bigint[];
  v_linked_token_ids text[]:='{}'::text[];
begin
  if auth.uid() is null then raise exception 'Autenticação obrigatória.'; end if;
  if nullif(btrim(p_character_id),'') is null or nullif(btrim(p_skill_id),'') is null then
    raise exception 'Personagem e perícia são obrigatórios.';
  end if;
  select * into v_character from public.characters
   where id::text=btrim(p_character_id) and user_id=auth.uid();
  if not found then raise exception 'Personagem não encontrado ou não pertence ao usuário.'; end if;
  select * into v_skill from public.srd_skills
   where id=btrim(p_skill_id) and source_status is distinct from 'excluded';
  if not found then raise exception 'Perícia não encontrada ou indisponível no catálogo.'; end if;

  select coalesce(
    max(cl.class_level) filter(where cls.class_key='rogue'),
    case when not exists(select 1 from public.srd_character_class_levels lv where lv.character_id=v_character.id)
      and sh.classe_id='ladino' then greatest(1,coalesce(sh.nivel,1)) else 0 end
  ) into v_rogue_level
  from public.srd_character_sheets sh
  left join public.srd_character_class_levels cl on cl.character_id=sh.character_id
  left join public.srd_classes cls on cls.id=cl.class_id
  where sh.character_id=v_character.id
  group by sh.character_id,sh.classe_id,sh.nivel;
  v_trapfinding:=coalesce(v_rogue_level,0)>=1;

  select coalesce(array_agg(distinct c.id),'{}'::bigint[]),
         coalesce(array_agg(distinct tok.value->>'id') filter(where tok.value->>'id' is not null),'{}'::text[])
    into v_linked_campaign_ids,v_linked_token_ids
  from public.campaigns c
  join public.members gm on gm.campaign_id=c.id and gm.user_id=auth.uid() and gm.role='GM'
  cross join lateral jsonb_array_elements(
    case when jsonb_typeof(c.cba_data->'tokens')='array' then c.cba_data->'tokens' else '[]'::jsonb end
  ) tok(value)
  where tok.value->>'tipo'='npc' and tok.value->>'sourceCharacterId'=v_character.id::text;

  select exists(
    select 1 from public.srd_campaign_effects e
    where e.active=true and e.effect_data->>'source_feature'='barbarian_rage'
      and (
        (v_character.campaign_id is not null and e.campaign_id=v_character.campaign_id
          and e.target_kind='character' and e.target_id=v_character.id::text)
        or (e.campaign_id=any(v_linked_campaign_ids) and e.target_kind='token'
          and e.target_id=any(v_linked_token_ids))
      )
  ) into v_rage_active;

  if v_rage_active then
    v_blocked:=v_skill.id='concentracao'
      or (upper(coalesce(v_skill.atributo,'')) in ('INT','DES','CAR')
        and v_skill.id not in ('srd35_skill_balance','fuga','intimidacao','cavalgar'));
    if v_blocked then
      v_reason:=case when v_skill.id='concentracao'
        then 'Não é possível usar Concentração enquanto estiver em Fúria.'
        else 'Durante a Fúria, não é possível usar perícias de Inteligência, Destreza ou Carisma, exceto Equilíbrio, Arte da Fuga, Intimidação e Cavalgar.' end;
      return jsonb_build_object('allowed',false,'rage_active',true,'skill_id',v_skill.id,
        'skill_name',v_skill.nome,'ability',v_skill.atributo,'reason',v_reason,
        'trapfinding',v_trapfinding,'trapfinding_search_dc_over_20',v_trapfinding,
        'trapfinding_magic_search_dc','25 + nível da magia','trapfinding_disarm_magic',v_trapfinding);
    end if;
  end if;
  return jsonb_build_object('allowed',true,'rage_active',v_rage_active,'skill_id',v_skill.id,
    'skill_name',v_skill.nome,'ability',v_skill.atributo,'trapfinding',v_trapfinding,
    'trapfinding_search_dc_over_20',v_trapfinding,'trapfinding_magic_search_dc','25 + nível da magia',
    'trapfinding_disarm_magic',v_trapfinding);
end;
$$;
revoke all on function public.srd_validar_uso_pericia_srd(text,text) from public,anon;
grant execute on function public.srd_validar_uso_pericia_srd(text,text) to authenticated;