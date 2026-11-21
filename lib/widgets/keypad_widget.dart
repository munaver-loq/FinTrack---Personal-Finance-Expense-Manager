import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class CustomKeypad extends StatelessWidget {
  final ValueChanged<String> onKeyPressed;
  final VoidCallback onBackspacePressed;

  const CustomKeypad({
    super.key,
    required this.onKeyPressed,
    required this.onBackspacePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildKey('1'),
              const SizedBox(width: 6),
              _buildKey('2'),
              const SizedBox(width: 6),
              _buildKey('3'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildKey('4'),
              const SizedBox(width: 6),
              _buildKey('5'),
              const SizedBox(width: 6),
              _buildKey('6'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildKey('7'),
              const SizedBox(width: 6),
              _buildKey('8'),
              const SizedBox(width: 6),
              _buildKey('9'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildKey('.'),
              const SizedBox(width: 6),
              _buildKey('0'),
              const SizedBox(width: 6),
              _buildBackspaceKey(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String value) {
    return Expanded(
      child: Material(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: AppColors.primary.withValues(alpha: 0.20),
          highlightColor: AppColors.primary.withValues(alpha: 0.10),
          onTap: () {
            HapticFeedback.selectionClick();
            onKeyPressed(value);
          },
          child: Container(
            height: 52,
            alignment: Alignment.center,
            child: Text(
              value,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return Expanded(
      child: Material(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: AppColors.alertDanger.withValues(alpha: 0.20),
          highlightColor: AppColors.alertDanger.withValues(alpha: 0.10),
          onTap: () {
            HapticFeedback.mediumImpact();
            onBackspacePressed();
          },
          child: Container(
            height: 52,
            alignment: Alignment.center,
            child: const Icon(
              Icons.backspace_outlined,
              color: AppColors.onSurface,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
