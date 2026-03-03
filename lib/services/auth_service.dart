import 'package:projectone/services/api_service.dart';

class AuthService {
  static String? _currentUserToken;
  static Map<String, dynamic>? _currentUser;
  
  // ============ MOCK DATA UNTUK TESTING OFFLINE ============
  static const bool USE_MOCK_API = false; // UNTUK TESTING DI WEB/EMULATOR - ganti false untuk live API
  static final Map<String, Map<String, String>> _mockUsers = {
  };

  // ============ INITIALIZATION ============
  static Future<void> init() async {
    if (!USE_MOCK_API) {
      await ApiService.init();
      _currentUserToken = ApiService.getToken();
    }
  }

  // ============ LOGIN ============
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // MOCK LOGIN untuk testing
      if (USE_MOCK_API) {
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
        
        // Cari user by nama_lengkap atau email
        for (var entry in _mockUsers.entries) {
          final user = entry.value;
          if ((user['nama_lengkap'] == email || entry.key == email) && user['password'] == password) {
            _currentUserToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
            _currentUser = {
              'id': 1,
              'email': entry.key,
              'nama_lengkap': user['nama_lengkap'],
              'no_hp': user['no_hp'],
            };
            return {
              'success': true,
              'message': '✅ Login berhasil!',
              'token': _currentUserToken,
              'user': _currentUser,
            };
          }
        }
        return {
          'success': false,
          'message': '❌ Nama lengkap atau password salah',
        };
      }
      
      // Real API call - backend akan handle login by nama_lengkap atau email
      final response = await ApiService.login(
        email: email,
        password: password,
      );

      if (response['success']) {
        _currentUserToken = response['token'];
        _currentUser = response['user'];
        return {
          'success': true,
          'message': response['message'],
          'user': response['user'],
        };
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Login gagal',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
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
      // MOCK REGISTER untuk testing
      if (USE_MOCK_API) {
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (_mockUsers.containsKey(email)) {
          return {
            'success': false,
            'message': '❌ Email sudah terdaftar',
            'email': email,
          };
        }
        
        // Simpan user baru ke mock data
        _mockUsers[email] = {
          'password': password,
          'nama_lengkap': namaLengkap,
          'no_hp': noHp,
        };
        
        return {
          'success': true,
          'message': '✅ Registrasi berhasil! Silakan login.',
          'email': email,
        };
      }
      
      // Real API call
      final response = await ApiService.register(
        namaLengkap: namaLengkap,
        noHp: noHp,
        email: email,
        password: password,
        konfirmasiPassword: konfirmasiPassword,
      );

      if (response['success']) {
        return {
          'success': true,
          'message': response['message'] ?? 'Registrasi berhasil!',
          'email': response['email'],
        };
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Registrasi gagal',
        'email': email,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  // ============ LOGOUT ============
  static Future<void> logout() async {
    _currentUserToken = null;
    _currentUser = null;
    await ApiService.clearToken();
  }

  // ============ CHECK IF LOGGED IN ============
  static bool isLoggedIn() {
    return _currentUserToken != null || ApiService.getToken() != null;
  }

  // ============ GET CURRENT USER ============
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    if (!isLoggedIn()) {
      return null;
    }

    try {
      final response = await ApiService.getCurrentUser();
      if (response['success']) {
        _currentUser = response['user'];
        return response['user'];
      }
      return _currentUser;
    } catch (e) {
      return _currentUser;
    }
  }

  // ============ GET USER DATA (CACHED) ============
  static Map<String, dynamic>? getUserData() {
    return _currentUser;
  }

  // ============ GET TOKEN ============
  static String? getToken() {
    return _currentUserToken ?? ApiService.getToken();
  }

  // ============ VALIDATORS ============
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (password.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  static String? validateNamaLengkap(String? nama) {
    if (nama == null || nama.isEmpty) {
      return 'Nama lengkap tidak boleh kosong';
    }
    if (nama.length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }
}
