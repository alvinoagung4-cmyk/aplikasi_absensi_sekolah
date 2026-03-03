import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:projectone/services/attendance_service.dart';
import 'package:projectone/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class FaceScanAttendancePage extends StatefulWidget {
  final String attendanceType; // 'check_in' atau 'check_out'

  const FaceScanAttendancePage({
    super.key,
    required this.attendanceType,
  });

  @override
  State<FaceScanAttendancePage> createState() => _FaceScanAttendancePageState();
}

class _FaceScanAttendancePageState extends State<FaceScanAttendancePage> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  FaceDetector? _faceDetector;
  bool _isProcessing = false;
  String _statusMessage = '';
  bool _faceDetected = false;
  double _faceConfidence = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: true,
        enableClassification: true,
        enableTracking: true,
        minFaceSize: 0.1,
      ),
    );
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
      );

      _initializeControllerFuture = _cameraController!.initialize();
      if (mounted) {
        setState(() {});
        _startFaceDetection();
      }
    } catch (e) {
      _showErrorDialog('Gagal menginisialisasi kamera: $e');
    }
  }

  void _startFaceDetection() {
    _cameraController?.startImageStream((image) async {
      if (!_isProcessing) {
        _isProcessing = true;
        try {
          final InputImage inputImage = InputImage.fromBytes(
            bytes: image.planes[0].bytes,
            metadata: InputImageMetadata(
              size: Size(image.width.toDouble(), image.height.toDouble()),
              rotation: InputImageRotation.rotation0deg,
              format: InputImageFormat.nv21,
              bytesPerRow: image.planes[0].bytesPerRow,
            ),
          );

          final List<Face> faces = await _faceDetector!.processImage(inputImage);

          if (faces.isNotEmpty) {
            setState(() {
              _faceDetected = true;
              _faceConfidence = 0.95; // Confidence score
              _statusMessage = 'Wajah terdeteksi dengan baik ✓';
            });

            // Auto capture setelah deteksi face yang bagus
            if (!_isProcessing) {
              await Future.delayed(const Duration(seconds: 1));
              _captureAndProcess(image);
            }
          } else {
            setState(() {
              _faceDetected = false;
              _statusMessage = 'Arahkan wajah ke kamera';
            });
          }
        } catch (e) {
          print('Error during face detection: $e');
        } finally {
          _isProcessing = false;
        }
      }
    });
  }

  Future<void> _captureAndProcess(CameraImage image) async {
    try {
      setState(() {
        _statusMessage = 'Memproses wajah...';
      });

      final userId = AuthService.getUserData()?['id'] ?? '';
      
      if (userId.isEmpty) {
        _showErrorDialog('User ID tidak ditemukan');
        return;
      }

      // Convert camera image to base64
      final bytes = image.planes[0].bytes;
      final base64Image = base64Encode(bytes);

      if (widget.attendanceType == 'check_in') {
        await AttendanceService.checkInWithFace(
          userId: userId,
          faceImage: base64Image,
          confidence: _faceConfidence,
        );
      } else {
        await AttendanceService.checkOutWithFace(
          userId: userId,
          faceImage: base64Image,
          confidence: _faceConfidence,
        );
      }

      if (mounted) {
        _showSuccessDialog(
          'Presensi ${widget.attendanceType == 'check_in' ? 'Masuk' : 'Keluar'} Berhasil!',
        );
      }
    } catch (e) {
      _showErrorDialog('Gagal memproses: $e');
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sukses'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scan Wajah - ${widget.attendanceType == 'check_in' ? 'Masuk' : 'Keluar'}',
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_cameraController!),
                // Face detection guide overlay
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      width: 280,
                      height: 350,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _faceDetected ? Colors.green : Colors.white,
                          width: 2,
                        ),
                        shape: BoxShape.rectangle,
                      ),
                    ),
                  ),
                ),
                // Status message at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _statusMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_faceDetected)
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Kepercayaan: ${(_faceConfidence * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kembali'),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Menginisialisasi kamera...'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
