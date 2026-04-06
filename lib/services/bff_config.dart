import 'package:shared_preferences/shared_preferences.dart';

/// Persisted BFF base URL (e.g. `https://cbsvault-api.onrender.com`).
abstract final class BffConfig {
  static const String _key = 'bff_base_url';

  static Future<String?> getBaseUrl() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getString(_key);
    if (v == null || v.trim().isEmpty) return null;
    return v.trim().replaceAll(RegExp(r'/$'), '');
  }

  static Future<void> setBaseUrl(String? value) async {
    final p = await SharedPreferences.getInstance();
    if (value == null || value.trim().isEmpty) {
      await p.remove(_key);
    } else {
      await p.setString(_key, value.trim().replaceAll(RegExp(r'/$'), ''));
    }
  }
}
