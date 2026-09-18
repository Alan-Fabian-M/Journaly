import 'package:flutter/material.dart';
import 'package:flutter_twemoji/flutter_twemoji.dart';

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
          child: Twemoji(emoji: emotion.emoji, height: 22, width: 22),
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
