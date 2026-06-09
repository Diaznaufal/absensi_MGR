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
    this.initialCameraLensDirection = CameraLensDirection.back,
    required this.onTakePicture,
  });

  final String title;
  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final VoidCallback? onCameraFeedReady;
  //stop live feed

  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;
  final Function(CameraImage cameraImage) onTakePicture;

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
  CameraLensDirection camDirec = CameraLensDirection.front;
  late Recognizer recognizer;
  late FaceDetector detector;
  bool isFaceRegistered = false;
  String faceStatusMessage = 'Belum Terdaftar';

  // Head turn detection variables
  bool _isHeadTurnedRight = false;
  bool _canTakePicture = false;
  String _instructionMessage = 'Position your face in the center';
  bool _showingInstruction = true;
  bool _isProcessing = true; // Flag to control face detection processing
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Blink detection variables
  bool _didCloseEyes = false;
  bool _isWaitingForBlink = false;
  String _blinkInstruction = 'Kedipkan mata Anda';

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

    // Initialize pulse animation for instruction overlay
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

    _initialize();
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
    _isProcessing = false; // Stop all processing
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
      _isProcessing = false; // Stop processing when app goes to background
      _stopLiveFeed();
    } else if (state == AppLifecycleState.resumed) {
      _isProcessing = true; // Resume processing when app comes back
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
    if (_cameras.isEmpty) return _buildLoadingScreen('No cameras available');
    if (_controller == null)
      return _buildLoadingScreen('Initializing camera...');
    if (_controller?.value.isInitialized == false)
      return _buildLoadingScreen('Starting camera...');

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // Camera Preview
        Center(
          child: _changingCameraLens
              ? _buildLoadingScreen('Switching camera...')
              : ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: CameraPreview(_controller!, child: widget.customPaint),
                ),
        ),

        // Dark overlay with face detection guide
        _buildFaceDetectionOverlay(),

        // Instructions overlay
        // _buildInstructionsOverlay(),

        // Bottom controls
        _buildBottomControls(),
      ],
    );
  }

  Widget _buildLoadingScreen(String message) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF0A49B7)),
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -250,
              top: -500,
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),

            // Lingkaran kedua
            Positioned(
              left: -200,
              top: -450,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                    width: 30,
                  ),
                ),
              ),
            ),

            Positioned(
              right: -250,
              bottom: -600,
              child: Container(
                width: 450,
                height: 450,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),

            // Lingkaran kedua
            Positioned(
              right: -220,
              bottom: -570,
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                    width: 30,
                  ),
                ),
              ),
            ),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
            const SpaceHeight(20),
            Text(
              message,
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

  Widget _buildFaceDetectionOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: CustomPaint(
        painter: FaceOverlayPainter(
          screenSize: MediaQuery.of(context).size,
          isHeadTurnedRight: _isHeadTurnedRight,
          canTakePicture: _canTakePicture,
        ),
        child: Container(),
      ),
    );
  }

  Widget _buildInstructionsOverlay() {
    return Positioned(
      top: 40,
      left: 24,
      right: 24,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _showingInstruction ? _pulseAnimation.value : 1.0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1e3c72).withOpacity(0.9),
                    const Color(0xFF2a5298).withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _canTakePicture
                              ? Icons.check_circle
                              : Icons.face_rounded,
                          color: _canTakePicture ? Colors.green : Colors.white,
                          size: 24,
                        ),
                      ),
                      const SpaceWidth(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _canTakePicture ? 'Perfect!' : 'Face Detection',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _instructionMessage,
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!_canTakePicture) ...[
                    const SpaceHeight(16),
                    Row(
                      children: [
                        _buildStepIndicator(
                          step: 1,
                          title: 'Center Face',
                          isCompleted: true,
                          isActive: !_isHeadTurnedRight,
                        ),
                        const SpaceWidth(8),
                        Expanded(
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: _isHeadTurnedRight
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                        const SpaceWidth(8),
                        _buildStepIndicator(
                          step: 2,
                          title: 'Turn Right',
                          isCompleted: _isHeadTurnedRight && _canTakePicture,
                          isActive: _isHeadTurnedRight,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator({
    required int step,
    required String title,
    required bool isCompleted,
    required bool isActive,
  }) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green
                : isActive
                    ? Colors.white
                    : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    step.toString(),
                    style: GoogleFonts.poppins(
                      color: isActive ? const Color(0xFF1e3c72) : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SpaceHeight(4),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.8),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
            // Zoom control
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

            // Take picture button
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isWaitingForBlink
              ? [
                  const Color(0xFF4CAF50).withAlpha((0.9 * 255).round()),
                  const Color(0xFF45A049).withAlpha((0.9 * 255).round()),
                ]
              : [
                  const Color(0xFF1e3c72).withAlpha((0.9 * 255).round()),
                  const Color(0xFF2a5298).withAlpha((0.9 * 255).round()),
                ],
        ),
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
          // Eye icon with animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isWaitingForBlink ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 60,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.2 * 255).round()),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _didCloseEyes
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              );
            },
          ),
          const SpaceHeight(12),
          // Instruction text
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
          // Status indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _isWaitingForBlink
                      ? (_didCloseEyes ? Colors.orange : Colors.green)
                      : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SpaceWidth(8),
              Text(
                _isWaitingForBlink
                    ? (_didCloseEyes ? 'Mendeteksi...' : 'Siap')
                    : 'Posisikan wajah',
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
    if (_isInitializing) {
      developer.log('Camera already initializing, skipping...',
          name: 'CameraView');
      return;
    }

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

      if (!mounted) {
        _isInitializing = false;
        return;
      }

      _currentZoomLevel = await _controller!.getMinZoomLevel();
      _minAvailableZoom = _currentZoomLevel;
      _maxAvailableZoom = await _controller!.getMaxZoomLevel();

      await _controller?.startImageStream(_processCameraImage);

      if (widget.onCameraFeedReady != null) {
        widget.onCameraFeedReady!();
      }
      if (widget.onCameraLensDirectionChanged != null) {
        widget.onCameraLensDirectionChanged!(camera.lensDirection);
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      developer.log('Error starting camera: $e', name: 'CameraView');
      if (mounted) {
        setState(() {});
      }
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
      _controller = null;
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (!_isProcessing) {
      developer.log('⏸️  Processing stopped - _isProcessing=false',
          name: 'CameraView');
      return; // Stop processing if flag is false
    }

    frame = image;
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;

    widget.onImage(inputImage);

    // Process face detection for head turn
    try {
      final faces = await detector.processImage(inputImage);
      if (_isProcessing) {
        // Check again before processing faces
        _processFaceDetection(faces);
      } else {
        developer.log('⏸️  Skipping face processing - _isProcessing=false',
            name: 'CameraView');
      }
    } catch (e) {
      // Handle face detection errors
      developer.log('❌ Error in face detection: $e', name: 'CameraView');
    }
  }

  void _processFaceDetection(List<Face> faces) {
    developer.log('🔍 Processing faces: ${faces.length} detected',
        name: 'FaceDetection');

    // Blink detection logic
    if (faces.isEmpty) {
      setState(() {
        _instructionMessage =
            'No face detected. Position your face in the center';
        _isHeadTurnedRight = false;
        _canTakePicture = false;
        _showingInstruction = true;
        _isWaitingForBlink = false;
        _didCloseEyes = false;
        _blinkInstruction = 'Posisikan wajah Anda';
      });
      return;
    }

    final face = faces.first;

    // Blink detection thresholds
    const double blinkThreshold = 0.25;
    final leftEyeOpen = face.leftEyeOpenProbability ?? 1.0;
    final rightEyeOpen = face.rightEyeOpenProbability ?? 1.0;

    // Face detected - wait for blink
    if (!_isWaitingForBlink) {
      developer.log('✅ Face detected! Waiting for blink.',
          name: 'BlinkDetection');
      setState(() {
        _isWaitingForBlink = true;
        _instructionMessage = 'Face detected! Kedipkan mata untuk foto';
        _blinkInstruction = 'Kedipkan mata Anda';
        _showingInstruction = false;
      });
    }

    // Log eye probabilities
    developer.log(
        '👁️ Eye values - Left: ${leftEyeOpen.toStringAsFixed(2)}, Right: ${rightEyeOpen.toStringAsFixed(2)}, Closed: $_didCloseEyes',
        name: 'BlinkDetection');

    // Detect blink when both eyes close
    if (leftEyeOpen < blinkThreshold && rightEyeOpen < blinkThreshold) {
      if (!_didCloseEyes) {
        developer.log(
            '👁️ EYES CLOSED! Left: $leftEyeOpen, Right: $rightEyeOpen',
            name: 'BlinkDetection');
        setState(() {
          _didCloseEyes = true;
          _blinkInstruction = 'Mata tertutup... buka mata';
        });
      }
    } else if (_didCloseEyes && leftEyeOpen > 0.75 && rightEyeOpen > 0.75) {
      // Eyes opened after closing - take picture!
      developer.log(
          '👁️✅ BLINK COMPLETE! Eyes reopened - Left: $leftEyeOpen, Right: $rightEyeOpen. Taking picture!',
          name: 'BlinkDetection');
      if (frame != null) {
        setState(() {
          _isProcessing = false;
          _blinkInstruction = 'Foto berhasil diambil!';
        });
        widget.onTakePicture(frame!);
      } else {
        developer.log('❌ Frame is null, cannot take picture',
            name: 'BlinkDetection');
      }
      setState(() {
        _didCloseEyes = false;
        _isWaitingForBlink = false;
      });
    } else if (_didCloseEyes) {
      // Eyes closed but not fully opened yet
      developer.log(
          '⏳ Waiting for eyes to fully open - Left: $leftEyeOpen, Right: $rightEyeOpen (need > 0.75)',
          name: 'BlinkDetection');
    }
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  // InputImage? _inputImageFromCameraImage(CameraImage image) {
  //   if (_controller == null) return null;

  //   final camera = _cameras[_cameraIndex];
  //   final sensorOrientation = camera.sensorOrientation;

  //   InputImageRotation? rotation;
  //   if (Platform.isIOS) {
  //     rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
  //   } else if (Platform.isAndroid) {
  //     var rotationCompensation =
  //         _orientations[_controller!.value.deviceOrientation];
  //     if (rotationCompensation == null) return null;
  //     if (camera.lensDirection == CameraLensDirection.front) {
  //       rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
  //     } else {
  //       rotationCompensation =
  //           (sensorOrientation - rotationCompensation + 360) % 360;
  //     }
  //     rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
  //   }
  //   if (rotation == null) return null;

  //   final format = InputImageFormatValue.fromRawValue(image.format.raw);

  //   if (format == null ||
  //       (Platform.isAndroid && format != InputImageFormat.nv21) ||
  //       (Platform.isIOS && format != InputImageFormat.bgra8888))
  //     return null;

  //   if (image.planes.length != 1) return null;
  //   final plane = image.planes.first;

  //   return InputImage.fromBytes(
  //     bytes: plane.bytes,
  //     metadata: InputImageMetadata(
  //       size: Size(image.width.toDouble(), image.height.toDouble()),
  //       rotation: rotation,
  //       format: format,
  //       bytesPerRow: plane.bytesPerRow,
  //     ),
  //   );
  // }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    // 1) Hitung rotasi seperti biasa
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
    final rotation = InputImageRotationValue.fromRawValue(
      rotationCompensation,
    )!;

    // 2) Konversi tiga plane ke NV21
    final bytes = _yuv420ToNv21(image);

    // 3) Buat metadata pakai NV21
    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      // *** Paksa jadi NV21 ***
      format: InputImageFormat.nv21,
      // bytesPerRow untuk NV21 = width
      bytesPerRow: image.width,
    );

    // 4) Kembalikan InputImage
    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  Uint8List _yuv420ToNv21(CameraImage image) {
    final width = image.width;
    final height = image.height;

    final yPlane = image.planes[0].bytes;
    final uPlane = image.planes[1].bytes;
    final vPlane = image.planes[2].bytes;

    // NV21 = YYYYY... + interleaved VU
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
  // void _detect({
  //   required Face face,
  // }) async {
  //   const double blinkThreshold = 0.25;

  //   if ((face.leftEyeOpenProbability ?? 1.0) < (blinkThreshold) &&
  //       (face.rightEyeOpenProbability ?? 1.0) < (blinkThreshold)) {
  //     if (mounted) {
  //       setState(
  //         () => _didCloseEyes = true,
  //       );
  //     }
  //   }
  // }

  // Future<void> _processImage(List<Face> faces) async {
  //   try {
  //     final Face firstFace = faces.first;

  //     if (_didCloseEyes) {
  //       if ((faces.first.leftEyeOpenProbability ?? 1.0) < 0.75 &&
  //           (faces.first.rightEyeOpenProbability ?? 1.0) < 0.75) {
  //         widget.onTakePicture(frame!);
  //         setState(() {
  //           _didCloseEyes = false;
  //         });
  //       }
  //     }

  //     _detect(
  //       face: firstFace,
  //     );
  //   } catch (e) {}
  // }

  double calculateSymmetry(
    Point<int>? leftPosition,
    Point<int>? rightPosition,
  ) {
    if (leftPosition != null && rightPosition != null) {
      final double dx = (rightPosition.x - leftPosition.x).abs().toDouble();
      final double dy = (rightPosition.y - leftPosition.y).abs().toDouble();
      final distance = Offset(dx, dy).distance;

      return distance;
    }

    return 0.0;
  }
}

// Custom painter for face detection overlay
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

    // Create face detection oval
    final center = Offset(size.width / 2, size.height / 2 - 50);
    final ovalRect = Rect.fromCenter(
      center: center,
      width: 280,
      height: 350,
    );

    // Draw the overlay with cut-out for face
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final facePath = Path()..addOval(ovalRect);

    final finalPath = Path.combine(
      PathOperation.difference,
      overlayPath,
      facePath,
    );

    // Fill the overlay
    paint.color = Colors.transparent;
    canvas.drawPath(finalPath, paint);

    // Draw face outline
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    paint.color = canTakePicture
        ? Colors.green
        : isHeadTurnedRight
            ? Colors.orange
            : Colors.white;

    // Add glow effect
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawOval(ovalRect, paint);

    // Draw solid outline
    paint.maskFilter = null;
    paint.strokeWidth = 2;
    canvas.drawOval(ovalRect, paint);

    // Draw corner guides
    _drawCornerGuides(canvas, ovalRect, paint);

    // Draw directional arrow if head needs to turn
    // if (!canTakePicture && !isHeadTurnedRight) {
    //   _drawDirectionalArrow(canvas, center, paint);
    // }
  }

  void _drawCornerGuides(Canvas canvas, Rect rect, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    paint.color = canTakePicture ? Colors.green : Colors.white;

    const cornerLength = 20.0;

    // Top-left corner
    canvas.drawLine(
      Offset(rect.left, rect.top + cornerLength),
      Offset(rect.left, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      paint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.top),
      Offset(rect.right, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(rect.left, rect.bottom - cornerLength),
      Offset(rect.left, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.bottom),
      Offset(rect.right, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - cornerLength),
      paint,
    );
  }

  void _drawDirectionalArrow(Canvas canvas, Offset center, Paint paint) {
    paint.style = PaintingStyle.fill;
    paint.color = Colors.orange;

    final arrowCenter = Offset(center.dx + 120, center.dy);
    final arrowPath = Path();

    // Arrow pointing right
    arrowPath.moveTo(arrowCenter.dx - 15, arrowCenter.dy - 10);
    arrowPath.lineTo(arrowCenter.dx + 15, arrowCenter.dy);
    arrowPath.lineTo(arrowCenter.dx - 15, arrowCenter.dy + 10);
    arrowPath.close();

    canvas.drawPath(arrowPath, paint);

    // Draw arrow tail
    final tailRect = Rect.fromCenter(
      center: Offset(arrowCenter.dx - 25, arrowCenter.dy),
      width: 20,
      height: 4,
    );
    canvas.drawRRect(
        RRect.fromRectAndRadius(tailRect, const Radius.circular(2)), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
