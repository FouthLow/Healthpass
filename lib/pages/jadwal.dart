import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF3F4F6), // Background abu-abu muda
      ),
      home: const JadwalPemeriksaanPage(),
    );
  }
}

class JadwalPemeriksaanPage extends StatelessWidget {
  const JadwalPemeriksaanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Judul Halaman
              const Text(
                'Jadwal Pemeriksaan',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Kontainer Kalender Strip
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNormalDate('16'),
                    _buildNormalDate('17'),
                    _buildNormalDate('18'),
                    _buildTodayDate('19'), // Hari ini (Solid blue)
                    _buildSelectedDate('20'), // Dipilih (Blue outline)
                    _buildNormalDate('21'),
                    _buildNormalDate('22'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Tombol / Indikator Bulan (MEI 2026)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black87, width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black87),
                    SizedBox(width: 8),
                    Text(
                      'MEI 2026',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. Daftar Kartu Jadwal
              _buildScheduleCard(
                date: '20',
                month: 'Mei',
                hospital: 'RS UMMI BOGOR',
                symptom: 'Flu dan batuk',
                time: '10:00 - 11:00',
                isActive: true, // Warna Biru
              ),
              const SizedBox(height: 16),
              _buildScheduleCard(
                date: '10',
                month: 'Mei',
                hospital: 'RS UMMI BOGOR',
                symptom: 'Flu dan batuk',
                time: '10:00 - 11:00',
                isActive: false, // Warna Abu-abu
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk Tanggal Biasa
  Widget _buildNormalDate(String day) {
    return Text(
      day,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  // Widget untuk Tanggal "Hari Ini" (Biru Penuh)
  Widget _buildTodayDate(String day) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFF3399FF),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            day,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Hari ini',
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF3399FF),
            fontWeight: FontWeight.w600,
          ),
        )
      ],
    );
  }

  // Widget untuk Tanggal Terpilih (Garis Tepi Biru)
  Widget _buildSelectedDate(String day) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF3399FF), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        day,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Color(0xFF3399FF),
        ),
      ),
    );
  }

  // Widget untuk Kartu Jadwal Pemeriksaan
  Widget _buildScheduleCard({
    required String date,
    required String month,
    required String hospital,
    required String symptom,
    required String time,
    required bool isActive,
  }) {
    final sideColor = isActive ? const Color(0xFF3399FF) : const Color(0xFFC2C2C2);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias, // Memotong sisi tajam kontainer anak
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bagian Kiri (Warna & Tanggal)
            Container(
              width: 110,
              color: sideColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    month,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Bagian Kanan (Detail Informasi)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Jadwal Pemeriksaan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hospital,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      symptom,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Waktu : $time',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}