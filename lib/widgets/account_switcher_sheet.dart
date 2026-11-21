import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../state/finance_state.dart';
import 'create_account_sheet.dart';
import 'edit_account_sheet.dart';
import 'user_avatar_view.dart';

class AccountSwitcherSheet extends StatelessWidget {
  final FinanceState state;

  const AccountSwitcherSheet({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final profiles = state.userProfiles;
        final current = state.currentProfile;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.switch_account_rounded, color: AppColors.primary, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Switch Account',
                        style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Account profiles list
              ...profiles.map((profile) {
                final isCurrent = profile.id == current.id;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isCurrent ? AppColors.surfaceContainerHigh : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCurrent ? AppColors.primary : AppColors.borderStroke,
                      width: isCurrent ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    onTap: () {
                      state.switchProfile(profile.id);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.surfaceContainerHigh,
                          content: Text(
                            'Switched to ${profile.name} (${profile.currencyCode} ${profile.currencySymbol})',
                            style: const TextStyle(color: AppColors.primary),
                          ),
                        ),
                      );
                    },
                    leading: UserAvatarView(
                      photoUrl: profile.photoUrl,
                      size: 44,
                      borderColor: isCurrent ? AppColors.primary : AppColors.outlineVariant,
                      borderWidth: 2,
                    ),
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.name,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.tertiary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            profile.currencyCode,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.tertiary,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      profile.email,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Edit Profile Icon
                        IconButton(
                          tooltip: 'Edit Profile',
                          icon: const Icon(Icons.edit_outlined, size: 19, color: AppColors.primary),
                          onPressed: () {
                            Navigator.pop(context); // close switcher
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
                        if (isCurrent)
                          const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22)
                        else
                          const Icon(Icons.radio_button_unchecked_rounded, color: AppColors.outline, size: 22),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 10),

              // Create Account CTA Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.person_add_rounded, size: 20),
                  label: const Text(
                    '+ Create New Account',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // close switcher
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
      },
    );
  }
}
