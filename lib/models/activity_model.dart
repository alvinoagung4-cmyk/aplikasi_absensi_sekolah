class ActivityJournal {
  final int id;
  final int studentId;
  final int? classId;
  final String tanggal;
  final String judulKegiatan;
  final String deskripsiKegiatan;
  final String? mataPelajaran;
  final String? lokasi;
  final int? totalPeserta;
  final String status; // 'draft', 'submitted', 'approved'
  final List<ActivityPhoto> photos;
  final DateTime createdAt;
  final DateTime updatedAt;

  ActivityJournal({
    required this.id,
    required this.studentId,
    this.classId,
    required this.tanggal,
    required this.judulKegiatan,
    required this.deskripsiKegiatan,
    this.mataPelajaran,
    this.lokasi,
    this.totalPeserta,
    this.status = 'draft',
    this.photos = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory ActivityJournal.fromJson(Map<String, dynamic> json) {
    return ActivityJournal(
      id: json['id'],
      studentId: json['student_id'],
      classId: json['class_id'],
      tanggal: json['tanggal'],
      judulKegiatan: json['judul_kegiatan'],
      deskripsiKegiatan: json['deskripsi_kegiatan'],
      mataPelajaran: json['mata_pelajaran'],
      lokasi: json['lokasi'],
      totalPeserta: json['total_peserta'],
      status: json['status'] ?? 'draft',
      photos: json['photos'] != null
          ? List<ActivityPhoto>.from(
              (json['photos'] as List).map((p) => ActivityPhoto.fromJson(p)))
          : [],
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
      'judul_kegiatan': judulKegiatan,
      'deskripsi_kegiatan': deskripsiKegiatan,
      'mata_pelajaran': mataPelajaran,
      'lokasi': lokasi,
      'total_peserta': totalPeserta,
      'status': status,
      'photos': photos.map((p) => p.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ActivityPhoto {
  final int id;
  final int activityJournalId;
  final String photoUrl;
  final String? keterangan;
  final int photoOrder;
  final DateTime uploadedAt;

  ActivityPhoto({
    required this.id,
    required this.activityJournalId,
    required this.photoUrl,
    this.keterangan,
    this.photoOrder = 1,
    required this.uploadedAt,
  });

  factory ActivityPhoto.fromJson(Map<String, dynamic> json) {
    return ActivityPhoto(
      id: json['id'],
      activityJournalId: json['activity_journal_id'],
      photoUrl: json['photo_url'],
      keterangan: json['keterangan'],
      photoOrder: json['photo_order'] ?? 1,
      uploadedAt: DateTime.parse(json['uploaded_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activity_journal_id': activityJournalId,
      'photo_url': photoUrl,
      'keterangan': keterangan,
      'photo_order': photoOrder,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}
