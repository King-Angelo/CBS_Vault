import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/entries_repository.dart';
import '../models/vault_entry.dart';

class VaultHomeScreen extends StatefulWidget {
  const VaultHomeScreen({super.key});

  @override
  State<VaultHomeScreen> createState() => _VaultHomeScreenState();
}

class _VaultHomeScreenState extends State<VaultHomeScreen> {
  final _searchController = TextEditingController();
  final _repo = EntriesRepository();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CBS Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search entries',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: uid == null
                ? const Center(child: Text('Not signed in'))
                : StreamBuilder<List<VaultEntry>>(
                    stream: _repo.watchEntriesForUser(uid),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Could not load entries.\n${snapshot.error}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final all = snapshot.data!;
                      final q = _searchController.text.trim().toLowerCase();
                      final filtered = q.isEmpty
                          ? all
                          : all
                              .where(
                                (e) =>
                                    e.siteUrl.toLowerCase().contains(q) ||
                                    e.username.toLowerCase().contains(q) ||
                                    e.notes.toLowerCase().contains(q),
                              )
                              .toList();

                      if (all.isEmpty) {
                        return _emptyNoEntries(context);
                      }
                      if (filtered.isEmpty) {
                        return Center(
                          child: Text(
                            'No matches for “$q”.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final e = filtered[i];
                          return ListTile(
                            title: Text(e.displayTitle),
                            subtitle: Text(e.maskedUsername),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.push('/entry/${e.id}'),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/entry/new'),
        tooltip: 'Add entry',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _emptyNoEntries(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(
              children: [
                Icon(
                  Icons.folder_open_outlined,
                  size: 56,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
                ),
                const SizedBox(height: 16),
                Text(
                  'No entries yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first credential with the + button.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
