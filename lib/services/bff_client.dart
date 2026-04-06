import 'package:http/http.dart' as http;

/// Minimal HTTP client for the optional Dart Frog BFF (Phase 5).
class BffClient {
  BffClient({required this.baseUrl});

  final String baseUrl;

  Uri _uri(String path) {
    final root = baseUrl.replaceAll(RegExp(r'/$'), '');
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$root$p');
  }

  /// GET /health — used from Settings to verify connectivity.
  Future<BffHealthResult> getHealth() async {
    try {
      final response = await http
          .get(
            _uri('/health'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return BffHealthResult.ok(body: response.body);
      }
      return BffHealthResult.fail('HTTP ${response.statusCode}');
    } catch (e) {
      return BffHealthResult.fail('$e');
    }
  }
}

class BffHealthResult {
  BffHealthResult.ok({required this.body}) : ok = true, error = null;
  BffHealthResult.fail(this.error) : ok = false, body = null;

  final bool ok;
  final String? body;
  final String? error;
}
