import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';

/// Lab-only status payload — not production-hardened (course storyline).
Response onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }
  return Response(
    body: jsonEncode({
      'api': 'cbsvault_api',
      'version': 1,
      'mode': 'lab',
      'hint':
          'Vault data still primarily uses Firebase from the mobile client.',
    }),
    headers: {'Content-Type': 'application/json'},
  );
}
