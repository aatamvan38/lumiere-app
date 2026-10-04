# Lumière — Belajar Membuat Aplikasi Sosial Media (Android & iOS)

Proyek belajar untuk pemula di Indonesia: HTML + CSS + JavaScript, backend Supabase, dibungkus jadi aplikasi dengan Capacitor.
Fitur: login, profil bisa diedit, beranda, like, komentar, story foto/video, reels, mode terang/gelap.

## 1. Coba dulu di browser (mode demo, tanpa backend)
Install Node.js (nodejs.org), lalu di folder ini: `npm run web` dan buka alamat yang muncul.

## 2. Hubungkan ke Supabase (gratis)
1. Daftar di supabase.com > New project.
2. SQL Editor > tempel isi `supabase/schema.sql` > Run.
3. Authentication > Providers > Email: matikan **Confirm email** (karena username diubah jadi email palsu `username@lumiere.app`).
4. Project Settings > API: salin **Project URL** dan **anon public key** ke `www/config.js`.
5. `npm run web` lagi. Sekarang akun, kiriman, like, komentar, dan story tersimpan sungguhan.

## 3. Jadikan aplikasi Android
```bash
npm install
npx cap add android
npm run sync
npm run android      # membuka Android Studio
```
Ubah `appId` di `capacitor.config.json` menjadi ID unik milikmu (contoh `com.budi.lumiere`) SEBELUM `cap add`.
Di Android Studio: Build > Generate Signed App Bundle (AAB). **Simpan file keystore & passwordnya baik-baik** — hilang berarti tidak bisa update aplikasi.

## 4. Terbitkan di Google Play
- Akun Google Play Console (biaya sekali bayar sekitar US$25).
- Siapkan: ikon 512x512, gambar fitur, screenshot, deskripsi, **kebijakan privasi** (URL), formulir Data Safety.
- Akun pribadi baru biasanya wajib uji tertutup dengan sejumlah tester selama beberapa hari sebelum rilis produksi — cek syarat terbaru di Play Console.
- Aplikasi dengan konten buatan pengguna wajib punya: tombol **laporkan** & **blokir**, moderasi, dan **hapus akun**. Fitur ini BELUM ada di proyek ini; kamu perlu menambahkannya.

## 5. App Store (iOS)
Butuh Mac + Xcode dan Apple Developer Program (sekitar US$99/tahun): `npx cap add ios`, `npm run ios`, lalu Archive > Distribute. Aturan UGC (laporkan/blokir/hapus akun) berlaku juga.

## Peta belajar
1. HTML/CSS: ubah warna di `:root` pada `www/index.html`.
2. JavaScript: ubah `CFG` (durasi story & reels), baca fungsi `render()`.
3. Database: pahami tabel di `schema.sql` dan fungsi `loadAll()`.
4. Keamanan: pelajari Row Level Security. Jangan simpan `service_role` key di aplikasi.
5. Publikasi: ikuti langkah 3-5.

## Catatan jujur
- Reels masih contoh animasi; belum ada upload/streaming video pendek (butuh tabel `reels` + storage).
- Proyek ini ringkas untuk belajar, belum diuji beban dan belum punya notifikasi, chat nyata, atau moderasi.
- Jangan memakai nama, logo, atau tampilan persis Facebook; gunakan identitasmu sendiri.
- Penghasilan dari aplikasi tidak dijamin; aplikasi sosial butuh pengguna dan moderasi.
