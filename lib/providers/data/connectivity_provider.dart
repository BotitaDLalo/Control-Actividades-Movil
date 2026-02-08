import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider that exposes the raw connectivity result stream
final connectivityStreamProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

// Provider that exposes a boolean representing the internet connection status
final connectivityStatusProvider = Provider<bool>((ref) {
  final connectivityResult = ref.watch(connectivityStreamProvider);

  // The connection status is true if the stream has data and the result is not none.
  return connectivityResult.when(
    data: (result) {
      return !result.contains(ConnectivityResult.none);
    },
    loading: () => true, // Assume connection is available while loading initially.
    error: (_, __) => false, // Assume no connection on error.
  );
});
