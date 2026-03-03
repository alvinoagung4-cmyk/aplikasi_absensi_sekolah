import 'package:flutter/material.dart';
import 'package:projectone/models/admin_model.dart';
import 'package:projectone/widgets/admin_widgets.dart';

class AdminKelolaSiswaPage extends StatefulWidget {
  const AdminKelolaSiswaPage({super.key});

  @override
  State<AdminKelolaSiswaPage> createState() => _AdminKelolaSiswaPageState();
}

class _AdminKelolaSiswaPageState extends State<AdminKelolaSiswaPage> {
  String _selectedKelas = 'Semua';
  
  late final List<Siswa> daftarSiswa = [
    // X TEI 1
    Siswa(
      id: '1',
      namaSiswa: 'Siswa 1 X TEI 1',
      kelas: 'X TEI 1',
      jurusan: 'TEI',
      jumlahHadir: 5,
      jumlahIzin: 0,
      jumlahSakit: 0,
      jumlahAlpha: 0,
    ),
    Siswa(
      id: '2',
      namaSiswa: 'Siswa 2 X TEI 1',
      kelas: 'X TEI 1',
      jurusan: 'TEI',
      jumlahHadir: 5,
      jumlahIzin: 0,
      jumlahSakit: 0,
      jumlahAlpha: 0,
    ),
    Siswa(
      id: '3',
      namaSiswa: 'Siswa 3 X TEI 1',
      kelas: 'X TEI 1',
      jurusan: 'TEI',
      jumlahHadir: 3,
      jumlahIzin: 1,
      jumlahSakit: 1,
      jumlahAlpha: 0,
    ),
    Siswa(
      id: '4',
      namaSiswa: 'Siswa 4 X TEI 1',
      kelas: 'X TEI 1',
      jurusan: 'TEI',
      jumlahHadir: 4,
      jumlahIzin: 1,
      jumlahSakit: 0,
      jumlahAlpha: 0,
    ),
    Siswa(
      id: '5',
      namaSiswa: 'Siswa 5 X TEI 1',
      kelas: 'X TEI 1',
      jurusan: 'TEI',
      jumlahHadir: 2,
      jumlahIzin: 1,
      jumlahSakit: 1,
      jumlahAlpha: 1,
    ),
    // X TEI 2
    Siswa(
      id: '6',
      namaSiswa: 'Siswa 1 X TEI 2',
      kelas: 'X TEI 2',
      jurusan: 'TEI',
      jumlahHadir: 5,
      jumlahIzin: 0,
      jumlahSakit: 0,
      jumlahAlpha: 0,
    ),
    Siswa(
      id: '7',
      namaSiswa: 'Siswa 2 X TEI 2',
      kelas: 'X TEI 2',
      jurusan: 'TEI',
      jumlahHadir: 5,
      jumlahIzin: 0,
      jumlahSakit: 0,
      jumlahAlpha: 0,
    ),
    // XI TEI 1
    Siswa(
      id: '8',
      namaSiswa: 'Siswa 1 XI TEI 1',
      kelas: 'XI TEI 1',
      jurusan: 'TEI',
      jumlahHadir: 0,
      jumlahIzin: 0,
      jumlahSakit: 0,
      jumlahAlpha: 0,
    ),
    // XI TEI 2
    Siswa(
      id: '9',
      namaSiswa: 'Siswa 1 XI TEI 2',
      kelas: 'XI TEI 2',
      jurusan: 'TEI',
      jumlahHadir: 0,
      jumlahIzin: 0,
      jumlahSakit: 0,
      jumlahAlpha: 0,
    ),
    // X TKR 1
    Siswa(
      id: '10',
      namaSiswa: 'Siswa 1 X TKR 1',
      kelas: 'X TKR 1',
      jurusan: 'TKR',
      jumlahHadir: 5,
      jumlahIzin: 0,
      jumlahSakit: 0,
      jumlahAlpha: 0,
    ),
  ];

  final List<String> kelasList = [
    'Semua',
    'X TEI 1',
    'X TEI 2',
    'XI TEI 1',
    'XI TEI 2',
    'XII TEI',
    'X TKR 1',
    'X TKR 2',
    'XI TKR 1',
    'XI TKR 2',
  ];

  List<Siswa> getFilteredSiswa() {
    if (_selectedKelas == 'Semua') {
      return daftarSiswa;
    }
    return daftarSiswa.where((s) => s.kelas == _selectedKelas).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSiswa = getFilteredSiswa();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kelola Siswa',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kelola data siswa per kelas',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AddSiswaDialog(
                        daftarKelas: kelasList.skip(1).toList(),
                        onSave: (data) {
                          setState(() {
                            daftarSiswa.add(
                              Siswa(
                                id: (daftarSiswa.length + 1).toString(),
                                namaSiswa: data['namaSiswa'] as String,
                                kelas: data['kelas'] as String,
                                jurusan: (data['kelas'] as String).split(' ')[1],
                                jumlahHadir: 0,
                                jumlahIzin: 0,
                                jumlahSakit: 0,
                                jumlahAlpha: 0,
                              ),
                            );
                          });
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Siswa ${data['namaSiswa']} berhasil ditambahkan'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Siswa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Filter Kelas
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: kelasList.length,
                itemBuilder: (context, index) {
                  final kelas = kelasList[index];
                  final isSelected = _selectedKelas == kelas;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(kelas),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedKelas = kelas;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFF2196F3),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF2196F3)
                            : Colors.grey[300]!,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Siswa Cards Grid
            if (filteredSiswa.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada siswa',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: filteredSiswa.length,
                itemBuilder: (context, index) {
                  final siswa = filteredSiswa[index];
                  return _buildSiswaCard(siswa);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSiswaCard(Siswa siswa) {
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      siswa.kelas,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      siswa.namaSiswa,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'detail',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, size: 16),
                        SizedBox(width: 8),
                        Text('Detail'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16),
                        SizedBox(width: 8),
                        Text('Hapus'),
                      ],
                    ),
                  ),
                ],
                onSelected: (String value) {
                  if (value == 'edit') {
                    showDialog(
                      context: context,
                      builder: (context) => AddSiswaDialog(
                        daftarKelas: kelasList.skip(1).toList(),
                        initialData: {
                          'namaSiswa': siswa.namaSiswa,
                          'kelas': siswa.kelas,
                        },
                        onSave: (data) {
                          setState(() {
                            siswa.namaSiswa = data['namaSiswa'] as String;
                            siswa.kelas = data['kelas'] as String;
                          });
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Siswa berhasil diperbarui'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                      ),
                    );
                  } else if (value == 'detail') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Detail ${siswa.namaSiswa}'),
                      ),
                    );
                  } else if (value == 'delete') {
                    showDialog(
                      context: context,
                      builder: (context) => ConfirmDialog(
                        title: 'Hapus Siswa',
                        message:
                            'Apakah Anda yakin ingin menghapus ${siswa.namaSiswa}?',
                        onConfirm: () {
                          setState(() {
                            daftarSiswa.removeWhere((s) => s.id == siswa.id);
                          });
                          Navigator.pop(context);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${siswa.namaSiswa} berhasil dihapus',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    );
                  }
                },
                child: Icon(Icons.more_vert, size: 18, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Attendance Stats
          Row(
            children: [
              _buildStatBadge('Hadir', siswa.jumlahHadir, Colors.green),
              const SizedBox(width: 6),
              _buildStatBadge('Izin', siswa.jumlahIzin, Colors.orange),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildStatBadge('Sakit', siswa.jumlahSakit, Colors.blue),
              const SizedBox(width: 6),
              _buildStatBadge('Alpha', siswa.jumlahAlpha, Colors.red),
            ],
          ),
          const SizedBox(height: 12),
          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lihat detail ${siswa.namaSiswa}'),
                  ),
                );
              },
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text('Lihat Siswa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                textStyle: const TextStyle(fontSize: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
              ),
            ),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
