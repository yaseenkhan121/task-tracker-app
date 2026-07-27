import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intern_task_tracker/models/task_model.dart';
import 'package:intern_task_tracker/repositories/task_repository.dart';
import 'package:uuid/uuid.dart';

class TaskProvider with ChangeNotifier {
  final TaskRepository _taskRepository = TaskRepository();
  final Uuid _uuid = const Uuid();

  String _searchQuery = '';
  TaskStatus? _selectedStatusFilter;
  TaskPriority? _selectedPriorityFilter;
  bool _isLoading = false;

  String get searchQuery => _searchQuery;
  TaskStatus? get selectedStatusFilter => _selectedStatusFilter;
  TaskPriority? get selectedPriorityFilter => _selectedPriorityFilter;
  bool get isLoading => _isLoading;

  /// Stream All Tasks (For Admin)
  Stream<List<TaskModel>> get allTasksStream => _taskRepository.getTasksStream();

  /// Stream Tasks Assigned to Specific Intern
  Stream<List<TaskModel>> internTasksStream(String internUid) =>
      _taskRepository.getInternTasksStream(internUid);

  /// Set Search Query for Realtime Filtering
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase().trim();
    notifyListeners();
  }

  /// Set Status Filter
  void setStatusFilter(TaskStatus? status) {
    _selectedStatusFilter = status;
    notifyListeners();
  }

  /// Set Priority Filter
  void setPriorityFilter(TaskPriority? priority) {
    _selectedPriorityFilter = priority;
    notifyListeners();
  }

  /// Clear All Filters
  void clearFilters() {
    _searchQuery = '';
    _selectedStatusFilter = null;
    _selectedPriorityFilter = null;
    notifyListeners();
  }

  /// Filter Task List Helper
  List<TaskModel> filterTasks(List<TaskModel> tasks) {
    return tasks.where((task) {
      final matchesSearch = _searchQuery.isEmpty ||
          task.title.toLowerCase().contains(_searchQuery) ||
          task.description.toLowerCase().contains(_searchQuery);

      final matchesStatus = _selectedStatusFilter == null ||
          task.status == _selectedStatusFilter;

      final matchesPriority = _selectedPriorityFilter == null ||
          task.priority == _selectedPriorityFilter;

      return matchesSearch && matchesStatus && matchesPriority;
    }).toList();
  }

  /// Create New Task (Admin)
  Future<bool> createTask({
    required String title,
    required String description,
    required String assignedBy,
    required String assignedTo,
    required TaskPriority priority,
    required DateTime deadline,
  }) async {
    _setLoading(true);
    try {
      final newTask = TaskModel(
        taskId: _uuid.v4(),
        title: title.trim(),
        description: description.trim(),
        assignedBy: assignedBy,
        assignedTo: assignedTo,
        priority: priority,
        status: TaskStatus.pending,
        deadline: deadline,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        attachments: [],
        completionPercentage: 0,
      );

      await _taskRepository.createTask(newTask);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  /// Update Task Status (Intern)
  Future<bool> updateTaskStatus({
    required String taskId,
    required TaskStatus newStatus,
    required int progress,
  }) async {
    _setLoading(true);
    try {
      await _taskRepository.updateTaskStatus(
        taskId: taskId,
        status: newStatus,
        progress: progress,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  /// Upload Task Attachment (Intern)
  Future<bool> uploadAttachment({
    required TaskModel task,
    required File file,
    required String fileName,
  }) async {
    _setLoading(true);
    try {
      final downloadUrl = await _taskRepository.uploadAttachment(task.taskId, file, fileName);
      final updatedAttachments = List<String>.from(task.attachments)..add(downloadUrl);

      final updatedTask = TaskModel(
        taskId: task.taskId,
        title: task.title,
        description: task.description,
        assignedBy: task.assignedBy,
        assignedTo: task.assignedTo,
        priority: task.priority,
        status: task.status,
        deadline: task.deadline,
        createdAt: task.createdAt,
        updatedAt: DateTime.now(),
        attachments: updatedAttachments,
        completionPercentage: task.completionPercentage,
      );

      await _taskRepository.updateTask(updatedTask);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  /// Delete Task
  Future<bool> deleteTask(String taskId) async {
    _setLoading(true);
    try {
      await _taskRepository.deleteTask(taskId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
