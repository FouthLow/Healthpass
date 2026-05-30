import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pengingat Obat',
      theme: ThemeData(
        // Menggunakan warna latar belakang abu-abu sangat muda sesuai mockup
        scaffoldBackgroundColor: const Color(0xFFF5F6F9),
        fontFamily: 'Roboto', // Atau font default sistem yang bersih
      ),
      home: const PengingatObatScreen(),
    );
  }
}

class PengingatObatScreen extends StatelessWidget {
  const PengingatObatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data contoh untuk list pengingat obat (sesuai gambar ada 5 item)
    final List<Map<String, String>> daftarObat = List.generate(
      5,
      (index) => {
        'nama': 'Antibiotik',
        'aturan': '1 Kali Setelah Makan',
        'waktu': '18:00',
      },
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER SECTION ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pengingat',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3142),
                      letterSpacing: -0.5,
                    ),
                  ),
                  // Tombol Notifikasi Biru
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B82F6), // Warna biru soft
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- LIST REMINDER SECTION ---
              Expanded(
                child: ListView.builder(
                  itemCount: daftarObat.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final obat = daftarObat[index];
                    return ItemPengingatCard(
                      namaObat: obat['nama']!,
                      aturanPakai: obat['aturan']!,
                      waktu: obat['waktu']!,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- CUSTOM CARD WIDGET ---
class ItemPengingatCard extends StatelessWidget {
  final String namaObat;
  final String aturanPakai;
  final String waktu;

  const ItemPengingatCard({
    super.key,
    required this.namaObat,
    required this.aturanPakai,
    required this.waktu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Sudut membulat halus
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Bulan (Malam Hari) dengan Background Biru
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFF5C7CFA), // Warna biru ungu ikon
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.dark_mode_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),

          // Detail Teks Obat
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  namaObat,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  aturanPakai,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Waktu Pengingat
          Text(
            waktu,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
        ],
      ),
    );
  }
}