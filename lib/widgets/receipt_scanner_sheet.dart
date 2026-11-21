import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class ReceiptScannerSheet extends StatefulWidget {
  final Function({
    required String merchant,
    required double amount,
    required String category,
    required String notes,
  }) onReceiptScanned;

  const ReceiptScannerSheet({super.key, required this.onReceiptScanned});

  @override
  State<ReceiptScannerSheet> createState() => _ReceiptScannerSheetState();
}

class _ReceiptScannerSheetState extends State<ReceiptScannerSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _isScanned = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Auto-detect after 2.5 seconds for realistic AR feel
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() {
          _isScanned = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.document_scanner_rounded, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'OCR Smart Receipt Scanner',
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
          const SizedBox(height: 12),

          // Camera Viewfinder Box
          Container(
            height: 190,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isScanned ? AppColors.tertiary : AppColors.primary,
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Simulated receipt preview
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isScanned ? Icons.check_circle_rounded : Icons.receipt_long_rounded,
                        color: _isScanned ? AppColors.tertiary : AppColors.outline,
                        size: 44,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isScanned ? 'Trader Joe\'s Market' : 'Align receipt within viewfinder',
                        style: AppTypography.titleMedium.copyWith(
                          color: _isScanned ? AppColors.onSurface : AppColors.outline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isScanned ? 'Amount Detected: \$64.50 • Groceries' : 'Offline ML Kit Text Recognition Active',
                        style: AppTypography.bodySmall.copyWith(
                          color: _isScanned ? AppColors.tertiary : AppColors.outline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Animated Laser Scanner Line
                if (!_isScanned)
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      return Positioned(
                        top: 20 + (_animController.value * 140),
                        left: 20,
                        right: 20,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.primary,
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_isScanned) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderStroke),
              ),
              child: const Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Merchant: Trader Joe\'s', style: TextStyle(color: AppColors.onSurface, fontSize: 13)),
                      Text('\$64.50', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Category: Groceries & Essentials', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                      Text('3 items parsed', style: TextStyle(color: AppColors.tertiary, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Fill & Save Transaction', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onReceiptScanned(
                    merchant: 'Trader Joe\'s Market',
                    amount: 64.50,
                    category: 'Groceries',
                    notes: 'Weekly fresh produce & essentials via receipt scan',
                  );
                },
              ),
            ),
          ] else ...[
            Text(
              'Scanning receipt with local encrypted OCR...',
              style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}
