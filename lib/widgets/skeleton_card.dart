import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A shimmer block drawn entirely with a custom painter — no third-party package.
class _ShimmerPainter extends CustomPainter {
  final double progress;

  const _ShimmerPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(6),
    );

    // Base fill
    canvas.drawRRect(rrect, Paint()..color = AppColors.shimmerBase);

    // Moving gradient overlay
    final shimmerRect = Rect.fromLTWH(
      -size.width + (size.width * 2 * progress),
      0,
      size.width * 2,
      size.height,
    );

    final shader = const LinearGradient(
      colors: [
        AppColors.shimmerBase,
        AppColors.shimmerHigh,
        AppColors.shimmerBase,
      ],
      stops: [0.0, 0.5, 1.0],
    ).createShader(shimmerRect);

    canvas.drawRRect(rrect, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) => old.progress != progress;
}

/// A single skeleton placeholder card that mirrors PostCard's geometry.
class SkeletonCard extends StatefulWidget {
  final Duration delay;

  const SkeletonCard({super.key, this.delay = Duration.zero});

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _anim = Tween<double>(begin: 0.0, end: 1.0).animate(_ctrl);

    if (widget.delay == Duration.zero) {
      _ctrl.repeat();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _ctrl.repeat();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _block(double width, double height) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (ctx, child) => CustomPaint(
        painter: _ShimmerPainter(_anim.value),
        child: SizedBox(width: width, height: height),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge placeholder
            _block(42, 42),
            const SizedBox(width: 12),
            // Text placeholders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _block(double.infinity, 14),
                  const SizedBox(height: 8),
                  _block(screenW * 0.55, 14),
                  const SizedBox(height: 12),
                  _block(double.infinity, 11),
                  const SizedBox(height: 6),
                  _block(screenW * 0.4, 11),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
