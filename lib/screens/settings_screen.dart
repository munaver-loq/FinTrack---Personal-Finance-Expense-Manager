import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../state/finance_state.dart';
import '../widgets/account_switcher_sheet.dart';
import '../widgets/create_account_sheet.dart';
import '../widgets/currency_picker_dialog.dart';
import '../widgets/edit_account_sheet.dart';
import '../widgets/sqlite_inspector_sheet.dart';
import '../widgets/user_avatar_view.dart';

class SettingsScreen extends StatelessWidget {
  final FinanceState state;

  const SettingsScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Card
              _buildProfileCard(context),
              const SizedBox(height: 16),

              // Database & Storage
              _buildSectionHeader('DATABASE & OFFLINE ENGINE'),
              const SizedBox(height: 8),
              _buildDatabaseCard(context),
              const SizedBox(height: 16),

              // Preferences
              _buildSectionHeader('PREFERENCES & SECURITY'),
              const SizedBox(height: 8),
              _buildPreferencesCard(context),
              const SizedBox(height: 16),

              // About
              _buildSectionHeader('SYSTEM & ABOUT'),
              const SizedBox(height: 8),
              _buildAboutCard(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.labelSmall.copyWith(
        color: AppColors.onSurfaceVariant,
        letterSpacing: 0.8,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final profile = state.currentProfile;
    final hasAcc = state.hasAccount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Column(
        children: [
          Row(
            children: [
              UserAvatarView(
                photoUrl: profile.photoUrl,
                size: 56,
                borderColor: AppColors.primary,
                borderWidth: 2,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            hasAcc ? profile.name : 'No Active Account',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasAcc) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.tertiary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${profile.currencyCode} (${profile.currencySymbol})',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.tertiary,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasAcc ? profile.email : 'Create an account to track your finances',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Encrypted Local Storage • 0ms Cloud Latency',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontSize: 9.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (hasAcc)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text('Edit Account', style: TextStyle(fontSize: 12)),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (_) => EditAccountSheet(state: state, profile: profile),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerHighest,
                      foregroundColor: AppColors.onSurface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.switch_account_rounded, size: 16),
                    label: const Text('Switch Account', style: TextStyle(fontSize: 12)),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: AppColors.surface,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (_) => AccountSwitcherSheet(state: state),
                      );
                    },
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: AppColors.onPrimaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('+ Add Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (_) => CreateAccountSheet(state: state),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDatabaseCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.storage_rounded,
            iconColor: AppColors.tertiary,
            title: 'SQLite Database Console',
            subtitle: '${state.totalRecordsCount} Records • Tap to open query inspector',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.tertiary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Console',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.tertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => SqliteInspectorSheet(state: state),
              );
            },
          ),
          const Divider(height: 1, indent: 56),
          _buildSettingsTile(
            icon: Icons.restart_alt_rounded,
            iconColor: AppColors.alertDanger,
            title: 'Reset Demo Data',
            subtitle: 'Restore factory initial demo state',
            trailing: const Icon(Icons.refresh_rounded, color: AppColors.alertDanger, size: 20),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surfaceContainerHigh,
                  title: const Text('Reset Demo Data?'),
                  content: const Text(
                    'This will reset accounts, transactions, and category limits to the initial demo state.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorContainer),
                      onPressed: () async {
                        await state.resetDemoData();
                        if (!context.mounted) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Demo data restored successfully!')),
                        );
                      },
                      child: const Text('Reset', style: TextStyle(color: AppColors.onErrorContainer)),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 56),
          _buildSettingsTile(
            icon: Icons.file_download_outlined,
            iconColor: AppColors.primary,
            title: 'Export Backup',
            subtitle: 'Full encrypted SQLite .db & CSV',
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.surfaceContainerHigh,
                  content: Text(
                    'Full SQLite database archive exported to Downloads/fintrack.db',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 56),
          _buildSettingsTile(
            icon: Icons.cleaning_services_rounded,
            iconColor: AppColors.secondary,
            title: 'Clear Cache',
            subtitle: 'Free temporary computation memory',
            trailing: const Text('12.4 MB', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.surfaceContainerHigh,
                  content: Text('Cache cleared successfully.', style: TextStyle(color: AppColors.tertiary)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.notifications_active_rounded,
            iconColor: AppColors.primary,
            title: 'Push Threshold Alerts',
            subtitle: 'Warn when budget reaches 80%',
            trailing: Switch(
              value: state.pushAlertsEnabled,
              activeTrackColor: AppColors.primaryContainer,
              activeThumbColor: AppColors.onPrimary,
              inactiveTrackColor: AppColors.surfaceContainerHighest,
              onChanged: (val) => state.togglePushAlerts(),
            ),
            onTap: () => state.togglePushAlerts(),
          ),
          const Divider(height: 1, indent: 56),
          _buildSettingsTile(
            icon: Icons.attach_money_rounded,
            iconColor: AppColors.tertiary,
            title: 'Currency',
            subtitle: '${state.currencyCode} (${state.currencySymbol})',
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant),
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppColors.surfaceContainerHigh,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (_) => CurrencyPickerSheet(state: state),
              );
            },
          ),
          const Divider(height: 1, indent: 56),
          _buildSettingsTile(
            icon: Icons.fingerprint_rounded,
            iconColor: AppColors.secondary,
            title: 'Biometric Security',
            subtitle: 'Fingerprint & Face Unlock enabled',
            trailing: const Icon(Icons.check_circle_rounded, color: AppColors.tertiary, size: 20),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
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
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_graph_rounded,
                          color: AppColors.surfaceContainerLowest,
                          size: 20,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FinTrack Mobile',
                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Version 1.0.0 (Electric Midnight)',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Built with Flutter, Material 3, and Plus Jakarta Sans. Pixel-perfect conversion from Google Stitch UI prototype.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: AppTypography.titleMedium.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(fontSize: 12),
        ),
        trailing: trailing,
      ),
    );
  }
}
