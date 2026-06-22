const express = require('express');
const pool = require('../config/database');
const { authenticate, authorize } = require('../middleware/auth');

const router = express.Router();

router.get('/', authenticate, async (req, res) => {
  try {
    let query = 'SELECT * FROM machines';
    const params = [];

    if (req.query.unit_id) {
      query += ' WHERE unit_id = $1';
      params.push(req.query.unit_id);
    }
    query += ' ORDER BY machine_name';

    const result = await pool.query(query, params);
    res.json({ data: result.rows });
  } catch (err) {
    console.error('Get machines error:', err);
    res.status(500).json({ message: 'Gagal mengambil data mesin' });
  }
});

router.get('/:id', authenticate, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM machines WHERE id = $1', [req.params.id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Mesin tidak ditemukan' });
    }
    res.json({ data: result.rows[0] });
  } catch (err) {
    console.error('Get machine error:', err);
    res.status(500).json({ message: 'Gagal mengambil data mesin' });
  }
});

router.post('/', authenticate, authorize('admin', 'superadmin'), async (req, res) => {
  try {
    const { id, unit_id, up3, machine_name, brand, machine_type, serial_number, generator_code, ownership_status, performance_label, capacity, available_capacity, dispatch_capacity, status, condition_label } = req.body;

    if (!id || !unit_id || !machine_name) {
      return res.status(400).json({ message: 'ID, unit_id, dan machine_name harus diisi' });
    }

    const result = await pool.query(
      `INSERT INTO machines (id, unit_id, up3, machine_name, brand, machine_type, serial_number, generator_code, ownership_status, performance_label, capacity, available_capacity, dispatch_capacity, status, condition_label)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15) RETURNING *`,
      [id, unit_id, up3, machine_name, brand, machine_type, serial_number, generator_code, ownership_status || 'P', performance_label, capacity, available_capacity, dispatch_capacity, status || 'operasi', condition_label]
    );

    res.status(201).json({ message: 'Mesin berhasil dibuat', data: result.rows[0] });
  } catch (err) {
    console.error('Create machine error:', err);
    if (err.code === '23505') {
      return res.status(409).json({ message: 'ID mesin sudah digunakan' });
    }
    res.status(500).json({ message: 'Gagal membuat mesin' });
  }
});

router.put('/:id', authenticate, authorize('admin', 'superadmin'), async (req, res) => {
  try {
    const { unit_id, up3, machine_name, brand, machine_type, serial_number, generator_code, ownership_status, performance_label, capacity, available_capacity, dispatch_capacity, status, condition_label } = req.body;

    const result = await pool.query(
      `UPDATE machines SET unit_id = COALESCE($1, unit_id), up3 = COALESCE($2, up3),
       machine_name = COALESCE($3, machine_name), brand = COALESCE($4, brand),
       machine_type = COALESCE($5, machine_type), serial_number = COALESCE($6, serial_number),
       generator_code = COALESCE($7, generator_code), ownership_status = COALESCE($8, ownership_status),
       performance_label = COALESCE($9, performance_label), capacity = COALESCE($10, capacity),
       available_capacity = COALESCE($11, available_capacity), dispatch_capacity = COALESCE($12, dispatch_capacity),
       status = COALESCE($13, status), condition_label = COALESCE($14, condition_label)
       WHERE id = $15 RETURNING *`,
      [unit_id, up3, machine_name, brand, machine_type, serial_number, generator_code, ownership_status, performance_label, capacity, available_capacity, dispatch_capacity, status, condition_label, req.params.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Mesin tidak ditemukan' });
    }
    res.json({ message: 'Mesin berhasil diupdate', data: result.rows[0] });
  } catch (err) {
    console.error('Update machine error:', err);
    res.status(500).json({ message: 'Gagal mengupdate mesin' });
  }
});

router.delete('/:id', authenticate, authorize('superadmin'), async (req, res) => {
  try {
    const result = await pool.query('DELETE FROM machines WHERE id = $1 RETURNING *', [req.params.id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Mesin tidak ditemukan' });
    }
    res.json({ message: 'Mesin berhasil dihapus' });
  } catch (err) {
    console.error('Delete machine error:', err);
    res.status(500).json({ message: 'Gagal menghapus mesin' });
  }
});

module.exports = router;
