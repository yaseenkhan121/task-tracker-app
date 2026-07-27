import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intern_task_tracker/core/constants/app_colors.dart';
import 'package:intern_task_tracker/core/constants/firebase_constants.dart';
import 'package:intern_task_tracker/models/user_model.dart';
import 'package:intern_task_tracker/models/task_model.dart';
import 'package:intern_task_tracker/providers/auth_provider.dart';
import 'package:intern_task_tracker/providers/task_provider.dart';
import 'package:intern_task_tracker/repositories/user_repository.dart';
import 'package:intern_task_tracker/widgets/glass_card.dart';
import 'package:intern_task_tracker/widgets/gradient_button.dart';
import 'package:intern_task_tracker/widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserRepository _userRepository = UserRepository();
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingImage = false;

  Future<void> _pickAndUploadAvatar(UserModel user) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return;

    setState(() => _isUploadingImage = true);
    try {
      final file = File(image.path);
      final ref = FirebaseStorage.instance
          .ref()
          .child('${FirebaseConstants.profileImagesFolder}/${user.uid}.jpg');

      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      final updatedUser = UserModel(
        uid: user.uid,
        name: user.name,
        email: user.email,
        phone: user.phone,
        department: user.department,
        university: user.university,
        profileImage: downloadUrl,
        role: user.role,
        createdAt: user.createdAt,
        internId: user.internId,
        bio: user.bio,
        skills: user.skills,
        address: user.address,
        emergencyContact: user.emergencyContact,
        github: user.github,
        linkedin: user.linkedin,
        portfolio: user.portfolio,
      );

      await _userRepository.updateUserProfile(updatedUser);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: AppColors.accentRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  void _showEditProfileModal(UserModel user) {
    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phone);
    final bioCtrl = TextEditingController(text: user.bio);
    final skillsCtrl = TextEditingController(text: user.skills);
    final deptCtrl = TextEditingController(text: user.department);
    final uniCtrl = TextEditingController(text: user.university);
    final githubCtrl = TextEditingController(text: user.github);
    final linkedinCtrl = TextEditingController(text: user.linkedin);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Edit Profile Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                CustomTextField(controller: nameCtrl, labelText: 'Full Name', hintText: 'Name'),
                const SizedBox(height: 12),
                CustomTextField(controller: phoneCtrl, labelText: 'Phone Number', hintText: '+92...'),
                const SizedBox(height: 12),
                CustomTextField(controller: bioCtrl, labelText: 'Bio / Objective', hintText: 'Tell us about yourself...'),
                const SizedBox(height: 12),
                CustomTextField(controller: skillsCtrl, labelText: 'Skills (comma separated)', hintText: 'Flutter, Dart, Firebase'),
                const SizedBox(height: 12),
                CustomTextField(controller: deptCtrl, labelText: 'Department', hintText: 'Mobile App Dev'),
                const SizedBox(height: 12),
                CustomTextField(controller: uniCtrl, labelText: 'University', hintText: 'University Name'),
                const SizedBox(height: 12),
                CustomTextField(controller: githubCtrl, labelText: 'GitHub URL', hintText: 'https://github.com/...'),
                const SizedBox(height: 12),
                CustomTextField(controller: linkedinCtrl, labelText: 'LinkedIn URL', hintText: 'https://linkedin.com/in/...'),
                const SizedBox(height: 24),
                GradientButton(
                  text: 'Save Changes',
                  onPressed: () async {
                    final navigator = Navigator.of(modalContext);
                    final updated = UserModel(
                      uid: user.uid,
                      name: nameCtrl.text.trim(),
                      email: user.email,
                      phone: phoneCtrl.text.trim(),
                      department: deptCtrl.text.trim(),
                      university: uniCtrl.text.trim(),
                      profileImage: user.profileImage,
                      role: user.role,
                      createdAt: user.createdAt,
                      internId: user.internId,
                      bio: bioCtrl.text.trim(),
                      skills: skillsCtrl.text.trim(),
                      address: user.address,
                      emergencyContact: user.emergencyContact,
                      github: githubCtrl.text.trim(),
                      linkedin: linkedinCtrl.text.trim(),
                      portfolio: user.portfolio,
                    );
                    await _userRepository.updateUserProfile(updated);
                    navigator.pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final user = authProvider.currentUserModel;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: AppColors.accentRed, size: 26),
            onPressed: () => _showEditProfileModal(user),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: user.isAdmin
            ? taskProvider.allTasksStream
            : taskProvider.internTasksStream(user.uid),
        builder: (context, snapshot) {
          final tasks = snapshot.data ?? [];
          final completed = tasks.where((t) => t.status == TaskStatus.completed).length;
          final pending = tasks.where((t) => t.status == TaskStatus.pending).length;
          final successRate = tasks.isEmpty ? 100 : ((completed / tasks.length) * 100).toInt();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                /// Avatar & Basic Info
                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _pickAndUploadAvatar(user),
                        child: CircleAvatar(
                          radius: 52,
                          backgroundColor: AppColors.primaryRed,
                          child: user.profileImage.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(52),
                                  child: CachedNetworkImage(
                                    imageUrl: user.profileImage,
                                    width: 104,
                                    height: 104,
                                    fit: BoxFit.cover,
                                    placeholder: (c, u) => const CircularProgressIndicator(color: Colors.white),
                                    errorWidget: (c, u, e) => Text(
                                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                      style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                              : Text(
                                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                  style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _pickAndUploadAvatar(user),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.accentRed,
                              shape: BoxShape.circle,
                            ),
                            child: _isUploadingImage
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${user.internId} • ${user.role}',
                  style: const TextStyle(color: AppColors.accentRed, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 20),

                /// Stat Pill Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatBadge(label: 'Completed', value: '$completed'),
                    _StatBadge(label: 'Pending', value: '$pending'),
                    _StatBadge(label: 'Success Rate', value: '$successRate%'),
                  ],
                ),
                const SizedBox(height: 24),

                /// Bio & Details Card
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (user.bio.isNotEmpty) ...[
                        const Text('Bio / Objective', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(user.bio, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        const Divider(height: 24, color: Colors.white10),
                      ],
                      _ProfileRow(icon: Icons.email_outlined, title: 'Email', value: user.email),
                      const Divider(height: 20, color: Colors.white10),
                      _ProfileRow(icon: Icons.phone_outlined, title: 'Phone', value: user.phone.isEmpty ? 'Not set' : user.phone),
                      const Divider(height: 20, color: Colors.white10),
                      _ProfileRow(icon: Icons.work_outline_rounded, title: 'Track / Department', value: user.department),
                      const Divider(height: 20, color: Colors.white10),
                      _ProfileRow(icon: Icons.school_outlined, title: 'University', value: user.university),
                      if (user.skills.isNotEmpty) ...[
                        const Divider(height: 20, color: Colors.white10),
                        _ProfileRow(icon: Icons.code_rounded, title: 'Skills', value: user.skills),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                /// Social Links Card
                if (user.github.isNotEmpty || user.linkedin.isNotEmpty)
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Social Links', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        if (user.github.isNotEmpty)
                          _ProfileRow(icon: Icons.code_off_rounded, title: 'GitHub', value: user.github),
                        if (user.linkedin.isNotEmpty)
                          _ProfileRow(icon: Icons.link_rounded, title: 'LinkedIn', value: user.linkedin),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),

                GradientButton(
                  text: 'Sign Out Account',
                  icon: Icons.logout_rounded,
                  onPressed: () => authProvider.signOut(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;

  const _StatBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.accentRed)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileRow({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accentRed, size: 18),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
