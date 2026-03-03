import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projectone/models/admin_model.dart';
import 'package:projectone/pages/admin_kelola_kelas_page.dart';
import 'package:projectone/pages/admin_kelola_siswa_page.dart';
import 'package:projectone/pages/admin_rekap_absensi_page.dart';
import 'package:projectone/pages/admin_pengaturan_page.dart';
import 'package:projectone/widgets/admin_widgets.dart';
import 'package:projectone/pages/login_page_new.dart';
import 'package:projectone/services/auth_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  // Data dummy untuk demonstrasi
  final DashboardStats stats = DashboardStats(
    totalSiswa: 25,
    hadir: 20,
    izin: 0,
    sakit: 0,
    alpha: 5,
  );

  final List<RingkasanJurusan> ringkasanJurusan = [
    RingkasanJurusan(
      namaJurusan: 'TEI',
      jumlahKelas: 5,
      jumlahSiswa: 10,
    ),
    RingkasanJurusan(
      namaJurusan: 'TKR',
      jumlahKelas: 5,
      jumlahSiswa: 5,
    ),
    RingkasanJurusan(
      namaJurusan: 'TBSM',
      jumlahKelas: 2,
      jumlahSiswa: 0,
    ),
    RingkasanJurusan(
      namaJurusan: 'RPL',
      jumlahKelas: 4,
      jumlahSiswa: 5,
    ),
    RingkasanJurusan(
      namaJurusan: 'TKJ',
      jumlahKelas: 4,
      jumlahSiswa: 5,
    ),
  ];

  final List<Kelas> daftarKelas = [
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
  ];

  int _selectedMenu = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AdminAppBar(
        title: 'Admin Panel',
        onLogout: () async {
          await AuthService.logout();
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPageNew()),
              (route) => false,
            );
          }
        },
      ),
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            selectedIndex: _selectedMenu,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedMenu = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.school),
                label: Text('Kelola Kelas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Kelola Siswa'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assignment),
                label: Text('Recap Absensi'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Pengaturan'),
              ),
            ],
          ),
          // Main Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedMenu) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildKelolaKelas();
      case 2:
        return _buildKelolaSiswa();
      case 3:
        return _buildRekapAbsensi();
      case 4:
        return _buildPengaturan();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
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
                      'Dashboard Admin',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sabtu, ${DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.now())}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Statistics Cards
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatCard(
                    icon: Icons.people,
                    label: 'Total Siswa',
                    value: '${stats.totalSiswa}',
                    color: const Color(0xFF4CAF50),
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    icon: Icons.check_circle,
                    label: 'Hadir',
                    value: '${stats.hadir}',
                    color: const Color(0xFF4CAF50),
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    icon: Icons.assignment,
                    label: 'Izin',
                    value: '${stats.izin}',
                    color: const Color(0xFFFFC107),
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    icon: Icons.local_hospital,
                    label: 'Sakit',
                    value: '${stats.sakit}',
                    color: const Color(0xFF2196F3),
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    icon: Icons.cancel,
                    label: 'Alpha',
                    value: '${stats.alpha}',
                    color: const Color(0xFFF44336),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Ringkasan Per Jurusan
            const Text(
              'Ringkasan Per Jurusan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ringkasanJurusan.map((jurusan) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jurusan.namaJurusan,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${jurusan.jumlahKelas} Kelas',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${jurusan.jumlahSiswa} Siswa',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),

            // Daftar Kelas
            const Text(
              'Daftar Kelas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildKelasList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2196F3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKelasList() {
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 24,
          columns: const [
            DataColumn(label: Text('KELAS')),
            DataColumn(label: Text('JURUSAN')),
            DataColumn(label: Text('WALI KELAS')),
            DataColumn(label: Text('SISWA')),
            DataColumn(label: Text('LOGIN')),
            DataColumn(label: Text('AKSI')),
          ],
          rows: daftarKelas.map((kelas) {
            return DataRow(
              cells: [
                DataCell(Text(kelas.namaKelas)),
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
                DataCell(Text('${kelas.jumlahSiswa} siswa')),
                DataCell(Text(kelas.loginWali)),
                DataCell(
                  TextButton(
                    onPressed: () {},
                    child: const Text('Lihat'),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildKelolaKelas() {
    return const AdminKelolaKelasPage();
  }

  Widget _buildKelolaSiswa() {
    return const AdminKelolaSiswaPage();
  }

  Widget _buildRekapAbsensi() {
    return const AdminRekapAbsensiPage();
  }

  Widget _buildPengaturan() {
    return const AdminPengaturanPage();
  }
}
