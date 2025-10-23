# heart-rate-app

A Flutter-based heart rate monitoring application with native Android integration (Kotlin/Java) and optional native C++ components. The app reads heart-rate data from device sensors or BLE heart-rate monitors and displays real-time metrics and historical trends.

## Features

- Real-time heart-rate display
- Login with google account and auto login on app restart
- Local storage of session data for trend analysis
- Lightweight data visualization (charts)
- Background/foreground handling for continuous monitoring
- Platform-specific native integrations for Android (Kotlin/Java, optional C++)

## Supported platforms & tech stack
- Mobile: Android (iOS support can be added similarly)
- Flutter / Dart (UI)
- Android (Kotlin / Java) for platform channels and permissions
- Optional native C++ (NDK) modules for performance-critical processing
- Build system: Gradle
- Package manager: pub (Dart packages)

## Prerequisites

- Flutter SDK (stable channel)
- Android Studio (recommended) with Android SDK
- For native C++: Android NDK (if using native modules)
- A physical Android device or emulator with BLE/sensor support
- (Optional) BLE heart-rate monitor for external device testing

## Quick start

1. Clone the repository
    - git clone <repository-url>
2. Enter project directory
    - cd heart-rate-app
3. Get Dart/Flutter dependencies
    - flutter pub get
4. Run on connected device or emulator
    - flutter run

## Android-specific setup

- Ensure `minSdkVersion` and `targetSdkVersion` in `android/app/build.gradle` meet the plugin requirements.
- Add required Android permissions to `android/app/src/main/AndroidManifest.xml`:
    - `android.permission.BLUETOOTH`
    - `android.permission.BLUETOOTH_ADMIN`
    - `android.permission.ACCESS_FINE_LOCATION` (if required for BLE scanning on some Android versions)
    - `android.permission.BODY_SENSORS` (for direct sensor access)
- Request runtime permissions from the app before accessing sensors or BLE.

If using native C++ modules, confirm the NDK path in `local.properties`:
- `ndk.dir=/path/to/android-ndk`

## Project structure (high level)

- `lib/` — Dart source (UI, state management, business logic)
- `android/` — Android platform code (Kotlin/Java, Gradle configs)
- `ios/` — iOS platform code (if present)
- `cpp/` or `android/src/main/cpp/` — optional C++ native code
- `test/` — Dart unit tests
- `integration_test/` — integration/e2e tests
- `pubspec.yaml` — Dart package & asset configuration

## Architecture overview

- Presentation: Flutter widgets and charts in `lib/ui`
- State: Provider / Bloc / Riverpod (project default) in `lib/state`
- Platform integration: Platform channels (method/event) implemented in `android/` for sensor/BLE access
- Data persistence: lightweight local storage (sqflite/shared_preferences/hive) in `lib/data`
- Optional C++ modules for signal processing exposed through JNI/FFI

## Usage notes

- When connecting to BLE devices, scan, pair, and subscribe to heart-rate characteristic (standard BLE HR profile UUIDs).
- Respect platform-specific battery and permission policies when performing background monitoring.

## Testing

- Run unit tests:
    - flutter test
- Run integration tests:
    - flutter drive --driver=test_driver/integration_driver.dart --target=integration_test/app_test.dart
- For Android instrumentation or native tests, use Android Studio / Gradle as required.

## CI / Build tips

- Cache `~/.pub-cache` and `~/.gradle` in CI to speed builds.
- Use `flutter build apk --release` for production APKs.
- Sign release builds by configuring `android/app/signingConfigs` in `build.gradle`.

## Contributing

- Follow the existing code style and lint rules (`analysis_options.yaml`).
- Write unit tests for new logic in `test/`.
- Open issues or PRs with clear descriptions and steps to reproduce.

## Troubleshooting

- If BLE scanning fails on Android 12+, ensure proper BLUETOOTH permissions and declare `BLUETOOTH_SCAN` / `BLUETOOTH_CONNECT` where required.
- If sensors return null or zero, verify device sensor availability and runtime permissions.

## License

- Add project license (e.g., `MIT`) in `LICENSE` and update this section.
