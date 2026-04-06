import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/entries_repository.dart';
import '../utils/input_validators.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _repo = EntriesRepository();
  final _siteController = TextEditingController();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _notesController = TextEditingController();
  bool _obscurePass = true;
  bool _saving = false;
  bool _loading = true;
  bool _forbidden = false;
  bool _notFound = false;

  @override
  void initState() {
    super.initState();
    if (widget.isNew) {
      _loading = false;
    } else {
      _loadEntry();
    }
  }

  Future<void> _loadEntry() async {
    setState(() {
      _loading = true;
      _forbidden = false;
      _notFound = false;
    });
    try {
      final e = await _repo.getEntry(widget.entryId!);
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (!mounted) return;
      if (e == null) {
        setState(() {
          _loading = false;
          _notFound = true;
        });
        return;
      }
      if (uid == null || e.ownerUid != uid) {
        setState(() {
          _loading = false;
          _forbidden = true;
        });
        return;
      }
      _siteController.text = e.siteUrl;
      _userController.text = e.username;
      _passController.text = e.secret;
      _notesController.text = e.notes;
      setState(() => _loading = false);
    } catch (err) {
      if (mounted) {
        setState(() => _loading = false);
        showAppSnackBar(context, 'Could not load entry: $err', isError: true);
      }
    }
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
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      showAppSnackBar(context, 'Not signed in.', isError: true);
      return;
    }

    final site = _siteController.text.trim();
    final user = _userController.text.trim();
    final pass = _passController.text;
    final notes = _notesController.text.trim();

    setState(() => _saving = true);
    try {
      if (widget.isNew) {
        await _repo.createEntry(
          siteUrl: site,
          username: user,
          secret: pass,
          notes: notes,
          ownerUid: uid,
        );
      } else {
        await _repo.updateEntry(
          entryId: widget.entryId!,
          siteUrl: site,
          username: user,
          secret: pass,
          notes: notes,
        );
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Save failed: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isNew ? 'New entry' : 'Edit entry';

    if (!widget.isNew && _forbidden) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('You cannot edit this entry.'),
          ),
        ),
      );
    }

    if (!widget.isNew && _notFound) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
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

    if (!widget.isNew && _loading) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _siteController,
              textInputAction: TextInputAction.next,
              validator: InputValidators.siteOrUrl,
              decoration: const InputDecoration(
                labelText: 'Site / URL',
                helperText: 'Site name or full URL',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _userController,
              textInputAction: TextInputAction.next,
              validator: (v) => InputValidators.optionalLength(v, 'Username', 256),
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passController,
              obscureText: _obscurePass,
              validator: (v) => InputValidators.optionalLength(v, 'Password', 4096),
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(_obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              validator: (v) => InputValidators.optionalLength(v, 'Notes', 4000),
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    onPressed: _saving ? null : () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
