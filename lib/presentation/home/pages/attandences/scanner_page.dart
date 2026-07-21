// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:flutter_absensi_app/core/core.dart';
import '../../bloc/check_qr/check_qr_bloc.dart';
import '../../bloc/get_qrcode_checkin/get_qrcode_checkin_bloc.dart';
import 'attendance_result_page.dart';

class ScannerPage extends StatefulWidget {
  final bool isCheckin;
  final String idSchedule;

  const ScannerPage({
    super.key,
    required this.isCheckin,
    required this.idSchedule,
  });

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  late final MobileScannerController cameraController;

  Barcode? _barcode;
  bool isScan = false;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      autoStart: true,
      torchEnabled: false,
    );
  }

  // FIX 1: kembalikan tipe return void (bukan Future<void>)
  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (!mounted || isScan) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode != null && barcode.displayValue != null) {
      setState(() {
        _barcode = barcode;
        isScan = true;
      });

      context.read<GetQrcodeCheckinBloc>().add(
            GetQrcodeCheckinEvent.getQrcodeCheckin(
              barcode.displayValue!,
              widget.isCheckin,
            ),
          );
    }
  }

  Widget _buildBarcode(Barcode? value) {
    if (value == null) {
      return const Text(
        'Scan sesuatu!',
        overflow: TextOverflow.fade,
        style: TextStyle(color: Colors.white),
      );
    }

    return Text(
      value.displayValue ?? 'Tidak ada nilai.',
      overflow: TextOverflow.fade,
      style: const TextStyle(color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            // Cukup pop, dispose() akan dipanggil otomatis oleh Lifecycle Widget
            Navigator.pop(context);
          },
        ),
        title: const Text('Scanning'),
        actions: [
          // FIX 2: Listen ke cameraController langsung untuk mengecek status Torch
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: cameraController,
            builder: (context, state, child) {
              final isTorchOn = state.torchState == TorchState.on;
              return IconButton(
                icon: Icon(
                  isTorchOn ? Icons.flash_on : Icons.flash_off,
                  color: isTorchOn ? Colors.yellow : Colors.grey,
                ),
                onPressed: () => cameraController.toggleTorch(),
              );
            },
          ),
          // Tombol Switch Kamera
          IconButton(
            icon: const Icon(Icons.cameraswitch, color: Colors.white),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _handleBarcode,
          ),
          MultiBlocListener(
            listeners: [
              BlocListener<GetQrcodeCheckinBloc, GetQrcodeCheckinState>(
                listener: (context, state) {
                  state.maybeWhen(
                    orElse: () {},
                    success: (data, isCheckin) {
                      final now = DateTime.now();
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(now);
                      context.read<CheckQrBloc>().add(CheckQrEvent.checkQr(
                          data,
                          formattedDate,
                          isCheckin ? 'qr_checkin' : 'qr_checkout'));
                    },
                  );
                },
              ),
              BlocListener<CheckQrBloc, CheckQrState>(
                listener: (context, state) {
                  state.maybeWhen(
                    orElse: () {},
                    error: (error) {
                      setState(() {
                        isScan = false;
                      });
                      context.pushReplacement(AttendanceResultPage(
                        isMatch: false,
                        isCheckin: widget.isCheckin,
                        attendanceType: 'QR',
                        idSchedule: widget.idSchedule,
                      ));
                      context
                          .read<GetQrcodeCheckinBloc>()
                          .add(GetQrcodeCheckinEvent.started());
                      context.read<CheckQrBloc>().add(CheckQrEvent.started());
                    },
                    success: (isValid) {
                      context.pushReplacement(AttendanceResultPage(
                        isMatch: true,
                        isCheckin: widget.isCheckin,
                        attendanceType: 'QR',
                        idSchedule: widget.idSchedule,
                      ));
                    },
                  );
                },
              ),
            ],
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.black.withOpacity(0.5),
                child: _buildBarcode(_barcode),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
