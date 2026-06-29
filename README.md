# 🐳 SEAPEDIA Monorepo

[![NestJS](https://img.shields.io/badge/NestJS-11.0-E0234E?logo=nestjs&logoColor=white)](https://nestjs.com)
[![Prisma](https://img.shields.io/badge/Prisma-6.19-2D3748?logo=prisma&logoColor=white)](https://prisma.io)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16.0-4169E1?logo=postgresql&logoColor=white)](https://postgresql.org)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Riverpod](https://img.shields.io/badge/Riverpod-3.x-02569B?logo=flutter&logoColor=white)](https://riverpod.dev)

**SEAPEDIA** adalah platform e-commerce multi-role yang menghubungkan Pembeli (Buyer), Penjual (Seller), dan Pengemudi (Driver/Courier) dalam satu ekosistem marketplace. Proyek ini dikelola secara monorepo, mencakup backend REST API berbasis NestJS dan frontend mobile berbasis Flutter.

> [!IMPORTANT]
> Aplikasi ini mendukung platform **Android** dan **Windows**. Namun, desain antarmuka pengguna (UI/UX) dimaksimalkan khusus untuk perangkat **Android** (tampilan mobile). Build platform **Windows** disediakan semata-mata untuk kemudahan evaluasi dan pengujian (*testing*) oleh reviewer di PC.

---

## 🗺️ Panduan Navigasi Monorepo

*   **[⚙️ Dokumentasi Backend](./backend/README.md)**: Konfigurasi env, instalasi lokal, migrasi database (Prisma + PostgreSQL), skema data, arsitektur keamanan, dan dokumentasi Swagger API.
*   **[📱 Dokumentasi Frontend](./frontend/README.md)**: Panduan instalasi aplikasi mobile, arsitektur MVVM, pengelolaan state dengan Riverpod 3.x, interceptor API, penyimpanan aman (Secure Storage), dan build production.

---

## 🌐 Tautan Deployment Backend (Live Demo)

Backend untuk proyek SEAPEDIA ini telah berhasil di-deploy ke Hugging Face Spaces secara publik di URL berikut:
🔗 **[https://lintangnv-seapedia-api.hf.space](https://lintangnv-seapedia-api.hf.space)**
*   **Swagger API Docs (Live)**: **[https://lintangnv-seapedia-api.hf.space/api/docs](https://lintangnv-seapedia-api.hf.space/api/docs)**

> [!NOTE]
> Secara default, aplikasi frontend Flutter diatur untuk langsung terhubung dengan link deployment backend di atas (dikonfigurasi dalam file [dio_provider.dart](file:///d:/KULIAH/kursus/Compfest%20Academy/seleksi/seapedia/frontend/lib/core/network/dio_provider.dart)). Namun, penguji tetap dapat menjalankan backend secara lokal dengan mengikuti panduan di bawah.

---

## 📦 Unduh Aplikasi Pre-built (Download Links)

Untuk mempermudah pengujian tanpa harus membangun (*compile*) kode sumber Flutter secara manual dari awal, Anda dapat mengunduh berkas rilis aplikasi siap pakai berikut:
*   🤖 **Android (APK)**: [Unduh APK Rilis SEAPEDIA (Tulis link download APK Anda di sini)](TULIS_LINK_DOWNLOAD_APK_DI_SINI)
*   💻 **Windows (Executable ZIP)**: [Unduh executable Windows (Tulis link download ZIP Windows Anda di sini)](TULIS_LINK_DOWNLOAD_EXE_DI_SINI)

---

## 🏗️ Arsitektur Sistem

Operasi SEAPEDIA dibagi menjadi empat peran utama: **Admin**, **Seller**, **Buyer**, dan **Driver**. Seluruh interaksi client-server dijembatani melalui REST API yang divalidasi dengan token otentikasi JWT yang memuat informasi peran aktif pengguna.

```mermaid
graph TD
    subgraph Client ["Layer Client (Frontend - Flutter)"]
        Flutter["Aplikasi Mobile Flutter"]
        RP["Riverpod 3.x (State Reactivity)"]
        Dio["Dio Client (Auth Interceptor & Auto-Logout)"]
    end

    subgraph Service ["Layer Service (Backend - NestJS)"]
        Nest["NestJS REST API Engine"]
        Prisma["Prisma ORM Client"]
    end

    subgraph Storage ["Layer Penyimpanan"]
        Postgres[(Database PostgreSQL)]
    end

    subgraph Roles ["Peran Pengguna & Modul"]
        Admin["Admin<br>(Monitoring, Discount Mgmt, Overdue Simulation)"]
        Buyer["Buyer<br>(Address, Wallet, Cart, Checkout, Reviews)"]
        Seller["Seller<br>(Store Profile, Product CRUD, Order Fulfillment)"]
        Driver["Driver<br>(Job Dispatch, Order Delivery, Earnings)"]
    end

    %% Hubungan
    Admin & Buyer & Seller & Driver --> Flutter
    Flutter --> RP
    RP --> Dio
    Dio <-->|REST API / JSON| Nest
    Nest <--> Prisma
    Prisma <--> Postgres
```

---

## ⚙️ Aturan Bisnis Utama (Core Business Rules)

Aplikasi SEAPEDIA menerapkan aturan bisnis secara konsisten baik di frontend maupun backend:

### 1. Multi-Role Management & Session Peran Aktif
*   Satu pengguna non-admin (username) dapat memiliki lebih dari satu peran (misalnya menjadi Buyer sekaligus Seller dan Driver).
*   Setelah login, pengguna yang memiliki lebih dari satu peran **wajib** memilih peran aktif di halaman pemilihan peran (`/select-role`). Pengguna tidak akan dialihkan ke dashboard utama sebelum peran aktif ditentukan.
*   Otorisasi di backend dilakukan berdasarkan **peran aktif yang saat ini digunakan**, bukan seluruh peran yang dimiliki oleh pengguna. Token JWT yang diterbitkan akan menyimpan properti `activeRole` secara spesifik.

### 2. Single-Store Checkout (Aturan Satu Toko)
*   Keranjang belanja pembeli hanya dapat berisi produk-produk yang berasal dari **satu toko yang sama**.
*   Jika pembeli mencoba menambahkan produk dari toko lain, sistem akan memblokir tindakan tersebut di backend (`ConflictException`) dan menampilkan pesan kesalahan yang jelas di frontend, meminta pengguna untuk mengosongkan keranjang belanja terlebih dahulu.

### 3. Perhitungan Discount (Voucher/Promo) & PPN 12%
*   Sistem mendukung dua jenis diskon: **Voucher** (memiliki kuota penggunaan `remainingUsage` dan tanggal kedaluwarsa) serta **Promo** (memiliki tanggal kedaluwarsa saja).
*   **Kombinasi Diskon**: Voucher dan Promo tidak dapat dikombinasikan. Input checkout hanya menerima satu kode diskon.
*   **Formula Perhitungan Final Total**:
    1.  `Subtotal` = Jumlah (`Harga Produk` × `Kuantitas`) untuk seluruh item.
    2.  `Discounted Subtotal` = `max(0, Subtotal - Nilai Diskon)`.
    3.  `Tax Amount (PPN 12%)` = `Discounted Subtotal` × 12%.
    4.  `Final Total` = `Discounted Subtotal` + `Delivery Fee` + `Tax Amount`.
*   Pembeli tidak dapat melakukan checkout jika saldo wallet tidak mencukupi untuk membayar `Final Total`.

### 4. Skema Tarif Pengiriman (Delivery Fee)
Biaya pengiriman ditentukan berdasarkan metode pengiriman yang dipilih saat checkout:
*   **Instant**: Rp20.000 (SLA pengiriman: 24 jam)
*   **Next Day**: Rp15.000 (SLA pengiriman: 48 jam)
*   **Regular**: Rp10.000 (SLA pengiriman: 120 jam / 5 hari)

### 5. Pendapatan Pengemudi (Driver Earnings)
*   Saat pengemudi menyelesaikan tugas pengiriman (`completeJob`), 100% dari biaya pengiriman (`deliveryFee`) dari pesanan tersebut akan dikreditkan secara otomatis sebagai pendapatan pengemudi (`earnings`) pada profil Driver mereka.

### 6. Kebijakan Overdue (Kedaluwarsa SLA), Auto Return/Refund & Simulasi Waktu
*   Sistem memantau setiap pesanan yang belum diselesaikan (status selain `ORDER_COMPLETED` atau `RETURNED`) berdasarkan waktu pemesanan (`createdAt`) dan batas SLA metode pengirimannya.
*   Jika pesanan melewati batas waktu SLA, sistem akan memproses **Auto Return / Refund** secara atomik dalam database transaction:
    *   Status pesanan diubah menjadi `RETURNED` (Dikembalikan).
    *   Dana sebesar `Final Total` dikembalikan sepenuhnya ke saldo dompet Pembeli (Buyer Wallet).
    *   Kuantitas stok produk dikembalikan ke inventaris toko Penjual.
    *   Pekerjaan pengiriman (Delivery Job) yang belum selesai akan dihapus.
    *   Dana transaksi refund dicatat ke dalam riwayat transaksi wallet pembeli dan dikecualikan dari laporan pendapatan penjual.
*   **Simulasi Hari Berikutnya**: Untuk mempermudah pengujian, Admin dapat memajukan waktu sistem (simulasi waktu) secara instan melalui endpoint `@Post('admin/simulate-overdue')` dengan mengirim parameter `daysToAdvance`.

---

## 🔒 Penerapan Keamanan (Security Implementation)

Aplikasi SEAPEDIA dirancang dengan standar keamanan berikut:

1.  **Pencegahan SQL Injection**: Seluruh akses database di backend diimplementasikan menggunakan Prisma ORM. Prisma secara bawaan menggunakan parameterized queries / prepared statements untuk seluruh query, memastikan payload berbahaya tidak dapat dieksekusi sebagai perintah SQL.
2.  **Pencegahan Cross-Site Scripting (XSS)**: Data ulasan aplikasi publik (reviewer name dan comment) disaring menggunakan library `xss` di backend sebelum disimpan ke database. Hal ini memastikan script berbahaya (seperti `<script>`) akan dinonaktifkan secara aman dan dirender sebagai teks biasa di frontend.
3.  **Validasi Input**: Validasi ketat dilakukan di tingkat DTO menggunakan NestJS `ValidationPipe` yang didukung oleh `class-validator`. Kolom penting seperti email, rating, kuantitas, harga, stok, dan nilai diskon divalidasi tipe datanya sebelum diproses.
4.  **Manajemen Sesi yang Aman**: Token JWT disimpan menggunakan `FlutterSecureStorage` pada mobile client untuk enkripsi data di tingkat perangkat.
5.  **Server-Side Role-Based Access Control (RBAC)**: Backend tidak memercayai role yang dideklarasikan oleh frontend. Setiap endpoint dashboard dilindungi dengan `@UseGuards(AuthGuard, RolesGuard)` yang memverifikasi kecocokan peran aktif (`activeRole`) yang terenkripsi di dalam JWT token.

---

## 👥 Akun Demo & Data Awal (Seed Data)

Setelah melakukan migrasi database dan menjalankan script seed, akun administrator berikut akan otomatis terdaftar:

*   **Role**: ADMIN
*   **Username**: `superadmin`
*   **Password**: `adminpassword123`

Untuk peran non-admin (Buyer, Seller, Driver), Anda dapat mendaftarkan akun baru secara langsung di aplikasi mobile atau menggunakan Swagger Docs untuk mempermudah alur simulasi.

---

## 🚀 Panduan Menjalankan Aplikasi Secara Lokal

### Kebutuhan Awal (Prerequisites)
Sebelum menjalankan aplikasi secara lokal, pastikan perangkat Anda telah memenuhi prasyarat lingkungan pengembangan berikut:

#### 1. Backend & Database
*   **Node.js (v22+)** & `npm` untuk mengompilasi dan menjalankan server NestJS.
*   **PostgreSQL (v15+)** yang berjalan secara lokal atau hosting cloud (koneksi diatur melalui `DATABASE_URL` di `.env`).

#### 2. Frontend Flutter (Umum)
*   **Flutter SDK (v3.x)** & **Dart SDK** terinstal dan telah didaftarkan pada PATH environment system Anda.
*   **Git** terinstal di perangkat untuk mengambil dependencies Flutter.
*   **Verifikasi Lingkungan**: Jalankan perintah `flutter doctor` di terminal Anda untuk memeriksa kesiapan development kit.

#### 3. Prasyarat Target Platform **Windows (Desktop)**
*   **Visual Studio 2022** (edisi Community, Professional, atau Enterprise) — **Wajib**.
*   Saat instalasi Visual Studio, centang beban kerja (workload) **"Desktop development with C++"** (Pengembangan desktop dengan C++).
*   Pastikan komponen default berikut di dalam beban kerja tersebut ikut terinstal:
    *   *MSVC v143 - VS 2022 C++ x64/x86 build tools*
    *   *Windows 10 SDK* atau *Windows 11 SDK*
    *   *C++ CMake tools for Windows*

#### 4. Prasyarat Target Platform **Android (Mobile)**
*   **Android Studio** (versi terbaru disarankan) atau **Android SDK Command-line Tools** (`cmdline-tools`).
*   **Android SDK** terinstal (Android SDK Platform-Tools, SDK Build-Tools, dan SDK Platform target).
*   **Java Development Kit (JDK)**: Direkomendasikan JDK 17 (biasanya otomatis terpaket di dalam folder instalasi Android Studio).
*   **Persetujuan Lisensi Android SDK**: Wajib menyetujui lisensi SDK dengan menjalankan perintah berikut di terminal:
    ```bash
    flutter doctor --android-licenses
    ```
*   **Perangkat Pengujian**:
    *   *Emulator*: Konfigurasikan Virtual Device (AVD) melalui Device Manager di Android Studio.
    *   *Perangkat Fisik*: Aktifkan **Developer Options** (Opsi Pengembang) dan **USB Debugging** pada HP Android Anda, serta instal *Google USB Driver* di Windows (jika menggunakan HP fisik).

### Langkah 1: Persiapan Database dan Backend
1. Masuk ke direktori backend:
   ```bash
   cd backend
   ```
2. Instal dependensi backend:
   ```bash
   npm install
   ```
3. Buat file `.env` di dalam folder `backend` dan sesuaikan koneksi database Anda:
   ```env
   DATABASE_URL="postgresql://username:password@localhost:5432/seapedia_db?schema=public"
   JWT_SECRET="kcgkejedukbelalangsembah"
   PORT=3000
   ```
4. Sinkronisasikan database, jalankan migrasi, dan seed data awal:
   ```bash
   npx prisma db push
   npx prisma migrate dev --name init
   npx prisma db seed
   ```
5. Jalankan server backend dalam mode development:
   ```bash
   npm run start:dev
   ```
   *Backend akan berjalan di [http://localhost:3000](http://localhost:3000).*
   *Swagger API Documentation dapat diakses di [http://localhost:3000/api/docs](http://localhost:3000/api/docs).*

### Langkah 2: Menjalankan Aplikasi Mobile (Frontend)
1. Buka terminal baru dan masuk ke direktori frontend:
   ```bash
   cd frontend
   ```
2. Dapatkan dependensi Dart:
   ```bash
   flutter pub get
   ```
3. Periksa perangkat emulator atau browser yang aktif:
   ```bash
   flutter devices
   ```
4. Jalankan aplikasi pada perangkat target (misalnya web/chrome atau emulator):
   ```bash
   flutter run -d chrome
   ```
   *(Aplikasi mobile mendukung hot reload untuk mempercepat pengembangan)*

---

## 🧪 Alur Pengujian E2E (End-to-End Demo Guide)

Untuk menguji seluruh fitur marketplace SEAPEDIA dari awal hingga akhir, ikuti skenario berikut:

1.  **Ulasan Publik & Katalog (Guest)**
    *   Buka aplikasi tanpa login. Akses halaman produk (`/products`) untuk melihat daftar katalog.
    *   Buka halaman ulasan (`/reviews`) dan kirim rating & komentar mengenai aplikasi. Konfirmasi ulasan tampil secara aman tanpa merusak tata letak.
2.  **Registrasi & Login Multi-Role**
    *   Lakukan registrasi akun baru dengan mencentang tiga peran sekaligus: **Buyer**, **Seller**, dan **Driver**.
    *   Login menggunakan akun tersebut. Halaman pemilihan peran (`/select-role`) akan muncul.
    *   Pilih peran **Seller** untuk masuk ke dashboard penjual.
3.  **Pembuatan Toko & Produk (Seller)**
    *   Pada dashboard penjual, klik menu Toko dan buat nama toko unik Anda (misalnya: "Seapedia Store").
    *   Masuk ke menu Manajemen Produk, tambahkan produk baru (masukkan nama, deskripsi, harga, dan stok). Produk ini sekarang akan muncul di katalog publik.
4.  **Belanja, Keranjang & Checkout (Buyer)**
    *   Kembali ke menu profil, ganti peran aktif Anda menjadi **Buyer**.
    *   Akses dompet pembeli (Wallet) lalu lakukan simulasi Top Up saldo.
    *   Cari produk yang baru saja Anda buat sebagai Seller tadi, tambahkan ke keranjang.
    *   *Pengujian Aturan Satu Toko*: Coba mendaftar akun lain, buat produk dengan toko berbeda, lalu coba tambahkan produk toko kedua tersebut ke keranjang. Aplikasi akan menolak dan meminta keranjang dibersihkan terlebih dahulu.
    *   Lakukan checkout. Masukkan alamat pengiriman, pilih metode pengiriman (Instant/Next Day/Regular), dan masukkan kode diskon (jika ada).
    *   Konfirmasi rincian biaya: Subtotal, Diskon, Ongkir, PPN 12%, dan Total Bayar. Konfirmasi saldo terpotong dan stok produk berkurang. Status pesanan awal adalah `Sedang Dikemas`.
5.  **Proses Pesanan (Seller)**
    *   Beralih peran kembali ke **Seller**.
    *   Masuk ke riwayat pesanan masuk, temukan pesanan pembeli tadi, lalu klik tombol **Proses Pesanan**.
    *   Status pesanan akan berubah dari `Sedang Dikemas` menjadi `Menunggu Pengirim`.
6.  **Pengantaran & Pendapatan (Driver)**
    *   Beralih peran menjadi **Driver**.
    *   Buka halaman Cari Pekerjaan (`/driver/find-jobs`). Pesanan yang berstatus `Menunggu Pengirim` akan muncul di sini.
    *   Klik **Ambil Pekerjaan**. Status pesanan berubah menjadi `Sedang Dikirim`.
    *   Klik **Konfirmasi Selesai** setelah pesanan diantarkan. Status pesanan berubah menjadi `Pesanan Selesai`.
    *   Periksa saldo pendapatan Driver Anda. Saldo tersebut harus bertambah tepat sebesar biaya ongkir pesanan tersebut.
7.  **Simulasi Overdue & Auto Return (Admin/Overdue)**
    *   Login menggunakan akun admin (`superadmin`).
    *   Buat transaksi baru sebagai Buyer (selesaikan hingga checkout, status `Sedang Dikemas` atau `Menunggu Pengirim`).
    *   Melalui Swagger API docs (`/api/docs`) atau UI Admin, jalankan simulasi memajukan waktu (simulate-overdue) sebanyak 5 hari (default).
    *   Verifikasi bahwa pesanan tersebut sekarang otomatis berstatus `Dikembalikan` (RETURNED), saldo pembeli di-refund penuh, dan stok produk dikembalikan ke semula secara aman.
