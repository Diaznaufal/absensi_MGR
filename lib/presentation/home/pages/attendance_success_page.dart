// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/is_checkedin/is_checkedin_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/core.dart';

class AttendanceSuccessPage extends StatefulWidget {
  final String status;
  const AttendanceSuccessPage({
    super.key,
    required this.status,
  });

  @override
  State<AttendanceSuccessPage> createState() => _AttendanceSuccessPageState();
}

class _AttendanceSuccessPageState extends State<AttendanceSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.7, curve: Curves.easeIn),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCheckIn = widget.status.toLowerCase() == 'datang';
    final gradient = isCheckIn
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4CAF50), // Green for check-in
              Color(0xFF45A049),
              Colors.white,
            ],
            stops: [0.0, 0.3, 1.0],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2196F3), // Blue for check-out
              Color(0xFF1976D2),
              Colors.white,
            ],
            stops: [0.0, 0.3, 1.0],
          );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Top spacing
                const SizedBox(height: 40),

                // Success Icon with Animation
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 48,
                      color: isCheckIn
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF2196F3),
                    ),
                  ),
                ),

                const SpaceHeight(20),

                // Success Title
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Berhasil!',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SpaceHeight(8),

                // Status Badge
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCheckIn
                              ? Icons.login_rounded
                              : Icons.logout_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SpaceWidth(6),
                        Text(
                          'Absensi ${widget.status}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SpaceHeight(24),

                // Info Card with slide animation
                SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Time Icon
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isCheckIn
                                  ? [
                                      const Color(0xFF4CAF50),
                                      const Color(0xFF45A049)
                                    ]
                                  : [
                                      const Color(0xFF2196F3),
                                      const Color(0xFF1976D2)
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.access_time_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),

                        const SpaceHeight(12),

                        // Time
                        Text(
                          DateTime.now().toFormattedTime(),
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: isCheckIn
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFF2196F3),
                            height: 1,
                          ),
                        ),

                        const SpaceHeight(4),

                        // Date
                        Text(
                          DateTime.now().toFormattedDate(),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),

                        const SpaceHeight(16),

                        // Divider
                        Container(
                          width: double.infinity,
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.grey[300]!,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        const SpaceHeight(16),

                        // Success Message
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isCheckIn
                                ? const Color(0xFF4CAF50).withOpacity(0.1)
                                : const Color(0xFF2196F3).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isCheckIn
                                  ? const Color(0xFF4CAF50).withOpacity(0.3)
                                  : const Color(0xFF2196F3).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: isCheckIn
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFF2196F3),
                                size: 18,
                              ),
                              const SpaceWidth(8),
                              Expanded(
                                child: Text(
                                  isCheckIn
                                      ? 'Selamat bekerja! Semoga hari Anda produktif.'
                                      : 'Terima kasih atas kerja keras Anda hari ini!',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: isCheckIn
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFF1565C0),
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom spacing
                const SizedBox(height: 40),

                // Button
                SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isCheckIn
                            ? [const Color(0xFF4CAF50), const Color(0xFF45A049)]
                            : [
                                const Color(0xFF2196F3),
                                const Color(0xFF1976D2)
                              ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: (isCheckIn
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFF2196F3))
                              .withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          context
                              .read<IsCheckedinBloc>()
                              .add(const IsCheckedinEvent.isCheckedIn());
                          context.popToRoot();
                        },
                        child: Center(
                          child: Text(
                            'Kembali ke Beranda',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
