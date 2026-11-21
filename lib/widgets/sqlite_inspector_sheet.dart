import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../state/finance_state.dart';

class SqliteInspectorSheet extends StatefulWidget {
  final FinanceState state;

  const SqliteInspectorSheet({super.key, required this.state});

  @override
  State<SqliteInspectorSheet> createState() => _SqliteInspectorSheetState();
}

class _SqliteInspectorSheetState extends State<SqliteInspectorSheet> {
  String _selectedQuery = 'SELECT * FROM transactions';
  List<Map<String, dynamic>> _queryResults = [];
  double _latency = 0.6;

  @override
  void initState() {
    super.initState();
    _runQuery();
  }

  void _runQuery() {
    setState(() {
      _queryResults = widget.state.runMockQuery(_selectedQuery);
      _latency = widget.state.dbLatencyMs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.storage_rounded, color: AppColors.tertiary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'SQLite Database Console',
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

          // Diagnostic status badges
          Row(
            children: [
              _buildBadge('v3.45.1 Embedded', AppColors.primary),
              const SizedBox(width: 6),
              _buildBadge('AES-256 Cipher', AppColors.tertiary),
              const SizedBox(width: 6),
              _buildBadge('${_latency.toStringAsFixed(2)}ms Latency', AppColors.secondary),
            ],
          ),
          const SizedBox(height: 14),

          // Query Selector Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderStroke),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedQuery,
                isExpanded: true,
                dropdownColor: AppColors.surfaceContainerHigh,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'SELECT * FROM transactions',
                    child: Text('SELECT * FROM transactions'),
                  ),
                  DropdownMenuItem(
                    value: 'SELECT * FROM budgets',
                    child: Text('SELECT * FROM budgets'),
                  ),
                  DropdownMenuItem(
                    value: 'SELECT * FROM accounts',
                    child: Text('SELECT * FROM accounts'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedQuery = val;
                    });
                    _runQuery();
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Query Result Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Query Result (${_queryResults.length} records)',
                style: AppTypography.labelMedium.copyWith(color: AppColors.onSurfaceVariant),
              ),
              GestureDetector(
                onTap: _runQuery,
                child: Row(
                  children: [
                    const Icon(Icons.refresh_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Re-query',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Table / JSON Viewer
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderStroke),
              ),
              child: ListView.builder(
                itemCount: _queryResults.length,
                itemBuilder: (context, index) {
                  final row = _queryResults[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      const JsonEncoder.withIndent('  ').convert(row),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppColors.onSurface,
                        fontSize: 11,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderStroke),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.restart_alt_rounded, size: 16, color: AppColors.alertDanger),
                  label: const Text('Reset Demo Data', style: TextStyle(color: AppColors.alertDanger, fontSize: 12)),
                  onPressed: () async {
                    await widget.state.resetDemoData();
                    _runQuery();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Database restored to default demo state!'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text('Export CSV', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: () {
                    final csv = widget.state.getCsvExport();
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.surfaceContainerHigh,
                        title: const Text('Exported CSV Preview'),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: SelectableText(
                            csv,
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
