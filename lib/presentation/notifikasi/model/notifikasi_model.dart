import 'package:flutter/material.dart';

class NotifikasiModel {
  final String id;
  final IconData icon;
  final Color color;
  final Color iconBg;
  final String title;
  final String subtitle;
  final DateTime time;
  bool isread;

  NotifikasiModel(
      {required this.id,
      required this.icon,
      required this.color,
      required this.iconBg,
      required this.title,
      required this.subtitle,
      required this.time,
      required this.isread});
}
