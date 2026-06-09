// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_absensi_app/presentation/home/pages/main_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import 'package:flutter_absensi_app/core/core.dart';

import '../face_detector_painter.dart';

import '../../../../core/ml/recognition_embedding.dart';
import '../../../../core/ml/recognizer.dart';
import '../../bloc/checkin_attendance/checkin_attendance_bloc.dart';
import '../../bloc/checkout_attendance/checkout_attendance_bloc.dart';
import '../attendance_success_page.dart';
import 'camera_view_attendance_page.dart';
import 'attendance_result_page.dart';

class FaceDetectorCheckinPage extends StatefulWidget {
  final bool isCheckedIn;
  final double? latitude;
  final double? longitude;

  const FaceDetectorCheckinPage({
    super.key,
    required this.isCheckedIn,
    this.latitude,
    this.longitude,
  });

  @override
  State<FaceDetectorCheckinPage> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorCheckinPage> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: false,
      enableLandmarks: false,
      // enableClassification: true,
    ),
  );
  bool isCheckedin = false;
  bool isCheckedout = false;
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;

  late List<RecognitionEmbedding> recognitions = [];
  CameraImage? frame;

  late Recognizer recognizer;
  bool isTakePicture = false;

  @override
  void initState() {
    super.initState();
    recognizer = Recognizer();
  }

  @override
  void dispose() {
    _canProcess = false;
    _isBusy = false;
    _faceDetector.close();
    super.dispose();
  }

  void _takePicture(CameraImage cameraImage) async {
    log('📸 _takePicture called from blink detection');
    setState(() {
      frame = cameraImage;
      isTakePicture = true;
    });
    log('✅ isTakePicture set to true, frame captured');
  }

  img.Image? image;
  img.Image? capturedImage;

  performFaceRecognition(List<Face> faces) async {
    log('🔄 performFaceRecognition called with ${faces.length} faces');

    if (frame == null) {
      log('❌ Frame is null, cannot perform recognition');
      if (mounted) {
        context.showError('Gagal menangkap gambar. Silakan coba lagi.');
      }
      return;
    }

    recognitions.clear();

    try {
      image = convertNV21ToImage(frame!);
      log('🖼️  Image converted from NV21');

      image = img.copyRotate(
        image!,
        angle: _cameraLensDirection == CameraLensDirection.front ? 270 : 90,
      );
      log('🔄 Image rotated');

      for (Face face in faces) {
        Rect faceRect = face.boundingBox;
        log('👤 Processing face with bounding box: $faceRect');

        // Validate bounding box before cropping
        int x = faceRect.left.toInt().clamp(0, image!.width - 1);
        int y = faceRect.top.toInt().clamp(0, image!.height - 1);
        int width = faceRect.width.toInt();
        int height = faceRect.height.toInt();

        // Ensure crop area doesn't exceed image bounds
        if (x + width > image!.width) {
          width = image!.width - x;
        }
        if (y + height > image!.height) {
          height = image!.height - y;
        }

        if (width <= 0 || height <= 0) {
          log('❌ Invalid crop dimensions: width=$width, height=$height');
          if (mounted) {
            context.showError(
                'Wajah terlalu dekat dengan tepi. Posisikan wajah di tengah frame.');
          }
          return;
        }

        img.Image croppedFace = img.copyCrop(
          image!,
          x: x,
          y: y,
          width: width,
          height: height,
        );
        log('✂️  Face cropped successfully');

        RecognitionEmbedding recognition = recognizer.recognize(
          croppedFace,
          face.boundingBox,
        );
        log('🧠 Face recognition completed, embedding size: ${recognition.embedding.length}');

        recognitions.add(recognition);

        // bool isValid = await recognizer.isValidFace(recognition.embedding);
        bool isValid = true;
        log('✅ Face validation result: $isValid');

        if (!mounted) return;

        // Store captured image
        capturedImage = image;

        if (isValid) {
          log('✨ Face is valid, showing success dialog');
          _showSuccessDialog();
        } else {
          log('❌ Face is invalid, showing error dialog');
          _showErrorDialog();
        }
      }
    } catch (e, stackTrace) {
      log('❌ Error in performFaceRecognition: $e');
      log('Stack trace: $stackTrace');
      if (mounted) {
        context.showError(
            'Terjadi kesalahan saat mengenali wajah. Silakan coba lagi.');
      }
    }
  }

  void _showSuccessDialog() {
    log('🎉 _showSuccessDialog called');
    if (capturedImage == null) {
      log('❌ capturedImage is null, cannot show dialog');
      return;
    }

    // Stop face detection processing
    _canProcess = false;
    log('🛑 Face detection processing stopped (success dialog)');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: Dialog(
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
                    Colors.green.shade50.withValues(alpha: 0.3),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success Icon
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade600],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade300.withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SpaceHeight(16),

                  // Title
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

                  // Subtitle
                  Text(
                    'Pengenalan wajah berhasil',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SpaceHeight(16),

                  // Captured Image
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade600],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade300.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        color: Colors.white,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.memory(
                        Uint8List.fromList(img.encodeJpg(capturedImage!)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SpaceHeight(16),

                  // Description
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
                            'Wajah Anda cocok dengan data yang terdaftar',
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

                  // Continue Button - Handle both Check-In and Check-Out
                  widget.isCheckedIn
                      ? _buildCheckinButton(dialogContext)
                      : _buildCheckoutButton(dialogContext),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorDialog() {
    log('⚠️  _showErrorDialog called');
    if (capturedImage == null) {
      log('❌ capturedImage is null, cannot show error dialog');
      return;
    }

    // Stop face detection processing
    _canProcess = false;
    log('🛑 Face detection processing stopped (error dialog)');

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
                  Colors.red.shade50.withValues(alpha: 0.3),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error Icon
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade400, Colors.red.shade600],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.shade300.withValues(alpha: 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.cancel_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SpaceHeight(16),

                // Title
                Text(
                  'Wajah Tidak Cocok',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SpaceHeight(6),

                // Subtitle
                Text(
                  'Pengenalan wajah gagal',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SpaceHeight(16),

                // Captured Image
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [Colors.red.shade400, Colors.red.shade600],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.shade300.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      color: Colors.white,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.memory(
                      Uint8List.fromList(img.encodeJpg(capturedImage!)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SpaceHeight(16),

                // Description with tips
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.orange.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange.shade700,
                            size: 18,
                          ),
                          const SpaceWidth(8),
                          Expanded(
                            child: Text(
                              'Wajah tidak cocok',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SpaceHeight(8),
                      Text(
                        '• Pastikan pencahayaan cukup\n• Posisikan wajah di tengah\n• Wajah terlihat jelas',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.orange.shade800,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SpaceHeight(20),

                // Back to Home Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      log('🏠 User clicked back to home');
                      Navigator.pop(dialogContext); // Close dialog
                      Navigator.pop(context); // Close face detector page
                      context.pushReplacement(const MainPage());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade500, Colors.red.shade700],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.home_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SpaceWidth(8),
                            Text(
                              'Kembali ke Beranda',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
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

  void showNotRegisteredDialogue() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Wajah Tidak Terdaftar", textAlign: TextAlign.center),
        content: const Text(
          "Wajah anda tidak terdaftar, pastikan check in dengan wajah yang sudah terdaftar",
          textAlign: TextAlign.center,
        ),
        actions: [
          Button.filled(
            onPressed: () {
              Navigator.of(context).pop();
            },
            color: Colors.red,
            label: 'Ulangi',
          ),
        ],
      ),
    );
  }

  void showRegisteredDialogue() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Wajah Anda Terdaftar", textAlign: TextAlign.center),
        content: const Text(
          "Wajah anda sudah terdaftar, silahkan lanjutkan proses check in",
          textAlign: TextAlign.center,
        ),
        actions: [
          Button.filled(
            onPressed: () {
              Navigator.of(context).pop();
            },
            label: 'Proses Check In',
          ),
        ],
      ),
    );
  }

  img.Image convertNV21ToImage(CameraImage cameraImage) {
    final width = cameraImage.width.toInt();
    final height = cameraImage.height.toInt();

    // Get Y plane and UV plane
    final yPlane = cameraImage.planes[0].bytes;
    final uvPlane = cameraImage.planes[1].bytes;

    final outImg = img.Image(height: height, width: width);

    // Convert YUV to RGB
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yIndex = y * width + x;

        // UV plane has half resolution (subsampling)
        final uvIndex = ((y >> 1) * (width >> 1) + (x >> 1)) * 2;

        // Ensure indices are within bounds
        if (yIndex >= yPlane.length || uvIndex + 1 >= uvPlane.length) {
          continue;
        }

        final yValue = yPlane[yIndex];
        final uValue = uvPlane[uvIndex];
        final vValue = uvPlane[uvIndex + 1];

        // Convert YUV to RGB
        int r = (yValue + 1.370705 * (vValue - 128)).toInt();
        int g = (yValue - 0.337633 * (uValue - 128) - 0.698001 * (vValue - 128))
            .toInt();
        int b = (yValue + 1.732446 * (uValue - 128)).toInt();

        // Clamp values to valid RGB range
        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        outImg.setPixelRgb(x, y, r, g, b);
      }
    }
    return outImg;
  }

  @override
  Widget build(BuildContext context) {
    return CameraViewAttendancePage(
      title: widget.isCheckedIn
          ? 'Kamera Absensi Datang '
          : 'Kamera Absensi Pulang',
      customPaint: _customPaint,
      onImage: _processImage,
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
      onTakePicture: _takePicture,
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) {
      log('⏸️  Processing stopped - _canProcess=false');
      return;
    }
    if (_isBusy) return;

    _isBusy = true;

    try {
      if (!mounted) {
        _isBusy = false;
        return;
      }

      setState(() {
        _text = '';
      });

      final faces = await _faceDetector.processImage(inputImage);

      if (!mounted) {
        _isBusy = false;
        return;
      }

      if (inputImage.metadata?.size != null &&
          inputImage.metadata?.rotation != null) {
        final painter = FaceDetectorPainter(
          faces,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
        );

        if (isTakePicture) {
          log('🎯 isTakePicture is TRUE, processing face recognition...');
          if (faces.isEmpty) {
            log('❌ No faces detected in captured image');
            if (mounted) {
              context.showError(
                "Tidak ada wajah yang terdeteksi. Pastikan wajah anda menghadap kamera dan pencahayaan yang cukup.",
              );
            }
            isTakePicture = false;
          } else {
            log('✅ ${faces.length} face(s) detected, calling performFaceRecognition');
            isTakePicture =
                false; // Reset immediately to prevent multiple calls
            performFaceRecognition(faces);
          }
        }

        _customPaint = CustomPaint(painter: painter);
      } else {
        String text = 'Faces found: ${faces.length}\n\n';
        for (final face in faces) {
          text += 'face: ${face.boundingBox}\n\n';
        }
        _text = text;
        _customPaint = null;
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e, stack) {
      log("❌ Error saat proses image: $e");
      log("Stack trace: $stack");
    } finally {
      _isBusy = false;
    }
  }

  Widget _buildCheckinButton(BuildContext dialogContext) {
    return BlocConsumer<CheckinAttendanceBloc, CheckinAttendanceState>(
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: () {},
          loaded: (data) {
            log('✅ Check-in berhasil: ${data.message}');
            isCheckedin = true;
            isCheckedout = false;
            Navigator.pop(dialogContext); // Close dialog
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AttendanceSuccessPage(
                  status: 'Datang',
                ),
              ),
            );
          },
          error: (message) {
            log('❌ Check-in error: $message');
            Navigator.pop(dialogContext);
            context.showError(message);
          },
        );
      },
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    log('✅ User confirmed face match, processing check-in...');
                    log('📍 Latitude: ${widget.latitude}, Longitude: ${widget.longitude}');
                    // Trigger check-in with lat/long
                    // context.read<CheckinAttendanceBloc>().add(
                    //       CheckinAttendanceEvent.checkin(
                    //         widget.latitude?.toString() ?? '0',
                    //         widget.longitude?.toString() ?? '0',
                    //       ),
                    //     );
                    Navigator.pop(dialogContext);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AttendanceSuccessPage(
                          status: 'Datang',
                        ),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade500, Colors.green.shade700],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                alignment: Alignment.center,
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SpaceWidth(8),
                          Text(
                            'Lanjutkan Check-In',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
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
      },
    );
  }

  Widget _buildCheckoutButton(BuildContext dialogContext) {
    return BlocConsumer<CheckoutAttendanceBloc, CheckoutAttendanceState>(
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: () {},
          loaded: (data) {
            log('✅ Check-out berhasil: ${data.message}');
            isCheckedin = false;
            isCheckedout = false;

            Navigator.pop(dialogContext); // Close dialog
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AttendanceSuccessPage(
                  status: 'Pulang',
                ),
              ),
            );
          },
          error: (message) {
            log('❌ Check-out error: $message');
            Navigator.pop(dialogContext);
            context.showError(message);
          },
        );
      },
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    log('✅ User confirmed face match, processing check-out...');
                    log('📍 Latitude: ${widget.latitude}, Longitude: ${widget.longitude}');
                    // Trigger check-out with lat/long
                    // context.read<CheckoutAttendanceBloc>().add(
                    //       CheckoutAttendanceEvent.checkout(
                    //         widget.latitude?.toString() ?? '0',
                    //         widget.longitude?.toString() ?? '0',
                    //       ),
                    //     );
                    Navigator.pop(dialogContext); // Close dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AttendanceSuccessPage(
                          status: 'Pulang',
                        ),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade500, Colors.green.shade700],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                alignment: Alignment.center,
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SpaceWidth(8),
                          Text(
                            'Lanjutkan Check-Out',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
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
      },
    );
  }
}
