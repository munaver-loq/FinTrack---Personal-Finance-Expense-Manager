import 'package:flutter/material.dart';

class CategoryBudgetModel {
  final String id;
  final String profileId;
  final String name;
  final String subtitle;
  double spent;
  double limit;
  double thresholdPercent;
  final IconData icon;
  final Color color;
  final Color iconBgColor;
  final String status;
  final Color statusColor;
  final Color statusBgColor;
  final String footerRight;
  final bool isNearLimit;

  CategoryBudgetModel({
    required this.id,
    this.profileId = 'user_alex',
    required this.name,
    required this.subtitle,
    required this.spent,
    required this.limit,
    this.thresholdPercent = 80.0,
    required this.icon,
    required this.color,
    required this.iconBgColor,
    required this.status,
    required this.statusColor,
    required this.statusBgColor,
    required this.footerRight,
    this.isNearLimit = false,
  });

  double get percentSpent => (limit > 0) ? (spent / limit) : 0.0;
  int get percentSpentInt => (percentSpent * 100).clamp(0, 100).toInt();
  double get remaining => (limit - spent).clamp(0, double.infinity);

  CategoryBudgetModel copyWith({
    String? id,
    String? profileId,
    String? name,
    String? subtitle,
    double? spent,
    double? limit,
    double? thresholdPercent,
    IconData? icon,
    Color? color,
    Color? iconBgColor,
    String? status,
    Color? statusColor,
    Color? statusBgColor,
    String? footerRight,
    bool? isNearLimit,
  }) {
    return CategoryBudgetModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      spent: spent ?? this.spent,
      limit: limit ?? this.limit,
      thresholdPercent: thresholdPercent ?? this.thresholdPercent,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      iconBgColor: iconBgColor ?? this.iconBgColor,
      status: status ?? this.status,
      statusColor: statusColor ?? this.statusColor,
      statusBgColor: statusBgColor ?? this.statusBgColor,
      footerRight: footerRight ?? this.footerRight,
      isNearLimit: isNearLimit ?? this.isNearLimit,
    );
  }
}
