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

app.get('/api/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', database: 'connected', timestamp: new Date().toISOString() });
  } catch (err) {
    res.status(503).json({ status: 'error', database: 'disconnected', error: err.message });
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
