import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import 'package:flutter_absensi_app/core/core.dart';

import 'face_detector_painter.dart';
import 'attandences/camera_view_attendance_page.dart';

import '../../../core/ml/recognition_embedding.dart';
import '../../../core/ml/recognizer.dart';
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

  @override
  void initState() {
    super.initState();
    recognizer = Recognizer();
  }

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  void _takePicture(CameraImage cameraImage) async {
    log('🎯 _takePicture called');
    setState(() {
      frame = cameraImage;
      currentCameraImage = cameraImage; // Store the camera image for processing
      isTakePicture = true;
    });
    log('📸 Frame captured, isTakePicture = $isTakePicture, currentCameraImage = ${currentCameraImage != null}');
  }

  img.Image? image;
  img.Image? capturedImage;
  List<double>? capturedEmbedding;
  CameraImage? currentCameraImage;

  performFaceRegistration(List<Face> faces) async {
    log('🔄 performFaceRegistration called with ${faces.length} faces');
    recognitions.clear();

    // Use currentCameraImage from the stream
    if (currentCameraImage == null) {
      log('❌ No camera image available');
      if (mounted) {
        context.showError("Gagal mengambil gambar. Silakan coba lagi.");
      }
      return;
    }

    try {
      image = convertNV21ToImage(currentCameraImage!);
      log('🖼️  Image converted from CameraImage');
    } catch (e) {
      log('❌ Error converting image: $e');
      if (mounted) {
        context.showError("Gagal memproses gambar. Silakan coba lagi.");
      }
      return;
    }

    image = img.copyRotate(
      image!,
      angle: _cameraLensDirection == CameraLensDirection.front ? 270 : 90,
    );
    log('🔄 Image rotated');

    for (Face face in faces) {
      Rect faceRect = face.boundingBox;
      log('👤 Processing face with bounding box: $faceRect');

      img.Image croppedFace = img.copyCrop(
        image!,
        x: faceRect.left.toInt(),
        y: faceRect.top.toInt(),
        width: faceRect.width.toInt(),
        height: faceRect.height.toInt(),
      );
      log('✂️  Face cropped');

      RecognitionEmbedding recognition = recognizer.recognize(
        croppedFace,
        face.boundingBox,
      );
      log('🧠 Face recognition completed, embedding size: ${recognition.embedding.length}');

      recognitions.add(recognition);

      if (!mounted) return;

      // For registration, we don't need to validate against existing face
      // Just check if we got a valid embedding (non-empty)
      if (recognition.embedding.isNotEmpty) {
        log('✨ Face embedding generated successfully, preparing to show dialog');
        // Store captured data for dialog
        capturedImage = image;
        capturedEmbedding = recognition.embedding;

        // Show confirmation dialog
        log('📱 Showing confirmation dialog');
        _showConfirmationDialog();
      } else {
        log('❌ Failed to generate face embedding');
        context.showError("Gagal memproses wajah. Silakan coba lagi.");
      }
    }
  }

  void _showConfirmationDialog() {
    log('🎭 _showConfirmationDialog called');
    if (capturedImage == null) {
      log('❌ capturedImage is null, cannot show dialog');
      return;
    }

    log('✅ Showing dialog with captured image');
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
              // Title
              Text(
                'Konfirmasi Foto Wajah',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1e3c72),
                ),
                textAlign: TextAlign.center,
              ),
              const SpaceHeight(20),

              // Captured Image
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF1e3c72),
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

              // Description
              Text(
                'Pastikan wajah Anda terlihat jelas pada foto di atas',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SpaceHeight(24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        log('🔄 User clicked Ulangi button');
                        Navigator.pop(dialogContext);
                        setState(() {
                          capturedImage = null;
                          capturedEmbedding = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF1e3c72)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Ulangi',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1e3c72),
                        ),
                      ),
                    ),
                  ),
                  const SpaceWidth(12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        log('✅ User clicked Daftar button');
                        Navigator.pop(dialogContext);
                        // Register face embedding
                        if (capturedEmbedding != null) {
                          log('📤 Sending face embedding to backend, size: ${capturedEmbedding!.length}');
                          final embeddingString = capturedEmbedding!.join(',');
                          log('📝 Embedding string preview: ${embeddingString.substring(0, embeddingString.length > 100 ? 100 : embeddingString.length)}...');
                          context.read<UpdateUserRegisterFaceBloc>().add(
                                UpdateUserRegisterFaceEvent
                                    .updateProfileRegisterFace(
                                  embeddingString,
                                  null,
                                ),
                              );
                        } else {
                          log('❌ capturedEmbedding is null!');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1e3c72),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
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

  img.Image convertNV21ToImage(CameraImage cameraImage) {
    final width = cameraImage.width.toInt();
    final height = cameraImage.height.toInt();

    // Get Y plane
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
    return BlocListener<UpdateUserRegisterFaceBloc,
        UpdateUserRegisterFaceState>(
      listener: (context, state) {
        state.maybeWhen(
          orElse: () {},
          loading: () {},
          success: (user) {
            if (!mounted) return;

            final navigator = Navigator.of(context);
            context.showSuccess("Wajah berhasil didaftarkan!");

            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MainPage()),
                  (route) => false,
                );
              }
            });
          },
          error: (message) {
            context.showError(message);
          },
        );
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Camera View
            CameraViewAttendancePage(
              title: 'Register Face',
              customPaint: _customPaint,
              onImage: _processImage,
              initialCameraLensDirection: _cameraLensDirection,
              onCameraLensDirectionChanged: (value) =>
                  _cameraLensDirection = value,
              onTakePicture: _takePicture,
            ),

            // Bottom Capture Button
            // Positioned(
            //   bottom: 40,
            //   left: 0,
            //   right: 0,
            //   child: Center(
            //     child: BlocBuilder<UpdateUserRegisterFaceBloc,
            //         UpdateUserRegisterFaceState>(
            //       builder: (context, state) {
            //         return state.maybeWhen(
            //           orElse: () => _buildCaptureButton(),
            //           loading: () => _buildLoadingButton(),
            //         );
            //       },
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return Container(
      width: 200,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1e3c72), Color(0xFF3b82c9)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1e3c72).withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            log('👆 Capture Face button tapped');
            // Trigger face capture
            setState(() {
              isTakePicture = true;
            });
            log('🎯 isTakePicture set to true');
          },
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SpaceWidth(12),
                Text(
                  'Capture Face',
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
  }

  Widget _buildLoadingButton() {
    return Container(
      width: 200,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1e3c72)),
              ),
            ),
            const SpaceWidth(12),
            Text(
              'Processing...',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processImage(
      InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;

    final faces = await _faceDetector.processImage(inputImage);
    log('🔍 Detected ${faces.length} faces');

    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = FaceDetectorPainter(
        faces,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);

      if (isTakePicture) {
        log('🎯 isTakePicture is TRUE, processing face registration...');
        if (!mounted) {
          isTakePicture = false;
          return;
        }

        if (faces.isEmpty) {
          log('❌ No faces detected');
          context.showError(
            "Tidak ada wajah yang terdeteksi. Pastikan wajah anda menghadap kamera.",
          );
          isTakePicture = false;
        } else if (faces.length > 1) {
          log('⚠️  Multiple faces detected: ${faces.length}');
          context.showError(
            "Terdeteksi lebih dari 1 wajah. Pastikan hanya wajah anda yang terlihat.",
          );
          isTakePicture = false;
        } else {
          log('✅ Single face detected, calling performFaceRegistration');
          isTakePicture = false; // Reset immediately to prevent multiple calls
          performFaceRegistration(faces);
        }
      }
    } else {
      log('⚠️  No metadata available');
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
