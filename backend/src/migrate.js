require('dotenv').config();
const fs = require('fs');
const path = require('path');
const pool = require('./config/database');
const bcrypt = require('bcryptjs');

async function migrate() {
  console.log('Memulai migrasi database...');
  console.log(`Host: ${process.env.DB_HOST || 'localhost'}`);
  console.log(`Database: ${process.env.DB_NAME || 'pltd_logsheet'}`);

  try {
    const schemaPath = path.join(__dirname, '..', 'migrations', '001_schema.sql');
    const schemaSQL = fs.readFileSync(schemaPath, 'utf8');
    await pool.query(schemaSQL);
    console.log('Schema berhasil dibuat.');

    const seedPath = path.join(__dirname, '..', 'migrations', '002_seed.sql');

    const existingUsers = await pool.query('SELECT COUNT(*)::int as count FROM users');
    if (existingUsers.rows[0].count === 0) {
      const seedSQL = fs.readFileSync(seedPath, 'utf8');
      await pool.query(seedSQL);
      console.log('Seed data berhasil dimasukkan.');
    } else {
      console.log('Data sudah ada, skip seed.');
    }

    console.log('\nMigrasi selesai!');
    console.log('\nAkun default (password: 123):');
    console.log('  Admin:      admin');
    console.log('  Superadmin: superadmin');
    console.log('  Supervisor: supervisor');
    console.log('  Operator:   operator');
    console.log('  Operator 2: operator2');
    console.log('  Operator 3: operator3');
  } catch (err) {
    console.error('Migrasi gagal:', err.message);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

migrate();
