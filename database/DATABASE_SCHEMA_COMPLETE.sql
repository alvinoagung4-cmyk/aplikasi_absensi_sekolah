-- DATABASE SCHEMA untuk Presensi Railway
-- Simpan file ini di: database/attendance_schema.sql

-- ============================================
-- 1. TABLE: KELAS (Class Management)
-- ============================================
CREATE TABLE IF NOT EXISTS kelas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_kelas VARCHAR(100) NOT NULL UNIQUE,
    jurusan VARCHAR(50) NOT NULL,
    wali_kelas VARCHAR(100) NOT NULL,
    login_wali VARCHAR(100),
    jumlah_siswa INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    INDEX idx_jurusan (jurusan),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 2. TABLE: SISWA (Student Management)
-- ============================================
CREATE TABLE IF NOT EXISTS siswa (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_siswa VARCHAR(100) NOT NULL,
    kelas_id INT NOT NULL,
    jurusan VARCHAR(50) NOT NULL,
    jumlah_hadir INT DEFAULT 0,
    jumlah_izin INT DEFAULT 0,
    jumlah_sakit INT DEFAULT 0,
    jumlah_alpha INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (kelas_id) REFERENCES kelas(id) ON DELETE CASCADE,
    INDEX idx_kelas_id (kelas_id),
    INDEX idx_jurusan (jurusan),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 3. TABLE: ADMIN (Admin Users)
-- ============================================
CREATE TABLE IF NOT EXISTS admin_users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    nama_lengkap VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    INDEX idx_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 4. TABLE: WALI_KELAS (Class Guardian/Teacher)
-- ============================================
CREATE TABLE IF NOT EXISTS wali_kelas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    nama_lengkap VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    kelas_id INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (kelas_id) REFERENCES kelas(id) ON DELETE SET NULL,
    INDEX idx_username (username),
    INDEX idx_kelas_id (kelas_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 5. TABLE: USERS (Student Users)
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    nama_lengkap VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    siswa_id INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (siswa_id) REFERENCES siswa(id) ON DELETE SET NULL,
    INDEX idx_username (username),
    INDEX idx_siswa_id (siswa_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 6. TABLE: PRESENSI (Attendance Records)
-- ============================================
CREATE TABLE IF NOT EXISTS presensi (
    id INT AUTO_INCREMENT PRIMARY KEY,
    siswa_id INT NOT NULL,
    kelas_id INT NOT NULL,
    tanggal DATE NOT NULL,
    status ENUM('Hadir', 'Izin', 'Sakit', 'Alpha') DEFAULT 'Alpha',
    keterangan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (siswa_id) REFERENCES siswa(id) ON DELETE CASCADE,
    FOREIGN KEY (kelas_id) REFERENCES kelas(id) ON DELETE CASCADE,
    UNIQUE KEY unique_presensi (siswa_id, tanggal),
    INDEX idx_siswa_id (siswa_id),
    INDEX idx_kelas_id (kelas_id),
    INDEX idx_tanggal (tanggal)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- SAMPLE DATA FOR TESTING
-- ============================================

-- Insert admin user
INSERT INTO admin_users (username, password, nama_lengkap, email) VALUES
('admin', 'admin123', 'Administrator', 'admin@sekolah.com');

-- Insert sample classes (Kelas)
INSERT INTO kelas (nama_kelas, jurusan, wali_kelas, login_wali, jumlah_siswa) VALUES
('X TEI 1', 'TEI', 'Pak Ahmad', 'teil/teil23', 5),
('X TEI 2', 'TEI', 'Bu Siti', 'tei2/tei23', 5),
('XI TEI 1', 'TEI', 'Pak Budi', 'tei3/tei23', 0),
('XI TEI 2', 'TEI', 'Bu Ani', 'tei4/tei23', 0),
('XII TEI', 'TEI', 'Pak Joko', 'tei5/tei23', 0),
('X TKR 1', 'TKR', 'Pak Hendra', 'tkr1/tkr23', 5);

-- Insert wali kelas
INSERT INTO wali_kelas (username, password, nama_lengkap, email, kelas_id) VALUES
('teil', 'teil23', 'Pak Ahmad', 'ahmad@sekolah.com', 1),
('tei2', 'tei23', 'Bu Siti', 'siti@sekolah.com', 2),
('tkr1', 'tkr23', 'Pak Hendra', 'hendra@sekolah.com', 6);

-- Insert students (Siswa)
INSERT INTO siswa (nama_siswa, kelas_id, jurusan, jumlah_hadir, jumlah_izin, jumlah_sakit, jumlah_alpha) VALUES
('Siswa 1 X TEI 1', 1, 'TEI', 5, 0, 0, 0),
('Siswa 2 X TEI 1', 1, 'TEI', 5, 0, 0, 0),
('Siswa 3 X TEI 1', 1, 'TEI', 3, 1, 1, 0),
('Siswa 4 X TEI 1', 1, 'TEI', 4, 1, 0, 0),
('Siswa 5 X TEI 1', 1, 'TEI', 2, 1, 1, 1),
('Siswa 1 X TEI 2', 2, 'TEI', 5, 0, 0, 0),
('Siswa 2 X TEI 2', 2, 'TEI', 5, 0, 0, 0),
('Siswa 1 X TKR 1', 6, 'TKR', 5, 0, 0, 0);
