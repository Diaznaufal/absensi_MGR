import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_absensi_app/presentation/home/pages/main_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../../core/core.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _isChecking = true;
  String _loadingText = "Loading...";

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    Future.delayed(
      const Duration(milliseconds: 300),
      () => _scaleController.forward(),
    );
    Future.delayed(
      const Duration(milliseconds: 500),
      () => _fadeController.forward(),
    );
    Future.delayed(
      const Duration(milliseconds: 700),
      () => _slideController.forward(),
    );

    _startSplashProcess();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _startSplashProcess() async {
    setState(() {
      _isChecking = true;
      _loadingText = "Memeriksa koneksi...";
    });

    await Future.delayed(const Duration(seconds: 2));

    bool hasInternet = await InternetConnection().hasInternetAccess;

    if (!hasInternet) {
      setState(() {
        _isChecking = false;
        _loadingText = "Koneksi internet tidak stabil.";
      });
      _showNoInternetDialog();
    } else {
      setState(() {
        _loadingText = "Membuka aplikasi...";
      });
      _checkAuthAndNavigate();
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    if (mounted) {
      final isAuth = await AuthLocalDatasource().isAuth();
      if (isAuth) {
        context.pushReplacement(const MainPage());
      } else {
        context.pushReplacement(const LoginPage());
      }
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Koneksi Bermasalah"),
        content: const Text(
          "Pastikan perangkat Anda terhubung ke internet lalu coba lagi.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startSplashProcess();
            },
            child: const Text("Coba Lagi"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background ilustrasi bawah fleksibel (mengisi lebar penuh)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/images/gedung.png",
                  width: double.infinity,
                  height: size.height * 0.38,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/images/container_bawah.png",
              width: double.infinity,
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomCenter,
            ),
          ),

          // Lingkaran Hiasan Atas
          Positioned(
            left: -100,
            top: -60,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF1e3c72).withOpacity(0.05),
                    width: 35,
                  ),
                ),
              ),
            ),
          ),

          // Konten Utama Tengah
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.12),
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Image.asset(
                          "assets/images/MGR_logo.png",
                          width: isTablet ? 300 : 240,
                          height: isTablet ? 180 : 140,
                          fit: BoxFit.contain,
                        ),
                      ),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              Text(
                                'Multi Graha Radhika',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF2a5298),
                                  fontSize: isTablet ? 24 : 20,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SpaceHeight(10),
                              Container(
                                width: 50,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3b82c9),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                              const SpaceHeight(10),
                              Text(
                                'Smart Digital Solution Provider',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF4b5f7a),
                                  fontSize: isTablet ? 15 : 13,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            if (_isChecking) ...[
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF2a5298),
                                  ),
                                  backgroundColor:
                                      const Color(0xFF2a5298).withOpacity(0.2),
                                ),
                              ),
                              const SpaceHeight(8),
                            ],
                            Text(
                              _loadingText,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF4b5f7a),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SpaceHeight(24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
