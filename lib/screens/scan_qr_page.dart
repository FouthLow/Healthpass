import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrPage extends StatefulWidget {
  final String token;
  final bool isActive;

  const ScanQrPage({
    super.key,
    required this.token,
    this.isActive = false,
  });

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> with SingleTickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _isProcessing = false;
  bool _hasDetected = false;
  final String baseUrl = "http://127.0.0.1:8000";

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 10, end: 230).animate(_animationController);
    if (widget.isActive) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant ScanQrPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        setState(() {
          _hasDetected = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  // verify qr code
  Future<void> _verifyQrString(String qrString) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _hasDetected = true;
    });

    // stop camera
    _scannerController.stop();

    final Uri url = Uri.parse("$baseUrl/api/pasien/qr/verify-scan");

    try {
      final response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer ${widget.token}",
            "ngrok-skip-browser-warning": "69420",
          },
          body: jsonEncode({
            "qr_encrypted_string": qrString,
          }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final status = responseData["status"];
        if (status == "success") {
          _showResultDialog(
            isSuccess: true,
            title: "Lolos Verifikasi",
            message: responseData["message"] ?? "Anda diperbolehkan memasuki instansi/layanan ini.",
          );
        } else {
          final List<dynamic> reasons = responseData["reasons"] ?? [];
          _showResultDialog(
            isSuccess: false,
            title: "Verifikasi Gagal",
            message: "Anda tidak memenuhi persyaratan kesehatan instansi ini.",
            details: reasons.map((r) => r.toString()).toList(),
          );
        }
      } else {
        String errMsg = responseData["message"] ?? "QR Code tidak dikenali atau tidak valid.";
        _showResultDialog(
          isSuccess: false,
          title: "Format Tidak Valid",
          message: errMsg,
        );
      }
    } catch (e) {
      _showResultDialog(
        isSuccess: false,
        title: "Kesalahan Koneksi",
        message: "Gagal terhubung ke server verifikasi. Silakan coba kembali.",
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // show dialog
  void _showResultDialog({
    required bool isSuccess,
    required String title,
    required String message,
    List<String>? details,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isSuccess ? const Color(0xffdcfce7) : const Color(0xfffee2e2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: isSuccess ? const Color(0xff16a34a) : const Color(0xffdc2626),
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? const Color(0xff15803d) : const Color(0xff991b1b),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xff64748b), height: 1.4),
              ),
              
              if (details != null && details.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xfffef2f2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xfffee2e2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Penyebab Penolakan:",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xff991b1b)),
                      ),
                      const SizedBox(height: 6),
                      ...details.map(
                        (detail) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("• ", style: TextStyle(color: Color(0xffdc2626), fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Text(
                                  detail,
                                  style: const TextStyle(fontSize: 11, color: Color(0xff7f1d1d), fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _hasDetected = false;
                    });
                    Navigator.pop(context);
                    _scannerController.start();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccess ? const Color(0xff16a34a) : const Color(0xffdc2626),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Tutup", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // input manual
  void _openManualInputDialog() {
    final TextEditingController inputController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.keyboard_outlined, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text("Input Manual (Testing)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tempelkan string aturan terenkripsi yang diperoleh dari portal web instansi:",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: inputController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Masukkan teks terenkripsi QR di sini...",
                  hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final text = inputController.text.trim();
                Navigator.pop(context);
                if (text.isNotEmpty) {
                  _verifyQrString(text);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Verifikasi", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // viewfinder
          if (widget.isActive)
            MobileScanner(
              controller: _scannerController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                  final String qrVal = barcodes.first.rawValue!;
                  _verifyQrString(qrVal);
                }
              },
            )
          else
            Container(color: Colors.black),

          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  color: Colors.transparent,
                ),
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _hasDetected ? Colors.green : Colors.blueAccent, 
                  width: 3,
                ),
                boxShadow: _hasDetected
                    ? [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 3,
                        )
                      ]
                    : [],
                borderRadius: BorderRadius.circular(24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(21),
                child: Stack(
                  children: [
                    if (widget.isActive && !_isProcessing)
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Positioned(
                            top: _animation.value,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.8),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  )
                                ],
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.blueAccent,
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.qr_code_scanner, color: Colors.blueAccent, size: 18),
                            SizedBox(width: 8),
                            Text(
                              "Pemindaian QR",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: ValueListenableBuilder(
                            valueListenable: _scannerController,
                            builder: (context, state, child) {
                              switch (state.torchState) {
                                case TorchState.off:
                                  return const Icon(Icons.flash_off, color: Colors.white);
                                case TorchState.on:
                                  return const Icon(Icons.flash_on, color: Colors.amber);
                                default:
                                  return const Icon(Icons.flash_off, color: Colors.white);
                              }
                            },
                          ),
                          onPressed: () => _scannerController.toggleTorch(),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Posisikan QR Code aturan instansi\ndi dalam area kotak bidik",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _openManualInputDialog,
                      icon: const Icon(Icons.keyboard_outlined, color: Colors.white, size: 18),
                      label: const Text("Input Kode Manual (Testing)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.blueAccent),
                    SizedBox(height: 16),
                    Text(
                      "Mengevaluasi Kriteria Sehat...",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}