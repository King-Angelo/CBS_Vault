import 'package:flutter/material.dart';

void showAppSnackBar(BuildContext context, String message, {bool isError = false}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? const Color(0xFF7F1D1D) : null,
    ),
  );
}

/// Clipboard copy feedback (Phase 4).
void showCopiedSnackBar(BuildContext context, String itemLabel) {
  showAppSnackBar(context, '$itemLabel copied to clipboard');
}
