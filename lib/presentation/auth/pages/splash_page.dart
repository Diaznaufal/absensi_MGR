import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_absensi_app/presentation/home/pages/main_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart'; // Import package baru

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

  // Variabel baru untuk melacak status loading/error internet
  bool _isChecking = true;
  String _loadingText = "Loading...";

  @override
  void initState() {
    super.initState();

    // ... (Konfigurasi controller & animation Anda tetap sama)
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
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _slideController, curve: Curves.easeOutCubic));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack));

    // Jalankan Animasi
    Future.delayed(
        const Duration(milliseconds: 300), () => _scaleController.forward());
    Future.delayed(
        const Duration(milliseconds: 500), () => _fadeController.forward());
    Future.delayed(
        const Duration(milliseconds: 700), () => _slideController.forward());

    // PANGGIL PROSES DI SINI (Bukan di dalam build)
    _startSplashProcess();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  // Menggabungkan delay minimal animasi + cek internet
  Future<void> _startSplashProcess() async {
    setState(() {
      _isChecking = true;
      _loadingText = "Memeriksa koneksi...";
    });

    // Berikan delay minimal 2-3 detik agar animasi logo selesai duluan dan halus
    await Future.delayed(const Duration(seconds: 2));

    // Lakukan pengecekan internet asli
    bool hasInternet = await InternetConnection().hasInternetAccess;

    if (!hasInternet) {
      // Jika internet tidak ada / jelek, ubah status text atau munculkan dialog
      setState(() {
        _isChecking = false;
        _loadingText = "Koneksi internet tidak stabil.";
      });

      // Tampilkan dialog opsi coba lagi
      _showNoInternetDialog();
    } else {
      // Jika ada internet, lanjutkan ke cek auth login seperti biasa
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

  // Dialog pengingat jika internet mati setelah ditunggu
  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Tidak bisa ditutup sembarangan
      builder: (context) => AlertDialog(
        title: const Text("Koneksi Bermasalah"),
        content: const Text(
            "Pastikan perangkat Anda terhubung ke internet (Wi-Fi/Kuotamu aktif) lalu coba lagi."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              _startSplashProcess(); // Jalankan ulang pengecekan internet
            },
            child: const Text("Coba Lagi"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // SEKARANG BERSIH: Tidak ada pemanggilan _checkAuthAndNavigate() di sini lagi mendahului siklus render.
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(),
        child: _buildSplashContent(),
      ),
    );
  }

  Widget _buildSplashContent() {
    return Stack(
      children: [
        // ... bagian background, lingkaran hiasan, dan logo (Tetap sama seperti kode Anda)
        Positioned.fill(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(flex: 55, child: Container(color: Colors.white)),
                ],
              ),
              Positioned(
                bottom: 40,
                left: -120,
                right: -120,
                child: Image.asset("assets/images/gedung.png",
                    width: 450, height: 450),
              ),
              Positioned(
                bottom: -5,
                left: -120,
                right: -120,
                child: Image.asset("assets/images/container_bawah.png",
                    width: 450, height: 450),
              ),
            ],
          ),
        ),
        Positioned(
          left: -190,
          top: -110,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(0xFF1e3c72).withOpacity(0.05),
                    width: 45),
              ),
            ),
          ),
        ),
        Positioned(
          left: -115,
          top: -35,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(0xFF1e3c72).withOpacity(0.05),
                    width: 25),
              ),
            ),
          ),
        ),
        Center(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.24),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset("assets/images/MGR_logo.png",
                    width: 320, height: 200, fit: BoxFit.contain),
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
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 4,
                        ),
                      ),
                      const SpaceHeight(12),
                      Container(
                        width: 60,
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3b82c9),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SpaceHeight(14),
                      Text(
                        'Smart Digital Solution Provider',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF4b5f7a),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // SEKTOR PROSES LOADING & INDIKATOR INTERNET
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    if (_isChecking) ...[
                      SizedBox(
                        width: 25,
                        height: 25,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          // Mengubah warna indicator jadi biru agar terlihat kontras di background putih Anda bawahnya
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF2a5298)),
                          backgroundColor:
                              const Color(0xFF2a5298).withOpacity(0.25),
                        ),
                      ),
                      const SpaceHeight(8),
                    ],
                    Text(
                      _loadingText, // Teks dinamis sesuai status internet
                      style: GoogleFonts.poppins(
                        color: const Color(
                            0xFF4b5f7a), // Ubah jadi warna gelap agar terbaca jelas
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SpaceHeight(40),
            ],
          ),
        ),
      ],
    );
  }
}
