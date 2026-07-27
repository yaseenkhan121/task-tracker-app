import 'package:flutter/material.dart';

/// 🎨 Enterprise Black + Red Color Palette for Internee Task Tracker
class AppColors {
  // Primary Black & Dark Tones
  static const Color pureBlack = Color(0xFF000000);
  static const Color darkBackground = Color(0xFF0D0D0D);
  static const Color darkSurface = Color(0xFF161616);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkBorder = Color(0xFF2A2A2A);

  // Primary Red & Accents
  static const Color primaryRed = Color(0xFFE53935);
  static const Color accentRed = Color(0xFFFF1744);
  static const Color deepRed = Color(0xFFB71C1C);
  static const Color lightRedGlow = Color(0x33FF1744);

  // Status Colors
  static const Color pendingOrange = Color(0xFFFF9800);
  static const Color inProgressBlue = Color(0xFF2196F3);
  static const Color reviewPurple = Color(0xFF9C27B0);
  static const Color completedGreen = Color(0xFF4CAF50);
  static const Color rejectedRed = Color(0xFFF44336);

  // Priority Colors
  static const Color priorityLow = Color(0xFF81C784);
  static const Color priorityMedium = Color(0xFFFFB74D);
  static const Color priorityHigh = Color(0xFFFF7043);
  static const Color priorityCritical = Color(0xFFE53935);

  // Light Mode Colors
  static const Color lightBackground = Color(0xFFF5F5F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1D1D1F);
  static const Color lightSubText = Color(0xFF6E6E73);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [pureBlack, deepRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient redButtonGradient = LinearGradient(
    colors: [primaryRed, accentRed],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient glassCardGradient = LinearGradient(
    colors: [Color(0x22262626), Color(0x11161616)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
