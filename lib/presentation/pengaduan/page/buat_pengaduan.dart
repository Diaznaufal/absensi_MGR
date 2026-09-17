import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/Provider/pengaduan_provider.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/bloc/kategoriOptions.dart';
import '../bloc/pengaduan/pengaduan_bloc.dart';
import '../bloc/pengaduan/pengaduan_event.dart';
import '../bloc/pengaduan/pengaduan_state.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/model/pengaduan_model.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/page/pengaduan_berhasil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class BuatPengaduan extends StatefulWidget {
  const BuatPengaduan({super.key});

  @override
  State<BuatPengaduan> createState() => _BuatPengaduanState();
}

class _BuatPengaduanState extends State<BuatPengaduan> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<PengaduanBloc>().add(
            GetProductsEvent(),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PengaduanProvider>();
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 600;

    return BlocListener<PengaduanBloc, PengaduanState>(
      listenWhen: (previous, current) =>
          current is StorePengaduanSuccess || current is PengaduanFailure,
      listener: (context, state) {
        if (state is StorePengaduanSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: TextStyle(fontSize: 12.sp)),
              backgroundColor: Colors.green,
            ),
          );

          PengaduanModel pengaduan = PengaduanModel(
            kodePengaduan: state.kodePengaduan.isNotEmpty
                ? state.kodePengaduan
                : provider.generateKodePengaduan(),
            area: provider.selectedArea!,
            kategori: provider.selectedKategori!,
            kategoriLainnya: provider.kategoriLainnyaController.text,
            judul: provider.judulPengaduanController.text,
            isi: provider.isiPengaduanController.text,
            lampiran: [...provider.uploadMedia],
            status: statusPengaduan.dalamProses,
            tanggalPengaduan: DateTime.now(),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PengaduanBerhasil(
                pengaduanData: pengaduan,
              ),
            ),
          );

          provider.resetFrom();
        }

        if (state is PengaduanFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: TextStyle(fontSize: 12.sp)),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF0A49B7),
          centerTitle: true,
          title: Text(
            "Buat Pengaduan",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              context.read<PengaduanProvider>().resetFrom();
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.keyboard_arrow_left,
              size: 26.r,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isTablet ? 18.w : 14.w,
                  18.h,
                  isTablet ? 18.w : 14.w,
                  24.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<PengaduanBloc, PengaduanState>(
                      buildWhen: (previous, current) =>
                          current is GetProductsSuccess ||
                          current is GetProductsLoading,
                      builder: (context, state) {
                        List<DropdownMenuItem<String>> dropdownItems = [];

                        final bool isDropdownLoading =
                            state is GetProductsLoading;

                        if (state is GetProductsSuccess) {
                          dropdownItems = state.products.map((item) {
                            return DropdownMenuItem<String>(
                              value: item.idProduct,
                              child: Text(
                                item.nameProduct ?? '',
                                style: TextStyle(fontSize: 12.5.sp),
                              ),
                            );
                          }).toList();
                        }

                        return _tempatKaryawan(
                          selectedValue: provider.selectedArea,
                          items: dropdownItems,
                          isLoading: isDropdownLoading,
                          onChanged: (newValue) {
                            provider.setSelectedArea(newValue);
                          },
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Icon(Icons.image_outlined,
                            color: const Color(0xFF0A49B7), size: 18.r),
                        SizedBox(width: 8.w),
                        Text(
                          "Lampiran Gambar",
                          style: GoogleFonts.poppins(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    provider.uploadMedia.isEmpty
                        ? _buildEmptyUpload(context)
                        : _buildMediaGrid(context, provider, isTablet),
                    SizedBox(height: 14.h),
                    _kategoriLaporan(
                      selectedValue: provider.selectedKategori,
                      onChanged: (newValue) {
                        provider.setSelectedKategori(newValue);
                      },
                    ),
                    if (provider.selectedKategori == '4') ...[
                      SizedBox(height: 14.h),
                      Row(
                        children: [
                          Icon(Icons.edit_note,
                              color: const Color(0xFF0A49B7), size: 18.r),
                          SizedBox(width: 8.w),
                          Text(
                            "Kategori Lainnya (Isi Manual)",
                            style: GoogleFonts.poppins(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: provider.kategoriLainnyaController,
                        style: GoogleFonts.poppins(
                            fontSize: 12.sp, color: Colors.black),
                        decoration: InputDecoration(
                          hintText:
                              "Ketik kategori atau detail pengaduan di sini...",
                          hintStyle: GoogleFonts.poppins(
                              color: Colors.grey, fontSize: 11.5.sp),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12.h, horizontal: 12.w),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: const BorderSide(
                                color: Color(0xFF0A49B7), width: 1.5),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 14.h),
                    _judulPengaduan(provider),
                    SizedBox(height: 14.h),
                    _isiPengaduan(provider),
                    SizedBox(height: 20.h),
                    BlocBuilder<PengaduanBloc, PengaduanState>(
                      builder: (context, state) {
                        bool isSubmitting = state is StorePengaduanLoading;

                        return InkWell(
                          onTap: provider.isFormValid() && !isSubmitting
                              ? () {
                                  XFile? logoFile;

                                  if (provider.uploadMedia.isNotEmpty) {
                                    logoFile = XFile(
                                      provider.uploadMedia.first,
                                    );
                                  }

                                  context.read<PengaduanBloc>().add(
                                        StorePengaduanEvent(
                                          title: provider
                                              .judulPengaduanController.text,
                                          text: provider
                                              .isiPengaduanController.text,
                                          kategori: provider.selectedKategori!,
                                          kategoriLainnya:
                                              provider.selectedKategori == '4'
                                                  ? provider
                                                      .kategoriLainnyaController
                                                      .text
                                                  : null,
                                          idProduct: provider.selectedArea!,
                                          logoFile: logoFile,
                                        ),
                                      );
                                }
                              : null,
                          borderRadius: BorderRadius.circular(10.r),
                          child: Container(
                            width: double.infinity,
                            height: 48.h,
                            decoration: BoxDecoration(
                              color: provider.isFormValid() && !isSubmitting
                                  ? const Color(0xff0a49b7)
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Center(
                              child: isSubmitting
                                  ? SizedBox(
                                      width: 18.r,
                                      height: 18.r,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      "Kirim Pengaduan",
                                      style: GoogleFonts.poppins(
                                        fontSize: 13.5.sp,
                                        color: provider.isFormValid()
                                            ? Colors.white
                                            : Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tempatKaryawan({
    required String? selectedValue,
    required List<DropdownMenuItem<String>> items,
    required bool isLoading,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.apartment, color: const Color(0xFF0A49B7), size: 18.r),
            SizedBox(width: 8.w),
            Text(
              "Tempat",
              style: GoogleFonts.poppins(
                  fontSize: 12.5.sp, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            DropdownButtonFormField2<String>(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide:
                      const BorderSide(color: Colors.black87, width: 1.5),
                ),
              ),
              hint: Text(
                isLoading ? 'Memuat data area...' : 'Pilih Area',
                style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
              iconStyleData: IconStyleData(
                icon: isLoading
                    ? const SizedBox.shrink()
                    : Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.black87, size: 22.r),
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 180.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                  color: Colors.white,
                ),
                elevation: 4,
              ),
              value: selectedValue,
              items: items,
              onChanged: isLoading ? null : onChanged,
            ),
            if (isLoading)
              Positioned(
                right: 14.w,
                child: SizedBox(
                  width: 16.r,
                  height: 16.r,
                  child: const CircularProgressIndicator(
                      strokeWidth: 2, color: Color(0xFF0A49B7)),
                ),
              )
          ],
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
            Icon(Icons.category, color: const Color(0xFF0A49B7), size: 18.r),
            SizedBox(width: 8.w),
            Text(
              "Kategori",
              style: GoogleFonts.poppins(
                  fontSize: 12.5.sp, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField2<String>(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            contentPadding:
                EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Colors.black87, width: 1.5),
            ),
          ),
          hint: Text(
            'Pilih Kategori',
            style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black),
          ),
          iconStyleData: IconStyleData(
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.black87, size: 22.r),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 180.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              color: Colors.white,
            ),
            elevation: 4,
          ),
          value: selectedValue,
          items: kategoriOptions.map((item) {
            return DropdownMenuItem<String>(
              value: item.value,
              child: Text(
                item.title,
                style: TextStyle(fontSize: 12.5.sp),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _judulPengaduan(PengaduanProvider provider) {
    return Column(children: [
      Row(
        children: [
          Icon(Icons.local_offer, size: 18.r, color: const Color(0xFF0A49B7)),
          SizedBox(width: 8.w),
          Text(
            "JUDUL PENGADUAN",
            style: GoogleFonts.poppins(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700),
          ),
        ],
      ),
      SizedBox(height: 8.h),
      TextFormField(
        controller: provider.judulPengaduanController,
        style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.black),
        decoration: InputDecoration(
          hintText: "Tuliskan judul yang singkat dan jelas..",
          hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 11.5.sp),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding:
              EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: Color(0xFF0A49B7), width: 1.5),
          ),
        ),
      ),
    ]);
  }

  Widget _isiPengaduan(PengaduanProvider provider) {
    return Column(children: [
      Row(
        children: [
          Icon(Icons.local_offer, size: 18.r, color: const Color(0xFF0A49B7)),
          SizedBox(width: 8.w),
          Text(
            "ISI PENGADUAN",
            style: GoogleFonts.poppins(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700),
          ),
        ],
      ),
      SizedBox(height: 8.h),
      TextFormField(
        controller: provider.isiPengaduanController,
        maxLines: 5,
        maxLength: 1000,
        style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.black),
        decoration: InputDecoration(
          hintText:
              "Jelaskan pengaduan anda secara lengkap dan detail. sertakan informasi seperti waktu kejadian, lokasi, pihak terlibat, dan hal-hal yang relevan...",
          hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 11.5.sp),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: EdgeInsets.all(12.r),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: Color(0xFF0A49B7), width: 1.5),
          ),
        ),
      ),
    ]);
  }

  Widget _buildEmptyUpload(BuildContext context) {
    return InkWell(
      onTap: () => context.read<PengaduanProvider>().pickMedia(context),
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        height: 125.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4.r,
                      offset: Offset(0, 2.h))
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(6.r),
                child: SvgPicture.asset(
                  "assets/icons/uploadCloud.svg",
                  width: 28.r,
                  height: 28.r,
                  colorFilter:
                      ColorFilter.mode(Colors.grey.shade600, BlendMode.srcIn),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text("Upload Gambar",
                style: GoogleFonts.poppins(
                    fontSize: 12.sp, color: Colors.grey[700])),
            Text("Ukuran file gambar maksimal adalah 4 MB.",
                style:
                    GoogleFonts.poppins(fontSize: 10.sp, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGrid(
      BuildContext context, PengaduanProvider provider, bool isTablet) {
    final bool canAdd = provider.uploadMedia.length < 4;
    final int crossAxisCount = isTablet ? 4 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: canAdd
          ? provider.uploadMedia.length + 1
          : provider.uploadMedia.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        if (canAdd && index == provider.uploadMedia.length) {
          return InkWell(
            onTap: () => provider.pickMedia(context),
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(Icons.add, color: Colors.grey, size: 26.r),
            ),
          );
        }
        return Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        backgroundColor: Colors.black,
                        child: SizedBox(
                          height: 350.h,
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
              top: 4.h,
              right: 4.w,
              child: Material(
                type: MaterialType.circle,
                color: Colors.black54,
                child: InkWell(
                  borderRadius: BorderRadius.circular(100.r),
                  onTap: () =>
                      provider.removeMedia(provider.uploadMedia[index]),
                  child: Padding(
                    padding: EdgeInsets.all(5.r),
                    child: Icon(Icons.close, size: 14.r, color: Colors.white),
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
