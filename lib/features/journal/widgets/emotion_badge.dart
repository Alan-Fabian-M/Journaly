import 'package:flutter/material.dart';

import '../models/emotion_result.dart';

class EmotionBadge extends StatelessWidget {
  const EmotionBadge({super.key, required this.emotion});

  final EmotionType emotion;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: emotion.color.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          child: Icon(emotion.icon, color: emotion.color, size: 22),
        ),
        const SizedBox(width: 10),
        Text(
          emotion.label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: emotion.color,
          ),
        ),
      ],
    );
  }
}
