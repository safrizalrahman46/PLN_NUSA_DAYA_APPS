const express = require('express');
const bcrypt = require('bcryptjs');
const pool = require('../config/database');
const { authenticate, authorize } = require('../middleware/auth');

const router = express.Router();

// GET /api/users — list all users (admin+)
router.get('/', authenticate, authorize('admin', 'superadmin'), async (req, res) => {
  try {
    const { role, unit_id } = req.query;
    let query = 'SELECT id, name, username, role, unit_id, unit_name, created_at FROM users WHERE 1=1';
    const params = [];

    if (role) {
      params.push(role);
      query += ` AND role = $${params.length}`;
    }
    if (unit_id) {
      params.push(unit_id);
      query += ` AND unit_id = $${params.length}`;
    }

    query += ' ORDER BY role, name';
    const result = await pool.query(query, params);
    res.json({ data: result.rows });
  } catch (err) {
    console.error('Get users error:', err);
    res.status(500).json({ message: 'Gagal mengambil data pengguna' });
  }
});

// GET /api/users/:id — get single user
router.get('/:id', authenticate, authorize('admin', 'superadmin'), async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, name, username, role, unit_id, unit_name, created_at FROM users WHERE id = $1',
      [req.params.id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Pengguna tidak ditemukan' });
    }
    res.json({ data: result.rows[0] });
  } catch (err) {
    console.error('Get user error:', err);
    res.status(500).json({ message: 'Gagal mengambil data pengguna' });
  }
});

// POST /api/users — create user (admin+)
router.post('/', authenticate, authorize('admin', 'superadmin'), async (req, res) => {
  try {
    const { name, username, password, role, unit_id, unit_name } = req.body;

    if (!name || !username || !password || !role) {
      return res.status(400).json({ message: 'Nama, username, password, dan role wajib diisi' });
    }

    const validRoles = ['operator', 'supervisor', 'admin', 'superadmin'];
    if (!validRoles.includes(role)) {
      return res.status(400).json({ message: 'Role tidak valid' });
    }

    // Only superadmin can create admin/superadmin
    if (['admin', 'superadmin'].includes(role) && req.user.role !== 'superadmin') {
      return res.status(403).json({ message: 'Hanya superadmin yang dapat membuat akun admin' });
    }

    // Check username uniqueness
    const existing = await pool.query('SELECT id FROM users WHERE username = $1', [username]);
    if (existing.rows.length > 0) {
      return res.status(409).json({ message: 'Username sudah digunakan' });
    }

    const id = 'usr_' + require('crypto').randomBytes(6).toString('hex');
    const hashedPassword = await bcrypt.hash(password, 10);

    const result = await pool.query(
      `INSERT INTO users (id, name, username, password, role, unit_id, unit_name)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING id, name, username, role, unit_id, unit_name, created_at`,
      [id, name, username, hashedPassword, role, unit_id || null, unit_name || null]
    );

    res.status(201).json({ message: 'Pengguna berhasil dibuat', data: result.rows[0] });
  } catch (err) {
    console.error('Create user error:', err);
    res.status(500).json({ message: 'Gagal membuat pengguna', error: err.message });
  }
});

// PUT /api/users/:id — update user (admin+)
router.put('/:id', authenticate, authorize('admin', 'superadmin'), async (req, res) => {
  try {
    const { name, username, password, role, unit_id, unit_name } = req.body;
    const userId = req.params.id;

    // Check target user exists
    const existing = await pool.query('SELECT * FROM users WHERE id = $1', [userId]);
    if (existing.rows.length === 0) {
      return res.status(404).json({ message: 'Pengguna tidak ditemukan' });
    }
    const targetUser = existing.rows[0];

    // Only superadmin can modify admin/superadmin accounts
    if (['admin', 'superadmin'].includes(targetUser.role) && req.user.role !== 'superadmin') {
      return res.status(403).json({ message: 'Hanya superadmin yang dapat mengedit akun admin' });
    }

    // Check username uniqueness (if changed)
    if (username && username !== targetUser.username) {
      const usernameCheck = await pool.query(
        'SELECT id FROM users WHERE username = $1 AND id != $2',
        [username, userId]
      );
      if (usernameCheck.rows.length > 0) {
        return res.status(409).json({ message: 'Username sudah digunakan' });
      }
    }

    const updates = [];
    const params = [];
    let idx = 1;

    if (name) { updates.push(`name = $${idx++}`); params.push(name); }
    if (username) { updates.push(`username = $${idx++}`); params.push(username); }
    if (password) {
      const hashed = await bcrypt.hash(password, 10);
      updates.push(`password = $${idx++}`); params.push(hashed);
    }
    if (role) {
      if (!['operator', 'supervisor', 'admin', 'superadmin'].includes(role)) {
        return res.status(400).json({ message: 'Role tidak valid' });
      }
      updates.push(`role = $${idx++}`); params.push(role);
    }
    if (unit_id !== undefined) { updates.push(`unit_id = $${idx++}`); params.push(unit_id || null); }
    if (unit_name !== undefined) { updates.push(`unit_name = $${idx++}`); params.push(unit_name || null); }

    if (updates.length === 0) {
      return res.status(400).json({ message: 'Tidak ada data yang diubah' });
    }

    updates.push(`updated_at = NOW()`);
    params.push(userId);
    const result = await pool.query(
      `UPDATE users SET ${updates.join(', ')} WHERE id = $${idx} RETURNING id, name, username, role, unit_id, unit_name`,
      params
    );

    res.json({ message: 'Pengguna berhasil diperbarui', data: result.rows[0] });
  } catch (err) {
    console.error('Update user error:', err);
    res.status(500).json({ message: 'Gagal memperbarui pengguna', error: err.message });
  }
});

// DELETE /api/users/:id — delete user (superadmin only)
router.delete('/:id', authenticate, authorize('superadmin'), async (req, res) => {
  try {
    const userId = req.params.id;

    // Cannot delete yourself
    if (userId === req.user.id.toString()) {
      return res.status(400).json({ message: 'Tidak dapat menghapus akun Anda sendiri' });
    }

    const result = await pool.query(
      'DELETE FROM users WHERE id = $1 RETURNING id, name, username, role',
      [userId]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Pengguna tidak ditemukan' });
    }

    res.json({ message: 'Pengguna berhasil dihapus', data: result.rows[0] });
  } catch (err) {
    console.error('Delete user error:', err);
    res.status(500).json({ message: 'Gagal menghapus pengguna', error: err.message });
  }
});

// PUT /api/users/:id/reset-password — reset password (admin+)
router.put('/:id/reset-password', authenticate, authorize('admin', 'superadmin'), async (req, res) => {
  try {
    const { new_password } = req.body;
    if (!new_password || new_password.length < 6) {
      return res.status(400).json({ message: 'Password baru minimal 6 karakter' });
    }
    const hashed = await bcrypt.hash(new_password, 10);
    const result = await pool.query(
      'UPDATE users SET password = $1, updated_at = NOW() WHERE id = $2 RETURNING id, name, username, role',
      [hashed, req.params.id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Pengguna tidak ditemukan' });
    }
    res.json({ message: 'Password berhasil direset', data: result.rows[0] });
  } catch (err) {
    console.error('Reset password error:', err);
    res.status(500).json({ message: 'Gagal mereset password' });
  }
});

module.exports = router;
