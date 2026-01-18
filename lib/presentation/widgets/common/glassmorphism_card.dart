import 'dart:ui';
import 'package:flutter/material.dart';

/// A beautiful glassmorphism card widget with frosted glass effect
class GlassmorphismCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<Color>? borderGradientColors;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const GlassmorphismCard({
    super.key,
    required this.child,
    this.blur = 10,
    this.opacity = 0.1,
    this.borderRadius,
    this.padding,
    this.margin,
    this.borderGradientColors,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBorderRadius = BorderRadius.circular(20);
    final effectiveBorderRadius = borderRadius ?? defaultBorderRadius;

    return Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (isDark ? Colors.white : Colors.white)
                        .withOpacity(opacity + 0.05),
                    (isDark ? Colors.white : Colors.white).withOpacity(opacity),
                  ],
                ),
                borderRadius: effectiveBorderRadius,
                border: borderGradientColors != null
                    ? null
                    : Border.all(
                        color: (isDark ? Colors.white : Colors.white)
                            .withOpacity(0.2),
                        width: 1.5,
                      ),
              ),
              foregroundDecoration: borderGradientColors != null
                  ? BoxDecoration(
                      borderRadius: effectiveBorderRadius,
                      border: GradientBorder(
                        gradient: LinearGradient(
                          colors: borderGradientColors!,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        width: 2,
                      ),
                    )
                  : null,
              child: Padding(
                padding: padding ?? const EdgeInsets.all(20),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom gradient border decoration
class GradientBorder extends BoxBorder {
  final Gradient gradient;
  final double width;

  const GradientBorder({
    required this.gradient,
    this.width = 1.0,
  });

  @override
  BorderSide get bottom => BorderSide.none;

  @override
  BorderSide get top => BorderSide.none;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  bool get isUniform => true;

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    final Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    if (borderRadius != null) {
      canvas.drawRRect(
        borderRadius.toRRect(rect).deflate(width / 2),
        paint,
      );
    } else {
      canvas.drawRect(rect.deflate(width / 2), paint);
    }
  }

  @override
  ShapeBorder scale(double t) {
    return GradientBorder(
      gradient: gradient,
      width: width * t,
    );
  }
}

/// Enhanced glassmorphism card with shimmer effect
class GlassmorphismCardAnimated extends StatefulWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool enableShimmer;

  const GlassmorphismCardAnimated({
    super.key,
    required this.child,
    this.blur = 10,
    this.opacity = 0.1,
    this.borderRadius,
    this.padding,
    this.margin,
    this.onTap,
    this.enableShimmer = false,
  });

  @override
  State<GlassmorphismCardAnimated> createState() =>
      _GlassmorphismCardAnimatedState();
}

class _GlassmorphismCardAnimatedState extends State<GlassmorphismCardAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.enableShimmer) {
      _controller.repeat();
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
    final defaultBorderRadius = BorderRadius.circular(20);
    final effectiveBorderRadius = widget.borderRadius ?? defaultBorderRadius;

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          margin: widget.margin ?? const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: effectiveBorderRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: widget.blur,
                sigmaY: widget.blur,
              ),
              child: GestureDetector(
                onTap: widget.onTap,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        (isDark ? Colors.white : Colors.white)
                            .withOpacity(widget.opacity + 0.05),
                        (isDark ? Colors.white : Colors.white)
                            .withOpacity(widget.opacity),
                      ],
                    ),
                    borderRadius: effectiveBorderRadius,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: widget.padding ?? const EdgeInsets.all(20),
                        child: widget.child,
                      ),
                      if (widget.enableShimmer)
                        Positioned.fill(
                          child: ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0),
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0),
                                ],
                                stops: [
                                  _shimmerAnimation.value - 0.3,
                                  _shimmerAnimation.value,
                                  _shimmerAnimation.value + 0.3,
                                ].map((s) => s.clamp(0.0, 1.0)).toList(),
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.srcOver,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: effectiveBorderRadius,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
