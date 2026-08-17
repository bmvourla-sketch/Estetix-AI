import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Decorative Aura Dark background with soft emerald/purple glow blobs.
///
/// Placed behind [GlassCard]s so their `BackdropFilter` has something colorful
/// to blur.
class AuraBackground extends StatelessWidget {
  const AuraBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -120,
            right: -80,
            child: _GlowBlob(
              size: 320,
              color: AppColors.purple.withValues(alpha: 0.28),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -100,
            child: _GlowBlob(
              size: 360,
              color: AppColors.emerald.withValues(alpha: 0.25),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
