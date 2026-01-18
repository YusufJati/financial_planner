import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../../app/themes/colors.dart';
import '../../../app/themes/spacing.dart';

class CreditScoreScreen extends StatelessWidget {
  const CreditScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Credit Score',
          style: GoogleFonts.spaceMono(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xl),
            // Credit Score Gauge
            const CreditScoreGauge(
              score: 660,
              minScore: 400,
              maxScore: 850,
              status: 'Good',
              pointsChange: 6,
              lastUpdate: '20 Jul 2020',
            ),
            const SizedBox(height: AppSpacing.xxl),
            // Credit Details Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildCreditDetailItem(
                    title: 'On-time patments',
                    status: 'Good',
                    statusColor: AppColors.good,
                    value: '95%',
                    subValue: '1 missed',
                    showDivider: true,
                  ),
                  _buildCreditDetailItem(
                    title: 'Credit Utilization',
                    status: 'Not bad',
                    statusColor: AppColors.notBad,
                    value: '95%',
                    subValue: '-15%',
                    subValueColor: AppColors.notBad,
                    showDivider: true,
                  ),
                  _buildCreditDetailItem(
                    title: 'Age of credit',
                    status: 'Good',
                    statusColor: AppColors.good,
                    value: '8 year',
                    showDivider: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditDetailItem({
    required String title,
    required String status,
    required Color statusColor,
    required String value,
    String? subValue,
    Color? subValueColor,
    required bool showDivider,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              )
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.spaceMono(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                status,
                style: GoogleFonts.spaceMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.spaceMono(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subValue != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subValue,
                  style: GoogleFonts.spaceMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: subValueColor ?? AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class CreditScoreGauge extends StatelessWidget {
  final int score;
  final int minScore;
  final int maxScore;
  final String status;
  final int pointsChange;
  final String lastUpdate;

  const CreditScoreGauge({
    super.key,
    required this.score,
    required this.minScore,
    required this.maxScore,
    required this.status,
    required this.pointsChange,
    required this.lastUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(280, 180),
                painter: CreditScoreGaugePainter(
                  score: score,
                  minScore: minScore,
                  maxScore: maxScore,
                ),
              ),
              Positioned(
                top: 60,
                child: Column(
                  children: [
                    Text(
                      status,
                      style: GoogleFonts.spaceMono(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      score.toString(),
                      style: GoogleFonts.spaceMono(
                        fontSize: 64,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '+${pointsChange}pts',
                      style: GoogleFonts.spaceMono(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Min/Max labels and last update
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                minScore.toString(),
                style: GoogleFonts.spaceMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Last update on $lastUpdate',
                style: GoogleFonts.spaceMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                maxScore.toString(),
                style: GoogleFonts.spaceMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CreditScoreGaugePainter extends CustomPainter {
  final int score;
  final int minScore;
  final int maxScore;

  CreditScoreGaugePainter({
    required this.score,
    required this.minScore,
    required this.maxScore,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 20;
    const strokeWidth = 16.0;

    // Calculate the percentage of the score
    final percentage = (score - minScore) / (maxScore - minScore);

    // Background arc (gray)
    final backgroundPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      backgroundPaint,
    );

    // Create gradient for the score arc
    // Purple -> Cyan -> Gray segments
    final scorePercentage = percentage.clamp(0.0, 1.0);

    // Draw colored segments
    // Purple segment (0 - 40%)
    if (scorePercentage > 0) {
      final purplePaint = Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final purpleEnd = math.min(scorePercentage, 0.4) * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi,
        purpleEnd,
        false,
        purplePaint,
      );
    }

    // Cyan segment (40% - 70%)
    if (scorePercentage > 0.4) {
      final cyanPaint = Paint()
        ..color = const Color(0xFF06B6D4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final cyanEnd = (math.min(scorePercentage, 0.7) - 0.4) * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi + 0.4 * math.pi,
        cyanEnd,
        false,
        cyanPaint,
      );
    }

    // Light purple segment (70% - 100%)
    if (scorePercentage > 0.7) {
      final lightPurplePaint = Paint()
        ..color = AppColors.primaryLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final lightPurpleEnd = (scorePercentage - 0.7) * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi + 0.7 * math.pi,
        lightPurpleEnd,
        false,
        lightPurplePaint,
      );
    }

    // Draw end caps (decorative circles at the ends)
    final startCapPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final startX = center.dx - radius;
    final startY = center.dy;
    canvas.drawCircle(Offset(startX, startY), strokeWidth / 2, startCapPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
