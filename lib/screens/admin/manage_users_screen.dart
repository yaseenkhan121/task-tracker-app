import 'package:flutter/material.dart';
import 'package:intern_task_tracker/core/constants/app_colors.dart';
import 'package:intern_task_tracker/models/user_model.dart';
import 'package:intern_task_tracker/repositories/user_repository.dart';
import 'package:intern_task_tracker/widgets/glass_card.dart';
import 'package:intern_task_tracker/widgets/skeleton_loader.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final UserRepository _userRepository = UserRepository();
  String _searchQuery = '';
  String _roleFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enterprise User Management'),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: _userRepository.getAllUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonLoader();
          }

          final allUsers = snapshot.data ?? [];
          final filteredUsers = allUsers.where((u) {
            final matchesQuery = _searchQuery.isEmpty ||
                u.name.toLowerCase().contains(_searchQuery) ||
                u.email.toLowerCase().contains(_searchQuery) ||
                u.department.toLowerCase().contains(_searchQuery);

            final matchesRole = _roleFilter == 'All' || u.role.toLowerCase() == _roleFilter.toLowerCase();
            return matchesQuery && matchesRole;
          }).toList();

          return Column(
            children: [
              /// Search & Filter Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (val) => setState(() => _searchQuery = val.toLowerCase().trim()),
                      decoration: InputDecoration(
                        hintText: 'Search by name, email, or department...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.accentRed),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () => setState(() => _searchQuery = ''),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: ['All', 'Admin', 'Intern'].map((role) {
                        final isSelected = _roleFilter == role;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(role),
                            selected: isSelected,
                            selectedColor: AppColors.primaryRed,
                            onSelected: (_) => setState(() => _roleFilter = role),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              /// User List View
              Expanded(
                child: filteredUsers.isEmpty
                    ? const Center(
                        child: Text('No matching users found.', style: TextStyle(color: Colors.grey)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return GlassCard(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: user.isAdmin ? AppColors.accentRed : Colors.blue,
                                child: Text(
                                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                user.name.isEmpty ? user.email : user.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Text(
                                '${user.email}\n${user.department.isEmpty ? 'General' : user.department} • ${user.internId}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
                                color: AppColors.darkCard,
                                onSelected: (action) async {
                                  if (action == 'toggle_role') {
                                    final newRole = user.isAdmin ? 'Intern' : 'Admin';
                                    final updated = UserModel(
                                      uid: user.uid,
                                      name: user.name,
                                      email: user.email,
                                      phone: user.phone,
                                      department: user.department,
                                      university: user.university,
                                      profileImage: user.profileImage,
                                      role: newRole,
                                      createdAt: user.createdAt,
                                      internId: user.internId,
                                      bio: user.bio,
                                      skills: user.skills,
                                    );
                                    await _userRepository.updateUserProfile(updated);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Role changed to $newRole!'), backgroundColor: Colors.green),
                                      );
                                    }
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'toggle_role',
                                    child: Text(user.isAdmin ? 'Demote to Intern' : 'Promote to Admin'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
