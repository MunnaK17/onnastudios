-- =============================================================
-- Onna Studios — Supabase Database Migration
-- Run this in: Supabase Dashboard → SQL Editor → New query
-- =============================================================

create extension if not exists pgcrypto;

-- ================================================================
-- CHECK-IN FEATURE MIGRATION (Add to existing database)
-- Run these separately after the base migration
-- ================================================================

-- Add check-in fields to bookings table
alter table public.bookings
  add column if not exists checked_in boolean not null default false;

alter table public.bookings
  add column if not exists checked_in_at timestamptz;

-- Create function for instructor to check in a booking
drop function if exists public.check_in_booking(text);
create or replace function public.check_in_booking(p_qr_code text)
returns public.bookings
language plpgsql
security definer
set search_path = public
as $$
declare
  is_admin_user boolean := public.is_admin();
  target_booking public.bookings%rowtype;
begin
  -- Only admins can check in bookings
  if not is_admin_user then
    raise exception 'Only instructors can perform check-in.';
  end if;

  -- Find booking by qr_code_value
  select * into target_booking
  from public.bookings
  where qr_code_value = p_qr_code
  for update;

  if not found then
    raise exception 'Booking not found. Please check the QR code.';
  end if;

  -- Check if already checked in
  if target_booking.checked_in then
    raise exception 'This booking has already been checked in.';
  end if;

  -- Check if booking is still upcoming
  if target_booking.status <> 'upcoming' then
    raise exception 'This booking is no longer active and cannot be checked in.';
  end if;

  -- Update the booking
  update public.bookings
  set
    checked_in = true,
    checked_in_at = now()
  where id = target_booking.id
  returning * into target_booking;

  return target_booking;
end;
$$;

grant execute on function public.check_in_booking(text) to authenticated;

-- Create function to auto-mark no-shows (run via cron)
drop function if exists public.mark_no_shows();
create or replace function public.mark_no_shows()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  current_time time := now()::time;
  current_date date := now()::date;
begin
  -- Mark bookings as no-show (expired) if:
  -- 1. Status is 'upcoming'
  -- 2. NOT checked in
  -- 3. The schedule has ended (start_time < current time)
  update public.bookings b
  set status = 'expired'
  from public.schedules s
  where b.schedule_id = s.id
    and b.status = 'upcoming'
    and b.checked_in = false
    and s.date < current_date;
end;
$$;

grant execute on function public.mark_no_shows() to supabase_admin;

-- ================================================================
-- END CHECK-IN FEATURE
-- ================================================================

-- Remove the retired membership/package feature from existing databases.
drop function if exists public.purchase_package(text);
drop table if exists public.membership_packages;

-- 1. Create the profiles table
-- Mirrors the UserModel fields and links to Supabase Auth users.
create table if not exists public.profiles (
  id                   uuid references auth.users on delete cascade primary key,
  full_name            text           not null default '',
  phone                text           not null default '',
  profile_photo        text           not null default '',
  role                 text           not null default 'member'
                       check (role in ('member', 'admin')),
  remaining_credits    int            not null default 0,
  created_at           timestamptz    not null default now(),
  updated_at           timestamptz    not null default now()
);

alter table public.profiles
  add column if not exists role text not null default 'member'
  check (role in ('member', 'admin'));

alter table public.profiles
  drop column if exists active_membership_id;

-- 2. Row-Level Security (RLS)
-- Only the owner of the profile row can read or update it.
alter table public.profiles enable row level security;

drop policy if exists "Users can view own profile" on public.profiles;
create policy "Users can view own profile"
  on public.profiles
  for select
  using (auth.uid() = id);

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile"
  on public.profiles
  for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and role = 'admin'
  );
$$;

drop policy if exists "Admins can view all profiles" on public.profiles;
create policy "Admins can view all profiles"
  on public.profiles
  for select
  using (public.is_admin());

drop policy if exists "Admins can update all profiles" on public.profiles;
create policy "Admins can update all profiles"
  on public.profiles
  for update
  using (public.is_admin())
  with check (public.is_admin());

create or replace function public.protect_profile_role()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if current_user in ('postgres', 'supabase_admin') then
    return new;
  end if;

  if (
    new.role is distinct from old.role or
    new.remaining_credits is distinct from old.remaining_credits
  ) and not public.is_admin() then
    raise exception 'Only admins or trusted server functions can update protected profile fields.';
  end if;

  return new;
end;
$$;

drop trigger if exists protect_profile_role on public.profiles;

create trigger protect_profile_role
  before update on public.profiles
  for each row
  execute function public.protect_profile_role();

-- 3. Auto-create profile row when a new user signs up
-- The trigger reads full_name and phone from the signup metadata
-- passed via supabase.auth.signUp(data: { 'full_name': ..., 'phone': ... }).
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, phone)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    coalesce(new.raw_user_meta_data->>'phone', '')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

-- Drop and re-create trigger so the migration is idempotent.
drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute function public.handle_new_user();

-- 4. Updated-at helper
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_profiles_updated_at on public.profiles;

create trigger set_profiles_updated_at
  before update on public.profiles
  for each row
  execute function public.set_updated_at();

-- 5. Wallet transaction history
-- The wallet balance is stored in profiles.remaining_credits.
-- This table stores the credit/debit audit trail shown on the wallet screen.
create table if not exists public.wallet_transactions (
  id          uuid        primary key default gen_random_uuid(),
  user_id     uuid        not null references auth.users on delete cascade,
  type        text        not null check (type in ('credit', 'debit')),
  amount      int         not null check (amount > 0),
  description text        not null default '',
  created_at  timestamptz not null default now()
);

alter table public.wallet_transactions enable row level security;

drop policy if exists "Users can view own wallet transactions" on public.wallet_transactions;
create policy "Users can view own wallet transactions"
  on public.wallet_transactions
  for select
  using (auth.uid() = user_id);

drop policy if exists "Admins can view all wallet transactions" on public.wallet_transactions;
create policy "Admins can view all wallet transactions"
  on public.wallet_transactions
  for select
  using (public.is_admin());

drop policy if exists "Users can insert own wallet transactions" on public.wallet_transactions;

drop policy if exists "Admins can insert wallet transactions" on public.wallet_transactions;
create policy "Admins can insert wallet transactions"
  on public.wallet_transactions
  for insert
  with check (public.is_admin());

-- 6. App master data
create table if not exists public.instructors (
  id         text primary key,
  name       text not null,
  photo_url  text not null default '',
  specialty  text not null default '',
  bio        text not null default '',
  class_ids  text[] not null default '{}',
  created_at timestamptz not null default now()
);

create table if not exists public.classes (
  id               text primary key,
  title            text not null,
  category         text not null,
  description      text not null default '',
  image_url        text not null default '',
  duration_minutes int not null default 0,
  intensity        text not null,
  credit_cost      int not null default 1,
  instructor_id    text not null references public.instructors(id),
  benefits         text[] not null default '{}',
  is_featured      bool not null default false,
  created_at       timestamptz not null default now()
);

create table if not exists public.schedules (
  id              text primary key,
  class_id        text not null references public.classes(id),
  instructor_id   text not null references public.instructors(id),
  date            date not null,
  start_time      text not null,
  end_time        text not null,
  available_slots int not null default 0,
  total_slots     int not null default 0,
  studio_room     text not null default '',
  created_at      timestamptz not null default now()
);

create table if not exists public.studio_locations (
  id            text primary key,
  name          text not null,
  address       text not null default '',
  image_url     text not null default '',
  latitude      double precision not null default 0,
  longitude     double precision not null default 0,
  phone         text not null default '',
  opening_hours text not null default '',
  is_main       bool not null default false,
  created_at    timestamptz not null default now()
);

alter table public.instructors enable row level security;
alter table public.classes enable row level security;
alter table public.schedules enable row level security;
alter table public.studio_locations enable row level security;

drop policy if exists "Anyone can view instructors" on public.instructors;
create policy "Anyone can view instructors"
  on public.instructors for select using (true);

drop policy if exists "Admins can manage instructors" on public.instructors;
create policy "Admins can manage instructors"
  on public.instructors for all
  using (public.is_admin())
  with check (public.is_admin());

drop policy if exists "Anyone can view classes" on public.classes;
create policy "Anyone can view classes"
  on public.classes for select using (true);

drop policy if exists "Admins can manage classes" on public.classes;
create policy "Admins can manage classes"
  on public.classes for all
  using (public.is_admin())
  with check (public.is_admin());

drop policy if exists "Anyone can view schedules" on public.schedules;
create policy "Anyone can view schedules"
  on public.schedules for select using (true);

drop policy if exists "Authenticated users can update schedules" on public.schedules;

drop policy if exists "Admins can manage schedules" on public.schedules;
create policy "Admins can manage schedules"
  on public.schedules for all
  using (public.is_admin())
  with check (public.is_admin());

drop policy if exists "Anyone can view studio locations" on public.studio_locations;
create policy "Anyone can view studio locations"
  on public.studio_locations for select using (true);

drop policy if exists "Admins can manage studio locations" on public.studio_locations;
create policy "Admins can manage studio locations"
  on public.studio_locations for all
  using (public.is_admin())
  with check (public.is_admin());

-- 7. Booking and notifications
create table if not exists public.bookings (
  id            text primary key default gen_random_uuid()::text,
  user_id       uuid not null references auth.users on delete cascade,
  schedule_id   text not null references public.schedules(id),
  class_id      text not null references public.classes(id),
  status        text not null default 'upcoming'
                check (status in ('upcoming', 'completed', 'cancelled', 'expired')),
  qr_code_value text not null default '',
  booked_at     timestamptz not null default now()
);

create table if not exists public.notifications (
  id         text primary key default gen_random_uuid()::text,
  user_id    uuid not null references auth.users on delete cascade,
  title      text not null,
  message    text not null,
  type       text not null,
  is_read    bool not null default false,
  created_at timestamptz not null default now()
);

alter table public.bookings enable row level security;
alter table public.notifications enable row level security;

delete from public.notifications
where type = 'packageExpiring';

drop policy if exists "Users can view own bookings" on public.bookings;
create policy "Users can view own bookings"
  on public.bookings for select using (auth.uid() = user_id);

drop policy if exists "Admins can view all bookings" on public.bookings;
create policy "Admins can view all bookings"
  on public.bookings for select using (public.is_admin());

drop policy if exists "Users can insert own bookings" on public.bookings;

drop policy if exists "Users can update own bookings" on public.bookings;

drop policy if exists "Admins can update all bookings" on public.bookings;
create policy "Admins can update all bookings"
  on public.bookings for update using (public.is_admin())
  with check (public.is_admin());

drop policy if exists "Users can view own notifications" on public.notifications;
create policy "Users can view own notifications"
  on public.notifications for select using (auth.uid() = user_id);

drop policy if exists "Admins can view all notifications" on public.notifications;
create policy "Admins can view all notifications"
  on public.notifications for select using (public.is_admin());

drop policy if exists "Admins can insert notifications" on public.notifications;
create policy "Admins can insert notifications"
  on public.notifications for insert with check (public.is_admin());

drop policy if exists "Users can update own notifications" on public.notifications;
create policy "Users can update own notifications"
  on public.notifications for update using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Admins can update all notifications" on public.notifications;
create policy "Admins can update all notifications"
  on public.notifications for update using (public.is_admin())
  with check (public.is_admin());

drop policy if exists "Users can delete own notifications" on public.notifications;
create policy "Users can delete own notifications"
  on public.notifications for delete using (auth.uid() = user_id);

drop policy if exists "Admins can delete all notifications" on public.notifications;
create policy "Admins can delete all notifications"
  on public.notifications for delete using (public.is_admin());

-- 8. Atomic booking actions used by the mobile app
drop function if exists public.create_booking(text, text);
create or replace function public.create_booking(p_schedule_id text, p_class_id text)
returns public.bookings
language plpgsql
security definer
set search_path = public
as $$
declare
  current_user_id uuid := auth.uid();
  selected_schedule public.schedules%rowtype;
  selected_class public.classes%rowtype;
  current_credits int;
  created_booking public.bookings%rowtype;
begin
  if current_user_id is null then
    raise exception 'Please sign in to continue.';
  end if;

  select *
  into selected_schedule
  from public.schedules
  where id = p_schedule_id
  for update;

  if not found then
    raise exception 'Schedule not found.';
  end if;

  if selected_schedule.class_id <> p_class_id then
    raise exception 'This schedule does not match the selected class.';
  end if;

  if selected_schedule.available_slots <= 0 then
    raise exception 'This class is already full.';
  end if;

  select *
  into selected_class
  from public.classes
  where id = p_class_id;

  if not found then
    raise exception 'Class not found.';
  end if;

  if exists (
    select 1
    from public.bookings
    where user_id = current_user_id
      and schedule_id = p_schedule_id
      and status = 'upcoming'
  ) then
    raise exception 'You already booked this schedule.';
  end if;

  select remaining_credits
  into current_credits
  from public.profiles
  where id = current_user_id
  for update;

  if not found then
    raise exception 'Profile not found.';
  end if;

  if current_credits < selected_class.credit_cost then
    raise exception 'Insufficient credits.';
  end if;

  insert into public.bookings (
    user_id,
    schedule_id,
    class_id,
    status,
    qr_code_value
  )
  values (
    current_user_id,
    p_schedule_id,
    p_class_id,
    'upcoming',
    current_user_id::text || ':' || p_schedule_id || ':' ||
      floor(extract(epoch from clock_timestamp()) * 1000)::text
  )
  returning * into created_booking;

  update public.schedules
  set available_slots = available_slots - 1
  where id = p_schedule_id;

  update public.profiles
  set remaining_credits = remaining_credits - selected_class.credit_cost
  where id = current_user_id;

  insert into public.wallet_transactions (
    user_id,
    type,
    amount,
    description
  )
  values (
    current_user_id,
    'debit',
    selected_class.credit_cost,
    selected_class.title || ' booking'
  );

  return created_booking;
end;
$$;

drop function if exists public.cancel_booking(text);
create or replace function public.cancel_booking(p_booking_id text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  current_user_id uuid := auth.uid();
  selected_booking public.bookings%rowtype;
  selected_class public.classes%rowtype;
begin
  if current_user_id is null then
    raise exception 'Please sign in to continue.';
  end if;

  select *
  into selected_booking
  from public.bookings
  where id = p_booking_id
    and user_id = current_user_id
  for update;

  if not found then
    raise exception 'Booking not found.';
  end if;

  if selected_booking.status <> 'upcoming' then
    raise exception 'Only upcoming bookings can be cancelled.';
  end if;

  select *
  into selected_class
  from public.classes
  where id = selected_booking.class_id;

  if not found then
    raise exception 'Class not found.';
  end if;

  update public.bookings
  set status = 'cancelled'
  where id = selected_booking.id;

  update public.schedules
  set available_slots = least(available_slots + 1, total_slots)
  where id = selected_booking.schedule_id;

  update public.profiles
  set remaining_credits = remaining_credits + selected_class.credit_cost
  where id = current_user_id;

  insert into public.wallet_transactions (
    user_id,
    type,
    amount,
    description
  )
  values (
    current_user_id,
    'credit',
    selected_class.credit_cost,
    selected_class.title || ' booking refund'
  );
end;
$$;

grant execute on function public.create_booking(text, text) to authenticated;
grant execute on function public.cancel_booking(text) to authenticated;

-- 9. Seed public data
insert into public.instructors (id, name, photo_url, specialty, bio, class_ids)
values
  ('instructor-elena', 'Elena Rostova', 'https://images.unsplash.com/photo-1594381898411-846e7d193883', 'Vinyasa Flow', 'Elena guides fluid, breath-led classes with a grounded and elegant pace.', array['class-morning-flow', 'class-power-align']),
  ('instructor-sarah', 'Sarah Jenkins', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2', 'Restorative Yoga', 'Sarah creates deeply calming sessions focused on nervous system restoration.', array['class-deep-rest', 'class-meditation']),
  ('instructor-marcus', 'Marcus Tan', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e', 'Pilates and Strength', 'Marcus teaches precise, strength-building movement with a quiet confidence.', array['class-power-pilates', 'class-sculpt-strength']),
  ('instructor-nadia', 'Nadia Larasati', 'https://images.unsplash.com/photo-1534751516642-a1af1ef26a56', 'Breathwork', 'Nadia leads breathwork and meditation practices for clarity and calm.', array['class-breathwork', 'class-meditation'])
on conflict (id) do update set
  name = excluded.name,
  photo_url = excluded.photo_url,
  specialty = excluded.specialty,
  bio = excluded.bio,
  class_ids = excluded.class_ids;

insert into public.classes (
  id, title, category, description, image_url, duration_minutes, intensity,
  credit_cost, instructor_id, benefits, is_featured
)
values
  ('class-morning-flow', 'Morning Flow', 'yogaFlow', 'A gentle morning sequence designed to awaken the body.', 'https://images.unsplash.com/photo-1506126613408-eca07ce68773', 60, 'medium', 1, 'instructor-elena', array['Improves mobility', 'Builds steady energy', 'Calms the mind'], true),
  ('class-deep-rest', 'Deep Rest', 'restorative', 'A restorative practice with supported postures and soft breathwork.', 'https://images.unsplash.com/photo-1599447292180-45fd84092ef4', 75, 'low', 1, 'instructor-sarah', array['Releases tension', 'Supports recovery', 'Encourages sleep'], true),
  ('class-power-pilates', 'Power Pilates', 'pilates', 'A sculpting mat pilates class with controlled strength work.', 'https://images.unsplash.com/photo-1518611012118-696072aa579a', 50, 'high', 1, 'instructor-marcus', array['Strengthens core', 'Improves posture', 'Builds endurance'], true),
  ('class-breathwork', 'Quiet Breath', 'breathwork', 'A guided breathwork session for emotional steadiness.', 'https://images.unsplash.com/photo-1529693662653-9d480530a697', 45, 'low', 1, 'instructor-nadia', array['Reduces stress', 'Improves focus', 'Restores balance'], true),
  ('class-sculpt-strength', 'Sculpt Strength', 'strength', 'Low-impact strength work using mindful repetitions.', 'https://images.unsplash.com/photo-1517963628607-235ccdd5476c', 55, 'high', 1, 'instructor-marcus', array['Builds strength', 'Improves stability', 'Boosts confidence'], false),
  ('class-meditation', 'Still Mind Meditation', 'meditation', 'A quiet guided meditation class with breath awareness.', 'https://images.unsplash.com/photo-1508672019048-805c876b67e2', 40, 'low', 1, 'instructor-nadia', array['Cultivates clarity', 'Supports calm', 'Improves presence'], false)
on conflict (id) do update set
  title = excluded.title,
  category = excluded.category,
  description = excluded.description,
  image_url = excluded.image_url,
  duration_minutes = excluded.duration_minutes,
  intensity = excluded.intensity,
  credit_cost = excluded.credit_cost,
  instructor_id = excluded.instructor_id,
  benefits = excluded.benefits,
  is_featured = excluded.is_featured;

insert into public.schedules (
  id, class_id, instructor_id, date, start_time, end_time,
  available_slots, total_slots, studio_room
)
values
  ('schedule-001', 'class-morning-flow', 'instructor-elena', current_date, '07:00', '08:00', 3, 16, 'The Sanctuary'),
  ('schedule-002', 'class-deep-rest', 'instructor-sarah', current_date, '09:00', '10:15', 8, 14, 'The Quiet Room'),
  ('schedule-003', 'class-power-pilates', 'instructor-marcus', current_date, '12:00', '12:50', 0, 12, 'The Flow Room'),
  ('schedule-004', 'class-breathwork', 'instructor-nadia', current_date, '18:30', '19:15', 10, 18, 'The Quiet Room'),
  ('schedule-005', 'class-morning-flow', 'instructor-elena', current_date + 1, '08:00', '09:00', 12, 16, 'The Sanctuary'),
  ('schedule-006', 'class-deep-rest', 'instructor-sarah', current_date + 1, '10:00', '11:15', 6, 14, 'The Quiet Room'),
  ('schedule-007', 'class-sculpt-strength', 'instructor-marcus', current_date + 1, '17:00', '17:55', 9, 12, 'The Flow Room'),
  ('schedule-008', 'class-breathwork', 'instructor-nadia', current_date + 2, '09:00', '09:45', 15, 18, 'The Quiet Room'),
  ('schedule-009', 'class-meditation', 'instructor-nadia', current_date + 2, '19:00', '19:40', 18, 20, 'The Sanctuary'),
  ('schedule-010', 'class-power-pilates', 'instructor-marcus', current_date + 3, '07:30', '08:20', 10, 12, 'The Flow Room')
on conflict (id) do update set
  date = excluded.date,
  start_time = excluded.start_time,
  end_time = excluded.end_time,
  available_slots = excluded.available_slots,
  total_slots = excluded.total_slots,
  studio_room = excluded.studio_room;

insert into public.studio_locations (
  id, name, address, image_url, latitude, longitude, phone, opening_hours, is_main
)
values (
  'location-main',
  'Onna Studios - The Sanctuary',
  'Jl. Senopati No. 24, Jakarta Selatan, Indonesia',
  'https://images.unsplash.com/photo-1603988363607-e1e4a66962c6',
  -6.2275,
  106.8089,
  '+62 21 5550 1200',
  'Mon-Sun, 06:00-21:00',
  true
)
on conflict (id) do update set
  name = excluded.name,
  address = excluded.address,
  image_url = excluded.image_url,
  latitude = excluded.latitude,
  longitude = excluded.longitude,
  phone = excluded.phone,
  opening_hours = excluded.opening_hours,
  is_main = excluded.is_main;

-- 10. Credit Packages for top-up
create table if not exists public.credit_packages (
  id              text primary key,
  name            text not null,
  description     text not null default '',
  credits         int not null check (credits > 0),
  price           numeric(10,2) not null check (price >= 0),
  bonus_credits   int not null default 0,
  is_featured     bool not null default false,
  is_active       bool not null default true,
  valid_days      int not null default 0,
  created_at      timestamptz not null default now()
);

alter table public.credit_packages enable row level security;

drop policy if exists "Anyone can view active credit packages" on public.credit_packages;
create policy "Anyone can view active credit packages"
  on public.credit_packages for select using (is_active = true);

drop policy if exists "Admins can manage credit packages" on public.credit_packages;
create policy "Admins can manage credit packages"
  on public.credit_packages for all
  using (public.is_admin())
  with check (public.is_admin());

-- Seed credit packages
insert into public.credit_packages (id, name, description, credits, price, bonus_credits, is_featured, valid_days)
values
  ('package-starter', 'Starter Pack', 'Perfect for beginners exploring our classes', 5, 110000.00, 0, false, 90),
  ('package-popular', 'Popular Pack', 'Our most loved package for regular practitioners', 12, 240000.00, 2, true, 180),
  ('package-premium', 'Premium Pack', 'Best value for dedicated yogis', 25, 450000.00, 5, true, 365),
  ('package-ultimate', 'Ultimate Pack', 'Unlimited exploration for the devoted', 50, 800000.00, 15, false, 365)
on conflict (id) do update set
  name = excluded.name,
  description = excluded.description,
  credits = excluded.credits,
  price = excluded.price,
  bonus_credits = excluded.bonus_credits,
  is_featured = excluded.is_featured,
  valid_days = excluded.valid_days;
