import 'package:flutter/material.dart';

/// Logo Widget yang configurable
class SchoolLogo extends StatelessWidget {
  final String logoAssetPath;
  final String schoolName;
  final String schoolSubtitle;
  final double logoSize;
  final Color? backgroundColor;
  final bool showText;

  const SchoolLogo({
    required this.logoAssetPath,
    required this.schoolName,
    this.schoolSubtitle = 'Sistem Absensi Siswa',
    this.logoSize = 50,
    this.backgroundColor,
    this.showText = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo Container
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF42A5F5).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: _buildLogoContent(),
        ),
        if (showText) ...[
          const SizedBox(height: 28),
          Text(
            schoolName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            schoolSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFBBBBBB),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLogoContent() {
    try {
      // Coba load image dari asset
      return Image.asset(
        logoAssetPath,
        width: logoSize,
        height: logoSize,
        color: Colors.white,
        errorBuilder: (context, error, stackTrace) {
          // Fallback ke icon jika asset tidak ditemukan
          return Icon(
            Icons.school,
            size: logoSize,
            color: Colors.white,
          );
        },
      );
    } catch (e) {
      // Fallback ke icon
      return Icon(
        Icons.school,
        size: logoSize,
        color: Colors.white,
      );
    }
  }
}

/// Custom AppBar untuk Admin dengan Logout
class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onLogout;
  final List<Widget>? actions;

  const AdminAppBar({
    required this.title,
    this.onLogout,
    this.actions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF2196F3),
      elevation: 0,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: false,
      actions: [
        ...(actions ?? []),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: PopupMenuButton<String>(
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 18),
                      SizedBox(width: 8),
                      Text('Profil'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Logout', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (String value) {
                if (value == 'logout' && onLogout != null) {
                  onLogout!();
                }
              },
              icon: const Icon(Icons.more_vert, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Dialog untuk menambah/edit Kelas
class AddKelasDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialData;

  const AddKelasDialog({
    required this.onSave,
    this.initialData,
    super.key,
  });

  @override
  State<AddKelasDialog> createState() => _AddKelasDialogState();
}

class _AddKelasDialogState extends State<AddKelasDialog> {
  late TextEditingController _namaKelasController;
  late TextEditingController _waliKelasController;
  String _selectedJurusan = 'TEI';
  bool _isLoading = false;

  final List<String> jurusanList = ['TEI', 'TKR', 'TBSM', 'RPL', 'TKJ'];

  @override
  void initState() {
    super.initState();
    _namaKelasController = TextEditingController(
      text: widget.initialData?['namaKelas'] ?? '',
    );
    _waliKelasController = TextEditingController(
      text: widget.initialData?['waliKelas'] ?? '',
    );
    _selectedJurusan = widget.initialData?['jurusan'] ?? 'TEI';
  }

  @override
  void dispose() {
    _namaKelasController.dispose();
    _waliKelasController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_namaKelasController.text.isEmpty || _waliKelasController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        widget.onSave({
          'namaKelas': _namaKelasController.text,
          'jurusan': _selectedJurusan,
          'waliKelas': _waliKelasController.text,
        });
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tambah Kelas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Nama Kelas
              const Text(
                'Nama Kelas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _namaKelasController,
                decoration: InputDecoration(
                  hintText: 'Contoh: X TEI 1',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Jurusan
              const Text(
                'Jurusan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedJurusan,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                items: jurusanList.map((jur) {
                  return DropdownMenuItem(
                    value: jur,
                    child: Text(jur),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedJurusan = value ?? 'TEI');
                },
              ),
              const SizedBox(height: 16),

              // Wali Kelas
              const Text(
                'Wali Kelas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _waliKelasController,
                decoration: InputDecoration(
                  hintText: 'Nama lengkap wali kelas',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleSave,
                    icon: const Icon(Icons.save, size: 18),
                    label: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Simpan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
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
}

/// Dialog untuk menambah/edit Siswa
class AddSiswaDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final List<String> daftarKelas;
  final Map<String, dynamic>? initialData;

  const AddSiswaDialog({
    required this.onSave,
    required this.daftarKelas,
    this.initialData,
    super.key,
  });

  @override
  State<AddSiswaDialog> createState() => _AddSiswaDialogState();
}

class _AddSiswaDialogState extends State<AddSiswaDialog> {
  late TextEditingController _namaSiswaController;
  late String _selectedKelas;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaSiswaController = TextEditingController(
      text: widget.initialData?['namaSiswa'] ?? '',
    );
    _selectedKelas = widget.initialData?['kelas'] ?? 
        (widget.daftarKelas.isNotEmpty ? widget.daftarKelas[0] : '');
  }

  @override
  void dispose() {
    _namaSiswaController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_namaSiswaController.text.isEmpty || _selectedKelas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        widget.onSave({
          'namaSiswa': _namaSiswaController.text,
          'kelas': _selectedKelas,
        });
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tambah Siswa',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Nama Siswa
              const Text(
                'Nama Siswa',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _namaSiswaController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama siswa',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Kelas
              const Text(
                'Kelas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedKelas.isNotEmpty ? _selectedKelas : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                items: widget.daftarKelas.map((kelas) {
                  return DropdownMenuItem(
                    value: kelas,
                    child: Text(kelas),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedKelas = value ?? '');
                },
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleSave,
                    icon: const Icon(Icons.save, size: 18),
                    label: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Simpan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
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
}

/// Confirm Dialog
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final Color? confirmColor;

  const ConfirmDialog({
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmText = 'Ya',
    this.cancelText = 'Batal',
    this.confirmColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? const Color(0xFFF44336),
            foregroundColor: Colors.white,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
