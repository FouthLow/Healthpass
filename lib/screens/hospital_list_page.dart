import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HospitalListPage extends StatefulWidget {
  final String token; 

  const HospitalListPage({
    super.key,
    required this.token,
  });

  @override
  State<HospitalListPage> createState() => _HospitalListPageState();
}

class _HospitalListPageState extends State<HospitalListPage> {
  // 1. DATA DUMMY DIHAPUS TOTAL! Sekarang diganti list kosong untuk menampung data asli server
  List<dynamic> _realHospitals = [];
  bool _isLoading = false;
  final String baseUrl = "http://127.0.0.1:8000"; 

  @override
  void initState() {
    super.initState();
    // 2. Jalankan fungsi fetch data asli saat halaman dibuka pertama kali
    _fetchHospitalsFromServer();
  }

  // Fungsi untuk mengambil (GET) data rumah sakit asli dari database server Laravel
  // Fungsi untuk mengambil (GET) data rumah sakit asli dari database server Laravel
  Future<void> _fetchHospitalsFromServer() async {
    setState(() {
      _isLoading = true;
    });

    final Uri url = Uri.parse("$baseUrl/api/pasien/hospitals");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer ${widget.token}", 
          "ngrok-skip-browser-warning": "69420",
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        setState(() {
          _realHospitals = responseData['data'] ?? []; 
        });
      } else {
        // KITA BONGKAR PESAN ERROR ASLI DARI SERVER DI SINI:
        String serverMessage = responseData['message'] ?? 
                               responseData['error'] ?? 
                               "HTTP Status: ${response.statusCode}";
        
        _showSnackbar("Detail Error Server: $serverMessage", Colors.red);
        print("BODY ERROR LENGKAP: ${response.body}");
      }
    } catch (e) {
      _showSnackbar("Koneksi gagal/Format salah: $e", Colors.orange);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi POST untuk mendaftar kunjungan berobat
  Future<void> _sendVisitRequest(String hospitalCode, String hospitalName) async {
    setState(() {
      _isLoading = true;
    });

    final Uri url = Uri.parse("$baseUrl/api/pasien/visit/request");

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
          "kode_rs": hospitalCode, // Mengirim kode rs dinamis asli server
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackbar(responseData['message'] ?? 'Berhasil mendaftar!', Colors.green);
      } else {
        // Jika gagal karena database (termasuk error SQL), pesan asli server akan langsung tampil di sini
        _showSnackbar(responseData['message'] ?? 'Gagal mendaftar ke RS.', Colors.red);
      }
    } catch (e) {
      _showSnackbar("Koneksi gagal: Gagal mengirimkan request.", Colors.orange);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackbar(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showRequestVisitDialog(BuildContext context, String hospitalName, String hospitalCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.healing, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text("Konfirmasi Berobat", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text("Apakah Anda yakin ingin mengajukan permohonan kunjungan berobat ke $hospitalName?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); 
              _sendVisitRequest(hospitalCode, hospitalName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Kirim Request", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Faskes Terintegrasi (B2B)",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Tombol refresh manual untuk fetch ulang data asli server
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchHospitalsFromServer,
          )
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.grey[50],
            // 3. KONDISI JIKA DATA KOSONG: Jika server belum punya data faskes, otomatis tampil placeholder rapi
            child: _realHospitals.isEmpty && !_isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.business_center_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          "Tidak ada data faskes aktif di database server.",
                          style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _realHospitals.length,
                    itemBuilder: (context, index) {
  final hospital = _realHospitals[index];
  
  // Membaca key JSON asli yang dikirim oleh select() Laravel
  final String name = hospital['nama_rs'] ?? 'Rumah Sakit';
  final String code = hospital['kode_rs'] ?? 'UNKNOWN';
  final String subtitle = "Kode Resmi Faskes: $code"; // Menggantikan kolom alamat yang tidak ada di DB

  return Container(
    margin: const EdgeInsets.only(bottom: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey[200]!),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_hospital, color: Colors.blueAccent, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 14, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, color: Color(0xff1e293b)),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _showRequestVisitDialog(context, name, code),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Daftar", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ),
  );
},
                  ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
            )
        ],
      ),
    );
  }
}