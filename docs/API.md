# Booking# API Structure

## Base URL
/api/v1

---

# Authentication

POST /auth/login
POST /auth/register
POST /auth/logout
POST /auth/forgot-password

---

# Classes

GET /classes
GET /classes/:id
GET /classes/categories

---

# Schedule

GET /schedule
GET /schedule/:date

---

POST /booking
GET /booking/history
POST /booking/cancel
GET /booking/:id

---

# Membership

GET /packages
POST /packages/purchase
GET /membership/active

---

# Wallet

GET /wallet
GET /wallet/history

---

# Notification

GET /notifications
POST /notifications/read

---

# Profile

GET /profile
PUT /profile