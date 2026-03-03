-- =====================================================
-- SCHOOL ATTENDANCE SYSTEM - COMPLETE DATABASE SCHEMA
-- =====================================================
-- Database lengkap untuk sistem presensi sekolah

-- ==================== USERS TABLE ====================
DROP TABLE IF EXISTS activity_journals CASCADE;
DROP TABLE IF EXISTS activity_photos CASCADE;
DROP TABLE IF EXISTS parent_contact CASCADE;
DROP TABLE IF EXISTS attendance_records CASCADE;
DROP TABLE IF EXISTS classes CASCADE;
DROP TABLE IF EXISTS student_class CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- TABEL USERS (UTAMA)
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  user_type VARCHAR(20) NOT NULL, -- 'admin', 'teacher', 'student', 'parent'
  nama_lengkap VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  no_hp VARCHAR(20) NOT NULL,
  password VARCHAR(255) NOT NULL,
  foto_profil TEXT,
  nip VARCHAR(50), -- Untuk guru
  nis VARCHAR(50) UNIQUE, -- Untuk siswa
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

-- ==================== CLASSES TABLE ====================
CREATE TABLE IF NOT EXISTS classes (
  id SERIAL PRIMARY KEY,
  nama_kelas VARCHAR(50) NOT NULL, -- 'X A', 'XI B', dll
  tingkat SMALLINT NOT NULL, -- 10, 11, 12
  jurusan VARCHAR(50), -- 'IPA', 'IPS', 'Teknik'
  wali_kelas_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
  tahun_ajaran VARCHAR(10) NOT NULL, -- '2024/2025'
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_classes_tingkat ON classes(tingkat);
CREATE INDEX idx_classes_jurusan ON classes(jurusan);

-- ==================== STUDENT CLASS TABLE ====================
CREATE TABLE IF NOT EXISTS student_class (
  id SERIAL PRIMARY KEY,
  student_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  class_id INTEGER NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  tahun_ajaran VARCHAR(10) NOT NULL,
  absen INTEGER DEFAULT 0,
  sakit INTEGER DEFAULT 0,
  izin INTEGER DEFAULT 0,
  terlambat INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(student_id, class_id, tahun_ajaran)
);

CREATE INDEX idx_student_class_student ON student_class(student_id);
CREATE INDEX idx_student_class_class ON student_class(class_id);

-- ==================== PARENT CONTACT TABLE ====================
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
CREATE TABLE IF NOT EXISTS attendance_records (
  id SERIAL PRIMARY KEY,
  student_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  class_id INTEGER REFERENCES classes(id) ON DELETE SET NULL,
  tanggal DATE NOT NULL,
  check_in_time TIMESTAMP,
  check_out_time TIMESTAMP,
  status VARCHAR(20) NOT NULL DEFAULT 'absent', -- 'present', 'absent', 'sick', 'permission', 'late'
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  foto_check_in TEXT, -- URL/path untuk foto check-in
  foto_check_out TEXT, -- URL/path untuk foto check-out
  notes TEXT,
  approved_by INTEGER REFERENCES users(id) ON DELETE SET NULL, -- Admin/Teacher yang approve
  notification_sent BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_attendance_student_date ON attendance_records(student_id, tanggal);
CREATE INDEX idx_attendance_class_date ON attendance_records(class_id, tanggal);
CREATE INDEX idx_attendance_status ON attendance_records(status);

-- ==================== ACTIVITY JOURNALS TABLE ====================
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

-- ==================== HOLIDAY/LEAVE TABLE ====================
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

-- ==================== SAMPLE DATA ====================
-- PASSWORD: 123456 (hash: $2a$10$XQnF0WXh0JHNYYj7QQk4Z.DTQQ8RHmJ5c3h5S5H5k5H5k5H5k5H5k)

INSERT INTO users (user_type, nama_lengkap, email, no_hp, password, nip, email_verified, is_active) VALUES
('admin', 'Admin Sekolah', 'admin@sekolah.com', '082123456789', '$2a$10$XQnF0WXh0JHNYYj7QQk4Z.DTQQ8RHmJ5c3h5S5H5k5H5k5H5k5H5k', '198001011234567', TRUE, TRUE),
('teacher', 'Ibu Suri Rahayu', 'suri@sekolah.com', '081234567890', '$2a$10$XQnF0WXh0JHNYYj7QQk4Z.DTQQ8RHmJ5c3h5S5H5k5H5k5H5k5H5k', '198501021234567', TRUE, TRUE),
('student', 'Budi Santoso', 'budi@sekolah.com', '087654321098', '$2a$10$XQnF0WXh0JHNYYj7QQk4Z.DTQQ8RHmJ5c3h5S5H5k5H5k5H5k5H5k', NULL, TRUE, TRUE),
('student', 'Ani Wijaya', 'ani@sekolah.com', '087654321099', '$2a$10$XQnF0WXh0JHNYYj7QQk4Z.DTQQ8RHmJ5c3h5S5H5k5H5k5H5k5H5k', NULL, TRUE, TRUE),
('parent', 'Bapak Santoso', 'bapak@sekolah.com', '081111111111', '$2a$10$XQnF0WXh0JHNYYj7QQk4Z.DTQQ8RHmJ5c3h5S5H5k5H5k5H5k5H5k', NULL, TRUE, TRUE);

-- Update NIS untuk siswa
UPDATE users SET nis = '001/X-A/2024' WHERE nama_lengkap = 'Budi Santoso';
UPDATE users SET nis = '002/X-A/2024' WHERE nama_lengkap = 'Ani Wijaya';

-- Insert classes
INSERT INTO classes (nama_kelas, tingkat, jurusan, wali_kelas_id, tahun_ajaran, is_active) VALUES
('X A', 10, 'IPA', 2, '2024/2025', TRUE),
('X B', 10, 'IPS', 2, '2024/2025', TRUE),
('XI A', 11, 'IPA', 2, '2024/2025', TRUE);

-- Insert student classes
INSERT INTO student_class (student_id, class_id, tahun_ajaran) VALUES
(3, 1, '2024/2025'),
(4, 1, '2024/2025');

-- Insert parent contacts
INSERT INTO parent_contact (student_id, parent_id, parent_name, parent_phone, parent_email, relationship, whatsapp_enabled, email_enabled) VALUES
(3, 5, 'Bapak Santoso', '081111111111', 'bapak@sekolah.com', 'ayah', TRUE, TRUE),
(3, NULL, 'Ibu Sangadah', '082222222222', 'ibu@sekolah.com', 'ibu', TRUE, TRUE);

-- Insert sample attendance records
INSERT INTO attendance_records (student_id, class_id, tanggal, check_in_time, check_out_time, status) VALUES
(3, 1, '2024-01-26', '2024-01-26 07:30:00', '2024-01-26 14:30:00', 'present'),
(3, 1, '2024-01-25', '2024-01-25 07:45:00', '2024-01-25 14:30:00', 'late'),
(4, 1, '2024-01-26', '2024-01-26 07:35:00', '2024-01-26 14:35:00', 'present'),
(4, 1, '2024-01-25', '2024-01-25 08:15:00', '2024-01-25 14:30:00', 'late');

-- Insert sample activity journals
INSERT INTO activity_journals (student_id, class_id, tanggal, judul_kegiatan, deskripsi_kegiatan, mata_pelajaran, guru_pengampu_id, lokasi, total_peserta, status) VALUES
(3, 1, '2024-01-26', 'Praktikum Kimia', 'Melakukan praktikum larutan asam dan basa di laboratorium kimia', 'Kimia', 2, 'Lab Kimia', 30, 'submitted'),
(4, 1, '2024-01-26', 'Olahraga', 'Bermain bola voli di lapangan sekolah', 'Pendidikan Jasmani', 2, 'Lapangan Sekolah', 32, 'submitted');

-- ==================== TRIGGERS (OPTIONAL) ====================
-- Trigger untuk update timestamp otomatis
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

CREATE TRIGGER attendance_records_update_timestamp BEFORE UPDATE ON attendance_records
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER activity_journals_update_timestamp BEFORE UPDATE ON activity_journals
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- ==================== VERIFICATION ====================
SELECT 'Database setup complete!' as status;
SELECT 'Users created: ' || COUNT(*) FROM users;
SELECT 'Classes created: ' || COUNT(*) FROM classes;
SELECT 'Attendance records created: ' || COUNT(*) FROM attendance_records;
