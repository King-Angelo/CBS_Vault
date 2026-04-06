import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/entry_detail_screen.dart';
import '../screens/entry_edit_screen.dart';
import '../screens/login_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/vault_home_screen.dart';
import 'go_router_refresh.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final path = state.uri.path;
      if (path == '/splash') return null;
      if (user == null) {
        if (path == '/login') return null;
        return '/login';
      }
      if (path == '/login') return '/vault';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/vault',
        builder: (context, state) => const VaultHomeScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/entry/new',
        builder: (context, state) => const EntryEditScreen(),
      ),
      GoRoute(
        path: '/entry/:entryId/edit',
        builder: (context, state) {
          final id = state.pathParameters['entryId']!;
          return EntryEditScreen(entryId: id);
        },
      ),
      GoRoute(
        path: '/entry/:entryId',
        builder: (context, state) {
          final id = state.pathParameters['entryId']!;
          return EntryDetailScreen(entryId: id);
        },
      ),
    ],
  );
}
