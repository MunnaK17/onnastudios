-- =====================================================================
-- Onna Studios — Reschedule Booking Function
-- Run this in: Supabase Dashboard → SQL Editor → New query
-- =====================================================================

-- Drop existing function if any
drop function if exists public.reschedule_booking(text, text);

-- Create reschedule function
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

-- Grant execute permission
grant execute on function public.reschedule_booking(text, text) to authenticated;
