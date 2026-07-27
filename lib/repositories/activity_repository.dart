import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intern_task_tracker/core/constants/firebase_constants.dart';
import 'package:intern_task_tracker/models/activity_log_model.dart';
import 'package:uuid/uuid.dart';

class ActivityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  /// Stream Recent Activity Logs
  Stream<List<ActivityLogModel>> getActivityLogsStream() {
    return _firestore
        .collection(FirebaseConstants.activityLogsCollection)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ActivityLogModel.fromDoc(doc)).toList());
  }

  /// Stream User Activity Logs
  Stream<List<ActivityLogModel>> getUserActivityLogsStream(String userId) {
    return _firestore
        .collection(FirebaseConstants.activityLogsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ActivityLogModel.fromDoc(doc)).toList());
  }

  /// Log Activity
  Future<void> logActivity({
    required String userId,
    required String title,
    required String description,
    required String type,
  }) async {
    final activityId = _uuid.v4();
    final log = ActivityLogModel(
      activityId: activityId,
      userId: userId,
      title: title,
      description: description,
      type: type,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(FirebaseConstants.activityLogsCollection)
        .doc(activityId)
        .set(log.toMap());
  }
}
