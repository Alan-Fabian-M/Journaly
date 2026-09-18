import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Bottom nav styled after design.md: active icon sits inside a solid
/// rounded pill, inactive icons are muted outline icons, no labels.
class JournalyBottomNavBar extends StatelessWidget {
  const JournalyBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _icons = [
    (Icons.mic_none_rounded, Icons.mic_rounded),
    (Icons.insights_outlined, Icons.insights_rounded),
    (Icons.people_outline_rounded, Icons.people_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_icons.length, (index) {
              final active = index == currentIndex;
              final (outlineIcon, filledIcon) = _icons[index];
              return GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: active
                        ? (isDark ? AppColors.darkAccent : AppColors.lightAccent)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    active ? filledIcon : outlineIcon,
                    size: 22,
                    color: active
                        ? (isDark ? AppColors.darkOnAccent : AppColors.lightOnAccent)
                        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
