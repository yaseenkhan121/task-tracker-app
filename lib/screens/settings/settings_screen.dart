import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intern_task_tracker/core/constants/app_colors.dart';
import 'package:intern_task_tracker/providers/auth_provider.dart';
import 'package:intern_task_tracker/providers/theme_provider.dart';
import 'package:intern_task_tracker/widgets/glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _taskAssignedNotif = true;
  bool _taskUpdatedNotif = true;
  bool _deadlineReminderNotif = true;

  void _showDeleteAccountDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.darkCard,
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text('Delete Account?', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone and will delete your profile data.',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context);
                await authProvider.signOut();
              },
              child: const Text('Delete Account', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Internee Task Tracker',
      applicationVersion: 'v1.0.0 (Build 1)',
      applicationLegalese: '© 2026 Internee.pk. All rights reserved.',
      applicationIcon: const Icon(Icons.task_alt_rounded, color: AppColors.primaryRed, size: 40),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Configuration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Appearance Section
            const Text('APPEARANCE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accentRed)),
            const SizedBox(height: 8),
            GlassCard(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.accentRed),
                    title: const Text('Dark Mode Theme'),
                    subtitle: const Text('Toggle between dark and light mode'),
                    value: themeProvider.isDarkMode,
                    activeThumbColor: AppColors.accentRed,
                    onChanged: (val) => themeProvider.toggleTheme(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            /// Notifications Section
            const Text('NOTIFICATIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accentRed)),
            const SizedBox(height: 8),
            GlassCard(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.assignment_turned_in_outlined, color: AppColors.accentRed),
                    title: const Text('Task Assigned Alerts'),
                    value: _taskAssignedNotif,
                    activeThumbColor: AppColors.accentRed,
                    onChanged: (val) => setState(() => _taskAssignedNotif = val),
                  ),
                  const Divider(color: Colors.white10),
                  SwitchListTile(
                    secondary: const Icon(Icons.update_rounded, color: AppColors.accentRed),
                    title: const Text('Task Update Alerts'),
                    value: _taskUpdatedNotif,
                    activeThumbColor: AppColors.accentRed,
                    onChanged: (val) => setState(() => _taskUpdatedNotif = val),
                  ),
                  const Divider(color: Colors.white10),
                  SwitchListTile(
                    secondary: const Icon(Icons.timer_outlined, color: AppColors.accentRed),
                    title: const Text('Deadline Reminders'),
                    value: _deadlineReminderNotif,
                    activeThumbColor: AppColors.accentRed,
                    onChanged: (val) => setState(() => _deadlineReminderNotif = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            /// Account & Security Section
            const Text('ACCOUNT & SECURITY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accentRed)),
            const SizedBox(height: 8),
            GlassCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_reset_rounded, color: AppColors.accentRed),
                    title: const Text('Reset Password'),
                    subtitle: const Text('Send password reset email link'),
                    onTap: () {
                      if (authProvider.currentUserModel?.email != null) {
                        authProvider.sendPasswordReset(authProvider.currentUserModel!.email);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password reset email sent!'), backgroundColor: Colors.green),
                        );
                      }
                    },
                  ),
                  const Divider(color: Colors.white10),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded, color: AppColors.accentRed),
                    title: const Text('About Application'),
                    subtitle: const Text('Version, licenses & terms'),
                    onTap: () => _showAboutDialog(context),
                  ),
                  const Divider(color: Colors.white10),
                  ListTile(
                    leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                    title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                    subtitle: const Text('Permanently remove profile data'),
                    onTap: () => _showDeleteAccountDialog(context, authProvider),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            GlassCard(
              onTap: () => authProvider.signOut(),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Sign Out Account', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
