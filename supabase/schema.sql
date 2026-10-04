-- Jalankan di Supabase > SQL Editor > New query > Run

-- 1. PROFILES TABLE
create table if not exists profiles(
  id uuid primary key references auth.users on delete cascade,
  username text unique not null,
  name text not null,
  bio text default '',
  city text default '',
  avatar_url text,
  followers_count int default 0,
  following_count int default 0,
  created_at timestamp default now(),
  updated_at timestamp default now()
);

-- 2. POSTS TABLE
create table if not exists posts(
  id bigint generated always as identity primary key,
  user_id uuid not null references profiles(id) on delete cascade,
  content text not null check (char_length(content)<=2000),
  image_url text,
  caption text,
  created_at timestamp default now(),
  updated_at timestamp default now(),
  likes_count int default 0,
  comments_count int default 0
);

-- 3. LIKES TABLE
create table if not exists likes(
  post_id bigint references posts(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade,
  created_at timestamp default now(),
  primary key(post_id,user_id)
);

-- 4. COMMENTS TABLE
create table if not exists comments(
  id bigint generated always as identity primary key,
  post_id bigint references posts(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade,
  content text not null check (char_length(content)<=500),
  created_at timestamp default now(),
  updated_at timestamp default now()
);

-- 5. STORIES TABLE
create table if not exists stories(
  id bigint generated always as identity primary key,
  user_id uuid references profiles(id) on delete cascade,
  url text not null,
  is_video boolean default false,
  duration_sec int default 5,
  created_at timestamp default now(),
  expires_at timestamp default now() + interval '24 hours'
);

-- 6. REELS TABLE
create table if not exists reels(
  id bigint generated always as identity primary key,
  user_id uuid references profiles(id) on delete cascade,
  title text not null,
  video_url text not null,
  thumbnail_url text,
  duration_sec int,
  created_at timestamp default now(),
  updated_at timestamp default now(),
  likes_count int default 0,
  views_count int default 0
);

-- 7. REEL LIKES TABLE
create table if not exists reel_likes(
  reel_id bigint references reels(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade,
  created_at timestamp default now(),
  primary key(reel_id,user_id)
);

-- 8. USER BLOCKS TABLE
create table if not exists user_blocks(
  blocker_id uuid references profiles(id) on delete cascade,
  blocked_id uuid references profiles(id) on delete cascade,
  created_at timestamp default now(),
  primary key(blocker_id,blocked_id),
  check(blocker_id != blocked_id)
);

-- 9. POST REPORTS TABLE
create table if not exists post_reports(
  id bigint generated always as identity primary key,
  post_id bigint references posts(id) on delete cascade,
  reporter_id uuid references profiles(id) on delete cascade,
  reason text not null check (reason in ('spam','inappropriate','violence','hate_speech','misinformation','other')),
  description text,
  status text default 'pending' check (status in ('pending','reviewed','resolved','dismissed')),
  created_at timestamp default now(),
  unique(post_id,reporter_id)
);

-- 10. USER REPORTS TABLE
create table if not exists user_reports(
  id bigint generated always as identity primary key,
  reported_user_id uuid references profiles(id) on delete cascade,
  reporter_id uuid references profiles(id) on delete cascade,
  reason text not null,
  description text,
  status text default 'pending' check (status in ('pending','reviewed','resolved','dismissed')),
  created_at timestamp default now(),
  unique(reported_user_id,reporter_id)
);

-- 11. DELETED ACCOUNTS TABLE (audit trail)
create table if not exists deleted_accounts(
  id uuid primary key,
  username text not null,
  name text not null,
  deletion_reason text,
  deleted_at timestamp default now(),
  deleted_by text default 'user'
);

-- Enable Row Level Security on all tables
alter table profiles enable row level security;
alter table posts enable row level security;
alter table likes enable row level security;
alter table comments enable row level security;
alter table stories enable row level security;
alter table reels enable row level security;
alter table reel_likes enable row level security;
alter table user_blocks enable row level security;
alter table post_reports enable row level security;
alter table user_reports enable row level security;
alter table deleted_accounts enable row level security;

-- PROFILES POLICIES
create policy "Profiles are viewable by everyone" on profiles
  for select using (true);

create policy "Users can create their own profile" on profiles
  for insert with check (auth.uid() = id);

create policy "Users can update their own profile" on profiles
  for update using (auth.uid() = id) with check (auth.uid() = id);

create policy "Users cannot delete their own profile directly (use delete_account function)" on profiles
  for delete using (false);

-- POSTS POLICIES
create policy "Posts are viewable by everyone" on posts
  for select using (
    not exists (select 1 from user_blocks where blocker_id = posts.user_id and blocked_id = auth.uid())
    and not exists (select 1 from user_blocks where blocker_id = auth.uid() and blocked_id = posts.user_id)
  );

create policy "Users can create posts" on posts
  for insert with check (auth.uid() = user_id);

create policy "Users can update their own posts" on posts
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Users can delete their own posts" on posts
  for delete using (auth.uid() = user_id);

-- LIKES POLICIES
create policy "Likes are viewable by everyone" on likes
  for select using (true);

create policy "Users can like posts" on likes
  for insert with check (auth.uid() = user_id);

create policy "Users can unlike posts" on likes
  for delete using (auth.uid() = user_id);

-- COMMENTS POLICIES
create policy "Comments are viewable by everyone" on comments
  for select using (true);

create policy "Users can create comments" on comments
  for insert with check (auth.uid() = user_id);

create policy "Users can update their own comments" on comments
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Users can delete their own comments" on comments
  for delete using (auth.uid() = user_id);

-- STORIES POLICIES
create policy "Stories are viewable by everyone" on stories
  for select using (
    not exists (select 1 from user_blocks where blocker_id = stories.user_id and blocked_id = auth.uid())
    and not exists (select 1 from user_blocks where blocker_id = auth.uid() and blocked_id = stories.user_id)
  );

create policy "Users can create stories" on stories
  for insert with check (auth.uid() = user_id);

create policy "Users can delete their own stories" on stories
  for delete using (auth.uid() = user_id);

-- REELS POLICIES
create policy "Reels are viewable by everyone" on reels
  for select using (
    not exists (select 1 from user_blocks where blocker_id = reels.user_id and blocked_id = auth.uid())
    and not exists (select 1 from user_blocks where blocker_id = auth.uid() and blocked_id = reels.user_id)
  );

create policy "Users can create reels" on reels
  for insert with check (auth.uid() = user_id);

create policy "Users can update their own reels" on reels
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Users can delete their own reels" on reels
  for delete using (auth.uid() = user_id);

-- REEL LIKES POLICIES
create policy "Reel likes are viewable by everyone" on reel_likes
  for select using (true);

create policy "Users can like reels" on reel_likes
  for insert with check (auth.uid() = user_id);

create policy "Users can unlike reels" on reel_likes
  for delete using (auth.uid() = user_id);

-- USER BLOCKS POLICIES
create policy "Users can view their own blocks" on user_blocks
  for select using (auth.uid() = blocker_id);

create policy "Users can block others" on user_blocks
  for insert with check (auth.uid() = blocker_id);

create policy "Users can unblock" on user_blocks
  for delete using (auth.uid() = blocker_id);

-- POST REPORTS POLICIES
create policy "Users can view their own reports" on post_reports
  for select using (auth.uid() = reporter_id);

create policy "Users can report posts" on post_reports
  for insert with check (auth.uid() = reporter_id);

-- USER REPORTS POLICIES
create policy "Users can view their own reports" on user_reports
  for select using (auth.uid() = reporter_id);

create policy "Users can report users" on user_reports
  for insert with check (auth.uid() = reporter_id);

-- DELETED ACCOUNTS POLICIES (read-only for audit)
create policy "Only admins can view deleted accounts" on deleted_accounts
  for select using (false);

-- Create storage buckets for media
insert into storage.buckets (id, name, public, avif_autodetection, file_size_limit, allowed_mime_types)
values 
  ('stories', 'stories', true, true, 104857600, '{"image/*","video/*"}'),
  ('reels', 'reels', true, true, 1073741824, '{"video/*"}'),
  ('posts', 'posts', true, true, 104857600, '{"image/*"}'),
  ('avatars', 'avatars', true, true, 10485760, '{"image/*"}')
on conflict (id) do nothing;

-- Storage policies for stories
create policy "Users can upload stories" on storage.objects
  for insert to authenticated with check (
    bucket_id = 'stories' 
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Users can delete their own stories" on storage.objects
  for delete to authenticated using (
    bucket_id = 'stories'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Storage policies for reels
create policy "Users can upload reels" on storage.objects
  for insert to authenticated with check (
    bucket_id = 'reels'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Users can delete their own reels" on storage.objects
  for delete to authenticated using (
    bucket_id = 'reels'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Storage policies for posts
create policy "Users can upload post images" on storage.objects
  for insert to authenticated with check (
    bucket_id = 'posts'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Users can delete their own post images" on storage.objects
  for delete to authenticated using (
    bucket_id = 'posts'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Storage policies for avatars
create policy "Users can upload avatars" on storage.objects
  for insert to authenticated with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Users can delete their own avatars" on storage.objects
  for delete to authenticated using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- All authenticated users can read storage
create policy "Anyone can read storage" on storage.objects
  for select using (true);

-- Create function to delete account and all associated data
create or replace function delete_user_account(delete_reason text default 'user_requested')
returns json as $$
declare
  user_id uuid;
  username text;
  user_name text;
begin
  user_id := auth.uid();
  
  if user_id is null then
    return json_build_object('success', false, 'error', 'Not authenticated');
  end if;

  select p.username, p.name into username, user_name from profiles p where p.id = user_id;

  if username is null then
    return json_build_object('success', false, 'error', 'User not found');
  end if;

  -- Store deletion record before deleting
  insert into deleted_accounts (id, username, name, deletion_reason, deleted_by)
  values (user_id, username, user_name, delete_reason, 'user');

  -- Delete auth user (cascade will handle all related data)
  delete from auth.users where id = user_id;

  return json_build_object('success', true, 'message', 'Account deleted successfully');
end;
$$ language plpgsql security definer;

-- Create function to soft-delete/archive post
create or replace function delete_post_with_audit(post_id bigint)
returns json as $$
begin
  if not exists (select 1 from posts where id = post_id and user_id = auth.uid()) then
    return json_build_object('success', false, 'error', 'Post not found or not owned by you');
  end if;

  delete from posts where id = post_id;
  return json_build_object('success', true, 'message', 'Post deleted');
end;
$$ language plpgsql security definer;
