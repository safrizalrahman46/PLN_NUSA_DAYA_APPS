require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const path = require('path');
const pool = require('./config/database');

const authRoutes = require('./routes/auth');
const unitsRoutes = require('./routes/units');
const machinesRoutes = require('./routes/machines');
const logsheetsRoutes = require('./routes/logsheets');
const supervisorRoutes = require('./routes/supervisor');
const notificationsRoutes = require('./routes/notifications');
const reportsRoutes = require('./routes/reports');
const usersRoutes = require('./routes/users');
const digikitRoutes = require('./routes/digikit');

const app = express();
const PORT = process.env.PORT || 8000;

app.use(helmet());
app.use(cors({ origin: '*', methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'] }));
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true }));

app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));

app.use('/api', authRoutes);
app.use('/api/units', unitsRoutes);
app.use('/api/machines', machinesRoutes);
app.use('/api/logsheets', logsheetsRoutes);
app.use('/api/supervisor', supervisorRoutes);
app.use('/api/notifications', notificationsRoutes);
app.use('/api/reports', reportsRoutes);
app.use('/api/users', usersRoutes);
app.use('/api', digikitRoutes);

app.get('/api/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', database: 'connected', timestamp: new Date().toISOString() });
  } catch (err) {
    res.status(503).json({ status: 'error', database: 'disconnected', error: err.message });
  }
});

// Summary Endpoint untuk Integrasi Multi-App
app.get('/api/summary', async (req, res) => {
  try {
    const unitsCount = await pool.query('SELECT COUNT(*) FROM units');
    const machinesCount = await pool.query('SELECT COUNT(*) FROM machines');
    const logsheetsCount = await pool.query("SELECT COUNT(*) FROM logsheet_records WHERE tanggal = TO_CHAR(NOW(), 'YYYY-MM-DD')").catch(() => ({ rows: [{ count: 0 }] }));
    const unreadNotifs = await pool.query('SELECT COUNT(*) FROM notifications WHERE is_read = FALSE');

    res.json({
      success: true,
      service: 'PLN_NUSA_DAYA_APPS (Field Operator API)',
      port: PORT,
      units_count: parseInt(unitsCount.rows[0].count, 10),
      machines_count: parseInt(machinesCount.rows[0].count, 10),
      logsheets_today: parseInt(logsheetsCount.rows[0].count, 10),
      unread_notifications: parseInt(unreadNotifs.rows[0].count, 10),
      timestamp: new Date().toISOString()
    });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// Broadcast Notifikasi Operator Lapangan ke Seluruh Sistem
app.post('/api/notifications/broadcast', async (req, res) => {
  try {
    const { title, description, priority = 'sedang', type = 'logsheet', unit_id } = req.body;
    const payload = JSON.stringify({ source: 'PLN_NUSA_DAYA_APPS', action_url: '/logsheet/matrix' });
    const result = await pool.query(
      `INSERT INTO notifications (title, description, priority, type, target_type, unit_id, is_read, payload, time)
       VALUES ($1, $2, $3, $4, 'general', $5, FALSE, $6, NOW()) RETURNING *`,
      [title, description, priority, type, unit_id || '0283', payload]
    );
    res.status(201).json({
      success: true,
      message: 'Notifikasi operator berhasil disiarkan ke Web & seluruh sistem',
      data: result.rows[0]
    });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ message: 'Terjadi kesalahan server', error: err.message });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server PLTD Logsheet API berjalan di port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/api/health`);
});
