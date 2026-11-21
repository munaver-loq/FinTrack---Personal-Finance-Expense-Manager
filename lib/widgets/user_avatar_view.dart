import 'dart:io';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class UserAvatarView extends StatelessWidget {
  final String photoUrl;
  final double size;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  const UserAvatarView({
    super.key,
    required this.photoUrl,
    this.size = 48,
    this.borderColor,
    this.borderWidth = 1.5,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatarContent = _buildContent();

    Widget container = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
      child: ClipOval(child: avatarContent),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: container);
    }
    return container;
  }

  Widget _buildContent() {
    // 1. Presets
    if (photoUrl.startsWith('preset_')) {
      return _buildPreset(photoUrl);
    }

    // 2. Bundled Assets
    if (photoUrl.startsWith('assets/')) {
      return Image.asset(
        photoUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }

    // 3. Mobile Device Local Photo file
    try {
      final file = File(photoUrl);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      }
    } catch (_) {
      // Ignored, proceed to fallback
    }

    return _buildFallback();
  }

  Widget _buildPreset(String preset) {
    Color startColor;
    Color endColor;

    switch (preset) {
      case 'preset_emerald':
        startColor = const Color(0xFF00C853);
        endColor = const Color(0xFF00E676);
        break;
      case 'preset_violet':
        startColor = const Color(0xFF7C4DFF);
        endColor = const Color(0xFF651FFF);
        break;
      case 'preset_amber':
        startColor = const Color(0xFFFFAB00);
        endColor = const Color(0xFFFFD600);
        break;
      case 'preset_cyan':
      default:
        startColor = AppColors.primary;
        endColor = AppColors.secondaryContainer;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          color: AppColors.surfaceContainerLowest,
          size: size * 0.55,
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.20),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          color: AppColors.primary,
          size: size * 0.55,
        ),
      ),
    );
  }
}
