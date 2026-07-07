# Onna Studios

Onna Studios is a premium wellness and yoga booking mobile application built with Flutter.

The app allows members to:
- browse yoga classes
- book schedules
- purchase memberships
- track remaining credits
- view instructors
- receive notifications
- manage profiles

## Tech Stack
- Flutter
- Dart
- Riverpod
- GoRouter
- Dio
- Freezed

## Features
- yoga booking system
- QR booking confirmation
- membership packages
- credit wallet
- schedule calendar
- notifications
- instructor profiles
- studio location

## Design Philosophy
The app follows a calm, elegant, breathable wellness design system inspired by premium yoga studios.

## Running Project

```bash
flutter pub get
flutter run
```

## Supabase Configuration

Auth uses Supabase, so the app must be run with these Dart defines:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

Or create a local, ignored `supabase.env.json` file:

```json
{
  "SUPABASE_URL": "https://your-project.supabase.co",
  "SUPABASE_ANON_KEY": "your-anon-key"
}
```

Then run:

```bash
flutter run --dart-define-from-file=supabase.env.json
```
