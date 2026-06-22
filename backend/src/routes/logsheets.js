const express = require('express');
const pool = require('../config/database');
const { authenticate, authorize } = require('../middleware/auth');
const upload = require('../middleware/upload');

const router = express.Router();

router.post('/', authenticate, async (req, res) => {
  try {
    const {
      id, local_id, proof_id,
      operator_id, operator_name, unit_id, unit_name,
      machine_id,
      machine_up3, machine_name, machine_brand, machine_type,
      machine_serial_number, machine_generator_code, machine_ownership_status,
      machine_performance_label, machine_capacity, machine_available_capacity,
      machine_dispatch_capacity, machine_condition_label, machine_status,
      beban_mesin, stand_kwh, stand_bbm, tekanan_oli, temperatur_air,
      phasa_r, phasa_s, phasa_t, tegangan, cos_phi, frequency,
      latitude, longitude, location_accuracy, distance_from_unit, location_status,
      sync_status, report_status, abnormal_notes, field_condition,
      notes, session_id, submitted_at,
    } = req.body;

    const logsheetId = id || local_id;
    if (!logsheetId) {
      return res.status(400).json({ message: 'ID logsheet harus diisi' });
    }

    if (!machine_id) {
      return res.status(400).json({ message: 'machine_id harus diisi' });
    }

    const result = await pool.query(
      `INSERT INTO logsheets (
        id, local_id, proof_id,
        operator_id, operator_name, unit_id, unit_name, machine_id,
        machine_up3, machine_name, machine_brand, machine_type,
        machine_serial_number, machine_generator_code, machine_ownership_status,
        machine_performance_label, machine_capacity, machine_available_capacity,
        machine_dispatch_capacity, machine_condition_label, machine_status,
        beban_mesin, stand_kwh, stand_bbm, tekanan_oli, temperatur_air,
        phasa_r, phasa_s, phasa_t, tegangan, cos_phi, frequency,
        latitude, longitude, location_accuracy, distance_from_unit, location_status,
        sync_status, report_status, abnormal_notes, field_condition,
        notes, session_id, submitted_at
      ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$40,$41,$42,$43)
      ON CONFLICT (id) DO UPDATE SET
        beban_mesin = EXCLUDED.beban_mesin, stand_kwh = EXCLUDED.stand_kwh,
        stand_bbm = EXCLUDED.stand_bbm, tekanan_oli = EXCLUDED.tekanan_oli,
        temperatur_air = EXCLUDED.temperatur_air,
        phasa_r = EXCLUDED.phasa_r, phasa_s = EXCLUDED.phasa_s, phasa_t = EXCLUDED.phasa_t,
        tegangan = EXCLUDED.tegangan, cos_phi = EXCLUDED.cos_phi, frequency = EXCLUDED.frequency,
        sync_status = EXCLUDED.sync_status, notes = EXCLUDED.notes,
        updated_at = NOW()
      RETURNING *`,
      [
        logsheetId, local_id, proof_id,
        operator_id, operator_name, unit_id, unit_name, machine_id,
        machine_up3, machine_name, machine_brand, machine_type,
        machine_serial_number, machine_generator_code, machine_ownership_status,
        machine_performance_label, machine_capacity, machine_available_capacity,
        machine_dispatch_capacity, machine_condition_label, machine_status,
        beban_mesin, stand_kwh, stand_bbm, tekanan_oli, temperatur_air,
        phasa_r, phasa_s, phasa_t, tegangan, cos_phi, frequency,
        latitude, longitude, location_accuracy, distance_from_unit, location_status || 'unknown',
        sync_status || 'pendingSync', report_status || 'onTime', abnormal_notes, field_condition,
        notes, session_id, submitted_at || new Date().toISOString(),
      ]
    );

    res.status(201).json({ message: 'Logsheet berhasil disimpan', data: result.rows[0] });
  } catch (err) {
    console.error('Create logsheet error:', err);
    res.status(500).json({ message: 'Gagal menyimpan logsheet', error: err.message });
  }
});

router.get('/history', authenticate, async (req, res) => {
  try {
    let query = 'SELECT * FROM logsheets';
    const params = [];

    if (req.user.role === 'operator') {
      query += ' WHERE operator_id = $1';
      params.push(req.user.id);
    } else if (req.user.role === 'supervisor' && req.user.unitid) {
      query += ' WHERE unit_id = $1';
      params.push(req.user.unitId);
    }

    query += ' ORDER BY submitted_at DESC';

    if (req.query.limit) {
      query += ` LIMIT ${parseInt(req.query.limit)}`;
    }

    const result = await pool.query(query, params);
    res.json({ data: result.rows });
  } catch (err) {
    console.error('Get history error:', err);
    res.status(500).json({ message: 'Gagal mengambil history logsheet' });
  }
});

router.get('/:id', authenticate, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM logsheets WHERE id = $1 OR local_id = $1', [req.params.id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Logsheet tidak ditemukan' });
    }
    res.json({ data: result.rows[0] });
  } catch (err) {
    console.error('Get logsheet error:', err);
    res.status(500).json({ message: 'Gagal mengambil data logsheet' });
  }
});

router.post('/:id/upload-media', authenticate, upload.fields([
  { name: 'selfie', maxCount: 1 },
  { name: 'machine', maxCount: 1 },
]), async (req, res) => {
  try {
    const files = req.files;
    const updates = [];
    const params = [];
    let paramIdx = 1;

    if (files.selfie && files.selfie.length > 0) {
      updates.push(`selfie_photo_path = $${paramIdx++}`);
      params.push(`/uploads/${files.selfie[0].filename}`);
    }
    if (files.machine && files.machine.length > 0) {
      updates.push(`machine_photo_path = $${paramIdx++}`);
      params.push(`/uploads/${files.machine[0].filename}`);
    }

    if (updates.length === 0) {
      return res.status(400).json({ message: 'Tidak ada file yang diupload' });
    }

    params.push(req.params.id);
    const query = `UPDATE logsheets SET ${updates.join(', ')} WHERE id = $${paramIdx} OR local_id = $${paramIdx} RETURNING *`;

    const result = await pool.query(query, params);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Logsheet tidak ditemukan' });
    }

    res.json({ message: 'Media berhasil diupload', data: result.rows[0] });
  } catch (err) {
    console.error('Upload media error:', err);
    res.status(500).json({ message: 'Gagal upload media' });
  }
});

router.put('/:id/approve', authenticate, authorize('supervisor', 'admin', 'superadmin'), async (req, res) => {
  try {
    const { approval_status, rejection_reason } = req.body;
    if (!approval_status || !['approved', 'rejected'].includes(approval_status)) {
      return res.status(400).json({ message: 'Status approval harus approved atau rejected' });
    }

    const result = await pool.query(
      `UPDATE logsheets SET approval_status = $1, rejection_reason = $2, last_edited_by = $3, last_edited_at = NOW()
       WHERE id = $4 RETURNING *`,
      [approval_status, rejection_reason, req.user.id, req.params.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Logsheet tidak ditemukan' });
    }

    res.json({ message: `Logsheet berhasil ${approval_status === 'approved' ? 'disetujui' : 'ditolak'}`, data: result.rows[0] });
  } catch (err) {
    console.error('Approve logsheet error:', err);
    res.status(500).json({ message: 'Gagal memproses approval' });
  }
});

module.exports = router;
