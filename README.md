# PLN Logsheet - PLTD Operasional Monitoring

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.x-success)](https://riverpod.dev)
[![License](https://img.shields.io/badge/License-MIT-green)](#license)

Aplikasi mobile untuk memantau operasional dan pencatatan logsheet mesin PLTD (Pembangkit Listrik Tenaga Diesel) secara real-time dengan fitur GPS validation, offline-first architecture, dan koordinasi tim terintegrasi.

## ✨ Fitur Utama

- 📋 **Logsheet Management** - Buat, edit, dan kelola laporan operasional mesin PLTD
- 📍 **GPS Validation** - Validasi lokasi operator dengan akurasi real-time
- 📸 **Photo Documentation** - Ambil foto langsung dari aplikasi untuk dokumentasi lapangan
- 🔌 **Offline First** - Bekerja tanpa internet, data tersinkron otomatis saat online
- 👥 **Koordinasi Tim** - Operator dan supervisor bekerja dalam satu platform
- 🎯 **Dashboard Analytics** - Ringkasan operasional dengan visualisasi data
- 🔐 **Authentication** - Sistem login aman untuk operator & supervisor
- 📱 **Responsive UI** - Interface modern dan animatif yang user-friendly

## 🏗️ Arsitektur

```
lib/
├── core/                    # Core utilities & constants
│   ├── constants/          # Colors, routes, strings, config
│   ├── network/            # Dio client, API exception handling
│   ├── permissions/        # Location, camera permissions
│   ├── theme/              # App theme, text styles
│   ├── utils/              # Helpers (date, distance, validator)
│   └── widgets/            # Reusable UI components
├── data/                    # Data layer
│   ├── local/              # Hive local storage, token storage
│   ├── models/             # Data models, enums
│   ├── remote/             # API endpoints (auth, logsheet, machine, etc)
│   └── repositories/       # Data repository layer
└── features/               # Feature modules
    ├── splash/
    ├── onboarding/
    ├── auth/
    ├── dashboard/
    ├── logsheet/
    ├── camera/
    ├── history/
    ├── location/
    ├── profile/
    ├── reports/
    ├── supervisor/
    ├── notifications/
    └── sync/
```

### Tech Stack

| Layer | Technology |
|-------|-----------|
| State Management | Riverpod |
| Local Storage | Hive |
| HTTP Client | Dio |
| Chart/Analytics | Flutter Charts |
| Image Picker | image_picker |
| Location | geolocator |
| Date Parsing | intl |

## 📋 Persyaratan

Before running this project, make sure you have:

- **Flutter SDK**: Version 3.x or later
- **Dart SDK**: Version 3.x or later
- **Android SDK**: Min API 21 (Android 5.0)
- **Java JDK**: Version 11 or later (for Gradle build)
- **Git**: For version control

### Instalasi Flutter

1. Download Flutter dari [flutter.dev](https://flutter.dev/docs/get-started/install)
2. Extract dan tambahkan ke PATH
3. Verify instalasi:
   ```bash
   flutter doctor
   ```

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/pln-logsheet.git
cd PLN_NUSA_DAYA_APPS
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Generate Code (Riverpod & Model Generator)
```bash
dart run build_runner build
```

### 4. Run Development
```bash
flutter run
```

### 5. Build Release APK
```bash
flutter build apk --release
```
APK akan tersimpan di: `build/app/outputs/flutter-apk/app-release.apk`

### 6. Build Release AAB (untuk Google Play)
```bash
flutter build appbundle --release
```

## 📱 Testing

### Unit Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/features/auth_test.dart
```

### Run with Coverage
```bash
flutter test --coverage
```

## 🔑 API Integration

### Set Environment Variables

Create `.env` file di root project:
```env
BASE_URL=https://your-api.com
API_VERSION=v1
TIMEOUT=30000
```

### API Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/api/auth/login` | User authentication |
| GET | `/api/logsheet` | Fetch logsheet data |
| POST | `/api/logsheet` | Create new logsheet |
| PUT | `/api/logsheet/:id` | Update logsheet |
| DELETE | `/api/logsheet/:id` | Delete logsheet |
| GET | `/api/machine` | Get machine list |
| POST | `/api/sync` | Sync offline data |

## 📊 Database Schema

### Local Storage (Hive)

```dart
// Logsheet Model
class Logsheet {
  String id;
  String machineId;
  DateTime timestamp;
  String operatorId;
  String description;
  List<String> photoUrls;
  LocationData location;
  SyncStatus syncStatus;
}

// User Model
class User {
  String id;
  String name;
  String email;
  String role; // operator | supervisor
  String token;
}
```

## 🎨 UI Components

### Reusable Widgets
- `AppButton` - Primary action button dengan gradient
- `AppTextField` - Text input dengan validation
- `AppCard` - Content card dengan shadow
- `AppDropdown` - Dropdown selector
- `AppLoading` - Loading indicator
- `StatusBadge` - Status label
- `SectionTitle` - Section header

## 🔒 Security

- ✅ Token-based authentication (JWT)
- ✅ Secure local storage dengan encryption
- ✅ HTTPS only untuk API calls
- ✅ Permission handling untuk sensitive features
- ✅ Input validation & sanitization

## 📈 Performance

- ✅ Code splitting dengan Riverpod
- ✅ Image caching & optimization
- ✅ Lazy loading untuk long lists
- ✅ Offline-first data sync
- ✅ Memory efficient dengan disposal management

## 🐛 Troubleshooting

### Build Issues

**Error: "this and base files have different roots"**
```bash
# Solusi: Copy project ke C: drive dulu sebelum build
cp -r . C:\project-name
cd C:\project-name
flutter build apk --release
```

**Error: "Android SDK not found"**
```bash
flutter config --android-sdk /path/to/android/sdk
```

**Error: "Java version mismatch"**
```bash
flutter config --jdk-dir /path/to/java/jdk
```

### Runtime Issues

**No permission untuk location?**
- Pastikan permissions di AndroidManifest.xml sudah di-request
- User harus grant permission saat pertama kali

**Image tidak load?**
- Pastikan assets sudah di-declare di pubspec.yaml
- Jalankan `flutter pub get` & `flutter clean` lalu rebuild

## 📦 Release Checklist

- [ ] Update version di `pubspec.yaml`
- [ ] Update `CHANGELOG.md`
- [ ] Run tests dan pastikan semua pass
- [ ] Build APK release dan test di device
- [ ] Create git tag: `git tag v1.0.0`
- [ ] Push ke GitHub dengan tags
- [ ] Upload ke Play Store atau distributor lain

## 🤝 Contributing

Kontribusi sangat diterima! Ikuti langkah ini:

1. Fork repository
2. Create feature branch: `git checkout -b feature/NewFeature`
3. Commit changes: `git commit -m "Add NewFeature"`
4. Push ke branch: `git push origin feature/NewFeature`
5. Open Pull Request

### Coding Standards

- Follow Dart style guide
- Use meaningful variable names
- Add comments untuk complex logic
- Keep functions small & focused
- Write tests untuk new features

## 📝 License

Project ini under MIT License - see [LICENSE](LICENSE) file for details.

## 📞 Support & Contact

- 📧 Email: support@pln-logsheet.com
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/pln-logsheet/issues)
- 📚 Docs: [Wiki](https://github.com/yourusername/pln-logsheet/wiki)

## 🙏 Acknowledgments

- Flutter & Dart teams untuk awesome framework
- Riverpod untuk state management
- Community contributors

---

**Made with ❤️ for PLN NUSA DAYA**

Last Updated: May 16, 2026
