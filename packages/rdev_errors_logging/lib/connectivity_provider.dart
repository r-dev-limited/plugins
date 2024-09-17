import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final connectivityProvider = StreamProvider<ConnectivityResult>((ref) async* {
  yield ConnectivityResult.none;
  yield* Connectivity().onConnectivityChanged.map((results) =>
      results.isNotEmpty ? results.first : ConnectivityResult.none);
});

final connectivityResultProvider = Provider<ConnectivityResult>((ref) {
  return ref.watch(connectivityProvider).when(
        data: (result) => result,
        loading: () => ConnectivityResult.none,
        error: (_, __) => ConnectivityResult.none,
      );
});
