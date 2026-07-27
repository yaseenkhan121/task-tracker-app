import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:intern_task_tracker/core/constants/app_colors.dart';
import 'package:intern_task_tracker/models/task_model.dart';
import 'package:intern_task_tracker/providers/task_provider.dart';
import 'package:intern_task_tracker/widgets/glass_card.dart';
import 'package:intern_task_tracker/widgets/gradient_button.dart';
import 'package:intern_task_tracker/widgets/status_badge.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TaskStatus _currentStatus;
  late double _progressValue;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.task.status;
    _progressValue = widget.task.completionPercentage.toDouble();
  }

  Future<void> _handleUpdateStatus() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final success = await taskProvider.updateTaskStatus(
      taskId: widget.task.taskId,
      newStatus: _currentStatus,
      progress: _progressValue.toInt(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task status updated!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;

      if (!mounted) return;
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final success = await taskProvider.uploadAttachment(
        task: widget.task,
        file: file,
        fileName: fileName,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attachment uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header Card
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PriorityBadge(priority: widget.task.priority),
                      StatusBadge(status: _currentStatus),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.task.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Assigned By: ${widget.task.assignedBy}',
                    style: const TextStyle(color: AppColors.accentRed, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Task Requirements',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.task.description,
                    style: TextStyle(color: Colors.grey.shade300, fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Deadline:', style: TextStyle(color: Colors.grey)),
                      Text(
                        DateFormat.yMMMd().format(widget.task.deadline),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            /// Update Status & Completion Slider
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Update Progress',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  /// Status Dropdown
                  DropdownButtonFormField<TaskStatus>(
                    initialValue: _currentStatus,
                    decoration: const InputDecoration(labelText: 'Task Status'),
                    dropdownColor: AppColors.darkCard,
                    items: TaskStatus.values.map((status) {
                      return DropdownMenuItem<TaskStatus>(
                        value: status,
                        child: Text(status.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _currentStatus = val!),
                  ),
                  const SizedBox(height: 20),

                  /// Progress Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Completion:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${_progressValue.toInt()}%', style: const TextStyle(color: AppColors.accentRed, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: _progressValue,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: AppColors.primaryRed,
                    onChanged: (val) => setState(() => _progressValue = val),
                  ),
                  const SizedBox(height: 16),

                  GradientButton(
                    text: 'Save Progress',
                    icon: Icons.save_rounded,
                    isLoading: taskProvider.isLoading,
                    onPressed: _handleUpdateStatus,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            /// Task Attachments
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Deliverables & Attachments',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.attach_file_rounded, color: AppColors.accentRed),
                        onPressed: _pickAndUploadFile,
                        tooltip: 'Upload File',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (widget.task.attachments.isEmpty)
                    const Text('No attachments uploaded yet.', style: TextStyle(color: Colors.grey, fontSize: 13))
                  else
                    Column(
                      children: widget.task.attachments.map((url) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.darkSurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.insert_drive_file_outlined, color: Colors.blue),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  url,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
