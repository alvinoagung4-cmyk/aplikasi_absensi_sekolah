class Attendance {
  final int? id;
  final int userId;
  final int? siswaId;
  final int? kelasId;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final DateTime date;
  final String status; // 'present', 'late', 'absent', 'sick', 'permit'
  final String? location;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final double? faceConfidence;
  final String? qrCode;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? namaSiswa;
  final String? namaKelas;

  // For compatibility with old code that uses timestamp
  DateTime get timestamp => checkInTime ?? date;

  Attendance({
    this.id,
    required this.userId,
    this.siswaId,
    this.kelasId,
    this.checkInTime,
    this.checkOutTime,
    required this.date,
    required this.status,
    this.location,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.faceConfidence,
    this.qrCode,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.namaSiswa,
    this.namaKelas,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'siswa_id': siswaId,
      'kelas_id': kelasId,
      'check_in_time': checkInTime?.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'date': date.toIso8601String(),
      'status': status,
      'location': location,
      'check_in_latitude': checkInLatitude,
      'check_in_longitude': checkInLongitude,
      'check_out_latitude': checkOutLatitude,
      'check_out_longitude': checkOutLongitude,
      'face_confidence': faceConfidence,
      'qr_code': qrCode,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'nama_siswa': namaSiswa,
      'nama_kelas': namaKelas,
    };
  }

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      userId: json['user_id'] ?? 0,
      siswaId: json['siswa_id'],
      kelasId: json['kelas_id'],
      checkInTime: json['check_in_time'] != null
          ? DateTime.parse(json['check_in_time'].toString())
          : null,
      checkOutTime: json['check_out_time'] != null
          ? DateTime.parse(json['check_out_time'].toString())
          : null,
      date: json['date'] != null
          ? DateTime.parse(json['date'].toString())
          : DateTime.now(),
      status: json['status'] ?? 'absent',
      location: json['location'],
      checkInLatitude: json['check_in_latitude'] != null
          ? double.parse(json['check_in_latitude'].toString())
          : null,
      checkInLongitude: json['check_in_longitude'] != null
          ? double.parse(json['check_in_longitude'].toString())
          : null,
      checkOutLatitude: json['check_out_latitude'] != null
          ? double.parse(json['check_out_latitude'].toString())
          : null,
      checkOutLongitude: json['check_out_longitude'] != null
          ? double.parse(json['check_out_longitude'].toString())
          : null,
      faceConfidence: json['face_confidence'] != null
          ? double.parse(json['face_confidence'].toString())
          : null,
      qrCode: json['qr_code'],
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
      namaSiswa: json['nama_siswa'],
      namaKelas: json['nama_kelas'],
    );
  }
}

class AttendanceStatistics {
  final int totalCheckIns;
  final int totalCheckOuts;
  final List<AttendanceDailySummary> dailySummaries;

  AttendanceStatistics({
    required this.totalCheckIns,
    required this.totalCheckOuts,
    required this.dailySummaries,
  });

  factory AttendanceStatistics.fromJson(Map<String, dynamic> json) {
    var dailyList = (json['daily_summaries'] as List?)
            ?.map((d) => AttendanceDailySummary.fromJson(d))
            .toList() ??
        [];
    return AttendanceStatistics(
      totalCheckIns: json['total_check_ins'] ?? 0,
      totalCheckOuts: json['total_check_outs'] ?? 0,
      dailySummaries: dailyList,
    );
  }
}

class AttendanceDailySummary {
  final DateTime date;
  final int checkIns;
  final int checkOuts;
  final String duration;

  AttendanceDailySummary({
    required this.date,
    required this.checkIns,
    required this.checkOuts,
    required this.duration,
  });

  factory AttendanceDailySummary.fromJson(Map<String, dynamic> json) {
    return AttendanceDailySummary(
      date: DateTime.parse(json['date']),
      checkIns: json['check_ins'] ?? 0,
      checkOuts: json['check_outs'] ?? 0,
      duration: json['duration'] ?? '0h 0m',
    );
  }
}
