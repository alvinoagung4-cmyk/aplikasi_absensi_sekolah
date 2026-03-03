-- =============================================
-- PostgreSQL Complete Attendance System Initialization
-- For Railway PostgreSQL Database
-- =============================================
-- This script sets up the complete attendance system with all tables,
-- indexes, views, and sample data. Run this AFTER creating the main schema.
-- =============================================

-- =============================================
-- 1. CREATE ATTENDANCE TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS attendance (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    siswa_id INTEGER,
    kelas_id INTEGER,
    check_in_time TIMESTAMP,
    check_out_time TIMESTAMP,
    date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'present', -- present, late, absent, sick, permit
    location VARCHAR(100),
    check_in_latitude DECIMAL(10, 8),
    check_in_longitude DECIMAL(11, 8),
    check_out_latitude DECIMAL(10, 8),
    check_out_longitude DECIMAL(11, 8),
    face_confidence DECIMAL(5, 2),
    qr_code VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (siswa_id) REFERENCES siswa(id) ON DELETE SET NULL,
    FOREIGN KEY (kelas_id) REFERENCES kelas(id) ON DELETE SET NULL
);

-- =============================================
-- 2. CREATE ATTENDANCE SUMMARY TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS attendance_summary (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    siswa_id INTEGER,
    kelas_id INTEGER,
    month INTEGER NOT NULL,
    year INTEGER NOT NULL,
    total_present INTEGER DEFAULT 0,
    total_late INTEGER DEFAULT 0,
    total_absent INTEGER DEFAULT 0,
    total_sick INTEGER DEFAULT 0,
    total_permit INTEGER DEFAULT 0,
    total_working_days INTEGER DEFAULT 0,
    attendance_percentage DECIMAL(5, 2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (siswa_id) REFERENCES siswa(id) ON DELETE SET NULL,
    FOREIGN KEY (kelas_id) REFERENCES kelas(id) ON DELETE SET NULL,
    UNIQUE(user_id, month, year)
);

-- =============================================
-- 3. CREATE INDEXES FOR PERFORMANCE
-- =============================================
CREATE INDEX IF NOT EXISTS idx_attendance_user_id ON attendance(user_id);
CREATE INDEX IF NOT EXISTS idx_attendance_siswa_id ON attendance(siswa_id);
CREATE INDEX IF NOT EXISTS idx_attendance_kelas_id ON attendance(kelas_id);
CREATE INDEX IF NOT EXISTS idx_attendance_date ON attendance(date);
CREATE INDEX IF NOT EXISTS idx_attendance_status ON attendance(status);
CREATE INDEX IF NOT EXISTS idx_attendance_user_date ON attendance(user_id, date);
CREATE INDEX IF NOT EXISTS idx_attendance_deleted_at ON attendance(deleted_at);
CREATE INDEX IF NOT EXISTS idx_attendance_check_in_time ON attendance(check_in_time);
CREATE INDEX IF NOT EXISTS idx_attendance_check_out_time ON attendance(check_out_time);

CREATE INDEX IF NOT EXISTS idx_summary_user_id ON attendance_summary(user_id);
CREATE INDEX IF NOT EXISTS idx_summary_siswa_id ON attendance_summary(siswa_id);
CREATE INDEX IF NOT EXISTS idx_summary_kelas_id ON attendance_summary(kelas_id);
CREATE INDEX IF NOT EXISTS idx_summary_user_month ON attendance_summary(user_id, month, year);
CREATE INDEX IF NOT EXISTS idx_summary_month_year ON attendance_summary(month, year);

-- =============================================
-- 4. CREATE VIEWS FOR EASY DATA ACCESS
-- =============================================

-- View: Attendance detail with user and student information
CREATE OR REPLACE VIEW v_attendance_detail AS
SELECT
  a.id,
  a.user_id,
  a.siswa_id,
  a.kelas_id,
  u.username,
  u.nama_lengkap,
  s.nama_siswa,
  k.nama_kelas,
  a.check_in_time,
  a.check_out_time,
  a.date,
  a.status,
  a.location,
  a.face_confidence,
  a.qr_code,
  a.notes,
  a.created_at,
  a.updated_at,
  CASE 
    WHEN a.check_out_time IS NOT NULL 
    THEN EXTRACT(EPOCH FROM (a.check_out_time - a.check_in_time))/3600 
    ELSE NULL 
  END as duration_hours
FROM attendance a
LEFT JOIN users u ON a.user_id = u.id
LEFT JOIN siswa s ON a.siswa_id = s.id
LEFT JOIN kelas k ON a.kelas_id = k.id
WHERE a.deleted_at IS NULL;

-- View: Daily attendance summary by class
CREATE OR REPLACE VIEW v_daily_attendance_summary AS
SELECT
  a.date,
  a.kelas_id,
  k.nama_kelas,
  COUNT(*) as total_students,
  COUNT(*) FILTER (WHERE a.status = 'present' OR a.status = 'late') as present_students,
  COUNT(*) FILTER (WHERE a.status = 'present') as on_time_students,
  COUNT(*) FILTER (WHERE a.status = 'late') as late_students,
  COUNT(*) FILTER (WHERE a.status = 'absent') as absent_students,
  COUNT(*) FILTER (WHERE a.status = 'sick') as sick_students,
  COUNT(*) FILTER (WHERE a.status = 'permit') as permit_students,
  ROUND(
    COUNT(*) FILTER (WHERE a.status = 'present' OR a.status = 'late')::DECIMAL / 
    NULLIF(COUNT(*), 0) * 100, 2
  ) as attendance_percentage
FROM attendance a
LEFT JOIN kelas k ON a.kelas_id = k.id
WHERE a.deleted_at IS NULL
GROUP BY a.date, a.kelas_id, k.nama_kelas;

-- View: Monthly attendance summary by student
CREATE OR REPLACE VIEW v_monthly_attendance_summary AS
SELECT
  a.user_id,
  s.nama_siswa,
  k.nama_kelas,
  EXTRACT(MONTH FROM a.date) as month,
  EXTRACT(YEAR FROM a.date) as year,
  COUNT(*) as total_days,
  COUNT(*) FILTER (WHERE a.status = 'present') as total_present,
  COUNT(*) FILTER (WHERE a.status = 'late') as total_late,
  COUNT(*) FILTER (WHERE a.status = 'absent') as total_absent,
  COUNT(*) FILTER (WHERE a.status = 'sick') as total_sick,
  COUNT(*) FILTER (WHERE a.status = 'permit') as total_permit,
  COUNT(*) FILTER (WHERE a.status = 'present' OR a.status = 'late') as total_attended,
  ROUND(
    COUNT(*) FILTER (WHERE a.status = 'present' OR a.status = 'late')::DECIMAL / 
    NULLIF(COUNT(*), 0) * 100, 2
  ) as attendance_percentage
FROM attendance a
LEFT JOIN siswa s ON a.siswa_id = s.id
LEFT JOIN kelas k ON a.kelas_id = k.id
WHERE a.deleted_at IS NULL
GROUP BY a.user_id, s.nama_siswa, k.nama_kelas, EXTRACT(MONTH FROM a.date), EXTRACT(YEAR FROM a.date);

-- =============================================
-- 5. INSERT SAMPLE DATA (Optional - for testing)
-- =============================================
-- This assumes you have at least one user and one student already in the database
-- Uncomment and modify the dates/IDs as needed for your testing

-- Sample attendance records
INSERT INTO attendance (
  user_id, siswa_id, kelas_id, check_in_time, check_out_time, 
  date, status, location, notes
)
SELECT
  u.id as user_id,
  s.id as siswa_id,
  k.id as kelas_id,
  (CURRENT_DATE - INTERVAL '5 days' + INTERVAL '7 hours 30 minutes')::TIMESTAMP,
  (CURRENT_DATE - INTERVAL '5 days' + INTERVAL '14 hours')::TIMESTAMP,
  CURRENT_DATE - INTERVAL '5 days',
  'present',
  'Kantor',
  'Presensi normal'
FROM users u, siswa s, kelas k
WHERE u.role = 'siswa' LIMIT 1
ON CONFLICT DO NOTHING;

INSERT INTO attendance (
  user_id, siswa_id, kelas_id, check_in_time, check_out_time, 
  date, status, location, notes
)
SELECT
  u.id as user_id,
  s.id as siswa_id,
  k.id as kelas_id,
  (CURRENT_DATE - INTERVAL '4 days' + INTERVAL '8 hours 15 minutes')::TIMESTAMP,
  (CURRENT_DATE - INTERVAL '4 days' + INTERVAL '14 hours 30 minutes')::TIMESTAMP,
  CURRENT_DATE - INTERVAL '4 days',
  'late',
  'Kantor',
  'Terlambat 45 menit'
FROM users u, siswa s, kelas k
WHERE u.role = 'siswa' LIMIT 1
ON CONFLICT DO NOTHING;

INSERT INTO attendance (
  user_id, siswa_id, kelas_id, check_in_time, check_out_time, 
  date, status, location, notes
)
SELECT
  u.id as user_id,
  s.id as siswa_id,
  k.id as kelas_id,
  NULL,
  NULL,
  CURRENT_DATE - INTERVAL '3 days',
  'sick',
  NULL,
  'Surat keterangan sakit'
FROM users u, siswa s, kelas k
WHERE u.role = 'siswa' LIMIT 1
ON CONFLICT DO NOTHING;

-- =============================================
-- 6. CREATE TRIGGER FUNCTION FOR SOFT DELETE
-- =============================================
CREATE OR REPLACE FUNCTION update_attendance_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger if it doesn't exist
DROP TRIGGER IF EXISTS trigger_update_attendance_timestamp ON attendance;
CREATE TRIGGER trigger_update_attendance_timestamp
BEFORE UPDATE ON attendance
FOR EACH ROW
EXECUTE FUNCTION update_attendance_timestamp();

-- =============================================
-- 7. GRANT PERMISSIONS (if needed for specific user)
-- =============================================
-- Uncomment and modify if you need to grant permissions to a specific database user
-- GRANT SELECT, INSERT, UPDATE, DELETE ON attendance TO your_user;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON attendance_summary TO your_user;
-- GRANT SELECT ON v_attendance_detail TO your_user;
-- GRANT SELECT ON v_daily_attendance_summary TO your_user;
-- GRANT SELECT ON v_monthly_attendance_summary TO your_user;

-- =============================================
-- END OF ATTENDANCE INITIALIZATION SCRIPT
-- Run this script once to set up the complete attendance system
-- =============================================

-- Verification queries (run these to verify the setup)
-- SELECT COUNT(*) as attendance_count FROM attendance;
-- SELECT COUNT(*) as summary_count FROM attendance_summary;
-- SELECT * FROM v_attendance_detail LIMIT 5;
-- SELECT * FROM information_schema.tables WHERE table_name LIKE 'attendance%';
