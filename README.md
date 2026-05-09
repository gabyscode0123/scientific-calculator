# Scientific Calculator

A cross-platform Flutter scientific calculator with a clean glass-style interface, responsive layout, and tested calculation behavior.

## Features

- Basic arithmetic: addition, subtraction, multiplication, and division
- Scientific functions: sine, cosine, tangent, natural log, base-10 log, square root, square, reciprocal, and powers
- Constants for pi and e
- Degree and radian angle modes
- Percent, sign toggle, delete, and all-clear controls
- Compact formatting for large and small results, including scientific notation
- Widget tests for core calculator behavior

## Project Structure

The app is organized into focused files for clarity and future scalability:

```text
lib/
  main.dart
  app.dart
  controllers/
    calculator_controller.dart
  models/
    angle_mode.dart
    calculator_button.dart
  screens/
    scientific_calculator_screen.dart
  widgets/
    calculator_button.dart
    calculator_display.dart
    calculator_header.dart
    calculator_keypad.dart
```

`main.dart` starts the app, `app.dart` configures the Flutter application shell, the controller owns calculator state and math logic, models define shared types, and widgets/screens contain the UI.

## Getting Started

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

Run tests:

```bash
flutter test
```
