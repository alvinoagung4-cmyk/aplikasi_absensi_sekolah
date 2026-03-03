// lib/pages/admin_kelola_kelas_page_v2.dart
// ✅ UPDATED VERSION WITH DATABASE INTEGRATION
// This is an example of how to integrate API calls into the Kelas management page

import 'package:flutter/material.dart';
import 'package:projectone/services/api_service.dart';

class AdminKelolaKelasPageV2 extends StatefulWidget {
  const AdminKelolaKelasPageV2({Key? key}) : super(key: key);

  @override
  State<AdminKelolaKelasPageV2> createState() => _AdminKelolaKelasPageV2State();
}

class _AdminKelolaKelasPageV2State extends State<AdminKelolaKelasPageV2> {
  List<Map<String, dynamic>> daftarKelas = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadKelasFromDatabase();
  }

  // ============ LOAD DATA FROM DATABASE ============
  Future<void> _loadKelasFromDatabase() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.getAllKelas();

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as List;
        setState(() {
          daftarKelas = data.map((k) {
            return {
              'id': k['id'],
              'nama': k['nama_kelas'],
              'jurusan': k['jurusan'],
              'waliKelas': k['wali_kelas'],
              'loginWali': k['login_wali'] ?? '',
              'jumlahSiswa': k['jumlah_siswa'] ?? 0,
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load kelas');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
      print('❌ Error loading kelas: $e');
    }
  }

  // ============ CREATE/UPDATE KELAS IN DATABASE ============
  Future<void> _saveKelasToDatabase({
    int? kelasId,
    required String nama,
    required String jurusan,
    required String waliKelas,
    String? loginWali,
  }) async {
    try {
      Map<String, dynamic> response;

      if (kelasId == null) {
        // CREATE
        response = await ApiService.createKelas(
          namaKelas: nama,
          jurusan: jurusan,
          waliKelas: waliKelas,
          loginWali: loginWali,
        );
      } else {
        // UPDATE
        response = await ApiService.updateKelas(
          id: kelasId,
          namaKelas: nama,
          jurusan: jurusan,
          waliKelas: waliKelas,
          loginWali: loginWali,
        );
      }

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kelasId == null
                ? 'Kelas berhasil ditambahkan'
                : 'Kelas berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );

        // Reload data from database
        _loadKelasFromDatabase();

        // Close dialog
        Navigator.pop(context);
      } else {
        throw Exception(response['message'] ?? 'Failed to save kelas');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============ DELETE KELAS FROM DATABASE ============
  Future<void> _deleteKelasFromDatabase(int kelasId) async {
    try {
      final response = await ApiService.deleteKelas(kelasId);

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kelas berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );

        // Reload data
        _loadKelasFromDatabase();
      } else {
        throw Exception(response['message'] ?? 'Failed to delete kelas');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============ SHOW ADD/EDIT DIALOG ============
  void _showAddEditDialog({Map<String, dynamic>? kelas}) {
    final namaController = TextEditingController(text: kelas?['nama'] ?? '');
    final jurusanController =
        TextEditingController(text: kelas?['jurusan'] ?? '');
    final waliKelasController =
        TextEditingController(text: kelas?['waliKelas'] ?? '');
    final loginWaliController =
        TextEditingController(text: kelas?['loginWali'] ?? '');

    showDialog(
      context: context,
      builder: (context) => _AddEditKelasDialog(
        title: kelas == null ? 'Tambah Kelas' : 'Edit Kelas',
        namaController: namaController,
        jurusanController: jurusanController,
        waliKelasController: waliKelasController,
        loginWaliController: loginWaliController,
        onSave: () {
          _saveKelasToDatabase(
            kelasId: kelas?['id'],
            nama: namaController.text.trim(),
            jurusan: jurusanController.text.trim(),
            waliKelas: waliKelasController.text.trim(),
            loginWali: loginWaliController.text.trim(),
          );
        },
      ),
    );
  }

  // ============ SHOW DELETE CONFIRMATION ============
  void _showDeleteConfirmation(int kelasId, String namaKelas) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kelas'),
        content: Text('Yakin hapus kelas "$namaKelas"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteKelasFromDatabase(kelasId);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kelas'),
        backgroundColor: Colors.blue,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadKelasFromDatabase,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (daftarKelas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Belum ada data kelas',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showAddEditDialog(),
              child: const Text('Tambah Kelas'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadKelasFromDatabase,
      child: ListView.builder(
        itemCount: daftarKelas.length,
        itemBuilder: (context, index) {
          final kelas = daftarKelas[index];
          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              title: Text(
                kelas['nama'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text('Jurusan: ${kelas['jurusan']}'),
                  Text('Wali Kelas: ${kelas['waliKelas']}'),
                  Text('Siswa: ${kelas['jumlahSiswa']}'),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text('Edit'),
                    onTap: () {
                      Future.delayed(Duration.zero, () {
                        _showAddEditDialog(kelas: kelas);
                      });
                    },
                  ),
                  PopupMenuItem(
                    child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Future.delayed(Duration.zero, () {
                        _showDeleteConfirmation(kelas['id'], kelas['nama']);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============ ADD/EDIT DIALOG WIDGET ============
class _AddEditKelasDialog extends StatefulWidget {
  final String title;
  final TextEditingController namaController;
  final TextEditingController jurusanController;
  final TextEditingController waliKelasController;
  final TextEditingController loginWaliController;
  final VoidCallback onSave;

  const _AddEditKelasDialog({
    required this.title,
    required this.namaController,
    required this.jurusanController,
    required this.waliKelasController,
    required this.loginWaliController,
    required this.onSave,
  });

  @override
  State<_AddEditKelasDialog> createState() => _AddEditKelasDialogState();
}

class _AddEditKelasDialogState extends State<_AddEditKelasDialog> {
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: widget.namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Kelas',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: widget.jurusanController,
              decoration: const InputDecoration(
                labelText: 'Jurusan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: widget.waliKelasController,
              decoration: const InputDecoration(
                labelText: 'Wali Kelas',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: widget.loginWaliController,
              decoration: const InputDecoration(
                labelText: 'Login Wali (opsional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: isSaving
              ? null
              : () {
                  setState(() => isSaving = true);
                  widget.onSave();
                },
          child: isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}
