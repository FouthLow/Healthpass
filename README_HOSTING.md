# PANDUAN INTEGRASI BACKEND & BUILD RELEASE (FLUTTER)

Dokumen ini berisi panduan untuk menghubungkan aplikasi Flutter Anda ke server backend Laravel (lokal/produksi) serta panduan melakukan build ke versi rilis (APK/IPA).

---

## 🔗 1. Konfigurasi Endpoint API (Base URL)
Untuk mengubah server tujuan API aplikasi, Anda hanya perlu mengedit satu berkas konfigurasi terpusat pada proyek ini:

👉 **Lokasi Berkas**: [lib/config.dart](file:///c:/nitip/Healthpass/lib/config.dart)

### Opsi Pengaturan Nilai `baseUrl`:

| Skenario Pengujian | Contoh Alamat `baseUrl` | Penjelasan |
| :--- | :--- | :--- |
| **Emulator Android Bawaan** | `http://10.0.2.2:8000` | Gateway khusus untuk mengakses localhost laptop dari dalam emulator Android. |
| **Simulator iOS / Web** | `http://127.0.0.1:8000` | Dapat mengakses localhost secara langsung dari simulator macOS atau browser web. |
| **HP Fisik (Satu Jaringan Wi-Fi)** | `http://192.168.1.15:8000` | Menggunakan IP lokal komputer Anda. Pastikan Laravel sudah dibind ke `0.0.0.0`. |
| **Uji Coba Online Publik** | `https://abcd-123.ngrok-free.app` | Alamat HTTPS publik gratis menggunakan tunneling Ngrok. |
| **Produksi / Hosting Asli** | `https://api.nama-domain-anda.com` | URL HTTPS aman dari server hosting atau VPS tempat Laravel di-deploy. |

---

## 🔒 2. Masalah Keamanan HTTP (Cleartext Traffic)
*   **Android & iOS secara default memblokir request HTTP polos** (tanpa enkripsi SSL/HTTPS).
*   Jika Anda menggunakan alamat `http://...` untuk pengujian lokal, koneksi di Android emulator atau perangkat fisik mungkin akan diblokir dan melempar eror.
*   **Solusi Terbaik**: Gunakan HTTPS (seperti tunnel gratis dari **Ngrok** yang otomatis menyediakan HTTPS, atau pasang SSL Let's Encrypt di domain produksi Anda).
*   Jika terpaksa harus menggunakan HTTP polos pada HP fisik Android untuk testing lokal, Anda harus mengizinkan *Cleartext Traffic* di berkas `android/app/src/main/AndroidManifest.xml` dengan menambahkan atribut `android:usesCleartextTraffic="true"` pada tag `<application>`.

---

## 🚀 3. Melakukan Build Aplikasi ke Versi Rilis

Setelah konfigurasi `baseUrl` di `lib/config.dart` diarahkan ke server produksi/hosting yang online (HTTPS), Anda dapat melakukan kompilasi aplikasi ke versi produksi:

### A. Kompilasi Rilis Android (APK)
Jalankan perintah berikut pada root direktori proyek Flutter Anda:
```bash
flutter clean
flutter pub get
flutter build apk --release
```
*   **Hasil Output**: File APK rilis akan tersimpan di direktori:
    `build/app/outputs/flutter-apk/app-release.apk`
*   Anda dapat langsung memindahkan file APK ini ke HP Android untuk menginstalnya.

### B. Kompilasi Rilis iOS (IPA / TestFlight)
Jika Anda menggunakan macOS dan ingin melakukan build untuk perangkat iOS:
1. Pastikan Anda sudah login ke akun Apple Developer di Xcode.
2. Jalankan perintah kompilasi:
   ```bash
   flutter clean
   flutter pub get
   flutter build ipa --release
   ```
3. Buka direktori Xcode workspace (`ios/Runner.xcworkspace`) menggunakan Xcode untuk melakukan *Archive* dan mendistribusikannya ke App Store Connect atau TestFlight.
