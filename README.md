# MentalMath

A modern Flutter mental mathematics practice app designed to sharpen fast calculation skills.

## Features

### 📚 Learn
- **Multiplication Tables 1–25** — tap any table for a full breakdown (1× through 12×)
- **Squares (1–30)** — visually displayed with superscript notation
- **Cubes (1–25)** — same clean layout as squares
- **Prime Numbers ≤ 100** — interactive Sieve of Eratosthenes visualization + prime list

### ✏️ Practice
- **4 Operations**: Addition, Subtraction, Multiplication, Division
- **6 Difficulty Levels** per operation, carefully tuned for mental math:
  - Addition: 1-digit+1-digit up to 3-digit+3-digit
  - Subtraction: always non-negative results
  - Multiplication: tables 1–25 + prime-number tables + general
  - Division: always integer quotients (generated from multiplication pairs)
- **Custom numeric keypad** — no distracting system keyboard
- **Timed & untimed** modes with configurable per-question time limit
- **Instant or end-of-session** feedback
- **Score, accuracy, streaks, grade** (S/A/B/C/D) per session

### 📊 Progress
- Session history with grade, accuracy, time
- Overall statistics (total sessions, accuracy, best streak)
- Offline persistence via SharedPreferences (no backend)

## Tech Stack

| Component | Library |
|-----------|---------|
| State Management | flutter_riverpod 2.6.1 |
| Navigation | go_router 14.8.1 |
| Persistence | shared_preferences 2.5.5 |
| Theme | Material 3 (Indigo seed, light + dark) |
| Flutter | 3.47.1 / Dart 3.13.1 |

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run on Linux desktop
flutter run -d linux

# Run tests
flutter test

# Analyze
flutter analyze

# Build release
flutter build linux --release
```

## Architecture

```
lib/
  app.dart           — Router + app entry
  models/            — Immutable data models
  services/          — Business logic (generator, scoring, persistence)
  providers/         — Riverpod state management
  features/          — Feature-first screen organization
  widgets/           — Shared reusable widgets
  core/              — Constants, theme, utilities
```

See `PLAN.md` for full architecture decisions and `PROGRESS.md` for current implementation status.
