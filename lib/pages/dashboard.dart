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
      theme: ThemeData(
        fontFamily: 'Sans-Serif',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header & Search Bar ---
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Ketuk untuk mencari',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Icon(Icons.search, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4EA6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- Jadwal Pemeriksaan Section ---
              const Text(
                'Jadwal Pemeriksaan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),

              // Kalender dan Card Jadwal (Digabung dalam satu Container Putih sesuai gambar)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Row Tanggal Kalender
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDateItem('16', false),
                        _buildDateItem('17', false),
                        _buildDateItem('18', false),
                        _buildDateItem('19', true, isToday: true),
                        _buildDateItem('20', true, isSelected: true),
                        _buildDateItem('21', false),
                        _buildDateItem('22', false),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Garis Putus-putus Biru (Dashed Line)
                    Row(
                      children: List.generate(
                        40,
                        (index) => Expanded(
                          child: Container(
                            color: index % 2 == 0 ? Colors.transparent : const Color(0xFF4EA6FF),
                            height: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Memanggil fungsi Card Jadwal Baru yang Sesuai Frame 261
                    _buildScheduleCard(
                      date: '20',
                      month: 'Mei',
                      hospital: 'RS UMMI BOGOR',
                      symptom: 'Flu dan batuk',
                      time: '10:00 - 11:00',
                      color: const Color(0xFF4EA6FF), // Warna Biru Terang
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Medicine Reminder Card ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF5C6BC0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.nightlight_round, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Antibiotik',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '1 Kali Setelah Makan',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      '18:00',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Pengingat akan menyala dalam 4 jam',
                  style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 24),

              // --- Passport Kesehatan ---
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF4EA6FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Passport Kesehatan',
                          style: TextStyle(
                            color: Colors.white, 
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Ketuk untuk scan',
                          style: TextStyle(
                            color: Colors.white, 
                            fontSize: 22, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- Riwayat Section ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Riwayat',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward, size: 28),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // History List
              _buildHistoryCard(),
              _buildHistoryCard(),
              _buildHistoryCard(),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget untuk Item Tanggal di Kalender
  Widget _buildDateItem(String date, bool isActive, {bool isToday = false, bool isSelected = false}) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isToday ? const Color(0xFFE3F2FD) : Colors.transparent,
            shape: BoxShape.circle,
            border: isSelected ? Border.all(color: const Color(0xFF4EA6FF), width: 2) : null,
          ),
          child: Center(
            child: Text(
              date,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                color: isToday ? const Color(0xFF4EA6FF) : (isActive ? Colors.black : Colors.grey[400]),
              ),
            ),
          ),
        ),
        if (isToday) const SizedBox(height: 4),
        if (isToday)
          const Text(
            'Hari ini',
            style: TextStyle(fontSize: 9, color: Color(0xFF4EA6FF), fontWeight: FontWeight.bold),
          ),
      ],
    );
  }

  // BAGIAN YANG DIUBAH: Fungsi Pembuat Card Sesuai Frame 261.png
  Widget _buildScheduleCard({
    required String date,
    required String month,
    required String hospital,
    required String symptom,
    required String time,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sisi Kiri: Angka Tanggal dan Bulan (Hanya Teks Bersih Berwarna Biru)
        SizedBox(
          width: 75,
          child: Column(
            children: [
              Text(
                date,
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w500,
                  color: color,
                  height: 1.0, // Mengurangi jarak renggang antar text atas-bawah
                ),
              ),
              const SizedBox(height: 2),
              Text(
                month,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Sisi Kanan: Detail Informasi Jadwal
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jadwal Pemeriksaan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hospital,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                symptom,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black38,
                ),
              ),
              const SizedBox(height: 24), // Memberikan jarak vertikal sebelum baris waktu
              Text(
                'Waktu : $time',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper Widget untuk Kartu Riwayat
  Widget _buildHistoryCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'RS UMMI BOGOR',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Text(
                'Flu dan batuk',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFA5D6A7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Sembuh Total',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                'Tanggal pemeriksaan:',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
              SizedBox(height: 4),
              Text(
                '18 Mei 2026',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}