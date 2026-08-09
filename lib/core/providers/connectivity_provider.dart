import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the device currently has any usable network connectivity.
///
/// Yields `true` while online and `false` while offline. Screens use this for
/// a consistent "you're offline" banner instead of per-screen generic errors.
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();

  List<ConnectivityResult> current;
  try {
    current = await connectivity.checkConnectivity();
  } catch (_) {
    current = [ConnectivityResult.none];
  }
  yield current.any((r) => r != ConnectivityResult.none);

  await for (final results in connectivity.onConnectivityChanged) {
    yield results.any((r) => r != ConnectivityResult.none);
  }
});
