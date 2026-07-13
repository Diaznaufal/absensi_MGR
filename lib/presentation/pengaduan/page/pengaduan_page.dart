import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/presentation/home/pages/main_page.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/page/buat_pengaduan.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/widget/riwayat_pengaduan.dart';

import 'package:flutter_absensi_app/presentation/pengaduan/bloc/pengaduan/pengaduan_bloc.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/bloc/pengaduan/pengaduan_event.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/bloc/pengaduan/pengaduan_state.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class PengaduanPage extends StatefulWidget {
  const PengaduanPage({super.key});

  @override
  State<PengaduanPage> createState() => _PengaduanPageState();
}

class _PengaduanPageState extends State<PengaduanPage> {
  final TextEditingController kodeController =
      TextEditingController();

  void _cariPengaduan() {
    final kode = kodeController.text.trim();

    if (kode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Masukkan kode pengaduan terlebih dahulu",
          ),
        ),
      );
      return;
    }

    // Tutup keyboard
    FocusScope.of(context).unfocus();

    // Kirim kode ke Bloc
    context.read<PengaduanBloc>().add(
          CariPengaduanByKodeEvent(
            kodePengaduan: kode,
          ),
        );
  }

  @override
  void dispose() {
    kodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => MainPage(),
          ),
          (route) => false,
        );
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 70,
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF0A49B7),
          centerTitle: true,
          title: Text(
            "Pengaduan Karyawan",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => MainPage(),
                ),
                (route) => false,
              );
            },
            icon: const Icon(
              Icons.keyboard_arrow_left,
              size: 27,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: const Color(0xFFE7EAEC),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Column(
              children: [
                // =========================
                // CARD BUAT PENGADUAN
                // =========================
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sampaikan keluhan atau \naspirasi anda",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          "Setiap laporan akan ditangani secara "
                          "profesional dan terjaga kerahasiaannya",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const BuatPengaduan(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A49B7),
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Buat Pengaduan",
                                  style: GoogleFonts.poppins(
                                    fontWeight:
                                        FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // =========================
                // CARD RIWAYAT
                // =========================
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Riwayat Pengaduan",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Cari riwayat pengaduan anda "
                            "\nmenggunakan kode pengaduan",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // =========================
                          // SEARCH FIELD
                          // =========================
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: kodeController,
                                  textInputAction:
                                      TextInputAction.search,
                                  onSubmitted: (_) {
                                    _cariPengaduan();
                                  },
                                  decoration: InputDecoration(
                                    hintText:
                                        'Masukkan kode pengaduan',
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[400],
                                    ),
                                    prefixIconConstraints:
                                        const BoxConstraints(
                                      minWidth: 10,
                                      minHeight: 10,
                                    ),
                                    prefixIcon: const Padding(
                                      padding: EdgeInsets.only(
                                        left: 10,
                                        right: 5,
                                      ),
                                      child: Icon(
                                        Icons.search,
                                        color: Colors.black87,
                                        size: 20,
                                      ),
                                    ),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    enabledBorder:
                                        OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    focusedBorder:
                                        OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.blue[800]!,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // =========================
                              // TOMBOL CARI
                              // =========================
                              BlocBuilder<
                                  PengaduanBloc,
                                  PengaduanState>(
                                buildWhen: (previous, current) =>
                                    current
                                        is CariPengaduanLoading ||
                                    current
                                        is CariPengaduanSuccess ||
                                    current
                                        is CariPengaduanNotFound ||
                                    current
                                        is CariPengaduanFailure,
                                builder: (context, state) {
                                  final isLoading =
                                      state
                                          is CariPengaduanLoading;

                                  return ElevatedButton(
                                    onPressed: isLoading
                                        ? null
                                        : _cariPengaduan,
                                    style:
                                        ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF0052CC),
                                      foregroundColor:
                                          Colors.white,
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      shape:
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                          12,
                                        ),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'Cari',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight:
                                                  FontWeight.w500,
                                            ),
                                          ),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // =========================
                          // HASIL PENCARIAN
                          // =========================
                          Expanded(
                            child: BlocBuilder<
                                PengaduanBloc,
                                PengaduanState>(
                              buildWhen: (previous, current) =>
                                  current
                                      is CariPengaduanLoading ||
                                  current
                                      is CariPengaduanSuccess ||
                                  current
                                      is CariPengaduanNotFound ||
                                  current
                                      is CariPengaduanFailure,
                              builder: (context, state) {
                                // Loading
                                if (state
                                    is CariPengaduanLoading) {
                                  return const Center(
                                    child:
                                        CircularProgressIndicator(),
                                  );
                                }

                                // Ketemu
                                if (state
                                    is CariPengaduanSuccess) {
                                  final item =
                                      state.pengaduan;

                                  return Align(
                                    alignment:
                                        Alignment.topCenter,
                                    child:
                                        RiwayatPengaduanCard(
                                      code:
                                          item.kodePengaduan,
                                      tanggal:
                                          item.tanggalPengaduan ??
                                              DateTime.now(),
                                      status: item.status,
                                      pengaduan: item,
                                    ),
                                  );
                                }

                                // Tidak ketemu
                                if (state
                                    is CariPengaduanNotFound) {
                                  return Center(
                                    child: Column(
                                      mainAxisSize:
                                          MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.search_off_rounded,
                                          size: 55,
                                          color:
                                              Colors.grey[350],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "Kode pengaduan tidak ditemukan",
                                          style:
                                              GoogleFonts.poppins(
                                            fontSize: 13,
                                            color:
                                                Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                // Error jaringan/server
                                if (state
                                    is CariPengaduanFailure) {
                                  return Center(
                                    child: Text(
                                      state.message,
                                      textAlign:
                                          TextAlign.center,
                                      style:
                                          GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.red,
                                      ),
                                    ),
                                  );
                                }

                                // Sebelum mencari
                                return Center(
                                  child: Text(
                                    "Masukkan kode pengaduan\n"
                                    "untuk melihat riwayat",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}