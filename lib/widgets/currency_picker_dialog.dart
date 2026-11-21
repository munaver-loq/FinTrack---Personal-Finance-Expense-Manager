import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/user_profile_model.dart';
import '../state/finance_state.dart';

class CurrencyPickerSheet extends StatelessWidget {
  final FinanceState state;

  const CurrencyPickerSheet({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
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
                  const Icon(Icons.currency_exchange_rounded, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Select Global Currency',
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
          const SizedBox(height: 8),
          Text(
            'Currency mode updates all ledgers, budgets, and balance figures instantly.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 14),

          // Currency options list
          SizedBox(
            height: 340,
            child: ListView.separated(
              itemCount: SupportedCurrencies.all.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final curr = SupportedCurrencies.all[index];
                final isSelected = state.currencyCode == curr.code;

                return InkWell(
                  onTap: () {
                    state.setCurrency(curr.code, curr.symbol);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.surfaceContainerHigh,
                        content: Text(
                          'Currency updated to ${curr.name} (${curr.symbol} ${curr.code})',
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.borderStroke,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(curr.flag, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  curr.name,
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: AppColors.onSurface,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${curr.code} • Symbol: ${curr.symbol}',
                                  style: AppTypography.bodySmall.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22)
                        else
                          Text(
                            curr.symbol,
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.outline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
