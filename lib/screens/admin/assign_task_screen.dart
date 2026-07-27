import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intern_task_tracker/core/constants/app_colors.dart';
import 'package:intern_task_tracker/models/task_model.dart';
import 'package:intern_task_tracker/models/user_model.dart';
import 'package:intern_task_tracker/providers/auth_provider.dart';
import 'package:intern_task_tracker/providers/task_provider.dart';
import 'package:intern_task_tracker/repositories/user_repository.dart';
import 'package:intern_task_tracker/widgets/custom_text_field.dart';
import 'package:intern_task_tracker/widgets/gradient_button.dart';
import 'package:intern_task_tracker/widgets/glass_card.dart';

class AssignTaskScreen extends StatefulWidget {
  const AssignTaskScreen({super.key});

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final UserRepository _userRepository = UserRepository();

  DateTime? _selectedDeadline;
  TaskPriority _selectedPriority = TaskPriority.medium;
  String? _selectedInternUid;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryRed,
              onPrimary: Colors.white,
              surface: AppColors.darkCard,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDeadline = picked);
    }
  }

  Future<void> _handleCreateTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedInternUid == null || _selectedInternUid!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an intern to assign the task.')),
      );
      return;
    }
    if (_selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a deadline.')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    final success = await taskProvider.createTask(
      title: _titleController.text,
      description: _descController.text,
      assignedBy: authProvider.currentUserModel?.name ?? 'Admin',
      assignedTo: _selectedInternUid!,
      priority: _selectedPriority,
      deadline: _selectedDeadline!,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task assigned successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign New Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: GlassCard(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Task Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _titleController,
                  labelText: 'Task Title *',
                  hintText: 'e.g. Build Auth Module in Flutter',
                  prefixIcon: Icons.title_rounded,
                  validator: (v) => v!.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _descController,
                  labelText: 'Description *',
                  hintText: 'Enter comprehensive task requirements and deliverables...',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 4,
                  validator: (v) => v!.isEmpty ? 'Description is required' : null,
                ),
                const SizedBox(height: 20),

                /// Select Intern Stream Dropdown
                const Text(
                  'Assign To Intern *',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                StreamBuilder<List<UserModel>>(
                  stream: _userRepository.getInternsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LinearProgressIndicator(color: AppColors.primaryRed);
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.darkBorder),
                        ),
                        child: const Text(
                          'No registered interns found in database.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      );
                    }

                    final interns = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedInternUid,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.badge_outlined, color: AppColors.primaryRed),
                        hintText: 'Select Intern',
                      ),
                      dropdownColor: AppColors.darkCard,
                      items: interns.map((intern) {
                        final displayName = intern.name.isEmpty ? intern.email : intern.name;
                        final dept = intern.department.isEmpty ? 'Intern' : intern.department;
                        return DropdownMenuItem<String>(
                          value: intern.uid,
                          child: Text('$displayName ($dept)'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedInternUid = val),
                    );
                  },
                ),
                const SizedBox(height: 20),

                /// Priority Selector
                const Text(
                  'Priority Level',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: TaskPriority.values.map((p) {
                    final isSelected = _selectedPriority == p;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedPriority = p),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryRed : AppColors.darkSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primaryRed),
                          ),
                          child: Center(
                            child: Text(
                              p.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                /// Deadline Picker
                const Text(
                  'Deadline *',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDeadline == null
                              ? 'Select Date'
                              : DateFormat.yMMMd().format(_selectedDeadline!),
                          style: TextStyle(
                            color: _selectedDeadline == null ? Colors.grey : Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const Icon(Icons.calendar_month_rounded, color: AppColors.accentRed),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                GradientButton(
                  text: 'Dispatch Task',
                  icon: Icons.send_rounded,
                  isLoading: taskProvider.isLoading,
                  onPressed: _handleCreateTask,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
