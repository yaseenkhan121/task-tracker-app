import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intern_task_tracker/core/constants/firebase_constants.dart';
import 'package:intern_task_tracker/models/task_model.dart';
import 'package:uuid/uuid.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  /// Stream All Tasks (Realtime Stream)
  Stream<List<TaskModel>> getTasksStream() {
    return _firestore
        .collection(FirebaseConstants.tasksCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromDoc(doc)).toList());
  }

  /// Stream Tasks Assigned to Specific Intern
  Stream<List<TaskModel>> getInternTasksStream(String internUid) {
    return _firestore
        .collection(FirebaseConstants.tasksCollection)
        .where('assignedTo', isEqualTo: internUid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromDoc(doc)).toList());
  }

  /// Create New Task
  Future<void> createTask(TaskModel task) async {
    await _firestore
        .collection(FirebaseConstants.tasksCollection)
        .doc(task.taskId)
        .set(task.toMap());
  }

  /// Update Task
  Future<void> updateTask(TaskModel task) async {
    await _firestore
        .collection(FirebaseConstants.tasksCollection)
        .doc(task.taskId)
        .update(task.toMap());
  }

  /// Update Task Status & Completion Percentage
  Future<void> updateTaskStatus({
    required String taskId,
    required TaskStatus status,
    required int progress,
  }) async {
    await _firestore
        .collection(FirebaseConstants.tasksCollection)
        .doc(taskId)
        .update({
      'status': status.name,
      'completionPercentage': progress,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Delete Task
  Future<void> deleteTask(String taskId) async {
    await _firestore
        .collection(FirebaseConstants.tasksCollection)
        .doc(taskId)
        .delete();
  }

  /// Upload Attachment File to Firebase Storage
  Future<String> uploadAttachment(String taskId, File file, String fileName) async {
    final ref = _storage
        .ref()
        .child('${FirebaseConstants.taskAttachmentsFolder}/$taskId/${_uuid.v4()}_$fileName');

    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }
}
