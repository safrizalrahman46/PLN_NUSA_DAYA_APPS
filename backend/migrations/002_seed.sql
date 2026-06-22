-- ============================================================
-- PLTD Logsheet - Seed Data
-- ============================================================

-- Password untuk semua user: "123" (bcrypt hash)
-- Hash: $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy

-- ============================================================
-- UNITS
-- ============================================================
INSERT INTO units (id, name, location_name, latitude, longitude, radius_meter, status) VALUES
('U01', 'PLTD KRAYAN', 'Krayan, Kalimantan Utara', 3.8920, 115.7200, 250, 'active'),
('U02', 'PLTD LONG LAYU', 'Long Layu, Kalimantan Utara', 3.6600, 115.5800, 250, 'active'),
('U03', 'PLTD LUMBIS', 'Lumbis, Kalimantan Utara', 3.8500, 116.0200, 250, 'active'),
('U04', 'PLTD MALINAU', 'Malinau, Kalimantan Utara', 3.5800, 116.6200, 250, 'active'),
('U05', 'PLTD NUNUKAN', 'Nunukan, Kalimantan Utara', 4.1360, 117.6700, 250, 'active'),
('U06', 'PLTD TANJUNG SELOR', 'Tanjung Selor, Kalimantan Utara', 2.8400, 117.3700, 250, 'active'),
('U07', 'PLTD TARAKAN', 'Tarakan, Kalimantan Utara', 3.3270, 117.5780, 250, 'active');

-- ============================================================
-- MACHINES
-- ============================================================
INSERT INTO machines (id, unit_id, up3, machine_name, brand, machine_type, serial_number, generator_code, ownership_status, performance_label, capacity, available_capacity, dispatch_capacity, status, condition_label) VALUES
('M001', 'U01', 'KALTARA', 'PLTD KRAYAN #01 (DEUTZ)', 'DEUTZ', 'BF8M1015C', 'SN-D001', 'PLTD-HSD', 'P', 'YA', '500 kW', '450 kW', '400 kW', 'operasi', 'BEROPERASI'),
('M002', 'U01', 'KALTARA', 'PLTD KRAYAN #02 (DEUTZ)', 'DEUTZ', 'BF8M1015C', 'SN-D002', 'PLTD-HSD', 'P', 'YA', '500 kW', '450 kW', '400 kW', 'standby', 'STANDBY'),
('M003', 'U02', 'KALTARA', 'PLTD LONG LAYU #01 (MAN)', 'MAN', 'D2866LE', 'SN-M001', 'PLTD-HSD', 'P', 'YA', '300 kW', '280 kW', '250 kW', 'operasi', 'BEROPERASI'),
('M004', 'U02', 'KALTARA', 'PLTD LONG LAYU #02 (MAN)', 'MAN', 'D2866LE', 'SN-M002', 'PLTD-HSD', 'P', 'TIDAK', '300 kW', '200 kW', '200 kW', 'gangguan-rusak', 'RUSAK PERMANEN'),
('M005', 'U03', 'KALTARA', 'PLTD LUMBIS #01 (MTU)', 'MTU', '8V396TC54', 'SN-MTU01', 'PLTD-HSD', 'P', 'YA', '800 kW', '750 kW', '700 kW', 'operasi', 'BEROPERASI'),
('M006', 'U03', 'KALTARA', 'PLTD LUMBIS #02 (MTU)', 'MTU', '8V396TC54', 'SN-MTU02', 'PLTD-HSD', 'P', 'YA', '800 kW', '750 kW', '700 kW', 'operasi', 'BEROPERASI'),
('M007', 'U04', 'KALTARA', 'PLTD MALINAU #01 (CUMMINS)', 'CUMMINS', 'QSK60G', 'SN-C001', 'PLTD-HSD', 'P', 'YA', '1000 kW', '950 kW', '900 kW', 'operasi', 'BEROPERASI'),
('M008', 'U05', 'KALTARA', 'PLTD NUNUKAN #01 (DEUTZ)', 'DEUTZ', 'TCD2015V06', 'SN-D003', 'PLTD-HSD', 'P', 'YA', '400 kW', '380 kW', '350 kW', 'operasi', 'BEROPERASI'),
('M009', 'U06', 'KALTARA', 'PLTD TANJUNG SELOR #01 (MAN)', 'MAN', 'D2842LE', 'SN-M003', 'PLTD-HSD', 'P', 'YA', '600 kW', '550 kW', '500 kW', 'operasi', 'BEROPERASI'),
('M010', 'U07', 'KALTARA', 'PLTD TARAKAN #01 (MTU)', 'MTU', '12V4000G63', 'SN-MTU03', 'PLTD-HSD', 'P', 'YA', '1500 kW', '1400 kW', '1300 kW', 'operasi', 'BEROPERASI');

-- ============================================================
-- USERS
-- ============================================================
-- Password: 123 (bcrypt hash)
INSERT INTO users (id, name, username, password, role, unit_id, unit_name) VALUES
('AD1', 'Admin Nusa Daya', 'admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'admin', 'U01', 'PLTD KRAYAN'),
('SA1', 'Super Admin', 'superadmin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'superadmin', NULL, 'ALL'),
('SP1', 'Supervisor Wilayah', 'supervisor', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'supervisor', 'U01', 'PLTD KRAYAN'),
('OP1', 'Operator Krayan', 'operator', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'operator', 'U01', 'PLTD KRAYAN'),
('OP2', 'Operator Long Layu', 'operator2', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'operator', 'U02', 'PLTD LONG LAYU'),
('OP3', 'Operator Lumbis', 'operator3', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'operator', 'U03', 'PLTD LUMBIS');

-- ============================================================
-- SAMPLE LOGSHEETS
-- ============================================================
INSERT INTO logsheets (
  id, local_id, proof_id, operator_id, operator_name, unit_id, unit_name,
  machine_id, machine_up3, machine_name, machine_brand, machine_capacity,
  machine_status, machine_condition_label,
  beban_mesin, stand_kwh, stand_bbm, tekanan_oli, temperatur_air,
  phasa_r, phasa_s, phasa_t, tegangan, cos_phi, frequency,
  latitude, longitude, location_accuracy, distance_from_unit, location_status,
  sync_status, report_status, approval_status, submitted_at
) VALUES
(
  'LGS-001', 'LOC-001', 'NP-PLTD-2401010800-001',
  'OP1', 'Operator Krayan', 'U01', 'PLTD KRAYAN',
  'M001', 'KALTARA', 'PLTD KRAYAN #01 (DEUTZ)', 'DEUTZ', '500 kW',
  'operasi', 'BEROPERASI',
  350.5, 12500.75, 4500.25, 4.2, 85.0,
  150.2, 148.5, 149.8, 380.0, 0.85, 50.1,
  3.8920, 115.7200, 10.5, 5.2, 'valid',
  'synced', 'onTime', 'approved',
  '2024-01-01 08:00:00+08'
),
(
  'LGS-002', 'LOC-002', 'NP-PLTD-2401010900-002',
  'OP1', 'Operator Krayan', 'U01', 'PLTD KRAYAN',
  'M001', 'KALTARA', 'PLTD KRAYAN #01 (DEUTZ)', 'DEUTZ', '500 kW',
  'operasi', 'BEROPERASI',
  355.2, 12505.80, 4510.50, 4.1, 86.0,
  151.0, 149.2, 150.5, 381.0, 0.86, 50.0,
  3.8920, 115.7200, 8.2, 5.2, 'valid',
  'synced', 'onTime', 'approved',
  '2024-01-01 09:00:00+08'
),
(
  'LGS-003', 'LOC-003', 'NP-PLTD-2401011000-003',
  'OP1', 'Operator Krayan', 'U01', 'PLTD KRAYAN',
  'M002', 'KALTARA', 'PLTD KRAYAN #02 (DEUTZ)', 'DEUTZ', '500 kW',
  'standby', 'STANDBY',
  0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0,
  3.8925, 115.7210, 12.0, 8.5, 'valid',
  'synced', 'onTime', 'pendingReview',
  '2024-01-01 10:00:00+08'
);

-- ============================================================
-- SAMPLE NOTIFICATIONS
-- ============================================================
INSERT INTO notifications (id, title, description, priority, type, target_type, is_read, user_id) VALUES
('00000000-0000-0000-0000-000000000001', 'Logsheet Baru', 'Logsheet baru dari PLTD KRAYAN perlu direview', 'sedang', 'approval', 'approval', FALSE, 'SP1'),
('00000000-0000-0000-0000-000000000002', 'Sinkronisasi Berhasil', 'Data logsheet berhasil disinkronkan ke server', 'rendah', 'sync', 'general', TRUE, 'OP1'),
('00000000-0000-0000-0000-000000000003', 'Peringatan Abnormal', 'Terdapat pengukuran abnormal pada PLTD KRAYAN #01', 'tinggi', 'error', 'error', FALSE, 'SP1');
