class AttendanceRecap {
  final int totalHari;
  final int hadir;
  final int absent;
  final int sakit;
  final int izin;
  final int terlambat;

  AttendanceRecap({
    required this.totalHari,
    required this.hadir,
    required this.absent,
    required this.sakit,
    required this.izin,
    required this.terlambat,
  });

  factory AttendanceRecap.fromJson(Map<String, dynamic> json) {
    return AttendanceRecap(
      totalHari: json['total_hari'] ?? 0,
      hadir: json['hadir'] ?? 0,
      absent: json['absent'] ?? 0,
      sakit: json['sakit'] ?? 0,
      izin: json['izin'] ?? 0,
      terlambat: json['terlambat'] ?? 0,
    );
  }

  double get persentaseHadir {
    if (totalHari == 0) return 0;
    return (hadir / totalHari) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'total_hari': totalHari,
      'hadir': hadir,
      'absent': absent,
      'sakit': sakit,
      'izin': izin,
      'terlambat': terlambat,
    };
  }
}

class AttendanceRecord {
  final int id;
  final int studentId;
  final int? classId;
  final String tanggal;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String status; // 'present', 'absent', 'sick', 'permission', 'late'
  final double? latitude;
  final double? longitude;
  final String? fotoCheckIn;
  final String? fotoCheckOut;
  final String? notes;
  final bool notificationSent;
  final DateTime createdAt;
  final DateTime updatedAt;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    this.classId,
    required this.tanggal,
    this.checkInTime,
    this.checkOutTime,
    this.status = 'present',
    this.latitude,
    this.longitude,
    this.fotoCheckIn,
    this.fotoCheckOut,
    this.notes,
    this.notificationSent = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      studentId: json['student_id'],
      classId: json['class_id'],
      tanggal: json['tanggal'],
      checkInTime: json['check_in_time'] != null 
          ? DateTime.parse(json['check_in_time'])
          : null,
      checkOutTime: json['check_out_time'] != null
          ? DateTime.parse(json['check_out_time'])
          : null,
      status: json['status'] ?? 'present',
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
      fotoCheckIn: json['foto_check_in'],
      fotoCheckOut: json['foto_check_out'],
      notes: json['notes'],
      notificationSent: json['notification_sent'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'class_id': classId,
      'tanggal': tanggal,
      'check_in_time': checkInTime?.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'foto_check_in': fotoCheckIn,
      'foto_check_out': fotoCheckOut,
      'notes': notes,
      'notification_sent': notificationSent,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Utility methods
  bool get isLate {
    if (checkInTime == null) return false;
    // Anggap jam masuk normal adalah 07:00
    final normalCheckInTime = TimeOfDay(hour: 7, minute: 0);
    final checkInTimeOfDay = TimeOfDay.fromDateTime(checkInTime!);
    return checkInTimeOfDay.hour > normalCheckInTime.hour ||
        (checkInTimeOfDay.hour == normalCheckInTime.hour &&
            checkInTimeOfDay.minute > normalCheckInTime.minute);
  }

  String get statusLabel {
    switch (status) {
      case 'present':
        return 'Hadir';
      case 'absent':
        return 'Tidak Hadir';
      case 'sick':
        return 'Sakit';
      case 'permission':
        return 'Izin';
      case 'late':
        return 'Terlambat';
      default:
        return status;
    }
  }
}

// Helper class untuk TimeOfDay jika belum ada
class TimeOfDay {
  final int hour;
  final int minute;

  TimeOfDay({required this.hour, required this.minute});

  factory TimeOfDay.fromDateTime(DateTime dateTime) {
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }
}
