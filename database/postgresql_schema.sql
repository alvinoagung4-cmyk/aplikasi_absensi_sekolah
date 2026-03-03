-- PostgreSQL Schema untuk Sistem Attendance (School Attendance System)
-- Database: absensingrok (or custom database name)

-- ============ CREATE TABLES ============

-- Table: kelas
CREATE TABLE IF NOT EXISTS kelas (
  id SERIAL PRIMARY KEY,
  nama_kelas VARCHAR(50) UNIQUE NOT NULL,
  jurusan VARCHAR(100),
  wali_kelas VARCHAR(100) NOT NULL,
  login_wali VARCHAR(100),
  jumlah_siswa INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP
);

-- Table: siswa
CREATE TABLE IF NOT EXISTS siswa (
  id SERIAL PRIMARY KEY,
  nama_siswa VARCHAR(100) NOT NULL,
  kelas_id INTEGER REFERENCES kelas(id),
  jurusan VARCHAR(100),
  hadir INTEGER DEFAULT 0,
  sakit INTEGER DEFAULT 0,
  izin INTEGER DEFAULT 0,
  alpa INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP
);

-- Table: users (untuk login siswa dan guru)
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(100) UNIQUE NOT NULL,
  email VARCHAR(100),
  password TEXT NOT NULL,
  nama_lengkap VARCHAR(100),
  role VARCHAR(20) DEFAULT 'siswa', -- siswa, guru, admin
  siswa_id INTEGER REFERENCES siswa(id),
  kelas_id INTEGER REFERENCES kelas(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP
);

-- Table: admin_users (untuk login admin)
CREATE TABLE IF NOT EXISTS admin_users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(100) UNIQUE NOT NULL,
  password TEXT NOT NULL,
  nama_lengkap VARCHAR(100),
  email VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP
);

-- Table: wali_kelas (untuk data guru/wali kelas)
CREATE TABLE IF NOT EXISTS wali_kelas (
  id SERIAL PRIMARY KEY,
  nama_wali VARCHAR(100) NOT NULL,
  kelas_id INTEGER REFERENCES kelas(id),
  nip VARCHAR(50),
  email VARCHAR(100),
  no_hp VARCHAR(20),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP
);

-- Table: presensi (untuk recording attendance detail per hari)
CREATE TABLE IF NOT EXISTS presensi (
  id SERIAL PRIMARY KEY,
  siswa_id INTEGER REFERENCES siswa(id),
  kelas_id INTEGER REFERENCES kelas(id),
  tanggal DATE NOT NULL,
  status VARCHAR(20), -- hadir, sakit, izin, alpa
  keterangan TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP
);

-- ============ CREATE INDEXES ============

-- Index untuk frequent queries
CREATE INDEX IF NOT EXISTS idx_kelas_deleted_at ON kelas(deleted_at);
CREATE INDEX IF NOT EXISTS idx_siswa_deleted_at ON siswa(deleted_at);
CREATE INDEX IF NOT EXISTS idx_siswa_kelas_id ON siswa(kelas_id);
CREATE INDEX IF NOT EXISTS idx_users_deleted_at ON users(deleted_at);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_presensi_siswa_id ON presensi(siswa_id);
CREATE INDEX IF NOT EXISTS idx_presensi_tanggal ON presensi(tanggal);
CREATE INDEX IF NOT EXISTS idx_presensi_kelas_id ON presensi(kelas_id);

-- ============ INSERT SAMPLE DATA ============

-- Sample Admin User
INSERT INTO admin_users (username, password, nama_lengkap, email) 
VALUES ('admin', '$2a$10$abc123', 'Administrator', 'admin@school.com')
ON CONFLICT (username) DO NOTHING;

-- Sample Classes
INSERT INTO kelas (nama_kelas, jurusan, wali_kelas, login_wali) 
VALUES 
  ('X-A', 'Akuntansi', 'Ibu Sarah', 'sarah_kls'),
  ('X-B', 'Akuntansi', 'Pak Ahmad', 'ahmad_kls'),
  ('XI-A', 'Penjualan', 'Ibu Nur', 'nur_kls'),
  ('XI-B', 'Penjualan', 'Pak Budi', 'budi_kls'),
  ('XII-A', 'Akuntansi', 'Ibu Dewi', 'dewi_kls'),
  ('XII-B', 'Penjualan', 'Pak Rudi', 'rudi_kls')
ON CONFLICT (nama_kelas) DO NOTHING;

-- Sample Students
INSERT INTO siswa (nama_siswa, kelas_id, jurusan) 
SELECT 
  'Akbar Pratama', k.id, 'Akuntansi'
FROM kelas k WHERE k.nama_kelas = 'X-A'
ON CONFLICT DO NOTHING;

INSERT INTO siswa (nama_siswa, kelas_id, jurusan) 
SELECT 
  'Bella Rahma', k.id, 'Akuntansi'
FROM kelas k WHERE k.nama_kelas = 'X-A'
ON CONFLICT DO NOTHING;

INSERT INTO siswa (nama_siswa, kelas_id, jurusan) 
SELECT 
  'Citra Sujati', k.id, 'Akuntansi'
FROM kelas k WHERE k.nama_kelas = 'X-B'
ON CONFLICT DO NOTHING;

INSERT INTO siswa (nama_siswa, kelas_id, jurusan) 
SELECT 
  'Doni Harjanto', k.id, 'Penjualan'
FROM kelas k WHERE k.nama_kelas = 'XI-A'
ON CONFLICT DO NOTHING;

INSERT INTO siswa (nama_siswa, kelas_id, jurusan) 
SELECT 
  'Eka Putri', k.id, 'Penjualan'
FROM kelas k WHERE k.nama_kelas = 'XI-B'
ON CONFLICT DO NOTHING;

-- ============ UPDATE jumlah_siswa IN kelas ============
UPDATE kelas 
SET jumlah_siswa = (SELECT COUNT(*) FROM siswa WHERE siswa.kelas_id = kelas.id AND siswa.deleted_at IS NULL);

-- ============ CREATE VIEW FOR EXTENDED DATA ============

-- View untuk siswa dengan detail kelas
CREATE OR REPLACE VIEW v_siswa_detail AS
SELECT 
  s.id,
  s.nama_siswa,
  s.kelas_id,
  k.nama_kelas,
  k.jurusan,
  s.hadir,
  s.sakit,
  s.izin,
  s.alpa,
  (s.hadir + s.sakit + s.izin + s.alpa) as total_hari,
  s.created_at,
  s.updated_at
FROM siswa s
LEFT JOIN kelas k ON s.kelas_id = k.id
WHERE s.deleted_at IS NULL;

-- View untuk kelas dengan detail siswa
CREATE OR REPLACE VIEW v_kelas_detail AS
SELECT 
  k.id,
  k.nama_kelas,
  k.jurusan,
  k.wali_kelas,
  k.jumlah_siswa,
  COUNT(s.id) as siswa_aktif,
  k.created_at,
  k.updated_at
FROM kelas k
LEFT JOIN siswa s ON s.kelas_id = k.id AND s.deleted_at IS NULL
WHERE k.deleted_at IS NULL
GROUP BY k.id, k.nama_kelas, k.jurusan, k.wali_kelas, k.jumlah_siswa, k.created_at, k.updated_at;
