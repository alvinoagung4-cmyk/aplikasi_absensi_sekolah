import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:projectone/models/attendance_model.dart';
import 'package:projectone/services/api_service.dart';

class AttendanceService {
  // ============ CHECK IN / CHECK OUT WITH FACE ============
  static Future<Map<String, dynamic>> checkInWithFace({
    required String userId,
    required String faceImage,
    required double confidence,
  }) async {
    try {
      if (userId.isEmpty) {
        throw Exception('User ID tidak boleh kosong');
      }

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/attendance/checkin-face'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiService.getToken()}',
        },
        body: jsonEncode({
          'user_id': userId,
          'face_image': faceImage,
          'confidence': confidence,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 30));

      final result = await ApiService.handleResponse(response);
      return result;
    } catch (e) {
      throw Exception('Error check-in dengan wajah: ${e.toString()}');
    }
  }

  // ============ CHECK OUT WITH FACE ============
  static Future<Map<String, dynamic>> checkOutWithFace({
    required String userId,
    required String faceImage,
    required double confidence,
  }) async {
    try {
      if (userId.isEmpty) {
        throw Exception('User ID tidak boleh kosong');
      }

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/attendance/checkout-face'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiService.getToken()}',
        },
        body: jsonEncode({
          'user_id': userId,
          'face_image': faceImage,
          'confidence': confidence,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 30));

      final result = await ApiService.handleResponse(response);
      return result;
    } catch (e) {
      throw Exception('Error check-out dengan wajah: ${e.toString()}');
    }
  }

  // ============ CHECK IN / CHECK OUT WITH QR CODE ============
  static Future<Map<String, dynamic>> checkInWithQRCode({
    required String userId,
    required String qrCode,
  }) async {
    try {
      if (userId.isEmpty) {
        throw Exception('User ID tidak boleh kosong');
      }
      if (qrCode.isEmpty) {
        throw Exception('QR Code tidak boleh kosong');
      }

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/attendance/checkin-qr'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiService.getToken()}',
        },
        body: jsonEncode({
          'user_id': userId,
          'qr_code': qrCode,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 10));

      final result = await ApiService.handleResponse(response);
      return result;
    } catch (e) {
      throw Exception('Error check-in dengan QR code: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> checkOutWithQRCode({
    required String userId,
    required String qrCode,
  }) async {
    try {
      if (userId.isEmpty) {
        throw Exception('User ID tidak boleh kosong');
      }
      if (qrCode.isEmpty) {
        throw Exception('QR Code tidak boleh kosong');
      }

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/attendance/checkout-qr'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiService.getToken()}',
        },
        body: jsonEncode({
          'user_id': userId,
          'qr_code': qrCode,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 10));

      final result = await ApiService.handleResponse(response);
      return result;
    } catch (e) {
      throw Exception('Error check-out dengan QR code: ${e.toString()}');
    }
  }

  // ============ GET ATTENDANCE HISTORY ============
  static Future<List<Attendance>> getAttendanceHistory({
    required String userId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      if (userId.isEmpty) {
        throw Exception('User ID tidak boleh kosong');
      }

      String url = '${ApiService.baseUrl}/attendance/history/$userId';
      
      Map<String, String> queryParams = {};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      if (queryParams.isNotEmpty) {
        url += '?' + queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${ApiService.getToken()}',
        },
      ).timeout(const Duration(seconds: 10));

      final result = await ApiService.handleResponse(response);
      
      List<Attendance> attendances = [];
      if (result['data'] is List) {
        attendances = (result['data'] as List)
            .map((item) => Attendance.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return attendances;
    } catch (e) {
      throw Exception('Error mengambil riwayat presensi: ${e.toString()}');
    }
  }

  // ============ GET TODAY'S ATTENDANCE ============
  static Future<Map<String, dynamic>?> getTodayAttendance({
    required String userId,
  }) async {
    try {
      if (userId.isEmpty) {
        throw Exception('User ID tidak boleh kosong');
      }

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/attendance/today/$userId'),
        headers: {
          'Authorization': 'Bearer ${ApiService.getToken()}',
        },
      ).timeout(const Duration(seconds: 10));

      final result = await ApiService.handleResponse(response);
      return result['data'] as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Error mengambil presensi hari ini: ${e.toString()}');
    }
  }

  // ============ GET ATTENDANCE STATISTICS ============
  static Future<AttendanceStatistics> getAttendanceStatistics({
    required String userId,
    String? month,
    String? year,
  }) async {
    try {
      if (userId.isEmpty) {
        throw Exception('User ID tidak boleh kosong');
      }

      String url = '${ApiService.baseUrl}/attendance/statistics/$userId';
      
      Map<String, String> queryParams = {};
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      if (queryParams.isNotEmpty) {
        url += '?' + queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${ApiService.getToken()}',
        },
      ).timeout(const Duration(seconds: 10));

      final result = await ApiService.handleResponse(response);
      return AttendanceStatistics.fromJson(result['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error mengambil statistik presensi: ${e.toString()}');
    }
  }

  // ============ VERIFY FACE WITH LIVENESS CHECK ============
  static Future<Map<String, dynamic>> verifyFaceWithLiveness({
    required String faceImage,
  }) async {
    try {
      if (faceImage.isEmpty) {
        throw Exception('Face image tidak boleh kosong');
      }

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/attendance/verify-face'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiService.getToken()}',
        },
        body: jsonEncode({
          'face_image': faceImage,
        }),
      ).timeout(const Duration(seconds: 15));

      final result = await ApiService.handleResponse(response);
      return result;
    } catch (e) {
      throw Exception('Error verifikasi wajah: ${e.toString()}');
    }
  }

  // ============ VALIDATE QR CODE ============
  static Future<Map<String, dynamic>> validateQRCode({
    required String qrCode,
  }) async {
    try {
      if (qrCode.isEmpty) {
        throw Exception('QR Code tidak boleh kosong');
      }

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/attendance/validate-qr'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiService.getToken()}',
        },
        body: jsonEncode({
          'qr_code': qrCode,
        }),
      ).timeout(const Duration(seconds: 10));

      final result = await ApiService.handleResponse(response);
      return result;
    } catch (e) {
      throw Exception('Error validasi QR code: ${e.toString()}');
    }
  }

  // ============ NEW: CHECK-IN DENGAN FOTO ============
  static Future<Map<String, dynamic>> checkIn({
    required int classId,
    double? latitude,
    double? longitude,
    String? fotoBase64,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/attendance/check-in'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiService.getToken()}',
        },
        body: jsonEncode({
          'class_id': classId,
          'latitude': latitude,
          'longitude': longitude,
          'foto_base64': fotoBase64,
        }),
      ).timeout(const Duration(seconds: 30));

      final result = await ApiService.handleResponse(response);
      return result;
    } catch (e) {
      throw Exception('Error check-in: ${e.toString()}');
    }
  }

  // ============ NEW: CHECK-OUT DENGAN FOTO ============
  static Future<Map<String, dynamic>> checkOut({
    required int attendanceId,
    double? latitude,
    double? longitude,
    String? fotoBase64,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/attendance/check-out'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiService.getToken()}',
        },
        body: jsonEncode({
          'attendance_id': attendanceId,
          'latitude': latitude,
          'longitude': longitude,
          'foto_base64': fotoBase64,
        }),
      ).timeout(const Duration(seconds: 30));

      final result = await ApiService.handleResponse(response);
      return result;
    } catch (e) {
      throw Exception('Error check-out: ${e.toString()}');
    }
  }
}
