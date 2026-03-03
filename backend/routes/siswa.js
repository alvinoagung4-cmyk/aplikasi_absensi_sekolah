// backend/routes/siswa.js
const express = require('express');
const router = express.Router();
const db = require('../config/database');

// ============================================
// SISWA ROUTES (Student Management)
// ============================================

// GET all siswa
router.get('/', (req, res) => {
    const query = `SELECT s.*, k.nama_kelas FROM siswa s 
                   LEFT JOIN kelas k ON s.kelas_id = k.id 
                   WHERE s.deleted_at IS NULL 
                   ORDER BY s.created_at DESC`;
    
    db.query(query, (err, results) => {
        if (err) {
            console.error('Database error:', err);
            return res.status(500).json({
                success: false,
                message: 'Error fetching siswa',
                error: err.message
            });
        }
        
        res.status(200).json({
            success: true,
            message: 'Siswa retrieved successfully',
            data: results,
            count: results.length
        });
    });
});

// GET siswa by ID
router.get('/:id', (req, res) => {
    const { id } = req.params;
    const query = `SELECT s.*, k.nama_kelas FROM siswa s 
                   LEFT JOIN kelas k ON s.kelas_id = k.id 
                   WHERE s.id = ? AND s.deleted_at IS NULL`;
    
    db.query(query, [id], (err, results) => {
        if (err) {
            console.error('Database error:', err);
            return res.status(500).json({
                success: false,
                message: 'Error fetching siswa',
                error: err.message
            });
        }
        
        if (results.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Siswa not found'
            });
        }
        
        res.status(200).json({
            success: true,
            message: 'Siswa retrieved successfully',
            data: results[0]
        });
    });
});

// GET siswa by kelas_id
router.get('/kelas/:kelas_id', (req, res) => {
    const { kelas_id } = req.params;
    const query = `SELECT s.*, k.nama_kelas FROM siswa s 
                   LEFT JOIN kelas k ON s.kelas_id = k.id 
                   WHERE s.kelas_id = ? AND s.deleted_at IS NULL 
                   ORDER BY s.nama_siswa ASC`;
    
    db.query(query, [kelas_id], (err, results) => {
        if (err) {
            console.error('Database error:', err);
            return res.status(500).json({
                success: false,
                message: 'Error fetching siswa',
                error: err.message
            });
        }
        
        res.status(200).json({
            success: true,
            message: 'Siswa retrieved successfully',
            data: results,
            count: results.length
        });
    });
});

// CREATE new siswa
router.post('/', (req, res) => {
    const { nama_siswa, kelas_id, jurusan } = req.body;
    
    // Validation
    if (!nama_siswa || !kelas_id || !jurusan) {
        return res.status(400).json({
            success: false,
            message: 'Missing required fields: nama_siswa, kelas_id, jurusan'
        });
    }
    
    // Check if kelas exists
    const checkKelas = 'SELECT id FROM kelas WHERE id = ? AND deleted_at IS NULL';
    db.query(checkKelas, [kelas_id], (err, results) => {
        if (err || results.length === 0) {
            return res.status(400).json({
                success: false,
                message: 'Kelas not found'
            });
        }
        
        const query = 'INSERT INTO siswa (nama_siswa, kelas_id, jurusan, jumlah_hadir, jumlah_izin, jumlah_sakit, jumlah_alpha) VALUES (?, ?, ?, 0, 0, 0, 0)';
        
        db.query(query, [nama_siswa, kelas_id, jurusan], (err, results) => {
            if (err) {
                console.error('Database error:', err);
                return res.status(500).json({
                    success: false,
                    message: 'Error creating siswa',
                    error: err.message
                });
            }
            
            res.status(201).json({
                success: true,
                message: 'Siswa created successfully',
                data: {
                    id: results.insertId,
                    nama_siswa,
                    kelas_id,
                    jurusan,
                    jumlah_hadir: 0,
                    jumlah_izin: 0,
                    jumlah_sakit: 0,
                    jumlah_alpha: 0
                }
            });
        });
    });
});

// UPDATE siswa
router.put('/:id', (req, res) => {
    const { id } = req.params;
    const { nama_siswa, kelas_id, jurusan } = req.body;
    
    // Validation
    if (!nama_siswa || !kelas_id || !jurusan) {
        return res.status(400).json({
            success: false,
            message: 'Missing required fields: nama_siswa, kelas_id, jurusan'
        });
    }
    
    const query = 'UPDATE siswa SET nama_siswa = ?, kelas_id = ?, jurusan = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ? AND deleted_at IS NULL';
    
    db.query(query, [nama_siswa, kelas_id, jurusan, id], (err, results) => {
        if (err) {
            console.error('Database error:', err);
            return res.status(500).json({
                success: false,
                message: 'Error updating siswa',
                error: err.message
            });
        }
        
        if (results.affectedRows === 0) {
            return res.status(404).json({
                success: false,
                message: 'Siswa not found'
            });
        }
        
        res.status(200).json({
            success: true,
            message: 'Siswa updated successfully',
            data: {
                id,
                nama_siswa,
                kelas_id,
                jurusan
            }
        });
    });
});

// DELETE siswa (soft delete)
router.delete('/:id', (req, res) => {
    const { id } = req.params;
    
    const query = 'UPDATE siswa SET deleted_at = CURRENT_TIMESTAMP WHERE id = ? AND deleted_at IS NULL';
    
    db.query(query, [id], (err, results) => {
        if (err) {
            console.error('Database error:', err);
            return res.status(500).json({
                success: false,
                message: 'Error deleting siswa',
                error: err.message
            });
        }
        
        if (results.affectedRows === 0) {
            return res.status(404).json({
                success: false,
                message: 'Siswa not found'
            });
        }
        
        res.status(200).json({
            success: true,
            message: 'Siswa deleted successfully'
        });
    });
});

// UPDATE attendance stats (called when presensi is recorded)
router.put('/:id/attendance', (req, res) => {
    const { id } = req.params;
    const { status } = req.body;
    
    if (!status || !['Hadir', 'Izin', 'Sakit', 'Alpha'].includes(status)) {
        return res.status(400).json({
            success: false,
            message: 'Invalid attendance status'
        });
    }
    
    let updateField = '';
    switch (status) {
        case 'Hadir':
            updateField = 'jumlah_hadir = jumlah_hadir + 1';
            break;
        case 'Izin':
            updateField = 'jumlah_izin = jumlah_izin + 1';
            break;
        case 'Sakit':
            updateField = 'jumlah_sakit = jumlah_sakit + 1';
            break;
        case 'Alpha':
            updateField = 'jumlah_alpha = jumlah_alpha + 1';
            break;
    }
    
    const query = `UPDATE siswa SET ${updateField}, updated_at = CURRENT_TIMESTAMP WHERE id = ? AND deleted_at IS NULL`;
    
    db.query(query, [id], (err, results) => {
        if (err) {
            console.error('Database error:', err);
            return res.status(500).json({
                success: false,
                message: 'Error updating attendance',
                error: err.message
            });
        }
        
        res.status(200).json({
            success: true,
            message: 'Attendance updated successfully'
        });
    });
});

module.exports = router;
