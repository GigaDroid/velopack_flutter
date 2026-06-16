import 'src/rust/api/velopack.dart' as velopack_api;
import 'src/rust/frb_generated.dart';

export 'src/rust/api/velopack.dart' hide initVelopack;
export 'src/rust/core/dart_types.dart';
export 'src/rust/frb_generated.dart' show VelopackRustLib;

Future<void> initializeVelopack({required String url}) async {
  await VelopackRustLib.init();
  await velopack_api.initVelopack(url: url);
}
