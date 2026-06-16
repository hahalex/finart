# FinArt

FinArt is a Flutter finance tracker for transactions, categories, analytics,
planned payments, notifications, JSON backup/restore, and demo data generation.

## Requirements

- Flutter SDK 3.10 or newer
- Dart SDK bundled with Flutter
- Android SDK, API 21+
- Android Studio or VS Code with Flutter tooling
- Android emulator or a physical Android device with USB debugging enabled

## Development

Install dependencies:

```bash
flutter pub get
```

Generate Drift database code after schema changes:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Run the app:

```bash
flutter run
```

Run static checks and tests:

```bash
dart format .
flutter analyze
flutter test --coverage
```

## Demo Checklist

Before a public demo, verify these critical paths:

- Create, edit, complete, and delete an upcoming payment.
- Switch upcoming payment filters: All, Active, Done.
- Create expense and income transactions with Russian and English locales.
- Open charts and reports with an empty database and with demo data.
- Import and export JSON v2 backup files.
- Toggle notification settings and confirm planned payment notifications resync.
- Open Dev Menu and seed small, large, skewed, planned, and mixed data sets.

## CI

GitHub Actions runs formatting, analysis, and tests with coverage on pushes to
`main`, `master`, `codex/**`, and on pull requests. The project target is at
least 70% code coverage for critical business logic and widget flows.

## Release Build

Universal APK:

```bash
flutter build apk --no-tree-shake-icons
```

Smaller APKs split by ABI:

```bash
flutter build apk --split-per-abi --no-tree-shake-icons
```

Output files are created in:

```text
build/app/outputs/flutter-apk/
```

The `--no-tree-shake-icons` flag is currently required because the app creates
some `IconData` values dynamically for user categories.

## Data And Backups

The app stores data locally in Drift over SQLite. JSON v2 exports include
metadata, checksums, and relation validation for categories, transactions,
planned payments, and the AI learning dictionary. Import routines should fail
without partially applying broken data.

Sensitive files such as real API keys, keystores, and signing configs must stay
outside the repository.

## Troubleshooting

Accept Android licenses:

```bash
flutter doctor --android-licenses
```

Rebuild generated files:

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

Check connected devices:

```bash
adb devices
```
