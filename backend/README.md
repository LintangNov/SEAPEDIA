---
title: Seapedia API
emoji: 🐳
colorFrom: blue
colorTo: green
sdk: docker
pinned: false
---

# ⚙️ Seapedia Backend — NestJS Engine

Ini adalah mesin REST API utama untuk aplikasi Seapedia, dibangun menggunakan framework progressive Node.js [NestJS](https://nestjs.com), [Prisma ORM](https://prisma.io), dan didukung oleh database [PostgreSQL](https://postgresql.org).

---

## 🌐 Tautan Deployment Backend (Live Demo)

Backend untuk proyek SEAPEDIA ini telah berhasil di-deploy ke Hugging Face Spaces secara publik di URL berikut:
🔗 **[https://lintangnv-seapedia-api.hf.space](https://lintangnv-seapedia-api.hf.space)**
*   **Swagger API Docs (Live)**: **[https://lintangnv-seapedia-api.hf.space/api/docs](https://lintangnv-seapedia-api.hf.space/api/docs)**

---

## 🚀 Memulai (Getting Started)

### 1. Kebutuhan Instalasi
Pastikan Anda memiliki **Node.js (v22+)** dan **npm** terinstal secara global, serta memiliki instance **PostgreSQL** yang berjalan.

### 2. Instalasi Lokal
Akses folder `/backend` dan instal dependensi lokal:
```bash
cd backend
npm install
```

---

## 🔒 Variabel Lingkungan (Environment Variables)

Buat file `.env` di root folder `/backend` untuk mendefinisikan konfigurasi berikut:

```env
DATABASE_URL="postgresql://username:password@localhost:5432/seapedia_db?schema=public"
JWT_SECRET="kcgkejedukbelalangsembah"
PORT=3000
```

| Key | Description | Example / Recommended Value |
| :--- | :--- | :--- |
| `DATABASE_URL` | String koneksi menuju PostgreSQL database. | `postgresql://postgres:password@localhost:5432/seapedia_db?schema=public` |
| `JWT_SECRET` | Kunci rahasia untuk menandatangani token JWT sesi pengguna. | `kcgkejedukbelalangsembah` |
| `PORT` | Port tempat server NestJS mendengarkan request (default: `3000`). | `3000` |

---

## 🗄️ Manajemen Database (Prisma)

Aplikasi ini menggunakan Prisma ORM untuk pemodelan data, migrasi, dan query.

### 🔌 Sinkronisasi Skema Database
Untuk menyelaraskan database PostgreSQL Anda dengan model pada `prisma/schema.prisma`:
```bash
npx prisma db push
```

### 🧬 Menghasilkan Prisma Client
Jalankan perintah ini setiap kali Anda melakukan perubahan skema pada `schema.prisma`:
```bash
npx prisma generate
```

### 📈 Migrasi Database
Untuk melacak perubahan database dan menerapkan migrasi pengembangan:
```bash
npx prisma migrate dev --name init
```

### 🌱 Data Awal (Seed Data)
Jalankan script seed untuk membuat peran master (`ADMIN`, `SELLER`, `BUYER`, `DRIVER`) serta profil superadmin bawaan:
```bash
npx prisma db seed
```

> [!IMPORTANT]
> Akun admin default yang didaftarkan melalui script seed adalah:
> *   **Username**: `superadmin`
> *   **Password**: `adminpassword123`

---

## 💻 Menjalankan Server

Gunakan script npm berikut untuk menjalankan backend:

```bash
# Mode pengembangan (dengan auto-reload/watch mode)
npm run start:dev

# Mode debug
npm run start:debug

# Kompilasi build produksi
npm run build

# Menjalankan build produksi
npm run start:prod
```

---

## 📖 Dokumentasi API (Swagger Docs)

Dokumentasi rute API yang interaktif disediakan menggunakan Swagger dan dapat diakses di:
🔗 **[http://localhost:3000/api/docs](http://localhost:3000/api/docs)**

---

## ⚙️ Implementasi Aturan Bisnis Utama

Berikut adalah detail teknis implementasi aturan bisnis SEAPEDIA di tingkat backend:

### 1. Aturan Satu Toko (Single-Store Cart)
*   Aturan ini diatur dalam [cart.service.ts](file:///d:/KULIAH/kursus/Compfest%20Academy/seleksi/seapedia/backend/src/cart/cart.service.ts).
*   Model `Cart` menyimpan kolom `sellerId`. Ketika produk pertama dimasukkan, `sellerId` dari toko produk tersebut dikunci ke keranjang.
*   Ketika produk berikutnya ditambahkan melalui `addToCart`, backend mencocokkan `product.sellerId` dengan `cart.sellerId`. Jika berbeda, backend mengembalikan `ConflictException`.
*   Keranjang akan mengosongkan kolom `sellerId` kembali menjadi `null` hanya ketika seluruh isi keranjang dihapus atau proses checkout berhasil.

### 2. Aturan Diskon & Perhitungan PPN 12%
*   Aturan ini diatur dalam [order.service.ts](file:///d:/KULIAH/kursus/Compfest%20Academy/seleksi/seapedia/backend/src/order/order.service.ts).
*   Sistem mendukung kode diskon berupa `VOUCHER` (memiliki kuota `remainingUsage` yang dikurangi secara atomik saat checkout) dan `PROMO` (hanya divalidasi tanggal kedaluwarsanya).
*   Pembeli memasukkan satu `discountCode` pada payload checkout. Diskon tidak dapat digabungkan.
*   **Urutan Perhitungan Pajak**: Diskon dikurangkan terlebih dahulu dari subtotal sebelum pengenaan pajak (PPN 12%).
    $$\text{Discounted Subtotal} = \max(0, \text{Subtotal} - \text{Discount Amount})$$
    $$\text{PPN 12\%} = \text{Discounted Subtotal} \times 0.12$$
    $$\text{Final Total} = \text{Discounted Subtotal} + \text{Delivery Fee} + \text{PPN 12\%}$$

### 3. Pendapatan Pengemudi (Driver Earnings)
*   Aturan ini diatur dalam [driver.service.ts](file:///d:/KULIAH/kursus/Compfest%20Academy/seleksi/seapedia/backend/src/driver/driver.service.ts).
*   Ketika pengemudi berhasil melakukan konfirmasi pengiriman selesai (`completeJob`), saldo pendapatan (`earnings`) pada profil pengemudi ditambahkan sebesar biaya ongkos kirim (`deliveryFee`) pesanan yang diantar.

### 4. Overdue SLA, Auto Return/Refund & Simulasi Waktu
*   Sistem menerapkan batas waktu (SLA) untuk penyelesaian pesanan:
    *   **Instant**: 24 jam.
    *   **Next Day**: 48 jam.
    *   **Regular**: 120 jam (5 hari).
*   Pemeriksaan otomatis dilakukan oleh [scheduler.service.ts](file:///d:/KULIAH/kursus/Compfest%20Academy/seleksi/seapedia/backend/src/scheduler/scheduler.service.ts) setiap menit menggunakan cron job `@Cron(CronExpression.EVERY_MINUTE)`.
*   Jika suatu pesanan melewati batas waktu SLA dan belum diselesaikan (status: `BEING_PACKED`, `AWAITING_SHIPMENT`, `BEING_SHIPPED`), backend akan:
    1.  Mengubah status pesanan menjadi `RETURNED`.
    2.  Mengembalikan saldo pembeli secara penuh (`Final Total`) melalui transaksi refund dompet.
    3.  Mengembalikan jumlah stok produk ke inventaris masing-masing penjual.
    4.  Menghapus pekerjaan pengiriman (`DeliveryJob`) yang aktif.
    5.  Transaksi ini dilakukan secara atomik menggunakan Prisma `$transaction` dengan tingkat isolasi `Serializable` untuk mencegah kondisi balapan (race condition).
*   **Simulasi Waktu**: Pengembang dapat memicu simulasi overdue secara instan dengan memanggil endpoint `POST /admin/simulate-overdue` (khusus peran `ADMIN`) dengan menyertakan payload `{"daysToAdvance": number}`. Ini akan memajukan waktu sistem dan segera menjalankan evaluasi SLA.

---

## 🔒 Arsitektur Keamanan (Security Hardening)

### 1. SQL Injection Prevention
Backend memanfaatkan **Prisma ORM** untuk seluruh operasi database. Prisma secara otomatis melakukan parameterisasi query untuk seluruh input pengguna, sehingga payload SQL berbahaya yang disisipkan pada form login, pencarian, ulasan, atau checkout tidak dapat merusak struktur database atau memanipulasi query.

### 2. XSS (Cross-Site Scripting) Prevention
Ulasan aplikasi publik dapat disubmit oleh tamu tanpa otentikasi. Untuk menghindari eksploitasi skrip berbahaya (misalnya tag `<script>` atau event handler inline seperti `onload`), backend menggunakan modul `xss` di dalam [reviews.service.ts](file:///d:/KULIAH/kursus/Compfest%20Academy/seleksi/seapedia/backend/src/reviews/reviews.service.ts) untuk menyaring nama pengulas dan konten komentar sebelum disimpan.

### 3. Validasi Input Ketat
NestJS dikonfigurasi menggunakan `ValidationPipe` global di [main.ts](file:///d:/KULIAH/kursus/Compfest%20Academy/seleksi/seapedia/backend/src/main.ts):
```typescript
app.useGlobalPipes(new ValidationPipe({
  whitelist: true,
  transform: true,
  forbidNonWhitelisted: true,
}));
```
Hal ini memastikan request body yang tidak terdefinisi di tingkat DTO (Data Transfer Object) akan ditolak secara ketat, dan input seperti rating (harus integer 1-5), kuantitas, harga, dan tanggal kedaluwarsa divalidasi keabsahannya sebelum diproses.

### 4. Manajemen Sesi Token JWT
*   Setelah berhasil masuk (`POST /auth/login`), backend menghasilkan token sesi sementara berisi daftar peran pengguna. Pengguna wajib mengirimkan request `POST /auth/select-role` untuk memilih peran aktif mereka.
*   Token JWT sesi akhir yang diterbitkan berisi properti `activeRole`. Token ini ditandatangani menggunakan algoritma HMAC SHA-256 dengan kunci rahasia `JWT_SECRET`.
*   Rute dilindungi secara server-side menggunakan `AuthGuard` untuk ekstraksi token dan `RolesGuard` untuk verifikasi kecocokan peran aktif pengguna. Jika peran yang dikirim di header tidak sesuai dengan otorisasi rute, backend akan melempar `ForbiddenException`.
*   Backend tidak pernah memercayai role yang dikirim langsung di request body; semua validasi bertumpu pada payload token JWT terenkripsi yang diterima.
