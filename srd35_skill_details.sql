-- Add normalized SRD descriptions, source references, and rules metadata.
alter table public.srd_skills add column if not exists descricao text; alter table public.srd_skills add column if not exists srd_source_url text; alter table public.srd_skills add column if not exists dados_tecnicos jsonb not null default '{}'::jsonb;
