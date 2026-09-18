import 'package:flutter/material.dart';

import '../providers/journal_provider.dart';

/// Big centered mic button with idle / recording / processing visual states.
///
/// The actual audio capture is not implemented in this MVP — see
/// `JournalProvider.stopRecordingAndAnalyze` and `AiJournalService` for the
/// TODOs marking where real recording + AI analysis would plug in.
class MicButton extends StatefulWidget {
  const MicButton({
    super.key,
    required this.status,
    required this.onStart,
    required this.onStop,
  });

  final RecordingStatus status;
  final VoidCallback onStart;
  final VoidCallback onStop;

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isRecording = widget.status == RecordingStatus.recording;
    final isProcessing = widget.status == RecordingStatus.processing;

    return GestureDetector(
      onTap: isProcessing
          ? null
          : (isRecording ? widget.onStop : widget.onStart),
      child: SizedBox(
        width: 200,
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isRecording)
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return _PulseRing(
                    progress: _pulseController.value,
                    color: colorScheme.primary,
                  );
                },
              ),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.35),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: isProcessing
                    ? const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Icon(
                        isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  const _PulseRing({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 200),
      painter: _PulsePainter(progress: progress, color: color),
    );
  }
}

class _PulsePainter extends CustomPainter {
  _PulsePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.width / 2;

    for (final offset in [0.0, 0.5]) {
      final t = (progress + offset) % 1.0;
      final radius = 60 + (maxRadius - 60) * t;
      final opacity = (1 - t).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = color.withValues(alpha: opacity * 0.35)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PulsePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
