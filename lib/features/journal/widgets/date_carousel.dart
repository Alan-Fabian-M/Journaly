import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';

/// Horizontal strip of the last [dayCount] days (today included, at the
/// end). Tapping a date reports it via [onDateSelected] so the caller can
/// look up and show that day's journal.
class DateCarousel extends StatelessWidget {
  const DateCarousel({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.dayCount = 10,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final int dayCount;

  static const _weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateTime.now();
    final dates = List.generate(
      dayCount,
      (i) => today.subtract(Duration(days: dayCount - 1 - i)),
    );

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = dates[index];
          final selected = _isSameDay(date, selectedDate);

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 52,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? (isDark ? AppColors.darkAccent : AppColors.lightAccent)
                    : (isDark ? AppColors.darkTile : AppColors.lightTile),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekdays[date.weekday - 1],
                    style: TextStyle(
                      fontSize: 11,
                      color: selected
                          ? (isDark ? AppColors.darkOnAccent : AppColors.lightOnAccent)
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? (isDark ? AppColors.darkOnAccent : AppColors.lightOnAccent)
                          : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
