-- Jalankan di Supabase > SQL Editor > New query > Run
create table profiles(id uuid primary key references auth.users on delete cascade, username text unique not null, name text not null, bio text default '', city text default '', created_at timestamptz default now());
create table posts(id bigint generated always as identity primary key, user_id uuid not null references profiles(id) on delete cascade, content text not null check (char_length(content)<=2000), created_at timestamptz default now());
create table likes(post_id bigint references posts(id) on delete cascade, user_id uuid references profiles(id) on delete cascade, primary key(post_id,user_id));
create table comments(id bigint generated always as identity primary key, post_id bigint references posts(id) on delete cascade, user_id uuid references profiles(id) on delete cascade, content text not null check (char_length(content)<=1000), created_at timestamptz default now());
create table stories(id bigint generated always as identity primary key, user_id uuid references profiles(id) on delete cascade, url text not null, is_video boolean default false, created_at timestamptz default now());

-- Row Level Security: WAJIB, supaya orang tidak bisa mengubah data orang lain
do $$ declare t text; begin
 foreach t in array array['profiles','posts','likes','comments','stories'] loop
  execute format('alter table %I enable row level security',t);
  execute format('create policy "baca %1$s" on %1$I for select to authenticated using (true)',t);
 end loop; end $$;
create policy "profil buat" on profiles for insert to authenticated with check (auth.uid()=id);
create policy "profil ubah" on profiles for update to authenticated using (auth.uid()=id);
create policy "post buat" on posts for insert to authenticated with check (auth.uid()=user_id);
create policy "post hapus" on posts for delete to authenticated using (auth.uid()=user_id);
create policy "like buat" on likes for insert to authenticated with check (auth.uid()=user_id);
create policy "like hapus" on likes for delete to authenticated using (auth.uid()=user_id);
create policy "komentar buat" on comments for insert to authenticated with check (auth.uid()=user_id);
create policy "komentar hapus" on comments for delete to authenticated using (auth.uid()=user_id);
create policy "story buat" on stories for insert to authenticated with check (auth.uid()=user_id);
create policy "story hapus" on stories for delete to authenticated using (auth.uid()=user_id);

-- Penyimpanan foto/video story
insert into storage.buckets(id,name,public) values('stories','stories',true);
create policy "upload story" on storage.objects for insert to authenticated with check (bucket_id='stories' and (storage.foldername(name))[1]=auth.uid()::text);
