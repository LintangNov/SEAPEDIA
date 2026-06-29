# 📱 Seapedia Mobile App — Flutter Experience

Ini adalah frontend aplikasi mobile untuk **Seapedia Marketplace**, dibangun menggunakan **Flutter SDK** dan **Dart**. Aplikasi ini dioptimalkan untuk lingkungan multi-platform (Android, iOS, dan Web) serta menerapkan standar manajemen state dan jaringan modern.

---

## 🚀 Memulai (Getting Started)

### 1. Kebutuhan Awal
Pastikan Anda telah mengonfigurasi **Flutter SDK (v3.x)** di environment path perangkat Anda. Pastikan juga emulator target (Android/iOS) atau browser web siap digunakan.

### 2. Persiapan Lokal
Masuk ke folder `/frontend` dan jalankan perintah berikut untuk mengunduh seluruh dependensi Dart:
```bash
cd frontend
flutter pub get
```

---

## 📐 Pola Arsitektur MVVM (Model-View-ViewModel)

Arsitektur aplikasi mobile ini dirancang menggunakan pola **MVVM** yang terisolasi dengan baik guna memudahkan pengujian dan pemeliharaan kode:

```text
frontend/lib/
├── core/
│   ├── network/          # Konfigurasi Dio Client & Interceptor Otentikasi
│   ├── router/           # Navigasi Aplikasi dengan GoRouter
│   ├── storage/          # Penyimpanan Aman (Secure Storage Provider)
│   └── widgets/          # Komponen UI Bersama (Button, Input, Card, Shells)
└── features/             # Folder Fitur Berdasarkan SubSistem (auth, buyer, seller, dll.)
    └── <nama_fitur>/
        ├── data/         # Model Data & Repositori API
        └── presentation/ # Pengendali UI (Controller/ViewModel) & Layar Tampilan (View)
```

### Pembagian Tugas Komponen:
1.  **Model (`/data/` models)**: Dart class murni yang merepresentasikan skema data dan translasi JSON (dari/ke API), bersih dari framework Flutter.
2.  **View (`/presentation/` screens & widgets)**: Representasi UI deklaratif Flutter yang mengamati perubahan state dari ViewModel dan meneruskan interaksi pengguna ke Controller.
3.  **ViewModel/Controller (`/presentation/` controllers)**: State notifier yang dikelola oleh **Riverpod 3.x** untuk mengontrol keadaan UI (loading, error, detail data) dan berkoordinasi dengan data repositori.
4.  **Repository (`/data/` repositories)**: Layer penyedia data yang memanggil endpoint backend menggunakan client Dio.

---

## 🌐 Koneksi Jaringan & Interceptor Otentikasi

Pengelolaan REST API diimplementasikan menggunakan **Dio (v5.x)** yang diatur secara terpusat di dalam [dio_provider.dart](file:///d:/KULIAH/kursus/Compfest%20Academy/seleksi/seapedia/frontend/lib/core/network/dio_provider.dart):

*   **Penyelarasan IP Otomatis**: Aplikasi mendeteksi target emulator yang sedang aktif:
    *   **Emulator Android**: Dialihkan ke IP khusus `http://10.0.2.2:3000` agar terhubung ke localhost mesin host.
    *   **iOS Emulator / Web**: Dialihkan langsung ke `http://localhost:3000`.
*   **Otentikasi Interceptor**: Menangkap token JWT dari `FlutterSecureStorage` dan menyisipkan header `Authorization: Bearer <accessToken>` pada setiap request keluar secara otomatis.
*   **Deteksi Sesi Habis**: Jika backend merespon dengan status HTTP `401 Unauthorized` (karena token kadaluwarsa atau di-logout), interceptor akan memicu fungsi `logout()` secara otomatis untuk mengamankan data sesi lokal.

---

## ⚙️ Penanganan Aturan Bisnis pada Frontend

Aplikasi mobile mengawal aturan bisnis SEAPEDIA melalui fitur-fitur berikut:

### 1. Guard Navigasi Pemilihan Peran (Role Selection Guard)
*   Sistem navigasi dikelola oleh **GoRouter** di [app_router.dart](file:///d:/KULIAH/kursus/Compfest%20Academy/seleksi/seapedia/frontend/lib/core/router/app_router.dart).
*   Jika pengguna memiliki beberapa peran (misal Buyer & Seller) dan baru saja login, status sesi diubah menjadi `AuthState.partial`.
*   Pengguna akan diarahkan ke halaman `/select-role` dan diblokir dari rute privat lainnya hingga memilih peran aktifnya. Setelah peran aktif dipilih dan token baru didapatkan, status berubah menjadi `AuthState.authenticated`.

### 2. Validasi Keranjang Satu Toko (Single-Store Cart Enforcement)
*   Saat Buyer menambahkan item ke keranjang (`CartScreen`), frontend mengirim data ke API.
*   Jika produk yang ditambahkan berasal dari toko yang berbeda dengan produk yang sudah ada di keranjang, frontend akan menerima error `ConflictException` dari backend.
*   Frontend akan menangkap pesan kesalahan tersebut dan menampilkan dialog modal konfirmasi yang jelas kepada pengguna agar mereka dapat memilih untuk **mengosongkan keranjang belanja** terlebih dahulu sebelum menambahkan produk baru.

### 3. Tampilan Informasi Peran Aktif & Saldo Dompet
*   Peran aktif pengguna selalu ditampilkan di Navbar utama atau bagian atas halaman profil (`ProfileScreen`).
*   Header aplikasi menampilkan detail finansial khusus peran aktif (Saldo Dompet untuk Buyer, Total Pendapatan untuk Seller/Driver).

---

## 💻 Cara Menjalankan & Membangun Aplikasi

### 🔍 Mencari Emulator/Perangkat yang Tersedia
Pastikan emulator Android, simulator iOS, atau browser web Anda sudah aktif:
```bash
flutter devices
```

### 🏃 Menjalankan Aplikasi (Mode Development)
Jalankan perintah berikut untuk menjalankan aplikasi:
```bash
# Menjalankan pada perangkat default yang aktif
flutter run

# Menjalankan pada ID perangkat tertentu
flutter run -d <id-perangkat>

# Menjalankan di Browser Chrome
flutter run -d chrome
```
*(Tekan tombol `r` di terminal untuk memicu Hot Reload saat mengubah kode)*

### 📦 Membangun Paket Produksi (Release Build)
Untuk memaketkan aplikasi ke dalam berkas siap rilis pada masing-masing platform:

```bash
# Membangun file APK Android (Hasil di build/app/outputs/flutter-apk/app-release.apk)
flutter build apk --release

# Membangun berkas App Bundle Android (untuk Google Play)
flutter build appbundle --release

# Membangun executable Windows (Hasil di build/windows/runner/Release/)
flutter build windows --release

# Membangun file distribusi Web (Hasil di build/web/)
flutter build web --release
```

---

## 📦 Unduh Aplikasi Pre-built (Download Links)
Untuk mempermudah penguji/reviewer menjalankan aplikasi tanpa harus meng-compile kode sumber dari awal:
*   🤖 **Android (APK)**: [Unduh APK Rilis SEAPEDIA (Tulis link download APK Anda di sini)](TULIS_LINK_DOWNLOAD_APK_DI_SINI)
*   💻 **Windows (Executable ZIP)**: [Unduh executable Windows (Tulis link download ZIP Windows Anda di sini)](TULIS_LINK_DOWNLOAD_EXE_DI_SINI)
