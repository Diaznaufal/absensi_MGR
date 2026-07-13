import 'package:flutter/material.dart';
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
  
  // Menyimpan objek DateTime murni untuk kebutuhan parsing ke format API
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
        // Format tampilan UI lokal
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
          title: const Text('Ajukan Day Off',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
        ),
        body: BlocListener<AddDayoffBloc, AddDayoffState>(
          listener: (context, state) {
            state.maybeWhen(
              loading: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );
              },
              error: (message) {
                Navigator.pop(context); // Tutup loading dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message), backgroundColor: Colors.red),
                );
              },
              success: (data) {
                Navigator.pop(context); // Tutup loading dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Berhasil mengajukan Day Off'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context, true); // Kembali ke halaman riwayat dengan status sukses
              },
              orElse: () {},
            );
          },
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. TANGGAL LIBUR
                  _buildFieldLabel('Tanggal Libur'),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: InputDecoration(
                      hintText: 'Pilih Tanggal',
                      suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Tanggal wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // 2. ALASAN / DESKRIPSI
                  _buildFieldLabel('Alasan / Deskripsi'),
                  TextFormField(
                    controller: _reasonController,
                    maxLines: 3,
                    maxLength: 1000,
                    decoration: InputDecoration(
                      hintText: 'Tulis alasannya..',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Deskripsi wajib diisi'
                        : null,
                  ),

                  const SizedBox(height: 20),

                  // TOMBOL SUBMIT UTAMA
                  Builder(
                    builder: (context) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Sesuaikan format string tanggal dengan kemauan backend kamu (misal YYYY-MM-DD)
                              String backendDateFormated = DateFormat('yyyy-MM-dd').format(_selectedDateBackend!);
                              String todayFormated = DateFormat('yyyy-MM-dd').format(DateTime.now());

                              // Trigger post request via Bloc
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Ajukan Day Off',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      );
                    }
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
    );
  }
}