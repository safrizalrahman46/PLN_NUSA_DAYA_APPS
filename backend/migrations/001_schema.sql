-- ============================================================
-- PLTD Logsheet - Database Schema
-- PostgreSQL Migration
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- ENUM TYPES
-- ============================================================
DO $$ BEGIN
  CREATE TYPE user_role AS ENUM ('operator', 'supervisor', 'admin', 'superadmin');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE machine_status AS ENUM ('operasi', 'standby', 'gangguan-rusak');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE logsheet_sync_status AS ENUM ('draft', 'pendingSync', 'pendingEdit', 'synced', 'failed');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE logsheet_report_status AS ENUM ('onTime', 'late', 'missing', 'abnormal');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE logsheet_approval_status AS ENUM ('pendingReview', 'approved', 'rejected');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE location_status AS ENUM ('valid', 'outsideArea', 'permissionDenied', 'gpsOff', 'unknown');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE notification_priority AS ENUM ('tinggi', 'sedang', 'rendah');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE notification_target AS ENUM ('logsheet', 'approval', 'error', 'general');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE error_status AS ENUM ('baru', 'diproses', 'selesai');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE unit_status AS ENUM ('active', 'inactive');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ============================================================
-- TABLE: units
-- ============================================================
CREATE TABLE IF NOT EXISTS units (
  id            VARCHAR(20) PRIMARY KEY,
  name          VARCHAR(255) NOT NULL,
  location_name VARCHAR(255),
  latitude      DOUBLE PRECISION,
  longitude     DOUBLE PRECISION,
  radius_meter  DOUBLE PRECISION DEFAULT 250,
  status        unit_status DEFAULT 'active',
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLE: machines
-- ============================================================
CREATE TABLE IF NOT EXISTS machines (
  id                  VARCHAR(20) PRIMARY KEY,
  unit_id             VARCHAR(20) NOT NULL REFERENCES units(id) ON DELETE CASCADE,
  up3                 VARCHAR(100),
  machine_name        VARCHAR(255) NOT NULL,
  brand               VARCHAR(100),
  machine_type        VARCHAR(100),
  serial_number       VARCHAR(100),
  generator_code      VARCHAR(50),
  ownership_status    VARCHAR(10) DEFAULT 'P',
  performance_label   VARCHAR(10),
  capacity            VARCHAR(50),
  available_capacity  VARCHAR(50),
  dispatch_capacity   VARCHAR(50),
  status              machine_status DEFAULT 'operasi',
  condition_label     VARCHAR(100),
  created_at          TIMESTAMPTZ DEFAULT NOW(),
  updated_at          TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_machines_unit_id ON machines(unit_id);

-- ============================================================
-- TABLE: users
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
  id            VARCHAR(20) PRIMARY KEY,
  name          VARCHAR(255) NOT NULL,
  username      VARCHAR(100) UNIQUE NOT NULL,
  password      VARCHAR(255) NOT NULL,
  role          user_role NOT NULL DEFAULT 'operator',
  unit_id       VARCHAR(20) REFERENCES units(id) ON DELETE SET NULL,
  unit_name     VARCHAR(255),
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_unit_id ON users(unit_id);

-- ============================================================
-- TABLE: logsheets
-- ============================================================
CREATE TABLE IF NOT EXISTS logsheets (
  id                      VARCHAR(50) PRIMARY KEY,
  local_id                VARCHAR(50),
  proof_id                VARCHAR(100),

  -- Relations
  operator_id             VARCHAR(20) REFERENCES users(id) ON DELETE SET NULL,
  operator_name           VARCHAR(255),
  unit_id                 VARCHAR(20) REFERENCES units(id) ON DELETE SET NULL,
  unit_name               VARCHAR(255),
  machine_id              VARCHAR(20) REFERENCES machines(id) ON DELETE SET NULL,

  -- Denormalized machine snapshot
  machine_up3                 VARCHAR(100),
  machine_name                VARCHAR(255),
  machine_brand               VARCHAR(100),
  machine_type                VARCHAR(100),
  machine_serial_number       VARCHAR(100),
  machine_generator_code      VARCHAR(50),
  machine_ownership_status    VARCHAR(10),
  machine_performance_label   VARCHAR(10),
  machine_capacity            VARCHAR(50),
  machine_available_capacity  VARCHAR(50),
  machine_dispatch_capacity   VARCHAR(50),
  machine_condition_label     VARCHAR(100),
  machine_status              machine_status,

  -- Operational measurements
  beban_mesin             DOUBLE PRECISION,
  stand_kwh               DOUBLE PRECISION,
  stand_bbm               DOUBLE PRECISION,
  tekanan_oli             DOUBLE PRECISION,
  temperatur_air          DOUBLE PRECISION,
  phasa_r                 DOUBLE PRECISION,
  phasa_s                 DOUBLE PRECISION,
  phasa_t                 DOUBLE PRECISION,
  tegangan                DOUBLE PRECISION,
  cos_phi                 DOUBLE PRECISION,
  frequency               DOUBLE PRECISION,

  -- Location data
  latitude                DOUBLE PRECISION,
  longitude               DOUBLE PRECISION,
  location_accuracy       DOUBLE PRECISION,
  distance_from_unit      DOUBLE PRECISION,
  location_status         location_status DEFAULT 'unknown',

  -- Media
  selfie_photo_path       TEXT,
  machine_photo_path      TEXT,

  -- Status & workflow
  submitted_at            TIMESTAMPTZ DEFAULT NOW(),
  sync_status             logsheet_sync_status DEFAULT 'draft',
  report_status           logsheet_report_status DEFAULT 'onTime',
  abnormal_notes          TEXT,
  field_condition         TEXT,
  approval_status         logsheet_approval_status DEFAULT 'pendingReview',
  rejection_reason        TEXT,
  session_id              VARCHAR(100),
  last_edited_by          VARCHAR(20) REFERENCES users(id) ON DELETE SET NULL,
  last_edited_at          TIMESTAMPTZ,
  archived_at             TIMESTAMPTZ,
  notes                   TEXT,
  sync_error_message      TEXT,

  -- Timestamps
  created_at              TIMESTAMPTZ DEFAULT NOW(),
  updated_at              TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_logsheets_operator_id ON logsheets(operator_id);
CREATE INDEX IF NOT EXISTS idx_logsheets_unit_id ON logsheets(unit_id);
CREATE INDEX IF NOT EXISTS idx_logsheets_machine_id ON logsheets(machine_id);
CREATE INDEX IF NOT EXISTS idx_logsheets_submitted_at ON logsheets(submitted_at);
CREATE INDEX IF NOT EXISTS idx_logsheets_sync_status ON logsheets(sync_status);
CREATE INDEX IF NOT EXISTS idx_logsheets_approval_status ON logsheets(approval_status);
CREATE INDEX IF NOT EXISTS idx_logsheets_local_id ON logsheets(local_id);
CREATE INDEX IF NOT EXISTS idx_logsheets_proof_id ON logsheets(proof_id);

-- ============================================================
-- TABLE: notifications
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title           VARCHAR(255) NOT NULL,
  description     TEXT,
  time            TIMESTAMPTZ DEFAULT NOW(),
  priority        notification_priority DEFAULT 'sedang',
  type            VARCHAR(50) DEFAULT 'general',
  target_type     notification_target DEFAULT 'general',
  is_read         BOOLEAN DEFAULT FALSE,
  user_id         VARCHAR(20) REFERENCES users(id) ON DELETE CASCADE,
  local_id        VARCHAR(50),
  error_log_id    VARCHAR(50),
  unit_id         VARCHAR(20),
  payload         JSONB DEFAULT '{}',
  recipient_roles JSONB DEFAULT '[]',
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);

-- ============================================================
-- TABLE: error_logs
-- ============================================================
CREATE TABLE IF NOT EXISTS error_logs (
  id              VARCHAR(50) PRIMARY KEY,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  page            VARCHAR(255),
  error_type      VARCHAR(100),
  message         TEXT,
  detail          TEXT,
  user_id         VARCHAR(20),
  user_name       VARCHAR(255),
  role            VARCHAR(50),
  stack_trace     TEXT,
  status          error_status DEFAULT 'baru',
  source          VARCHAR(100) DEFAULT 'app',
  metadata        JSONB DEFAULT '{}'
);

CREATE INDEX IF NOT EXISTS idx_error_logs_status ON error_logs(status);
CREATE INDEX IF NOT EXISTS idx_error_logs_created_at ON error_logs(created_at);

-- ============================================================
-- TABLE: audit_logs
-- ============================================================
CREATE TABLE IF NOT EXISTS audit_logs (
  id              VARCHAR(100) PRIMARY KEY,
  entity_id       VARCHAR(50),
  user_id         VARCHAR(20),
  user_name       VARCHAR(255),
  role            VARCHAR(50),
  edited_at       TIMESTAMPTZ DEFAULT NOW(),
  sync_status     VARCHAR(50),
  changes         JSONB DEFAULT '[]'
);

CREATE INDEX IF NOT EXISTS idx_audit_logs_entity_id ON audit_logs(entity_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON audit_logs(user_id);

-- ============================================================
-- TABLE: retention_logs
-- ============================================================
CREATE TABLE IF NOT EXISTS retention_logs (
  id              VARCHAR(50) PRIMARY KEY,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  action          VARCHAR(100),
  affected_count  INTEGER DEFAULT 0,
  file_name       VARCHAR(255),
  note            TEXT
);

-- ============================================================
-- UPDATED_AT TRIGGER FUNCTION
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to tables
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_units_updated_at') THEN
    CREATE TRIGGER trg_units_updated_at BEFORE UPDATE ON units FOR EACH ROW EXECUTE FUNCTION update_updated_at();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_machines_updated_at') THEN
    CREATE TRIGGER trg_machines_updated_at BEFORE UPDATE ON machines FOR EACH ROW EXECUTE FUNCTION update_updated_at();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_users_updated_at') THEN
    CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_logsheets_updated_at') THEN
    CREATE TRIGGER trg_logsheets_updated_at BEFORE UPDATE ON logsheets FOR EACH ROW EXECUTE FUNCTION update_updated_at();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_notifications_updated_at') THEN
    CREATE TRIGGER trg_notifications_updated_at BEFORE UPDATE ON notifications FOR EACH ROW EXECUTE FUNCTION update_updated_at();
  END IF;
END $$;
