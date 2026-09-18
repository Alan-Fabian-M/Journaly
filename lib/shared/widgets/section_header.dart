import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Title + chevron header, matching the "Super Card >" / "Super ATM >"
/// section style from design.md. The chevron only renders when [onTap] is
/// given, so it also works as a plain section title.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onTap});

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          if (onTap != null)
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
        ],
      ),
    );
  }
}
