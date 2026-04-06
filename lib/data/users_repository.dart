import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firestore `Users` collection — one document per Auth user (`docId` = `uid`).
class UsersRepository {
  UsersRepository({FirebaseFirestore? firestore}) : _override = firestore;

  final FirebaseFirestore? _override;

  FirebaseFirestore get _db => _override ?? FirebaseFirestore.instance;

  static const String collectionName = 'Users';

  /// Creates `Users/{uid}` on first sign-in, or updates email / activity on return visits.
  Future<void> syncUserDocument(User user) async {
    final ref = _db.collection(collectionName).doc(user.uid);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final email = user.email ?? '';
      final displayName = user.displayName;
      final updatedAt = FieldValue.serverTimestamp();
      final lastLoginAt = FieldValue.serverTimestamp();

      if (!snap.exists) {
        tx.set(ref, {
          'email': email,
          'displayName': displayName,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': updatedAt,
          'lastLoginAt': lastLoginAt,
        });
      } else {
        final updates = <String, dynamic>{
          'email': email,
          'updatedAt': updatedAt,
          'lastLoginAt': lastLoginAt,
        };
        if (displayName != null) {
          updates['displayName'] = displayName;
        }
        tx.update(ref, updates);
      }
    });
  }
}
