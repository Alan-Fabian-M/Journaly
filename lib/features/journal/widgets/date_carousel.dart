import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../models/emotion_result.dart';
import '../models/journal.dart';

/// Horizontal strip centered on today: past dates to the left, future dates
/// to the right. Scrolls so today sits in the middle of the viewport as
/// soon as it lays out. Tapping a date reports it via [onDateSelected] so
/// the caller can look up and show that day's journal.
///
/// Each tile is tinted with that day's journal emotion color when there is
/// one, so the week's mood is visible at a glance; days with no journal (and
/// future dates) stay neutral.
class DateCarousel extends StatefulWidget {
  const DateCarousel({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.journals,
    this.daysAround = 7,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final List<Journal> journals;

  /// How many days to show on each side of today.
  final int daysAround;

  @override
  State<DateCarousel> createState() => _DateCarouselState();
}

class _DateCarouselState extends State<DateCarousel> {
  static const _itemWidth = 52.0;
  static const _itemSpacing = 10.0;
  static const _itemExtent = _itemWidth + _itemSpacing;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerToday());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _centerToday() {
    if (!_scrollController.hasClients) return;
    final viewportWidth = _scrollController.position.viewportDimension;
    // Today is always at index `daysAround` — see `dates` in build().
    final todayCenter = widget.daysAround * _itemExtent + _itemWidth / 2;
    final target = (todayCenter - viewportWidth / 2)
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.jumpTo(target);
  }

  static const _weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  EmotionType? _emotionOf(DateTime date) {
    for (final journal in widget.journals) {
      if (_isSameDay(journal.date, date)) return journal.emotionResult.emotion;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final onAccent = isDark ? AppColors.darkOnAccent : AppColors.lightOnAccent;
    final tileColor = isDark ? AppColors.darkTile : AppColors.lightTile;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primaryColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final today = DateTime.now();
    final dates = List.generate(
      widget.daysAround * 2 + 1,
      (i) => today.add(Duration(days: i - widget.daysAround)),
    );

    return SizedBox(
      height: 72,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, _) => const SizedBox(width: _itemSpacing),
        itemBuilder: (context, index) {
          final date = dates[index];
          final selected = _isSameDay(date, widget.selectedDate);
          final emotion = _emotionOf(date);

          final fillColor = emotion != null
              ? emotion.color.withValues(alpha: selected ? 0.28 : 0.16)
              : (selected ? accent : tileColor);
          final contentColor = emotion != null
              ? emotion.color
              : (selected ? onAccent : null);

          return GestureDetector(
            onTap: () => widget.onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: _itemWidth,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(18),
                border: selected
                    ? Border.all(color: emotion != null ? emotion.color : accent, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekdays[date.weekday - 1],
                    style: TextStyle(
                      fontSize: 11,
                      color: contentColor ?? secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: contentColor ?? primaryColor,
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
