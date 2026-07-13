import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/core.dart';
import '../../../../core/ml/recognition_embedding.dart';
import '../../../../core/ml/recognizer.dart';

class CameraViewAttendancePage extends StatefulWidget {
  const CameraViewAttendancePage({
    super.key,
    required this.title,
    required this.customPaint,
    required this.onImage,
    this.onCameraFeedReady,
    this.onCameraLensDirectionChanged,
    this.initialCameraLensDirection = CameraLensDirection.front,
    required this.onTakePicture,
    this.isModelReady = true,
  });

  final String title;
  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final VoidCallback? onCameraFeedReady;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;
  final Function(CameraImage cameraImage) onTakePicture;
  final bool isModelReady;

  @override
  State<CameraViewAttendancePage> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraViewAttendancePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;
  double _currentZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  bool _changingCameraLens = false;
  bool _isInitializing = false;

  late List<RecognitionEmbedding> recognitions = [];
  CameraImage? frame;
  late Recognizer recognizer;
  late FaceDetector detector;

  bool _isProcessing = true;
  bool _photoTakenSuccess = false; // Penanda kunci sukses diambil
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _didCloseEyes = false;
  bool _isWaitingForBlink = false;
  String _blinkInstruction = 'Posisikan wajah Anda';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    recognizer = Recognizer();
    detector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        enableClassification: true,
        enableLandmarks: true,
        enableContours: true,
        enableTracking: true,
      ),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initialize();
      }
    });
  }

  void _initialize() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == widget.initialCameraLensDirection) {
        _cameraIndex = i;
        break;
      }
    }
    if (_cameraIndex != -1) {
      _startLiveFeed();
    }
  }

  @override
  void dispose() {
    _isProcessing = false;
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    detector.close();
    _stopLiveFeed();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _isProcessing = false;
      _stopLiveFeed();
    } else if (state == AppLifecycleState.resumed) {
      _isProcessing = true;
      _startLiveFeed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            widget.title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: _liveFeedBody(),
    );
  }

  Widget _liveFeedBody() {
    if (_cameras.isEmpty ||
        _controller == null ||
        _controller?.value.isInitialized == false ||
        _changingCameraLens) {
      return const SizedBox.shrink();
    }

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: CameraPreview(_controller!, child: widget.customPaint),
          ),
        ),
        _buildFaceDetectionOverlay(),
        _buildBottomControls(),
      ],
    );
  }

  Widget _buildFaceDetectionOverlay() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: CustomPaint(
        painter: FaceOverlayPainter(
          screenSize: MediaQuery.of(context).size,
          isHeadTurnedRight: false,
          canTakePicture: _photoTakenSuccess || _isWaitingForBlink,
        ),
        child: Container(),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              width: 250,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Slider(
                      value: _currentZoomLevel,
                      min: _minAvailableZoom,
                      max: _maxAvailableZoom,
                      activeColor: Colors.white,
                      inactiveColor: Colors.white30,
                      onChanged: (value) async {
                        setState(() {
                          _currentZoomLevel = value;
                        });
                        await _controller?.setZoomLevel(value);
                      },
                    ),
                  ),
                  Container(
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          '${_currentZoomLevel.toStringAsFixed(1)}x',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SpaceHeight(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTakePictureButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTakePictureButton() {
    final List<Color> buttonGradient =
        (_photoTakenSuccess || _isWaitingForBlink)
            ? [
                const Color(0xFF4CAF50).withAlpha((0.9 * 255).round()),
                const Color(0xFF45A049).withAlpha((0.9 * 255).round()),
              ]
            : [
                const Color(0xFFE53935).withAlpha((0.9 * 255).round()),
                const Color(0xFFD32F2F).withAlpha((0.9 * 255).round()),
              ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: buttonGradient),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withAlpha((0.3 * 255).round()),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.3 * 255).round()),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: (_photoTakenSuccess || _isWaitingForBlink)
                    ? _pulseAnimation.value
                    : 1.0,
                child: Container(
                  width: 60,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.2 * 255).round()),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    // 🆕 PERBAIKAN UTAMA: Penerapan 3 Kondisi pada Ikon secara sinkron dan adaptif
                    _photoTakenSuccess
                        ? Icons
                            .check_circle_rounded // Tahap 3: Sukses jepret -> Centang
                        : _isWaitingForBlink
                            ? (_didCloseEyes
                                ? Icons
                                    .visibility_off_rounded // Tahap 2a: Sedang kedip -> Mata off
                                : Icons
                                    .visibility_rounded) // Tahap 2b: Siap kedip -> Mata on
                            : Icons
                                .no_photography_rounded, // Tahap 1: Belum Pas -> Tanda silang kamera/posisi
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              );
            },
          ),
          const SpaceHeight(12),
          Text(
            _blinkInstruction,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SpaceHeight(4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: (_photoTakenSuccess || _isWaitingForBlink)
                      ? (_didCloseEyes ? Colors.orange : Colors.green)
                      : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SpaceWidth(8),
              Text(
                _photoTakenSuccess
                    ? 'Sukses'
                    : _isWaitingForBlink
                        ? (_didCloseEyes ? 'Mendeteksi...' : 'Posisi Siap')
                        : 'Belum Pas',
                style: GoogleFonts.poppins(
                  color: Colors.white.withAlpha((0.8 * 255).round()),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future _startLiveFeed() async {
    if (_isInitializing) return;
    _isInitializing = true;

    try {
      final camera = _cameras[_cameraIndex];
      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _controller?.initialize();

      if (!mounted || _controller == null) {
        _isInitializing = false;
        return;
      }

      _currentZoomLevel = await _controller!.getMinZoomLevel();
      _minAvailableZoom = _currentZoomLevel;
      _maxAvailableZoom = await _controller!.getMaxZoomLevel();

      if (_controller != null && _controller!.value.isInitialized) {
        await _controller?.startImageStream(_processCameraImage);
        if (widget.onCameraFeedReady != null) widget.onCameraFeedReady!();
      }

      if (mounted) setState(() {});
    } catch (e) {
      developer.log('Error starting camera: $e', name: 'CameraView');
    } finally {
      _isInitializing = false;
    }
  }

  Future _stopLiveFeed() async {
    try {
      if (_controller != null) {
        if (_controller!.value.isStreamingImages) {
          await _controller!.stopImageStream();
        }
        await _controller!.dispose();
        _controller = null;
      }
    } catch (e) {
      developer.log('Error stopping camera: $e', name: 'CameraView');
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (!_isProcessing) return;

    frame = image;
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;

    widget.onImage(inputImage);

    try {
      final faces = await detector.processImage(inputImage);
      if (_isProcessing) {
        _processFaceDetection(faces, inputImage);
      }
    } catch (e) {
      developer.log('❌ Error in face detection: $e', name: 'CameraView');
    }
  }

  void _processFaceDetection(List<Face> faces, InputImage inputImage) {
    if (!_isProcessing) return;

    if (faces.isEmpty) {
      setState(() {
        _isWaitingForBlink = false;
        _didCloseEyes = false;
        _blinkInstruction = 'Posisikan wajah Anda di dalam oval';
      });
      return;
    }

    final face = faces.first;
    final rect = face.boundingBox;
    final double nativeWidth = inputImage.metadata!.size.width;
    final double nativeHeight = inputImage.metadata!.size.height;
    final rotation = inputImage.metadata!.rotation;

    final bool isPortrait = rotation == InputImageRotation.rotation90deg ||
        rotation == InputImageRotation.rotation270deg;

    final double imageWidth = isPortrait ? nativeHeight : nativeWidth;
    final double imageHeight = isPortrait ? nativeWidth : nativeHeight;

    double faceCenterX = rect.left + (rect.width / 2);
    double faceCenterY = rect.top + (rect.height / 2);

    if (isPortrait) {
      if (rotation == InputImageRotation.rotation90deg) {
        faceCenterX = rect.top + (rect.width / 2);
        faceCenterY = nativeWidth - (rect.left + (rect.width / 2));
      } else if (rotation == InputImageRotation.rotation270deg) {
        faceCenterX = nativeHeight - (rect.top + (rect.height / 2));
        faceCenterY = rect.left + (rect.width / 2);
      }
    }

    final double idealCenterX = imageWidth / 2;
    final double idealCenterY = imageHeight / 2;

    final double horizontalTolerance = imageWidth * 0.40;
    final double verticalTolerance = imageHeight * 0.40;

    if ((faceCenterX - idealCenterX).abs() > horizontalTolerance ||
        (faceCenterY - idealCenterY).abs() > verticalTolerance) {
      setState(() {
        _isWaitingForBlink = false;
        _blinkInstruction = 'Wajah harus tepat di tengah';
      });
      return;
    }

    final double faceHeightPercentage = rect.height / imageHeight;
    if (faceHeightPercentage < 0.25) {
      setState(() {
        _isWaitingForBlink = false;
        _blinkInstruction = 'Silakan mendekat ke kamera';
      });
      return;
    } else if (faceHeightPercentage > 0.80) {
      setState(() {
        _isWaitingForBlink = false;
        _blinkInstruction = 'Terlalu dekat, silakan menjauh';
      });
      return;
    }

    if (!_isWaitingForBlink) {
      setState(() {
        _isWaitingForBlink = true;
        _blinkInstruction = 'Posisi Bagus! Kedipkan mata Anda';
      });
    }

    const double blinkThreshold = 0.25;
    final leftEyeOpen = face.leftEyeOpenProbability ?? 1.0;
    final rightEyeOpen = face.rightEyeOpenProbability ?? 1.0;

    if (leftEyeOpen < blinkThreshold && rightEyeOpen < blinkThreshold) {
      if (!_didCloseEyes) {
        setState(() {
          _didCloseEyes = true;
          _blinkInstruction = 'Mata tertutup... Buka mata Anda';
        });
      }
    } else if (_didCloseEyes && leftEyeOpen > 0.70 && rightEyeOpen > 0.70) {
      if (frame != null) {
        _isProcessing = false;
        setState(() {
          _photoTakenSuccess = true;
          _blinkInstruction = 'Foto berhasil diambil!';
        });
        widget.onTakePicture(frame!);
      }
    }
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;
    var rotationCompensation =
        _orientations[_controller!.value.deviceOrientation]!;
    if (camera.lensDirection == CameraLensDirection.front) {
      rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
    } else {
      rotationCompensation =
          (sensorOrientation - rotationCompensation + 360) % 360;
    }
    final rotation =
        InputImageRotationValue.fromRawValue(rotationCompensation)!;

    final bytes = _yuv420ToNv21(image);

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: InputImageFormat.nv21,
      bytesPerRow: image.width,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  Uint8List _yuv420ToNv21(CameraImage image) {
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
    return nv21;
  }
}

class FaceOverlayPainter extends CustomPainter {
  final Size screenSize;
  final bool isHeadTurnedRight;
  final bool canTakePicture;

  FaceOverlayPainter({
    required this.screenSize,
    required this.isHeadTurnedRight,
    required this.canTakePicture,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final center = Offset(size.width / 2, size.height / 2 - 50);
    final ovalRect = Rect.fromCenter(center: center, width: 280, height: 350);

    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final facePath = Path()..addOval(ovalRect);
    final finalPath =
        Path.combine(PathOperation.difference, overlayPath, facePath);

    paint.color = Colors.black.withOpacity(0.7);
    canvas.drawPath(finalPath, paint);

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;

    paint.color = canTakePicture
        ? const Color(0xFF4CAF50)
        : Colors.white.withOpacity(0.6);

    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawOval(ovalRect, paint);

    paint.maskFilter = null;
    paint.strokeWidth = 2;
    canvas.drawOval(ovalRect, paint);

    _drawCornerGuides(canvas, ovalRect, paint);
  }

  void _drawCornerGuides(Canvas canvas, Rect rect, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;

    paint.color = canTakePicture
        ? const Color(0xFF4CAF50)
        : Colors.white.withOpacity(0.8);
    const cornerLength = 20.0;

    canvas.drawLine(Offset(rect.left, rect.top + cornerLength),
        Offset(rect.left, rect.top), paint);
    canvas.drawLine(Offset(rect.left, rect.top),
        Offset(rect.left + cornerLength, rect.top), paint);

    canvas.drawLine(Offset(rect.right - cornerLength, rect.top),
        Offset(rect.right, rect.top), paint);
    canvas.drawLine(Offset(rect.right, rect.top),
        Offset(rect.right, rect.top + cornerLength), paint);

    canvas.drawLine(Offset(rect.left, rect.bottom - cornerLength),
        Offset(rect.left, rect.bottom), paint);
    canvas.drawLine(Offset(rect.left, rect.bottom),
        Offset(rect.left + cornerLength, rect.bottom), paint);

    canvas.drawLine(Offset(rect.right - cornerLength, rect.bottom),
        Offset(rect.right, rect.bottom), paint);
    canvas.drawLine(Offset(rect.right, rect.bottom),
        Offset(rect.right, rect.bottom - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
