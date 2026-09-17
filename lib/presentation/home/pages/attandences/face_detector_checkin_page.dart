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
      performanceMode: FaceDetectorMode.fast,
      enableContours: false,
      enableLandmarks: false,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  var _cameraLensDirection = CameraLensDirection.front;

  late List<RecognitionEmbedding> recognitions = [];
  CameraImage? frame;

  late Recognizer recognizer;
  bool isTakePicture = false;
  bool _isActionLoading = false;
  bool _isDialogShowing = false;
  bool _isDownloadingMasterFace = true;
  String? _masterFaceErrorMessage;

  String _cameraKey = 'initial_checkin_camera_key';
  List<double>? _serverMasterEmbedding;

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

  // Helper 1: Normalisasi L2 Vector Embedding
  List<double> _normalizeEmbedding(List<double> embedding) {
    double sum = 0.0;
    for (var val in embedding) {
      sum += val * val;
    }
    double magnitude = sqrt(sum);
    if (magnitude == 0.0) return embedding;
    return embedding.map((e) => e / magnitude).toList();
  }

  // Helper 2: Crop Wajah dengan Margin/Padding agar tidak terpotong kaku
  img.Image _cropFaceWithPadding(img.Image srcImage, Rect faceRect) {
    const double paddingFactor = 0.15; // 15% margin di sekitar wajah
    final double padW = faceRect.width * paddingFactor;
    final double padH = faceRect.height * paddingFactor;

    final int x = (faceRect.left - padW).toInt().clamp(0, srcImage.width - 1);
    final int y = (faceRect.top - padH).toInt().clamp(0, srcImage.height - 1);
    final int w =
        (faceRect.width + (padW * 2)).toInt().clamp(1, srcImage.width - x);
    final int h =
        (faceRect.height + (padH * 2)).toInt().clamp(1, srcImage.height - y);

    return img.copyCrop(srcImage, x: x, y: y, width: w, height: h);
  }

  // Helper 3: Hitung Normalized Euclidean Distance
  double _calculateEuclideanDistance(List<double> emb1, List<double> emb2) {
    final norm1 = _normalizeEmbedding(emb1);
    final norm2 = _normalizeEmbedding(emb2);

    double sum = 0.0;
    for (int i = 0; i < norm1.length; i++) {
      double diff = norm1[i] - norm2[i];
      sum += diff * diff;
    }
    return sqrt(sum);
  }

  Future<void> _fetchAndPrepareMasterFace() async {
    setState(() {
      _isDownloadingMasterFace = true;
      _masterFaceErrorMessage = null;
    });

    try {
      final url = Uri.parse('${Variables.baseUrl}/face/status');
      final response = await ApiClient.instance.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final String? imageUrl = decoded['data']?['imageface_register'];

        if (imageUrl != null && imageUrl.isNotEmpty) {
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
                final img.Image croppedMasterFace =
                    _cropFaceWithPadding(masterImage, face.boundingBox);

                final RecognitionEmbedding masterRecognition =
                    recognizer.recognize(
                  croppedMasterFace,
                  face.boundingBox,
                );

                if (masterRecognition.embedding.isNotEmpty) {
                  _serverMasterEmbedding = masterRecognition.embedding;
                  _masterFaceErrorMessage = null;
                } else {
                  _masterFaceErrorMessage =
                      'Gagal mengekstrak fitur biometrik dari foto terdaftar.';
                }
              } else {
                _masterFaceErrorMessage =
                    'Wajah tidak terdeteksi pada foto master server.';
              }
            } else {
              _masterFaceErrorMessage = 'Format foto master tidak valid.';
            }
          } else {
            _masterFaceErrorMessage =
                'Gagal mengunduh foto master (Kode: ${fileResponse.statusCode}).';
          }
        } else {
          _masterFaceErrorMessage =
              'Akun Anda belum memiliki foto wajah terdaftar pada cabang ini.';
        }
      } else {
        _masterFaceErrorMessage =
            'Gagal memeriksa status biometrik (Kode: ${response.statusCode}).';
      }
    } catch (e) {
      _masterFaceErrorMessage = 'Gagal sinkronisasi data biometrik: $e';
    } finally {
      if (mounted) {
        setState(() {
          _isDownloadingMasterFace = false;
        });
      }
    }
  }

  void _takePicture(CameraImage cameraImage) async {
    if (!mounted ||
        !_canProcess ||
        _isDialogShowing ||
        _isDownloadingMasterFace) return;

    if (_serverMasterEmbedding == null) {
      context.showError(
        _masterFaceErrorMessage ??
            'Data biometrik belum tersinkronisasi. Silakan muat ulang.',
      );
      _resetCameraViewManual();
      return;
    }

    setState(() {
      _canProcess = false;
      frame = cameraImage;
      isTakePicture = true;
    });

    try {
      final rawImage = _convertCameraImageToRgb(cameraImage);
      if (rawImage == null) {
        context.showError('Gagal membaca gambar dari kamera.');
        _resetCameraViewManual();
        return;
      }

      capturedImage = img.copyRotate(
        rawImage,
        angle: _cameraLensDirection == CameraLensDirection.front ? 270 : 90,
      );

      final inputImage = _inputImageFromCameraImage(cameraImage);
      if (inputImage == null) {
        context.showError('Format citra kamera tidak valid.');
        _resetCameraViewManual();
        return;
      }

      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        context
            .showError('Wajah tidak terdeteksi. Posisikan wajah Anda kembali.');
        _resetCameraViewManual();
        return;
      }

      final Face face = faces.first;
      final img.Image croppedFace =
          _cropFaceWithPadding(capturedImage!, face.boundingBox);

      final RecognitionEmbedding currentFace = recognizer.recognize(
        croppedFace,
        face.boundingBox,
      );

      if (currentFace.embedding.isEmpty) {
        context.showError('Gagal memproses fitur wajah saat ini.');
        _resetCameraViewManual();
        return;
      }

      // Hitung Normalized Euclidean Distance
      final double distance = _calculateEuclideanDistance(
        currentFace.embedding,
        _serverMasterEmbedding!,
      );
      debugPrint('📏 Normalized Euclidean Distance: $distance');

      // Nilai threshold ideal dan stabil (0.90)
      const double threshold = 0.90;
      if (distance > threshold) {
        if (mounted) {
          context.showError(
            'Verifikasi Gagal: Wajah tidak cocok (Skor: ${distance.toStringAsFixed(2)})',
          );
        }
        _resetCameraViewManual();
        return;
      }

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      debugPrint('❌ Error validasi biometrik: $e');
      if (mounted) {
        context.showError('Terjadi kesalahan validasi: $e');
      }
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
    if (_isDialogShowing) return;
    setState(() {
      _isDialogShowing = true;
      _canProcess = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
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
                          colors: [
                            Colors.green.shade400,
                            Colors.green.shade600
                          ],
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
                          colors: [
                            Colors.green.shade400,
                            Colors.green.shade600
                          ],
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
                                Uint8List.fromList(
                                    img.encodeJpg(capturedImage!)),
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
        },
      ),
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

                  if (widget.isCheckedIn) {
                    context.read<CheckinAttendanceBloc>().add(
                          CheckinAttendanceEvent.checkin(
                              latitute: widget.latitude ?? 0.0,
                              longitude: widget.longitude ?? 0.0,
                              imagePath: fileImagePath,
                              idSchedule: widget.idSchedule),
                        );
                  } else {
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
                  debugPrint('❌ Gagal mengolah berkas citra absensi: $e');
                  setDialogState(() {
                    _isActionLoading = false;
                  });
                  setState(() {
                    _isActionLoading = false;
                  });
                  context.showError('Gagal memproses file gambar absensi.');
                }
              },
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

  img.Image? _convertCameraImageToRgb(CameraImage cameraImage) {
    try {
      final width = cameraImage.width;
      final height = cameraImage.height;
      final outImg = img.Image(width: width, height: height);

      if (cameraImage.format.group == ImageFormatGroup.nv21 ||
          cameraImage.planes.length == 1) {
        final nv21Bytes = cameraImage.planes[0].bytes;
        final int frameSize = width * height;

        for (int j = 0; j < height; j++) {
          for (int i = 0; i < width; i++) {
            final int yIndex = j * width + i;
            final int uvIndex = frameSize + (j >> 1) * width + (i & ~1);

            if (yIndex >= nv21Bytes.length || uvIndex + 1 >= nv21Bytes.length) {
              continue;
            }

            final int y = nv21Bytes[yIndex] & 0xff;
            final int v = (nv21Bytes[uvIndex] & 0xff) - 128;
            final int u = (nv21Bytes[uvIndex + 1] & 0xff) - 128;

            int r = (y + (1.370705 * v)).round().clamp(0, 255);
            int g = (y - (0.337633 * u) - (0.698001 * v)).round().clamp(0, 255);
            int b = (y + (1.732446 * u)).round().clamp(0, 255);

            outImg.setPixelRgb(i, j, r, g, b);
          }
        }
        return outImg;
      }

      if (cameraImage.planes.length >= 3) {
        final yPlane = cameraImage.planes[0].bytes;
        final uPlane = cameraImage.planes[1].bytes;
        final vPlane = cameraImage.planes[2].bytes;

        final uvRowStride = cameraImage.planes[1].bytesPerRow;
        final uvPixelStride = cameraImage.planes[1].bytesPerPixel ?? 1;

        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            final yIndex = y * width + x;
            final uvIndex = (y >> 1) * uvRowStride + (x >> 1) * uvPixelStride;

            if (yIndex >= yPlane.length ||
                uvIndex >= uPlane.length ||
                uvIndex >= vPlane.length) {
              continue;
            }

            final yValue = yPlane[yIndex] & 0xFF;
            final uValue = (uPlane[uvIndex] & 0xFF) - 128;
            final vValue = (vPlane[uvIndex] & 0xFF) - 128;

            int r = (yValue + 1.402 * vValue).round().clamp(0, 255);
            int g = (yValue - 0.344136 * uValue - 0.714136 * vValue)
                .round()
                .clamp(0, 255);
            int b = (yValue + 1.772 * uValue).round().clamp(0, 255);

            outImg.setPixelRgb(x, y, r, g, b);
          }
        }
        return outImg;
      }
    } catch (e) {
      debugPrint('❌ Error converting CameraImage to RGB: $e');
    }
    return null;
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

      Uint8List bytes;
      if (image.planes.length == 1) {
        bytes = image.planes[0].bytes;
      } else {
        final yPlane = image.planes[0].bytes;
        final uPlane = image.planes[1].bytes;
        final vPlane = image.planes[2].bytes;

        final nv21 = Uint8List(width * height + (width * height ~/ 2));
        nv21.setRange(0, width * height, yPlane);

        int offset = width * height;
        final chromaRowStride = image.planes[1].bytesPerRow;
        final chromaPixelStride = image.planes[1].bytesPerPixel ?? 1;

        for (int row = 0; row < height ~/ 2; row++) {
          for (int col = 0; col < width ~/ 2; col++) {
            final idx = row * chromaRowStride + col * chromaPixelStride;
            nv21[offset++] = vPlane[idx];
            nv21[offset++] = uPlane[idx];
          }
        }
        bytes = nv21;
      }

      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.width,
      );

      return InputImage.fromBytes(bytes: bytes, metadata: metadata);
    } catch (_) {
      return null;
    }
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess || _isBusy) return;
    _isBusy = true;

    try {
      if (!mounted) return;

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
      debugPrint("❌ Error saat proses image: $e");
    } finally {
      _isBusy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
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
            if (!_isDownloadingMasterFace && _serverMasterEmbedding == null)
              Container(
                color: Colors.black.withOpacity(0.92),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.redAccent,
                        size: 64,
                      ),
                      const SpaceHeight(16),
                      Text(
                        'Sinkronisasi Wajah Gagal',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SpaceHeight(8),
                      Text(
                        _masterFaceErrorMessage ??
                            'Data master wajah tidak ditemukan untuk cabang saat ini.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SpaceHeight(24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white38),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Kembali',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          ),
                          const SpaceWidth(12),
                          ElevatedButton.icon(
                            onPressed: _fetchAndPrepareMasterFace,
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: Text(
                              'Coba Lagi',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
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
