-- ==============================================================================
-- AI COMPASSION AMBASSADORS - SUPABASE MIGRATION SCRIPT
-- ==============================================================================
-- Run this script in your Supabase Project:
-- Dashboard -> SQL Editor -> New Query -> Paste and Run.
-- ==============================================================================

-- 1. Create the ambassadors table
create table if not exists public.ambassadors (
  id text primary key,
  name text not null,
  region_number text not null,
  region_name text default 'Global',
  country text default 'Global',
  city text default '',
  role text default '',
  bio text default '',
  image_url text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Create index on created_at and region_number for performant ordering and filtering
create index if not exists idx_ambassadors_created_at on public.ambassadors (created_at desc);
create index if not exists idx_ambassadors_region on public.ambassadors (region_number);

-- 3. Enable Row Level Security (RLS)
alter table public.ambassadors enable row level security;

-- 4. Policies for public.ambassadors table
drop policy if exists "Allow public read access on ambassadors" on public.ambassadors;
create policy "Allow public read access on ambassadors"
  on public.ambassadors
  for select
  using (true);

drop policy if exists "Allow public insert on ambassadors" on public.ambassadors;
create policy "Allow public insert on ambassadors"
  on public.ambassadors
  for insert
  with check (true);

-- 5. Storage Bucket Setup: ambassador-photos
-- Insert bucket if it does not already exist
insert into storage.buckets (id, name, public)
values ('ambassador-photos', 'ambassador-photos', true)
on conflict (id) do update set public = true;

-- 6. Storage Policies for ambassador-photos bucket
drop policy if exists "Allow public read on ambassador photos" on storage.objects;
create policy "Allow public read on ambassador photos"
  on storage.objects
  for select
  using (bucket_id = 'ambassador-photos');

drop policy if exists "Allow public upload on ambassador photos" on storage.objects;
create policy "Allow public upload on ambassador photos"
  on storage.objects
  for insert
  with check (bucket_id = 'ambassador-photos');

drop policy if exists "Allow public update on ambassador photos" on storage.objects;
create policy "Allow public update on ambassador photos"
  on storage.objects
  for update
  using (bucket_id = 'ambassador-photos');
