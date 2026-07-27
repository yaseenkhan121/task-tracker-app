import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String reportId;
  final String userId;
  final int completedTasks;
  final int pendingTasks;
  final int overdueTasks;
  final double completionRate;
  final DateTime generatedAt;

  ReportModel({
    required this.reportId,
    required this.userId,
    required this.completedTasks,
    required this.pendingTasks,
    required this.overdueTasks,
    required this.completionRate,
    required this.generatedAt,
  });

  factory ReportModel.fromMap(Map<String, dynamic> data, String id) {
    return ReportModel(
      reportId: id,
      userId: data['userId'] ?? '',
      completedTasks: (data['completedTasks'] as num?)?.toInt() ?? 0,
      pendingTasks: (data['pendingTasks'] as num?)?.toInt() ?? 0,
      overdueTasks: (data['overdueTasks'] as num?)?.toInt() ?? 0,
      completionRate: (data['completionRate'] as num?)?.toDouble() ?? 0.0,
      generatedAt: (data['generatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory ReportModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ReportModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'userId': userId,
      'completedTasks': completedTasks,
      'pendingTasks': pendingTasks,
      'overdueTasks': overdueTasks,
      'completionRate': completionRate,
      'generatedAt': Timestamp.fromDate(generatedAt),
    };
  }
}
