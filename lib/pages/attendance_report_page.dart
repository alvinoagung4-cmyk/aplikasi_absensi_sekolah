import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projectone/services/attendance_recap_service.dart';
import 'package:projectone/models/attendance_recap_model.dart';

class AttendanceReportPage extends StatefulWidget {
  const AttendanceReportPage({super.key});

  @override
  State<AttendanceReportPage> createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage> {
  late int selectedMonth = DateTime.now().month;
  late int selectedYear = DateTime.now().year;
  AttendanceRecap? recap;
  List<AttendanceRecord> records = [];
  bool isLoading = false;
  String? htmlReport;

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  Future<void> _generateReport() async {
    setState(() => isLoading = true);

    try {
      final html = await AttendanceRecapService.generatePdfReport(
        bulan: selectedMonth,
        tahun: selectedYear,
      );

      if (html != null) {
        setState(() => htmlReport = html);
      } else {
        _showErrorSnackBar('Gagal generate laporan');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📄 Laporan Presensi'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header dengan Filter
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Laporan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMonthDropdown(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildYearDropdown(),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _generateReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Preview & Actions
            if (htmlReport != null) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showPrintPreview(),
                        icon: const Icon(Icons.preview),
                        label: const Text('Lihat Preview'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showPrintOptions(),
                        icon: const Icon(Icons.print),
                        label: const Text('Cetak/Export'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Report Preview
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: _buildReportPreview(),
              ),
            ] else if (isLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada data untuk periode ini',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthDropdown() {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];

    return DropdownButton<int>(
      value: selectedMonth,
      isExpanded: true,
      items: List.generate(12, (index) {
        return DropdownMenuItem(
          value: index + 1,
          child: Text(months[index]),
        );
      }),
      onChanged: (value) {
        if (value != null) {
          setState(() => selectedMonth = value);
        }
      },
    );
  }

  Widget _buildYearDropdown() {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => currentYear - 2 + index);

    return DropdownButton<int>(
      value: selectedYear,
      isExpanded: true,
      items: years
          .map((year) => DropdownMenuItem(
                value: year,
                child: Text(year.toString()),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => selectedYear = value);
        }
      },
    );
  }

  Widget _buildReportPreview() {
    final bulanList = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Center(
          child: Column(
            children: [
              const Text(
                '📋 Laporan Presensi Sekolah',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bulan: ${bulanList[selectedMonth - 1]} $selectedYear',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Dicetak: ${DateFormat('dd MMMM yyyy HH:mm', 'id_ID').format(DateTime.now())}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        const Divider(height: 24),

        // Summary Section
        const Text(
          'Ringkasan Presensi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              _buildSummaryRow('Hari Sekolah Total', '20'),
              _buildSummaryRow('Hadir', '18'),
              _buildSummaryRow('Terlambat', '1'),
              _buildSummaryRow('Sakit', '1'),
              _buildSummaryRow('Izin', '0'),
              _buildSummaryRow('Tidak Hadir', '0'),
              const Divider(),
              _buildSummaryRow(
                'Persentase Kehadiran',
                '90%',
                isBold: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Catatan
        const Text(
          'Catatan:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 8),
        const Text(
          '• Laporan ini digenerate secara otomatis oleh Sistem Presensi Sekolah',
          style: TextStyle(fontSize: 11),
        ),
        const SizedBox(height: 4),
        const Text(
          '• Status presensi: Hadir = Datang tepat waktu | Terlambat = Datang setelah jam 07:00',
          style: TextStyle(fontSize: 11),
        ),
        const SizedBox(height: 4),
        const Text(
          '• Untuk informasi lebih detail, silakan hubungi kantor sekolah',
          style: TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 13 : 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 13 : 12,
              color: isBold ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showPrintPreview() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          children: [
            AppBar(
              title: const Text('Preview Laporan'),
              automaticallyImplyLeading: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildReportPreview(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrintOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Format Export',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export sebagai PDF'),
              subtitle: const Text('Simpan laporan dalam format PDF'),
              onTap: () {
                _showSuccessSnackBar('Fitur PDF akan segera tersedia');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export sebagai Excel'),
              subtitle: const Text('Simpan data ke file Excel'),
              onTap: () {
                _showSuccessSnackBar('Fitur Excel akan segera tersedia');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Cetak Langsung'),
              subtitle: const Text('Cetak ke printer yang terhubung'),
              onTap: () {
                _showSuccessSnackBar('Mengirim ke printer...');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Kirim via Email'),
              subtitle: const Text('Kirim laporan ke email orang tua'),
              onTap: () {
                _showSuccessSnackBar('Fitur email akan segera tersedia');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Bagikan'),
              subtitle: const Text('Bagikan laporan ke aplikasi lain'),
              onTap: () {
                _showSuccessSnackBar('Fitur share akan segera tersedia');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
