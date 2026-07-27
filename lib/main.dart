import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intern_task_tracker/core/theme/app_theme.dart';
import 'package:intern_task_tracker/providers/auth_provider.dart';
import 'package:intern_task_tracker/providers/task_provider.dart';
import 'package:intern_task_tracker/providers/theme_provider.dart';
import 'package:intern_task_tracker/screens/auth/login_screen.dart';
import 'package:intern_task_tracker/screens/main_screen.dart';
import 'package:intern_task_tracker/widgets/skeleton_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init notice: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Internee Task Tracker',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const RootAuthRouter(),
          );
        },
      ),
    );
  }
}

class RootAuthRouter extends StatelessWidget {
  const RootAuthRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Show spinner only until initial profile load check completes
    if (!authProvider.isProfileLoaded) {
      return const Scaffold(
        body: Center(
          child: SkeletonLoader(),
        ),
      );
    }

    // Navigates to main app if user is authenticated AND user profile model exists in Firestore
    if (authProvider.isAuthenticated && authProvider.currentUserModel != null) {
      return const MainScreen();
    }

    // Default to login screen if unauthenticated or profile document doesn't exist
    return const LoginScreen();
  }
}