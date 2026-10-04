-- Jalankan di Supabase > SQL Editor > New query > Run
create table profiles(
  id uuid primary key references auth.users on delete cascade,
  username text unique not null,
  name text not null,
  bio text default '',
  city text default '',
  created_at timestamptz default now()
);

create table posts(
  id bigint generated always as identity primary key,
  user_id uuid not null references profiles(id) on delete cascade,
  content text not null check (char_length(content)<=2000),
  created_at timestamptz default now()
);

create table likes(
  post_id bigint references posts(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade,
  primary key(post_id,user_id)
);

create table comments(
  id bigint generated always as identity primary key,
  post_id bigint references posts(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade,
  content text not null check (char_length(content)<=1000),
  created_at timestamptz default now()
);

create table stories(
  id bigint generated always as identity primary key,
  user_id uuid references profiles(id) on delete cascade,
  url text not null,
  is_video boolean default false,
  created_at timestamptz default now()
);

create table reels(
  id bigint generated always as identity primary key,
  user_id uuid not null references profiles(id) on delete cascade,
  title text not null,
  video_url text not null,
  thumbnail_url text,
  created_at timestamptz default now()
);

create table reel_likes(
  reel_id bigint references reels(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade,
  primary key(reel_id,user_id)
);

create table user_blocks(
  user_id uuid not null references profiles(id) on delete cascade,
  blocked_user_id uuid not null references profiles(id) on delete cascade,
  created_at timestamptz default now(),
  primary key(user_id, blocked_user_id)
);

create table post_reports(
  id bigint generated always as identity primary key,
  post_id bigint not null references posts(id) on delete cascade,
  reporter_id uuid not null references profiles(id) on delete cascade,
  reason text default 'spam',
  created_at timestamptz default now()
);

-- RLS
 do $$ declare t text; begin
  foreach t in array array['profiles','posts','likes','comments','stories','reels','reel_likes','user_blocks','post_reports'] loop
   execute format('alter table %I enable row level security', t);
   execute format('create policy "baca %1$s" on %1$I for select to authenticated using (true)', t);
  end loop;
 end $$;

create policy "profil buat" on profiles for insert to authenticated with check (auth.uid() = id);
create policy "profil ubah" on profiles for update to authenticated using (auth.uid() = id);

create policy "post buat" on posts for insert to authenticated with check (auth.uid() = user_id);
create policy "post hapus" on posts for delete to authenticated using (auth.uid() = user_id);

create policy "like buat" on likes for insert to authenticated with check (auth.uid() = user_id);
create policy "like hapus" on likes for delete to authenticated using (auth.uid() = user_id);

create policy "komentar buat" on comments for insert to authenticated with check (auth.uid() = user_id);
create policy "komentar hapus" on comments for delete to authenticated using (auth.uid() = user_id);

create policy "story buat" on stories for insert to authenticated with check (auth.uid() = user_id);
create policy "story hapus" on stories for delete to authenticated using (auth.uid() = user_id);

create policy "reel buat" on reels for insert to authenticated with check (auth.uid() = user_id);
create policy "reel hapus" on reels for delete to authenticated using (auth.uid() = user_id);

create policy "reel_like buat" on reel_likes for insert to authenticated with check (auth.uid() = user_id);
create policy "reel_like hapus" on reel_likes for delete to authenticated using (auth.uid() = user_id);

create policy "block buat" on user_blocks for insert to authenticated with check (auth.uid() = user_id);
create policy "block hapus" on user_blocks for delete to authenticated using (auth.uid() = user_id);

create policy "report buat" on post_reports for insert to authenticated with check (auth.uid() = reporter_id);

-- Storage buckets
insert into storage.buckets(id, name, public)
values ('stories', 'stories', true), ('reels', 'reels', true)
on conflict (id) do nothing;

create policy "upload story" on storage.objects
for insert to authenticated
with check (
  bucket_id = 'stories' and
  (storage.foldername(name))[1] = auth.uid()::text
);

create policy "read story" on storage.objects
for select to authenticated
using (bucket_id = 'stories');

create policy "upload reel" on storage.objects
for insert to authenticated
with check (
  bucket_id = 'reels' and
  (storage.foldername(name))[1] = auth.uid()::text
);

create policy "read reel" on storage.objects
for select to authenticated
using (bucket_id = 'reels');
