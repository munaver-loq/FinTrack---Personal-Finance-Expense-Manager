import 'package:flutter/material.dart';

class CategoryBreakdownItem {
  final String title;
  final String subtitle;
  final double amount;
  final int percentage;
  final Color color;

  const CategoryBreakdownItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}

class WeeklyBarData {
  final String day;
  final double amount;
  final double percentage;
  final bool isPeak;

  const WeeklyBarData({
    required this.day,
    required this.amount,
    required this.percentage,
    this.isPeak = false,
  });
}

class WeeklyTrendData {
  final String weekLabel;
  final double amount;
  final double heightPercentage;
  final bool isPeak;
  final bool isSafe;

  const WeeklyTrendData({
    required this.weekLabel,
    required this.amount,
    required this.heightPercentage,
    this.isPeak = false,
    this.isSafe = false,
  });
}
