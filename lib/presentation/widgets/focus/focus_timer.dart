import 'dart:async';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:logger/logger.dart';

import 'package:focus_flow_app/adapters/dtos/ws_dtos.dart';

class FocusTimerWidget extends StatefulWidget {
  final DateTime? startDate;
  final VoidCallback onStart;
  final VoidCallback onBreak;
  final VoidCallback onTerminate;
  final SessionTypeEnum? sessionType;

  const FocusTimerWidget({
    super.key,
    this.startDate,
    required this.onStart,
    required this.onBreak,
    required this.onTerminate,
    this.sessionType,
  });

  @override
  State<FocusTimerWidget> createState() => _FocusTimerWidgetState();
}

class _FocusTimerWidgetState extends State<FocusTimerWidget>
    with SingleTickerProviderStateMixin {
  final Logger logger = Logger();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
    int elapsed = 0;
    if (widget.startDate != null) {
      final now = DateTime.now();
      elapsed = now.difference(widget.startDate!).inSeconds;
    }

    if (widget.startDate != null && elapsed > _getTotalSeconds(sessionType)) {
      return context.tr('focus.overtime');
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
    // logger.i('Building FocusTimerWidget, startDate: ${widget.startDate}');

    final bool isRunning = widget.startDate != null;
    final colorScheme = Theme.of(context).colorScheme;

    // Use theme colors instead of hardcoded values
    final accentColor = colorScheme.primary;
    final trackColor = colorScheme.surfaceContainerHighest.withAlpha(
      (255 * 0.3).round(),
    );
    final textColor = colorScheme.onSurface;
    final errorColor = colorScheme.error;

    return StreamBuilder<int>(
      stream:
          isRunning
              ? Stream.periodic(const Duration(seconds: 1), (i) => i)
              : null,
      builder: (context, snapshot) {
        final totalSeconds = _getTotalSeconds(widget.sessionType);
        int remainingSeconds;
        int overtimeSeconds = 0;
        bool isOvertime = false;

        if (isRunning) {
          final now = DateTime.now();
          final elapsed = now.difference(widget.startDate!).inSeconds;
          if (elapsed > totalSeconds) {
            remainingSeconds = 0;
            overtimeSeconds = elapsed - totalSeconds;
            isOvertime = true;
          } else {
            remainingSeconds = totalSeconds - elapsed;
          }
        } else {
          remainingSeconds = totalSeconds;
        }

        final progress =
            totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;

        String formatTime(int seconds) {
          final minutes = seconds ~/ 60;
          final secs = seconds % 60;
          return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
        }

        final displayTime =
            isOvertime
                ? formatTime(totalSeconds + overtimeSeconds)
                : formatTime(remainingSeconds);

        final timerColor = isOvertime ? errorColor : textColor;

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(
              (255 * 0.3).round(),
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: colorScheme.outlineVariant.withAlpha((255 * 0.2).round()),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((255 * 0.05).round()),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Text(
                  _getTitle(context, widget.sessionType),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 300,
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background Track
                      CustomPaint(
                        size: const Size(300, 300),
                        painter: _TimerPainter(
                          progress: 1.0,
                          color: trackColor,
                          strokeWidth: 20,
                        ),
                      ),
                      // Progress Arc with Gradient and Glow
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return CustomPaint(
                            size: const Size(300, 300),
                            painter: _TimerPainter(
                              progress: isOvertime ? 1.0 : progress,
                              color: isOvertime ? errorColor : accentColor,
                              strokeWidth: 20,
                              strokeCap: StrokeCap.round,
                              gradientColors:
                                  isOvertime
                                      ? [
                                        errorColor,
                                        errorColor.withAlpha(
                                          (255 * 0.7).round(),
                                        ),
                                      ]
                                      : [accentColor, colorScheme.tertiary],
                              withGlow: true,
                              rotation: _controller.value * 2 * math.pi,
                              glowOpacity:
                                  0.3 +
                                  0.2 *
                                      math.sin(
                                        _controller.value * 2 * math.pi,
                                      ), // Pulse between 0.3 and 0.5
                            ),
                          );
                        },
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            displayTime,
                            style: Theme.of(
                              context,
                            ).textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 72,
                              color: timerColor,
                              letterSpacing: -2.0,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: (isOvertime ? errorColor : accentColor)
                                  .withAlpha((255 * 0.1).round()),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getStatusText(context, widget.sessionType),
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                color: isOvertime ? errorColor : accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                if (!isRunning)
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: FilledButton(
                      onPressed: widget.onStart,
                      style: FilledButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 8,
                        shadowColor: accentColor.withAlpha((255 * 0.4).round()),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      child: Text(context.tr('focus.start').toUpperCase()),
                    ),
                  )
                else if (widget.sessionType == SessionTypeEnum.shortBreak ||
                    widget.sessionType == SessionTypeEnum.longBreak)
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 64,
                          child: FilledButton(
                            onPressed: widget.onStart,
                            style: FilledButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: colorScheme.onPrimary,
                              elevation: 8,
                              shadowColor: accentColor.withAlpha(
                                (255 * 0.4).round(),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: Text(
                              context.tr('focus.start').toUpperCase(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 64,
                          child: OutlinedButton(
                            onPressed: widget.onTerminate,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textColor.withAlpha(
                                (255 * 0.8).round(),
                              ),
                              side: BorderSide(
                                color: colorScheme.outline.withAlpha(
                                  (255 * 0.3).round(),
                                ),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
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
                          height: 64,
                          child: FilledButton(
                            onPressed: widget.onBreak,
                            style: FilledButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: colorScheme.onPrimary,
                              elevation: 8,
                              shadowColor: accentColor.withAlpha(
                                (255 * 0.4).round(),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: Text(
                              context.tr('focus.break').toUpperCase(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 64,
                          child: OutlinedButton(
                            onPressed: widget.onTerminate,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textColor.withAlpha(
                                (255 * 0.8).round(),
                              ),
                              side: BorderSide(
                                color: colorScheme.outline.withAlpha(
                                  (255 * 0.3).round(),
                                ),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
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
  final List<Color>? gradientColors;
  final bool withGlow;
  final double rotation;
  final double glowOpacity;

  _TimerPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 8,
    this.strokeCap = StrokeCap.butt,
    this.gradientColors,
    this.withGlow = false,
    this.rotation = 0.0,
    this.glowOpacity = 0.4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint =
        Paint()
          ..strokeWidth = strokeWidth
          ..strokeCap = strokeCap
          ..style = PaintingStyle.stroke;

    if (gradientColors != null && gradientColors!.isNotEmpty) {
      paint.shader = SweepGradient(
        colors: gradientColors!,
        startAngle: -math.pi / 2 + rotation,
        endAngle: 2 * math.pi - math.pi / 2 + rotation,
        tileMode: TileMode.repeated,
        transform: GradientRotation(rotation),
      ).createShader(rect);
    } else {
      paint.color = color;
    }

    if (withGlow) {
      final glowPaint =
          Paint()
            ..strokeWidth = strokeWidth
            ..strokeCap = strokeCap
            ..style = PaintingStyle.stroke
            ..color = (gradientColors?.first ?? color).withAlpha(
              (glowOpacity * 255).round(),
            )
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        glowPaint,
      );
    }

    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, paint);
  }

  @override
  bool shouldRepaint(_TimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gradientColors != gradientColors ||
        oldDelegate.withGlow != withGlow ||
        oldDelegate.rotation != rotation ||
        oldDelegate.glowOpacity != glowOpacity;
  }
}
