# legged_robot_app

Cross‑platform Flutter app for **robot control & visualization**. Features a URDF 3D viewer, joint control panel, posture capture, and responsive layouts for mobile, tablet, desktop, and web.

---

## Getting Started

```bash
git clone <repo-url>
cd legged_robot_app
flutter pub get
flutter run   # select device: emulator/simulator/Chrome/Windows/…
```

---

## Configuration

### Orientation Lock

Landscape‑first. Configure per platform:

**Android – `android/app/src/main/AndroidManifest.xml`**

```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    android:screenOrientation="sensorLandscape"
    android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode" />
```

**iOS / iPadOS – `ios/Runner/Info.plist`**

```xml
<key>UISupportedInterfaceOrientations</key>
<array>
  <string>UIInterfaceOrientationLandscapeLeft</string>
  <string>UIInterfaceOrientationLandscapeRight</string>
</array>
<key>UISupportedInterfaceOrientations~ipad</key>
<array>
  <string>UIInterfaceOrientationLandscapeLeft</string>
  <string>UIInterfaceOrientationLandscapeRight</string>
</array>
<key>UIRequiresFullScreen</key>
<true/>
```

**Dart (before `runApp`)**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}
```
---

## Running

```bash
flutter run                 # auto-picks a device
flutter run -d chrome       # run on web (Chrome)
flutter run -d windows      # run on Windows desktop
flutter run -d macos        # run on macOS desktop
flutter run -d linux        # run on Linux desktop
```

---

## Build Commands

> Use `--release` for production. Add `--no-tree-shake-icons` if you bundle many icons.

### Android

```bash
# Universal APK (install directly)
flutter build apk --release --no-tree-shake-icons

# Play Store (recommended): AAB
flutter build appbundle --release --no-tree-shake-icons

# Split by ABI (smaller APKs)
flutter build apk --release --split-per-abi --no-tree-shake-icons
```

Artifacts:

- `build/app/outputs/flutter-apk/app-release.apk`
- `build/app/outputs/bundle/release/app-release.aab`

### iOS / iPadOS

```bash
# Produce IPA for TestFlight / App Store (requires signing set in Xcode)
flutter build ipa --release
```

Or open Xcode → **Archive** → **Distribute**.

### Web

```bash
flutter build web --profile
# Output: build/web/ (deploy to static hosting)
```

### Windows

```bash
flutter build windows --release
# Output: build/windows/runner/Release/
```

### macOS

```bash
flutter build macos --release
# Output: build/macos/Build/Products/Release/
```

### Linux

```bash
flutter build linux --release
# Output: build/linux/x64/release/bundle/
```

