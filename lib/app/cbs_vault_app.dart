import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../theme/app_theme.dart';

class CbsVaultApp extends StatefulWidget {
  const CbsVaultApp({super.key});

  @override
  State<CbsVaultApp> createState() => _CbsVaultAppState();
}

class _CbsVaultAppState extends State<CbsVaultApp> {
  late final GoRouter _router = createAppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CBS Vault',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      routerConfig: _router,
    );
  }
}
