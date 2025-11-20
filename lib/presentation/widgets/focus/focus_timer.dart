import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'dart:math' as math;

class FocusTimerWidget extends StatefulWidget {
  const FocusTimerWidget({Key? key}) : super(key: key);

  @override
  State<FocusTimerWidget> createState() => _FocusTimerWidgetState();
}

class _FocusTimerWidgetState extends State<FocusTimerWidget>
    with SingleTickerProviderStateMixin {
  bool isRunning = false;
  int totalSeconds = 25 * 60; // 25 minutes default
  int remainingSeconds = 25 * 60;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
      if (isRunning && remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else if (remainingSeconds == 0) {
        _stopTimer();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      isRunning = true;
    });
    _animationController.repeat();
  }

  void _stopTimer() {
    setState(() {
      isRunning = false;
    });
    _animationController.stop();
  }

  void _resetTimer() {
    setState(() {
      isRunning = false;
      remainingSeconds = totalSeconds;
    });
    _animationController.stop();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = remainingSeconds / totalSeconds;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Text(
              context.tr('focus.session_title'),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // Circular Timer
            SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  CustomPaint(
                    size: const Size(280, 280),
                    painter: _TimerPainter(
                      progress: 1.0,
                      color: colorScheme.outlineVariant.withOpacity(0.3),
                    ),
                  ),

                  // Progress circle with animation
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(280, 280),
                        painter: _TimerPainter(
                          progress: progress,
                          color: colorScheme.primary,
                          strokeWidth: 12,
                        ),
                      );
                    },
                  ),

                  // Time display
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatTime(remainingSeconds),
                        style: Theme.of(
                          context,
                        ).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 56,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isRunning ? context.tr('focus.focusing') : context.tr('focus.ready_to_focus'),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Play/Pause button
                FilledButton.icon(
                  onPressed: isRunning ? _stopTimer : _startTimer,
                  icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(isRunning ? context.tr('focus.pause') : context.tr('focus.start')),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Reset button
                OutlinedButton.icon(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.refresh),
                  label: Text(context.tr('focus.reset')),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for circular timer
class _TimerPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _TimerPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_TimerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
