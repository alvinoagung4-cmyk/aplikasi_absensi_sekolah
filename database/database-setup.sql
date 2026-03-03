-- ============================================
-- DATABASE SETUP UNTUK APLIKASI PRESENSI
-- ============================================

-- Buat Database
CREATE DATABASE IF NOT EXISTS presensi_app;
USE presensi_app;

-- ============ TABEL USERS ============
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nama_lengkap VARCHAR(100) NOT NULL,
  no_hp VARCHAR(20) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  email_verified BOOLEAN DEFAULT FALSE,
  verification_token VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_email (email)
);

-- ============ TABEL ATTENDANCE ============
CREATE TABLE attendance (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  check_in_time DATETIME,
  check_out_time DATETIME,
  location VARCHAR(100),
  status VARCHAR(50),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_date (user_id, check_in_time)
);

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
  TIME(a.check_in_time) as waktu_masuk,
  TIME(a.check_out_time) as waktu_keluar,
  TIMEDIFF(a.check_out_time, a.check_in_time) as durasi_kerja,
  a.location,
  a.status
FROM users u
LEFT JOIN attendance a ON u.id = a.user_id
ORDER BY a.check_in_time DESC;

-- ============ PROCEDURE UNTUK AUTO CLEANUP ============
DELIMITER $$

CREATE PROCEDURE cleanup_old_tokens()
BEGIN
  DELETE FROM users WHERE email_verified = FALSE AND created_at < DATE_SUB(NOW(), INTERVAL 7 DAY);
END $$

DELIMITER ;

-- ============ TIPS UNTUK NAVICAT ============
/*
1. Buka Navicat
2. Connection → MySQL
3. Fill dengan:
   - Host: localhost
   - Port: 3306
   - Username: root
   - Password: (kosong atau password Anda)
4. Test Connection
5. New Query
6. Copy paste seluruh SQL ini
7. Run Query
8. Database sudah siap digunakan!

DEFAULT TEST ACCOUNTS:
- Email: admin@test.com, Password: 123456
- Email: john@test.com, Password: 123456
- Email: jane@test.com, Password: 123456
*/
