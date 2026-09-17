import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'package:flutter_absensi_app/core/core.dart';

import 'face_detector_painter.dart';
import 'attandences/camera_view_attendance_page.dart';

import '../../../core/ml/recognition_embedding.dart';
import '../../../core/ml/recognizer.dart';
import '../../profile/bloc/get_user/get_user_bloc.dart';
import '../bloc/update_user_register_face/update_user_register_face_bloc.dart';
import 'main_page.dart';

class RegisterFacePage extends StatefulWidget {
  const RegisterFacePage({super.key});

  @override
  State<RegisterFacePage> createState() => _RegisterFacePageState();
}

class _RegisterFacePageState extends State<RegisterFacePage> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: false,
      enableLandmarks: false,
      enableClassification: true,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  bool _isDisposed = false;
  bool _isModelDownloaded = false;
  bool _isCameraInitialized = false;
  CustomPaint? _customPaint;
  var _cameraLensDirection = CameraLensDirection.front;

  late List<RecognitionEmbedding> recognitions = [];
  CameraImage? frame;

  late Recognizer recognizer;
  bool isTakePicture = false;
  bool _isRegisterLoading = false;
  String _cameraKey = 'initial_camera_key';

  img.Image? image;
  img.Image? capturedImage;
  List<double>? capturedEmbedding;
  CameraImage? currentCameraImage;

  @override
  void initState() {
    super.initState();
    recognizer = Recognizer();
    _checkAndDownloadFaceModel();
  }

  @override
  void dispose() {
    _canProcess = false;
    _isDisposed = true;
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _checkAndDownloadFaceModel() async {
    try {
      log('📥 Menunggu inisialisasi awal Google Play Services di background...');
      await Future.delayed(const Duration(milliseconds: 2200));
      log('✅ Jeda selesai. Membuka gerbang pemrosesan.');
      if (mounted && !_isDisposed) {
        setState(() {
          _isModelDownloaded = true;
        });
      }
    } catch (e) {
      log('❌ Terjadi kesalahan pada jeda inisialisasi: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _isModelDownloaded = true;
        });
      }
    }
  }

  void _takePicture(CameraImage cameraImage) async {
    if (_isDisposed || _isBusy) return;

    _isBusy = true;
    log('🎯 _takePicture dipanggil dari kedipan sukses berkualitas');

    setState(() {
      frame = cameraImage;
      currentCameraImage = cameraImage;
    });

    try {
      final inputImage = _inputImageFromCameraImage(cameraImage);
      if (inputImage != null) {
        log('🔍 Memproses pemindaian wajah ML Kit...');
        final faces = await _faceDetector.processImage(inputImage);
        log('👤 Jumlah wajah terdeteksi: ${faces.length}');

        if (faces.isNotEmpty) {
          await performFaceRegistration(faces);
        } else {
          if (mounted) {
            context.showError("Gagal memproses detail kontur wajah.");
          }
        }
      } else {
        log('❌ InputImage null, gagal mengonversi frame kamera.');
      }
    } catch (e, stack) {
      log('❌ Error pada _takePicture: $e');
      log('📌 Stacktrace: $stack');
    } finally {
      _isBusy = false;
    }
  }

  Future<void> performFaceRegistration(List<Face> faces) async {
    log('🔄 performFaceRegistration called with ${faces.length} faces');
    recognitions.clear();

    final CameraImage? imgFrame = currentCameraImage;
    if (imgFrame == null) {
      log('❌ currentCameraImage null');
      return;
    }

    try {
      log('🖼️ Mengonversi NV21 ke img.Image...');
      final rawImage = convertNV21ToImage(imgFrame);
      if (rawImage == null) {
        log('❌ Gagal mengonversi NV21 ke img.Image');
        if (mounted) context.showError("Gagal memproses gambar dari kamera.");
        return;
      }

      final Face face = faces.first;
      Rect faceRect = face.boundingBox;

      final int rotateAngle =
          _cameraLensDirection == CameraLensDirection.front ? 270 : 90;

      final img.Image rotatedFullImage =
          img.copyRotate(rawImage, angle: rotateAngle);

      capturedImage = rotatedFullImage;

      try {
        final img.Image croppedFace = img.copyCrop(
          rotatedFullImage,
          x: faceRect.left.toInt().clamp(0, rotatedFullImage.width - 1),
          y: faceRect.top.toInt().clamp(0, rotatedFullImage.height - 1),
          width: faceRect.width.toInt().clamp(1, rotatedFullImage.width),
          height: faceRect.height.toInt().clamp(1, rotatedFullImage.height),
        );

        final RecognitionEmbedding recognition = recognizer.recognize(
          croppedFace,
          face.boundingBox,
        );
        capturedEmbedding = recognition.embedding;
      } catch (e) {
        log('⚠️ Recognizer error (diabaikan untuk pendaftaran gambar): $e');
        capturedEmbedding = [];
      }

      if (mounted) {
        log('🚀 Membuka _showConfirmationDialog()...');
        _showConfirmationDialog();
      }
    } catch (e, stack) {
      log('❌ Error pada performFaceRegistration: $e');
      log('📌 Stacktrace: $stack');
      if (mounted) {
        context.showError("Terjadi kesalahan saat memproses foto wajah.");
      }
    }
  }

  void _showConfirmationDialog() {
    if (capturedImage == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Konfirmasi Foto Wajah',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0A49B7),
                ),
                textAlign: TextAlign.center,
              ),
              const SpaceHeight(20),
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF0A49B7),
                    width: 2,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.memory(
                  Uint8List.fromList(img.encodeJpg(capturedImage!)),
                  fit: BoxFit.cover,
                ),
              ),
              const SpaceHeight(20),
              Text(
                'Pastikan wajah Anda terlihat jelas pada foto di atas',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SpaceHeight(24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isRegisterLoading
                          ? null
                          : () {
                              Navigator.pop(dialogContext);
                              setState(() {
                                _cameraKey = DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString();
                                frame = null;
                                currentCameraImage = null;
                                capturedImage = null;
                                capturedEmbedding = null;
                              });
                            },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF0A49B7)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Ulangi',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0A49B7),
                        ),
                      ),
                    ),
                  ),
                  const SpaceWidth(12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isRegisterLoading
                          ? null
                          : () async {
                              if (_isRegisterLoading) return;
                              setState(() {
                                _isRegisterLoading = true;
                              });

                              try {
                                final tempDir = await getTemporaryDirectory();
                                final uniqueSuffix =
                                    DateTime.now().millisecondsSinceEpoch;
                                final fileImagePath =
                                    '${tempDir.path}/face_register_$uniqueSuffix.jpg';
                                final file = File(fileImagePath);

                                final resizedImage =
                                    img.copyResize(capturedImage!, width: 480);
                                await file.writeAsBytes(
                                    img.encodeJpg(resizedImage, quality: 85));

                                if (!mounted) return;

                                context.read<UpdateUserRegisterFaceBloc>().add(
                                      UpdateUserRegisterFaceEvent
                                          .updateProfileRegisterFace(
                                        fileImagePath,
                                        null,
                                      ),
                                    );

                                Navigator.pop(dialogContext);
                              } catch (e) {
                                if (mounted) {
                                  setState(() {
                                    _isRegisterLoading = false;
                                  });
                                  context.showError(
                                      "Gagal menyiapkan file registrasi.");
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A49B7),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isRegisterLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Daftar',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🎨 PERBAIKAN KONVERSI: Mendukung NV21 (1-plane) & YUV420 (3-plane) secara presisi berwarna
  img.Image? convertNV21ToImage(CameraImage cameraImage) {
    try {
      final width = cameraImage.width;
      final height = cameraImage.height;
      final outImg = img.Image(width: width, height: height);

      // 1. Format NV21 / Single Plane (Perangkat Android CameraX Direct)
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

      // 2. Format YUV420 Multi Planes (3 Planes)
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
                uvIndex >= vPlane.length) continue;

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
      log('❌ Error convertNV21ToImage: $e');
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
        final chromaRowStride =
            image.planes.length > 1 ? image.planes[1].bytesPerRow : width;
        final chromaPixelStride =
            image.planes.length > 1 ? (image.planes[1].bytesPerPixel ?? 1) : 1;

        for (int row = 0; row < height ~/ 2; row++) {
          for (int col = 0; col < width ~/ 2; col++) {
            final idx = row * chromaRowStride + col * chromaPixelStride;
            if (idx < vPlane.length && idx < uPlane.length) {
              nv21[offset++] = vPlane[idx];
              nv21[offset++] = uPlane[idx];
            }
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

  Widget _buildSingleUnifiedLoading() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
        ),
      ),
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
              'Memulai kamera...',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateUserRegisterFaceBloc,
        UpdateUserRegisterFaceState>(
      listener: (context, state) {
        state.maybeWhen(
          orElse: () {},
          loading: () {
            setState(() {
              _isRegisterLoading = true;
            });
          },
          success: (user) {
            setState(() {
              _isRegisterLoading = false;
            });
            if (!mounted) return;
            context.showSuccess("Wajah berhasil didaftarkan ke server!");

            context.read<GetUserBloc>().add(const GetUserEvent.getUser());

            Future.delayed(const Duration(milliseconds: 1200), () {
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MainPage()),
                  (route) => false,
                );
              }
            });
          },
          error: (message) {
            setState(() {
              _isRegisterLoading = false;
            });
            if (mounted) context.showError(message);
          },
        );
      },
      child: Scaffold(
        body: Stack(
          children: [
            CameraViewAttendancePage(
              key: ValueKey(_cameraKey),
              title: 'Register Face',
              customPaint: _customPaint,
              onImage: (img) {},
              initialCameraLensDirection: _cameraLensDirection,
              onTakePicture: _takePicture,
              isModelReady: _isModelDownloaded,
              onCameraFeedReady: () {
                if (mounted) {
                  setState(() {
                    _isCameraInitialized = true;
                  });
                }
              },
            ),
            if (!_isModelDownloaded || !_isCameraInitialized)
              _buildSingleUnifiedLoading(),
          ],
        ),
      ),
    );
  }
}
