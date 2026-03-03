import 'package:flutter/material.dart';
import 'package:projectone/models/attendance_model.dart';
import 'package:projectone/services/attendance_service.dart';
import 'package:projectone/services/auth_service.dart';
import 'package:intl/intl.dart';

class AttendanceHistoryPage extends StatefulWidget {
  const AttendanceHistoryPage({super.key});

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Attendance> _attendanceList = [];
  AttendanceStatistics? _statistics;

  bool _isLoading = true;
  String? _errorMessage;

  DateTime? _selectedDateStart;
  DateTime? _selectedDateEnd;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final userId = AuthService.getUserData()?['id'] ?? '';

      // Load attendance history
      final attendances = await AttendanceService.getAttendanceHistory(
        userId: userId,
        startDate: _selectedDateStart?.toIso8601String(),
        endDate: _selectedDateEnd?.toIso8601String(),
      );

      // Load statistics
      final stats = await AttendanceService.getAttendanceStatistics(
        userId: userId,
      );

      setState(() {
        _attendanceList = attendances;
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateStart != null && _selectedDateEnd != null
          ? DateTimeRange(start: _selectedDateStart!, end: _selectedDateEnd!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _selectedDateStart = picked.start;
        _selectedDateEnd = picked.end;
      });
      _loadAttendanceData();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDateStart = null;
      _selectedDateEnd = null;
    });
    _loadAttendanceData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Presensi'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : Column(
                  children: [
                    // Date filter
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.blue.shade50,
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _selectDateRange,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.date_range,
                                        size: 18, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _selectedDateStart != null
                                            ? '${DateFormat('dd/MM/yyyy').format(_selectedDateStart!)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateEnd!)}'
                                            : 'Pilih tanggal',
                                        style: TextStyle(
                                          color: _selectedDateStart != null
                                              ? Colors.black
                                              : Colors.grey,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (_selectedDateStart != null)
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: _clearDateFilter,
                              constraints: const BoxConstraints(
                                minHeight: 32,
                                minWidth: 32,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                        ],
                      ),
                    ),
                    // Tab bar
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Hari Ini'),
                        Tab(text: 'Riwayat'),
                        Tab(text: 'Statistik'),
                      ],
                    ),
                    // Tab content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTodayView(),
                          _buildHistoryView(),
                          _buildStatisticsView(),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(_errorMessage ?? 'Terjadi kesalahan'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAttendanceData,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayView() {
    final today = DateTime.now();
    final todayAttendance = _attendanceList
        .where((a) => a.timestamp.year == today.year &&
            a.timestamp.month == today.month &&
            a.timestamp.day == today.day)
        .toList();

    if (todayAttendance.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Belum ada presensi hari ini',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: todayAttendance.length,
      itemBuilder: (context, index) {
        final attendance = todayAttendance[index];
        return _buildAttendanceCard(attendance);
      },
    );
  }

  Widget _buildHistoryView() {
    if (_attendanceList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Tidak ada riwayat presensi',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    // Group by date
    final groupedByDate = <String, List<Attendance>>{};
    for (var attendance in _attendanceList) {
      final dateKey = DateFormat('dd MMMM yyyy', 'id_ID')
          .format(attendance.timestamp);
      groupedByDate.putIfAbsent(dateKey, () => []).add(attendance);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: groupedByDate.length,
      itemBuilder: (context, index) {
        final dateKey = groupedByDate.keys.toList()[index];
        final attendances = groupedByDate[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                dateKey,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.blue,
                ),
              ),
            ),
            ...attendances
                .map((attendance) => _buildAttendanceCard(attendance))
                .toList(),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildAttendanceCard(Attendance attendance) {
    // Determine card color based on status
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (attendance.status) {
      case 'present':
        statusColor = Colors.green;
        statusLabel = 'Hadir';
        statusIcon = Icons.check_circle;
        break;
      case 'late':
        statusColor = Colors.orange;
        statusLabel = 'Terlambat';
        statusIcon = Icons.schedule;
        break;
      case 'absent':
        statusColor = Colors.red;
        statusLabel = 'Absen';
        statusIcon = Icons.cancel;
        break;
      case 'sick':
        statusColor = Colors.purple;
        statusLabel = 'Sakit';
        statusIcon = Icons.local_hospital;
        break;
      case 'permit':
        statusColor = Colors.blue;
        statusLabel = 'Izin';
        statusIcon = Icons.description;
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = attendance.status;
        statusIcon = Icons.help;
    }

    final hasCheckOut = attendance.checkOutTime != null;
    final timeDisplay = _formatTimeRange(
      attendance.checkInTime,
      attendance.checkOutTime,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                statusIcon,
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeDisplay,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (attendance.location != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              attendance.location!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (attendance.notes != null && attendance.notes!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '📝 ${attendance.notes}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            if (hasCheckOut)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.check,
                  color: statusColor,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimeRange(DateTime? checkIn, DateTime? checkOut) {
    if (checkIn == null && checkOut == null) {
      return 'Waktu tidak tersedia';
    }

    final timeFormat = DateFormat('HH:mm');

    if (checkIn != null && checkOut != null) {
      return '${timeFormat.format(checkIn)} - ${timeFormat.format(checkOut)}';
    } else if (checkIn != null) {
      return 'Check-in: ${timeFormat.format(checkIn)}';
    } else if (checkOut != null) {
      return 'Check-out: ${timeFormat.format(checkOut)}';
    }

    return '';
  }

  Widget _buildStatisticsView() {
    if (_statistics == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Statistik tidak tersedia'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAttendanceData,
              child: const Text('Muat Ulang'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Total Check-In',
                  value: _statistics!.totalCheckIns.toString(),
                  icon: Icons.login,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Total Check-Out',
                  value: _statistics!.totalCheckOuts.toString(),
                  icon: Icons.logout,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Daily summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ringkasan Harian',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ..._statistics!.dailySummaries.map((summary) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, dd MMMM', 'id_ID')
                                  .format(summary.date),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Durasi: ${summary.duration}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${summary.checkIns}/${summary.checkOuts}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
