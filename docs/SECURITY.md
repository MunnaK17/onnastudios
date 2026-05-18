# Security Guidelines

## Authentication
- store token securely
- use flutter_secure_storage
- never store plain password
- clear token on logout

---

## API
- use HTTPS only
- attach auth token using interceptor
- handle token expiration globally
- avoid exposing sensitive error responses

---

## User Data
Protect:
- profile data
- booking history
- membership status
- transaction history

---

## QR Code
QR code must represent booking check-in token, not raw user personal data.

Recommended QR payload:
- booking_id
- checkin_token
- expiry timestamp