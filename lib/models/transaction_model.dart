import 'package:flutter/material.dart';

enum TransactionType { expense, income, transfer }

class TransactionModel {
  final String id;
  final String profileId;
  final String title;
  final String category;
  final String time;
  final double amount;
  final String? badgeText;
  final Color? badgeColor;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final TransactionType type;
  final String? notes;
  final List<String> tags;
  final DateTime date;

  const TransactionModel({
    required this.id,
    this.profileId = 'user_alex',
    required this.title,
    required this.category,
    required this.time,
    required this.amount,
    this.badgeText,
    this.badgeColor,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.type,
    this.notes,
    this.tags = const [],
    required this.date,
  });

  bool get isIncome => type == TransactionType.income || (type != TransactionType.expense && amount > 0);

  String formatAmount([String symbol = r'$']) {
    final prefix = isIncome ? '+$symbol' : '-$symbol';
    return '$prefix${amount.abs().toStringAsFixed(2)}';
  }

  String get formattedAmount => formatAmount();
}
