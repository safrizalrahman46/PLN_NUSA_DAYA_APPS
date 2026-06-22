# PLTD Logsheet API

REST API untuk aplikasi **PLN Nusa Daya Monitoring (PLTD Logsheet Operasi)**.
Backend ini **tanpa website/UI**, hanya API murni untuk melayani aplikasi Flutter.

---

## Persyaratan Server

| Komponen | Spesifikasi |
|----------|-------------|
| OS | Linux / Windows Server |
| Node.js | v18 atau lebih baru |
| PostgreSQL | 14 atau lebih baru |
| RAM | Minimal 1 GB |
| Storage | Minimal 10 GB + untuk file foto |

---

## 1. Install PostgreSQL

### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib -y
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### Windows
- Download installer dari https://www.postgresql.org/download/windows/
- Jalankan installer, catat password user `postgres`
- Pastikan service PostgreSQL berjalan

### Setup Database
```bash
sudo -u postgres psql
```

```sql
CREATE DATABASE pltd_logsheet;
CREATE USER pltd_user WITH PASSWORD 'password_kuat_disini';
GRANT ALL PRIVILEGES ON DATABASE pltd_logsheet TO pltd_user;
\q
```

---

## 2. Install Node.js

### Linux (Ubuntu/Debian)
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install nodejs -y
node --version
npm --version
```

### Windows
- Download installer dari https://nodejs.org/ (versi LTS v20 atau lebih baru)
- Jalankan installer, pastikan "Add to PATH" tercentang

---

## 3. Konfigurasi Backend

Clone atau copy folder `backend/` ke server, lalu:

```bash
cd backend
npm install
```

### Edit File `.env`

```env
# Server
PORT=8000
NODE_ENV=production

# Database PostgreSQL
DB_HOST=localhost
DB_PORT=5432
DB_NAME=pltd_logsheet
DB_USER=pltd_user
DB_PASSWORD=password_kuat_disini

# JWT (GANTI dengan string acak yang panjang dan aman)
JWT_SECRET=buat_string_acak_panjang_sampe_50_karakter
JWT_EXPIRES_IN=24h

# File Upload
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=5242880
```

---

## 4. Migrasi Database

```bash
npm run migrate
```

Perintah ini akan:
- Membuat 8 tabel: `units`, `machines`, `users`, `logsheets`, `notifications`, `error_logs`, `audit_logs`, `retention_logs`
- Memasukkan data contoh (seed)

### Akun Default (password: `123`)

| Username | Role | Unit |
|----------|------|------|
| admin | Admin | PLTD KRAYAN |
| superadmin | Super Admin | Semua |
| supervisor | Supervisor | PLTD KRAYAN |
| operator | Operator | PLTD KRAYAN |
| operator2 | Operator | PLTD LONG LAYU |
| operator3 | Operator | PLTD LUMBIS |

---

## 5. Menjalankan Server

### Production
```bash
npm start
```

### Development (dengan auto-reload)
```bash
npm run dev
```

Server akan berjalan di `http://0.0.0.0:8000`

### Cek Status
```bash
curl http://localhost:8000/api/health
```
Response: `{"status":"ok","database":"connected","timestamp":"..."}`

---

## 6. Deploy dengan PM2 (Production - Linux)

```bash
npm install -g pm2
pm2 start src/index.js --name pltd-logsheet-api
pm2 save
pm2 startup
```

### Setup Nginx sebagai Reverse Proxy (Opsional)

```nginx
server {
    listen 80;
    server_name api.domain-anda.com;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        client_max_body_size 10M;
    }
}
```

---

## 7. Update IP di Aplikasi Flutter

Edit file `lib/core/constants/app_config.dart` di project Flutter:

```dart
static const String baseUrl = 'http://IP_SERVER_ANDA:8000/api';
```

Ganti `IP_SERVER_ANDA` dengan IP publik server backend.

> **Catatan**: Untuk production dengan HTTPS, gunakan domain dan SSL certificate.

---

## 8. Endpoint API Lengkap

| Method | Endpoint | Auth | Role |
|--------|----------|------|------|
| POST | `/api/login` | - | Semua |
| POST | `/api/logout` | Token | Semua |
| GET | `/api/me` | Token | Semua |
| GET | `/api/units` | Token | Semua |
| GET | `/api/units/:id` | Token | Semua |
| POST | `/api/units` | Token | admin, superadmin |
| PUT | `/api/units/:id` | Token | admin, superadmin |
| DELETE | `/api/units/:id` | Token | superadmin |
| GET | `/api/machines` | Token | Semua |
| GET | `/api/machines/:id` | Token | Semua |
| POST | `/api/machines` | Token | admin, superadmin |
| PUT | `/api/machines/:id` | Token | admin, superadmin |
| DELETE | `/api/machines/:id` | Token | superadmin |
| POST | `/api/logsheets` | Token | operator |
| GET | `/api/logsheets/history` | Token | operator, supervisor |
| GET | `/api/logsheets/:id` | Token | Semua |
| POST | `/api/logsheets/:id/upload-media` | Token | operator |
| PUT | `/api/logsheets/:id/approve` | Token | supervisor, admin, superadmin |
| GET | `/api/supervisor/dashboard` | Token | supervisor, admin, superadmin |
| GET | `/api/supervisor/monitoring` | Token | supervisor, admin, superadmin |
| GET | `/api/notifications` | Token | Semua |
| PUT | `/api/notifications/:id/read` | Token | Semua |
| PUT | `/api/notifications/read-all` | Token | Semua |
| GET | `/api/reports` | Token | supervisor, admin, superadmin |
| GET | `/api/health` | - | Semua |

---

## 9. Struktur Database

```
units ──── machines
  │
  ├──── users
  │
  └──── logsheets ──── notifications
                      ├── error_logs
                      ├── audit_logs
                      └── retention_logs
```

### Tabel Utama: `logsheets`

Tabel ini menyimpan data operasional mesin PLTD dengan ~50 field termasuk:

- **Identitas**: id, proof_id, operator, unit, mesin
- **Pengukuran**: beban mesin (kW), stand KWH, stand BBM, tekanan oli, temperatur air, phasa R/S/T, tegangan, cos phi, frekuensi
- **Lokasi**: latitude, longitude, akurasi GPS, jarak dari unit
- **Media**: path foto selfie, path foto mesin
- **Status**: sync_status, report_status, approval_status

---

## 10. Troubleshooting

### Server tidak bisa start
```bash
# Cek error
npm start

# Pastikan PostgreSQL berjalan
sudo systemctl status postgresql

# Test koneksi database
psql -h localhost -U pltd_user -d pltd_logsheet -c "SELECT 1"
```

### File upload gagal
```bash
# Pastikan folder uploads ada
ls -la backend/uploads/

# Jika tidak ada, buat
mkdir -p backend/uploads
chmod 755 backend/uploads
```

### Lupa password
Hash bcrypt untuk password "123":
```
$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
```

Update password di database:
```sql
UPDATE users SET password = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy' WHERE username = 'admin';
```
