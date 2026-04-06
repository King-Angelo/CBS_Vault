import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../services/bff_client.dart';
import '../services/bff_config.dart';
import '../widgets/app_snackbar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _urlController = TextEditingController();
  bool _loadingPrefs = true;
  bool _testing = false;

  @override
  void initState() {
    super.initState();
    _loadUrl();
  }

  Future<void> _loadUrl() async {
    final u = await BffConfig.getBaseUrl();
    if (mounted) {
      setState(() {
        _urlController.text = u ?? '';
        _loadingPrefs = false;
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _saveUrl() async {
    final raw = _urlController.text.trim();
    await BffConfig.setBaseUrl(raw.isEmpty ? null : raw);
    if (mounted) {
      showAppSnackBar(
        context,
        raw.isEmpty ? 'BFF URL cleared.' : 'BFF URL saved.',
      );
    }
  }

  Future<void> _testConnection() async {
    final base = await BffConfig.getBaseUrl();
    if (!mounted) return;
    if (base == null || base.isEmpty) {
      showAppSnackBar(context, 'Enter and save a base URL first.', isError: true);
      return;
    }
    setState(() => _testing = true);
    final client = BffClient(baseUrl: base);
    final result = await client.getHealth();
    if (!mounted) return;
    setState(() => _testing = false);
    if (result.ok) {
      showAppSnackBar(context, 'BFF reachable (GET /health OK).');
    } else {
      showAppSnackBar(context, 'BFF check failed: ${result.error}', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          if (_loadingPrefs)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BFF base URL',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Optional Dart Frog API (e.g. your Render URL). Firebase vault data is unchanged.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _urlController,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      hintText: 'https://your-service.onrender.com',
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      FilledButton(
                        onPressed: _saveUrl,
                        child: const Text('Save URL'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: _testing ? null : _testConnection,
                        child: _testing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Test connection'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
          ListTile(
            leading: const Icon(Icons.dns_outlined),
            title: const Text('Server / API (placeholder)'),
            subtitle: Text(
              'Legacy row — configure the BFF field above for real HTTP checks.',
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
