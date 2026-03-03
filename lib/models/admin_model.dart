// Model untuk Kelas
class Kelas {
  final String id;
  String namaKelas;
  String jurusan;
  String waliKelas;
  final String loginWali;
  final int jumlahSiswa;
  final String aksi;

  Kelas({
    required this.id,
    required this.namaKelas,
    required this.jurusan,
    required this.waliKelas,
    required this.loginWali,
    required this.jumlahSiswa,
    required this.aksi,
  });

  factory Kelas.fromJson(Map<String, dynamic> json) {
    return Kelas(
      id: json['id'] ?? '',
      namaKelas: json['namaKelas'] ?? '',
      jurusan: json['jurusan'] ?? '',
      waliKelas: json['waliKelas'] ?? '',
      loginWali: json['loginWali'] ?? '',
      jumlahSiswa: json['jumlahSiswa'] ?? 0,
      aksi: json['aksi'] ?? 'Lihat',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaKelas': namaKelas,
      'jurusan': jurusan,
      'waliKelas': waliKelas,
      'loginWali': loginWali,
      'jumlahSiswa': jumlahSiswa,
      'aksi': aksi,
    };
  }
}

// Model untuk Siswa
class Siswa {
  final String id;
  String namaSiswa;
  String kelas;
  final String jurusan;
  final int jumlahHadir;
  final int jumlahIzin;
  final int jumlahSakit;
  final int jumlahAlpha;

  Siswa({
    required this.id,
    required this.namaSiswa,
    required this.kelas,
    required this.jurusan,
    required this.jumlahHadir,
    required this.jumlahIzin,
    required this.jumlahSakit,
    required this.jumlahAlpha,
  });

  factory Siswa.fromJson(Map<String, dynamic> json) {
    return Siswa(
      id: json['id'] ?? '',
      namaSiswa: json['namaSiswa'] ?? '',
      kelas: json['kelas'] ?? '',
      jurusan: json['jurusan'] ?? '',
      jumlahHadir: json['jumlahHadir'] ?? 0,
      jumlahIzin: json['jumlahIzin'] ?? 0,
      jumlahSakit: json['jumlahSakit'] ?? 0,
      jumlahAlpha: json['jumlahAlpha'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaSiswa': namaSiswa,
      'kelas': kelas,
      'jurusan': jurusan,
      'jumlahHadir': jumlahHadir,
      'jumlahIzin': jumlahIzin,
      'jumlahSakit': jumlahSakit,
      'jumlahAlpha': jumlahAlpha,
    };
  }
}

// Model untuk Ringkasan Absensi Per Jurusan
class RingkasanJurusan {
  final String namaJurusan;
  final int jumlahKelas;
  final int jumlahSiswa;

  RingkasanJurusan({
    required this.namaJurusan,
    required this.jumlahKelas,
    required this.jumlahSiswa,
  });

  factory RingkasanJurusan.fromJson(Map<String, dynamic> json) {
    return RingkasanJurusan(
      namaJurusan: json['namaJurusan'] ?? '',
      jumlahKelas: json['jumlahKelas'] ?? 0,
      jumlahSiswa: json['jumlahSiswa'] ?? 0,
    );
  }
}

// Model untuk Statistik Absensi
class StatistikAbsensi {
  final String kelas;
  final int hadir;
  final int izin;
  final int sakit;
  final int alpha;

  StatistikAbsensi({
    required this.kelas,
    required this.hadir,
    required this.izin,
    required this.sakit,
    required this.alpha,
  });

  factory StatistikAbsensi.fromJson(Map<String, dynamic> json) {
    return StatistikAbsensi(
      kelas: json['kelas'] ?? '',
      hadir: json['hadir'] ?? 0,
      izin: json['izin'] ?? 0,
      sakit: json['sakit'] ?? 0,
      alpha: json['alpha'] ?? 0,
    );
  }
}

// Model untuk Dashboard Admin
class DashboardStats {
  final int totalSiswa;
  final int hadir;
  final int izin;
  final int sakit;
  final int alpha;

  DashboardStats({
    required this.totalSiswa,
    required this.hadir,
    required this.izin,
    required this.sakit,
    required this.alpha,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalSiswa: json['totalSiswa'] ?? 0,
      hadir: json['hadir'] ?? 0,
      izin: json['izin'] ?? 0,
      sakit: json['sakit'] ?? 0,
      alpha: json['alpha'] ?? 0,
    );
  }
}
