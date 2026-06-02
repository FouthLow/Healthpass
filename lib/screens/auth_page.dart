import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../widget/main_navigation.dart';
import 'dashboard_page.dart'; // Mengarah ke file dashboard terpisah

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true; 
  bool _isObscure = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _noController = TextEditingController();
  final _bpjsController = TextEditingController();
  final _nameEmailBpjsController = TextEditingController();
  String _completePhoneNumber = '';

  final String baseUrl = "http://127.0.0.1:8000";

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _noController.dispose();
    _bpjsController.dispose();
    _nameEmailBpjsController.dispose();
    super.dispose();
  }

  Future<void> handleAuthSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final String urlEndpoint = _isLogin ? "$baseUrl/api/flutter/login" : "$baseUrl/api/flutter/register";
    
    final Map<String, String> bodyData = _isLogin 
      ? {
          "login": _nameEmailBpjsController.text.trim(), 
          "password": _passwordController.text,
        }
      : {
          "email": _emailController.text.trim(),
          "password": _passwordController.text,
          "no_bpjs": _bpjsController.text.trim(),
        };

    try {
      final response = await http.post(
        Uri.parse(urlEndpoint),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "ngrok-skip-browser-warning": "true", // <--- TAMBAHKAN BARIS INI
        },
        body: json.encode(bodyData),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        String tokenSukses = responseData['token'] ?? '';
        String username = responseData['username'] ?? 'Pasien';
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', tokenSukses);

        _showSnackBar(_isLogin ? "Selamat datang kembali, $username!" : "Pendaftaran berhasil!");

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigation(token: tokenSukses),
          ),
        );
      } else {
        _showSnackBar(responseData['message'] ?? "Terjadi kesalahan respon server.");
      }
    } catch (e) {
      _showSnackBar("Gagal terhubung ke server backend.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isLogin ? 'Masuk' : 'Daftar',
                      style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin
                          ? 'Pantau Terus Passport Kesehatanmu!'
                          : 'Buat akun baru untuk mulai menggunakan layanan passport kesehatan digital.',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),

              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      if (!_isLogin) ...[
                        TextFormField(
                          controller: _emailController,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => value!.isEmpty ? 'Email tidak boleh kosong' : null,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ] else ...[
                        TextFormField(
                          controller: _nameEmailBpjsController,
                          textInputAction: TextInputAction.next,
                          validator: (value) => value!.isEmpty ? 'Kolom ini wajib diisi' : null,
                          decoration: InputDecoration(
                            labelText: 'Nama, Email / No. BPJS',
                            prefixIcon: const Icon(Icons.person_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _passwordController,
                        textInputAction: TextInputAction.next,
                        obscureText: _isObscure,
                        validator: (value) => value!.length < 6 ? 'Sandi minimal 6 karakter' : null,
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                              onPressed: () => setState(() => _isObscure = !_isObscure),
                              icon: Icon(_isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),

                      if (!_isLogin) ...[
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _bpjsController,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          validator: (value) => value!.isEmpty ? 'No.BPJS wajib diisi' : null,
                          decoration: InputDecoration(
                            labelText: 'No.BPJS',
                            prefixIcon: const Icon(Icons.card_membership_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: IntlPhoneField(
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  counterText: '',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                ),
                                initialCountryCode: 'ID',
                                disableLengthCheck: true,
                                dropdownIconPosition: IconPosition.trailing,
                                flagsButtonPadding: const EdgeInsets.only(left: 8),
                                style: const TextStyle(fontSize: 16),
                                onChanged: (phone) {
                                  _completePhoneNumber = phone.completeNumber;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 7,
                              child: TextFormField(
                                controller: _noController,
                                keyboardType: TextInputType.phone,
                                validator: (value) => value!.isEmpty ? 'No.HP wajib diisi' : null,
                                decoration: InputDecoration(
                                  hintText: 'Nomor Telepon',
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : handleAuthSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(_isLogin ? 'Masuk' : 'Daftar', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_isLogin ? 'Belum Punya Akun?' : 'Sudah Punya Akun?'),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        _formKey.currentState?.reset();
                        _passwordController.clear();
                        _nameEmailBpjsController.clear();
                        _emailController.clear();
                        _bpjsController.clear();
                        _noController.clear();
                      });
                    },
                    child: Text(
                      _isLogin ? 'Daftar' : 'Masuk',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}