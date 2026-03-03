import 'package:flutter/material.dart';

class AdminPengaturanPage extends StatefulWidget {
  const AdminPengaturanPage({super.key});

  @override
  State<AdminPengaturanPage> createState() => _AdminPengaturanPageState();
}

class _AdminPengaturanPageState extends State<AdminPengaturanPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordLamaController = TextEditingController();
  final _passwordBaruController = TextEditingController();
  final _konfirmasiPasswordController = TextEditingController();

  bool _isPasswordVisible1 = false;
  bool _isPasswordVisible2 = false;
  bool _isPasswordVisible3 = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordLamaController.dispose();
    _passwordBaruController.dispose();
    _konfirmasiPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() {
    if (_formKey.currentState!.validate()) {
      if (_passwordBaruController.text != _konfirmasiPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password baru tidak cocok dengan konfirmasi'),
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password berhasil diubah'),
              backgroundColor: Colors.green,
            ),
          );
          _passwordLamaController.clear();
          _passwordBaruController.clear();
          _konfirmasiPasswordController.clear();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Pengaturan Admin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Kelola pengaturan sistem dan akun admin',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // Grid Layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column - Account Management & System Info
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      // Card 1: Keamanan Akun
                      _buildLargeCard(
                        title: 'Keamanan Akun',
                        subtitle: 'Ubah password dan pengaturan login',
                        icon: Icons.lock_outline,
                        backgroundColor: const Color(0xFFFFEBEE),
                        child: _buildPasswordChangeForm(),
                      ),
                      const SizedBox(height: 24),
                      // Card 2: Informasi Sistem
                      _buildInfoCard(
                        title: 'Informasi Sistem',
                        subtitle: 'Data sistem dan akun admin',
                        icon: Icons.info_outline,
                        backgroundColor: const Color(0xFFE3F2FD),
                        details: [
                          InfoDetail(
                            label: 'Akun Administrator',
                            value: 'admin',
                          ),
                          InfoDetail(
                            label: 'Status',
                            value: 'Aktif & Berfungsi',
                            valueColor: const Color(0xFF4CAF50),
                          ),
                          InfoDetail(
                            label: 'Role',
                            value: 'Administrator',
                            icon: Icons.admin_panel_settings,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Right Column - Statistics & Tips
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      // Card 3: Statistik Sistem
                      _buildStatsCard(
                        title: 'Statistik Sistem',
                        subtitle: 'Ringkasan data dalam sistem',
                        icon: Icons.bar_chart_outlined,
                        backgroundColor: const Color(0xFFF0F4C3),
                        stats: [
                          StatItem(
                            label: 'Total Kelas',
                            value: '20',
                            color: const Color(0xFF4CAF50),
                          ),
                          StatItem(
                            label: 'Total Siswa',
                            value: '25',
                            color: const Color(0xFF2196F3),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Card 4: Bantuan & Panduan
                      _buildTipsCard(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordChangeForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Password Lama
          TextFormField(
            controller: _passwordLamaController,
            obscureText: !_isPasswordVisible1,
            decoration: InputDecoration(
              labelText: 'Password Lama',
              hintText: 'Masukkan password lama',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible1
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible1 = !_isPasswordVisible1;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password lama tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Password Baru
          TextFormField(
            controller: _passwordBaruController,
            obscureText: !_isPasswordVisible2,
            decoration: InputDecoration(
              labelText: 'Password Baru',
              hintText: 'Minimal 6 karakter',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible2
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible2 = !_isPasswordVisible2;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password baru tidak boleh kosong';
              }
              if (value.length < 6) {
                return 'Password baru minimal 6 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Konfirmasi Password
          TextFormField(
            controller: _konfirmasiPasswordController,
            obscureText: !_isPasswordVisible3,
            decoration: InputDecoration(
              labelText: 'Konfirmasi Password',
              hintText: 'Ketik ulang password baru',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible3
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible3 = !_isPasswordVisible3;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Konfirmasi password tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          // Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _changePassword,
              icon: const Icon(Icons.lock_reset),
              label: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Simpan Password Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color backgroundColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFF44336),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Content
          child,
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color backgroundColor,
    required List<InfoDetail> details,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF2196F3),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Details
          Column(
            children: details.asMap().entries.map((entry) {
              final detail = entry.value;
              final isLast = entry.key == details.length - 1;
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (detail.icon != null)
                            Icon(
                              detail.icon,
                              size: 18,
                              color: Colors.grey[600],
                            )
                          else
                            SizedBox(width: 18),
                          const SizedBox(width: 12),
                          Text(
                            detail.label,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        detail.value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color:
                              detail.valueColor ?? const Color(0xFF2196F3),
                        ),
                      ),
                    ],
                  ),
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: Colors.grey[200]),
                    )
                  else
                    const SizedBox(height: 12),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color backgroundColor,
    required List<StatItem> stats,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFFFC107),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Stats
          Column(
            children: stats.map((stat) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      stat.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      stat.value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: stat.color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9C4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.help_outline,
                  color: Color(0xFFFFC107),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bantuan & Panduan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tips penggunaan sistem',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Tips
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9C4).withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💡 Tips Keamanan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ganti password secara berkala dan hindari password yang mudah ditebak',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9C4).withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🔒 Akses sistem hanya dari perangkat aman dan terpercaya',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InfoDetail {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;

  InfoDetail({
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
  });
}

class StatItem {
  final String label;
  final String value;
  final Color color;

  StatItem({
    required this.label,
    required this.value,
    required this.color,
  });
}
