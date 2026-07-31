import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_rust/native_toolchain_rust.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets) {
      return;
    }

    final targetOS = input.config.code.targetOS;

    if (targetOS == OS.iOS || targetOS == OS.android) {
      return;
    }

    await const RustBuilder(
      assetName: 'src/lib.rs',
      cratePath: 'rust',
    ).run(
      input: input,
      output: output,
    );
  });
}
