import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/category_budget_model.dart';

class BudgetLimitModal extends StatefulWidget {
  final CategoryBudgetModel budget;
  final Function(double newLimit, double newThreshold) onSave;
  final String currencySymbol;

  const BudgetLimitModal({
    super.key,
    required this.budget,
    required this.onSave,
    this.currencySymbol = r'$',
  });

  @override
  State<BudgetLimitModal> createState() => _BudgetLimitModalState();
}

class _BudgetLimitModalState extends State<BudgetLimitModal> {
  late TextEditingController _ceilingController;
  late double _threshold;

  @override
  void initState() {
    super.initState();
    _ceilingController = TextEditingController(
      text: widget.budget.limit.toStringAsFixed(0),
    );
    _threshold = widget.budget.thresholdPercent;
  }

  @override
  void dispose() {
    _ceilingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune_rounded, color: AppColors.alertDanger, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Adjust ${widget.budget.name} Limit',
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
            'Modify your monthly threshold to accommodate dining shifts without triggering alert fatigue.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),

          // Ceiling Input
          Text(
            'New Monthly Ceiling (${widget.currencySymbol})',
            style: AppTypography.labelLarge.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderStroke),
            ),
            child: TextField(
              controller: _ceilingController,
              keyboardType: TextInputType.number,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                prefixText: '${widget.currencySymbol}  ',
                prefixStyle: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Threshold Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Threshold Alert Trigger',
                style: AppTypography.labelLarge.copyWith(color: AppColors.onSurface),
              ),
              Text(
                '${_threshold.toInt()}%',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.surfaceContainerLowest,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: _threshold,
              min: 50,
              max: 95,
              divisions: 45,
              onChanged: (val) {
                setState(() {
                  _threshold = val;
                });
              },
            ),
          ),
          const SizedBox(height: 24),

          // Actions
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainer,
                      foregroundColor: AppColors.onSurface,
                      side: const BorderSide(color: AppColors.borderStroke),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.onPrimaryContainer,
                      elevation: 4,
                      shadowColor: const Color(0x6600B4D8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      final newLimit = double.tryParse(_ceilingController.text) ?? widget.budget.limit;
                      widget.onSave(newLimit, _threshold);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Save Limit',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
