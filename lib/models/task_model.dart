import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus { pending, inProgress, review, completed, rejected }
enum TaskPriority { low, medium, high, critical }

class TaskModel {
  final String taskId;
  final String title;
  final String description;
  final String assignedBy;
  final String assignedTo;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime deadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> attachments;
  final int completionPercentage;

  TaskModel({
    required this.taskId,
    required this.title,
    required this.description,
    required this.assignedBy,
    required this.assignedTo,
    required this.priority,
    required this.status,
    required this.deadline,
    required this.createdAt,
    required this.updatedAt,
    required this.attachments,
    required this.completionPercentage,
  });

  factory TaskModel.fromMap(Map<String, dynamic> data, String id) {
    return TaskModel(
      taskId: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      assignedBy: data['assignedBy'] ?? '',
      assignedTo: data['assignedTo'] ?? '',
      priority: _priorityFromString(data['priority'] ?? 'medium'),
      status: _statusFromString(data['status'] ?? 'pending'),
      deadline: (data['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      attachments: List<String>.from(data['attachments'] ?? []),
      completionPercentage: (data['completionPercentage'] as num?)?.toInt() ?? 0,
    );
  }

  factory TaskModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TaskModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'title': title,
      'description': description,
      'assignedBy': assignedBy,
      'assignedTo': assignedTo,
      'priority': priority.name,
      'status': status.name,
      'deadline': Timestamp.fromDate(deadline),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'attachments': attachments,
      'completionPercentage': completionPercentage,
    };
  }

  static TaskStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'inprogress':
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'review':
        return TaskStatus.review;
      case 'completed':
        return TaskStatus.completed;
      case 'rejected':
        return TaskStatus.rejected;
      default:
        return TaskStatus.pending;
    }
  }

  static TaskPriority _priorityFromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return TaskPriority.low;
      case 'high':
        return TaskPriority.high;
      case 'critical':
        return TaskPriority.critical;
      default:
        return TaskPriority.medium;
    }
  }

  bool get isOverdue => DateTime.now().isAfter(deadline) && status != TaskStatus.completed;
}
