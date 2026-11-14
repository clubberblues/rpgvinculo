-- Friends VTT: campaign-scoped SRD shop and atomic player transactions.
-- Drafted on the feature branch only. Do not apply to production before review/tests.

begin;

create table if not exists public.srd_campaign_shop_items (
  campaign_id bigint not null references public.campaigns(id) on delete cascade,
  equipment_id text not null references public.srd_equipment(id) on delete restrict,
  buy_price numeric(12,2) not null check (buy_price >= 0),
  sell_price numeric(12,2) check (sell_price is null or sell_price >= 0),
  stock_quantity integer not null default 0 check (stock_quantity >= 0),
  unlimited_stock boolean not null default false,
  active boolean not null default true,
  updated_by uuid not null,
  updated_at timestamptz not null default now(),
  primary key (campaign_id, equipment_id),
  constraint srd_campaign_shop_unlimited_stock_check
    check (not unlimited_stock or stock_quantity = 0)
);

create table if not exists public.srd_campaign_shop_receipts (
  receipt_id uuid primary key default gen_random_uuid(),
  campaign_id bigint not null references public.campaigns(id) on delete cascade,
  character_id bigint not null references public.characters(id) on delete cascade,
  actor_id uuid not null,
  operation text not null check (operation in ('buy', 'sell')),
  equipment_id text not null references public.srd_equipment(id) on delete restrict,
  quantity integer not null check (quantity between 1 and 99),
  unit_price numeric(12,2) not null check (unit_price >= 0),
  total numeric(14,2) not null check (total >= 0),
  gold_before numeric(14,2) not null check (gold_before >= 0),
  gold_after numeric(14,2) not null check (gold_after >= 0),
  idempotency_key uuid not null,
  created_at timestamptz not null default now(),
  constraint srd_campaign_shop_receipt_idempotency
    unique (campaign_id, actor_id, operation, idempotency_key)
);

create index if not exists srd_campaign_shop_receipts_character_created_idx
  on public.srd_campaign_shop_receipts (character_id, created_at desc);

alter table public.srd_campaign_shop_items enable row level security;
alter table public.srd_campaign_shop_receipts enable row level security;

drop policy if exists srd_campaign_shop_items_member_read on public.srd_campaign_shop_items;
create policy srd_campaign_shop_items_member_read
  on public.srd_campaign_shop_items for select to authenticated
  using (exists (
    select 1 from public.members m
    where m.campaign_id = srd_campaign_shop_items.campaign_id
      and m.user_id = (select auth.uid())
  ));

drop policy if exists srd_campaign_shop_receipts_owner_gm_read on public.srd_campaign_shop_receipts;
create policy srd_campaign_shop_receipts_owner_gm_read
  on public.srd_campaign_shop_receipts for select to authenticated
  using (
    actor_id = (select auth.uid())
    or exists (
      select 1 from public.characters ch
      where ch.id = srd_campaign_shop_receipts.character_id
        and ch.user_id = (select auth.uid())
    )
    or exists (
      select 1 from public.members m
      where m.campaign_id = srd_campaign_shop_receipts.campaign_id
        and m.user_id = (select auth.uid())
        and m.role = 'GM'
    )
  );

revoke all on public.srd_campaign_shop_items from public, anon, authenticated;
revoke all on public.srd_campaign_shop_receipts from public, anon, authenticated;
grant select on public.srd_campaign_shop_items, public.srd_campaign_shop_receipts to authenticated;

create or replace function public.srd_campaign_shop_configure_item(
  p_campaign_id bigint,
  p_equipment_id text,
  p_buy_price numeric,
  p_sell_price numeric default null,
  p_stock_quantity integer default 0,
  p_unlimited_stock boolean default false,
  p_active boolean default true
) returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then raise exception 'É necessário estar autenticado.'; end if;
  if not exists (
    select 1 from public.members m
    where m.campaign_id = p_campaign_id and m.user_id = v_uid and m.role = 'GM'
  ) then
    raise exception 'Somente o Mestre desta campanha pode administrar a loja.';
  end if;
  if p_equipment_id is null or not exists (
    select 1 from public.srd_equipment e where e.id = p_equipment_id
  ) then raise exception 'Equipamento não encontrado no catálogo SRD.'; end if;
  if p_buy_price is null or p_buy_price < 0 or p_buy_price > 9999999999.99
     or (p_sell_price is not null and (p_sell_price < 0 or p_sell_price > 9999999999.99)) then
    raise exception 'Preço inválido.';
  end if;
  if p_stock_quantity is null or p_stock_quantity < 0 or p_stock_quantity > 1000000 then
    raise exception 'Estoque inválido.';
  end if;
  if coalesce(p_unlimited_stock, false) and p_stock_quantity <> 0 then
    raise exception 'Estoque ilimitado deve ser configurado com quantidade zero.';
  end if;

  insert into public.srd_campaign_shop_items (
    campaign_id, equipment_id, buy_price, sell_price, stock_quantity,
    unlimited_stock, active, updated_by, updated_at
  ) values (
    p_campaign_id, p_equipment_id, p_buy_price, p_sell_price, p_stock_quantity,
    coalesce(p_unlimited_stock, false), coalesce(p_active, true), v_uid, now()
  )
  on conflict (campaign_id, equipment_id) do update set
    buy_price = excluded.buy_price,
    sell_price = excluded.sell_price,
    stock_quantity = excluded.stock_quantity,
    unlimited_stock = excluded.unlimited_stock,
    active = excluded.active,
    updated_by = excluded.updated_by,
    updated_at = now();

  return jsonb_build_object(
    'campaign_id', p_campaign_id, 'equipment_id', p_equipment_id,
    'buy_price', p_buy_price, 'sell_price', p_sell_price,
    'stock_quantity', case when p_unlimited_stock then null else p_stock_quantity end,
    'unlimited_stock', coalesce(p_unlimited_stock, false), 'active', coalesce(p_active, true)
  );
end;
$function$;

create or replace function public.srd_campaign_shop_buy(
  p_campaign_id bigint,
  p_character_id text,
  p_equipment_id text,
  p_quantity integer,
  p_idempotency_key uuid
) returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
declare
  v_uid uuid := auth.uid();
  v_character public.characters%rowtype;
  v_sheet public.srd_character_sheets%rowtype;
  v_listing public.srd_campaign_shop_items%rowtype;
  v_prior public.srd_campaign_shop_receipts%rowtype;
  v_before numeric(14,2);
  v_total numeric(14,2);
  v_after numeric(14,2);
  v_receipt public.srd_campaign_shop_receipts%rowtype;
begin
  if v_uid is null then raise exception 'É necessário estar autenticado.'; end if;
  if p_idempotency_key is null then raise exception 'Chave de operação obrigatória.'; end if;
  if p_quantity is null or p_quantity < 1 or p_quantity > 99 then raise exception 'Quantidade inválida.'; end if;

  perform pg_advisory_xact_lock(hashtextextended(
    p_campaign_id::text || ':' || v_uid::text || ':buy:' || p_idempotency_key::text, 0
  ));

  select * into v_prior from public.srd_campaign_shop_receipts r
  where r.campaign_id = p_campaign_id and r.actor_id = v_uid
    and r.operation = 'buy' and r.idempotency_key = p_idempotency_key;
  if found then
    if v_prior.character_id::text <> btrim(p_character_id) or v_prior.equipment_id <> p_equipment_id
       or v_prior.quantity <> p_quantity then
      raise exception 'Chave de operação já utilizada com dados diferentes.';
    end if;
    return to_jsonb(v_prior);
  end if;

  select * into v_character from public.characters ch
  where ch.id::text = btrim(p_character_id) and ch.campaign_id = p_campaign_id and ch.user_id = v_uid
  for update;
  if not found then raise exception 'A ficha não pertence a você nesta campanha.'; end if;
  if not exists (
    select 1 from public.members m
    where m.campaign_id = p_campaign_id and m.user_id = v_uid and m.role = 'PLAYER'
  ) then raise exception 'Somente jogadores podem comprar na loja.'; end if;

  select * into v_sheet from public.srd_character_sheets s
  where s.character_id = v_character.id for update;
  if not found then raise exception 'Ficha D&D 3.5 não encontrada.'; end if;

  select * into v_listing from public.srd_campaign_shop_items i
  where i.campaign_id = p_campaign_id and i.equipment_id = p_equipment_id
  for update;
  if not found or not v_listing.active then raise exception 'Este item não está disponível na loja.'; end if;
  if not v_listing.unlimited_stock and v_listing.stock_quantity < p_quantity then
    raise exception 'Estoque insuficiente.';
  end if;

  v_before := round(coalesce(v_sheet.ouro, 0), 2);
  v_total := round(v_listing.buy_price * p_quantity, 2);
  if v_before < v_total then raise exception 'Ouro insuficiente.'; end if;
  v_after := round(v_before - v_total, 2);
  if v_after > 2147483647.99 then raise exception 'O saldo excede o limite do espelho legado de ouro.'; end if;

  update public.srd_character_sheets set ouro = v_after where character_id = v_character.id;
  update public.characters set ouro = floor(v_after)::integer where id = v_character.id;
  if not v_listing.unlimited_stock then
    update public.srd_campaign_shop_items
      set stock_quantity = stock_quantity - p_quantity, updated_at = now()
    where campaign_id = p_campaign_id and equipment_id = p_equipment_id;
  end if;

  if exists (
    select 1 from public.srd_character_equipment e
    where e.character_id = btrim(p_character_id) and e.equipment_id = p_equipment_id and e.equipado
  ) then
    raise exception 'Desequipe este item antes de comprar outra unidade do mesmo equipamento.';
  end if;

  insert into public.srd_character_equipment(character_id, equipment_id, quantidade, equipado)
  values (btrim(p_character_id), p_equipment_id, p_quantity, false)
  on conflict (character_id, equipment_id) do update
    set quantidade = public.srd_character_equipment.quantidade + excluded.quantidade;

  insert into public.srd_campaign_shop_receipts (
    campaign_id, character_id, actor_id, operation, equipment_id, quantity,
    unit_price, total, gold_before, gold_after, idempotency_key
  ) values (
    p_campaign_id, v_character.id, v_uid, 'buy', p_equipment_id, p_quantity,
    v_listing.buy_price, v_total, v_before, v_after, p_idempotency_key
  ) returning * into v_receipt;

  return to_jsonb(v_receipt);
end;
$function$;

create or replace function public.srd_campaign_shop_sell(
  p_campaign_id bigint,
  p_character_id text,
  p_equipment_id text,
  p_quantity integer,
  p_idempotency_key uuid
) returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
declare
  v_uid uuid := auth.uid();
  v_character public.characters%rowtype;
  v_sheet public.srd_character_sheets%rowtype;
  v_listing public.srd_campaign_shop_items%rowtype;
  v_held public.srd_character_equipment%rowtype;
  v_prior public.srd_campaign_shop_receipts%rowtype;
  v_before numeric(14,2);
  v_total numeric(14,2);
  v_after numeric(14,2);
  v_receipt public.srd_campaign_shop_receipts%rowtype;
begin
  if v_uid is null then raise exception 'É necessário estar autenticado.'; end if;
  if p_idempotency_key is null then raise exception 'Chave de operação obrigatória.'; end if;
  if p_quantity is null or p_quantity < 1 or p_quantity > 99 then raise exception 'Quantidade inválida.'; end if;

  perform pg_advisory_xact_lock(hashtextextended(
    p_campaign_id::text || ':' || v_uid::text || ':sell:' || p_idempotency_key::text, 0
  ));

  select * into v_prior from public.srd_campaign_shop_receipts r
  where r.campaign_id = p_campaign_id and r.actor_id = v_uid
    and r.operation = 'sell' and r.idempotency_key = p_idempotency_key;
  if found then
    if v_prior.character_id::text <> btrim(p_character_id) or v_prior.equipment_id <> p_equipment_id
       or v_prior.quantity <> p_quantity then
      raise exception 'Chave de operação já utilizada com dados diferentes.';
    end if;
    return to_jsonb(v_prior);
  end if;

  select * into v_character from public.characters ch
  where ch.id::text = btrim(p_character_id) and ch.campaign_id = p_campaign_id and ch.user_id = v_uid
  for update;
  if not found then raise exception 'A ficha não pertence a você nesta campanha.'; end if;
  if not exists (
    select 1 from public.members m
    where m.campaign_id = p_campaign_id and m.user_id = v_uid and m.role = 'PLAYER'
  ) then raise exception 'Somente jogadores podem vender na loja.'; end if;

  select * into v_sheet from public.srd_character_sheets s
  where s.character_id = v_character.id for update;
  if not found then raise exception 'Ficha D&D 3.5 não encontrada.'; end if;

  select * into v_listing from public.srd_campaign_shop_items i
  where i.campaign_id = p_campaign_id and i.equipment_id = p_equipment_id
  for update;
  if not found or not v_listing.active or v_listing.sell_price is null then
    raise exception 'Este item não pode ser vendido nesta loja.';
  end if;

  select * into v_held from public.srd_character_equipment e
  where e.character_id = btrim(p_character_id) and e.equipment_id = p_equipment_id
  for update;
  if not found or v_held.quantidade < p_quantity then raise exception 'Quantidade insuficiente no inventário.'; end if;
  if v_held.equipado then
    raise exception 'Desequipe este item antes de vendê-lo.';
  end if;

  v_before := round(coalesce(v_sheet.ouro, 0), 2);
  v_total := round(v_listing.sell_price * p_quantity, 2);
  v_after := round(v_before + v_total, 2);
  if v_after > 2147483647.99 then raise exception 'O saldo excede o limite do espelho legado de ouro.'; end if;
  if not v_listing.unlimited_stock and v_listing.stock_quantity > 1000000 - p_quantity then
    raise exception 'O estoque da loja atingiria o limite permitido.';
  end if;

  if v_held.quantidade = p_quantity then
    delete from public.srd_character_equipment
    where character_id = btrim(p_character_id) and equipment_id = p_equipment_id;
  else
    update public.srd_character_equipment
      set quantidade = quantidade - p_quantity
    where character_id = btrim(p_character_id) and equipment_id = p_equipment_id;
  end if;

  update public.srd_character_sheets set ouro = v_after where character_id = v_character.id;
  update public.characters set ouro = floor(v_after)::integer where id = v_character.id;
  if not v_listing.unlimited_stock then
    update public.srd_campaign_shop_items
      set stock_quantity = stock_quantity + p_quantity, updated_at = now()
    where campaign_id = p_campaign_id and equipment_id = p_equipment_id;
  end if;

  insert into public.srd_campaign_shop_receipts (
    campaign_id, character_id, actor_id, operation, equipment_id, quantity,
    unit_price, total, gold_before, gold_after, idempotency_key
  ) values (
    p_campaign_id, v_character.id, v_uid, 'sell', p_equipment_id, p_quantity,
    v_listing.sell_price, v_total, v_before, v_after, p_idempotency_key
  ) returning * into v_receipt;

  return to_jsonb(v_receipt);
end;
$function$;

revoke all on function public.srd_campaign_shop_configure_item(bigint,text,numeric,numeric,integer,boolean,boolean) from public, anon;
revoke all on function public.srd_campaign_shop_buy(bigint,text,text,integer,uuid) from public, anon;
revoke all on function public.srd_campaign_shop_sell(bigint,text,text,integer,uuid) from public, anon;
grant execute on function public.srd_campaign_shop_configure_item(bigint,text,numeric,numeric,integer,boolean,boolean) to authenticated;
grant execute on function public.srd_campaign_shop_buy(bigint,text,text,integer,uuid) to authenticated;
grant execute on function public.srd_campaign_shop_sell(bigint,text,text,integer,uuid) to authenticated;

commit;
