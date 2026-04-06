import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../data/entries_repository.dart';
import '../models/vault_entry.dart';
import '../widgets/app_snackbar.dart';

class EntryDetailScreen extends StatefulWidget {
  const EntryDetailScreen({super.key, required this.entryId});

  final String entryId;

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  final _repo = EntriesRepository();
  bool _showPassword = false;

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await _repo.deleteEntry(widget.entryId);
      if (context.mounted) context.go('/vault');
    } catch (e) {
      if (context.mounted) {
        showAppSnackBar(context, 'Delete failed: $e', isError: true);
      }
    }
  }

  void _copy(BuildContext context, String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    showAppSnackBar(context, '$label copied');
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<VaultEntry?>(
      stream: _repo.watchEntry(widget.entryId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Entry')),
            body: Center(child: Text('${snapshot.error}')),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final entry = snapshot.data;
        if (entry == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Entry')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Entry not found'),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Back'),
                  ),
                ],
              ),
            ),
          );
        }
        if (uid == null || entry.ownerUid != uid) {
          return Scaffold(
            appBar: AppBar(title: const Text('Entry')),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('This entry belongs to another account.'),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(entry.displayTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/entry/${widget.entryId}/edit'),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context),
                tooltip: 'Delete',
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _FieldRow(
                label: 'Site / URL',
                value: entry.siteUrl.isEmpty ? '—' : entry.siteUrl,
              ),
              _FieldRow(
                label: 'Username',
                value: entry.username.isEmpty ? '—' : entry.username,
                onCopy: entry.username.isEmpty
                    ? null
                    : () => _copy(context, 'Username', entry.username),
              ),
              _FieldRow(
                label: 'Password',
                value: entry.secret.isEmpty ? '—' : entry.secret,
                obscure: entry.secret.isNotEmpty && !_showPassword,
                onCopy: entry.secret.isEmpty
                    ? null
                    : () => _copy(context, 'Password', entry.secret),
                trailing: entry.secret.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(
                          _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        ),
                        onPressed: () => setState(() => _showPassword = !_showPassword),
                        tooltip: _showPassword ? 'Hide' : 'Show',
                      ),
              ),
              _FieldRow(
                label: 'Notes',
                value: entry.notes.isEmpty ? '—' : entry.notes,
              ),
              const SizedBox(height: 8),
              Text(
                'Document id: ${widget.entryId}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.label,
    required this.value,
    this.obscure = false,
    this.onCopy,
    this.trailing,
  });

  final String label;
  final String value;
  final bool obscure;
  final VoidCallback? onCopy;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final display = obscure ? '••••••••' : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                ),
              ),
              trailing ?? const SizedBox.shrink(),
              if (onCopy != null)
                IconButton(
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy_outlined, size: 20),
                  tooltip: 'Copy',
                ),
            ],
          ),
          const SizedBox(height: 6),
          SelectableText(
            display,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
