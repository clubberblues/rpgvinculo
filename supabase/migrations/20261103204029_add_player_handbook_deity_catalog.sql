
create table if not exists public.srd_deities (
  deity_id text primary key,
  name text not null,
  alignment text not null check (alignment in ('Leal e Bom','Neutro e Bom','Caótico e Bom','Leal e Neutro','Neutro','Caótico e Neutro','Leal e Mau','Neutro e Mau','Caótico e Mau')),
  domains text[] not null default '{}'::text[],
  favored_weapon text not null,
  racial_races text[] not null default '{}'::text[],
  source_reference text not null default 'D&D 3.5 Livro do Jogador, capítulo 6, páginas 93–95',
  verification_status text not null default 'verified_book',
  created_at timestamptz not null default now()
);
create index if not exists srd_deities_racial_races_gin on public.srd_deities using gin(racial_races);
create index if not exists srd_deities_domains_gin on public.srd_deities using gin(domains);
alter table public.srd_deities enable row level security;
drop policy if exists srd_deities_read on public.srd_deities;
create policy srd_deities_read on public.srd_deities for select to authenticated using (true);
grant select on public.srd_deities to authenticated;

insert into public.srd_deities(deity_id,name,alignment,domains,favored_weapon,racial_races) values
('boccob','Boccob','Neutro',array['knowledge','magic','trickery'],'Bordão',array[]::text[]),
('corellon_larethian','Corellon Larethian','Caótico e Bom',array['chaos','good','protection','war'],'Espada longa',array['elfo','meio-elfo']),
('ehlonna','Ehlonna','Neutro e Bom',array['animal','good','plant','sun'],'Arco longo',array[]::text[]),
('erythnul','Erythnul','Caótico e Mau',array['chaos','evil','trickery','war'],'Maça-estrela',array[]::text[]),
('fharlanghn','Fharlanghn','Neutro',array['luck','protection','travel'],'Bordão',array[]::text[]),
('garl_glittergold','Garl Glittergold','Neutro e Bom',array['good','protection','trickery'],'Machado de batalha',array['gnomo']),
('gruumsh','Gruumsh','Caótico e Mau',array['chaos','evil','strength','war'],'Lança',array['meio-orc']),
('heironeous','Heironeous','Leal e Bom',array['good','law','war'],'Espada longa',array[]::text[]),
('hextor','Hextor','Leal e Mau',array['destruction','evil','law','war'],'Mangual',array[]::text[]),
('kord','Kord','Caótico e Bom',array['chaos','good','luck','strength'],'Espada larga',array[]::text[]),
('moradin','Moradin','Leal e Bom',array['earth','good','law','protection'],'Martelo de guerra',array['anao']),
('nerull','Nerull','Neutro e Mau',array['death','evil','trickery'],'Foice',array[]::text[]),
('obad_hai','Obad-Hai','Neutro',array['air','animal','earth','fire','plant','water'],'Bordão',array[]::text[]),
('olidammara','Olidammara','Caótico e Neutro',array['chaos','luck','trickery'],'Sabre',array[]::text[]),
('pelor','Pelor','Neutro e Bom',array['good','healing','strength','sun'],'Maça',array[]::text[]),
('st_cuthbert','St. Cuthbert','Leal e Neutro',array['destruction','law','protection','strength'],'Maça',array[]::text[]),
('vecna','Vecna','Neutro e Mau',array['evil','knowledge','magic'],'Adaga',array[]::text[]),
('wee_jas','Wee Jas','Leal e Neutro',array['death','law','magic'],'Adaga',array[]::text[]),
('yondalla','Yondalla','Leal e Bom',array['good','law','protection'],'Espada curta',array['halfling'])
on conflict (deity_id) do update set
  name=excluded.name,alignment=excluded.alignment,domains=excluded.domains,
  favored_weapon=excluded.favored_weapon,racial_races=excluded.racial_races,
  source_reference=excluded.source_reference,verification_status=excluded.verification_status;
