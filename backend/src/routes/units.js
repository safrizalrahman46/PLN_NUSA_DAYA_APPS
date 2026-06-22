const express = require('express');
const pool = require('../config/database');
const { authenticate, authorize } = require('../middleware/auth');

const router = express.Router();

router.get('/', authenticate, async (req, res) => {
  try {
    const limit = req.query.limit ? parseInt(req.query.limit) : null;
    let query = 'SELECT * FROM units ORDER BY name';
    if (limit) query += ` LIMIT ${limit}`;

    const result = await pool.query(query);
    res.json({ data: result.rows });
  } catch (err) {
    console.error('Get units error:', err);
    res.status(500).json({ message: 'Gagal mengambil data unit' });
  }
});

router.get('/:id', authenticate, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM units WHERE id = $1', [req.params.id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Unit tidak ditemukan' });
    }
    res.json({ data: result.rows[0] });
  } catch (err) {
    console.error('Get unit error:', err);
    res.status(500).json({ message: 'Gagal mengambil data unit' });
  }
});

router.post('/', authenticate, authorize('admin', 'superadmin'), async (req, res) => {
  try {
    const { id, name, location_name, latitude, longitude, radius_meter, status } = req.body;
    if (!id || !name) {
      return res.status(400).json({ message: 'ID dan nama unit harus diisi' });
    }

    const result = await pool.query(
      `INSERT INTO units (id, name, location_name, latitude, longitude, radius_meter, status)
       VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
      [id, name, location_name, latitude, longitude, radius_meter || 250, status || 'active']
    );

    res.status(201).json({ message: 'Unit berhasil dibuat', data: result.rows[0] });
  } catch (err) {
    console.error('Create unit error:', err);
    if (err.code === '23505') {
      return res.status(409).json({ message: 'ID unit sudah digunakan' });
    }
    res.status(500).json({ message: 'Gagal membuat unit' });
  }
});

router.put('/:id', authenticate, authorize('admin', 'superadmin'), async (req, res) => {
  try {
    const { name, location_name, latitude, longitude, radius_meter, status } = req.body;
    const result = await pool.query(
      `UPDATE units SET name = COALESCE($1, name), location_name = COALESCE($2, location_name),
       latitude = COALESCE($3, latitude), longitude = COALESCE($4, longitude),
       radius_meter = COALESCE($5, radius_meter), status = COALESCE($6, status)
       WHERE id = $7 RETURNING *`,
      [name, location_name, latitude, longitude, radius_meter, status, req.params.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Unit tidak ditemukan' });
    }
    res.json({ message: 'Unit berhasil diupdate', data: result.rows[0] });
  } catch (err) {
    console.error('Update unit error:', err);
    res.status(500).json({ message: 'Gagal mengupdate unit' });
  }
});

router.delete('/:id', authenticate, authorize('superadmin'), async (req, res) => {
  try {
    const result = await pool.query('DELETE FROM units WHERE id = $1 RETURNING *', [req.params.id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Unit tidak ditemukan' });
    }
    res.json({ message: 'Unit berhasil dihapus' });
  } catch (err) {
    console.error('Delete unit error:', err);
    res.status(500).json({ message: 'Gagal menghapus unit' });
  }
});

module.exports = router;
