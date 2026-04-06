import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cbsvault/screens/login_screen.dart';
import 'package:cbsvault/theme/app_theme.dart';

void main() {
  testWidgets('Login screen shows Sign in and Google', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const LoginScreen(),
      ),
    );
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
