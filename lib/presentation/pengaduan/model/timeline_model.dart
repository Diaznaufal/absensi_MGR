import 'package:flutter/material.dart';

class TimelineData {
  final String title;
  final String description;
  final DateTime? date;
  final bool isActive;
  final Color color;

  const TimelineData({
    required this.title,
    required this.description,
    this.date,
    required this.isActive,
    required this.color,
  });
}