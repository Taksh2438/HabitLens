# HabitLens

HabitLens is a Flutter habit and metric tracker designed to make daily tracking simple and help users understand their progress over time.

## Features

- **Checkbox habits:** Mark daily habits as complete.
- **Number goals:** Track measurable goals such as pages read or kilometres walked.
- **Counters:** Record quantities using configurable increments, with optional daily goals.
- **Rating habits:** Record a daily rating.
- **Progress tracking:** View daily completion progress, streaks, and total completions.
- **Habit management:** Create, edit, and delete habits.
- **Local storage:** Save habit data on the device.
- **Theme preference:** Choose a light or dark appearance.

## Built With

- Flutter and Dart
- Provider for state management
- SharedPreferences for local persistence
- fl_chart for charts
- table_calendar for calendar features

## Getting Started

### Requirements

- Flutter SDK
- Dart SDK included with Flutter
- Android Studio or Visual Studio Code
- An Android device or emulator, or another supported Flutter platform

### Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/Taksh2438/HabitLens.git
   ```

2. Enter the project directory:

   ```bash
   cd HabitLens
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Run the app:

   ```bash
   flutter run
   ```

## Development Checks

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

## Data and Privacy

Habit data is stored locally using SharedPreferences. This project does not imply cloud synchronization or account-based backup.

## Project Status

HabitLens is under active development. Features and implementation details may change as the project evolves.

## License

No license has been specified yet. Check the repository for licensing updates before reusing or distributing this project.