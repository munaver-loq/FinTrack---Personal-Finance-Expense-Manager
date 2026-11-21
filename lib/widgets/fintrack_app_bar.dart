import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../state/finance_state.dart';
import 'account_switcher_sheet.dart';
import 'create_account_sheet.dart';
import 'user_avatar_view.dart';

class FinTrackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String subtitle;
  final bool showBackButton;
  final VoidCallback? onBack;
  final FinanceState? state;

  const FinTrackAppBar({
    super.key,
    required this.subtitle,
    this.showBackButton = false,
    this.onBack,
    this.state,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.90),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 12,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Back button or Logo + Title
              Expanded(
                child: Row(
                  children: [
                    if (showBackButton) ...[
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.onSurface,
                          size: 24,
                        ),
                        onPressed: onBack ?? () => Navigator.maybePop(context),
                        splashRadius: 24,
                      ),
                      const SizedBox(width: 4),
                    ],
                    // Custom Vector FinTrack Brand Mark
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x5500B4D8),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/fintrack_logo_128.png',
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.primary, AppColors.secondaryContainer],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.auto_graph_rounded,
                                  color: AppColors.surfaceContainerLowest,
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FinTrack',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            subtitle,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Right: Notifications & Profile
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.onSurfaceVariant,
                      size: 22,
                    ),
                    splashRadius: 22,
                    onPressed: () {
                      _showNotificationsDialog(context);
                    },
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      if (state != null) {
                        if (state!.hasAccount) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: AppColors.surface,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            ),
                            builder: (_) => AccountSwitcherSheet(state: state!),
                          );
                        } else {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: AppColors.surfaceContainerHigh,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            ),
                            builder: (_) => CreateAccountSheet(state: state!),
                          );
                        }
                      } else {
                        _showProfileModal(context);
                      }
                    },
                    child: UserAvatarView(
                      photoUrl: state != null ? state!.currentProfile.photoUrl : 'assets/images/avatar_alex.png',
                      size: 34,
                      borderColor: AppColors.primary,
                      borderWidth: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildNotificationItem(
              icon: Icons.warning_amber_rounded,
              color: AppColors.alertWarning,
              title: 'Food & Dining at 88%',
              subtitle: 'Approaching monthly ceiling of \$880.00',
              time: '10m ago',
            ),
            const SizedBox(height: 10),
            _buildNotificationItem(
              icon: Icons.check_circle_outline_rounded,
              color: AppColors.tertiary,
              title: 'SQLite Auto-Backup Completed',
              subtitle: '1,248 records safely synchronized offline',
              time: '1h ago',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleMedium.copyWith(fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.bodySmall),
              ],
            ),
          ),
          Text(time, style: AppTypography.labelSmall.copyWith(color: AppColors.outline)),
        ],
      ),
    );
  }

  void _showProfileModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/avatar_alex.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alex Nomad',
                      style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'alex.nomad@fintrack.app',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'LOCAL PRO TIER • ACTIVE',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.tertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderStroke),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.storage_rounded, color: AppColors.tertiary, size: 20),
                      SizedBox(width: 10),
                      Text('Database Records: 1,248', style: TextStyle(color: AppColors.onSurface)),
                    ],
                  ),
                  Text('Encrypted', style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerHighest,
                  foregroundColor: AppColors.onSurface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
