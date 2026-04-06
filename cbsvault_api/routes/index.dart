import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';

/// Root — lab BFF metadata (intentionally verbose for coursework / pentest narrative).
Response onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }
  return Response(
    body: jsonEncode({
      'service': 'cbsvault_api',
      'description': 'Optional CBS Vault lab BFF (Dart Frog)',
      'docs': 'GET /health, GET /v1/status',
    }),
    headers: {'Content-Type': 'application/json'},
  );
}
