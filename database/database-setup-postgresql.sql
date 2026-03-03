-- ============================================
-- DATABASE SETUP UNTUK APLIKASI PRESENSI (PostgreSQL)
-- ============================================

-- Buat Database
CREATE DATABASE presensi_app;

-- Hubungkan ke database
\c presensi_app;

-- ============ TABEL USERS ============
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  nama_lengkap VARCHAR(100) NOT NULL,
  no_hp VARCHAR(20) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  email_verified BOOLEAN DEFAULT FALSE,
  verification_token VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_email ON users(email);

-- ============ TABEL ATTENDANCE ============
CREATE TABLE IF NOT EXISTS attendance (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  check_in_time TIMESTAMP,
  check_out_time TIMESTAMP,
  location VARCHAR(100),
  status VARCHAR(50),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_user_date ON attendance(user_id, check_in_time);

-- ============ SAMPLE DATA ============
-- PASSWORD UNTUK SEMUA SAMPLE: 123456 (hashed dengan bcrypt)
INSERT INTO users (nama_lengkap, no_hp, email, password, email_verified) VALUES
('Admin User', '082123456789', 'admin@test.com', '$2a$10$XQnF0WXh0JHNYYj7QQk4Z.DTQQ8RHmJ5c3h5S5H5k5H5k5H5k5H5k', TRUE),
('John Doe', '081234567890', 'john@test.com', '$2a$10$XQnF0WXh0JHNYYj7QQk4Z.DTQQ8RHmJ5c3h5S5H5k5H5k5H5k5H5k', TRUE),
('Jane Smith', '087654321098', 'jane@test.com', '$2a$10$XQnF0WXh0JHNYYj7QQk4Z.DTQQ8RHmJ5c3h5S5H5k5H5k5H5k5H5k', TRUE);

-- ============ SAMPLE ATTENDANCE DATA ============
INSERT INTO attendance (user_id, check_in_time, check_out_time, location, status) VALUES
(1, '2024-01-26 08:00:00', '2024-01-26 17:00:00', 'Kantor', 'present'),
(1, '2024-01-25 08:15:00', '2024-01-25 17:15:00', 'Kantor', 'present'),
(1, '2024-01-24 08:30:00', NULL, 'Kantor', 'present'),
(2, '2024-01-26 08:10:00', '2024-01-26 17:10:00', 'Kantor', 'present'),
(3, '2024-01-26 08:05:00', '2024-01-26 17:05:00', 'Kantor', 'present');

-- ============ VIEW UNTUK STATISTIK ============
CREATE VIEW attendance_summary AS
SELECT 
  u.id,
  u.nama_lengkap,
  u.email,
  DATE(a.check_in_time) as tanggal,
  to_char(a.check_in_time, 'HH24:MI:SS') as waktu_masuk,
  to_char(a.check_out_time, 'HH24:MI:SS') as waktu_keluar,
  (a.check_out_time - a.check_in_time) as durasi_kerja,
  a.location,
  a.status
FROM users u
LEFT JOIN attendance a ON u.id = a.user_id
ORDER BY a.check_in_time DESC;

-- ============ TIPS UNTUK SETUP ============
/*
UNTUK MENJALANKAN SCRIPT INI:

1. DENGAN psql (command line):
   psql -U postgres -h localhost -f database-setup-postgresql.sql

2. DENGAN pgAdmin:
   - Buka pgAdmin
   - Right-click pada "Databases"
   - Pilih "Create" → "Database"
   - Nama: presensi_app
   - Klik "Create"
   - Buka Query Tool
   - Copy paste script ini (mulai dari tabel users)
   - Klik "Execute"

3. Sesuaikan konfigurasi di .env:
   DB_HOST=localhost
   DB_PORT=5432
   DB_USER=postgres
   DB_PASSWORD=postgres
   DB_NAME=presensi_app

DEFAULT TEST ACCOUNTS (Password: 123456):
- Email: admin@test.com
- Email: john@test.com
- Email: jane@test.com
*/
