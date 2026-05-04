# Scientific Calculator

A polished Flutter scientific calculator with a responsive Material 3 interface,
degree/radian angle modes, constants, exponent operations, and focused widget
tests for calculator behavior.

## Features

- Scientific operations: `sin`, `cos`, `tan`, `ln`, `log`, square root,
  reciprocal, percent, powers, and constants.
- Degree/radian mode switching for trigonometric calculations.
- Responsive calculator layout for mobile, web, and desktop Flutter targets.
- Automated widget tests covering core arithmetic and scientific functions.

## Tech Stack

- Flutter
- Dart
- Material 3
- `flutter_test`

## Project Structure

```text
lib/                 Application source code
test/                Widget tests
android/             Android Flutter platform project
ios/                 iOS Flutter platform project
web/                 Web app shell and icons
linux/ macos/ windows/ Desktop Flutter platform projects
.github/workflows/   GitHub Actions CI
```

## Getting Started

Install Flutter, then run:

```sh
flutter pub get
flutter run
```

Run the test suite:

```sh
flutter test
```
