import 'package:flutter/material.dart';

class TimelineData {
  final String title;
  final String description;
  final DateTime date;
  final Color color;
  final bool isActive;

  TimelineData({
    required this.title,
    required this.description,
    required this.date,
    required this.color,
    required this.isActive,
  });
}