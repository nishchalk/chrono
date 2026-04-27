# Chrono

Chrono is a Flutter Android app to track important moments in time and show live relative labels such as `2 years 3 months 5 days ago` or `in 4 days 6 hours`.

## Download APK

- Build and package the installable APK as `crono.apk`:

```bash
cd /path/to/chrono
flutter pub get
flutter build apk --release
cp build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/crono.apk
```

- Final APK path:
  - `build/app/outputs/flutter-apk/crono.apk`

You can share that `crono.apk` file directly for manual Android installation.

## Features

- Create time entries with title, date-time, category, and custom color
- Live relative time with calendar-aware breakdown (`years`, `months`, `days`, `hours`)
- Past/future visual cues and dense list cards for high-information view
- Sort entries by closest upcoming or most recent past
- Filter entries by category from app-bar dropdown
- Add, edit, and delete entries with confirmation
- Dark mode support (`ThemeMode.system`)
- Clock-based app logo in app bar and Android launcher icon

## Functionality

- **Entry management**
  - Add entry via FAB
  - Edit existing entry from the list
  - Delete with confirmation dialog
- **Time engine**
  - Computes relative time using calendar-aware utilities
  - Updates labels periodically for live display
- **Organization**
  - Category-based filtering
  - Sort controls for timeline browsing
- **Persistence**
  - Stores entries locally in SQLite (`sqflite`)
  - Handles schema migrations for new fields
  - Uses Android backup rules to improve restore behavior where supported

## Basic Architecture

The app follows a clean layered architecture:

- **Presentation layer** (`lib/presentation`)
  - Screens, widgets, and Riverpod providers
  - Handles UI state, filtering, sorting, and interactions
- **Domain layer** (`lib/domain`)
  - Core entities and repository contracts
  - Framework-independent business model definitions
- **Data layer** (`lib/data`)
  - SQLite datasource and repository implementation
  - Maps between database rows and domain entities
- **Core utilities** (`lib/core`)
  - Theme, constants, and relative-time calculation/formatting utilities

## Project Structure

```text
lib/
  main.dart
  app.dart
  core/
    constants/
    theme/
    utils/
  domain/
    entities/
    repositories/
  data/
    datasources/
    models/
    repositories/
  presentation/
    providers/
    screens/
    widgets/
android/
test/
assets/
```

## Requirements

- [Flutter](https://docs.flutter.dev/get-started/install) stable (Dart 3.5+)
- Android SDK + device/emulator

## Run Locally

```bash
cd /path/to/chrono
flutter pub get
flutter run
```

## Test

```bash
flutter test
```

## Notes

- `local.properties` (contains `flutter.sdk`) is machine-specific and should not be committed.
