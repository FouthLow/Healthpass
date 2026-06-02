import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_page.dart';

class AccountPage extends StatefulWidget {
  final String token;

  const AccountPage({
    super.key,
    required this.token,
  });

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _isLoading = true;
  String? _error;

  String _name = 'Pasien';
  String _noBpjs = '-';
  String _email = '-';
  String _born = '-';
  String _gender = '-';

  final String baseUrl = "http://127.0.0.1:8000";

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/pasien/profile"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${widget.token}",
          "ngrok-skip-browser-warning": "69420",
        },
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _name = body["name"] ?? 'Pasien Tanpa Nama';
          _noBpjs = body["no_bpjs"] ?? '-';
          _email = body["email"] ?? '-';
          _born = body["born"] ?? '-';
          _gender = body["gender"] ?? '-';
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = body["message"] ?? "Gagal mengambil data profil.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Kesalahan koneksi: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    // Tampilkan dialog konfirmasi
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.redAccent),
            SizedBox(width: 8),
            Text("Konfirmasi Keluar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text("Apakah Anda yakin ingin keluar dari akun Anda?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Keluar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthPage()),
        (route) => false,
      );
    }
  }

  void _showEditProfileDialog() {
    final TextEditingController emailController = TextEditingController(text: _email);
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.manage_accounts_rounded, color: Colors.blueAccent),
                  SizedBox(width: 8),
                  Text("Ubah Email & Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Perbarui informasi email dan password akun Anda di bawah ini:",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    const Text("Email Baru", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "Masukkan email...",
                        prefixIcon: const Icon(Icons.email_outlined, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("Password Baru (Kosongkan jika tidak diubah)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "Minimal 8 karakter...",
                        prefixIcon: const Icon(Icons.lock_outline, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("Konfirmasi Password Baru", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "Ketik ulang password baru...",
                        prefixIcon: const Icon(Icons.lock_clock_outlined, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final email = emailController.text.trim();
                          final password = passwordController.text;
                          final confirmPassword = confirmPasswordController.text;

                          if (email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Email tidak boleh kosong.')),
                            );
                            return;
                          }

                          if (password.isNotEmpty) {
                            if (password.length < 8) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Password baru minimal 8 karakter.')),
                              );
                              return;
                            }
                            if (password != confirmPassword) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Konfirmasi password tidak cocok.')),
                              );
                              return;
                            }
                          }

                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            final response = await http.post(
                              Uri.parse("$baseUrl/api/pasien/profile/update"),
                              headers: {
                                "Content-Type": "application/json",
                                "Accept": "application/json",
                                "Authorization": "Bearer ${widget.token}",
                                "ngrok-skip-browser-warning": "69420",
                              },
                              body: jsonEncode({
                                "email": email,
                                if (password.isNotEmpty) "password": password,
                              }),
                            );

                            final body = jsonDecode(response.body);

                            if (response.statusCode == 200) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profil berhasil diperbarui!')),
                              );
                              _fetchProfile();
                            } else {
                              String errMsg = body["message"] ?? "Gagal menyimpan perubahan.";
                              if (body["errors"] != null && body["errors"] is Map) {
                                errMsg += "\n" + (body["errors"] as Map).values.expand((v) => v as List).join("\n");
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(errMsg)),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Kesalahan koneksi: $e')),
                            );
                          } finally {
                            setDialogState(() {
                              isSaving = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text("Simpan", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _error = null;
                    });
                    _fetchProfile();
                  },
                  child: const Text("Coba Lagi"),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchProfile,
          color: Colors.blueAccent,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: [
              const SizedBox(height: 32),

              // --- KARTU PROFIL USER ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200, width: 1.5),
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
                    Text(
                      _name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Badge Nomor BPJS
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD), // Biru muda transparan
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.credit_card_rounded,
                            size: 16,
                            color: Color(0xFF1E88E5),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'No. BPJS: $_noBpjs',
                            style: const TextStyle(
                              color: Color(0xFF1E88E5), // Biru tegas
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Informasi Pribadi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 12),

              // --- KOTAK DETAIL DATA PROFIL ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200, width: 1.5),
                ),
                child: Column(
                  children: [
                    _buildInfoTile(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      value: _email,
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFE0E0E0)),
                    _buildInfoTile(
                      icon: Icons.cake_outlined,
                      title: 'Tanggal Lahir',
                      value: _born,
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFE0E0E0)),
                    _buildInfoTile(
                      icon: _gender.toLowerCase() == 'male' ? Icons.male_outlined : Icons.female_outlined,
                      title: 'Jenis Kelamin',
                      value: _gender.toLowerCase() == 'male' ? 'Laki-laki' : (_gender.toLowerCase() == 'female' ? 'Perempuan' : _gender),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- TOMBOL UBAH AKUN ---
              InkWell(
                onTap: _showEditProfileDialog,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.blueAccent.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_note_rounded,
                        color: Colors.blueAccent,
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Ubah Email & Password',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // --- TOMBOL KELUAR ---
              InkWell(
                onTap: _handleLogout,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.redAccent.shade100,
                      width: 1.5,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: Colors.redAccent,
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Keluar dari Aplikasi',
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

              const SizedBox(height: 40),

              // --- FOOTER PRIVASI ---
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 24.0),
                  child: Text.rich(
                    TextSpan(
                      text: 'Privasi, keamanan, dan kenyamanan pengguna\nadalah ',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'prioritas kami.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2D3142), size: 22),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3142),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}