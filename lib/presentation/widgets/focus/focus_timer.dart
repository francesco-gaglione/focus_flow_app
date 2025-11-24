import 'dart:async';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:logger/logger.dart';

import 'package:focus_flow_app/adapters/dtos/ws_dtos.dart';

class FocusTimerWidget extends StatelessWidget {
  final Logger logger = Logger();

  final DateTime? startDate;
  final VoidCallback onStart;
  final VoidCallback onBreak;
  final VoidCallback onTerminate;
  final SessionTypeEnum? sessionType;

  FocusTimerWidget({
    super.key,
    this.startDate,
    required this.onStart,
    required this.onBreak,
    required this.onTerminate,
    this.sessionType,
  });

  int _getTotalSeconds(SessionTypeEnum? sessionType) {
    switch (sessionType) {
      case SessionTypeEnum.focus:
      case SessionTypeEnum.work:
        return 25 * 60;
      case SessionTypeEnum.shortBreak:
        return 5 * 60;
      case SessionTypeEnum.longBreak:
        return 15 * 60;
      default:
        return 25 * 60;
    }
  }

  String _getTitle(BuildContext context, SessionTypeEnum? sessionType) {
    switch (sessionType) {
      case SessionTypeEnum.focus:
      case SessionTypeEnum.work:
        return context.tr('focus.session_title');
      case SessionTypeEnum.shortBreak:
        return context.tr('focus.short_break_title');
      case SessionTypeEnum.longBreak:
        return context.tr('focus.long_break_title');
      default:
        return context.tr('focus.session_title');
    }
  }

  String _getStatusText(BuildContext context, SessionTypeEnum? sessionType) {
    if (startDate == null) {
      return context.tr('focus.ready_to_focus');
    }

    switch (sessionType) {
      case SessionTypeEnum.focus:
      case SessionTypeEnum.work:
        return context.tr('focus.focusing');

      case SessionTypeEnum.shortBreak:
        return context.tr('focus.short_break_status');

      case SessionTypeEnum.longBreak:
        return context.tr('focus.long_break_status');

      default:
        return context.tr('focus.focusing');
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.i('Building FocusTimerWidget, startDate: $startDate');

    final bool isRunning = startDate != null;

    return StreamBuilder<int>(
      stream:
          isRunning
              ? Stream.periodic(const Duration(seconds: 1), (i) => i)
              : null,
      builder: (context, snapshot) {
        final totalSeconds = _getTotalSeconds(sessionType);
        int remainingSeconds;
        if (isRunning) {
          final now = DateTime.now();
          final elapsed = now.difference(startDate!).inSeconds;
          remainingSeconds = (totalSeconds - elapsed).clamp(0, totalSeconds);
        } else {
          remainingSeconds = totalSeconds;
        }
        final colorScheme = Theme.of(context).colorScheme;
        // Restore dynamic category color (primary) but keep Figma style
        final accentColor = colorScheme.primary; 
        final trackColor = Colors.grey.shade200;
        final textColor = const Color(0xFF2D3142); // Dark grey/blue for text

        final progress =
            totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;
        String formatTime(int seconds) {
          final minutes = seconds ~/ 60;
          final secs = seconds % 60;
          return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
        }

        return Card(
          elevation: 4, // Added elevation for a card look
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          color: Colors.white, // White background as per Figma
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Text(
                  _getTitle(context, sessionType),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 280,
                  height: 280,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(280, 280),
                        painter: _TimerPainter(
                          progress: 1.0,
                          color: trackColor,
                          strokeWidth: 12, // Thicker track
                        ),
                      ),
                      CustomPaint(
                        size: const Size(280, 280),
                        painter: _TimerPainter(
                          progress: progress,
                          color: accentColor,
                          strokeWidth: 12,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            formatTime(remainingSeconds),
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.w900, // Bolder font
                              fontSize: 64, // Larger font
                              color: textColor,
                              letterSpacing: -1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getStatusText(context, sessionType),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: textColor.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48), // More spacing

                if (!isRunning)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: onStart,
                      style: FilledButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text(context.tr('focus.start').toUpperCase()),
                    ),
                  )
                else if (sessionType == SessionTypeEnum.shortBreak ||
                    sessionType == SessionTypeEnum.longBreak)
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: FilledButton(
                            onPressed: onStart,
                            style: FilledButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: Text(context.tr('focus.start').toUpperCase()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: OutlinedButton(
                            onPressed: onTerminate,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textColor.withOpacity(0.7),
                              side: BorderSide(color: textColor.withOpacity(0.3)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: Text(context.tr('focus.terminate')),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: FilledButton(
                            onPressed: onBreak,
                            style: FilledButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: Text(context.tr('focus.break').toUpperCase()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: OutlinedButton(
                            onPressed: onTerminate,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textColor.withOpacity(0.7),
                              side: BorderSide(color: textColor.withOpacity(0.3)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: Text(context.tr('focus.terminate')),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter for circular timer
class _TimerPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final StrokeCap strokeCap;

  _TimerPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 8,
    this.strokeCap = StrokeCap.butt,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..strokeCap = strokeCap
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
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
