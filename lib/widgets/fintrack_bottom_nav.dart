import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class FinTrackBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAddPressed;

  const FinTrackBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xEE080E1B),
        boxShadow: [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Overview Tab
              _buildNavItem(
                index: 0,
                icon: Icons.account_balance_wallet_rounded,
                label: 'Overview',
              ),

              // 2. Analytics Tab
              _buildNavItem(
                index: 1,
                icon: Icons.query_stats_rounded,
                label: 'Analytics',
              ),

              // 3. Center Elevated FAB (+)
              GestureDetector(
                onTap: onAddPressed,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 52,
                  height: 52,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x7300B4D8),
                        blurRadius: 18,
                        spreadRadius: 2,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_rounded,
                      color: AppColors.onPrimaryContainer,
                      size: 30,
                    ),
                  ),
                ),
              ),

              // 4. Budgets Tab
              _buildNavItem(
                index: 2,
                icon: Icons.donut_large_rounded,
                label: 'Budgets',
              ),

              // 5. Settings Tab
              _buildNavItem(
                index: 3,
                icon: Icons.settings_rounded,
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: () => onTabSelected(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
