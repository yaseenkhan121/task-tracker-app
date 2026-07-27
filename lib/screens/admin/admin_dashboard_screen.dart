import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intern_task_tracker/core/constants/app_colors.dart';
import 'package:intern_task_tracker/models/task_model.dart';
import 'package:intern_task_tracker/models/user_model.dart';
import 'package:intern_task_tracker/providers/auth_provider.dart';
import 'package:intern_task_tracker/providers/task_provider.dart';
import 'package:intern_task_tracker/repositories/user_repository.dart';
import 'package:intern_task_tracker/widgets/stat_card.dart';
import 'package:intern_task_tracker/widgets/task_card.dart';
import 'package:intern_task_tracker/widgets/skeleton_loader.dart';
import 'package:intern_task_tracker/screens/admin/assign_task_screen.dart';
import 'package:intern_task_tracker/screens/admin/manage_users_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final userRepository = UserRepository();

    final currentUser = authProvider.currentUserModel;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.primaryRed,
              radius: 18,
              child: Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${currentUser?.name ?? "Admin"}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Internee.pk Admin Portal',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_alt_rounded, color: AppColors.accentRed),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageUsersScreen()),
              );
            },
            tooltip: 'Manage Users',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.grey),
            onPressed: () => authProvider.signOut(),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AssignTaskScreen()),
          );
        },
        backgroundColor: AppColors.primaryRed,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: const Text('Assign Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: taskProvider.allTasksStream,
        builder: (context, taskSnapshot) {
          if (taskSnapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonLoader();
          }

          final allTasks = taskSnapshot.data ?? [];
          final filteredTasks = taskProvider.filterTasks(allTasks);

          final totalCount = allTasks.length;
          final completedCount = allTasks.where((t) => t.status == TaskStatus.completed).length;
          final pendingCount = allTasks.where((t) => t.status == TaskStatus.pending).length;
          final reviewCount = allTasks.where((t) => t.status == TaskStatus.review).length;
          final overdueCount = allTasks.where((t) => t.isOverdue).length;

          return StreamBuilder<List<UserModel>>(
            stream: userRepository.getInternsStream(),
            builder: (context, internSnapshot) {
              final internCount = internSnapshot.data?.length ?? 0;

              return RefreshIndicator(
                onRefresh: () async {},
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Statistics Grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.4,
                        children: [
                          StatCard(
                            count: internCount,
                            title: 'Active Interns',
                            icon: Icons.people_outline_rounded,
                            color: Colors.cyan,
                          ),
                          StatCard(
                            count: totalCount,
                            title: 'Total Tasks',
                            icon: Icons.assignment_outlined,
                            color: Colors.blue,
                          ),
                          StatCard(
                            count: completedCount,
                            title: 'Completed',
                            icon: Icons.check_circle_outline_rounded,
                            color: AppColors.completedGreen,
                          ),
                          StatCard(
                            count: reviewCount,
                            title: 'In Review',
                            icon: Icons.rate_review_outlined,
                            color: AppColors.reviewPurple,
                          ),
                          StatCard(
                            count: pendingCount,
                            title: 'Pending',
                            icon: Icons.hourglass_empty_rounded,
                            color: AppColors.pendingOrange,
                          ),
                          StatCard(
                            count: overdueCount,
                            title: 'Overdue Tasks',
                            icon: Icons.warning_amber_rounded,
                            color: AppColors.accentRed,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      /// Search Bar & Realtime Filters
                      TextField(
                        onChanged: (val) => taskProvider.setSearchQuery(val),
                        decoration: InputDecoration(
                          hintText: 'Search tasks by title or details...',
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.accentRed),
                          suffixIcon: taskProvider.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () => taskProvider.setSearchQuery(''),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// Status Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ChoiceChip(
                              label: const Text('All Tasks'),
                              selected: taskProvider.selectedStatusFilter == null,
                              onSelected: (_) => taskProvider.setStatusFilter(null),
                              selectedColor: AppColors.primaryRed,
                            ),
                            const SizedBox(width: 8),
                            ...TaskStatus.values.map((status) {
                              final isSelected = taskProvider.selectedStatusFilter == status;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(status.name.toUpperCase()),
                                  selected: isSelected,
                                  selectedColor: AppColors.primaryRed,
                                  onSelected: (_) => taskProvider.setStatusFilter(status),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      /// Task List Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Realtime Task Overview',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${filteredTasks.length} tasks',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      /// Task List View
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
                              Icon(Icons.assignment_turned_in_outlined, size: 48, color: Colors.grey),
                              SizedBox(height: 12),
                              Text(
                                'No matching tasks found',
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
                              onTap: () {},
                              onDelete: () => taskProvider.deleteTask(task.taskId),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
