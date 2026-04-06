/// Shared validation for login and vault forms (Phase 4 polish).
abstract final class InputValidators {
  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}$');

  static String? email(String? value) {
    final s = value?.trim() ?? '';
    if (s.isEmpty) {
      return 'Enter an email address.';
    }
    if (!_email.hasMatch(s)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? passwordSignIn(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your password.';
    }
    return null;
  }

  static String? passwordRegister(String? value) {
    if (value == null || value.isEmpty) {
      return 'Choose a password.';
    }
    if (value.length < 6) {
      return 'Use at least 6 characters.';
    }
    return null;
  }

  /// Site label or URL — required for vault entries.
  static String? siteOrUrl(String? value, {int maxLen = 512}) {
    final s = value?.trim() ?? '';
    if (s.isEmpty) {
      return 'Site / URL is required.';
    }
    if (s.length > maxLen) {
      return 'Use at most $maxLen characters.';
    }
    return null;
  }

  static String? optionalLength(String? value, String fieldLabel, int maxLen) {
    final s = value?.trim() ?? '';
    if (s.length > maxLen) {
      return '$fieldLabel must be at most $maxLen characters.';
    }
    return null;
  }
}
