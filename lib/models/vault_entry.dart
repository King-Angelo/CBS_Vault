import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore document in `entries` — maps to coursework pentest story (lab only).
class VaultEntry {
  VaultEntry({
    required this.id,
    required this.siteUrl,
    required this.username,
    required this.secret,
    required this.notes,
    required this.createdAt,
    required this.ownerUid,
  });

  final String id;
  final String siteUrl;
  final String username;
  final String secret;
  final String notes;
  final DateTime createdAt;
  final String ownerUid;

  String get displayTitle => siteUrl.trim().isNotEmpty ? siteUrl.trim() : 'Untitled';

  /// Short mask for list rows (not cryptographic).
  String get maskedUsername {
    if (username.isEmpty) return '—';
    if (username.length <= 2) return '••';
    return '${username.substring(0, 2)}•••';
  }

  factory VaultEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final ts = d['createdAt'];
    DateTime created;
    if (ts is Timestamp) {
      created = ts.toDate();
    } else {
      created = DateTime.fromMillisecondsSinceEpoch(0);
    }
    return VaultEntry(
      id: doc.id,
      siteUrl: (d['siteUrl'] as String?) ?? '',
      username: (d['username'] as String?) ?? '',
      secret: (d['secret'] as String?) ?? '',
      notes: (d['notes'] as String?) ?? '',
      createdAt: created,
      ownerUid: (d['ownerUid'] as String?) ?? '',
    );
  }
}
