import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';

/// Health check for Render / probes and Flutter “Test connection”.
Response onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }
  return Response(
    body: jsonEncode({
      'status': 'ok',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    }),
    headers: {'Content-Type': 'application/json'},
  );
}
