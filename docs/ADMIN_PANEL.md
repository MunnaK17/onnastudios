# Admin Panel Preparation

The mobile app reads operational data from Supabase. A future admin panel can
connect to the same Supabase project and manage the same tables.

## Recommended Stack

- Next.js or React for the admin web app
- `@supabase/supabase-js` for auth and database access
- Supabase Auth with admin users marked in `public.profiles.role`

## Admin Role

Admin users are regular Supabase Auth users whose profile row has:

```sql
role = 'admin'
```

Promote an admin manually from the Supabase SQL Editor:

```sql
update public.profiles
set role = 'admin'
where id = '<auth-user-id>';
```

Do not allow users to set their own role from the mobile app or admin signup
form.

## Tables Prepared For Admin CRUD

- `public.instructors`
- `public.classes`
- `public.schedules`
- `public.studio_locations`
- `public.notifications`

Admins can also view operational data:

- `public.profiles`
- `public.bookings`
- `public.wallet_transactions`

## Mobile App Contract

The mobile app expects enum values to stay in Dart enum `name` format:

- class category: `yogaFlow`, `pilates`, `meditation`, `breathwork`, `strength`, `restorative`
- class intensity: `low`, `medium`, `high`
- booking status: `upcoming`, `completed`, `cancelled`, `expired`
- wallet transaction type: `credit`, `debit`
- notification type: `classReminder`, `bookingConfirmed`, `creditRunningLow`, `promotion`, `scheduleUpdate`

The admin panel should write snake_case database columns, matching
`docs/supabase_migration.sql`.

## Later Hardening

Booking creation currently updates credits and schedule slots from the mobile
client. Before launch, move booking creation/cancellation and credit adjustments
to a Supabase RPC or Edge Function so those updates are atomic and server-side.
