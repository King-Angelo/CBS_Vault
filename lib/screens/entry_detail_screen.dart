import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_snackbar.dart';

class EntryDetailScreen extends StatelessWidget {
  const EntryDetailScreen({super.key, required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context) {
    // Phase 3: load document entries/$entryId from Firestore
    const site = '—';
    const username = '—';
    const password = '••••••••';
    const notes = '—';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/entry/$entryId/edit'),
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showAppSnackBar(context, 'Delete will be implemented in Phase 3');
            },
            tooltip: 'Delete',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _FieldRow(label: 'Site / URL', value: site),
          _FieldRow(label: 'Username', value: username, onCopy: () {
            showAppSnackBar(context, 'Copy username (Phase 3)');
          }),
          _FieldRow(
            label: 'Password',
            value: password,
            obscure: true,
            onCopy: () {
              showAppSnackBar(context, 'Copy password (Phase 3)');
            },
          ),
          _FieldRow(label: 'Notes', value: notes),
          const SizedBox(height: 8),
          Text(
            'Document id: $entryId',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                ),
          ),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.label,
    required this.value,
    this.obscure = false,
    this.onCopy,
  });

  final String label;
  final String value;
  final bool obscure;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
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
            obscure ? '••••••••' : value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
