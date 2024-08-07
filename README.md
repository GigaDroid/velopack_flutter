# velopack_flutter

A flutter implementation of Velopack using flutter_rust_bridge

## Why?

At the moment, Flutter has no proper way to distribute auto updates for desktop apps at the moment, apart from the Microsoft and Mac App Store.
Velopack is an installation and auto-update framework for cross-platform desktop application, which solves this problem.
Learn more about Velopack here: https://velopack.io/
This project uses [flutter_rust_bridge](https://cjycode.com/flutter_rust_bridge/) to call the rust implementation of Velopack.

## Getting Started

Add the velopack dependency to your pubspec.yaml

```yaml
  dependencies:
    velopack_flutter: ^0.0.1
```

Import the velopack packages and add call to ``await RustLib.init();`` in the main function for your app. Furthermore, add handling of specific velo startup commands.

```dart
import 'package:flutter/material.dart';
import 'package:velopack_flutter/velopack_flutter.dart';

Future<void> main() async {
  await RustLib.init();
  
  final veloCommands = ['--veloapp-install', '--veloapp-updated', '--veloapp-obsolete', '--veloapp-uninstall'];
  if (veloCommands.any(args.contains)) {
    exit(0);
  }
  
  runApp(const MyApp());
}
```

## Functions

``ìsUpdateAvailable(String url)``
Checks the specified url for an update and returns true or false but does nothing else.

``updateAndRestart(String url)``
Checks the specified url for an update, downloads and applies it, then restarts.

``updateAndExit(String url)``
Checks the specified url for an update, downloads and applies it, then exits.

``waitExitThenUpdate(String url)``
Checks the specified url for an update, downloads it and applies it after app has been closed.


## Packaging
First install .NET Core SDK 6.0 and ```vpk```

```shell
dotnet tool update -g vpk
```

Then build your flutter app:

```shell
flutter build [windows|macos|linux] --release
```

Go to the directory of your release build (this can differ based on your target)

```shell
cd build/windows/x64/runner
```

Then use ``vpk`` to package it:

```shell
vpk pack --packId SomeId --packVersion 1.0.0 --packDir Release --mainExe yourExe.exe
```

Your release package should now appear in the Releases directory. You can now distribute your package.
For more information regarding packaging and distributing see these links:
https://docs.velopack.io/category/packaging
https://docs.velopack.io/category/distributing


## Remarks
- The linux implementation has not been tested yet. It should theoretically work just fine but I don't have any device running linux. If you have a linux device and know this works fine, open an issue to let me know.
- The API differs from Velopack in other languages and is not feature-complete. In the long-term it would probably make sense to keep these consistent, however I didn't have time for this yet. Feel free to open a PR!