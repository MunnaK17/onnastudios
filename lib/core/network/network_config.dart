import '../constants/api_endpoints.dart';

abstract final class NetworkConfig {
  static const baseUrl = String.fromEnvironment(
    'ONNA_API_BASE_URL',
    defaultValue: '',
  );

  static const connectTimeout = Duration(seconds: 20);
  static const receiveTimeout = Duration(seconds: 20);
  static const sendTimeout = Duration(seconds: 20);

  static Uri endpoint(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    if (baseUrl.isEmpty) {
      return Uri(path: normalizedPath);
    }

    return Uri.parse(baseUrl).replace(path: normalizedPath);
  }

  static Uri get apiBaseUri => endpoint(ApiEndpoints.basePath);
}
