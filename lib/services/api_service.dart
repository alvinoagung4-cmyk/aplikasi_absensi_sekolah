import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


class ApiService {

  // ========== NGROK CONFIGURATION ==========
  // Ngrok URL untuk production/development
  static const String _ngrokUrl = 'https://cheliform-unappreciably-allison.ngrok-free.dev/api';

  // Development URLs - menggunakan ngrok
  static const String _developmentMobileUrl = 'https://cheliform-unappreciably-allison.ngrok-free.dev/api';
  static const String _developmentWebUrl = 'https://cheliform-unappreciably-allison.ngrok-free.dev/api';

  // MODE: set to true for production, false untuk development/ngrok
  static const bool isProduction = false; // ✅ Set ke FALSE untuk menggunakan ngrok

  static String get baseUrl {
    // Selalu menggunakan ngrok (isProduction = false)
    if (kIsWeb) {
      return _developmentWebUrl;
    }
    return _developmentMobileUrl;
  }

  static void printBaseUrl() {
    print('🌐 API Base URL: $baseUrl');
    print('📱 Environment: ${isProduction ? 'PRODUCTION' : 'DEVELOPMENT'}');
  }

  static String? _token;

  // ============ INITIALIZATION ============
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    printBaseUrl(); // Print current environment
  }

  // ============ SAVE & LOAD TOKEN ============
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _token = token;
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
  }

  static String? getToken() => _token;

  // ============ HELPER FUNCTION ============
  static Future<dynamic> _handleResponse(http.Response response) async {
    try {
      final body = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return body;
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        await clearToken();
        throw Exception(body['message'] ?? 'Token expired or invalid');
      } else if (response.statusCode == 400) {
        throw Exception(body['message'] ?? 'Bad request');
      } else if (response.statusCode == 404) {
        throw Exception(body['message'] ?? 'Endpoint not found');
      } else if (response.statusCode == 500) {
        throw Exception(body['message'] ?? 'Server error');
      } else {
        throw Exception(body['message'] ?? 'Terjadi kesalahan: ${response.statusCode}');
      }
    } catch (e) {
      if (e is FormatException) {
        print('❌ Response parsing error: ${response.body}');
        throw Exception('Invalid response format from server');
      }
      rethrow;
    }
  }

  // ============ PUBLIC HANDLE RESPONSE (untuk service lain) ============
  static Future<dynamic> handleResponse(http.Response response) async {
    return _handleResponse(response);
  }

  // ============ REGISTER ============
  static Future<Map<String, dynamic>> register({
    required String namaLengkap,
    required String noHp,
    required String email,
    required String password,
    required String konfirmasiPassword,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/register');
      print('📤 Register request to: $url');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'nama_lengkap': namaLengkap,
          'no_hp': noHp,
          'email': email,
          'password': password,
          'konfirmasi_password': konfirmasiPassword,
        }),
      ).timeout(const Duration(seconds: 15));

      print('📥 Register response: ${response.statusCode}');
      return await _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout - backend server tidak merespons');
    } on SocketException {
      throw Exception('Network error - pastikan internet terhubung');
    } catch (e) {
      print('❌ Register error: ${e.toString()}');
      throw Exception('Register error: ${e.toString()}');
    }
  }

  // ============ LOGIN ============
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/login');
      print('📤 Login request to: $url');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      print('📥 Login response: ${response.statusCode}');
      
      final result = await _handleResponse(response);
      
      if (result['success'] && result['token'] != null) {
        await saveToken(result['token']);
      }

      return result;
    } on TimeoutException {
      throw Exception('Request timeout - backend server tidak merespons');
    } on SocketException {
      throw Exception('Network error - pastikan internet terhubung');
    } catch (e) {
      print('❌ Login error: ${e.toString()}');
      throw Exception('Login error: ${e.toString()}');
    }
  }

  // ============ GET CURRENT USER ============
  static Future<Map<String, dynamic>> getCurrentUser() async {
    if (_token == null) {
      throw Exception('Token tidak ditemukan');
    }

    try {
      final url = Uri.parse('$baseUrl/me');
      print('📤 Get current user from: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 15));

      print('📥 getCurrentUser response: ${response.statusCode}');
      return await _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout - backend server tidak merespons');
    } on SocketException {
      throw Exception('Network error - pastikan internet terhubung');
    } catch (e) {
      print('❌ getCurrentUser error: ${e.toString()}');
      throw Exception('Error: ${e.toString()}');
    }
  }

  // ============ CHECK-IN ============
  static Future<Map<String, dynamic>> checkIn({
    required String location,
  }) async {
    if (_token == null) {
      throw Exception('Token tidak ditemukan');
    }

    try {
      final url = Uri.parse('$baseUrl/check-in');
      print('📤 Check-in request to: $url');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'location': location,
        }),
      ).timeout(const Duration(seconds: 15));

      print('📥 Check-in response: ${response.statusCode}');
      return await _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout - backend server tidak merespons');
    } on SocketException {
      throw Exception('Network error - pastikan internet terhubung');
    } catch (e) {
      print('❌ Check-in error: ${e.toString()}');
      throw Exception('Error: ${e.toString()}');
    }
  }

  // ============ CHECK-OUT ============
  static Future<Map<String, dynamic>> checkOut() async {
    if (_token == null) {
      throw Exception('Token tidak ditemukan');
    }

    try {
      final url = Uri.parse('$baseUrl/check-out');
      print('📤 Check-out request to: $url');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({}),
      ).timeout(const Duration(seconds: 15));

      print('📥 Check-out response: ${response.statusCode}');
      return await _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout - backend server tidak merespons');
    } on SocketException {
      throw Exception('Network error - pastikan internet terhubung');
    } catch (e) {
      print('❌ Check-out error: ${e.toString()}');
      throw Exception('Error: ${e.toString()}');
    }
  }

  // ============ GET TODAY'S ATTENDANCE ============
  static Future<Map<String, dynamic>> getTodayAttendance() async {
    if (_token == null) {
      throw Exception('Token tidak ditemukan');
    }

    try {
      final url = Uri.parse('$baseUrl/attendance/today');
      print('📤 Get today attendance from: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 15));

      print('📥 Today attendance response: ${response.statusCode}');
      return await _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout - backend server tidak merespons');
    } on SocketException {
      throw Exception('Network error - pastikan internet terhubung');
    } catch (e) {
      print('❌ getTodayAttendance error: ${e.toString()}');
      throw Exception('Error: ${e.toString()}');
    }
  }

  // ============ GET ATTENDANCE HISTORY ============
  static Future<Map<String, dynamic>> getAttendanceHistory() async {
    if (_token == null) {
      throw Exception('Token tidak ditemukan');
    }

    try {
      final url = Uri.parse('$baseUrl/attendance/history');
      print('📤 Get attendance history from: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 15));

      print('📥 Attendance history response: ${response.statusCode}');
      return await _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout - backend server tidak merespons');
    } on SocketException {
      throw Exception('Network error - pastikan internet terhubung');
    } catch (e) {
      print('❌ getAttendanceHistory error: ${e.toString()}');
      throw Exception('Error: ${e.toString()}');
    }
  }

  // ============ HEALTH CHECK ============
  static Future<bool> checkServerHealth() async {
    try {
      final url = Uri.parse('$baseUrl/health');
      print('🏥 Checking server health at: $url');
      
      final response = await http.get(url)
          .timeout(const Duration(seconds: 10));

      final isHealthy = response.statusCode == 200;
      print(isHealthy ? '✅ Server is healthy' : '⚠️ Server health check failed');
      return isHealthy;
    } catch (e) {
      print('❌ Health check error: ${e.toString()}');
      return false;
    }
  }

  // ============ DELETE ATTENDANCE ============
  static Future<Map<String, dynamic>> deleteAttendance(int attendanceId) async {
    if (_token == null) {
      throw Exception('Token tidak ditemukan');
    }

    try {
      final url = Uri.parse('$baseUrl/attendance/$attendanceId');
      print('📤 Delete attendance request to: $url');
      
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 15));

      print('📥 Delete response: ${response.statusCode}');
      return await _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout - backend server tidak merespons');
    } on SocketException {
      throw Exception('Network error - pastikan internet terhubung');
    } catch (e) {
      print('❌ deleteAttendance error: ${e.toString()}');
      throw Exception('Error: ${e.toString()}');
    }
  }

  // ============ UPDATE PROFILE ============
  static Future<Map<String, dynamic>> updateProfile({
    String? email,
    String? noHp,
  }) async {
    if (_token == null) {
      throw Exception('Token tidak ditemukan');
    }

    try {
      final url = Uri.parse('$baseUrl/profile');
      final body = <String, dynamic>{};
      if (email != null) body['email'] = email;
      if (noHp != null) body['no_hp'] = noHp;

      print('📤 Update profile request to: $url');
      
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      print('📥 Update profile response: ${response.statusCode}');
      return await _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout - backend server tidak merespons');
    } on SocketException {
      throw Exception('Network error - pastikan internet terhubung');
    } catch (e) {
      print('❌ updateProfile error: ${e.toString()}');
      throw Exception('Error: ${e.toString()}');
    }
  }

  // ============ CHANGE PASSWORD ============
  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (_token == null) {
      throw Exception('Token tidak ditemukan');
    }

    try {
      final url = Uri.parse('$baseUrl/change-password');
      print('📤 Change password request to: $url');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      ).timeout(const Duration(seconds: 15));

      print('📥 Change password response: ${response.statusCode}');
      return await _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout - backend server tidak merespons');
    } on SocketException {
      throw Exception('Network error - pastikan internet terhubung');
    } catch (e) {
      print('❌ changePassword error: ${e.toString()}');
      throw Exception('Error: ${e.toString()}');
    }
  }

  // ============ KELAS MANAGEMENT ============
  
  // Get all kelas
  static Future<Map<String, dynamic>> getAllKelas() async {
    try {
      final url = Uri.parse('$baseUrl/kelas');
      print('📤 GET all kelas from: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('📥 Get kelas response: ${response.statusCode}');
      return await _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout');
    } on SocketException {
      throw Exception('Network error');
    } catch (e) {
      print('❌ getAllKelas error: ${e.toString()}');
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Get kelas by ID
  static Future<Map<String, dynamic>> getKelasById(int id) async {
    try {
      final url = Uri.parse('$baseUrl/kelas/$id');
      print('📤 GET kelas by ID: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('📥 Get kelas by ID response: ${response.statusCode}');
      return await _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout');
    } on SocketException {
      throw Exception('Network error');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Create kelas
  static Future<Map<String, dynamic>> createKelas({
    required String namaKelas,
    required String jurusan,
    required String waliKelas,
    String? loginWali,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/kelas');
      final body = {
        'nama_kelas': namaKelas,
        'jurusan': jurusan,
        'wali_kelas': waliKelas,
        'login_wali': loginWali ?? '',
      };

      print('📤 Create kelas: $url');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      print('📥 Create kelas response: ${response.statusCode}');
      return await _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout');
    } on SocketException {
      throw Exception('Network error');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Update kelas
  static Future<Map<String, dynamic>> updateKelas({
    required int id,
    required String namaKelas,
    required String jurusan,
    required String waliKelas,
    String? loginWali,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/kelas/$id');
      final body = {
        'nama_kelas': namaKelas,
        'jurusan': jurusan,
        'wali_kelas': waliKelas,
        'login_wali': loginWali ?? '',
      };

      print('📤 Update kelas: $url');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      print('📥 Update kelas response: ${response.statusCode}');
      return await _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout');
    } on SocketException {
      throw Exception('Network error');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Delete kelas
  static Future<Map<String, dynamic>> deleteKelas(int id) async {
    try {
      final url = Uri.parse('$baseUrl/kelas/$id');
      print('📤 Delete kelas: $url');
      
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('📥 Delete kelas response: ${response.statusCode}');
      return await _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout');
    } on SocketException {
      throw Exception('Network error');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // ============ SISWA MANAGEMENT ============

  // Get all siswa
  static Future<Map<String, dynamic>> getAllSiswa() async {
    try {
      final url = Uri.parse('$baseUrl/siswa');
      print('📤 GET all siswa from: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('📥 Get siswa response: ${response.statusCode}');
      return await _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout');
    } on SocketException {
      throw Exception('Network error');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Get siswa by ID
  static Future<Map<String, dynamic>> getSiswaById(int id) async {
    try {
      final url = Uri.parse('$baseUrl/siswa/$id');
      print('📤 GET siswa by ID: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('📥 Get siswa response: ${response.statusCode}');
      return await _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout');
    } on SocketException {
      throw Exception('Network error');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Get siswa by kelas
  static Future<Map<String, dynamic>> getSiswaByKelas(int kelasId) async {
    try {
      final url = Uri.parse('$baseUrl/siswa/kelas/$kelasId');
      print('📤 GET siswa by kelas: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('📥 Get siswa by kelas response: ${response.statusCode}');
      return await _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout');
    } on SocketException {
      throw Exception('Network error');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Create siswa
  static Future<Map<String, dynamic>> createSiswa({
    required String namaSiswa,
    required int kelasId,
    String? jurusan,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/siswa');
      final body = {
        'nama_siswa': namaSiswa,
        'kelas_id': kelasId,
        'jurusan': jurusan ?? '',
      };

      print('📤 Create siswa: $url');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      print('📥 Create siswa response: ${response.statusCode}');
      return await _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout');
    } on SocketException {
      throw Exception('Network error');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Update siswa
  static Future<Map<String, dynamic>> updateSiswa({
    required int id,
    required String namaSiswa,
    required int kelasId,
    String? jurusan,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/siswa/$id');
      final body = {
        'nama_siswa': namaSiswa,
        'kelas_id': kelasId,
        'jurusan': jurusan ?? '',
      };

      print('📤 Update siswa: $url');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      print('📥 Update siswa response: ${response.statusCode}');
      return await _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout');
    } on SocketException {
      throw Exception('Network error');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Delete siswa
  static Future<Map<String, dynamic>> deleteSiswa(int id) async {
    try {
      final url = Uri.parse('$baseUrl/siswa/$id');
      print('📤 Delete siswa: $url');
      
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('📥 Delete siswa response: ${response.statusCode}');
      return await _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout');
    } on SocketException {
      throw Exception('Network error');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Update attendance
  static Future<Map<String, dynamic>> updateAttendance({
    required int siswaId,
    required String status,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/siswa/$siswaId/attendance');
      final body = {'status': status};

      print('📤 Update attendance: $url');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      print('📥 Update attendance response: ${response.statusCode}');
      return await _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout');
    } on SocketException {
      throw Exception('Network error');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }
}
