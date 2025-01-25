# velopack_flutter

[![pub package](https://img.shields.io/pub/v/velopack_flutter.svg)](https://pub.dartlang.org/packages/velopack_flutter)

A Flutter implementation of Velopack using flutter_rust_bridge for automated desktop app updates.

## Why Velopack?

Flutter currently lacks a robust solution for distributing auto-updates for desktop applications, aside from the Microsoft and Mac App Stores. Velopack addresses this gap by providing a cross-platform installation and auto-update framework for desktop applications.

Learn more about Velopack at [https://velopack.io/](https://velopack.io/)

This project leverages [flutter_rust_bridge](https://cjycode.com/flutter_rust_bridge/) to interface with the Rust implementation of Velopack.

## Getting Started

1. Make sure rust is installed: <https://www.rust-lang.org/tools/install>
2. Add the velopack_flutter dependency to your `pubspec.yaml`:

```yaml
  dependencies:
    velopack_flutter: ^0.1.0
```

3. Import the package, initialize the Rust library and handle Velopack app hooks in your main.dart:

```dart
import 'package:flutter/material.dart';
import 'package:velopack_flutter/velopack_flutter.dart';

Future<void> main(List<String> args) async {
  await VelopackRustLib.init();

  final veloCommands = ['--veloapp-install', '--veloapp-updated', '--veloapp-obsolete', '--veloapp-uninstall'];
  if (veloCommands.any((cmd) => args.contains(cmd))) {
    exit(0);
  }

  /* You can now call the API functions shown in the API section. E.g isUpdateAvailable(url: ...);
     Do note that the API functions will only function correctly in a vpk packed release.
     isUpdateAvailable and the rest will just throw an exception if you call them while debugging.
  */
  runApp(const MyApp());
}
```

## Use with another rust library

If your project have already existing rust bindings. You'll certainly need to have a distinct library class name to prevent name conflicts.

This is what Velopack Flutter is doing by setting the following values in `flutter_rust_bridge.yaml` to make the class name "unique" and avoid conflicts.

```yaml
  dart_entrypoint_class_name: VelopackRustLib
```

**We recommend you to do the same on your own rust bindings.**

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

3. Navigate to your release build directory & package your app using `vpk`:

### Windows

```shell
cd build/windows/x64/runner
vpk pack --packId YourAppId --packVersion 1.0.0 --packDir Release --mainExe YourApp.exe
```

### MacOS

```shell
cd build/macos/Build/Products/Release
vpk pack -u "xyz.appName.companyName" -v 1.0.0 \
            -p "./YourApp.app" \
            --channel "osx-channelName" \
            --mainExe "Application Binary" \
            --noPortable --packTitle "Application Title" --signEntitlements "$(pwd)/macos/Runner/Release.entitlements" \
            --signAppIdentity "Developer ID Application: (Your Name)" \
            --signInstallIdentity "Developer ID Installer: (Your Name)" \
            --notaryProfile "notary-profile-name" \
```


Your release package will be generated in the `Releases` directory.

For more information on packaging and distribution, refer to:

- [Velopack Packaging Documentation](https://docs.velopack.io/category/packaging)
- [Velopack Distribution Documentation](https://docs.velopack.io/category/distributing)

## Using Github releases as your updates location

There is an issue (<https://github.com/velopack/velopack/issues/254>) in the velopack repo about adding full api support for github releases. In the meantime
you can still use github releases with a few workarounds:

### Download step (before packing the release)

Run the download command before packing to include the latest information from your github releases

```shell
vpk download github --repoUrl https://github.com/{orgOrUser}/{repoName}
```

Then pack as normal.

#### Uploading

```shell
vpk upload github --repoUrl https://github.com/{orgOrUser}/{repoName} --publish --releaseName YourDesiredReleaseName --tag v1.0.0 --token your_github_token
```

#### Using the API in your flutter app

velopack expects all the files to be available at the given url. One way to accomplish this with github releases is
to specify  `${repoUrl}releases/download/${tagName}/` as the url to isUpdateAvailable or any other api function.
This does require you to parse out the tag for the latest release manually yourself, e.g.:  

```dart
final url = Uri.parse('${repoUrl}releases/latest/');
final response = await http.get(url);
if (response.statusCode == 200) {
  final data = json.decode(response.body);
  final tag_name = data['tag_name']
}
```

## Notes

- The Linux implementation is currently untested. Contributions and feedback from Linux users are welcome.
- The API may differ from Velopack implementations in other languages and is not feature-complete. In the long-term it would make sense to keep these consistent, however I didn't have time for this yet. Feel free to open a PR!

## Contributing

If you encounter issues, have suggestions, or want to contribute code, please open an issue or submit a pull request on this GitHub repository.
