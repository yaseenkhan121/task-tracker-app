import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intern_task_tracker/core/constants/firebase_constants.dart';
import 'package:intern_task_tracker/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// Sign In with Email & Password
  Future<UserModel> signIn({required String email, required String password}) async {
    final UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    if (credential.user == null) {
      throw Exception('Authentication failed. User is null.');
    }

    final DocumentSnapshot doc = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(credential.user!.uid)
        .get();

    if (!doc.exists) {
      throw Exception('User profile not found in database.');
    }

    return UserModel.fromDoc(doc);
  }

  /// Register New User Profile in Firebase Auth & Firestore
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String department,
    required String university,
    required String role,
  }) async {
    final UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    if (credential.user == null) {
      throw Exception('Registration failed.');
    }

    final userModel = UserModel(
      uid: credential.user!.uid,
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      department: department.trim(),
      university: university.trim(),
      profileImage: '',
      role: role,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userModel.uid)
        .set(userModel.toMap());

    return userModel;
  }

  /// Reset Password Link
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Fetch User Profile by UID
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .get();

    if (!doc.exists) return null;
    return UserModel.fromDoc(doc);
  }

  /// Stream User Profile
  Stream<UserModel?> streamUserProfile(String uid) {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromDoc(doc) : null);
  }

  /// Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
