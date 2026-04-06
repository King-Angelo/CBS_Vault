import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/vault_entry.dart';

/// CRUD for `entries` — scoped by [ownerUid] in queries (rules remain permissive for lab).
class EntriesRepository {
  EntriesRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _entries =>
      _db.collection('entries');

  Stream<List<VaultEntry>> watchEntriesForUser(String ownerUid) {
    return _entries
        .where('ownerUid', isEqualTo: ownerUid)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(VaultEntry.fromDoc).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<VaultEntry?> watchEntry(String entryId) {
    return _entries.doc(entryId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return VaultEntry.fromDoc(doc);
    });
  }

  Future<VaultEntry?> getEntry(String entryId) async {
    final doc = await _entries.doc(entryId).get();
    if (!doc.exists) return null;
    return VaultEntry.fromDoc(doc);
  }

  Future<String> createEntry({
    required String siteUrl,
    required String username,
    required String secret,
    required String notes,
    required String ownerUid,
  }) async {
    final ref = _entries.doc();
    await ref.set({
      'siteUrl': siteUrl.trim(),
      'username': username.trim(),
      'secret': secret,
      'notes': notes.trim(),
      'ownerUid': ownerUid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> updateEntry({
    required String entryId,
    required String siteUrl,
    required String username,
    required String secret,
    required String notes,
  }) async {
    await _entries.doc(entryId).update({
      'siteUrl': siteUrl.trim(),
      'username': username.trim(),
      'secret': secret,
      'notes': notes.trim(),
    });
  }

  Future<void> deleteEntry(String entryId) => _entries.doc(entryId).delete();
}
