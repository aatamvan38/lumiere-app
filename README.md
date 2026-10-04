# Lumière — Belajar Membuat Aplikasi Sosial Media (Android & iOS)

Proyek belajar untuk pemula di Indonesia: HTML + CSS + JavaScript, backend Supabase, dibungkus jadi aplikasi dengan Capacitor.
Fitur utama: login/register, profil bisa diedit, beranda, like, komentar, story foto/video, reels, mode terang/gelap, dan fitur moderasi sederhana (laporkan/blokir/hapus kiriman).

## 1. Coba dulu di browser (mode demo, tanpa backend)
Install Node.js (nodejs.org), lalu di folder ini:

```bash
npm install
npm run web
```

Lalu buka URL yang muncul di terminal.

## 2. Hubungkan ke Supabase (gratis)
1. Daftar di supabase.com > New project.
2. SQL Editor > jalankan isi `supabase/schema.sql`.
3. Authentication > Providers > Email: matikan Confirm email.
4. Project Settings > API: salin Project URL dan anon public key ke `www/config.js`.
5. Jalankan `npm run web` lagi.

Sekarang akun, kiriman, like, komentar, story, dan moderasi bisa berjalan dengan data sungguhan.

## 3. Jadikan aplikasi Android
```bash
npm install
npx cap add android
npm run sync
npm run android
```

Ubah `appId` di `capacitor.config.json` menjadi ID unik milikmu sebelum `cap add`.

## 4. Publikasi ke Google Play
- Akun Google Play Console (sekitar US$25 sekali bayar)
- Siapkan ikon 512x512, screenshot, deskripsi, privacy policy, dan formulir Data Safety
- Aplikasi UGC wajib punya laporkan + blokir + moderasi + hapus akun

## 5. App Store (iOS)
Butuh Mac + Xcode + Apple Developer Program ($99/tahun):

```bash
npx cap add ios
npm run ios
```

## Fitur yang sudah ditambahkan di versi ini
- Login/register demo + mekanisme siap terhubung ke Supabase
- Profil bisa diedit
- Feed, like, komentar
- Story foto/video lokal
- Reels demo
- Moderasi sederhana: laporkan, blokir, hapus kiriman sendiri

## Catatan penting
- Ini masih prototype belajar dan belum siap untuk produksi massal.
- Untuk rilis nyata, kamu tetap perlu keamanan tambahan, notifikasi, storage yang benar, serta moderation workflow.
