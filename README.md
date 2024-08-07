# velopack_flutter

[![pub package](https://img.shields.io/pub/v/velopack_flutter.svg)](https://pub.dartlang.org/packages/velopack_flutter)

A Flutter implementation of Velopack using flutter_rust_bridge for automated desktop app updates.

## Why Velopack?

Flutter currently lacks a robust solution for distributing auto-updates for desktop applications, aside from the Microsoft and Mac App Stores. Velopack addresses this gap by providing a cross-platform installation and auto-update framework for desktop applications.

Learn more about Velopack at [https://velopack.io/](https://velopack.io/)

This project leverages [flutter_rust_bridge](https://cjycode.com/flutter_rust_bridge/) to interface with the Rust implementation of Velopack.

## Getting Started

1. Add the velopack_flutter dependency to your `pubspec.yaml`:

```yaml
dependencies:
  velopack_flutter: ^0.0.1
```

2. Import the package, initialize the Rust library and handle Velopack app hooks in your `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:velopack_flutter/velopack_flutter.dart';

Future<void> main() async {
  await RustLib.init();
  
  final veloCommands = ['--veloapp-install', '--veloapp-updated', '--veloapp-obsolete', '--veloapp-uninstall'];
  if (veloCommands.any((cmd) => args.contains(cmd))) {
    exit(0);
  }
  
  runApp(const MyApp());
}
```

## API

| Function | Description                                                                                                                  |
|----------|------------------------------------------------------------------------------------------------------------------------------|
| `isUpdateAvailable(String url)` | Checks the specified URL for an update and returns a boolean.                                                                |
| `updateAndRestart(String url)` | Checks for an update, downloads and applies it, then restarts the app.                                                       |
| `updateAndExit(String url)` | Checks for an update, downloads and applies it, then exits the app.                                                          |
| `waitExitThenUpdate(String url)` | Checks for an update, downloads it, and applies it after the app has been closed. Will close automatically after 60 seconds. |

## Packaging

1. Install .NET Core SDK 6.0 and the `vpk` tool:

```shell
dotnet tool update -g vpk
```

2. Build your Flutter app:

```shell
flutter build [windows|macos|linux] --release
```

3. Navigate to your release build directory:

```shell
cd build/windows/x64/runner
```

4. Package your app using `vpk`:

```shell
vpk pack --packId YourAppId --packVersion 1.0.0 --packDir Release --mainExe YourApp.exe
```

Your release package will be generated in the `Releases` directory.

For more information on packaging and distribution, refer to:
- [Velopack Packaging Documentation](https://docs.velopack.io/category/packaging)
- [Velopack Distribution Documentation](https://docs.velopack.io/category/distributing)

## Notes

- The Linux implementation is currently untested. Contributions and feedback from Linux users are welcome.
- The API may differ from Velopack implementations in other languages and is not feature-complete. In the long-term it would make sense to keep these consistent, however I didn't have time for this yet. Feel free to open a PR!

## Contributing

If you encounter issues, have suggestions, or want to contribute code, please open an issue or submit a pull request on this GitHub repository.