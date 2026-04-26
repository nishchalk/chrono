# Time Tracker

A **Flutter** (Android-focused) **Material 3** app to log moments in time and see **live**, calendar-aware relative labels such as `2 years 3 months 5 days ago` or `in 4 days 6 hours`.

## Features

- **Entries**: title + date-time (past or future)
- **Live updates** every second via a clock stream
- **Local storage** with **sqflite**
- **CRUD**: add, edit (tap card), delete (with confirmation)
- **Sorting**: closest upcoming first, or most recent past first
- **Dark mode** follows system (`ThemeMode.system`)
- **Clean architecture**: `domain` → `data` → `presentation`, Riverpod for DI and state

## Project layout

```
lib/
  main.dart                 # ProviderScope + runApp
  app.dart                  # MaterialApp, themes
  core/
    theme/app_theme.dart
    utils/
      calendar_duration_parts.dart   # years…seconds between two instants
      relative_time_formatter.dart   # human phrases
    constants/database_constants.dart
  domain/
    entities/time_entry.dart
    repositories/time_entry_repository.dart
  data/
    models/time_entry_model.dart
    datasources/time_entry_local_data_source.dart
    repositories/time_entry_repository_impl.dart
  presentation/
    providers/…              # Riverpod: DB, repo, clock, sort, list notifier
    screens/home_screen.dart
    screens/entry_form_sheet.dart
    widgets/time_entry_card.dart
android/                    # Gradle + manifest (launcher icon uses a system drawable; replace for store)
test/widget_test.dart
```

## Requirements

- [Flutter](https://docs.flutter.dev/get-started/install) stable (Dart 3.5+)
- Android SDK / emulator or device for `flutter run`

## Run

```bash
cd /path/to/chrono
flutter pub get
flutter run
```

If native folders are out of date with your Flutter SDK, regenerate without clobbering `lib/`:

```bash
flutter create . --project-name time_tracker --org com.timetracker
```

Then run `flutter pub get` again.

## Tests

```bash
flutter test
```

## Notes

- The Android manifest uses `@android:drawable/ic_dialog_info` as a **placeholder launcher icon** so the project builds without generated mipmaps. For production, add adaptive launcher icons under `android/app/src/main/res/mipmap-*`.
- `local.properties` (with `flutter.sdk`) is created by Flutter tooling and should not be committed.
