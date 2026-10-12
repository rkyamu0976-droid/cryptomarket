class AppConfig {
  /// Android emulator  -> http://10.0.2.2:3000
  /// iOS simulator     -> http://localhost:3000
  /// Real phone        -> http://<your-PC-LAN-IP>:3000
  /// Override at run time:
  ///   flutter run --dart-define=API_BASE=http://192.168.1.5:3000
  static const String baseUrl =
      String.fromEnvironment('API_BASE', defaultValue: 'http://10.0.2.2:3000');
}
