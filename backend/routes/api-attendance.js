// backend/routes/api-attendance.js - Routes untuk Attendance/Presensi Data
const express = require('express');
const router = express.Router();

function setPool(pool) {
  router.pool = pool;
}

// ============ GET ATTENDANCE HISTORY BY USER ID ============
router.get('/history/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { start_date, end_date } = req.query;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'User ID is required'
      });
    }

    let query = `
      SELECT a.*, s.nama_siswa, k.nama_kelas
      FROM attendance a
      LEFT JOIN siswa s ON a.siswa_id = s.id
      LEFT JOIN kelas k ON a.kelas_id = k.id
      WHERE a.user_id = $1 AND a.deleted_at IS NULL
    `;

    const params = [userId];
    let paramIndex = 2;

    if (start_date) {
      query += ` AND a.date >= $${paramIndex}`;
      params.push(start_date);
      paramIndex++;
    }

    if (end_date) {
      query += ` AND a.date <= $${paramIndex}`;
      params.push(end_date);
      paramIndex++;
    }

    query += ' ORDER BY a.date DESC, a.check_in_time DESC';

    const results = await router.pool.query(query, params);

    res.status(200).json({
      success: true,
      message: 'Attendance history retrieved successfully',
      data: results.rows,
      count: results.rows.length
    });
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching attendance history',
      error: error.message
    });
  }
});

// ============ GET TODAY'S ATTENDANCE BY USER ID ============
router.get('/today/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'User ID is required'
      });
    }

    const query = `
      SELECT a.*, s.nama_siswa, k.nama_kelas
      FROM attendance a
      LEFT JOIN siswa s ON a.siswa_id = s.id
      LEFT JOIN kelas k ON a.kelas_id = k.id
      WHERE a.user_id = $1 
      AND DATE(a.date) = CURRENT_DATE
      AND a.deleted_at IS NULL
      ORDER BY a.check_in_time DESC
      LIMIT 1
    `;

    const results = await router.pool.query(query, [userId]);

    if (results.rows.length === 0) {
      return res.status(200).json({
        success: true,
        message: 'No attendance record for today',
        data: null
      });
    }

    res.status(200).json({
      success: true,
      message: 'Today attendance retrieved successfully',
      data: results.rows[0]
    });
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching today attendance',
      error: error.message
    });
  }
});

// ============ GET ATTENDANCE STATISTICS BY USER ID ============
router.get('/statistics/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { month, year } = req.query;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'User ID is required'
      });
    }

    const currentDate = new Date();
    const queryMonth = month || currentDate.getMonth() + 1;
    const queryYear = year || currentDate.getFullYear();

    const statisticsQuery = `
      SELECT 
        user_id,
        month,
        year,
        total_present,
        total_late,
        total_absent,
        total_sick,
        total_permit,
        total_working_days,
        attendance_percentage
      FROM attendance_summary
      WHERE user_id = $1 
      AND month = $2 
      AND year = $3
    `;

    const statsResult = await router.pool.query(statisticsQuery, [
      userId,
      queryMonth,
      queryYear
    ]);

    // If no summary exists, calculate from attendance records
    if (statsResult.rows.length === 0) {
      const calcQuery = `
        SELECT
          COUNT(*) FILTER (WHERE status = 'present') as total_present,
          COUNT(*) FILTER (WHERE status = 'late') as total_late,
          COUNT(*) FILTER (WHERE status = 'absent') as total_absent,
          COUNT(*) FILTER (WHERE status = 'sick') as total_sick,
          COUNT(*) FILTER (WHERE status = 'permit') as total_permit,
          COUNT(*) as total_working_days,
          ROUND(
            COUNT(*) FILTER (WHERE status IN ('present', 'late'))::DECIMAL / 
            NULLIF(COUNT(*), 0) * 100, 2
          ) as attendance_percentage
        FROM attendance
        WHERE user_id = $1
        AND EXTRACT(MONTH FROM date) = $2
        AND EXTRACT(YEAR FROM date) = $3
        AND deleted_at IS NULL
      `;

      const calcResult = await router.pool.query(calcQuery, [
        userId,
        queryMonth,
        queryYear
      ]);

      return res.status(200).json({
        success: true,
        message: 'Attendance statistics retrieved successfully',
        data: {
          user_id: userId,
          month: parseInt(queryMonth),
          year: parseInt(queryYear),
          ...calcResult.rows[0]
        }
      });
    }

    res.status(200).json({
      success: true,
      message: 'Attendance statistics retrieved successfully',
      data: statsResult.rows[0]
    });
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching attendance statistics',
      error: error.message
    });
  }
});

// ============ CREATE ATTENDANCE RECORD ============
router.post('/', async (req, res) => {
  try {
    const {
      user_id,
      siswa_id,
      kelas_id,
      check_in_time,
      check_out_time,
      date,
      status,
      location,
      face_confidence,
      qr_code,
      notes
    } = req.body;

    if (!user_id || !date || !status) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: user_id, date, status'
      });
    }

    const query = `
      INSERT INTO attendance (
        user_id, siswa_id, kelas_id, check_in_time, check_out_time,
        date, status, location, face_confidence, qr_code, notes
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
      RETURNING *
    `;

    const results = await router.pool.query(query, [
      user_id,
      siswa_id || null,
      kelas_id || null,
      check_in_time || null,
      check_out_time || null,
      date,
      status,
      location || null,
      face_confidence || null,
      qr_code || null,
      notes || null
    ]);

    res.status(201).json({
      success: true,
      message: 'Attendance created successfully',
      data: results.rows[0]
    });
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({
      success: false,
      message: 'Error creating attendance',
      error: error.message
    });
  }
});

// ============ UPDATE ATTENDANCE RECORD ============
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const {
      check_in_time,
      check_out_time,
      status,
      location,
      face_confidence,
      qr_code,
      notes
    } = req.body;

    const query = `
      UPDATE attendance
      SET
        check_in_time = COALESCE($1, check_in_time),
        check_out_time = COALESCE($2, check_out_time),
        status = COALESCE($3, status),
        location = COALESCE($4, location),
        face_confidence = COALESCE($5, face_confidence),
        qr_code = COALESCE($6, qr_code),
        notes = COALESCE($7, notes),
        updated_at = CURRENT_TIMESTAMP
      WHERE id = $8 AND deleted_at IS NULL
      RETURNING *
    `;

    const results = await router.pool.query(query, [
      check_in_time || null,
      check_out_time || null,
      status || null,
      location || null,
      face_confidence || null,
      qr_code || null,
      notes || null,
      id
    ]);

    if (results.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Attendance record not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Attendance updated successfully',
      data: results.rows[0]
    });
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating attendance',
      error: error.message
    });
  }
});

// ============ DELETE ATTENDANCE RECORD (SOFT DELETE) ============
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const query = `
      UPDATE attendance
      SET deleted_at = CURRENT_TIMESTAMP
      WHERE id = $1 AND deleted_at IS NULL
      RETURNING id
    `;

    const results = await router.pool.query(query, [id]);

    if (results.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Attendance record not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Attendance deleted successfully'
    });
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting attendance',
      error: error.message
    });
  }
});

// ============ GET ATTENDANCE BY KELAS ID ============
router.get('/kelas/:kelasId', async (req, res) => {
  try {
    const { kelasId } = req.params;
    const { date } = req.query;

    if (!kelasId) {
      return res.status(400).json({
        success: false,
        message: 'Kelas ID is required'
      });
    }

    let query = `
      SELECT a.*, s.nama_siswa, k.nama_kelas
      FROM attendance a
      LEFT JOIN siswa s ON a.siswa_id = s.id
      LEFT JOIN kelas k ON a.kelas_id = k.id
      WHERE a.kelas_id = $1 AND a.deleted_at IS NULL
    `;

    const params = [kelasId];

    if (date) {
      query += ` AND DATE(a.date) = $2`;
      params.push(date);
    }

    query += ' ORDER BY a.date DESC, a.check_in_time DESC';

    const results = await router.pool.query(query, params);

    res.status(200).json({
      success: true,
      message: 'Attendance retrieved successfully',
      data: results.rows,
      count: results.rows.length
    });
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching attendance',
      error: error.message
    });
  }
});

router.setPool = setPool;
module.exports = router;
