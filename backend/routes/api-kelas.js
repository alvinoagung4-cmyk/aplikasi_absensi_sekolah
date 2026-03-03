// backend/routes/api-kelas.js - Routes untuk manajemen Kelas (PostgreSQL)
const express = require('express');
const router = express.Router();

// Middleware untuk parse pool dari parent app
function setPool(pool) {
  router.pool = pool;
}

// GET semua kelas
router.get('/', async (req, res) => {
  try {
    const query = 'SELECT * FROM kelas WHERE deleted_at IS NULL ORDER BY created_at DESC';
    const results = await router.pool.query(query);
    
    res.status(200).json({
      success: true,
      message: 'Kelas retrieved successfully',
      data: results.rows,
      count: results.rows.length
    });
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching kelas',
      error: error.message
    });
  }
});

// GET kelas by ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const query = 'SELECT * FROM kelas WHERE id = $1 AND deleted_at IS NULL';
    const results = await router.pool.query(query, [id]);
    
    if (results.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Kelas not found'
      });
    }
    
    res.status(200).json({
      success: true,
      message: 'Kelas retrieved successfully',
      data: results.rows[0]
    });
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching kelas',
      error: error.message
    });
  }
});

// CREATE kelas baru
router.post('/', async (req, res) => {
  try {
    const { nama_kelas, jurusan, wali_kelas, login_wali } = req.body;
    
    if (!nama_kelas || !jurusan || !wali_kelas) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: nama_kelas, jurusan, wali_kelas'
      });
    }
    
    const query = `INSERT INTO kelas (nama_kelas, jurusan, wali_kelas, login_wali, jumlah_siswa) 
                   VALUES ($1, $2, $3, $4, 0) 
                   RETURNING *`;
    
    const results = await router.pool.query(query, [nama_kelas, jurusan, wali_kelas, login_wali || '']);
    
    res.status(201).json({
      success: true,
      message: 'Kelas created successfully',
      data: results.rows[0]
    });
  } catch (error) {
    if (error.code === '23505') { // UNIQUE CONSTRAINT
      return res.status(400).json({
        success: false,
        message: 'Kelas with this name already exists'
      });
    }
    console.error('Database error:', error);
    res.status(500).json({
      success: false,
      message: 'Error creating kelas',
      error: error.message
    });
  }
});

// UPDATE kelas
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { nama_kelas, jurusan, wali_kelas, login_wali } = req.body;
    
    if (!nama_kelas || !jurusan || !wali_kelas) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: nama_kelas, jurusan, wali_kelas'
      });
    }
    
    const query = `UPDATE kelas 
                   SET nama_kelas = $1, jurusan = $2, wali_kelas = $3, login_wali = $4, updated_at = CURRENT_TIMESTAMP 
                   WHERE id = $5 AND deleted_at IS NULL 
                   RETURNING *`;
    
    const results = await router.pool.query(query, [nama_kelas, jurusan, wali_kelas, login_wali || '', id]);
    
    if (results.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Kelas not found'
      });
    }
    
    res.status(200).json({
      success: true,
      message: 'Kelas updated successfully',
      data: results.rows[0]
    });
  } catch (error) {
    if (error.code === '23505') {
      return res.status(400).json({
        success: false,
        message: 'Kelas with this name already exists'
      });
    }
    console.error('Database error:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating kelas',
      error: error.message
    });
  }
});

// DELETE kelas (soft delete)
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    const query = `UPDATE kelas 
                   SET deleted_at = CURRENT_TIMESTAMP 
                   WHERE id = $1 AND deleted_at IS NULL 
                   RETURNING id`;
    
    const results = await router.pool.query(query, [id]);
    
    if (results.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Kelas not found'
      });
    }
    
    res.status(200).json({
      success: true,
      message: 'Kelas deleted successfully'
    });
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting kelas',
      error: error.message
    });
  }
});

router.setPool = setPool;
module.exports = router;
