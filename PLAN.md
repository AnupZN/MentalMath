# MentalMath – Implementation Plan

> **Flutter 3.47.1 · Dart 3.13.1 · Material 3**
> Started: 2026-09-17

---

## Status Legend
- ✅ Complete
- 🔄 In Progress
- ⬜ Pending
- ❌ Blocked / Issue

---

## Phase Overview

| Phase | Description | Status |
|-------|-------------|--------|
| 0 | Project init, structure, plan | ✅ |
| 1 | Core models, data, question-generation engine | ✅ |
| 2 | State management & persistence layer | ✅ |
| 3 | Navigation & shell scaffolding | ✅ |
| 4 | Learn section – Tables, Squares, Cubes, Primes | ✅ |
| 5 | Practice section – all operations + difficulty | ✅ |
| 6 | Session/scoring/stats UI | ✅ |
| 7 | Home/dashboard screen | ✅ |
| 8 | Theme, animations, polish | ✅ |
| 9 | Unit tests, flutter analyze, build verification | ✅ |
| 10 | Final review, cleanup, docs | ✅ |

---

## 1. Architecture

### Pattern
- **Feature-first folder structure** with shared core/ layer.
- **Riverpod** (flutter_riverpod) for state management — lightweight, testable, null-safe.
- **SharedPreferences** (shared_preferences) for local persistence — no backend needed.
- Clean separation: models/ → services/ → providers/ → screens/ → widgets/

### Folder Structure
```
lib/
  core/
    constants/       # app-wide constants (colors, sizes, strings)
    extensions/      # Dart extensions
    utils/           # utility functions
    theme/           # Material 3 theme (light + dark)
  models/
    question.dart
    answer.dart
    session.dart
    progress.dart
    settings.dart
  services/
    question_generator.dart
    scoring_service.dart
    persistence_service.dart
  providers/
    settings_provider.dart
    progress_provider.dart
    session_provider.dart
    learn_provider.dart
  features/
    home/
    learn/
    practice/
    settings/
  app.dart
  main.dart
test/
  models/
  services/
  providers/
```

---

## 2. Dependencies

- flutter_riverpod: ^2.6.1
- go_router: ^14.x
- shared_preferences: ^2.3.x
- intl: ^0.19.x
- dev: flutter_lints, mocktail

---

## 3. Navigation

GoRouter routes:
- /                    → HomeScreen
- /learn               → LearnScreen
- /learn/tables        → TablesScreen
- /learn/squares-cubes → SquaresCubesScreen
- /learn/primes        → PrimesScreen
- /practice            → PracticeHomeScreen
- /practice/session    → PracticeSessionScreen
- /practice/results    → PracticeResultsScreen
- /settings            → SettingsScreen

Bottom NavigationBar (M3 NavigationBar): Home | Learn | Practice | Settings

---

## 4. Difficulty Levels

### Addition (6 levels)
1. 1-digit + 1-digit
2. Mixed 1-digit + 2-digit
3. 2-digit + 2-digit
4. 1-digit + 3-digit
5. 2-digit + 3-digit
6. 3-digit + 3-digit

### Subtraction (6 levels)
1. 1-digit − 1-digit (result ≥ 0)
2. 2-digit − 1-digit
3. 2-digit − 2-digit (result ≥ 0)
4. 3-digit − 1-digit
5. 3-digit − 2-digit
6. 3-digit − 3-digit (result ≥ 0)

### Multiplication (6 levels)
1. Tables 1–5 × 1–10
2. Tables 6–12 × 1–10
3. Tables 11–15 × 1–10
4. Tables 16–25 × 1–10
5. Prime × 1–10 (primes ≤ 100)
6. 2-digit × 1-digit (general)

### Division (6 levels)
1. Divide by 1–5 (quotient ≤ 10)
2. Divide by 1–10 (quotient ≤ 12)
3. Divide by 11–15 (quotient ≤ 10)
4. Divide by 16–25 (quotient ≤ 10)
5. 3-digit ÷ 1-digit (clean)
6. Divide by prime (clean)

---

## 5. Scoring

- +1 per correct
- Streak (consecutive correct)
- Accuracy % = correct/total × 100
- Grade: S ≥95%, A ≥85%, B ≥70%, C ≥55%, D <55%
- Avg response time (timed mode)

---

## 6. Persistence (SharedPreferences)

Keys:
- app.settings.questionCount
- app.settings.timedMode
- app.settings.timeLimitSeconds
- app.settings.feedbackMode
- app.settings.themeMode
- app.progress.sessions (JSON)
- app.progress.stats (JSON)

---

## 7. UI/UX

- Material 3, seed color Indigo (#3F51B5)
- Light + Dark theme
- Custom numeric keypad (no system keyboard)
- Responsive: phone/tablet/desktop breakpoints
- Animations: hero, fade, timer bar, answer flash
- Touch targets ≥ 48dp
- Empty/loading/error states

---

## Technical Decisions Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-09-17 | Riverpod for state management | Testable, null-safe, no BuildContext required in services |
| 2026-09-17 | GoRouter for navigation | Type-safe, declarative, deep-link ready |
| 2026-09-17 | SharedPreferences for persistence | Sufficient for settings+stats, no backend overhead |
| 2026-09-17 | Custom numeric keypad | Avoids system keyboard UX issues |
| 2026-09-17 | Feature-first folder structure | Scales better for multi-screen apps |
| 2026-09-17 | Integer-only answers for Division | Simplest mental-math focus |
| 2026-09-17 | Seed color Indigo | Professional, calm, good contrast |

---

## Task Checklist

### Phase 0 – Setup ✅
- [x] Inspect workspace
- [x] Check Flutter/Dart version
- [x] Write PLAN.md
- [x] flutter create mental_math
- [x] Add dependencies to pubspec.yaml
- [x] git init, initial commit
- [x] Create folder structure

### Phase 1 – Core Models & Question Generator 🔄
- [x] models/question.dart
- [x] models/session.dart
- [x] models/settings.dart
- [x] models/progress.dart
- [x] services/question_generator.dart
- [x] services/scoring_service.dart
- [x] Unit tests for generator
- [x] Unit tests for scoring

### Phase 2 – Persistence & Providers ⬜
- [x] services/persistence_service.dart
- [x] providers/settings_provider.dart
- [x] providers/progress_provider.dart
- [x] providers/session_provider.dart
- [x] providers/learn_provider.dart

### Phase 3 – Navigation & Shell ⬜
- [x] app.dart with GoRouter
- [x] main.dart with ProviderScope
- [x] Bottom NavigationBar shell
- [x] core/theme/app_theme.dart

### Phase 4 – Learn Section ⬜
- [x] LearnScreen tab host
- [x] TablesScreen (1–25 grid + detail)
- [x] SquaresCubesScreen
- [x] PrimesScreen
- [x] Learn quiz mode

### Phase 5 – Practice Section ⬜
- [x] PracticeHomeScreen (selector)
- [x] PracticeSessionScreen (question loop + keypad + timer)
- [x] PracticeResultsScreen
- [x] Custom numeric keypad widget
- [x] Timer bar widget
- [x] Answer feedback overlay

### Phase 6 – Home / Dashboard ⬜
- [x] HomeScreen hero cards
- [x] Recent session strip
- [x] Quick stats widgets

### Phase 7 – Settings ⬜
- [x] SettingsScreen
- [x] Theme toggle
- [x] Default question count / time limit

### Phase 8 – Polish ⬜
- [x] Animations
- [x] Responsive layout wrapper
- [x] Empty/loading/error states
- [x] Accessibility

### Phase 9 – QA ⬜
- [x] flutter analyze
- [x] flutter test
- [x] Fix all errors/warnings
- [x] Verify flutter build
- [x] Update PROGRESS.md

### Phase 10 – Final ⬜
- [x] Code review pass
- [x] Final git commit
- [x] Clean README.md

---

*Last updated: 2026-09-17 · Phase 0 complete, Phase 1 starting*

---

*Last updated: 2026-09-17 · ALL PHASES COMPLETE ✅ · flutter analyze: No issues · 52 tests passing · Build: ✅*
