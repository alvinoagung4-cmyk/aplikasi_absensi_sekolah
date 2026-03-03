import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projectone/services/auth_service.dart';
import 'package:projectone/pages/home_page.dart';
import 'package:projectone/pages/admin_dashboard_page.dart';
import 'package:projectone/widgets/admin_widgets.dart';
import 'registration_page.dart';

class LoginPageNew extends StatefulWidget {
  const LoginPageNew({super.key});

  @override
  State<LoginPageNew> createState() => _LoginPageNewState();
}

class _LoginPageNewState extends State<LoginPageNew> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedRole = 'siswa'; // siswa, wali, admin

  // Logo configuration (bisa diganti dengan path file lokal)
  final String _schoolLogo = 'assets/icons/school_icon.png';
  final String _schoolName = 'SMKN I KEPANJAN';
  final String _schoolSubtitle = 'Sistem Absensi Siswa';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Simulasi login berdasarkan role
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        bool loginSuccess = false;

        if (_selectedRole == 'admin') {
          // Admin credentials: admin / admin123
          if (_usernameController.text == 'admin' &&
              _passwordController.text == 'admin123') {
            loginSuccess = true;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
            );
          }
        } else if (_selectedRole == 'wali') {
          // Wali credentials: tei / tei23 (example)
          if (_usernameController.text.isNotEmpty &&
              _passwordController.text.isNotEmpty) {
            loginSuccess = true;
            // Navigate to wali dashboard (bisa dibuat nanti)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Dashboard Wali Kelas - Segera Hadir')),
            );
          }
        } else {
          // Siswa login dengan AuthService
          final result = await AuthService.login(
            email: _usernameController.text.trim(),
            password: _passwordController.text,
          );

          if (result['success']) {
            loginSuccess = true;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        }

        if (!loginSuccess) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Username atau password salah untuk role $_selectedRole';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2A42),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: SizedBox(
                  width: 400,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo & School Name
                        Center(
                          child: SchoolLogo(
                            logoAssetPath: _schoolLogo,
                            schoolName: _schoolName,
                            schoolSubtitle: _schoolSubtitle,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Date
                        Center(
                          child: Text(
                            DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                                .format(DateTime.now()),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Role Selection
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            underline: const SizedBox.shrink(),
                            value: _selectedRole,
                            items: const [
                              DropdownMenuItem(
                                value: 'siswa',
                                child: Text('📚 Siswa'),
                              ),
                              DropdownMenuItem(
                                value: 'wali',
                                child: Text('👨‍🏫 Wali Kelas'),
                              ),
                              DropdownMenuItem(
                                value: 'admin',
                                child: Text('👤 Admin'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() => _selectedRole = value ?? 'siswa');
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Error Message
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFEF5350),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Color(0xFFEF5350),
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Color(0xFFEF5350),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_errorMessage != null) const SizedBox(height: 20),

                        // Username Field
                        const Text(
                          'Username',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _usernameController,
                          enabled: !_isLoading,
                          decoration: InputDecoration(
                            hintText: 'Masukkan username',
                            prefixIcon:
                                const Icon(Icons.person, color: Color(0xFF2196F3)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Username tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          enabled: !_isLoading,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Masukkan password',
                            prefixIcon:
                                const Icon(Icons.lock, color: Color(0xFF2196F3)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: const Color(0xFF2196F3),
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        // Login Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            disabledBackgroundColor: Colors.grey[300],
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  '🔐 Masuk',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20),

                        // Register Link
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegistrationPage(),
                                ),
                              );
                            },
                            child: RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Belum punya akun? ',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  TextSpan(
                                    text: 'Daftar di sini',
                                    style: TextStyle(
                                      color: Color(0xFF2196F3),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Credentials Info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '📋 Kredensial Testing:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildCredentialRow(
                                'Admin',
                                'admin / admin123',
                              ),
                              const SizedBox(height: 6),
                              _buildCredentialRow(
                                'Wali Kelas',
                                '[kode kelas] / [password kelas]',
                              ),
                              const SizedBox(height: 6),
                              _buildCredentialRow(
                                'Siswa',
                                'Gunakan form registrasi',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialRow(String label, String credential) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
        Text(
          credential,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2196F3),
          ),
        ),
      ],
    );
  }
}
