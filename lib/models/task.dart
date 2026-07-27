import 'package:cloud_firestore/cloud_firestore.dart';

/// 🔹 Task Status Enum
enum TaskStatus { pending, inProgress, completed }

/// 🔹 Task Model
class Task {
  final String id; // Firestore document ID
  final String title;
  final String description;
  final DateTime deadline;
  final TaskStatus status;
  final int progress; // 0-100
  final String assignedTo; // userId of intern
  final DateTime? createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.status,
    required this.progress,
    required this.assignedTo,
    this.createdAt,
  });

  /// 🔹 Convert Firestore doc → Task
  factory Task.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      deadline: (data['deadline'] as Timestamp).toDate(),
      status: _statusFromString(data['status'] ?? 'pending'),
      progress: data['progress'] ?? 0,
      assignedTo: data['assignedTo'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// 🔹 Convert Task → Firestore data
  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "deadline": Timestamp.fromDate(deadline),
      "status": status.name,
      "progress": progress,
      "assignedTo": assignedTo,
      "createdAt": createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  /// 🔹 Helper: Convert String → Enum
  static TaskStatus _statusFromString(String status) {
    switch (status) {
      case "inProgress":
        return TaskStatus.inProgress;
      case "completed":
        return TaskStatus.completed;
      default:
        return TaskStatus.pending;
    }
  }
}

/// 🔹 Dummy data for UI testing
List<Task> getDummyTasks() {
  return [
    Task(
      id: "1",
      title: 'Complete User Research Analysis',
      description: 'Analyze user feedback and create a comprehensive report.',
      deadline: DateTime.now().add(const Duration(days: 5)),
      status: TaskStatus.inProgress,
      progress: 75,
      assignedTo: "intern_1",
      createdAt: DateTime.now(),
    ),
    Task(
      id: "2",
      title: 'Update Project Documentation',
      description: 'Review and update all project documentation files.',
      deadline: DateTime.now().add(const Duration(days: 10)),
      status: TaskStatus.pending,
      progress: 0,
      assignedTo: "intern_1",
      createdAt: DateTime.now(),
    ),
    Task(
      id: "3",
      title: 'Design Mobile App Wireframes',
      description: 'Create wireframes for new mobile application features.',
      deadline: DateTime.now().subtract(const Duration(days: 2)),
      status: TaskStatus.completed,
      progress: 100,
      assignedTo: "intern_2",
      createdAt: DateTime.now(),
    ),
    Task(
      id: "4",
      title: 'Prepare Weekly Status Report',
      description: 'Compile weekly progress report for team review.',
      deadline: DateTime.now().subtract(const Duration(days: 12)), // overdue
      status: TaskStatus.pending,
      progress: 10,
      assignedTo: "intern_3",
      createdAt: DateTime.now(),
    ),
  ];
}
