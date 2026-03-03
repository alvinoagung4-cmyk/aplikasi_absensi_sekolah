import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:projectone/services/attendance_service.dart';
import 'package:projectone/services/auth_service.dart';

class QRScanAttendancePage extends StatefulWidget {
  final String attendanceType; // 'check_in' atau 'check_out'

  const QRScanAttendancePage({
    super.key,
    required this.attendanceType,
  });

  @override
  State<QRScanAttendancePage> createState() => _QRScanAttendancePageState();
}

class _QRScanAttendancePageState extends State<QRScanAttendancePage> {
  late MobileScannerController _scannerController;
  bool _isProcessing = false;
  String _statusMessage = 'Arahkan QR Code ke depan kamera';
  bool _torchEnabled = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
      returnImage: false,
    );
  }

  Future<void> _processQRCode(String qrCode) async {
    if (_isProcessing) return;

    _isProcessing = true;
    setState(() {
      _statusMessage = 'Memproses QR Code...';
    });

    try {
      final userId = AuthService.getUserData()?['id'] ?? '';

      if (widget.attendanceType == 'check_in') {
        await AttendanceService.checkInWithQRCode(
          userId: userId,
          qrCode: qrCode,
        );
      } else {
        await AttendanceService.checkOutWithQRCode(
          userId: userId,
          qrCode: qrCode,
        );
      }

      if (mounted) {
        _showSuccessDialog(
          'Presensi ${widget.attendanceType == 'check_in' ? 'Masuk' : 'Keluar'} Berhasil!',
          qrCode,
        );
      }
    } catch (e) {
      _showErrorDialog('Gagal memproses: $e');
      _isProcessing = false;
    }
  }

  void _showSuccessDialog(String message, String qrCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('✓ Sukses'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'QR Code:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    qrCode,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Selesai'),
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
            onPressed: () {
              Navigator.of(context).pop();
              _isProcessing = false;
              setState(() {
                _statusMessage = 'Silakan coba lagi';
              });
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scan QR Code - ${widget.attendanceType == 'check_in' ? 'Masuk' : 'Keluar'}',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _torchEnabled ? Icons.flash_on : Icons.flash_off,
              color: _torchEnabled ? Colors.yellow : null,
            ),
            onPressed: () {
              setState(() {
                _torchEnabled = !_torchEnabled;
              });
              _scannerController.toggleTorch();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null && !_isProcessing) {
                  _processQRCode(barcode.rawValue!);
                }
              }
            },
          ),
          // Scanning frame overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: CustomPaint(
                painter: QRFramePainter(),
                size: const Size(300, 300),
              ),
            ),
          ),
          // Bottom info panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
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
                  if (_isProcessing)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      child: const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Close button
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QRFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const borderRadius = 20.0;
    const borderWidth = 4.0;
    const borderColor = Colors.white;

    // Draw rectangle
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(borderRadius));

    // Draw outer shadow
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Draw border
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );

    // Draw corner highlights
    const cornerLength = 30.0;
    const cornerStrokeWidth = 3.0;

    // Top-left corner
    canvas.drawLine(
      Offset.zero,
      const Offset(cornerLength, 0),
      Paint()
        ..color = borderColor
        ..strokeWidth = cornerStrokeWidth
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset.zero,
      const Offset(0, cornerLength),
      Paint()
        ..color = borderColor
        ..strokeWidth = cornerStrokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width - cornerLength, 0),
      Paint()
        ..color = borderColor
        ..strokeWidth = cornerStrokeWidth
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLength),
      Paint()
        ..color = borderColor
        ..strokeWidth = cornerStrokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLength, size.height),
      Paint()
        ..color = borderColor
        ..strokeWidth = cornerStrokeWidth
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - cornerLength),
      Paint()
        ..color = borderColor
        ..strokeWidth = cornerStrokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - cornerLength, size.height),
      Paint()
        ..color = borderColor
        ..strokeWidth = cornerStrokeWidth
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - cornerLength),
      Paint()
        ..color = borderColor
        ..strokeWidth = cornerStrokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(QRFramePainter oldDelegate) => false;
}
