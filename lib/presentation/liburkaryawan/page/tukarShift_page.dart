import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/liburKaryawan_model.dart';
import '../provider/liburKaryawan_provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:intl/intl.dart';

class FormTukarShiftPage extends StatefulWidget {
  const FormTukarShiftPage({super.key});

  @override
  State<FormTukarShiftPage> createState() => _FormTukarShiftPageState();
}

class _FormTukarShiftPageState extends State<FormTukarShiftPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  LiburkaryawanModel? _selectedPeer;

  @override
  void dispose() {
    _reasonController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LiburkaryawanProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Ajukan Tukar Shift',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Jadwal Shift Saya',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue)),
              const SizedBox(height: 8),
              _buildShiftDetailCard(
                bgColor: Colors.blue.shade50.withOpacity(0.5),
                shift: provider.userShift.shiftName,
                time: provider.userShift.timeRange,
              ),
              const SizedBox(height: 16),
              _buildFieldLabel('Pilih Tanggal'),

              TextFormField(
                // Ubah ke TextFormField agar bisa divalidasi wajib diisi
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                    hintText: 'Tanggal Lembur *',
                    suffixIcon: Icon(Icons.calendar_today_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    )),
                onTap: () async {
                  final now = DateTime.now();
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: now.subtract(const Duration(days: 30)),
                    lastDate: now.add(const Duration(days: 365 * 5)),
                  );

                  if (pickedDate != null) {
                    // 2. GUNAKAN setState BAWAAN PAGE (Bukan setModalState)
                    setState(() {
                      _dateController.text = _formatDate(pickedDate);
                    });
                  }
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Tanggal wajib dipilih'
                    : null,
              ),
              // SECTION 2: DROPDOWN PILIHAN REKAN PENGGANTI
              _buildFieldLabel('Pilih Rekan Pengganti'),
              DropdownButtonFormField2<LiburkaryawanModel>(
                value: _selectedPeer,
                hint: const Text('Pilih Karyawan'),
                buttonStyleData: const ButtonStyleData(
                  height: 50,
                ),
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                  contentPadding: const EdgeInsets.fromLTRB(-8, 4, 8, 4),
                ),
                items: provider.karyawanLain.map((LiburkaryawanModel emp) {
                  return DropdownMenuItem<LiburkaryawanModel>(
                    value: emp,
                    child: Row(
                      children: [
                        CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[200],
                            child: const Icon(Icons.person, size: 22)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              emp.nama,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              emp.role,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ))
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (newValue) =>
                    setState(() => _selectedPeer = newValue),
                validator: (value) =>
                    value == null ? 'Rekan pengganti wajib dipilih' : null,
              ),

              const SizedBox(height: 16),

              // SECTION 3: JADWAL PENGGANTI (OTOMATIS MUNCUL)
              if (_selectedPeer != null) ...[
                Text('Jadwal Pengganti (Shift ${_selectedPeer!.nama})',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple)),
                const SizedBox(height: 8),
                _buildShiftDetailCard(
                  bgColor: Colors.purple.shade50.withOpacity(0.5),
                  shift: _selectedPeer!.shiftName,
                  time: _selectedPeer!.timeRange,
                ),
                const SizedBox(height: 16),
              ],

              // SECTION 4: ALASAN TUKAR SHIFT
              _buildFieldLabel('Alasan Tukar Shift'),
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                maxLength: 1000,
                decoration: InputDecoration(
                  hintText: 'Ada urusan penting di sore hari.',
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                  contentPadding: const EdgeInsets.all(12),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Alasan wajib diisi'
                    : null,
              ),
              const SizedBox(height: 20),

              // TOMBOL SUBMIT UTAMA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        _selectedPeer != null) {
                      context
                          .read<LiburkaryawanProvider>()
                          .addSubmit(submitLiburKaryawan(
                            id: 'TSH-202606-${DateTime.now().millisecond}',
                            type: 'Tukar Shift',
                            date:
                                '${_dateController.text} • ${provider.userShift.shiftName} → ${_selectedPeer!.shiftName}',
                            status: 'Menunggu Rekan',
                            note: _reasonController.text,
                            peerName: _selectedPeer!.nama,
                          ));
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Ajukan Tukar Shift',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
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
          children: const [
            TextSpan(text: ' *', style: TextStyle(color: Colors.red))
          ],
        ),
      ),
    );
  }

  Widget _buildShiftDetailCard(
      {required Color bgColor, required String shift, required String time}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Table(
        columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(2.5)},
        children: [
          _buildTableRow('Shift', shift),
          _buildTableRow('Jam', time),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Colors.black54))),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo))),
      ],
    );
  }
}
