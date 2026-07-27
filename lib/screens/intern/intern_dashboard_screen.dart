import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intern_task_tracker/core/constants/app_colors.dart';
import 'package:intern_task_tracker/models/task_model.dart';
import 'package:intern_task_tracker/providers/auth_provider.dart';
import 'package:intern_task_tracker/providers/task_provider.dart';
import 'package:intern_task_tracker/widgets/stat_card.dart';
import 'package:intern_task_tracker/widgets/task_card.dart';
import 'package:intern_task_tracker/widgets/skeleton_loader.dart';
import 'package:intern_task_tracker/screens/intern/task_detail_screen.dart';

class InternDashboardScreen extends StatelessWidget {
  const InternDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final currentUser = authProvider.currentUserModel;

    if (currentUser == null) {
      return const SkeletonLoader();
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primaryRed,
              radius: 18,
              child: Text(
                currentUser.name.isNotEmpty ? currentUser.name[0].toUpperCase() : 'I',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${currentUser.name}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${currentUser.department} Intern',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.grey),
            onPressed: () => authProvider.signOut(),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: taskProvider.internTasksStream(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonLoader();
          }

          final tasks = snapshot.data ?? [];
          final filteredTasks = taskProvider.filterTasks(tasks);

          final completed = tasks.where((t) => t.status == TaskStatus.completed).length;
          final inProgress = tasks.where((t) => t.status == TaskStatus.inProgress).length;
          final pending = tasks.where((t) => t.status == TaskStatus.pending).length;
          final overdue = tasks.where((t) => t.isOverdue).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Stats Summary Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    StatCard(
                      count: tasks.length,
                      title: 'Assigned Tasks',
                      icon: Icons.assignment_rounded,
                      color: Colors.blue,
                    ),
                    StatCard(
                      count: completed,
                      title: 'Completed Tasks',
                      icon: Icons.task_alt_rounded,
                      color: AppColors.completedGreen,
                    ),
                    StatCard(
                      count: inProgress + pending,
                      title: 'Active Tasks',
                      icon: Icons.autorenew_rounded,
                      color: AppColors.pendingOrange,
                    ),
                    StatCard(
                      count: overdue,
                      title: 'Overdue Deadlines',
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.accentRed,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                /// Search Field
                TextField(
                  onChanged: (val) => taskProvider.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search my assigned tasks...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.accentRed),
                    suffixIcon: taskProvider.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () => taskProvider.setSearchQuery(''),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'My Active Deliverables',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                if (filteredTasks.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.done_all_rounded, size: 48, color: Colors.green),
                        SizedBox(height: 12),
                        Text(
                          'No tasks assigned or pending!',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return TaskCard(
                        task: task,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TaskDetailScreen(task: task),
                            ),
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
