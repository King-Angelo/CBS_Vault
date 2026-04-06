import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_snackbar.dart';

/// Add (`entryId` null) or edit existing entry.
class EntryEditScreen extends StatefulWidget {
  const EntryEditScreen({super.key, this.entryId});

  /// Firestore document id; null when creating.
  final String? entryId;

  bool get isNew => entryId == null;

  @override
  State<EntryEditScreen> createState() => _EntryEditScreenState();
}

class _EntryEditScreenState extends State<EntryEditScreen> {
  final _siteController = TextEditingController();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _notesController = TextEditingController();
  bool _obscurePass = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Phase 3: load existing when !isNew
  }

  @override
  void dispose() {
    _siteController.dispose();
    _userController.dispose();
    _passController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _saving = false);
    showAppSnackBar(context, 'Save will persist to Firestore in Phase 3');
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isNew ? 'New entry' : 'Edit entry';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _siteController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Site / URL'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _userController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passController,
            obscureText: _obscurePass,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(_obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving ? null : () => context.pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
