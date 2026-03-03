import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projectone/services/attendance_recap_service.dart';
import 'package:projectone/models/attendance_recap_model.dart';

class AttendanceRecapPage extends StatefulWidget {
  const AttendanceRecapPage({super.key});

  @override
  State<AttendanceRecapPage> createState() => _AttendanceRecapPageState();
}

class _AttendanceRecapPageState extends State<AttendanceRecapPage> {
  late int selectedMonth = DateTime.now().month;
  late int selectedYear = DateTime.now().year;
  AttendanceRecap? recap;
  List<AttendanceRecord> records = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final recapData = await AttendanceRecapService.getAttendanceRecap(
        bulan: selectedMonth,
        tahun: selectedYear,
      );

      final recordsData = await AttendanceRecapService.getAttendanceRecords(
        bulan: selectedMonth,
        tahun: selectedYear,
      );

      if (mounted) {
        setState(() {
          recap = recapData;
          records = recordsData;
        });
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('Gagal memuat data: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Rekap Absensi'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month & Year Picker
              _buildMonthYearSelector(),
              const SizedBox(height: 20),

              // Summary Cards
              if (recap != null) ...[
                _buildSummaryCards(),
                const SizedBox(height: 20),
              ],

              // Attendance Records
              _buildAttendanceRecords(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthYearSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Bulan & Tahun',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _loadData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Icon(Icons.search),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthDropdown() {
    final months = [
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
        if (value != null && mounted) {
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
        if (value != null && mounted) {
          setState(() => selectedYear = value);
        }
      },
    );
  }

  Widget _buildSummaryCards() {
    final bulanString = _getBulanString(selectedMonth);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rekap Presensi - $bulanString $selectedYear',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Total Hari: ${recap!.totalHari} | Persentase Hadir: ${recap!.persentaseHadir.toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildRecapCard(
              'Hadir',
              recap!.hadir.toString(),
              Colors.green,
            ),
            _buildRecapCard(
              'Terlambat',
              recap!.terlambat.toString(),
              Colors.orange,
            ),
            _buildRecapCard(
              'Sakit',
              recap!.sakit.toString(),
              Colors.blue,
            ),
            _buildRecapCard(
              'Izin',
              recap!.izin.toString(),
              Colors.purple,
            ),
            _buildRecapCard(
              'Tidak Hadir',
              recap!.absent.toString(),
              Colors.red,
            ),
            _buildRecapCard(
              'Total',
              recap!.totalHari.toString(),
              Colors.grey,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecapCard(String label, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceRecords() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              Icon(
                Icons.inbox,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Tidak ada data presensi',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detail Presensi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return _buildAttendanceCard(record);
          },
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(AttendanceRecord record) {
    Color statusColor;
    IconData statusIcon;

    switch (record.status) {
      case 'present':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'late':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case 'absent':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'sick':
        statusColor = Colors.blue;
        statusIcon = Icons.local_hospital;
        break;
      case 'permission':
        statusColor = Colors.purple;
        statusIcon = Icons.assignment;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text(
          record.tanggal,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            if (record.checkInTime != null)
              Text(
                'Masuk: ${DateFormat('HH:mm').format(record.checkInTime!)}',
                style: const TextStyle(fontSize: 12),
              ),
            if (record.checkOutTime != null) ...[
              const Text(' | ', style: TextStyle(fontSize: 12)),
              Text(
                'Keluar: ${DateFormat('HH:mm').format(record.checkOutTime!)}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            record.statusLabel,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  String _getBulanString(int bulan) {
    const bulanList = [
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
    return bulan > 0 && bulan <= 12 ? bulanList[bulan - 1] : '';
  }
}
