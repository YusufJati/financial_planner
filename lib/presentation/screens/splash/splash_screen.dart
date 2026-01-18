import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/themes/colors.dart';
import '../../../app/themes/radius.dart';
import '../../../app/themes/spacing.dart';
import '../../../app/themes/text_styles.dart';
import '../../widgets/common/app_background.dart';
import '../../widgets/common/typewriter_text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _lineController;
  late Animation<double> _lineAnimation;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _lineAnimation =
        CurvedAnimation(parent: _lineController, curve: Curves.easeInOut);

    _navTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        context.go('/');
      }
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _lineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final trackColor = isDark ? AppColors.borderDark : AppColors.border;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TypewriterText(
                  text: 'FINANCIAL PLANNER',
                  style: AppTextStyles.h1.copyWith(
                    color: textColor,
                    letterSpacing: 1.2,
                  ),
                  charDelay: const Duration(milliseconds: 60),
                  startDelay: const Duration(milliseconds: 200),
                  showCursor: true,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Pencatat keuangan offline',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: mutedColor,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _LoadingLine(
                  animation: _lineAnimation,
                  trackColor: trackColor,
                  barColor: textColor,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'memuat',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: mutedColor,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingLine extends StatelessWidget {
  final Animation<double> animation;
  final Color trackColor;
  final Color barColor;

  const _LoadingLine({
    required this.animation,
    required this.trackColor,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 8,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          return ClipRRect(
            borderRadius: AppRadius.radiusFull,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final barWidth = width * 0.3;
                final travel = width - barWidth;
                final left = travel * animation.value;
                return Stack(
                  children: [
                    Container(color: trackColor),
                    Positioned(
                      left: left,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: barWidth,
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: AppRadius.radiusFull,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
