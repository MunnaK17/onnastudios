# Architecture Overview

## Architecture Style
The project uses Clean Architecture with feature-first modular organization.

## Layers

### Presentation Layer
Contains:
- screens
- widgets
- providers
- controllers

### Domain Layer
Contains:
- entities
- repositories
- usecases

### Data Layer
Contains:
- models
- datasource
- repository implementation
- API services

---

## Feature Modules

/auth
/home
/classes
/booking
/schedule
/package
/wallet
/profile
/notification
/location

---

## Principles
- scalable
- testable
- maintainable
- reusable
- modular