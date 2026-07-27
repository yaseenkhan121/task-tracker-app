import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intern_task_tracker/core/constants/firebase_constants.dart';
import 'package:intern_task_tracker/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream All Users
  Stream<List<UserModel>> getAllUsersStream() {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromDoc(doc)).toList());
  }

  /// Stream Interns Only (Case-insensitive robust filtering)
  Stream<List<UserModel>> getInternsStream() {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromDoc(doc))
            .where((u) => u.role.toLowerCase() != 'admin')
            .toList());
  }

  /// Fetch User Profile by ID
  Future<UserModel?> getUserById(String uid) async {
    final doc = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .get();

    if (!doc.exists) return null;
    return UserModel.fromDoc(doc);
  }

  /// Update User Profile
  Future<void> updateUserProfile(UserModel user) async {
    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(user.uid)
        .update(user.toMap());
  }
}
