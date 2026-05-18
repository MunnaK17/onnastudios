# Error Handling Guidelines

## General Rule
All errors must be shown in a calm, non-aggressive tone consistent with the Onna Studios brand.

Avoid technical messages like:
- Request failed
- Server error
- Invalid token

Use user-friendly messages instead.

---

## Empty States

### No Classes Found
Message:
No class matches your search. Try adjusting your filter.

### No Upcoming Booking
Message:
You have no upcoming classes yet. Explore the schedule and reserve your next session.

### No Credits
Message:
Your credits have run out. Choose a package to continue booking sessions.

---

## Error States

### Network Error
Message:
We could not connect right now. Please check your connection and try again.

### Booking Failed
Message:
This class could not be booked. Please try another schedule or refresh availability.

### Payment Failed
Message:
Your package purchase was not completed. Please try again.

---

## Loading States
Use skeleton loading for:
- home content
- class list
- schedule list
- booking history
- package cards

Avoid blank screens.