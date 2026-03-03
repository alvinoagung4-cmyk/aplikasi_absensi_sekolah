import 'package:flutter/material.dart';
import 'package:projectone/services/auth_service.dart';
import 'package:projectone/services/api_service.dart';
import 'package:projectone/pages/login_page.dart';
import 'package:projectone/pages/settings_page.dart';
import 'package:projectone/pages/face_scan_page.dart';
import 'package:projectone/pages/qr_scan_page.dart';
import 'package:projectone/pages/attendance_history_page.dart';
import 'package:projectone/pages/attendance_recap_page.dart';
import 'package:projectone/pages/activity_journal_page.dart';
import 'package:projectone/pages/attendance_report_page.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? currentUser;
  bool _isCheckedIn = false;
  DateTime? _checkInTime;
  DateTime? _checkOutTime;
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _attendanceHistory = [];
  bool _isLoading = true;

  DateTime _parseToLocal(String dateTimeStr) {
    return DateTime.parse(dateTimeStr).toLocal();
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTodayAttendance();
    _loadAttendanceHistory();
  }

  Future<void> _loadUserData() async {
    try {
      // Get user data dari AuthService (cache)
      var user = AuthService.getUserData();
      
      // Jika tidak ada cache, fetch dari API
      if (user == null) {
        user = await AuthService.getCurrentUser();
      }
      
      if (mounted) {
        setState(() {
          currentUser = user ?? {
            'nama_lengkap': 'User',
            'email': 'email@example.com',
            'no_hp': '081000000000'
          };
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          currentUser = {
            'nama_lengkap': 'User',
            'email': 'email@example.com',
            'no_hp': '081000000000'
          };
        });
      }
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadTodayAttendance() async {
    try {
      final result = await ApiService.getTodayAttendance();
      if (result['success'] && result['data'] != null) {
        final data = result['data'];
        if (mounted) {
          setState(() {
            if (data['check_in_time'] != null) {
              _checkInTime = _parseToLocal(data['check_in_time']);
              _isCheckedIn = true;
            }
            if (data['check_out_time'] != null) {
              _checkOutTime = _parseToLocal(data['check_out_time']);
            } 
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error loading today attendance: $e');
    }
  }

  Future<void> _loadAttendanceHistory() async {
    try {
      final result = await ApiService.getAttendanceHistory();
      if (result['success'] && result['data'] != null) {
        if (mounted) {
          setState(() {
            _attendanceHistory = List<Map<String, dynamic>>.from(result['data']);
          });
        }
      }
    } catch (e) {
      print('Error loading attendance history: $e');
    }
  }

  void _handleCheckIn() async {
    try {
      final result = await ApiService.checkIn(location: 'Kantor');
      
      if (result['success']) {
        setState(() {
          _isCheckedIn = true;
          _checkInTime = DateTime.now();
          _checkOutTime = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Check-in berhasil pada ${DateFormat('HH:mm:ss').format(_checkInTime!)}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Check-in gagal'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
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

  void _handleCheckOut() async {
    try {
      final result = await ApiService.checkOut();
      
      if (result['success']) {
        setState(() {
          _checkOutTime = DateTime.now();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Check-out berhasil pada ${DateFormat('HH:mm:ss').format(_checkOutTime!)}',
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Reload attendance history
        _loadAttendanceHistory();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Check-out gagal'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
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

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              AuthService.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Aplikasi Presensi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            tooltip: 'Settings',
            iconSize: 22,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _handleLogout,
            tooltip: 'Logout',
            iconSize: 22,
          ),
        ],
      ),
      body: _buildPageByIndex(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.grey[400],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Recap',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Jurnal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.print),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }

  Widget _buildPageByIndex() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return const AttendanceRecapPage();
      case 2:
        return const ActivityJournalPage();
      case 3:
        return const AttendanceReportPage();
      case 4:
        return _buildHistoryPage();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Card with Gradient
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2196F3).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser?['nama_lengkap'] ?? 'User',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentUser?['email'] ?? 'email@example.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentUser?['no_hp'] ?? '081000000000',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Time Card with Clock
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy').format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF424242),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 1)),
                    builder: (context, snapshot) {
                      final now = DateTime.now();
                      final timeString = DateFormat('HH:mm:ss').format(now);
                      return Text(
                        timeString,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3),
                          letterSpacing: 2,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.schedule,
                    color: Color(0xFF2196F3),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Check In / Check Out Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (_checkInTime != null)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF4CAF50),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF4CAF50),
                            size: 24,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Check-in Masuk',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF558B2F),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('HH:mm:ss').format(_checkInTime!),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Text(
                      'Belum check-in',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (_checkOutTime != null)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF2196F3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.exit_to_app,
                            color: Color(0xFF1976D2),
                            size: 24,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Check-out Pulang',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF1565C0),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('HH:mm:ss').format(_checkOutTime!),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1565C0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_isCheckedIn)
                    Text(
                      'Belum check-out',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Buttons
          if (!_isCheckedIn)
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _handleCheckIn,
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.check_circle, color: Colors.white, size: 24),
                        SizedBox(width: 10),
                        Text(
                          'Check-in',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else if (_checkOutTime == null)
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2196F3).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _handleCheckOut,
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.exit_to_app, color: Colors.white, size: 24),
                        SizedBox(width: 10),
                        Text(
                          'Check-out',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Alternative Check-in/out Methods Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.blue.shade200,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.verified_user,
                      color: Colors.blue.shade600,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Metode Presensi Lanjutan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Face Recognition Section
                Text(
                  'Scan Wajah',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const FaceScanAttendancePage(
                                  attendanceType: 'check_in',
                                ),
                              ),
                            ).then((_) => _loadTodayAttendance());
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green.shade300,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.face,
                                  color: Colors.green.shade700,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Masuk',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const FaceScanAttendancePage(
                                  attendanceType: 'check_out',
                                ),
                              ),
                            ).then((_) => _loadTodayAttendance());
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.shade300,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.face,
                                  color: Colors.orange.shade700,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Pulang',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // QR Code Section
                Text(
                  'Scan QR Code',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const QRScanAttendancePage(
                                  attendanceType: 'check_in',
                                ),
                              ),
                            ).then((_) => _loadTodayAttendance());
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.purple.shade300,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.qr_code_2,
                                  color: Colors.purple.shade700,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Masuk',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const QRScanAttendancePage(
                                  attendanceType: 'check_out',
                                ),
                              ),
                            ).then((_) => _loadTodayAttendance());
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.shade300,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.qr_code_2,
                                  color: Colors.red.shade700,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Pulang',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // View History Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AttendanceHistoryPage(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.blue.shade300,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.history, color: Color(0xFF2196F3)),
                    const SizedBox(width: 10),
                    const Text(
                      'Lihat Riwayat Lengkap',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2196F3),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Riwayat Presensi',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F1F1F),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 20),
          if (_attendanceHistory.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 80,
                      color: Colors.grey[200],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Belum ada riwayat presensi',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lakukan check-in terlebih dahulu',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _attendanceHistory.length,
              itemBuilder: (context, index) {
                final attendance = _attendanceHistory[index];
                final checkInTime = _parseToLocal(attendance['check_in_time']);
                final checkOutTime = attendance['check_out_time'] != null
                ? _parseToLocal(attendance['check_out_time'])
                : null;


                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy').format(checkInTime),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F1F1F),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '✓ Masuk',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Check-in info
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.login,
                                color: Color(0xFF2E7D32),
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Waktu Datang',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF558B2F),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('HH:mm:ss').format(checkInTime),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Check-out info
                        if (checkOutTime != null)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.logout,
                                  color: Color(0xFF1565C0),
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Waktu Pulang',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF1565C0),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('HH:mm:ss').format(checkOutTime),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1565C0),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        if (checkOutTime != null) const SizedBox(height: 12),
                        // Duration info
                        if (checkOutTime != null)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E5F5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.schedule,
                                      color: Color(0xFF6A1B9A),
                                      size: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Durasi Kerja',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6A1B9A),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${checkOutTime.difference(checkInTime).inHours}h ${checkOutTime.difference(checkInTime).inMinutes % 60}m',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF6A1B9A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Color(0xFFEF5350)),
                                  onPressed: () => _deleteAttendance(attendance['id']),
                                  tooltip: 'Hapus',
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _deleteAttendance(int attendanceId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Riwayat'),
        content: const Text('Apakah Anda yakin ingin menghapus riwayat presensi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final result = await ApiService.deleteAttendance(attendanceId);
                if (result['success']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Riwayat berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadAttendanceHistory();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'] ?? 'Gagal menghapus'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
