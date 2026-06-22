const express = require('express');
const pool = require('../config/database');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.get('/', authenticate, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT * FROM notifications
       WHERE user_id = $1 OR user_id IS NULL
       ORDER BY time DESC
       LIMIT 50`,
      [req.user.id]
    );
    res.json({ data: result.rows });
  } catch (err) {
    console.error('Get notifications error:', err);
    res.status(500).json({ message: 'Gagal mengambil notifikasi' });
  }
});

router.put('/:id/read', authenticate, async (req, res) => {
  try {
    const result = await pool.query(
      'UPDATE notifications SET is_read = TRUE WHERE id = $1 RETURNING *',
      [req.params.id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Notifikasi tidak ditemukan' });
    }
    res.json({ message: 'Notifikasi ditandai sudah dibaca', data: result.rows[0] });
  } catch (err) {
    console.error('Read notification error:', err);
    res.status(500).json({ message: 'Gagal mengupdate notifikasi' });
  }
});

router.put('/read-all', authenticate, async (req, res) => {
  try {
    await pool.query(
      'UPDATE notifications SET is_read = TRUE WHERE (user_id = $1 OR user_id IS NULL) AND is_read = FALSE',
      [req.user.id]
    );
    res.json({ message: 'Semua notifikasi ditandai sudah dibaca' });
  } catch (err) {
    console.error('Read all notifications error:', err);
    res.status(500).json({ message: 'Gagal mengupdate notifikasi' });
  }
});

module.exports = router;
