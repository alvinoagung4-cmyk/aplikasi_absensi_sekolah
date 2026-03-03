import 'package:flutter/material.dart';
import 'package:projectone/models/admin_model.dart';

class AdminRekapAbsensiPage extends StatefulWidget {
  const AdminRekapAbsensiPage({super.key});

  @override
  State<AdminRekapAbsensiPage> createState() => _AdminRekapAbsensiPageState();
}

class _AdminRekapAbsensiPageState extends State<AdminRekapAbsensiPage> {
  final List<StatistikAbsensi> statistikAbsensi = [
    StatistikAbsensi(
      kelas: 'X TEI 1',
      hadir: 5,
      izin: 0,
      sakit: 0,
      alpha: 0,
    ),
    StatistikAbsensi(
      kelas: 'X TEI 2',
      hadir: 5,
      izin: 0,
      sakit: 0,
      alpha: 0,
    ),
    StatistikAbsensi(
      kelas: 'XI TEI 1',
      hadir: 0,
      izin: 0,
      sakit: 0,
      alpha: 0,
    ),
    StatistikAbsensi(
      kelas: 'XI TEI 2',
      hadir: 0,
      izin: 0,
      sakit: 0,
      alpha: 0,
    ),
    StatistikAbsensi(
      kelas: 'XII TEI',
      hadir: 0,
      izin: 0,
      sakit: 0,
      alpha: 0,
    ),
    StatistikAbsensi(
      kelas: 'X TKR 1',
      hadir: 5,
      izin: 0,
      sakit: 0,
      alpha: 0,
    ),
    StatistikAbsensi(
      kelas: 'X TKR 2',
      hadir: 0,
      izin: 0,
      sakit: 0,
      alpha: 0,
    ),
    StatistikAbsensi(
      kelas: 'XI TKR 1',
      hadir: 0,
      izin: 0,
      sakit: 0,
      alpha: 0,
    ),
    StatistikAbsensi(
      kelas: 'XI TKR 2',
      hadir: 0,
      izin: 0,
      sakit: 0,
      alpha: 0,
    ),
    StatistikAbsensi(
      kelas: 'XII TKR',
      hadir: 0,
      izin: 0,
      sakit: 0,
      alpha: 0,
    ),
    StatistikAbsensi(
      kelas: 'X TBSM',
      hadir: 0,
      izin: 0,
      sakit: 0,
      alpha: 0,
    ),
    StatistikAbsensi(
      kelas: 'XI TBSM',
      hadir: 0,
      izin: 0,
      sakit: 0,
      alpha: 0,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rekap Absensi Semua Kelas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sabtu, 3 Januari 2026',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Statistics Cards
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatCard(
                    icon: Icons.check_circle,
                    label: 'Hadir',
                    value: '25',
                    color: const Color(0xFF4CAF50),
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    icon: Icons.assignment,
                    label: 'Izin',
                    value: '0',
                    color: const Color(0xFFFFC107),
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    icon: Icons.local_hospital,
                    label: 'Sakit',
                    value: '0',
                    color: const Color(0xFF2196F3),
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    icon: Icons.cancel,
                    label: 'Alpha',
                    value: '0',
                    color: const Color(0xFFF44336),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Rekap Absensi Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: statistikAbsensi.length,
              itemBuilder: (context, index) {
                final stats = statistikAbsensi[index];
                return _buildAbsensiCard(stats);
              },
            ),
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

  Widget _buildAbsensiCard(StatistikAbsensi stats) {
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
          // Class Name
          Text(
            stats.kelas,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Attendance Stats
          _buildAbsensiRow(
            icon: Icons.check_circle,
            label: 'Hadir',
            count: stats.hadir,
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 8),
          _buildAbsensiRow(
            icon: Icons.assignment,
            label: 'Izin',
            count: stats.izin,
            color: const Color(0xFFFFC107),
          ),
          const SizedBox(height: 8),
          _buildAbsensiRow(
            icon: Icons.local_hospital,
            label: 'Sakit',
            count: stats.sakit,
            color: const Color(0xFF2196F3),
          ),
          const SizedBox(height: 8),
          _buildAbsensiRow(
            icon: Icons.cancel,
            label: 'Alpha',
            count: stats.alpha,
            color: const Color(0xFFF44336),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsensiRow({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
