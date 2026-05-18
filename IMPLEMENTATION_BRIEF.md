# MOBILE DEVELOPMENT IMPLEMENTATION BRIEF
## Project: Onna Studios Mobile App

build a production-ready mobile application based on the provided wellness/yoga studio design system and UX direction.

the application name is:
"Onna Studios"

the app must match the premium wellness aesthetic from the design specification:
- calm
- elegant
- minimalist
- modern
- mobile-first
- whitespace-heavy
- soft rounded UI
- luxury wellness studio feel

---

# PRIMARY GOAL

implement a fully structured mobile app architecture that supports:

- viewing classes
- viewing schedules
- booking classes
- purchasing membership/packages
- tracking remaining credits
- viewing studio locations
- managing member profile
- notifications and reminders

focus on:
- scalable architecture
- reusable components
- clean state management
- responsive mobile UI
- maintainable codebase
- smooth UX interactions

---

# TECH STACK

preferred:
- React Native Expo
- TypeScript
- NativeWind / Tailwind
- React Navigation
- Zustand or Redux Toolkit
- React Query / TanStack Query
- Axios
- React Hook Form
- Zod validation

alternative stack is acceptable if architecture remains modular and scalable.

---

# APP STRUCTURE

implement folder structure like:

/src
  /components
  /screens
  /navigation
  /services
  /hooks
  /store
  /types
  /utils
  /constants
  /assets

---

# DESIGN IMPLEMENTATION RULES

follow the visual style from design references strictly.

UI characteristics:
- premium wellness aesthetic
- rounded cards
- large imagery
- soft shadows
- elegant typography
- spacious layout
- minimalist interaction
- smooth transitions

primary colors:
- cream
- beige
- off-white
- brown
- charcoal
- gold accent
- terracotta accent

avoid:
- overly saturated colors
- cluttered layouts
- sharp corners
- dense spacing
- gaming-style UI
- neon colors

---

# MOBILE TARGET

target:
- iPhone layout first
- responsive for modern mobile devices
- safe area support
- bottom navigation optimized

bottom navigation:
- home
- classes
- schedule
- package
- profile

---

# REQUIRED SCREENS

implement all screens:

1. Splash / Onboarding
2. Login
3. Register
4. Home
5. Classes
6. Class Detail
7. Schedule / Timetable
8. Booking Flow
9. Booking Confirmation
10. Package / Membership
11. My Credit / Wallet
12. Location
13. Instructor Profile
14. Notifications
15. Profile
16. Booking History

---

# SCREEN REQUIREMENTS

## HOME
must include:
- hero banner
- featured classes
- upcoming bookings
- membership summary
- quick actions
- promotional cards

---

## CLASSES
must include:
- search bar
- category filter
- class cards
- instructor preview
- intensity/category labels

---

## CLASS DETAIL
must include:
- large class image
- instructor info
- schedule info
- description
- benefits
- book button

---

## SCHEDULE
must include:
- calendar/timetable
- day selector
- available slots
- filtering
- class availability indicator

---

## BOOKING FLOW
must include:
- selected class summary
- selected schedule
- remaining credit
- confirmation modal
- success state

---

## BOOKING CONFIRMATION
must include:
- QR code
- booking details
- studio location
- add to calendar button

---

## PACKAGE / MEMBERSHIP
must include:
- package comparison
- pricing cards
- membership benefits
- purchase CTA

---

## MY CREDIT / WALLET
must include:
- remaining credits
- transaction history
- active membership
- expiration info

---

## LOCATION
must include:
- studio image
- address
- map preview
- open maps button
- contact info

---

## INSTRUCTOR PROFILE
must include:
- instructor photo
- biography
- specialties
- available classes

---

## NOTIFICATIONS
must include:
- upcoming class reminders
- booking updates
- package reminders

---

## PROFILE
must include:
- profile info
- settings
- membership status
- logout

---

## BOOKING HISTORY
must include:
- past bookings
- upcoming bookings
- status badges
- quick rebook button

---

# UX REQUIREMENTS

must implement:
- smooth navigation transitions
- loading skeletons
- empty states
- error states
- pull to refresh
- responsive touch targets
- clean spacing hierarchy

interaction style:
- calm
- fluid
- premium
- non-aggressive

---

# COMPONENT RULES

create reusable components for:
- buttons
- cards
- inputs
- bottom sheet
- modals
- navigation
- calendar item
- class card
- package card
- section headers

avoid duplicated UI code.

---

# STATE MANAGEMENT

implement scalable state handling for:
- auth
- booking
- membership
- credit
- notifications
- schedule

---

# API STRUCTURE

prepare service layer for future backend integration.

example:
- auth service
- booking service
- class service
- membership service
- notification service

use mock data first if backend is unavailable.

---

# PERFORMANCE

optimize:
- image loading
- navigation performance
- list rendering
- component re-rendering

---

# ACCESSIBILITY

ensure:
- readable typography
- proper spacing
- accessible touch areas
- clean contrast
- intuitive navigation

---

# DELIVERABLES

generate:
- complete mobile UI implementation
- reusable component architecture
- navigation setup
- mock data integration
- clean scalable codebase

after implementation:
- explain project structure
- explain reusable components
- explain state flow
- explain how to run the app