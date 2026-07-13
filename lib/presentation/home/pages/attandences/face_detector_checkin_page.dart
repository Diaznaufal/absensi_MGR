// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/checkout_attendance/checkout_attendance_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/is_checkedin/is_checkedin_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/pages/main_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_absensi_app/core/core.dart';
import 'package:flutter_absensi_app/core/constants/variables.dart';
import 'package:flutter_absensi_app/core/network/api_client.dart';
import 'package:flutter_absensi_app/data/models/request/checkinout_request_model.dart';

import '../face_detector_painter.dart';
import '../../bloc/checkin_attendance/checkin_attendance_bloc.dart';

import '../../../../core/ml/recognition_embedding.dart';
import '../../../../core/ml/recognizer.dart';
import '../attendance_success_page.dart';
import 'camera_view_attendance_page.dart';

class FaceDetectorCheckinPage extends StatefulWidget {
  final bool isCheckedIn;
  final double? latitude;
  final double? longitude;
  final String idSchedule;

  const FaceDetectorCheckinPage({
    super.key,
    required this.isCheckedIn,
    this.latitude,
    this.longitude,
    required this.idSchedule,
  });

  @override
  State<FaceDetectorCheckinPage> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorCheckinPage> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: false,
      enableLandmarks: false,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;

  late List<RecognitionEmbedding> recognitions = [];
  CameraImage? frame;

  late Recognizer recognizer;
  bool isTakePicture = false;
  bool _isActionLoading = false;
  bool _isDialogShowing = false;
  bool _isDownloadingMasterFace = true;

  String _cameraKey = 'initial_checkin_camera_key';
  List<double>? _serverMasterEmbedding;

  img.Image? image;
  img.Image? capturedImage;

  @override
  void initState() {
    super.initState();
    recognizer = Recognizer();
    _fetchAndPrepareMasterFace();
  }

  @override
  void dispose() {
    _canProcess = false;
    _isBusy = false;
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _fetchAndPrepareMasterFace() async {
    try {
      print(
          '📥 Menghubungi server untuk memuat profil foto wajah terdaftar...');
      final url = Uri.parse('${Variables.baseUrl}/face/status');
      final response = await ApiClient.instance.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final String? imageUrl = decoded['data']['imageface_register'];

        if (imageUrl != null && imageUrl.isNotEmpty) {
          print('🌐 Mengunduh data biner master foto wajah: $imageUrl');
          final fileResponse = await http.get(Uri.parse(imageUrl));

          if (fileResponse.statusCode == 200) {
            final Uint8List bytes = fileResponse.bodyBytes;
            final img.Image? masterImage = img.decodeImage(bytes);

            if (masterImage != null) {
              final tempDir = await getTemporaryDirectory();
              final tempFile = File('${tempDir.path}/temp_master_face.jpg');
              await tempFile.writeAsBytes(bytes);

              final inputImage = InputImage.fromFilePath(tempFile.path);
              final faces = await _faceDetector.processImage(inputImage);

              if (faces.isNotEmpty) {
                final Face face = faces.first;
                Rect faceRect = face.boundingBox;

                // 🆕 PERBAIKAN UTAMA: Potong (Crop) area wajah master terlebih dahulu!
                final img.Image croppedMasterFace = img.copyCrop(
                  masterImage,
                  x: faceRect.left.toInt().clamp(0, masterImage.width - 1),
                  y: faceRect.top.toInt().clamp(0, masterImage.height - 1),
                  width: faceRect.width.toInt().clamp(1, masterImage.width),
                  height: faceRect.height.toInt().clamp(1, masterImage.height),
                );

                // Ekstrak matriks dari wajah yang SUDAH DI-CROP agar seimbang dengan live frame
                final RecognitionEmbedding masterRecognition =
                    recognizer.recognize(
                  croppedMasterFace, // 👈 Gunakan hasil crop di sini
                  face.boundingBox,
                );

                if (masterRecognition.embedding.isNotEmpty) {
                  _serverMasterEmbedding = masterRecognition.embedding;
                  print(
                      '✅ Master Biometrik Akun Berhasil Di-generate Secara Seimbang di Memori.');
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print('⚠️ Gagal memproses sinkronisasi wajah server secara lokal: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isDownloadingMasterFace = false;
        });
      }
    }
  }

  void _takePicture(CameraImage cameraImage) async {
    print(
        '📸 _takePicture dipanggil dari kedipan sukses berkualitas kamera view');
    if (!mounted ||
        !_canProcess ||
        _isDialogShowing ||
        _isDownloadingMasterFace) return;

    setState(() {
      _canProcess = false;
      frame = cameraImage;
      isTakePicture = true;
    });

    try {
      final rawImage = convertNV21ToImage(cameraImage);
      if (rawImage == null) {
        print('❌ Gagal mengonversi raw image ke objek gambar');
        _resetCameraViewManual();
        return;
      }

      capturedImage = img.copyRotate(
        rawImage,
        angle: _cameraLensDirection == CameraLensDirection.front ? 270 : 90,
      );

      final inputImage = _inputImageFromCameraImage(cameraImage);
      if (inputImage != null && _serverMasterEmbedding != null) {
        final faces = await _faceDetector.processImage(inputImage);

        if (faces.isNotEmpty) {
          final Face face = faces.first;
          Rect faceRect = face.boundingBox;

          final img.Image croppedFace = img.copyCrop(
            capturedImage!,
            x: faceRect.left.toInt().clamp(0, capturedImage!.width - 1),
            y: faceRect.top.toInt().clamp(0, capturedImage!.height - 1),
            width: faceRect.width.toInt().clamp(1, capturedImage!.width),
            height: faceRect.height.toInt().clamp(1, capturedImage!.height),
          );

          final RecognitionEmbedding currentFace = recognizer.recognize(
            croppedFace,
            face.boundingBox,
          );

          double distance = 0.0;
          for (int i = 0; i < currentFace.embedding.length; i++) {
            double diff = currentFace.embedding[i] - _serverMasterEmbedding![i];
            distance += diff * diff;
          }
          distance = sqrt(distance);
          print('📏 Jarak Euclidean Perbandingan Wajah Lokal di HP: $distance');

          if (distance > 1.0) {
            print('❌ PROTEKSI AKTIF: Wajah tidak cocok dengan akun terdaftar!');
            if (mounted) {
              context.showError(
                  'Verifikasi Gagal: Wajah Anda tidak cocok dengan pemilik terdaftar akun ini!');
            }
            _resetCameraViewManual();
            return;
          }
        }
      }

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      print('❌ Error saat memproses jepretan wajah: $e');
      _resetCameraViewManual();
    }
  }

  void _resetCameraViewManual() {
    if (mounted) {
      setState(() {
        _cameraKey = DateTime.now().millisecondsSinceEpoch.toString();
        isTakePicture = false;
        frame = null;
        capturedImage = null;
        _isDialogShowing = false;
        _canProcess = true;
      });
    }
  }

  void _showSuccessDialog() {
    print('🎉 Menampilkan dialog review konfirmasi absensi');
    if (_isDialogShowing) return;
    setState(() {
      _isDialogShowing = true;
      _canProcess = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          StatefulBuilder(builder: (context, setDialogState) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.green.shade50.withOpacity(0.3),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade600],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SpaceHeight(16),
                  Text(
                    'Wajah Terverifikasi!',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1e3c72),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SpaceHeight(6),
                  Text(
                    'Siap mengirim berkas data absensi ke server',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SpaceHeight(16),
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade600],
                      ),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        color: Colors.white,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: capturedImage != null
                          ? Image.memory(
                              Uint8List.fromList(img.encodeJpg(capturedImage!)),
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.grey[100],
                              child: Icon(Icons.person,
                                  size: 80, color: Colors.grey[400]),
                            ),
                    ),
                  ),
                  const SpaceHeight(16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.green.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Colors.green.shade700,
                          size: 18,
                        ),
                        const SpaceWidth(8),
                        Expanded(
                          child: Text(
                            widget.isCheckedIn
                                ? 'Posisi wajah sudah pas. Tekan kirim untuk melanjutkan check in.'
                                : 'Posisi wajah sudah pas. Tekan kirim untuk melanjutkan check out.',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.green.shade800,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SpaceHeight(20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isActionLoading
                              ? null
                              : () {
                                  Navigator.pop(dialogContext);
                                  setState(() {
                                    _isDialogShowing = false;
                                    _canProcess = true;
                                  });
                                  _resetCameraViewManual();
                                },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Ulangi',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      const SpaceWidth(12),
                      Expanded(
                        child: _buildLocalSubmitButton(
                            dialogContext, setDialogState),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLocalSubmitButton(
      BuildContext dialogContext, StateSetter setDialogState) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isActionLoading
            ? null
            : () async {
                if (frame == null || capturedImage == null) {
                  context.showError('Gambar kamera kosong atau tidak terbaca.');
                  return;
                }

                setDialogState(() {
                  _isActionLoading = true;
                });
                setState(() {
                  _isActionLoading = true;
                });

                try {
                  final tempDir = await getTemporaryDirectory();
                  final uniqueSuffix = DateTime.now().millisecondsSinceEpoch;
                  final fileImagePath =
                      '${tempDir.path}/face_checkin_$uniqueSuffix.jpg';
                  final file = File(fileImagePath);

                  final resizedImage =
                      img.copyResize(capturedImage!, width: 480);
                  await file
                      .writeAsBytes(img.encodeJpg(resizedImage, quality: 85));

                  if (!mounted) return;

                  // 🔥 KONDISI DINAMIS: Cek apakah absen datang (Check-In) atau pulang (Check-Out)
                  if (widget.isCheckedIn) {
                    context.read<CheckinAttendanceBloc>().add(
                          CheckinAttendanceEvent.checkin(
                              latitute: widget.latitude ?? 0.0,
                              longitude: widget.longitude ?? 0.0,
                              imagePath: fileImagePath,
                              idSchedule: widget.idSchedule),
                        );
                  } else {
                    // 🔥 INTEGRASI BARU: Jalankan BLoc Checkout dengan parameter terupdate (double)
                    context.read<CheckoutAttendanceBloc>().add(
                          CheckoutAttendanceEvent.checkout(
                              latitude: widget.latitude ?? 0.0,
                              longitude: widget.longitude ?? 0.0,
                              imagePath: fileImagePath,
                              idSchedule: widget.idSchedule),
                        );
                  }

                  Navigator.pop(dialogContext);
                } catch (e) {
                  print('❌ Gagal mengolah berkas citra absensi: $e');
                  setDialogState(() {
                    _isActionLoading = false;
                  });
                  setState(() {
                    _isActionLoading = false;
                  });
                  context.showError('Gagal memproses file gambar absensi.');
                }
              },
        // ... properti style tombol Anda ke bawah tetap sama ...
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade500, Colors.green.shade700],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isActionLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 20),
                      const SpaceWidth(4),
                      Text(
                        'Kirim',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void _showErrorDialog() {
    print('⚠️ _showErrorDialog called');
    _canProcess = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.red.shade50.withOpacity(0.3),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade400, Colors.red.shade600],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cancel_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SpaceHeight(16),
                Text(
                  'Absensi Gagal',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SpaceHeight(6),
                Text(
                  'Gagal memverifikasi kecocokan wajah ke server API',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SpaceHeight(20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _canProcess = true;
                          _resetCameraViewManual();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Coba Lagi',
                          style: GoogleFonts.poppins(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SpaceWidth(10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          Navigator.pop(context);
                          context.pushReplacement(const MainPage());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Beranda',
                          style: GoogleFonts.poppins(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  img.Image? convertNV21ToImage(CameraImage cameraImage) {
    try {
      final width = cameraImage.width.toInt();
      final height = cameraImage.height.toInt();
      final yPlane = cameraImage.planes[0].bytes;
      final uvPlane = cameraImage.planes[1].bytes;
      final outImg = img.Image(height: height, width: width);

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final yIndex = y * width + x;
          final uvIndex = ((y >> 1) * (width >> 1) + (x >> 1)) * 2;

          if (yIndex >= yPlane.length || uvIndex + 1 >= uvPlane.length)
            continue;

          final yValue = yPlane[yIndex];
          final uValue = uvPlane[uvIndex];
          final vValue = uvPlane[uvIndex + 1];

          int r = (yValue + 1.370705 * (vValue - 128)).toInt();
          int g =
              (yValue - 0.337633 * (uValue - 128) - 0.698001 * (vValue - 128))
                  .toInt();
          int b = (yValue + 1.732446 * (uValue - 128)).toInt();

          outImg.setPixelRgb(
              x, y, r.clamp(0, 255), g.clamp(0, 255), b.clamp(0, 255));
        }
      }
      return outImg;
    } catch (_) {
      return null;
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    try {
      final orientations = {
        DeviceOrientation.portraitUp: 0,
        DeviceOrientation.landscapeLeft: 90,
        DeviceOrientation.portraitDown: 180,
        DeviceOrientation.landscapeRight: 270,
      };

      final rotationCompensation = orientations[DeviceOrientation.portraitUp]!;
      final rotation = InputImageRotationValue.fromRawValue(
          (270 + rotationCompensation) % 360)!;

      final width = image.width;
      final height = image.height;
      final yPlane = image.planes[0].bytes;
      final uPlane = image.planes[1].bytes;
      final vPlane = image.planes[2].bytes;

      final nv21 = Uint8List(width * height + (width * height ~/ 2));
      nv21.setRange(0, width * height, yPlane);

      int offset = width * height;
      final chromaRowStride = image.planes[1].bytesPerRow;
      final chromaPixelStride = image.planes[1].bytesPerPixel!;

      for (int row = 0; row < height ~/ 2; row++) {
        for (int col = 0; col < width ~/ 2; col++) {
          final idx = row * chromaRowStride + col * chromaPixelStride;
          nv21[offset++] = vPlane[idx];
          nv21[offset++] = uPlane[idx];
        }
      }

      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.width,
      );

      return InputImage.fromBytes(bytes: nv21, metadata: metadata);
    } catch (_) {
      return null;
    }
  }

  // 🆕 FUNGSI UTAMA YANG SEMPAT HILANG (Kini dikembalikan penuh)
  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess || _isBusy) return;
    _isBusy = true;

    try {
      if (!mounted) return;

      setState(() {
        _text = '';
      });
      final faces = await _faceDetector.processImage(inputImage);

      if (!mounted) return;

      if (inputImage.metadata?.size != null &&
          inputImage.metadata?.rotation != null) {
        final painter = FaceDetectorPainter(
          faces,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
        );

        _customPaint = CustomPaint(painter: painter);
      } else {
        _customPaint = null;
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print("❌ Error saat proses image: $e");
    } finally {
      _isBusy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // 1. LISTENER UNTUK CHECK-IN (DATANG)
        BlocListener<CheckinAttendanceBloc, CheckinAttendanceState>(
          listener: (context, state) {
            state.maybeWhen(
              orElse: () {},
              loading: () {
                setState(() {
                  _isActionLoading = true;
                });
              },
              error: (message) {
                setState(() {
                  _isActionLoading = false;
                });
                context.showError(message);
                _showErrorDialog();
              },
              loaded: (response) {
                setState(() {
                  _isActionLoading = false;
                });

                // Pemicu refresh status tombol API tunggal harian
                context
                    .read<IsCheckedinBloc>()
                    .add(const IsCheckedinEvent.isCheckedIn());

                context.showSuccess("Absensi Berhasil diverifikasi server!");

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AttendanceSuccessPage(status: 'Datang'),
                  ),
                );
              },
            );
          },
        ),

        // 2. LISTENER UNTUK CHECK-OUT (PULANG)
        BlocListener<CheckoutAttendanceBloc, CheckoutAttendanceState>(
          listener: (context, state) {
            state.maybeWhen(
              orElse: () {},
              loading: () {
                setState(() {
                  _isActionLoading = true;
                });
              },
              error: (message) {
                setState(() {
                  _isActionLoading = false;
                });
                context.showError(message);
                _showErrorDialog();
              },
              loaded: (response) {
                setState(() {
                  _isActionLoading = false;
                });

                // Pemicu refresh status tombol API tunggal harian
                context
                    .read<IsCheckedinBloc>()
                    .add(const IsCheckedinEvent.isCheckedIn());

                context.showSuccess(
                    "Absensi Pulang Berhasil diverifikasi server!");

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AttendanceSuccessPage(status: 'Pulang'),
                  ),
                );
              },
            );
          },
        ),
      ],
      child: Scaffold(
        body: Stack(
          children: [
            CameraViewAttendancePage(
              key: ValueKey(_cameraKey),
              title: widget.isCheckedIn
                  ? 'Kamera Absensi Datang'
                  : 'Kamera Absensi Pulang',
              customPaint: _customPaint,
              onImage: _processImage,
              initialCameraLensDirection: _cameraLensDirection,
              onCameraLensDirectionChanged: (value) =>
                  _cameraLensDirection = value,
              onTakePicture: _takePicture,
            ),
            if (_isDownloadingMasterFace)
              Container(
                color: Colors.black87,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                      const SpaceHeight(20),
                      Text(
                        'Menyinkronkan Kunci Wajah Akun...',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
