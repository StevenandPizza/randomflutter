# randomflutter

A new Flutter project.

## Debug With Hot Reload

1. Start an Android emulator or connect a device with USB debugging enabled.
2. Open this project in VS Code.
3. Select `RandomFlutter (Hot Reload)` in Run and Debug, then press `F5`.
4. Save a Dart file to hot reload without reinstalling the APK.

Use `r` in the `flutter run` terminal for manual hot reload and `R` for hot restart.
Changes to native Android code, plugins, or `pubspec.yaml` require stopping and running again.

### Phone From The Terminal Without USB

On Android 11 or newer, enable `Developer options > Wireless debugging`. Keep the phone and PC on the same Wi-Fi network. Run this once from the project root:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\connect_phone_hot_reload.ps1
```

The script asks for the pairing address, pairing code, and Wireless debugging address shown on the phone. It then connects Flutter and starts hot reload automatically. Save a Dart file in `lib/` and the app updates on the phone without USB or APK reinstallation.

You can also connect manually:

```powershell
adb pair PHONE_IP:PAIRING_PORT PAIRING_CODE
adb connect PHONE_IP:DEBUG_PORT
powershell -ExecutionPolicy Bypass -File .\tools\run_phone_hot_reload.ps1 -DeviceId PHONE_IP:DEBUG_PORT
```

The first pairing requires entering the code displayed by Android; this cannot be bypassed for security.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
