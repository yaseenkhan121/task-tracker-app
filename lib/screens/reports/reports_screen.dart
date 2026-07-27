import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intern_task_tracker/core/constants/app_colors.dart';
import 'package:intern_task_tracker/models/task_model.dart';
import 'package:intern_task_tracker/providers/auth_provider.dart';
import 'package:intern_task_tracker/providers/task_provider.dart';
import 'package:intern_task_tracker/widgets/glass_card.dart';
import 'package:intern_task_tracker/widgets/skeleton_loader.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedFilterDays = 30; // 0 = Today, 7 = Last 7 Days, 30 = Last 30 Days, 365 = All Time

  List<TaskModel> _filterTasksByDate(List<TaskModel> tasks) {
    if (_selectedFilterDays == 365) return tasks;
    final now = DateTime.now();
    final cutoff = _selectedFilterDays == 0
        ? DateTime(now.year, now.month, now.day)
        : now.subtract(Duration(days: _selectedFilterDays));
    return tasks.where((t) => t.createdAt.isAfter(cutoff)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final currentUser = authProvider.currentUserModel;

    final stream = (currentUser?.isAdmin ?? false)
        ? taskProvider.allTasksStream
        : taskProvider.internTasksStream(currentUser?.uid ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Text(currentUser?.isAdmin ?? false ? 'Admin Analytics' : 'My Performance Analytics'),
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonLoader();
          }

          final rawTasks = snapshot.data ?? [];
          final tasks = _filterTasksByDate(rawTasks);

          final completed = tasks.where((t) => t.status == TaskStatus.completed).length.toDouble();
          final pending = tasks.where((t) => t.status == TaskStatus.pending).length.toDouble();
          final inProgress = tasks.where((t) => t.status == TaskStatus.inProgress).length.toDouble();
          final review = tasks.where((t) => t.status == TaskStatus.review).length.toDouble();
          final rejected = tasks.where((t) => t.status == TaskStatus.rejected).length.toDouble();
          final overdue = tasks.where((t) => t.isOverdue).length.toDouble();

          final total = tasks.isEmpty ? 1.0 : tasks.length.toDouble();
          final completionRate = (completed / total * 100).toStringAsFixed(1);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Date Range Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Today',
                        isSelected: _selectedFilterDays == 0,
                        onTap: () => setState(() => _selectedFilterDays = 0),
                      ),
                      _FilterChip(
                        label: 'Last 7 Days',
                        isSelected: _selectedFilterDays == 7,
                        onTap: () => setState(() => _selectedFilterDays = 7),
                      ),
                      _FilterChip(
                        label: 'Last 30 Days',
                        isSelected: _selectedFilterDays == 30,
                        onTap: () => setState(() => _selectedFilterDays = 30),
                      ),
                      _FilterChip(
                        label: 'All Time',
                        isSelected: _selectedFilterDays == 365,
                        onTap: () => setState(() => _selectedFilterDays = 365),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                /// Completion Rate Banner
                GlassCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: AppColors.accentRed,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Realtime Completion Rate',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$completionRate%',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentRed,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                /// Stat Metrics Grid
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.1,
                  children: [
                    _MiniMetric(count: '${completed.toInt()}', label: 'Completed', color: AppColors.completedGreen),
                    _MiniMetric(count: '${pending.toInt()}', label: 'Pending', color: AppColors.pendingOrange),
                    _MiniMetric(count: '${inProgress.toInt()}', label: 'In Progress', color: AppColors.inProgressBlue),
                    _MiniMetric(count: '${review.toInt()}', label: 'Review', color: AppColors.reviewPurple),
                    _MiniMetric(count: '${rejected.toInt()}', label: 'Rejected', color: AppColors.rejectedRed),
                    _MiniMetric(count: '${overdue.toInt()}', label: 'Overdue', color: Colors.red),
                  ],
                ),
                const SizedBox(height: 24),

                /// Task Status Pie Chart
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Task Status Distribution',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                color: AppColors.completedGreen,
                                value: completed == 0 ? 0.001 : completed,
                                title: '${completed.toInt()}',
                                radius: 45,
                                titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              PieChartSectionData(
                                color: AppColors.inProgressBlue,
                                value: inProgress == 0 ? 0.001 : inProgress,
                                title: '${inProgress.toInt()}',
                                radius: 45,
                                titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              PieChartSectionData(
                                color: AppColors.reviewPurple,
                                value: review == 0 ? 0.001 : review,
                                title: '${review.toInt()}',
                                radius: 45,
                                titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              PieChartSectionData(
                                color: AppColors.pendingOrange,
                                value: pending == 0 ? 0.001 : pending,
                                title: '${pending.toInt()}',
                                radius: 45,
                                titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _LegendItem(color: AppColors.completedGreen, label: 'Completed'),
                          _LegendItem(color: AppColors.inProgressBlue, label: 'In Progress'),
                          _LegendItem(color: AppColors.reviewPurple, label: 'Review'),
                          _LegendItem(color: AppColors.pendingOrange, label: 'Pending'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryRed : AppColors.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primaryRed),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String count;
  final String label;
  final Color color;

  const _MiniMetric({required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(count, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
