# ⚡ PLTD Logsheet Mobile

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter">
  <img src="https://img.shields.io/badge/Dart-3.x-blue?logo=dart">
  <img src="https://img.shields.io/badge/Platform-Android-success">
  <img src="https://img.shields.io/badge/License-Private-red">
  <img src="https://img.shields.io/badge/Status-Production%20Ready-brightgreen">
</p>

<p align="center">
Mobile application for <b>PLTD Logsheet Reporting</b> integrated with the <b>WACB (Web Application Control Board)</b> system at PLN Nusa Daya.
</p>

---

# 📱 Overview

PLTD Logsheet Mobile is an Android application designed to replace the previous **WhatsApp Bot** reporting process.

Instead of sending operational reports through WhatsApp, operators can now:

- Login securely
- Select Unit
- Fill in Logsheet
- Submit reports directly to the WACB API
- Automatically synchronize operational data
- Update WACB Dashboard in real-time

The goal is to simplify operational reporting while improving data accuracy, speed, and monitoring.

---

# ✨ Features

## 🔐 Authentication

- Secure Login
- Bearer Token Authentication
- Auto Login
- Session Management

---

## 📋 Logsheet Reporting

- Dynamic Logsheet Form
- Automatic Machine Loading
- Operator Information
- Date & Time Picker
- Validation
- Auto Format Generator

---

## 🔄 WACB Integration

- Login API
- Get Format Logsheet
- Submit Logsheet
- Get Report
- Detail Report

Fully integrated with the official WACB REST API.

---

## 📡 Synchronization

- Online Sync
- Offline Queue
- Auto Retry
- Background Synchronization
- Sync Status

---

## 📊 Dashboard

- Daily Report Summary
- Success Reports
- Failed Reports
- Pending Reports
- Synchronization Status

---

## 📁 History

- Report History
- Detail Report
- Retry Failed Report
- Sync Log

---

## 🔒 Security

- Flutter Secure Storage
- HTTPS Communication
- Bearer Authentication
- Secure Session

---

# 🏗 System Architecture

```
             ┌────────────────────┐
             │   Flutter Mobile   │
             └─────────┬──────────┘
                       │
                       │ REST API
                       ▼
             ┌────────────────────┐
             │     WACB API       │
             └─────────┬──────────┘
                       │
                       ▼
             ┌────────────────────┐
             │   WACB Database    │
             └─────────┬──────────┘
                       │
                       ▼
             ┌────────────────────┐
             │ WACB Dashboard Web │
             └────────────────────┘
```

---

# 🚀 Workflow

```
Operator Login
        │
        ▼
Authentication
        │
        ▼
Select Unit
        │
        ▼
Load Logsheet Format
        │
        ▼
Fill Report
        │
        ▼
Submit
        │
        ▼
WACB API
        │
        ▼
Database
        │
        ▼
Dashboard Updated
```

---

# 📦 Project Structure

```
lib/
│
├── core/
│
├── models/
│
├── services/
│
├── repository/
│
├── providers/
│
├── screens/
│
├── widgets/
│
├── utils/
│
├── routes/
│
└── main.dart
```

---

# 📸 Screenshots

## Login

<img width="350" src="https://github.com/user-attachments/assets/06da927c-4b45-4c84-ac04-6a3c90b7942e">

---

## Dashboard

<img width="350" src="https://github.com/user-attachments/assets/7ea79911-3612-49f1-ad89-96a8793dff60">

---

## Unit Selection

<img width="350" src="https://github.com/user-attachments/assets/aaa48adf-2c4c-41ab-9a2b-f48d8f955672">

---

## Machine List

<img width="350" src="https://github.com/user-attachments/assets/31d40695-8dc5-49c1-9900-ae025b9fd344">

---

## Logsheet Input

<img width="350" src="https://github.com/user-attachments/assets/44133f6d-82d2-4799-b413-fffb16ce2564">

---

## Detail Form

<img width="350" src="https://github.com/user-attachments/assets/018d2c45-cd35-4c0d-ac32-e092d55704a3">

---

## Synchronization

<img width="350" src="https://github.com/user-attachments/assets/d7079e03-4867-42dd-ad34-8f2dec10747d">

---

## History

<img width="350" src="https://github.com/user-attachments/assets/0cffb847-9b98-442f-a17e-3d315d1f0c6b">

---

## Detail Report

<img width="350" src="https://github.com/user-attachments/assets/7c32cfe8-6f3c-4bd1-ae5d-c001e2bc29e9">

---

## Dashboard Monitoring

<img width="700" src="https://github.com/user-attachments/assets/0b592596-59a2-4f79-b93f-1e6a80bd949c">

---

## Reporting

<img width="700" src="https://github.com/user-attachments/assets/958410d8-d51b-4590-975a-d755076ab8fb">

---

## History Report

<img width="700" src="https://github.com/user-attachments/assets/7b20eed3-dbe3-4d9a-849c-5960e18e505a">

---

## API Monitoring

<img width="700" src="https://github.com/user-attachments/assets/9ef5813c-c859-43ac-9cef-7326816d3b56">

---

## Synchronization Status

<img width="700" src="https://github.com/user-attachments/assets/d13647e4-1c68-4a27-8b0f-9f8046fc90ab">

---

# ⚙️ Getting Started

Clone repository

```bash
git clone https://github.com/yourusername/pltd_logsheet.git
```

Install packages

```bash
flutter pub get
```

Run application

```bash
flutter run
```

Build APK

```bash
flutter build apk
```

---

# 🛠 Tech Stack

| Technology | Description |
|------------|-------------|
| Flutter | Mobile Framework |
| Dart | Programming Language |
| REST API | Backend Communication |
| HTTP | API Client |
| Flutter Secure Storage | Secure Authentication |
| Provider / Riverpod | State Management |
| SQLite / Hive | Offline Storage |

---

# 📡 API Integration

The application communicates directly with the WACB REST API.

Available endpoints include:

- Authentication
- Get Unit
- Get Logsheet Format
- Submit Logsheet
- Report History
- Detail Report

---

# 🔄 Synchronization Flow

```
Offline
      │
      ▼
Local Storage
      │
      ▼
Internet Available
      │
      ▼
Auto Sync
      │
      ▼
Success
      │
      ▼
WACB Dashboard Updated
```

---

# 📈 Future Improvements

- Push Notification
- Background Sync Service
- QR Login
- Face Authentication
- Biometric Login
- Multi Region Support
- Dark Mode
- Export PDF
- Export Excel
- Real-Time Monitoring

---

# 👨‍💻 Developer

Developed for

**PLN Nusa Daya**

PLTD Operational Reporting System

Integrated with

**WACB (Web Application Control Board)**

---

# 📄 License

This project is intended for internal operational use.

© 2026 PLN Nusa Daya. All Rights Reserved.
