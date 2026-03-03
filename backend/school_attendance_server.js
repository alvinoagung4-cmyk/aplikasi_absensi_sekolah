const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');
const axios = require('axios');
require('dotenv').config();

const app = express();

// ============ MIDDLEWARE ============
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  credentials: true
}));
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// ============ DATABASE CONNECTION ============
let pool;

if (process.env.DATABASE_URL) {
  pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
  });
  console.log('✅ Using Railway Cloud Database');
} else {
  pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
    database: process.env.DB_NAME || 'presensi_raliway',
    port: process.env.DB_PORT || 5433,
  });
  console.log('✅ Using Local PostgreSQL Database');
}

pool.connect()
  .then(client => {
    console.log('✅ Database connected successfully');
    client.release();
  })
  .catch(err => console.error('❌ Database error:', err.message));

// ============ EMAIL SETUP ============
const transporter = nodemailer.createTransport({
  service: process.env.EMAIL_SERVICE || 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS
  }
});

// ============ WHATSAPP SETUP (menggunakan Twilio) ============
const twilioAccountSid = process.env.TWILIO_ACCOUNT_SID;
const twilioAuthToken = process.env.TWILIO_AUTH_TOKEN;
const twilioPhoneNumber = process.env.TWILIO_PHONE_NUMBER;

// ============ MIDDLEWARE VERIFIKASI JWT ============
const verifyToken = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) {
    return res.status(401).json({ success: false, message: 'Token tidak ditemukan' });
  }
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key');
    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({ success: false, message: 'Token tidak valid' });
  }
};

// ============ FUNGSI HELPER ============

// Kirim Email
const sendEmail = async (to, subject, html) => {
  try {
    await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to,
      subject,
      html
    });
    return true;
  } catch (error) {
    console.error('Error sending email:', error);
    return false;
  }
};

// Kirim WhatsApp (Twilio)
const sendWhatsApp = async (to, message) => {
  try {
    if (!twilioAccountSid || !twilioAuthToken || !twilioPhoneNumber) {
      console.warn('⚠️ Twilio configuration not complete');
      return false;
    }

    const url = `https://api.twilio.com/2010-04-01/Accounts/${twilioAccountSid}/Messages.json`;
    const response = await axios.post(url, {
      From: `whatsapp:${twilioPhoneNumber}`,
      To: `whatsapp:${to}`,
      Body: message
    }, {
      auth: {
        username: twilioAccountSid,
        password: twilioAuthToken
      }
    });
    
    return response.status === 201;
  } catch (error) {
    console.error('Error sending WhatsApp:', error.message);
    return false;
  }
};

// Generate JWT Token
const generateToken = (user) => {
  return jwt.sign(
    { 
      id: user.id, 
      user_type: user.user_type,
      nama_lengkap: user.nama_lengkap,
      email: user.email
    },
    process.env.JWT_SECRET || 'your-secret-key',
    { expiresIn: '7d' }
  );
};

// ============ HEALTH CHECK ============
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// ============ AUTH ENDPOINTS ============

// Register
app.post('/api/auth/register', async (req, res) => {
  try {
    const { nama_lengkap, email, no_hp, password, konfirmasi_password, user_type } = req.body;

    if (!nama_lengkap || !email || !no_hp || !password) {
      return res.status(400).json({ success: false, message: 'Semua field harus diisi' });
    }

    if (password !== konfirmasi_password) {
      return res.status(400).json({ success: false, message: 'Password tidak cocok' });
    }

    // Cek email sudah ada
    const checkEmail = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
    if (checkEmail.rows.length > 0) {
      return res.status(400).json({ success: false, message: 'Email sudah terdaftar' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert user
    const result = await pool.query(
      'INSERT INTO users (user_type, nama_lengkap, email, no_hp, password, email_verified) VALUES ($1, $2, $3, $4, $5, TRUE) RETURNING *',
      [user_type || 'student', nama_lengkap, email, no_hp, hashedPassword]
    );

    const token = generateToken(result.rows[0]);

    res.status(201).json({
      success: true,
      message: 'Registrasi berhasil',
      token,
      user: result.rows[0]
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ success: false, message: 'Registrasi gagal: ' + error.message });
  }
});

// Login
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Email dan password harus diisi' });
    }

    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (result.rows.length === 0) {
      return res.status(401).json({ success: false, message: 'Email atau password salah' });
    }

    const user = result.rows[0];
    const passwordMatch = await bcrypt.compare(password, user.password);
    if (!passwordMatch) {
      return res.status(401).json({ success: false, message: 'Email atau password salah' });
    }

    if (!user.is_active) {
      return res.status(401).json({ success: false, message: 'Akun Anda tidak aktif' });
    }

    const token = generateToken(user);

    res.json({
      success: true,
      message: 'Login berhasil',
      token,
      user: {
        id: user.id,
        user_type: user.user_type,
        nama_lengkap: user.nama_lengkap,
        email: user.email,
        no_hp: user.no_hp,
        nis: user.nis
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ success: false, message: 'Login gagal' });
  }
});

// Get Profile
app.get('/api/users/profile', verifyToken, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM users WHERE id = $1', [req.user.id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'User tidak ditemukan' });
    }

    const user = result.rows[0];
    delete user.password;
    res.json({ success: true, user });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Gagal mengambil profil' });
  }
});

// ============ ATTENDANCE ENDPOINTS ============

// Check-in
app.post('/api/attendance/check-in', verifyToken, async (req, res) => {
  try {
    const { class_id, latitude, longitude, foto_base64 } = req.body;
    const student_id = req.user.id;
    const tanggal = new Date().toISOString().split('T')[0];
    const check_in_time = new Date();

    // Cek apakah sudah ada check-in hari ini
    const existing = await pool.query(
      'SELECT id FROM attendance_records WHERE student_id = $1 AND tanggal = $2',
      [student_id, tanggal]
    );

    let attendanceId;
    if (existing.rows.length > 0) {
      attendanceId = existing.rows[0].id;
    } else {
      const result = await pool.query(
        'INSERT INTO attendance_records (student_id, class_id, tanggal, check_in_time, status) VALUES ($1, $2, $3, $4, $5) RETURNING id',
        [student_id, class_id, tanggal, check_in_time, 'present']
      );
      attendanceId = result.rows[0].id;
    }

    // Kirim notifikasi ke orang tua
    await sendAttendanceNotification(student_id, 'datang', check_in_time);

    res.json({
      success: true,
      message: 'Check-in berhasil',
      attendance_id: attendanceId
    });
  } catch (error) {
    console.error('Check-in error:', error);
    res.status(500).json({ success: false, message: 'Check-in gagal' });
  }
});

// Check-out
app.post('/api/attendance/check-out', verifyToken, async (req, res) => {
  try {
    const { attendance_id, latitude, longitude, foto_base64 } = req.body;
    const check_out_time = new Date();

    const result = await pool.query(
      'UPDATE attendance_records SET check_out_time = $1 WHERE id = $2 RETURNING *',
      [check_out_time, attendance_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Attendance record tidak ditemukan' });
    }

    // Kirim notifikasi ke orang tua
    await sendAttendanceNotification(result.rows[0].student_id, 'pulang', check_out_time);

    res.json({
      success: true,
      message: 'Check-out berhasil'
    });
  } catch (error) {
    console.error('Check-out error:', error);
    res.status(500).json({ success: false, message: 'Check-out gagal' });
  }
});

// Get Attendance Records
app.get('/api/attendance/records', verifyToken, async (req, res) => {
  try {
    const { bulan, tahun, student_id } = req.query;
    const userId = student_id || req.user.id;

    let query = 'SELECT * FROM attendance_records WHERE student_id = $1';
    let params = [userId];

    if (bulan && tahun) {
      query += ` AND EXTRACT(MONTH FROM tanggal) = $2 AND EXTRACT(YEAR FROM tanggal) = $3`;
      params.push(bulan, tahun);
    }

    query += ' ORDER BY tanggal DESC';

    const result = await pool.query(query, params);
    res.json({ success: true, records: result.rows });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Gagal mengambil data presensi' });
  }
});

// Get Attendance Summary/Recap
app.get('/api/attendance/recap', verifyToken, async (req, res) => {
  try {
    const { bulan, tahun, student_id } = req.query;
    const userId = student_id || req.user.id;

    const result = await pool.query(`
      SELECT 
        COUNT(*) as total_hari,
        COUNT(CASE WHEN status = 'present' THEN 1 END) as hadir,
        COUNT(CASE WHEN status = 'absent' THEN 1 END) as absent,
        COUNT(CASE WHEN status = 'sick' THEN 1 END) as sakit,
        COUNT(CASE WHEN status = 'permission' THEN 1 END) as izin,
        COUNT(CASE WHEN status = 'late' THEN 1 END) as terlambat
      FROM attendance_records 
      WHERE student_id = $1 
      AND EXTRACT(MONTH FROM tanggal) = $2 
      AND EXTRACT(YEAR FROM tanggal) = $3`,
      [userId, bulan, tahun]
    );

    res.json({ success: true, recap: result.rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Gagal mengambil recap presensi' });
  }
});

// ============ ACTIVITY JOURNAL ENDPOINTS ============

// Create Activity Journal
app.post('/api/activity-journal', verifyToken, async (req, res) => {
  try {
    const { judul_kegiatan, deskripsi_kegiatan, mata_pelajaran, lokasi, total_peserta } = req.body;
    const student_id = req.user.id;
    const tanggal = new Date().toISOString().split('T')[0];

    const result = await pool.query(
      `INSERT INTO activity_journals (student_id, tanggal, judul_kegiatan, deskripsi_kegiatan, mata_pelajaran, lokasi, total_peserta, status)
       VALUES ($1, $2, $3, $4, $5, $6, $7, 'draft')
       RETURNING *`,
      [student_id, tanggal, judul_kegiatan, deskripsi_kegiatan, mata_pelajaran, lokasi, total_peserta]
    );

    res.status(201).json({
      success: true,
      message: 'Jurnal kegiatan berhasil dibuat',
      activity: result.rows[0]
    });
  } catch (error) {
    console.error('Activity creation error:', error);
    res.status(500).json({ success: false, message: 'Gagal membuat jurnal kegiatan' });
  }
});

// Upload Activity Photo
app.post('/api/activity-journal/:activity_id/photos', verifyToken, async (req, res) => {
  try {
    const { activity_id } = req.params;
    const { photo_base64, keterangan, photo_order } = req.body;

    // Simpan foto (dalam implementasi nyata, gunakan cloud storage seperti AWS S3)
    // Untuk demo, simpan base64 langsung
    const photo_url = `data:image/jpeg;base64,${photo_base64}`;

    const result = await pool.query(
      'INSERT INTO activity_photos (activity_journal_id, photo_url, keterangan, photo_order) VALUES ($1, $2, $3, $4) RETURNING *',
      [activity_id, photo_url, keterangan, photo_order || 1]
    );

    res.status(201).json({
      success: true,
      message: 'Foto berhasil diunggah',
      photo: result.rows[0]
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Gagal mengunggah foto' });
  }
});

// Get Activity Journals
app.get('/api/activity-journal', verifyToken, async (req, res) => {
  try {
    const { bulan, tahun, student_id } = req.query;
    const userId = student_id || req.user.id;

    let query = `
      SELECT aj.*, 
             json_agg(json_build_object('id', ap.id, 'photo_url', ap.photo_url, 'keterangan', ap.keterangan)) as photos
      FROM activity_journals aj
      LEFT JOIN activity_photos ap ON aj.id = ap.activity_journal_id
      WHERE aj.student_id = $1`;

    let params = [userId];

    if (bulan && tahun) {
      query += ` AND EXTRACT(MONTH FROM aj.tanggal) = $2 AND EXTRACT(YEAR FROM aj.tanggal) = $3`;
      params.push(bulan, tahun);
    }

    query += ' GROUP BY aj.id ORDER BY aj.tanggal DESC';

    const result = await pool.query(query, params);
    res.json({ success: true, journals: result.rows });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Gagal mengambil jurnal kegiatan' });
  }
});

// Submit Activity Journal
app.put('/api/activity-journal/:activity_id/submit', verifyToken, async (req, res) => {
  try {
    const { activity_id } = req.params;

    const result = await pool.query(
      'UPDATE activity_journals SET status = $1 WHERE id = $2 RETURNING *',
      ['submitted', activity_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Jurnal tidak ditemukan' });
    }

    res.json({
      success: true,
      message: 'Jurnal berhasil disubmit',
      activity: result.rows[0]
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Gagal submit jurnal' });
  }
});

// ============ PARENT CONTACT ENDPOINTS ============

app.post('/api/parent-contact', verifyToken, async (req, res) => {
  try {
    const { student_id, parent_name, parent_phone, parent_email, relationship } = req.body;

    const result = await pool.query(
      `INSERT INTO parent_contact (student_id, parent_name, parent_phone, parent_email, relationship, whatsapp_enabled, email_enabled)
       VALUES ($1, $2, $3, $4, $5, TRUE, TRUE)
       RETURNING *`,
      [student_id, parent_name, parent_phone, parent_email, relationship]
    );

    res.status(201).json({
      success: true,
      message: 'Kontak orang tua berhasil ditambahkan',
      parent_contact: result.rows[0]
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Gagal menambahkan kontak orang tua' });
  }
});

app.get('/api/parent-contact/:student_id', verifyToken, async (req, res) => {
  try {
    const { student_id } = req.params;

    const result = await pool.query(
      'SELECT * FROM parent_contact WHERE student_id = $1',
      [student_id]
    );

    res.json({ success: true, contacts: result.rows });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Gagal mengambil kontak orang tua' });
  }
});

// ============ NOTIFICATION HELPER ============
async function sendAttendanceNotification(student_id, status, time) {
  try {
    // Dapatkan data siswa
    const studentResult = await pool.query(
      'SELECT nama_lengkap FROM users WHERE id = $1',
      [student_id]
    );

    if (studentResult.rows.length === 0) return;

    const studentName = studentResult.rows[0].nama_lengkap;
    const timeStr = new Date(time).toLocaleTimeString('id-ID');
    const statusLabel = status === 'datang' ? 'hadir' : 'pulang';

    const message = `📲 Notifikasi Presensi\n\n${studentName} telah ${statusLabel} di sekolah pada pukul ${timeStr}.\n\nTerimakasih.`;

    // Dapatkan kontak orang tua
    const parentResult = await pool.query(
      'SELECT * FROM parent_contact WHERE student_id = $1 AND (whatsapp_enabled = TRUE OR email_enabled = TRUE)',
      [student_id]
    );

    // Kirim ke semua kontak orang tua
    for (const parent of parentResult.rows) {
      // Kirim WhatsApp
      if (parent.whatsapp_enabled && parent.parent_phone) {
        const phoneSanitized = parent.parent_phone.replace(/\D/g, '');
        const whatsappNo = phoneSanitized.startsWith('62') ? `+${phoneSanitized}` : `+62${phoneSanitized.substring(1)}`;
        
        await sendWhatsApp(whatsappNo, message);

        // Log notification
        await pool.query(
          'INSERT INTO notification_logs (student_id, parent_id, notification_type, recipient, message, status, check_in_status, check_in_time) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)',
          [student_id, parent.parent_id || null, 'whatsapp', whatsappNo, message, 'sent', status, time]
        );
      }

      // Kirim Email
      if (parent.email_enabled && parent.parent_email) {
        const emailHtml = `
          <div style="font-family: Arial; max-width: 600px; margin: auto; padding: 20px;">
            <h2 style="color: #2196F3;">Notifikasi Presensi Sekolah</h2>
            <p>Halo ${parent.parent_name},</p>
            <p>Kami informasikan bahwa:</p>
            <div style="background: #f0f0f0; padding: 15px; border-radius: 5px; margin: 15px 0;">
              <p><strong>${studentName}</strong> telah <strong>${statusLabel}</strong> di sekolah pada pukul <strong>${timeStr}</strong></p>
            </div>
            <p style="color: #666; font-size: 12px; margin-top: 20px;">Terima kasih,<br>Sistem Presensi Sekolah</p>
          </div>
        `;

        await sendEmail(parent.parent_email, `Notifikasi Presensi: ${studentName}`, emailHtml);

        await pool.query(
          'INSERT INTO notification_logs (student_id, parent_id, notification_type, recipient, message, status, check_in_status, check_in_time) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)',
          [student_id, parent.parent_id || null, 'email', parent.parent_email, emailHtml, 'sent', status, time]
        );
      }
    }
  } catch (error) {
    console.error('Error sending notification:', error);
  }
}

// ============ START SERVER ============
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`✅ Server berjalan di port ${PORT}`);
});

module.exports = app;
