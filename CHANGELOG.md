# Changelog

## 0.3.3

* Fixed the Rust build hook to skip builds when code assets are disabled

## 0.3.2

* Added top-level desktop platform metadata so pub.dev correctly lists Linux, macOS, and Windows support
* Removed desktop `ffiPlugin` declarations to avoid CocoaPods looking for unsupported platform folders during builds

## 0.3.1

* Fixed mobile app builds by skipping the Rust build hook on unsupported iOS and Android targets
* Declared desktop-only FFI plugin support for Linux, macOS, and Windows
* Added `code_assets` as a direct dependency for build hook platform detection

## 0.3.0

* Added release channel support: `initializeVelopack` now accepts an optional `channel` to override the update channel
* Added per-call `channel` and `allowDowngrade` overrides to `isUpdateAvailable`, `getLatestUpdateInfo`, `checkAndDownloadUpdatesWithProgress`, `updateAndRestart`, `updateAndExit`, and `waitExitThenUpdate` for checking or pulling from a different channel (including downgrades) without re-initializing
* Added `allowDowngrade` to `initializeVelopack` to permit migrating to an older version when switching channels
* Fixed potential panic in update download by propagating errors instead of `unwrap()`

## 0.2.0

* Upgrade Rust Velopack crate to 1.2.0
* Upgrade FRB to 2.12.0
* Added Dart types mirroring for UpdateInfo
* Initialize Velopack with URL just once after init
* Added Dart initializeVelopack helper for one-step setup
* Raised minimum Dart SDK to 3.6.0 for build hook support
* Added download progress stream sink to Flutter
* Used build hooks instead of CargoKit
* Better example UI

## 0.1.0

* Upgrade Rust bridge to 2.6.0
* Upgrade Velopack to 0.0.869

## 0.0.2

* Upgrade Rust bridge to 2.2.0 and fix error because of bridge version mismatch

## 0.0.1

* Initial release.
