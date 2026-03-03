// backend/routes/kelas.js
const express = require('express');
const router = express.Router();
const db = require('../config/database');

// ============================================
// KELAS ROUTES (Class Management)
// ============================================

// GET all kelas
router.get('/', (req, res) => {
    const query = 'SELECT * FROM kelas WHERE deleted_at IS NULL ORDER BY created_at DESC';
    
    db.query(query, (err, results) => {
        if (err) {
            console.error('Database error:', err);
            return res.status(500).json({
                success: false,
                message: 'Error fetching kelas',
                error: err.message
            });
        }
        
        res.status(200).json({
            success: true,
            message: 'Kelas retrieved successfully',
            data: results,
            count: results.length
        });
    });
});

// GET kelas by ID
router.get('/:id', (req, res) => {
    const { id } = req.params;
    const query = 'SELECT * FROM kelas WHERE id = ? AND deleted_at IS NULL';
    
    db.query(query, [id], (err, results) => {
        if (err) {
            console.error('Database error:', err);
            return res.status(500).json({
                success: false,
                message: 'Error fetching kelas',
                error: err.message
            });
        }
        
        if (results.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Kelas not found'
            });
        }
        
        res.status(200).json({
            success: true,
            message: 'Kelas retrieved successfully',
            data: results[0]
        });
    });
});

// CREATE new kelas
router.post('/', (req, res) => {
    const { nama_kelas, jurusan, wali_kelas, login_wali } = req.body;
    
    // Validation
    if (!nama_kelas || !jurusan || !wali_kelas) {
        return res.status(400).json({
            success: false,
            message: 'Missing required fields: nama_kelas, jurusan, wali_kelas'
        });
    }
    
    const query = 'INSERT INTO kelas (nama_kelas, jurusan, wali_kelas, login_wali, jumlah_siswa) VALUES (?, ?, ?, ?, 0)';
    
    db.query(query, [nama_kelas, jurusan, wali_kelas, login_wali || ''], (err, results) => {
        if (err) {
            if (err.code === 'ER_DUP_ENTRY') {
                return res.status(400).json({
                    success: false,
                    message: 'Kelas with this name already exists'
                });
            }
            console.error('Database error:', err);
            return res.status(500).json({
                success: false,
                message: 'Error creating kelas',
                error: err.message
            });
        }
        
        res.status(201).json({
            success: true,
            message: 'Kelas created successfully',
            data: {
                id: results.insertId,
                nama_kelas,
                jurusan,
                wali_kelas,
                login_wali: login_wali || '',
                jumlah_siswa: 0
            }
        });
    });
});

// UPDATE kelas
router.put('/:id', (req, res) => {
    const { id } = req.params;
    const { nama_kelas, jurusan, wali_kelas, login_wali } = req.body;
    
    // Validation
    if (!nama_kelas || !jurusan || !wali_kelas) {
        return res.status(400).json({
            success: false,
            message: 'Missing required fields: nama_kelas, jurusan, wali_kelas'
        });
    }
    
    const query = 'UPDATE kelas SET nama_kelas = ?, jurusan = ?, wali_kelas = ?, login_wali = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ? AND deleted_at IS NULL';
    
    db.query(query, [nama_kelas, jurusan, wali_kelas, login_wali || '', id], (err, results) => {
        if (err) {
            if (err.code === 'ER_DUP_ENTRY') {
                return res.status(400).json({
                    success: false,
                    message: 'Kelas with this name already exists'
                });
            }
            console.error('Database error:', err);
            return res.status(500).json({
                success: false,
                message: 'Error updating kelas',
                error: err.message
            });
        }
        
        if (results.affectedRows === 0) {
            return res.status(404).json({
                success: false,
                message: 'Kelas not found'
            });
        }
        
        res.status(200).json({
            success: true,
            message: 'Kelas updated successfully',
            data: {
                id,
                nama_kelas,
                jurusan,
                wali_kelas,
                login_wali: login_wali || ''
            }
        });
    });
});

// DELETE kelas (soft delete)
router.delete('/:id', (req, res) => {
    const { id } = req.params;
    
    const query = 'UPDATE kelas SET deleted_at = CURRENT_TIMESTAMP WHERE id = ? AND deleted_at IS NULL';
    
    db.query(query, [id], (err, results) => {
        if (err) {
            console.error('Database error:', err);
            return res.status(500).json({
                success: false,
                message: 'Error deleting kelas',
                error: err.message
            });
        }
        
        if (results.affectedRows === 0) {
            return res.status(404).json({
                success: false,
                message: 'Kelas not found'
            });
        }
        
        res.status(200).json({
            success: true,
            message: 'Kelas deleted successfully'
        });
    });
});

module.exports = router;
