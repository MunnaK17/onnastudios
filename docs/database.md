# Database Schema

## users
- id
- full_name
- email
- password
- phone
- profile_photo
- created_at

---

## classes
- id
- title
- category
- instructor_id
- description
- intensity
- image
- duration

---

## schedules
- id
- class_id
- date
- start_time
- end_time
- slot

---

## bookings
- id
- user_id
- schedule_id
- qr_code
- status
- created_at

---

## memberships
- id
- name
- credits
- expiration_days
- price

---

## wallet_transactions
- id
- user_id
- type
- amount
- created_at