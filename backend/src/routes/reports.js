const express = require('express');
const pool = require('../config/database');
const { authenticate, authorize } = require('../middleware/auth');

const router = express.Router();

router.get('/', authenticate, authorize('supervisor', 'admin', 'superadmin'), async (req, res) => {
  try {
    const { start_date, end_date, unit_id } = req.query;

    let query = `
      SELECT
        DATE(l.submitted_at) as tanggal,
        l.unit_id as unit,
        l.unit_name,
        l.operator_name as operator,
        COUNT(*)::int as jumlah,
        COUNT(*) FILTER (WHERE l.report_status = 'onTime')::int as tepat_waktu,
        COUNT(*) FILTER (WHERE l.report_status = 'late')::int as terlambat,
        COUNT(*) FILTER (WHERE l.report_status = 'abnormal')::int as abnormal,
        COUNT(*) FILTER (WHERE l.approval_status = 'pendingReview')::int as pending
      FROM logsheets l
      WHERE 1=1
    `;

    const params = [];
    let paramIdx = 1;

    if (start_date) {
      query += ` AND l.submitted_at >= $${paramIdx++}`;
      params.push(start_date);
    }
    if (end_date) {
      query += ` AND l.submitted_at <= $${paramIdx++}`;
      params.push(end_date + 'T23:59:59Z');
    }
    if (unit_id) {
      query += ` AND l.unit_id = $${paramIdx++}`;
      params.push(unit_id);
    }
    if (req.user.role === 'supervisor' && req.user.unitid) {
      query += ` AND l.unit_id = $${paramIdx++}`;
      params.push(req.user.unitId);
    }

    query += ' GROUP BY DATE(l.submitted_at), l.unit_id, l.unit_name, l.operator_name ORDER BY tanggal DESC';

    const result = await pool.query(query, params);
    res.json({ data: result.rows });
  } catch (err) {
    console.error('Get reports error:', err);
    res.status(500).json({ message: 'Gagal mengambil data laporan' });
  }
});

module.exports = router;
