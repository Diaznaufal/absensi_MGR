import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/Provider/pengaduan_provider.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/bloc/kantorOptions.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/bloc/kategoriOptions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

class BuatPengaduan extends StatelessWidget {
  const BuatPengaduan({super.key});

  // Data dummy untuk Tips
  final List<String> tipsPengaduan = const [
    "Pastikan foto terlihat jelas dan tidak buram.",
    "Ukuran file gambar maksimal adalah 4 MB.",
    "Format file yang didukung: PNG, JPG, WEBP.",
  ];

  @override
  Widget build(BuildContext context) {
    // Membaca state dari Provider secara realtime
    final provider = context.watch<PengaduanProvider>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0A49B7),
        centerTitle: true,
        title: Text(
          "Buat Pengaduan",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.keyboard_arrow_left,
            size: 27,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 25, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Dropdown Tempat (Membaca & mengubah nilai lewat Provider)
                _tempatKaryawan(
                  selectedValue: provider.selectedArea,
                  onChanged: (newValue) {
                    provider.setSelectedArea(newValue);
                  },
                ),

                const SizedBox(height: 24),

                // 2. Judul Section Lampiran Gambar
                Row(
                  children: [
                    const Icon(Icons.image_outlined),
                    const SizedBox(width: 10),
                    Text(
                      "Lampiran Gambar",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // 3. Komponen Upload Media (Kondisional)
                provider.uploadMedia.isEmpty
                    ? _buildEmptyUpload(context)
                    : _buildMediaGrid(context, provider),

                const SizedBox(height: 12),

                // 4. Section Tips
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tips :",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...tipsPengaduan.map(
                      (tip) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        child: Text(
                          "• $tip",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                _kategoriLaporan(
                  selectedValue: provider.selectedKategori,
                  onChanged: (newValue) {
                    provider.setSelectedKategori(newValue);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildEmptyUpload(BuildContext context) {
    return InkWell(
      onTap: () => context.read<PengaduanProvider>().pickMedia(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2))
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SvgPicture.asset(
                  "assets/icons/uploadCloud.svg",
                  width: 35,
                  height: 35,
                  colorFilter:
                      ColorFilter.mode(Colors.grey.shade600, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Upload Gambar",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGrid(BuildContext context, PengaduanProvider provider) {
    final bool canAdd = provider.uploadMedia.length < 4;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: canAdd
          ? provider.uploadMedia.length + 1
          : provider.uploadMedia.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        if (canAdd && index == provider.uploadMedia.length) {
          return InkWell(
            onTap: () => provider.pickMedia(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(Icons.add, color: Colors.grey, size: 30),
            ),
          );
        }
        return Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        backgroundColor: Colors.black,
                        child: SizedBox(
                          height: 400,
                          child: PhotoView(
                              imageProvider:
                                  FileImage(File(provider.uploadMedia[index]))),
                        ),
                      ),
                    );
                  },
                  child: Image.file(File(provider.uploadMedia[index]),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Material(
                type: MaterialType.circle,
                color: Colors.black54,
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () =>
                      provider.removeMedia(provider.uploadMedia[index]),
                  child: const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Icon(Icons.close, size: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget _tempatKaryawan({
  required String? selectedValue,
  required ValueChanged<String?> onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(Icons.apartment),
          const SizedBox(width: 10),
          Text(
            "Tempat",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonFormField2<String>(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 10,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black87, width: 1.5),
            ),
          ),
          hint: Text(
            'Pilih Area',
            style: GoogleFonts.poppins(
                fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
          ),
          iconStyleData: const IconStyleData(
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.black87,
            ),
            iconSize: 26,
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 155,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white,
            ),
            elevation: 4,
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),
          value: selectedValue,
          items: kantorOptions.map((item) {
            return DropdownMenuItem<String>(
              value: item.value,
              child: Text(item.title),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    ],
  );
}

Widget _kategoriLaporan({
  required String? selectedValue,
  required ValueChanged<String?> onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(Icons.apartment),
          const SizedBox(width: 10),
          Text(
            "Tempat",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonFormField2<String>(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 10,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black87, width: 1.5),
            ),
          ),
          hint: Text(
            'Pilih Kategori',
            style: GoogleFonts.poppins(
                fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
          ),
          iconStyleData: const IconStyleData(
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.black87,
            ),
            iconSize: 26,
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 155,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white,
            ),
            elevation: 4,
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),
          value: selectedValue,
          items: kategoriOptions.map((item) {
            return DropdownMenuItem<String>(
              value: item.value,
              child: Text(item.title),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    ],
  );
}
