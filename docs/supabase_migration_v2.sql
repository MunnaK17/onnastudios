-- =============================================================
-- Onna Studios — Supabase Database Migration v2
-- Run this in: Supabase Dashboard → SQL Editor → New query
-- =============================================================

-- Enable pgcrypto extension if not exists
create extension if not exists pgcrypto;

-- Remove the retired membership/package feature from existing databases.
drop function if exists public.purchase_package(text);
drop table if exists public.membership_packages;

-- =====================================================================
-- 1. PROFILES TABLE
-- Mirrors the UserModel fields and links to Supabase Auth users.
-- =====================================================================
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

-- =====================================================================
-- 2. ROW-LEVEL SECURITY (RLS) - PROFILES
-- =====================================================================
alter table public.profiles enable row level security;

-- Drop existing policies
drop policy if exists "Users can view own profile" on public.profiles;
drop policy if exists "Users can update own profile" on public.profiles;
drop policy if exists "Admins can view all profiles" on public.profiles;
drop policy if exists "Admins can update all profiles" on public.profiles;

-- Users can view own profile
create policy "Users can view own profile"
  on public.profiles
  for select
  using (auth.uid() = id);

-- Users can update own profile (except role and remaining_credits)
create policy "Users can update own profile"
  on public.profiles
  for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Admin function
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

-- Admins can view all profiles
create policy "Admins can view all profiles"
  on public.profiles
  for select
  using (public.is_admin());

-- Admins can update all profiles
create policy "Admins can update all profiles"
  on public.profiles
  for update
  using (public.is_admin())
  with check (public.is_admin());

-- Trigger to protect role and remaining_credits fields
drop function if exists public.protect_profile_role();
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

-- =====================================================================
-- 3. AUTO-CREATE PROFILE ON USER SIGNUP
-- =====================================================================
drop function if exists public.handle_new_user();
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

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute function public.handle_new_user();

-- =====================================================================
-- 4. UPDATED-AT HELPER
-- =====================================================================
drop function if exists public.set_updated_at();
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

-- =====================================================================
-- 5. WALLET TRANSACTIONS TABLE
-- =====================================================================
create table if not exists public.wallet_transactions (
  id          uuid        primary key default gen_random_uuid(),
  user_id     uuid        not null references auth.users on delete cascade,
  type        text        not null check (type in ('credit', 'debit')),
  amount      int         not null check (amount > 0),
  description text        not null default '',
  created_at  timestamptz not null default now()
);

alter table public.wallet_transactions enable row level security;

-- Drop existing policies
drop policy if exists "Users can view own wallet transactions" on public.wallet_transactions;
drop policy if exists "Admins can view all wallet transactions" on public.wallet_transactions;
drop policy if exists "Users can insert own wallet transactions" on public.wallet_transactions;
drop policy if exists "Admins can insert wallet transactions" on public.wallet_transactions;

-- Users can view own wallet transactions
create policy "Users can view own wallet transactions"
  on public.wallet_transactions
  for select
  using (auth.uid() = user_id);

-- Admins can view all wallet transactions
create policy "Admins can view all wallet transactions"
  on public.wallet_transactions
  for select
  using (public.is_admin());

-- Users can insert their own wallet transactions (for booking credits)
create policy "Users can insert own wallet transactions"
  on public.wallet_transactions
  for insert
  with check (auth.uid() = user_id);

-- Admins can insert wallet transactions
create policy "Admins can insert wallet transactions"
  on public.wallet_transactions
  for insert
  with check (public.is_admin());

-- =====================================================================
-- 6. INSTRUCTORS TABLE
-- =====================================================================
create table if not exists public.instructors (
  id         text primary key,
  name       text not null,
  photo_url  text not null default '',
  specialty  text not null default '',
  bio        text not null default '',
  class_ids  text[] not null default '{}',
  created_at timestamptz not null default now()
);

alter table public.instructors enable row level security;

-- Drop existing policies
drop policy if exists "Anyone can view instructors" on public.instructors;
drop policy if exists "Admins can manage instructors" on public.instructors;

-- Anyone can view instructors
create policy "Anyone can view instructors"
  on public.instructors for select using (true);

-- Admins can manage instructors
create policy "Admins can manage instructors"
  on public.instructors for all
  using (public.is_admin())
  with check (public.is_admin());

-- =====================================================================
-- 7. CLASSES TABLE
-- =====================================================================
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

alter table public.classes enable row level security;

-- Drop existing policies
drop policy if exists "Anyone can view classes" on public.classes;
drop policy if exists "Admins can manage classes" on public.classes;

-- Anyone can view classes
create policy "Anyone can view classes"
  on public.classes for select using (true);

-- Admins can manage classes
create policy "Admins can manage classes"
  on public.classes for all
  using (public.is_admin())
  with check (public.is_admin());

-- =====================================================================
-- 8. SCHEDULES TABLE
-- =====================================================================
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

alter table public.schedules enable row level security;

-- Drop existing policies
drop policy if exists "Anyone can view schedules" on public.schedules;
drop policy if exists "Admins can manage schedules" on public.schedules;
drop policy if exists "Authenticated users can update schedules" on public.schedules;

-- Anyone can view schedules
create policy "Anyone can view schedules"
  on public.schedules for select using (true);

-- Admins can manage schedules
create policy "Admins can manage schedules"
  on public.schedules for all
  using (public.is_admin())
  with check (public.is_admin());

-- =====================================================================
-- 9. STUDIO LOCATIONS TABLE
-- =====================================================================
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

alter table public.studio_locations enable row level security;

-- Drop existing policies
drop policy if exists "Anyone can view studio locations" on public.studio_locations;
drop policy if exists "Admins can manage studio locations" on public.studio_locations;

-- Anyone can view studio locations
create policy "Anyone can view studio locations"
  on public.studio_locations for select using (true);

-- Admins can manage studio locations
create policy "Admins can manage studio locations"
  on public.studio_locations for all
  using (public.is_admin())
  with check (public.is_admin());

-- =====================================================================
-- 10. BOOKINGS TABLE
-- User can INSERT directly from Flutter app
-- =====================================================================
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

alter table public.bookings enable row level security;

-- Drop existing policies
drop policy if exists "Users can view own bookings" on public.bookings;
drop policy if exists "Admins can view all bookings" on public.bookings;
drop policy if exists "Users can insert own bookings" on public.bookings;
drop policy if exists "Users can update own bookings" on public.bookings;
drop policy if exists "Admins can update all bookings" on public.bookings;

-- Users can view own bookings
create policy "Users can view own bookings"
  on public.bookings for select using (auth.uid() = user_id);

-- Admins can view all bookings
create policy "Admins can view all bookings"
  on public.bookings for select using (public.is_admin());

-- Users can insert their own bookings
create policy "Users can insert own bookings"
  on public.bookings for insert
  with check (auth.uid() = user_id);

-- Users can update their own bookings (e.g., cancel)
create policy "Users can update own bookings"
  on public.bookings for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Admins can update all bookings
create policy "Admins can update all bookings"
  on public.bookings for update
  using (public.is_admin())
  with check (public.is_admin());

-- =====================================================================
-- 11. NOTIFICATIONS TABLE
-- =====================================================================
create table if not exists public.notifications (
  id         text primary key default gen_random_uuid()::text,
  user_id    uuid not null references auth.users on delete cascade,
  title      text not null,
  message    text not null,
  type       text not null,
  is_read    bool not null default false,
  created_at timestamptz not null default now()
);

alter table public.notifications enable row level security;

-- Delete expired package notifications
delete from public.notifications
where type = 'packageExpiring';

-- Drop existing policies
drop policy if exists "Users can view own notifications" on public.notifications;
drop policy if exists "Admins can view all notifications" on public.notifications;
drop policy if exists "Admins can insert notifications" on public.notifications;
drop policy if exists "Users can update own notifications" on public.notifications;
drop policy if exists "Admins can update all notifications" on public.notifications;
drop policy if exists "Users can delete own notifications" on public.notifications;
drop policy if exists "Admins can delete all notifications" on public.notifications;

-- Users can view own notifications
create policy "Users can view own notifications"
  on public.notifications for select using (auth.uid() = user_id);

-- Admins can view all notifications
create policy "Admins can view all notifications"
  on public.notifications for select using (public.is_admin());

-- Users can insert their own notifications (for booking confirmations, etc.)
create policy "Users can insert own notifications"
  on public.notifications for insert
  with check (auth.uid() = user_id);

-- Admins can insert notifications
create policy "Admins can insert notifications"
  on public.notifications for insert
  with check (public.is_admin());

-- Users can update own notifications (mark as read)
create policy "Users can update own notifications"
  on public.notifications for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Admins can update all notifications
create policy "Admins can update all notifications"
  on public.notifications for update
  using (public.is_admin())
  with check (public.is_admin());

-- Users can delete own notifications
create policy "Users can delete own notifications"
  on public.notifications for delete
  using (auth.uid() = user_id);

-- Admins can delete all notifications
create policy "Admins can delete all notifications"
  on public.notifications for delete
  using (public.is_admin());

-- =====================================================================
-- 12. CREDIT PACKAGES TABLE
-- =====================================================================
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

-- Drop existing policies
drop policy if exists "Anyone can view active credit packages" on public.credit_packages;
drop policy if exists "Admins can manage credit packages" on public.credit_packages;

-- Anyone can view active credit packages
create policy "Anyone can view active credit packages"
  on public.credit_packages for select
  using (is_active = true);

-- Admins can manage credit packages
create policy "Admins can manage credit packages"
  on public.credit_packages for all
  using (public.is_admin())
  with check (public.is_admin());

-- =====================================================================
-- 13. GRANT EXECUTE FOR AUTHENTICATED USERS
-- =====================================================================
grant usage on schema public to authenticated;
grant all on schema public to authenticated;
grant all on schema public to anon;

-- =====================================================================
-- 14. SEED DATA - INSTRUCTORS
-- =====================================================================
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

-- =====================================================================
-- 15. SEED DATA - CLASSES
-- =====================================================================
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

-- =====================================================================
-- 16. SEED DATA - SCHEDULES
-- =====================================================================
insert into public.schedules (
  id, class_id, instructor_id, date, start_time, end_time,
  available_slots, total_slots, studio_room
)
values
  ('schedule-001', 'class-morning-flow', 'instructor-elena', current_date, '07:00', '08:00', 16, 16, 'The Sanctuary'),
  ('schedule-002', 'class-deep-rest', 'instructor-sarah', current_date, '09:00', '10:15', 14, 14, 'The Quiet Room'),
  ('schedule-003', 'class-power-pilates', 'instructor-marcus', current_date, '12:00', '12:50', 12, 12, 'The Flow Room'),
  ('schedule-004', 'class-breathwork', 'instructor-nadia', current_date, '18:30', '19:15', 18, 18, 'The Quiet Room'),
  ('schedule-005', 'class-morning-flow', 'instructor-elena', current_date + 1, '08:00', '09:00', 16, 16, 'The Sanctuary'),
  ('schedule-006', 'class-deep-rest', 'instructor-sarah', current_date + 1, '10:00', '11:15', 14, 14, 'The Quiet Room'),
  ('schedule-007', 'class-sculpt-strength', 'instructor-marcus', current_date + 1, '17:00', '17:55', 12, 12, 'The Flow Room'),
  ('schedule-008', 'class-breathwork', 'instructor-nadia', current_date + 2, '09:00', '09:45', 18, 18, 'The Quiet Room'),
  ('schedule-009', 'class-meditation', 'instructor-nadia', current_date + 2, '19:00', '19:40', 20, 20, 'The Sanctuary'),
  ('schedule-010', 'class-power-pilates', 'instructor-marcus', current_date + 3, '07:30', '08:20', 12, 12, 'The Flow Room')
on conflict (id) do update set
  date = excluded.date,
  start_time = excluded.start_time,
  end_time = excluded.end_time,
  available_slots = excluded.available_slots,
  total_slots = excluded.total_slots,
  studio_room = excluded.studio_room;

-- =====================================================================
-- 17. SEED DATA - STUDIO LOCATIONS
-- =====================================================================
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

-- =====================================================================
-- 18. SEED DATA - CREDIT PACKAGES
-- =====================================================================
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

-- =====================================================================
-- 19. RESCHEDULE BOOKING FUNCTION
-- Handles rescheduling with credit refund/charge logic
-- =====================================================================
drop function if exists public.reschedule_booking(text, text);
create or replace function public.reschedule_booking(
  p_booking_id text,
  p_new_schedule_id text
)
returns public.bookings
language plpgsql
security definer
set search_path = public
as $$
declare
  current_user_id uuid := auth.uid();
  old_booking public.bookings%rowtype;
  old_class public.classes%rowtype;
  new_schedule public.schedules%rowtype;
  new_class public.classes%rowtype;
  credit_difference int;
  new_booking public.bookings%rowtype;
begin
  if current_user_id is null then
    raise exception 'Please sign in to continue.';
  end if;

  -- Get old booking
  select * into old_booking from public.bookings where id = p_booking_id and user_id = current_user_id;
  if not found then
    raise exception 'Booking not found.';
  end if;

  if old_booking.status <> 'upcoming' then
    raise exception 'Only upcoming bookings can be rescheduled.';
  end if;

  -- Get old class info
  select * into old_class from public.classes where id = old_booking.class_id;
  if not found then
    raise exception 'Original class not found.';
  end if;

  -- Get new schedule
  select * into new_schedule from public.schedules where id = p_new_schedule_id for update;
  if not found then
    raise exception 'New schedule not found.';
  end if;

  if new_schedule.available_slots <= 0 then
    raise exception 'New schedule is full.';
  end if;

  -- Get new class info
  select * into new_class from public.classes where id = new_schedule.class_id;
  if not found then
    raise exception 'New class not found.';
  end if;

  -- Check if already booked this schedule
  if exists (
    select 1 from public.bookings
    where user_id = current_user_id
      and schedule_id = p_new_schedule_id
      and status = 'upcoming'
      and id <> p_booking_id
  ) then
    raise exception 'You already booked this schedule.';
  end if;

  -- Calculate credit difference (new - old)
  credit_difference := new_class.credit_cost - old_class.credit_cost;

  -- Update old booking to cancelled (soft delete)
  update public.bookings
  set status = 'cancelled'
  where id = p_booking_id;

  -- Restore slot on old schedule
  update public.schedules
  set available_slots = least(available_slots + 1, total_slots)
  where id = old_booking.schedule_id;

  -- Refund old class credits (add back)
  update public.profiles
  set remaining_credits = remaining_credits + old_class.credit_cost
  where id = current_user_id;

  -- Record refund transaction
  insert into public.wallet_transactions (user_id, type, amount, description)
  values (current_user_id, 'credit', old_class.credit_cost, old_class.title || ' reschedule refund');

  -- Check if user has enough credits for new class
  if credit_difference > 0 then
    if not exists (
      select 1 from public.profiles
      where id = current_user_id and remaining_credits >= credit_difference
    ) then
      raise exception 'Insufficient credits for new class. Need % more credits.', credit_difference;
    end if;

    -- Deduct additional credits
    update public.profiles
    set remaining_credits = remaining_credits - credit_difference
    where id = current_user_id;

    -- Record debit transaction
    insert into public.wallet_transactions (user_id, type, amount, description)
    values (current_user_id, 'debit', credit_difference, new_class.title || ' reschedule (upgrade)');
  end if;

  -- Reduce slot on new schedule
  update public.schedules
  set available_slots = available_slots - 1
  where id = p_new_schedule_id;

  -- Create new booking
  insert into public.bookings (
    user_id,
    schedule_id,
    class_id,
    status,
    qr_code_value
  )
  values (
    current_user_id,
    p_new_schedule_id,
    new_schedule.class_id,
    'upcoming',
    current_user_id::text || ':' || p_new_schedule_id || ':' ||
      floor(extract(epoch from clock_timestamp()) * 1000)::text
  )
  returning * into new_booking;

  return new_booking;
end;
$$;

grant execute on function public.reschedule_booking(text, text) to authenticated;

