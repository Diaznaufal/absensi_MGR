import 'package:flutter/material.dart';

class SessionManager {
  SessionManager._();

  static final SessionManager instance = SessionManager._();

  VoidCallback? onSessionExpired;

  bool _isHandlingExpiredSession = false;

  Future<void> sessionExpired() async {
    // Mencegah navigasi login berkali-kali
    if (_isHandlingExpiredSession) return;

    _isHandlingExpiredSession = true;

    try {
      onSessionExpired?.call();
    } finally {
      // Beri sedikit waktu agar navigasi selesai
      await Future.delayed(const Duration(milliseconds: 500));
      _isHandlingExpiredSession = false;
    }
  }
}