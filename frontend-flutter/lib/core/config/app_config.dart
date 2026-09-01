/// Конфігурація застосунку з --dart-define та значеннями за замовчуванням.
class AppConfig {
  const AppConfig({required this.apiUrl});

  /// Базовий URL backend без trailing slash.
  final String apiUrl;

  static const String _apiUrlDefine = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8080',
  );

  factory AppConfig.fromEnvironment() {
    return AppConfig(apiUrl: _normalizeApiUrl(_apiUrlDefine));
  }

  String apiPath(String path) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return '$apiUrl$normalized';
  }

  String authPath(String path) {
    final suffix = path.startsWith('/') ? path : '/$path';
    return apiPath('/api/v1/auth$suffix');
  }

  static String _normalizeApiUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'http://localhost:8080';
    }
    return trimmed.replaceAll(RegExp(r'/+$'), '');
  }
}
