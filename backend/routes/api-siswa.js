// backend/routes/api-siswa.js - Routes untuk manajemen Siswa (PostgreSQL)
const express = require('express');
const router = express.Router();

// Middleware untuk parse pool dari parent app
function setPool(pool) {
  router.pool = pool;
}

// GET semua siswa
router.get('/', async (req, res) => {
  try {
    const query = `SELECT s.*, k.nama_kelas, k.jurusan 
                   FROM siswa s 
                   LEFT JOIN kelas k ON s.kelas_id = k.id 
                   WHERE s.deleted_at IS NULL 
                   ORDER BY s.created_at DESC`;
    const results = await router.pool.query(query);
    
    res.status(200).json({
      success: true,
      message: 'Siswa retrieved successfully',
      data: results.rows,
      count: results.rows.length
    });
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching siswa',
      error: error.message
    });
  }
});

// GET siswa by ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const query = `SELECT s.*, k.nama_kelas, k.jurusan 
                   FROM siswa s 
                   LEFT JOIN kelas k ON s.kelas_id = k.id 
                   WHERE s.id = $1 AND s.deleted_at IS NULL`;
    const results = await router.pool.query(query, [id]);
    
    if (results.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Siswa not found'
      });
    }
    
    res.status(200).json({
      success: true,
      message: 'Siswa retrieved successfully',
      data: results.rows[0]
    });
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching siswa',
      error: error.message
    });
  }
});

// GET siswa by kelas_id
router.get('/kelas/:kelas_id', async (req, res) => {
  try {
    const { kelas_id } = req.params;
    const query = `SELECT s.*, k.nama_kelas, k.jurusan 
                   FROM siswa s 
                   LEFT JOIN kelas k ON s.kelas_id = k.id 
                   WHERE s.kelas_id = $1 AND s.deleted_at IS NULL 
                   ORDER BY s.nama_siswa ASC`;
    const results = await router.pool.query(query, [kelas_id]);
    
    res.status(200).json({
      success: true,
      message: 'Siswa retrieved successfully',
      data: results.rows,
      count: results.rows.length
    });
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching siswa',
      error: error.message
    });
  }
});

// CREATE siswa baru
router.post('/', async (req, res) => {
  try {
    const { nama_siswa, kelas_id, jurusan } = req.body;
    
    if (!nama_siswa || !kelas_id) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: nama_siswa, kelas_id'
      });
    }
    
    // Check if kelas exists
    const kelasCheck = await router.pool.query(
      'SELECT id FROM kelas WHERE id = $1 AND deleted_at IS NULL',
      [kelas_id]
    );
    
    if (kelasCheck.rows.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Kelas not found'
      });
    }
    
    const query = `INSERT INTO siswa (nama_siswa, kelas_id, jurusan, hadir, sakit, izin, alpa) 
                   VALUES ($1, $2, $3, 0, 0, 0, 0) 
                   RETURNING *`;
    
    const results = await router.pool.query(query, [nama_siswa, kelas_id, jurusan || '']);
    
    // Update jumlah_siswa in kelas
    await router.pool.query(
      `UPDATE kelas SET jumlah_siswa = (SELECT COUNT(*) FROM siswa WHERE kelas_id = $1 AND deleted_at IS NULL) 
       WHERE id = $1`,
      [kelas_id]
    );
    
    res.status(201).json({
      success: true,
      message: 'Siswa created successfully',
      data: results.rows[0]
    });
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({
      success: false,
      message: 'Error creating siswa',
      error: error.message
    });
  }
});

// UPDATE siswa
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { nama_siswa, kelas_id, jurusan } = req.body;
    
    if (!nama_siswa || !kelas_id) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: nama_siswa, kelas_id'
      });
    }
    
    // Check if kelas exists
    const kelasCheck = await router.pool.query(
      'SELECT id FROM kelas WHERE id = $1 AND deleted_at IS NULL',
      [kelas_id]
    );
    
    if (kelasCheck.rows.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Kelas not found'
      });
    }
    
    // Get old kelas_id
    const oldSiswa = await router.pool.query(
      'SELECT kelas_id FROM siswa WHERE id = $1',
      [id]
    );
    
    if (oldSiswa.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Siswa not found'
      });
    }
    
    const oldKelasId = oldSiswa.rows[0].kelas_id;
    
    const query = `UPDATE siswa 
                   SET nama_siswa = $1, kelas_id = $2, jurusan = $3, updated_at = CURRENT_TIMESTAMP 
                   WHERE id = $4 AND deleted_at IS NULL 
                   RETURNING *`;
    
    const results = await router.pool.query(query, [nama_siswa, kelas_id, jurusan || '', id]);
    
    if (results.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Siswa not found'
      });
    }
    
    // Update jumlah_siswa for both old and new kelas
    if (oldKelasId !== kelas_id) {
      await router.pool.query(
        `UPDATE kelas SET jumlah_siswa = (SELECT COUNT(*) FROM siswa WHERE kelas_id = $1 AND deleted_at IS NULL) 
         WHERE id = ANY($2::integer[])`,
        [[oldKelasId, kelas_id]]
      );
    }
    
    res.status(200).json({
      success: true,
      message: 'Siswa updated successfully',
      data: results.rows[0]
    });
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating siswa',
      error: error.message
    });
  }
});

// DELETE siswa (soft delete)
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Get kelas_id before delete
    const siswa = await router.pool.query(
      'SELECT kelas_id FROM siswa WHERE id = $1',
      [id]
    );
    
    if (siswa.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Siswa not found'
      });
    }
    
    const kelas_id = siswa.rows[0].kelas_id;
    
    const query = `UPDATE siswa 
                   SET deleted_at = CURRENT_TIMESTAMP 
                   WHERE id = $1 AND deleted_at IS NULL 
                   RETURNING id`;
    
    const results = await router.pool.query(query, [id]);
    
    if (results.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Siswa not found'
      });
    }
    
    // Update jumlah_siswa in kelas
    await router.pool.query(
      `UPDATE kelas SET jumlah_siswa = (SELECT COUNT(*) FROM siswa WHERE kelas_id = $1 AND deleted_at IS NULL) 
       WHERE id = $1`,
      [kelas_id]
    );
    
    res.status(200).json({
      success: true,
      message: 'Siswa deleted successfully'
    });
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting siswa',
      error: error.message
    });
  }
});

// UPDATE attendance
router.put('/:id/attendance', async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body; // 'hadir', 'sakit', 'izin', 'alpa'
    
    if (!status || !['hadir', 'sakit', 'izin', 'alpa'].includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid status. Must be: hadir, sakit, izin, or alpa'
      });
    }
    
    // Get current count
    const siswa = await router.pool.query(
      `SELECT ${status} FROM siswa WHERE id = $1 AND deleted_at IS NULL`,
      [id]
    );
    
    if (siswa.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Siswa not found'
      });
    }
    
    const currentCount = siswa.rows[0][status];
    const newCount = currentCount + 1;
    
    const query = `UPDATE siswa 
                   SET ${status} = $1, updated_at = CURRENT_TIMESTAMP 
                   WHERE id = $2 AND deleted_at IS NULL 
                   RETURNING *`;
    
    const results = await router.pool.query(query, [newCount, id]);
    
    res.status(200).json({
      success: true,
      message: `Attendance marked as ${status}`,
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

router.setPool = setPool;
module.exports = router;
