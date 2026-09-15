import 'package:cloud_firestore/cloud_firestore.dart';

/// Per-user profile document in Firestore `users/{uid}`.
class UserProfileRepository {
  UserProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const _collection = 'users';

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection(_collection).doc(uid);

  /// Returns the saved Cloudinary photo URL, or null if missing.
  Future<String?> getPhotoUrl(String uid) async {
    final snap = await _doc(uid).get();
    if (!snap.exists) return null;
    final data = snap.data();
    final url = data?['photoUrl']?.toString().trim();
    if (url == null || url.isEmpty) return null;
    return url;
  }

  /// Creates/updates the farmer profile with a Cloudinary image URL.
  Future<void> savePhotoUrl({
    required String uid,
    required String photoUrl,
    String? email,
    String? displayName,
  }) async {
    await _doc(uid).set(
      {
        'uid': uid,
        'photoUrl': photoUrl,
        if (email != null && email.isNotEmpty) 'email': email,
        if (displayName != null && displayName.isNotEmpty)
          'displayName': displayName,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Clears the saved profile photo URL for [uid].
  Future<void> clearPhotoUrl(String uid) async {
    await _doc(uid).set(
      {
        'uid': uid,
        'photoUrl': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
