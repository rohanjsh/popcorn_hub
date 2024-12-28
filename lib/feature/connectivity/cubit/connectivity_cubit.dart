import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Represents the current state of network connectivity.
///
/// Two possible states:
/// * [connected] - Device has active network connection
/// * [disconnected] - Device has no network connection
enum ConnectivityStatus { connected, disconnected }

/// A cubit that manages and monitors the device's network connectivity state.
///
/// This cubit uses the connectivity_plus package to listen to network changes
/// and emits the current [ConnectivityStatus].
///
/// Example usage:
/// ```dart
/// final connectivityCubit = ConnectivityCubit();
///
/// // Listen to connectivity changes
/// connectivityCubit.stream.listen((status) {
///   if (status == ConnectivityStatus.connected) {
///     print('Device is connected to the network');
///   } else {
///     print('Device is offline');
///   }
/// });
///
/// // Check current connectivity
/// await connectivityCubit.checkConnectivity();
///
/// // Don't forget to close the cubit when no longer needed
/// connectivityCubit.close();
/// ```
class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  /// Creates a [ConnectivityCubit] instance and initializes connectivity monitoring.
  ///
  /// The constructor starts listening to connectivity changes immediately and
  /// performs an initial connectivity check.
  ConnectivityCubit() : super(ConnectivityStatus.connected) {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
    checkConnectivity();
  }

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  /// Checks the current connectivity status of the device.
  ///
  /// This method can be called manually to force a connectivity check.
  /// The result will be emitted as a new state.
  ///
  /// Example:
  /// ```dart
  /// await connectivityCubit.checkConnectivity();
  /// print(connectivityCubit.state); // Prints current connectivity status
  /// ```
  Future<void> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);
  }

  /// Updates the connectivity status based on the received connectivity results.
  ///
  /// [results] - List of [ConnectivityResult] from the connectivity_plus package.
  /// If the list is empty or contains only [ConnectivityResult.none],
  /// the state will be updated to [ConnectivityStatus.disconnected].
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.isEmpty ||
        results.every((result) => result == ConnectivityResult.none)) {
      emit(ConnectivityStatus.disconnected);
    } else {
      emit(ConnectivityStatus.connected);
    }
  }

  /// Closes the connectivity subscription and the cubit.
  ///
  /// This method should be called when the cubit is no longer needed
  /// to prevent memory leaks.
  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    return super.close();
  }
}
