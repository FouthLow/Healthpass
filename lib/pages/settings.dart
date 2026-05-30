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
      title: 'Halaman Pengaturan',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F6F9), // Latar abu-abu sangat muda
        fontFamily: 'Poppins', // Pastikan font ini terdaftar, atau akan fallback ke font sistem
      ),
      home: const PengaturanScreen(),
    );
  }
}

class PengaturanScreen extends StatelessWidget {
  const PengaturanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              // --- SECTION 1: PROFIL USER ---
              Row(
                children: [
                  // Foto Profil (Bulat)
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200', // Contoh placeholder foto
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Teks Nama & Badge Penyakit
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ahmad Firdausy Ahla',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD), // Biru muda transparan
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Kanker Bulu Ayam',
                          style: TextStyle(
                            color: Color(0xFF1E88E5), // Biru tegas
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              
              const SizedBox(height: 40),
              
              // --- SECTION 2: JUDUL PENGATURAN ---
              const Text(
                'Pengaturan',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 16),

              // --- SECTION 3: KOTAK MENU LIST ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200, width: 1.5),
                ),
                child: const Column(
                  children: [
                    MenuTileSetting(
                      icon: Icons.palette_outlined, 
                      title: 'Tampilan'
                    ),
                    Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFE0E0E0)),
                    MenuTileSetting(
                      icon: Icons.badge_outlined, 
                      title: 'ID BPJS'
                    ),
                    Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFE0E0E0)),
                    MenuTileSetting(
                      icon: Icons.mail_outline_rounded, 
                      title: 'Kaitkan Akun'
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // --- SECTION 4: TOMBOL KELUAR ---
              InkWell(
                onTap: () {
                  // Aksi Log Out di sini
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.redAccent.shade100, width: 1.5),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.redAccent, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'Keluar',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // --- SECTION 5: FOOTER PRIVASI ---
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 24.0),
                  child: Text.rich(
                    TextSpan(
                      text: 'Privasi, keamanan, dan kenyamanan pengguna\nadalah ',
                      style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.5),
                      children: [
                        TextSpan(
                          text: 'prioritas kami.',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center, // Aman dari error typo kemarin 👍
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- CUSTOM COMPONENT: BARIS MENU PENGATURAN ---
class MenuTileSetting extends StatelessWidget {
  final IconData icon;
  final String title;

  const MenuTileSetting({
    super.key, 
    required this.icon, 
    required this.title
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Aksi ketika menu diklik
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Container Icon Sisi Kiri
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF2D3142), size: 24),
            ),
            const SizedBox(width: 16),
            // Judul Menu
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D3142),
              ),
            ),
            const Spacer(),
            // Panah Sisi Kanan
            const Icon(
              Icons.arrow_forward_ios_rounded, 
              color: Colors.grey, 
              size: 16
            ),
          ],
        ),
      ),
    );
  }
}