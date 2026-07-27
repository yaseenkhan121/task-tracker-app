import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intern_task_tracker/core/constants/app_colors.dart';
import 'package:intern_task_tracker/providers/auth_provider.dart';
import 'package:intern_task_tracker/screens/admin/admin_dashboard_screen.dart';
import 'package:intern_task_tracker/screens/intern/intern_dashboard_screen.dart';
import 'package:intern_task_tracker/screens/reports/reports_screen.dart';
import 'package:intern_task_tracker/screens/profile/profile_screen.dart';
import 'package:intern_task_tracker/screens/settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin;

    final List<Widget> pages = [
      isAdmin ? const AdminDashboardScreen() : const InternDashboardScreen(),
      const ReportsScreen(),
      const ProfileScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.darkBorder, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: AppColors.accentRed,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
