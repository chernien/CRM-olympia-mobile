import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker _connectionChecker;

  NetworkInfoImpl(this._connectionChecker);

  @override
  Future<bool> get isConnected async {
    // internet_connection_checker relies on dart:io sockets and isn't supported
    // on web — the browser handles connectivity, and DioClient already surfaces
    // real connection errors with a friendly message.
    if (kIsWeb) return true;
    return _connectionChecker.hasConnection;
  }
}
