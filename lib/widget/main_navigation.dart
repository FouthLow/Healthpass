import 'package:flutter/material.dart';
import '../screens/dashboard_page.dart';
import '../screens/scan_qr_page.dart'; // 🟢 Mengarah ke halaman scan asli
import '../screens/account_page.dart'; // 🟢 Mengarah ke halaman akun asli

class MainNavigation extends StatefulWidget {
  final String token;

  const MainNavigation({super.key, required this.token});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Menghubungkan token ke masing-masing page asli
    _pages = [
      DashboardPage(
        token: widget.token,
        onTabChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      ScanQrPage(token: widget.token),
      AccountPage(token: widget.token),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _pages),
      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          shape: const CircleBorder(),
          onPressed: () {
            setState(() {
              _currentIndex = 1; // Pindah ke halaman ScanQrPage
            });
          },
          elevation: 4,
          child: const Icon(
            Icons.qr_code_scanner,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 15,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  Icons.home_rounded,
                  size: 28,
                  color: _currentIndex == 0
                      ? Colors.blueAccent
                      : Colors.grey.shade400,
                ),
                onPressed: () {
                  setState(() {
                    _currentIndex = 0; // Pindah ke Dashboard
                  });
                },
              ),
              const SizedBox(width: 40), // Ruang kosong untuk lekukan FAB QR
              IconButton(
                icon: Icon(
                  Icons.person_rounded,
                  size: 28,
                  color: _currentIndex == 2
                      ? Colors.blueAccent
                      : Colors.grey.shade400,
                ),
                onPressed: () {
                  setState(() {
                    _currentIndex = 2; // Pindah ke AccountPage
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
