const express = require('express');
const pool = require('../config/database');
const { authenticate, authorize } = require('../middleware/auth');

const router = express.Router();

router.get('/dashboard', authenticate, authorize('supervisor', 'admin', 'superadmin'), async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    let unitFilter = '';
    const params = [today.toISOString()];

    if (req.user.role === 'supervisor' && req.user.unitid) {
      unitFilter = ' AND l.unit_id = $2';
      params.push(req.user.unitId);
    }

    const queries = [
      pool.query(`SELECT COUNT(*)::int as count FROM logsheets l WHERE l.submitted_at >= $1${unitFilter}`, params),
      pool.query(`SELECT COUNT(*)::int as count FROM logsheets l WHERE l.sync_status IN ('pendingSync','pendingEdit')${unitFilter.replace('l.submitted_at', 'l.sync_status')}`, req.user.role === 'supervisor' && req.user.unitid ? [req.user.unitId] : []),
      pool.query(`SELECT COUNT(*)::int as count FROM logsheets l WHERE l.approval_status = 'approved' AND l.submitted_at >= $1${unitFilter}`, params),
      pool.query(`SELECT COUNT(*)::int as count FROM logsheets l WHERE l.report_status = 'abnormal' AND l.submitted_at >= $1${unitFilter}`, params),
      pool.query('SELECT COUNT(*)::int as count FROM units WHERE status = $1', ['active']),
      pool.query('SELECT COUNT(*)::int as count FROM users WHERE role = $1', ['operator']),
    ];

    const [
      todayReports, pendingSync, successReports, abnormalReports,
      totalUnits, totalOperators,
    ] = await Promise.all(queries);

    res.json({
      data: {
        todayReports: todayReports.rows[0]?.count || 0,
        pendingSync: pendingSync.rows[0]?.count || 0,
        successReports: successReports.rows[0]?.count || 0,
        abnormalReports: abnormalReports.rows[0]?.count || 0,
        totalUnits: totalUnits.rows[0]?.count || 0,
        totalOperators: totalOperators.rows[0]?.count || 0,
      },
    });
  } catch (err) {
    console.error('Dashboard error:', err);
    res.status(500).json({ message: 'Gagal mengambil data dashboard' });
  }
});

router.get('/monitoring', authenticate, authorize('supervisor', 'admin', 'superadmin'), async (req, res) => {
  try {
    let query = `
      SELECT u.id as unit_id, u.name as unit_name,
             COUNT(l.id) FILTER (WHERE l.submitted_at >= NOW() - INTERVAL '24 hours') as last_24h_reports,
             COUNT(l.id) FILTER (WHERE l.submitted_at >= NOW() - INTERVAL '24 hours' AND l.approval_status = 'pendingReview') as pending_review,
             COUNT(l.id) FILTER (WHERE l.submitted_at >= NOW() - INTERVAL '24 hours' AND l.report_status = 'abnormal') as abnormal_reports
      FROM units u
      LEFT JOIN logsheets l ON l.unit_id = u.id
    `;

    const params = [];
    if (req.user.role === 'supervisor' && req.user.unitid) {
      query += ' WHERE u.id = $1';
      params.push(req.user.unitId);
    }

    query += ' GROUP BY u.id, u.name ORDER BY u.name';

    const result = await pool.query(query, params);
    res.json({ data: result.rows });
  } catch (err) {
    console.error('Monitoring error:', err);
    res.status(500).json({ message: 'Gagal mengambil data monitoring' });
  }
});

module.exports = router;
