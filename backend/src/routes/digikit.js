const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const pool = require('../config/database');
const { authenticate, JWT_SECRET } = require('../middleware/auth');

const router = express.Router();

// Helper to parse status
function parseMachineStatus(value) {
  switch (value?.trim().toLowerCase()) {
    case 'operasi':
    case 'operation':
    case 'active':
    case 'beroperasi':
      return 'operasi';
    case 'standby':
    case 'pemeliharaan':
    case 'maintenance':
      return 'standby';
    case 'gangguan-rusak':
    case 'gangguan_rusak':
    case 'gangguan/rusak':
    case 'rusak':
      return 'gangguan-rusak';
    default:
      return 'operasi';
  }
}

// 1. GET /api/login — login endpoint
router.get('/login', async (req, res) => {
  try {
    const { username, password } = req.query;
    if (!username || !password) {
      return res.status(400).json({ message: 'Username dan password harus diisi' });
    }

    const result = await pool.query(
      'SELECT id, name, username, password, role, unit_id, unit_name FROM users WHERE username = $1',
      [username]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ message: 'Username atau password salah' });
    }

    const user = result.rows[0];
    const valid = await bcrypt.compare(password, user.password);
    if (!valid) {
      return res.status(401).json({ message: 'Username atau password salah' });
    }

    const token = jwt.sign(
      { id: user.id, name: user.name, username: user.username, role: user.role, unitId: user.unit_id, unitName: user.unit_name },
      JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.json({
      user: {
        id: user.id,
        name: user.name,
        username: user.username,
        email: `${user.username}@nusadaya.net`,
        email_verified_at: null,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        kd_region: '05',
        role: user.role
      },
      token: token,
      token_type: 'Bearer'
    });
  } catch (err) {
    console.error('DIGIKIT login error:', err);
    res.status(500).json({ message: 'Terjadi kesalahan server' });
  }
});

// 2. GET /api/v1/format-logsheet-pltd
router.get('/v1/format-logsheet-pltd', authenticate, async (req, res) => {
  try {
    const { kd_region, kd_area, kd_unit } = req.query;

    if (kd_unit) {
      // Get detailed logsheet format for the specified unit
      const unitResult = await pool.query('SELECT * FROM units WHERE id = $1', [kd_unit]);
      if (unitResult.rows.length === 0) {
        return res.status(404).json({ message: 'Unit tidak ditemukan' });
      }
      const unit = unitResult.rows[0];

      const machinesResult = await pool.query('SELECT * FROM machines WHERE unit_id = $1', [kd_unit]);
      const machines = machinesResult.rows.map((m, index) => ({
        nomor: index + 1,
        nama_mesin: `${m.machine_name} (${m.brand}) s/n ${m.serial_number}`,
        id_mesin: m.id,
        kode_mesin_silm: m.generator_code || '',
        sn: m.serial_number || '',
        dt: parseInt(m.capacity) || 100,
        kd_jenis_bahan_bakar: 'B35'
      }));

      // Build the raw text template
      let textTemplate = `LAPORAN LOGSHEET PLTD\n${unit.name}\nid unit: ${unit.id}\ntgl : ${new Date().toISOString().substring(0, 10)}\njam : 08:00\nnama operator:\n\n`;
      machines.forEach((m) => {
        textTemplate += `${m.nomor}. ${m.nama_mesin}\nid mesin: ${m.id_mesin}\nkode mesin: ${m.kode_mesin_silm}\nsn: ${m.sn}\ndt: ${m.dt}\ndaya mampu:\nbeban:\nstand kwh:\nstand bbm:\nphasa r:\nphasa s:\nphasa t:\ntek oli:\ntemp air pendingin:\ntegangan:\nfrequency:\ncos phi:\njam kerja mesin:\nstatus mesin:\nKwh produksi :\npemakaian bbm :\njenis bahan bakar : B35\nket:\n\n`;
      });

      return res.json({
        message: 'Format logsheet PLTD',
        filters: { kd_region: kd_region || '05', kd_area: kd_area || '40', kd_unit: kd_unit },
        unit: {
          kd_unit: unit.id,
          nama_unit: unit.name,
          kd_region: kd_region || '05',
          kd_area: kd_area || '40',
          nama_area: unit.location_name || ''
        },
        format: {
          title: 'LAPORAN LOGSHEET PLTD',
          unit_name: unit.name,
          unit_code: unit.id,
          date: new Date().toISOString().substring(0, 10),
          time: '08:00',
          operator_name: '',
          mesin: machines,
          text: textTemplate
        }
      });
    }

    // Default: List units filtered by region and area
    let query = 'SELECT * FROM units';
    const params = [];
    if (kd_area) {
      query += ' WHERE location_name LIKE $1';
      params.push(`%${kd_area}%`);
    }

    const result = await pool.query(query, params);
    const units = result.rows.map(u => ({
      kd_unit: u.id,
      nama_unit: u.name,
      kd_region: kd_region || '05',
      kd_area: kd_area || '40',
      nama_area: u.location_name || 'SITE BONTANG'
    }));

    res.json({
      message: 'Daftar unit logsheet PLTD',
      filters: {
        kd_region: kd_region || '05',
        kd_area: kd_area || null,
        kd_unit: null
      },
      units: units
    });
  } catch (err) {
    console.error('Get format logsheet error:', err);
    res.status(500).json({ message: 'Gagal mengambil format logsheet' });
  }
});

// 3. POST /api/v1/logsheet-pltd — Submit text logsheet
router.post('/v1/logsheet-pltd', authenticate, async (req, res) => {
  try {
    const { kd_region } = req.query;
    const { message_text } = req.body;

    if (!message_text) {
      return res.status(400).json({ message: 'message_text wajib diisi' });
    }

    // Parse the message_text
    const lines = message_text.split('\n').map(l => l.trim());
    let unitName = '';
    let unitId = '';
    let date = '';
    let time = '';
    let operatorName = '';

    const machines = [];
    let currentMachine = null;

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      if (!line) continue;

      if (line.startsWith('LAPORAN LOGSHEET PLTD')) continue;

      if (line.toLowerCase().startsWith('id unit:')) {
        unitId = line.split(':')[1].trim();
        continue;
      }
      if (line.toLowerCase().startsWith('tgl :')) {
        date = line.split(':')[1].trim();
        continue;
      }
      if (line.toLowerCase().startsWith('jam :')) {
        time = line.split(':')[1].trim();
        continue;
      }
      if (line.toLowerCase().startsWith('nama operator:')) {
        operatorName = line.split(':')[1].trim();
        continue;
      }

      if (!unitName && i === 1 && !line.includes(':')) {
        unitName = line;
        continue;
      }

      const machineMatch = line.match(/^(\d+)\.\s*(.*)/);
      if (machineMatch) {
        if (currentMachine) {
          machines.push(currentMachine);
        }
        currentMachine = {
          nomor: parseInt(machineMatch[1]),
          machineName: machineMatch[2],
          values: {}
        };
        continue;
      }

      if (currentMachine) {
        const parts = line.split(':');
        if (parts.length >= 2) {
          const key = parts[0].trim().toLowerCase();
          const val = parts.slice(1).join(':').trim();
          currentMachine.values[key] = val;
        }
      }
    }

    if (currentMachine) {
      machines.push(currentMachine);
    }

    // Create database records
    const submittedAt = new Date(`${date}T${time}:00`);
    const results = [];

    for (const m of machines) {
      const machineId = m.values['id mesin'] || m.values['id_mesin'];
      if (!machineId) continue;

      // Query machine detail to seed denormalized columns
      const machDetailResult = await pool.query('SELECT * FROM machines WHERE id = $1', [machineId]);
      const md = machDetailResult.rows[0] || {};

      const id = uuidv4();
      const localId = uuidv4();
      const proofId = `NP-PLTD-${date.replace(/-/g, '')}${time.replace(/:/g, '')}-${machineId}`;

      const beban = parseFloat(m.values['beban']) || 0;
      const standKwh = parseFloat(m.values['stand kwh']) || parseFloat(m.values['stand_kwh']) || 0;
      const standBbm = parseFloat(m.values['stand bbm']) || parseFloat(m.values['stand_bbm']) || 0;
      const tekOli = parseFloat(m.values['tek oli']) || parseFloat(m.values['tek_oli']) || 0;
      const tempAir = parseFloat(m.values['temp air pendingin']) || parseFloat(m.values['tem_air']) || 0;
      const phasaR = parseFloat(m.values['phasa r']) || parseFloat(m.values['arus_r']) || 0;
      const phasaS = parseFloat(m.values['phasa s']) || parseFloat(m.values['arus_s']) || 0;
      const phasaT = parseFloat(m.values['phasa t']) || parseFloat(m.values['arus_t']) || 0;
      const tegangan = parseFloat(m.values['tegangan']) || parseFloat(m.values['teg']) || 380;
      const frequency = parseFloat(m.values['frequency']) || 50;
      const cosPhi = parseFloat(m.values['cos phi']) || parseFloat(m.values['cos_phi']) || 0.85;
      const notes = m.values['ket'] || m.values['keterangan'] || '-';
      const statusMesin = parseMachineStatus(m.values['status mesin'] || m.values['kd_status']);

      await pool.query(
        `INSERT INTO logsheets (
          id, local_id, proof_id, operator_id, operator_name, unit_id, unit_name,
          machine_id, machine_up3, machine_name, machine_brand, machine_type,
          machine_serial_number, machine_generator_code, machine_ownership_status,
          machine_performance_label, machine_capacity, machine_available_capacity,
          machine_dispatch_capacity, machine_condition_label, machine_status,
          beban_mesin, stand_kwh, stand_bbm, tekanan_oli, temperatur_air,
          phasa_r, phasa_s, phasa_t, tegangan, cos_phi, frequency,
          latitude, longitude, location_accuracy, distance_from_unit, location_status,
          sync_status, report_status, approval_status, field_condition, notes, session_id, submitted_at
        ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$40,$41,$42,$43,$44)`,
        [
          id, localId, proofId, req.user.id, operatorName || req.user.name, unitId, unitName,
          machineId, md.up3 || 'KALIMANTAN 3', md.machine_name || m.machineName, md.brand, md.machine_type,
          md.serial_number, md.generator_code, md.ownership_status,
          md.performance_label, md.capacity, md.available_capacity,
          md.dispatch_capacity, md.condition_label, statusMesin,
          beban, standKwh, standBbm, tekOli, tempAir,
          phasaR, phasaS, phasaT, tegangan, cosPhi, frequency,
          0.0, 0.0, 0.0, 0.0, 'unknown',
          'synced', 'onTime', 'pendingReview', 'Normal', notes, uuidv4(), submittedAt
        ]
      );
    }

    res.json({
      success: true,
      message: 'Laporan logsheet berhasil disimpan.',
      data: {
        id: Math.floor(Math.random() * 1000) + 1,
        kd_region: kd_region || '05',
        kd_unit: unitId,
        nama_unit: unitName
      }
    });
  } catch (err) {
    console.error('Submit DIGIKIT logsheet error:', err);
    res.status(500).json({ message: 'Gagal memproses logsheet' });
  }
});

// 4. POST/GET /api/logsheet — Get summary list of logsheet reports
router.all('/logsheet', authenticate, async (req, res) => {
  try {
    const { kd_region, tanggal, kd_unit } = req.query;
    const reqTanggal = tanggal || req.body.tanggal || req.query.tanggal;
    const reqUnit = kd_unit || req.body.kd_unit || req.query.kd_unit;

    if (!reqTanggal) {
      return res.status(400).json({ message: 'Tanggal wajib diisi' });
    }

    let unitsQuery = 'SELECT id, name FROM units';
    const unitsParams = [];
    if (reqUnit) {
      unitsQuery += ' WHERE id = $1';
      unitsParams.push(reqUnit);
    }
    const unitsResult = await pool.query(unitsQuery, unitsParams);

    const logsheetsResult = await pool.query(
      `SELECT id, unit_id, machine_id, submitted_at FROM logsheets WHERE DATE(submitted_at) = $1`,
      [reqTanggal]
    );

    const data = unitsResult.rows.map(unit => {
      const slots = {};
      for (let h = 0; h < 24; h++) {
        const hStr = String(h).padStart(2, '0');
        slots[`${hStr}:00`] = { status: 'not done', id_beban: null };
        slots[`${hStr}:30`] = { status: 'not done', id_beban: null };
      }

      const unitLogs = logsheetsResult.rows.filter(l => l.unit_id === unit.id);
      for (const log of unitLogs) {
        const time = new Date(log.submitted_at);
        const hour = time.getHours();
        const min = time.getMinutes();
        const timeStr = `${String(hour).padStart(2, '0')}:${min < 30 ? '00' : '30'}`;
        slots[timeStr] = {
          status: 'done',
          id_beban: `${unit.id}-${log.machine_id}-${reqTanggal}-${timeStr}:00`
        };
      }

      return {
        id: Math.floor(Math.random() * 1000) + 1,
        kd_region: kd_region || '05',
        kd_unit: unit.id,
        nama_unit: unit.name,
        jam_operasional: 24,
        logsheet_pltd: slots
      };
    });

    res.json({
      success: true,
      data: data
    });
  } catch (err) {
    console.error('Get reports summary error:', err);
    res.status(500).json({ message: 'Gagal mengambil data summary' });
  }
});

// 5. POST/GET /api/getLogsheet/:idBebanUld — Get detailed logsheet record
router.all('/getLogsheet/:idBebanUld', authenticate, async (req, res) => {
  try {
    const idBebanUld = req.params.idBebanUld;
    const parts = idBebanUld.split('-');
    const unitId = parts[0];
    const machineId = parts[1];
    const tanggal = parts.slice(2, 5).join('-');
    const jam = parts.slice(5).join(':');

    const unitResult = await pool.query('SELECT name FROM units WHERE id = $1', [unitId]);
    if (unitResult.rows.length === 0) {
      return res.status(404).json({ message: 'Unit tidak ditemukan' });
    }

    const machinesResult = await pool.query('SELECT * FROM machines WHERE unit_id = $1', [unitId]);
    const logsheetsResult = await pool.query(
      `SELECT * FROM logsheets WHERE unit_id = $1 AND DATE(submitted_at) = $2 AND EXTRACT(HOUR FROM submitted_at) = $3`,
      [unitId, tanggal, parseInt(jam.split(':')[0]) || 0]
    );

    const bebanMesinList = machinesResult.rows.map(machine => {
      const log = logsheetsResult.rows.find(l => l.machine_id === machine.id);
      return {
        id_beban: `${unitId}-${machine.id}-${tanggal}-${jam}`,
        id_mesin: machine.id,
        nama_mesin: machine.machine_name,
        no_seri: machine.serial_number,
        kode_mesin_silm: machine.generator_code || null,
        kd_status: log ? (log.machine_status === 'operasi' ? '01' : '02') : '02',
        daya_mampu: parseFloat(machine.capacity) || 100,
        beban: log ? log.beban_mesin : null,
        stand_kwh: log ? log.stand_kwh : null,
        stand_bbm: log ? log.stand_bbm : null,
        jkm: log ? 0 : null,
        tek_oli: log ? log.tekanan_oli : null,
        tem_air: log ? log.temperatur_air : null,
        arus_r: log ? log.phasa_r : null,
        arus_s: log ? log.phasa_s : null,
        arus_t: log ? log.phasa_t : null,
        teg: log ? log.tegangan : null,
        cos_phi: log ? String(log.cos_phi) : null,
        frequency: log ? log.frequency : null,
        keterangan: log ? log.notes : '-',
        operator: log ? log.operator_name : '-'
      };
    });

    res.json({
      success: true,
      data: {
        beban_uld: {
          id_beban: idBebanUld,
          kd_unit: unitId,
          nama_unit: unitResult.rows[0].name,
          tanggal: tanggal,
          jam: jam
        },
        beban_mesin: bebanMesinList
      }
    });
  } catch (err) {
    console.error('Get detailed logsheet error:', err);
    res.status(500).json({ message: 'Gagal mengambil detail logsheet' });
  }
});

module.exports = router;
