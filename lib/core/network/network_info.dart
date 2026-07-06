abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl();

  @override
  Future<bool> get isConnected async {
    // We do NOT pre-flight connectivity by pinging public DNS hosts: during USB
    // debugging the phone reaches the backend through an `adb reverse` tunnel
    // (localhost:5000 → PC), and often has no WiFi/mobile data at all — a public
    // ping would falsely report "offline" and block every request even though
    // the backend is reachable. Real connection failures are surfaced by
    // DioClient with a friendly message ("Erreur de connexion au serveur").
    return true;
  }
}
