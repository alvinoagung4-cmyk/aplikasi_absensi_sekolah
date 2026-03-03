-- =====================================================
-- COMPLETE DATABASE SCHEMA FOR SCHOOL ATTENDANCE SYSTEM
-- WITH NGROK INTEGRATION
-- =====================================================
-- 
-- Database lengkap untuk sistem presensi sekolah dengan tunelling NGROK
-- 
-- Instruksi Setup:
-- 1. Buat database PostgreSQL: CREATE DATABASE presensi_railway;
-- 2. Connect ke database: psql -U postgres -d presensi_railway
-- 3. Copy dan paste semua query di bawah ini
-- 4. Atau gunakan: psql -U postgres -d presensi_railway -f database-setup-ngrok.sql

-- ==================== DROP TABLES ====================
-- Hapus table lama jika ada (untuk reset)
DROP TABLE IF EXISTS activity_photos CASCADE;
DROP TABLE IF EXISTS activity_journals CASCADE;
DROP TABLE IF EXISTS notification_logs CASCADE;
DROP TABLE IF EXISTS holidays_leaves CASCADE;
DROP TABLE IF EXISTS attendance_records CASCADE;
DROP TABLE IF EXISTS student_class CASCADE;
DROP TABLE IF EXISTS parent_contact CASCADE;
DROP TABLE IF EXISTS classes CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ==================== USERS TABLE ====================
-- Tabel utama untuk semua user (admin, guru, siswa, orang tua)
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  user_type VARCHAR(20) NOT NULL, -- 'admin', 'teacher', 'student', 'parent'
  nama_lengkap VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  no_hp VARCHAR(20) NOT NULL,
  password VARCHAR(255) NOT NULL,
  foto_profil TEXT,
  nip VARCHAR(50), -- Nomor Induk Pegawai (untuk guru)
  nis VARCHAR(50) UNIQUE, -- Nomor Induk Siswa (untuk siswa)
  email_verified BOOLEAN DEFAULT FALSE,
  phone_verified BOOLEAN DEFAULT FALSE,
  verification_token VARCHAR(500),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_user_type ON users(user_type);
CREATE INDEX idx_users_nis ON users(nis);
CREATE INDEX idx_users_nip ON users(nip);
CREATE INDEX idx_users_is_active ON users(is_active);

-- ==================== CLASSES TABLE ====================
-- Tabel untuk kelas/ruang pembelajaran
CREATE TABLE IF NOT EXISTS classes (
  id SERIAL PRIMARY KEY,
  nama_kelas VARCHAR(50) NOT NULL, -- 'X A', 'XI B', 'XII IPA', dll
  tingkat SMALLINT NOT NULL, -- 10, 11, 12 (kelas X, XI, XII)
  jurusan VARCHAR(50), -- 'IPA', 'IPS', 'Teknik', 'Akuntansi'
  wali_kelas_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
  tahun_ajaran VARCHAR(10) NOT NULL, -- '2024/2025', '2025/2026'
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_classes_tingkat ON classes(tingkat);
CREATE INDEX idx_classes_jurusan ON classes(jurusan);
CREATE INDEX idx_classes_tahun_ajaran ON classes(tahun_ajaran);
CREATE INDEX idx_classes_wali_kelas ON classes(wali_kelas_id);

-- ==================== STUDENT CLASS TABLE ====================
-- Tabel gabungan antara siswa dan kelas mereka
CREATE TABLE IF NOT EXISTS student_class (
  id SERIAL PRIMARY KEY,
  student_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  class_id INTEGER NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  tahun_ajaran VARCHAR(10) NOT NULL,
  absen INTEGER DEFAULT 0, -- Jumlah hari absen
  sakit INTEGER DEFAULT 0, -- Jumlah hari sakit
  izin INTEGER DEFAULT 0, -- Jumlah hari izin
  terlambat INTEGER DEFAULT 0, -- Jumlah kali terlambat
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(student_id, class_id, tahun_ajaran)
);

CREATE INDEX idx_student_class_student ON student_class(student_id);
CREATE INDEX idx_student_class_class ON student_class(class_id);

-- ==================== PARENT CONTACT TABLE ====================
-- Tabel untuk informasi kontak orang tua siswa
CREATE TABLE IF NOT EXISTS parent_contact (
  id SERIAL PRIMARY KEY,
  student_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  parent_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
  parent_name VARCHAR(100) NOT NULL,
  parent_phone VARCHAR(20) NOT NULL,
  parent_email VARCHAR(100),
  relationship VARCHAR(20), -- 'ibu', 'ayah', 'wali'
  whatsapp_enabled BOOLEAN DEFAULT TRUE,
  email_enabled BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_parent_contact_student ON parent_contact(student_id);
CREATE INDEX idx_parent_contact_parent ON parent_contact(parent_id);

-- ==================== ATTENDANCE RECORDS TABLE ====================
-- Tabel utama untuk data presensi/absensi
CREATE TABLE IF NOT EXISTS attendance_records (
  id SERIAL PRIMARY KEY,
  student_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  class_id INTEGER REFERENCES classes(id) ON DELETE SET NULL,
  tanggal DATE NOT NULL,
  check_in_time TIMESTAMP, -- Waktu datang
  check_out_time TIMESTAMP, -- Waktu pulang
  status VARCHAR(20) NOT NULL DEFAULT 'absent', -- 'present', 'absent', 'sick', 'permission', 'late'
  latitude DECIMAL(10, 8), -- Koordinat lokasi saat check-in
  longitude DECIMAL(11, 8), -- Koordinat lokasi saat check-in
  foto_check_in TEXT, -- URL/path untuk foto check-in (wajah)
  foto_check_out TEXT, -- URL/path untuk foto check-out
  notes TEXT, -- Catatan atau keterangan
  approved_by INTEGER REFERENCES users(id) ON DELETE SET NULL, -- Admin/Guru yang approve
  notification_sent BOOLEAN DEFAULT FALSE, -- Flag untuk notifikasi WhatsApp/Email
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_attendance_student_date ON attendance_records(student_id, tanggal);
CREATE INDEX idx_attendance_class_date ON attendance_records(class_id, tanggal);
CREATE INDEX idx_attendance_status ON attendance_records(status);
CREATE INDEX idx_attendance_tanggal ON attendance_records(tanggal);

-- ==================== ACTIVITY JOURNALS TABLE ====================
-- Tabel untuk jurnal kegiatan tambahan siswa
CREATE TABLE IF NOT EXISTS activity_journals (
  id SERIAL PRIMARY KEY,
  student_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  class_id INTEGER REFERENCES classes(id) ON DELETE SET NULL,
  tanggal DATE NOT NULL,
  judul_kegiatan VARCHAR(255) NOT NULL,
  deskripsi_kegiatan TEXT NOT NULL,
  mata_pelajaran VARCHAR(100),
  guru_pengampu_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
  lokasi VARCHAR(255),
  total_peserta INTEGER,
  status VARCHAR(20) DEFAULT 'draft', -- 'draft', 'submitted', 'approved'
  approved_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
  is_printable BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_activity_student_date ON activity_journals(student_id, tanggal);
CREATE INDEX idx_activity_class_date ON activity_journals(class_id, tanggal);
CREATE INDEX idx_activity_status ON activity_journals(status);

-- ==================== ACTIVITY PHOTOS TABLE ====================
-- Tabel untuk foto-foto kegiatan
CREATE TABLE IF NOT EXISTS activity_photos (
  id SERIAL PRIMARY KEY,
  activity_journal_id INTEGER NOT NULL REFERENCES activity_journals(id) ON DELETE CASCADE,
  photo_url TEXT NOT NULL,
  photo_order SMALLINT DEFAULT 1,
  keterangan TEXT,
  uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_activity_photos_journal ON activity_photos(activity_journal_id);

-- ==================== NOTIFICATION LOGS TABLE ====================
-- Tabel untuk log notifikasi WhatsApp dan Email
CREATE TABLE IF NOT EXISTS notification_logs (
  id SERIAL PRIMARY KEY,
  student_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  parent_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
  attendance_id INTEGER REFERENCES attendance_records(id) ON DELETE SET NULL,
  notification_type VARCHAR(20) NOT NULL, -- 'whatsapp', 'email'
  recipient VARCHAR(100) NOT NULL,
  message TEXT NOT NULL,
  status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'sent', 'failed'
  check_in_status VARCHAR(20), -- 'datang', 'pulang'
  check_in_time TIMESTAMP,
  error_message TEXT,
  sent_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notification_logs_student ON notification_logs(student_id);
CREATE INDEX idx_notification_logs_status ON notification_logs(status);
CREATE INDEX idx_notification_logs_type ON notification_logs(notification_type);

-- ==================== HOLIDAYS/LEAVES TABLE ====================
-- Tabel untuk hari libur dan cuti sekolah
CREATE TABLE IF NOT EXISTS holidays_leaves (
  id SERIAL PRIMARY KEY,
  tanggal_mulai DATE NOT NULL,
  tanggal_akhir DATE NOT NULL,
  nama_libur VARCHAR(100) NOT NULL,
  tipe_libur VARCHAR(30), -- 'libur_resmi', 'cuti_guru', 'cuti_siswa'
  keterangan TEXT,
  created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_holidays_tanggal ON holidays_leaves(tanggal_mulai, tanggal_akhir);

-- ==================== TRIGGERS FOR AUTO TIMESTAMP ====================
-- Trigger untuk auto-update kolom updated_at

CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_update_timestamp BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER classes_update_timestamp BEFORE UPDATE ON classes
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER student_class_update_timestamp BEFORE UPDATE ON student_class
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER parent_contact_update_timestamp BEFORE UPDATE ON parent_contact
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER attendance_records_update_timestamp BEFORE UPDATE ON attendance_records
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER activity_journals_update_timestamp BEFORE UPDATE ON activity_journals
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- ==================== SAMPLE DATA ====================
-- Password untuk semua: 123456
-- Hashed dengan bcrypt: $2a$10$XQnF0WXh0JHNYYj7QQk4Z.DTQQ8RHmJ5c3h5S5H5k5H5k5H5k5H5k

-- Insert Users (Admin, Guru, Siswa, Orang Tua)
INSERT INTO users (user_type, nama_lengkap, email, no_hp, password, nip, email_verified, is_active) VALUES
('admin', 'Admin Sekolah', 'admin@sekolah.com', '082123456789', '$2a$10$XQnF0WXh0JHNYYj7QQk4Z.DTQQ8RHmJ5c3h5S5H5k5H5k5H5k5H5k', '198001011234567', TRUE, TRUE),
('teacher', 'Ibu Suri Rahayu', 'suri@sekolah.com', '081234567890', '$2a$10$XQnF0WXh0JHNYYj7QQk4Z.DTQQ8RHmJ5c3h5S5H5k5H5k5H5k5H5k', '198501021234567', TRUE, TRUE),
('teacher', 'Bapak Ahmad Wijaya', 'ahmad@sekolah.com', '082345678901', '$2a$10$XQnF0WXh0JHNYYj7QQk4Z.DTQQ8RHmJ5c3h5S5H5k5H5k5H5k5H5k', '199001031234567', TRUE, TRUE),
('student', 'Budi Santoso', 'budi@sekolah.com', '087654321098', '$2a$10$XQnF0WXh0JHNYYj7QQk4Z.DTQQ8RHmJ5c3h5S5H5k5H5k5H5k5H5k', NULL, TRUE, TRUE),
('student', 'Ani Wijaya', 'ani@sekolah.com', '087654321099', '$2a$10$XQnF0WXh0JHNYYj7QQk4Z.DTQQ8RHmJ5c3h5S5H5k5H5k5H5k5H5k', NULL, TRUE, TRUE),
('student', 'Citra Dewi', 'citra@sekolah.com', '087654321100', '$2a$10$XQnF0WXh0JHNYYj7QQk4Z.DTQQ8RHmJ5c3h5S5H5k5H5k5H5k5H5k', NULL, TRUE, TRUE),
('parent', 'Bapak Santoso', 'bapak.santoso@sekolah.com', '081111111111', '$2a$10$XQnF0WXh0JHNYYj7QQk4Z.DTQQ8RHmJ5c3h5S5H5k5H5k5H5k5H5k', NULL, TRUE, TRUE),
('parent', 'Ibu Sangadah', 'ibu.sangadah@sekolah.com', '082222222222', '$2a$10$XQnF0WXh0JHNYYj7QQk4Z.DTQQ8RHmJ5c3h5S5H5k5H5k5H5k5H5k', NULL, TRUE, TRUE);

-- Update NIS untuk siswa
UPDATE users SET nis = '001/X-A/2024' WHERE nama_lengkap = 'Budi Santoso';
UPDATE users SET nis = '002/X-A/2024' WHERE nama_lengkap = 'Ani Wijaya';
UPDATE users SET nis = '003/X-A/2024' WHERE nama_lengkap = 'Citra Dewi';

-- Insert Classes
INSERT INTO classes (nama_kelas, tingkat, jurusan, wali_kelas_id, tahun_ajaran, is_active) VALUES
('X A', 10, 'IPA', 2, '2024/2025', TRUE),
('X B', 10, 'IPS', 3, '2024/2025', TRUE),
('XI A', 11, 'IPA', 2, '2024/2025', TRUE),
('XI B', 11, 'IPS', 3, '2024/2025', TRUE),
('XII A', 12, 'IPA', 2, '2024/2025', TRUE);

-- Insert Student Classes
INSERT INTO student_class (student_id, class_id, tahun_ajaran) VALUES
(4, 1, '2024/2025'),
(5, 1, '2024/2025'),
(6, 1, '2024/2025');

-- Insert Parent Contacts
INSERT INTO parent_contact (student_id, parent_id, parent_name, parent_phone, parent_email, relationship, whatsapp_enabled, email_enabled) VALUES
(4, 7, 'Bapak Santoso', '081111111111', 'bapak.santoso@sekolah.com', 'ayah', TRUE, TRUE),
(4, NULL, 'Ibu Sangadah', '082222222222', 'ibu.sangadah@sekolah.com', 'ibu', TRUE, TRUE),
(5, NULL, 'Bapak Wijaya', '083333333333', 'bapak.wijaya@sekolah.com', 'ayah', TRUE, TRUE),
(6, NULL, 'Ibu Dewi', '084444444444', 'ibu.dewi@sekolah.com', 'ibu', TRUE, TRUE);

-- Insert Sample Attendance Records
INSERT INTO attendance_records (student_id, class_id, tanggal, check_in_time, check_out_time, status, latitude, longitude, notes) VALUES
-- Budi Santoso - Data presensi minggu lalu
(4, 1, '2025-02-24', '2025-02-24 07:30:00', '2025-02-24 14:30:00', 'present', -6.2088, 106.8456, 'Hadir tepat waktu'),
(4, 1, '2025-02-25', '2025-02-25 08:15:00', '2025-02-25 14:30:00', 'late', -6.2088, 106.8456, 'Terlambat 15 menit'),
(4, 1, '2025-02-26', '2025-02-26 07:25:00', '2025-02-26 14:30:00', 'present', -6.2088, 106.8456, 'Hadir'),
(4, 1, '2025-02-27', NULL, NULL, 'sick', NULL, NULL, 'Sakit, ada surat keterangan'),
(4, 1, '2025-02-28', '2025-02-28 07:45:00', '2025-02-28 14:30:00', 'present', -6.2088, 106.8456, 'Hadir'),
-- Ani Wijaya - Data presensi
(5, 1, '2025-02-24', '2025-02-24 07:35:00', '2025-02-24 14:35:00', 'present', -6.2088, 106.8456, 'Hadir'),
(5, 1, '2025-02-25', '2025-02-25 07:40:00', '2025-02-25 14:35:00', 'present', -6.2088, 106.8456, 'Hadir'),
(5, 1, '2025-02-26', '2025-02-26 07:30:00', '2025-02-26 14:35:00', 'present', -6.2088, 106.8456, 'Hadir'),
(5, 1, '2025-02-27', '2025-02-27 07:50:00', '2025-02-27 14:35:00', 'late', -6.2088, 106.8456, 'Terlambat 20 menit'),
(5, 1, '2025-02-28', '2025-02-28 07:35:00', '2025-02-28 14:35:00', 'present', -6.2088, 106.8456, 'Hadir'),
-- Citra Dewi - Data presensi
(6, 1, '2025-02-24', '2025-02-24 07:40:00', '2025-02-24 14:40:00', 'present', -6.2088, 106.8456, 'Hadir'),
(6, 1, '2025-02-25', '2025-02-25 07:30:00', '2025-02-25 14:40:00', 'present', -6.2088, 106.8456, 'Hadir'),
(6, 1, '2025-02-26', NULL, NULL, 'absent', NULL, NULL, 'Tidak hadir, tanpa keterangan'),
(6, 1, '2025-02-27', '2025-02-27 07:35:00', '2025-02-27 14:40:00', 'present', -6.2088, 106.8456, 'Hadir'),
(6, 1, '2025-02-28', '2025-02-28 07:30:00', '2025-02-28 14:40:00', 'present', -6.2088, 106.8456, 'Hadir'),
-- Data untuk hari ini (1 Maret 2025)
(4, 1, '2025-03-01', '2025-03-01 07:28:00', '2025-03-01 14:32:00', 'present', -6.2088, 106.8456, 'Check-in dengan face recognition'),
(5, 1, '2025-03-01', '2025-03-01 07:33:00', '2025-03-01 14:35:00', 'present', -6.2088, 106.8456, 'Check-in dengan face recognition'),
(6, 1, '2025-03-01', '2025-03-01 07:29:00', '2025-03-01 14:38:00', 'present', -6.2088, 106.8456, 'Check-in dengan face recognition');

-- Insert Sample Activity Journals
INSERT INTO activity_journals (student_id, class_id, tanggal, judul_kegiatan, deskripsi_kegiatan, mata_pelajaran, guru_pengampu_id, lokasi, total_peserta, status) VALUES
(4, 1, '2025-02-24', 'Praktikum Kimia', 'Melakukan praktikum larutan asam dan basa di laboratorium kimia. Siswa membuat larutan dengan pH berbeda dan melakukan pengujian dengan indikator universal.', 'Kimia', 2, 'Laboratorium Kimia', 30, 'submitted'),
(5, 1, '2025-02-24', 'Praktikum Biologi', 'Mengamati sel dengan mikroskop. Praktikum ini dilakukan untuk memahami struktur sel tumbuhan dan hewan.', 'Biologi', 2, 'Laboratorium Biologi', 30, 'approved'),
(6, 1, '2025-02-25', 'Olahraga - Bola Voli', 'Bermain bola voli dan latihan teknik dasar pukulan. Kegiatan ini bertujuan meningkatkan kebugaran dan kerja sama tim.', 'Pendidikan Jasmani', 3, 'Lapangan Sekolah', 32, 'submitted'),
(4, 1, '2025-02-26', 'Ekstrakurikuler Robotik', 'Merakit dan memprogram robot sederhana menggunakan Arduino. Acara ini berlangsung selama 2 jam setelah jam sekolah.', 'Teknologi', 2, 'Ruang IT', 15, 'draft'),
(5, 1, '2025-02-27', 'Pramuka', 'Perkemahan pramuka pagi di halaman sekolah dengan materi kepemimpinan dan outdoor skills.', 'Pendidikan Budaya', 3, 'Halaman Sekolah', 45, 'submitted');

-- Insert Sample Activity Photos
INSERT INTO activity_photos (activity_journal_id, photo_url, photo_order, keterangan) VALUES
(1, 'https://cheliform-unappreciably-allison.ngrok-free.dev/uploads/activity_001_01.jpg', 1, 'Siswa melakukan praktikum membuat larutan'),
(1, 'https://cheliform-unappreciably-allison.ngrok-free.dev/uploads/activity_001_02.jpg', 2, 'Pengujian pH menggunakan indikator universal'),
(2, 'https://cheliform-unappreciably-allison.ngrok-free.dev/uploads/activity_002_01.jpg', 1, 'Mengamati persiapan mikroskop'),
(3, 'https://cheliform-unappreciably-allison.ngrok-free.dev/uploads/activity_003_01.jpg', 1, 'Permainan bola voli sedang berlangsung'),
(4, 'https://cheliform-unappreciably-allison.ngrok-free.dev/uploads/activity_004_01.jpg', 1, 'Perakitan robot Arduino'),
(5, 'https://cheliform-unappreciably-allison.ngrok-free.dev/uploads/activity_005_01.jpg', 1, 'Kegiatan pramuka di pagi hari');

-- Insert Sample Notification Logs
INSERT INTO notification_logs (student_id, parent_id, attendance_id, notification_type, recipient, message, status, check_in_status, check_in_time) VALUES
(4, 7, 16, 'whatsapp', '081111111111', 'Halo Bapak Santoso, Budi telah melakukan check-in pukul 07:28 hari ini. Status: HADIR', 'sent', 'datang', '2025-03-01 07:28:00'),
(5, NULL, 17, 'whatsapp', '083333333333', 'Halo Bapak Wijaya, Ani telah melakukan check-in pukul 07:33 hari ini. Status: HADIR', 'sent', 'datang', '2025-03-01 07:33:00'),
(6, NULL, 18, 'email', 'ibu.dewi@sekolah.com', 'Citra telah check-in pada 2025-03-01 07:29. Status: HADIR', 'sent', 'datang', '2025-03-01 07:29:00');

-- Insert Sample Holidays/Leaves
INSERT INTO holidays_leaves (tanggal_mulai, tanggal_akhir, nama_libur, tipe_libur, keterangan, created_by, is_active) VALUES
('2025-03-02', '2025-03-02', 'Hari Guru Nasional', 'libur_resmi', 'Libur nasional untuk memperingati Hari Guru Nasional', 1, TRUE),
('2025-03-29', '2025-04-06', 'Libur Paskah', 'libur_resmi', 'Libur untuk memperingati hari Paskah', 1, TRUE),
('2025-05-01', '2025-05-03', 'Libur Hari Raya Waisak', 'libur_resmi', 'Libur untuk perayaan Hari Raya Waisak', 1, TRUE),
('2025-05-19', '2025-05-21', 'Libur Hari Raya Idul Fitri', 'libur_resmi', 'Libur untuk perayaan Hari Raya Idul Fitri 2025', 1, TRUE);

-- ==================== DATABASE VERIFICATION ====================
SELECT '✅ Database Setup Complete!' as setup_status;
SELECT '📊 Total Users: ' || COUNT(*) as summary FROM users;
SELECT '📚 Total Classes: ' || COUNT(*) as summary FROM classes;
SELECT '📝 Total Student Classes: ' || COUNT(*) as summary FROM student_class;
SELECT '👨‍👩‍👧 Total Parent Contacts: ' || COUNT(*) as summary FROM parent_contact;
SELECT '📋 Total Attendance Records: ' || COUNT(*) as summary FROM attendance_records;
SELECT '📖 Total Activity Journals: ' || COUNT(*) as summary FROM activity_journals;

-- ==================== USEFUL QUERIES ====================
-- Query untuk melihat presensi siswa hari ini
-- SELECT ar.tanggal, u.nama_lengkap, c.nama_kelas, ar.check_in_time, ar.status
-- FROM attendance_records ar
-- JOIN users u ON ar.student_id = u.id
-- JOIN classes c ON ar.class_id = c.id
-- WHERE ar.tanggal = CURRENT_DATE
-- ORDER BY u.nama_lengkap;

-- Query untuk melihat rekapitulasi presensi per siswa
-- SELECT u.nama_lengkap, c.nama_kelas,
--        sc.absen, sc.sakit, sc.izin, sc.terlambat
-- FROM student_class sc
-- JOIN users u ON sc.student_id = u.id
-- JOIN classes c ON sc.class_id = c.id;

-- Query untuk melihat aktivitas siswa
-- SELECT aj.tanggal, u.nama_lengkap, aj.judul_kegiatan, aj.status
-- FROM activity_journals aj
-- JOIN users u ON aj.student_id = u.id
-- ORDER BY aj.tanggal DESC;
