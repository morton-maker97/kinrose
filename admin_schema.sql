-- Run this once, AFTER schema.sql and seed.sql, to add:
--   - a single admin login
--   - a site-wide theme (colors, fonts, corner roundness) editable from the admin panel
--   - freeform content blocks (text / image / card) that can be added to any page

create table if not exists admins (
  user_id uuid primary key references auth.users(id) on delete cascade
);

-- Checks whether the currently logged-in user is an admin. SECURITY DEFINER means this
-- function can read the admins table even though nothing else can (see policies below) --
-- that's what keeps the admin list itself private while still being checkable.
create or replace function is_admin()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (select 1 from admins where user_id = auth.uid());
$$;

create table if not exists site_theme (
  id int primary key default 1,
  bg_color text not null default '#583b1f',
  text_color text not null default '#eae6e1',
  text_dim_color text not null default '#cbb9a3',
  card_bg_color text not null default '#6b4b29',
  radius text not null default '8px',
  heading_font text not null default 'system',
  body_font text not null default 'system',
  updated_at timestamptz not null default now(),
  constraint single_row check (id = 1)
);
insert into site_theme (id) values (1) on conflict (id) do nothing;

create table if not exists blocks (
  id uuid primary key default gen_random_uuid(),
  zone text not null,                              -- 'home' | 'projects' | 'videos' | 'project:<slug>'
  type text not null check (type in ('text', 'image', 'card')),
  content jsonb not null default '{}'::jsonb,
  position bigint not null default 0,
  created_at timestamptz not null default now()
);

alter table admins enable row level security;
alter table site_theme enable row level security;
alter table blocks enable row level security;

-- admins: no policies at all means no one can read or write it through the public API --
-- it's only ever consulted from inside is_admin(), which runs with elevated rights.

-- site_theme: anyone can read it (it styles the public site); only an admin can change it.
create policy "public can read theme" on site_theme
  for select to anon, authenticated using (true);
create policy "admin can update theme" on site_theme
  for update to authenticated using (is_admin()) with check (is_admin());

-- blocks: anyone can read them; only an admin can add, edit, or remove them.
create policy "public can read blocks" on blocks
  for select to anon, authenticated using (true);
create policy "admin can insert blocks" on blocks
  for insert to authenticated with check (is_admin());
create policy "admin can update blocks" on blocks
  for update to authenticated using (is_admin()) with check (is_admin());
create policy "admin can delete blocks" on blocks
  for delete to authenticated using (is_admin());

-- Storage: before running the lines below, create a bucket by hand once in
-- Supabase -> Storage -> New bucket -> name it exactly "site-images" -> Public bucket: ON.
-- Then come back and run this part to lock down who can upload to it.
create policy "public can view site-images" on storage.objects
  for select to anon, authenticated using (bucket_id = 'site-images');
create policy "admin can upload site-images" on storage.objects
  for insert to authenticated with check (bucket_id = 'site-images' and is_admin());
create policy "admin can update site-images" on storage.objects
  for update to authenticated using (bucket_id = 'site-images' and is_admin());
create policy "admin can delete site-images" on storage.objects
  for delete to authenticated using (bucket_id = 'site-images' and is_admin());
