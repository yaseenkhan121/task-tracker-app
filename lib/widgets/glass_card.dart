import 'package:flutter/material.dart';
import 'package:intern_task_tracker/core/constants/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Border? border;
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.border,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultDecoration = BoxDecoration(
      color: color ?? (isDark ? AppColors.darkCard : AppColors.lightCard),
      borderRadius: BorderRadius.circular(24),
      border: border ??
          Border.all(
            color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
            width: 1.5,
          ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );

    Widget content = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: defaultDecoration,
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: content,
        ),
      );
    }

    return content;
  }
}
