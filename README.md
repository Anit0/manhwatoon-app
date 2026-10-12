# ManhwaToon

A premium native Flutter manga / manhwa reader.

## Open in Android Studio (Windows)

1. Install [Flutter](https://docs.flutter.dev/get-started/install/windows) and Android Studio with the Flutter and Dart plugins.
2. Confirm the SDK is on PATH:

```bash
flutter doctor
```

3. In Android Studio: **File > Open** and select this project folder (the folder that contains `pubspec.yaml`).
4. Wait for Android Studio to index, then open a terminal in the project root:

```bash
flutter pub get
```

5. Select a device or emulator, then run the app with the green Run button, or:

```bash
flutter run
```

## Build a release APK

From the project root:

```bash
flutter build apk --release
```

The APK is written to:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Testing the promotional timer

Edit `lib/core/constants/app_constants.dart` and change:

```dart
static const Duration adInterval = Duration(minutes: 10);
```

to:

```dart
static const Duration adInterval = Duration(seconds: 10);
```

Change it back to 10 minutes before shipping.
