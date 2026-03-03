import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projectone/models/activity_model.dart';
import 'package:projectone/services/api_service.dart';

class ActivityService {

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Buat Jurnal Kegiatan Baru
  static Future<ActivityJournal?> createActivityJournal({
    required String judulKegiatan,
    required String deskripsiKegiatan,
    String? mataPelajaran,
    String? lokasi,
    int? totalPeserta,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/activity-journal'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'judul_kegiatan': judulKegiatan,
          'deskripsi_kegiatan': deskripsiKegiatan,
          'mata_pelajaran': mataPelajaran,
          'lokasi': lokasi,
          'total_peserta': totalPeserta,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ActivityJournal.fromJson(data['activity']);
      } else {
        throw Exception('Gagal membuat jurnal: ${response.body}');
      }
    } catch (e) {
      print('Error creating activity journal: $e');
      return null;
    }
  }

  // Upload Foto Kegiatan
  static Future<ActivityPhoto?> uploadActivityPhoto({
    required int activityId,
    required String photoBase64,
    String? keterangan,
    int? photoOrder,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/activity-journal/$activityId/photos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'photo_base64': photoBase64,
          'keterangan': keterangan,
          'photo_order': photoOrder ?? 1,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ActivityPhoto.fromJson(data['photo']);
      } else {
        throw Exception('Gagal upload foto: ${response.body}');
      }
    } catch (e) {
      print('Error uploading photo: $e');
      return null;
    }
  }

  // Ambil Jurnal Kegiatan
  static Future<List<ActivityJournal>> getActivityJournals({
    int? bulan,
    int? tahun,
    int? studentId,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      String url = '${ApiService.baseUrl}/activity-journal';
      final QueryParameters = [];

      if (bulan != null) QueryParameters.add('bulan=$bulan');
      if (tahun != null) QueryParameters.add('tahun=$tahun');
      if (studentId != null) QueryParameters.add('student_id=$studentId');

      if (QueryParameters.isNotEmpty) {
        url += '?${QueryParameters.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final journals = (data['journals'] as List)
            .map((j) => ActivityJournal.fromJson(j))
            .toList();
        return journals;
      } else {
        throw Exception('Gagal mengambil jurnal: ${response.body}');
      }
    } catch (e) {
      print('Error fetching activity journals: $e');
      return [];
    }
  }

  // Submit Jurnal Kegiatan
  static Future<bool> submitActivityJournal(int activityId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/activity-journal/$activityId/submit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Gagal submit jurnal: ${response.body}');
      }
    } catch (e) {
      print('Error submitting activity journal: $e');
      return false;
    }
  }

  // Delete Activity Journal
  static Future<bool> deleteActivityJournal(int activityId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      // Note: API endpoint ini perlu ditambahkan di backend
      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/activity-journal/$activityId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Gagal hapus jurnal: ${response.body}');
      }
    } catch (e) {
      print('Error deleting activity journal: $e');
      return false;
    }
  }
}
