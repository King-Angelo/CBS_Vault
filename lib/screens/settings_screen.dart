import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../widgets/app_snackbar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.dns_outlined),
            title: const Text('Server / API base URL'),
            subtitle: Text(
              'https://api.example.cbsvault.demo (placeholder)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('Demo only — cybersecurity coursework. Not for production.'),
            onTap: () => showAppSnackBar(
              context,
              'CBS Vault — authorized lab demo only. Do not use real passwords.',
            ),
          ),
          const Divider(height: 1),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const ListTile(
                  leading: Icon(Icons.tag),
                  title: Text('Version'),
                  subtitle: Text('…'),
                );
              }
              final p = snap.data!;
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.apps_outlined),
                    title: const Text('App'),
                    subtitle: Text(p.appName),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.tag),
                    title: const Text('Version'),
                    subtitle: Text('${p.version} (${p.buildNumber})'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      kDebugMode ? Icons.bug_report_outlined : Icons.verified_outlined,
                    ),
                    title: const Text('Build'),
                    subtitle: Text(
                      kDebugMode
                          ? 'Debug — use release APK for demos & pentest report'
                          : 'Release',
                    ),
                  ),
                ],
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
            title: Text('Sign out', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onTap: () async {
              try {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) context.go('/login');
              } catch (e) {
                if (context.mounted) {
                  showAppSnackBar(context, 'Sign out failed: $e', isError: true);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
