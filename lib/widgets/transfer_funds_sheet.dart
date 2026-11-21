import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../services/mock_database_service.dart';

class TransferFundsSheet extends StatefulWidget {
  final List<AccountBalance> accounts;
  final Function({
    required String fromId,
    required String toId,
    required double amount,
  }) onTransfer;

  const TransferFundsSheet({
    super.key,
    required this.accounts,
    required this.onTransfer,
  });

  @override
  State<TransferFundsSheet> createState() => _TransferFundsSheetState();
}

class _TransferFundsSheetState extends State<TransferFundsSheet> {
  late String _fromAccountId;
  late String _toAccountId;
  final TextEditingController _amountController = TextEditingController(text: '150.00');

  @override
  void initState() {
    super.initState();
    _fromAccountId = widget.accounts.isNotEmpty ? widget.accounts.first.id : 'acc_checking';
    _toAccountId = widget.accounts.length > 1 ? widget.accounts[1].id : 'acc_savings';
  }

  @override
  void dispose() {
    _amountController.dispose();
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.sync_alt_rounded, color: AppColors.secondary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Transfer Between Accounts',
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

          // From Account Dropdown
          Text('From Account', style: AppTypography.labelMedium.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderStroke),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _fromAccountId,
                isExpanded: true,
                dropdownColor: AppColors.surfaceContainerHigh,
                style: const TextStyle(color: AppColors.onSurface),
                items: widget.accounts.map((a) {
                  return DropdownMenuItem(
                    value: a.id,
                    child: Text('${a.name} (\$${a.balance.toStringAsFixed(2)})'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _fromAccountId = val;
                      if (_toAccountId == val) {
                        _toAccountId = widget.accounts.firstWhere((a) => a.id != val).id;
                      }
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // To Account Dropdown
          Text('To Account', style: AppTypography.labelMedium.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderStroke),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _toAccountId,
                isExpanded: true,
                dropdownColor: AppColors.surfaceContainerHigh,
                style: const TextStyle(color: AppColors.onSurface),
                items: widget.accounts.map((a) {
                  return DropdownMenuItem(
                    value: a.id,
                    child: Text('${a.name} (\$${a.balance.toStringAsFixed(2)})'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _toAccountId = val;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Amount
          Text('Amount (\$)', style: AppTypography.labelMedium.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderStroke),
            ),
            child: TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
              decoration: const InputDecoration(
                prefixText: '\$  ',
                prefixStyle: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 18),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryContainer,
                foregroundColor: AppColors.onSecondaryContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final amt = double.tryParse(_amountController.text) ?? 0.0;
                if (amt <= 0) return;
                widget.onTransfer(fromId: _fromAccountId, toId: _toAccountId, amount: amt);
                Navigator.pop(context);
              },
              child: const Text('Execute Transfer (Instant)', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
