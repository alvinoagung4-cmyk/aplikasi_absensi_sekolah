import 'package:flutter/material.dart';
import 'package:projectone/models/admin_model.dart';
import 'package:projectone/widgets/admin_widgets.dart';

class AdminKelolaKelasPage extends StatefulWidget {
  const AdminKelolaKelasPage({super.key});

  @override
  State<AdminKelolaKelasPage> createState() => _AdminKelolaKelasPageState();
}

class _AdminKelolaKelasPageState extends State<AdminKelolaKelasPage> {
  late final List<Kelas> daftarKelas = [
    Kelas(
      id: '1',
      namaKelas: 'X TEI 1',
      jurusan: 'TEI',
      waliKelas: 'Pak Ahmad',
      loginWali: 'teil / teil23',
      jumlahSiswa: 5,
      aksi: 'Lihat',
    ),
    Kelas(
      id: '2',
      namaKelas: 'X TEI 2',
      jurusan: 'TEI',
      waliKelas: 'Bu Siti',
      loginWali: 'tei2 / tei23',
      jumlahSiswa: 5,
      aksi: 'Lihat',
    ),
    Kelas(
      id: '3',
      namaKelas: 'XI TEI 1',
      jurusan: 'TEI',
      waliKelas: 'Pak Budi',
      loginWali: 'tei3 / tei23',
      jumlahSiswa: 0,
      aksi: 'Lihat',
    ),
    Kelas(
      id: '4',
      namaKelas: 'XI TEI 2',
      jurusan: 'TEI',
      waliKelas: 'Bu Ani',
      loginWali: 'tei4 / tei23',
      jumlahSiswa: 0,
      aksi: 'Lihat',
    ),
    Kelas(
      id: '5',
      namaKelas: 'XII TEI',
      jurusan: 'TEI',
      waliKelas: 'Pak Joko',
      loginWali: 'tei5 / tei23',
      jumlahSiswa: 0,
      aksi: 'Lihat',
    ),
    Kelas(
      id: '6',
      namaKelas: 'X TKR 1',
      jurusan: 'TKR',
      waliKelas: 'Pak Hendra',
      loginWali: 'tkr1 / tkr23',
      jumlahSiswa: 5,
      aksi: 'Lihat',
    ),
    Kelas(
      id: '7',
      namaKelas: 'X TKR 2',
      jurusan: 'TKR',
      waliKelas: 'Bu Dewi',
      loginWali: 'tkr2 / tkr23',
      jumlahSiswa: 0,
      aksi: 'Lihat',
    ),
    Kelas(
      id: '8',
      namaKelas: 'XI TKR 1',
      jurusan: 'TKR',
      waliKelas: 'Pak Rudi',
      loginWali: 'tkr3 / tkr23',
      jumlahSiswa: 0,
      aksi: 'Lihat',
    ),
    Kelas(
      id: '9',
      namaKelas: 'XI TKR 2',
      jurusan: 'TKR',
      waliKelas: 'Bu Maya',
      loginWali: 'tkr4 / tkr23',
      jumlahSiswa: 0,
      aksi: 'Lihat',
    ),
    Kelas(
      id: '10',
      namaKelas: 'XII TKR',
      jurusan: 'TKR',
      waliKelas: 'Pak Eko',
      loginWali: 'tkr5 / tkr23',
      jumlahSiswa: 0,
      aksi: 'Lihat',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                      'Kelola Kelas',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Daftar Semua Kelas',
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
                      builder: (context) => AddKelasDialog(
                        onSave: (data) {
                          setState(() {
                            daftarKelas.add(
                              Kelas(
                                id: (daftarKelas.length + 1).toString(),
                                namaKelas: data['namaKelas'] as String,
                                jurusan: data['jurusan'] as String,
                                waliKelas: data['waliKelas'] as String,
                                loginWali: '${(data['namaKelas'] as String).toLowerCase()} / ${(data['namaKelas'] as String).toLowerCase()}23',
                                jumlahSiswa: 0,
                                aksi: 'Lihat',
                              ),
                            );
                          });
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Kelas ${data['namaKelas']} berhasil ditambahkan'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Kelas'),
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

            // Daftar Kelas Table
            Container(
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  dataRowHeight: 56,
                  headingRowColor: MaterialStateProperty.all(
                    const Color(0xFFF5F5F5),
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'KELAS',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'JURUSAN',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'WALI KELAS',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'LOGIN WALI',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'SISWA',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'AKSI',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                  rows: daftarKelas.asMap().entries.map((entry) {
                    int idx = entry.key;
                    Kelas kelas = entry.value;
                    return DataRow(
                      color: MaterialStateProperty.all(
                        idx.isEven ? Colors.transparent : const Color(0xFFFAFAFA),
                      ),
                      cells: [
                        DataCell(
                          Text(
                            kelas.namaKelas,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              kelas.jurusan,
                              style: const TextStyle(
                                color: Color(0xFF2196F3),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(kelas.waliKelas)),
                        DataCell(
                          Text(
                            kelas.loginWali,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${kelas.jumlahSiswa}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                PopupMenuButton<String>(
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry<String>>[
                                    const PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 18),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'detail',
                                      child: Row(
                                        children: [
                                          Icon(Icons.visibility, size: 18),
                                          SizedBox(width: 8),
                                          Text('Detail'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, size: 18),
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
                                        builder: (context) => AddKelasDialog(
                                          initialData: {
                                            'namaKelas': kelas.namaKelas,
                                            'jurusan': kelas.jurusan,
                                            'waliKelas': kelas.waliKelas,
                                          },
                                          onSave: (data) {
                                            setState(() {
                                              kelas.namaKelas = data['namaKelas'] as String;
                                              kelas.jurusan = data['jurusan'] as String;
                                              kelas.waliKelas = data['waliKelas'] as String;
                                            });
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Kelas berhasil diperbarui',
                                                  ),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      );
                                    } else if (value == 'detail') {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Detail kelas ${kelas.namaKelas}',
                                          ),
                                        ),
                                      );
                                    } else if (value == 'delete') {
                                      showDialog(
                                        context: context,
                                        builder: (context) => ConfirmDialog(
                                          title: 'Hapus Kelas',
                                          message:
                                              'Apakah Anda yakin ingin menghapus kelas ${kelas.namaKelas}?',
                                          onConfirm: () {
                                            setState(() {
                                              daftarKelas.removeWhere((k) =>
                                                  k.id == kelas.id);
                                            });
                                            Navigator.pop(context);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Kelas ${kelas.namaKelas} berhasil dihapus',
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
                                  child: const Icon(Icons.more_vert, size: 18),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
