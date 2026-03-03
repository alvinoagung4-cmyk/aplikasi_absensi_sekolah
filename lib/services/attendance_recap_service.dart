import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projectone/models/attendance_recap_model.dart';
import 'package:projectone/services/api_service.dart';

class AttendanceRecapService {

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Ambil Recap Presensi (Ringkasan)
  static Future<AttendanceRecap?> getAttendanceRecap({
    required int bulan,
    required int tahun,
    int? studentId,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      String url = '${ApiService.baseUrl}/attendance/recap?bulan=$bulan&tahun=$tahun';
      if (studentId != null) url += '&student_id=$studentId';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AttendanceRecap.fromJson(data['recap']);
      } else {
        throw Exception('Gagal mengambil recap: ${response.body}');
      }
    } catch (e) {
      print('Error fetching attendance recap: $e');
      return null;
    }
  }

  // Ambil Records Presensi Detail
  static Future<List<AttendanceRecord>> getAttendanceRecords({
    int? bulan,
    int? tahun,
    int? studentId,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      String url = '${ApiService.baseUrl}/attendance/records';
      final params = [];

      if (bulan != null) params.add('bulan=$bulan');
      if (tahun != null) params.add('tahun=$tahun');
      if (studentId != null) params.add('student_id=$studentId');

      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final records = (data['records'] as List)
            .map((r) => AttendanceRecord.fromJson(r))
            .toList();
        return records;
      } else {
        throw Exception('Gagal mengambil records: ${response.body}');
      }
    } catch (e) {
      print('Error fetching attendance records: $e');
      return [];
    }
  }

  // Generate PDF Report (untuk print)
  static Future<String?> generatePdfReport({
    required int bulan,
    required int tahun,
    int? studentId,
  }) async {
    try {
      // Ambil data terlebih dahulu
      final records = await getAttendanceRecords(
        bulan: bulan,
        tahun: tahun,
        studentId: studentId,
      );

      final recap = await getAttendanceRecap(
        bulan: bulan,
        tahun: tahun,
        studentId: studentId,
      );

      if (records.isEmpty || recap == null) {
        throw Exception('Data tidak lengkap untuk generate PDF');
      }

      // Generate HTML untuk PDF
      final htmlContent = _generateHtmlReport(records, recap, bulan, tahun);
      return htmlContent;
    } catch (e) {
      print('Error generating PDF report: $e');
      return null;
    }
  }

  // Generate HTML Report Content
  static String _generateHtmlReport(
    List<AttendanceRecord> records,
    AttendanceRecap recap,
    int bulan,
    int tahun,
  ) {
    final bulanString = _getBulanString(bulan);
    
    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <title>Laporan Presensi - $bulanString $tahun</title>
      <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { text-align: center; margin-bottom: 30px; }
        .header h1 { margin: 0; color: #2196F3; }
        .header p { margin: 5px 0; color: #666; }
        .summary { 
          background: #f5f5f5; 
          padding: 15px; 
          border-radius: 5px; 
          margin-bottom: 20px;
        }
        .summary-item { 
          display: inline-block; 
          margin-right: 20px; 
          min-width: 150px;
        }
        .summary-item strong { color: #2196F3; }
        .summary-item .value { font-size: 24px; font-weight: bold; }
        table { 
          width: 100%; 
          border-collapse: collapse; 
          margin-top: 20px;
        }
        th, td { 
          border: 1px solid #ddd; 
          padding: 10px; 
          text-align: left;
        }
        th { background: #2196F3; color: white; }
        tr:nth-child(even) { background: #f9f9f9; }
        .status-hadir { color: #4CAF50; font-weight: bold; }
        .status-terlambat { color: #FF9800; font-weight: bold; }
        .status-absent { color: #f44336; font-weight: bold; }
        .status-sakit { color: #2196F3; font-weight: bold; }
        .status-izin { color: #9C27B0; font-weight: bold; }
        .footer { 
          margin-top: 30px; 
          text-align: right; 
          color: #999;
          font-size: 12px;
        }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>📋 Laporan Presensi Sekolah</h1>
        <p><strong>Bulan:</strong> $bulanString $tahun</p>
      </div>

      <div class="summary">
        <div class="summary-item">
          <strong>Hadir:</strong>
          <div class="value" style="color: #4CAF50;">${recap.hadir}</div>
        </div>
        <div class="summary-item">
          <strong>Terlambat:</strong>
          <div class="value" style="color: #FF9800;">${recap.terlambat}</div>
        </div>
        <div class="summary-item">
          <strong>Sakit:</strong>
          <div class="value" style="color: #2196F3;">${recap.sakit}</div>
        </div>
        <div class="summary-item">
          <strong>Izin:</strong>
          <div class="value" style="color: #9C27B0;">${recap.izin}</div>
        </div>
        <div class="summary-item">
          <strong>Tidak Hadir:</strong>
          <div class="value" style="color: #f44336;">${recap.absent}</div>
        </div>
      </div>

      <table>
        <thead>
          <tr>
            <th>No.</th>
            <th>Tanggal</th>
            <th>Masuk</th>
            <th>Keluar</th>
            <th>Status</th>
            <th>Keterangan</th>
          </tr>
        </thead>
        <tbody>
          ${_generateTableRows(records)}
        </tbody>
      </table>

      <div class="footer">
        <p>Laporan ini digenerate secara otomatis oleh Sistem Presensi Sekolah</p>
        <p>Dicetak pada: ${DateTime.now().toString()}</p>
      </div>
    </body>
    </html>
    ''';
  }

  static String _generateTableRows(List<AttendanceRecord> records) {
    int no = 1;
    return records.map((record) {
      final checkIn = record.checkInTime?.toString().split(' ')[1] ?? '-';
      final checkOut = record.checkOutTime?.toString().split(' ')[1] ?? '-';
      
      return '''
      <tr>
        <td>$no</td>
        <td>${record.tanggal}</td>
        <td>$checkIn</td>
        <td>$checkOut</td>
        <td><span class="status-${record.status}">${record.statusLabel}</span></td>
        <td>${record.notes ?? '-'}</td>
      </tr>
      ''';
    }).join('');
  }

  static String _getBulanString(int bulan) {
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
