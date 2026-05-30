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
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        fontFamily: 'Poppins',
      ),
      home: const RiwayatScreen(),
    );
  }
}

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  // Menggunakan tanggal default awal (Mei 2026)
  DateTime _selectedDate = DateTime(2026, 5, 18);

  // Array nama bulan manual agar tidak butuh package intl
  final List<String> _namaBulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  // Fungsi untuk memunculkan Google Calendar Picker
  Future<void> _pilihBulanTahun(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020), // Batas tahun paling tua
      lastDate: DateTime(2035),  // Batas tahun paling muda
      helpText: 'PILIH TANGGAL & BULAN',
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Trik Dart untuk menghitung total jumlah hari dalam bulan yang dipilih secara dinamis
    int jumlahHari = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER TITLE ---
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 30, 24, 15),
              child: Text(
                'Riwayat',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),

            // --- SEARCH BAR ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Ketuk untuk mencari',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    suffixIcon: Icon(Icons.search, color: Colors.grey, size: 28),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // --- FITUR BARU: TOMBOL PILIH BULAN & TAHUN (GOOGLE CALENDAR STYLE) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: InkWell(
                onTap: () => _pilihBulanTahun(context),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_namaBulan[_selectedDate.month - 1]} ${_selectedDate.year}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF005088),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_drop_down_circle_outlined,
                        color: Color(0xFF005088),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // --- KALENDER HORIZONTAL DINAMIS ---
            Container(
              height: 95,
              padding: const EdgeInsets.only(left: 24),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: jumlahHari, // Mengikuti jumlah hari di bulan terpilih
                itemBuilder: (context, index) {
                  // Membuat objek tanggal untuk setiap kotak/item berdasarkan indeks
                  DateTime date = DateTime(_selectedDate.year, _selectedDate.month, index + 1);
                  bool isSelected = date.day == _selectedDate.day;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedDate = date),
                    child: Container(
                      width: 65,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF005088) : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Menampilkan Nama Hari (Sen - Min)
                          Text(
                            ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'][date.weekday - 1],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Menampilkan Angka Tanggal
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            // --- DAFTAR KARTU RIWAYAT MEDIS ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: 3,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return MedicalHistoryCard(
                    tanggalPemeriksaan: '${_selectedDate.day} ${_namaBulan[_selectedDate.month - 1]} ${_selectedDate.year}',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET KARTU RIWAYAT ---
class MedicalHistoryCard extends StatelessWidget {
  final String tanggalPemeriksaan;
  
  const MedicalHistoryCard({super.key, required this.tanggalPemeriksaan});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RS UMMI BOGOR',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Flu dan batuk',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Tanggal periksa:',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tanggalPemeriksaan, // Mengikuti bulan/tahun yang aktif
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF005088)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Sembuh Total',
              style: TextStyle(
                color: Color(0xFF4CAF50),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}