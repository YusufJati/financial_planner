import 'package:flutter/material.dart';
import '../../../app/themes/colors.dart';

/// Animated gradient progress bar widget
class GradientProgressBar extends StatefulWidget {
  final double progress;
  final double height;
  final List<Color>? gradientColors;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Duration animationDuration;
  final bool showPercentage;
  final bool showGlow;
  final String? label;

  const GradientProgressBar({
    super.key,
    required this.progress,
    this.height = 12,
    this.gradientColors,
    this.backgroundColor,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.showPercentage = false,
    this.showGlow = true,
    this.label,
  });

  @override
  State<GradientProgressBar> createState() => _GradientProgressBarState();
}

class _GradientProgressBarState extends State<GradientProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(GradientProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBorderRadius =
        widget.borderRadius ?? BorderRadius.circular(widget.height / 2);
    final gradientColors = widget.gradientColors ??
        [
          AppColors.primary,
          AppColors.primaryLight,
        ];
    final backgroundColor = widget.backgroundColor ??
        (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label!,
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.showPercentage)
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Text(
                      '${(_progressAnimation.value * 100).toInt()}%',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                // Background
                Container(
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: effectiveBorderRadius,
                  ),
                ),
                // Progress
                FractionallySizedBox(
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    height: widget.height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: effectiveBorderRadius,
                      boxShadow: widget.showGlow
                          ? [
                              BoxShadow(
                                color: gradientColors.last
                                    .withOpacity(_glowAnimation.value),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
                // Shimmer effect
                if (_progressAnimation.value > 0)
                  FractionallySizedBox(
                    widthFactor: _progressAnimation.value,
                    child: Container(
                      height: widget.height,
                      decoration: BoxDecoration(
                        borderRadius: effectiveBorderRadius,
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white.withOpacity(0),
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        if (widget.showPercentage && widget.label == null) ...[
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Text(
                '${(_progressAnimation.value * 100).toInt()}%',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

/// Circular progress with gradient
class GradientCircularProgress extends StatefulWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final List<Color>? gradientColors;
  final Color? backgroundColor;
  final Widget? child;
  final Duration animationDuration;

  const GradientCircularProgress({
    super.key,
    required this.progress,
    this.size = 100,
    this.strokeWidth = 8,
    this.gradientColors,
    this.backgroundColor,
    this.child,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<GradientCircularProgress> createState() =>
      _GradientCircularProgressState();
}

class _GradientCircularProgressState extends State<GradientCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(GradientCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = widget.gradientColors ??
        [
          AppColors.primary,
          AppColors.primaryLight,
        ];
    final backgroundColor = widget.backgroundColor ??
        (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200);

    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _GradientCircularPainter(
                  progress: _progressAnimation.value,
                  strokeWidth: widget.strokeWidth,
                  gradientColors: gradientColors,
                  backgroundColor: backgroundColor,
                ),
              ),
              if (widget.child != null) widget.child!,
            ],
          ),
        );
      },
    );
  }
}

class _GradientCircularPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final List<Color> gradientColors;
  final Color backgroundColor;

  _GradientCircularPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradientColors,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Gradient progress arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: -1.5708, // -90 degrees
      endAngle: 4.7124, // 270 degrees
      colors: gradientColors,
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -1.5708, // Start from top (-90 degrees)
      progress * 2 * 3.14159, // Progress in radians
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GradientCircularPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
