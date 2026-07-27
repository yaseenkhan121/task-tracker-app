import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLogModel {
  final String activityId;
  final String userId;
  final String title;
  final String description;
  final String type; // 'task_create', 'status_update', 'profile_edit', 'login'
  final DateTime createdAt;

  ActivityLogModel({
    required this.activityId,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.createdAt,
  });

  factory ActivityLogModel.fromMap(Map<String, dynamic> data, String id) {
    return ActivityLogModel(
      activityId: id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? 'general',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory ActivityLogModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ActivityLogModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'activityId': activityId,
      'userId': userId,
      'title': title,
      'description': description,
      'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
