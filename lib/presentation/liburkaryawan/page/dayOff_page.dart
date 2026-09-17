import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/datasources/liburkaryawan_remote_datasource.dart';
import 'package:flutter_absensi_app/presentation/liburkaryawan/bloc/add_dayoff/add_dayoff_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class FormDayOffPage extends StatefulWidget {
  const FormDayOffPage({super.key});

  @override
  State<FormDayOffPage> createState() => _FormDayOffPageState();
}

class _FormDayOffPageState extends State<FormDayOffPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  DateTime? _selectedDateBackend;

  @override
  void dispose() {
    _dateController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDateBackend = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddDayoffBloc(DayOffRemoteDatasource()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 56.h,
          title: Text(
            'Ajukan Day Off',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 18.r,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: const Color(0xFF0A49B7),
          foregroundColor: Colors.black87,
          elevation: 0.5,
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: BlocListener<AddDayoffBloc, AddDayoffState>(
              listener: (context, state) {
                state.maybeWhen(
                  loading: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                    );
                  },
                  error: (message) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text(message, style: TextStyle(fontSize: 12.sp)),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  success: (data) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Berhasil mengajukan Day Off',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context, true);
                  },
                  orElse: () {},
                );
              },
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(12.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. TANGGAL LIBUR
                      _buildFieldLabel('Tanggal Libur'),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        style: TextStyle(fontSize: 12.5.sp),
                        decoration: InputDecoration(
                          hintText: 'Pilih Tanggal',
                          hintStyle:
                              TextStyle(fontSize: 12.sp, color: Colors.grey),
                          suffixIcon:
                              Icon(Icons.calendar_today_outlined, size: 18.r),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Tanggal wajib diisi'
                            : null,
                      ),
                      SizedBox(height: 14.h),

                      // 2. ALASAN / DESKRIPSI
                      _buildFieldLabel('Alasan / Deskripsi'),
                      TextFormField(
                        controller: _reasonController,
                        maxLines: 4,
                        maxLength: 1000,
                        style: TextStyle(fontSize: 12.5.sp),
                        decoration: InputDecoration(
                          hintText: 'Tulis alasannya..',
                          hintStyle:
                              TextStyle(fontSize: 12.sp, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: EdgeInsets.all(12.r),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Deskripsi wajib diisi'
                            : null,
                      ),

                      SizedBox(height: 18.h),

                      // TOMBOL SUBMIT UTAMA
                      Builder(
                        builder: (context) {
                          return SizedBox(
                            width: double.infinity,
                            height: 46.h,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  String backendDateFormated =
                                      DateFormat('yyyy-MM-dd')
                                          .format(_selectedDateBackend!);
                                  String todayFormated =
                                      DateFormat('yyyy-MM-dd')
                                          .format(DateTime.now());

                                  context.read<AddDayoffBloc>().add(
                                        AddDayoffEvent.addDayOff(
                                          inputAt: todayFormated,
                                          tglDayOff: backendDateFormated,
                                          description: _reasonController.text,
                                        ),
                                      );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0A49B7),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                              child: Text(
                                'Ajukan Day Off',
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 4.h, 4.w, 6.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.5.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
