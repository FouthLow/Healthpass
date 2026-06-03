import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:http/http.dart' as http;
import 'package:healthpass/config.dart';
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

  final String baseUrl = AppConfig.baseUrl;

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    size: 48,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin ? 'Masuk' : 'Daftar',
                      style: const TextStyle(
                        fontSize: 28, 
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade100, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ] else ...[
                          TextFormField(
                            controller: _nameEmailBpjsController,
                            textInputAction: TextInputAction.next,
                            validator: (value) => value!.isEmpty ? 'Kolom ini wajib diisi' : null,
                            decoration: InputDecoration(
                              labelText: 'Email atau Nomor BPJS',
                              prefixIcon: const Icon(Icons.person_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),

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
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),

                        if (!_isLogin) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _bpjsController,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number,
                            validator: (value) => value!.isEmpty ? 'Nomor BPJS wajib diisi' : null,
                            decoration: InputDecoration(
                              labelText: 'Nomor BPJS',
                              prefixIcon: const Icon(Icons.card_membership_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 4,
                                child: IntlPhoneField(
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    counterText: '',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                  ),
                                  initialCountryCode: 'ID',
                                  disableLengthCheck: true,
                                  dropdownIconPosition: IconPosition.trailing,
                                  flagsButtonPadding: const EdgeInsets.only(left: 8),
                                  style: const TextStyle(fontSize: 15),
                                  onChanged: (phone) {
                                    _completePhoneNumber = phone.completeNumber;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 7,
                                child: TextFormField(
                                  controller: _noController,
                                  keyboardType: TextInputType.phone,
                                  validator: (value) => value!.isEmpty ? 'Nomor telepon wajib diisi' : null,
                                  decoration: InputDecoration(
                                    hintText: 'Nomor Telepon',
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: _isLoading ? null : handleAuthSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isLoading 
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(_isLogin ? 'Masuk' : 'Daftar', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_isLogin ? 'Belum Punya Akun?' : 'Sudah Punya Akun?', style: const TextStyle(color: Colors.grey)),
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
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}