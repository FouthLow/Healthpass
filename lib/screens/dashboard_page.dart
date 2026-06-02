import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'detail_page.dart';
import 'detail_passport_page.dart'; 
import 'hospital_list_page.dart'; 

class DashboardPage extends StatefulWidget {
  final String token;
  final Function(int)? onTabChanged;

  const DashboardPage({
    super.key,
    required this.token,
    this.onTabChanged,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isLoading = true;
  String? error;

  Map<String, dynamic>? passport;
  Map<String, dynamic>? medication;

  List appointments = [];
  List history = [];

  List filteredAppointments = [];
  List filteredHistory = [];
  Map<String, dynamic>? filteredMedication;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final String baseUrl = "http://127.0.0.1:8000";

  @override
  void initState() {
    super.initState();
    fetchDashboard();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchDashboard() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/pasien/dashboard"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${widget.token}",
          "ngrok-skip-browser-warning": "69420",
        },
      );

      final body = jsonDecode(response.body);

      if (body["status"] == "success") {
        final data = body["data"];

        setState(() {
          passport = data["health_passport"];
          medication = data["next_medication_alarm"];
          appointments = data["calendar_appointments"] ?? [];
          history = data["medical_history"] ?? [];
          
          filteredAppointments = List.from(appointments);
          filteredHistory = List.from(history);
          filteredMedication = medication != null ? Map<String, dynamic>.from(medication!) : null;
          
          isLoading = false;
        });
        
        if (_searchQuery.isNotEmpty) {
          _performSearch(_searchQuery);
        }
      } else {
        setState(() {
          error = body["message"];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
    _performSearch(_searchQuery);
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredAppointments = List.from(appointments);
        filteredHistory = List.from(history);
        filteredMedication = medication != null ? Map<String, dynamic>.from(medication!) : null;
      });
      return;
    }

    final lowerQuery = query.toLowerCase();

    setState(() {
      filteredAppointments = appointments.where((item) {
        final rsName = (item["rs_name"] ?? "").toString().toLowerCase();
        final reason = (item["reason"] ?? "").toString().toLowerCase();
        return rsName.contains(lowerQuery) || reason.contains(lowerQuery);
      }).toList();

      filteredHistory = history.where((item) {
        final roomName = (item["room"]?["name"] ?? "").toString().toLowerCase();
        final diseaseName = (item["disease"]?["name"] ?? "").toString().toLowerCase();
        return roomName.contains(lowerQuery) || diseaseName.contains(lowerQuery);
      }).toList();

      if (medication != null) {
        final medName = (medication!["medicine_name"] ?? "").toString().toLowerCase();
        final rules = (medication!["rules"] ?? "").toString().toLowerCase();
        
        if (medName.contains(lowerQuery) || rules.contains(lowerQuery)) {
          filteredMedication = Map<String, dynamic>.from(medication!);
        } else {
          filteredMedication = null; 
        }
      } else {
        filteredMedication = null;
      }
    });
  }

  String _getNamaBulanIndo(int bulan) {
    const bulanIndo = [
      "Jan", "Feb", "Mar", "Apr", "Mei", "Jun", 
      "Jul", "Agu", "Sep", "Okt", "Nov", "Des"
    ];
    return bulanIndo[bulan - 1];
  }

  Map<String, String> _getJadwalObatTerdekat(Map<String, dynamic>? medData) {
    if (medData == null) return {"time": "--:--", "status": "Belum ada obat"};
    
    String alarmTime = medData["remind_at"] != null 
        ? medData["remind_at"].toString().substring(0, 5) 
        : "18:00";
    String infoStatus = "Pengingat obat berikutnya aktif";

    if (medData["times_array"] != null && medData["times_array"] is List) {
      List times = medData["times_array"];
      DateTime skg = DateTime.now();
      String hitungJamEsok = times.first.toString();
      bool ditemukan = false; 

      for (var t in times) {
        List<String> parts = t.toString().split(':');
        int jamJadwal = int.parse(parts[0]);
        int menitJadwal = int.parse(parts[1]);

        if (jamJadwal > skg.hour || (jamJadwal == skg.hour && menitJadwal > skg.minute)) {
          alarmTime = t.toString().substring(0, 5);
          infoStatus = "Jadwal minum obat berikutnya hari ini";
          ditemukan = true;
          break;
        }
      }

      if (!ditemukan) {
        alarmTime = hitungJamEsok.substring(0, 5);
        infoStatus = "Jadwal obat terdekat esok pagi";
      }
    }

    return {"time": alarmTime, "status": infoStatus};
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xfff8fafc),
        body: Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(error!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchDashboard,
      color: Colors.blueAccent,
      child: Scaffold(
        backgroundColor: const Color(0xfff8fafc),
        appBar: AppBar(
          backgroundColor: const Color(0xfff8fafc),
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0, top: 10.0),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                        )
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications, color: Colors.blueAccent),
                      onPressed: () {},
                    ),
                  ),
                  if (passport?["pending_approval_count"] != null &&
                      passport?["pending_approval_count"] > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${passport?["pending_approval_count"]}',
                          style: const TextStyle(color: Colors.white, fontSize: 8),
                        ),
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            // Search Bar Fungsional
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Cari jadwal, obat, atau riwayat...",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ==========================================
            // TOMBOL BARU: BANNER LAYANAN UTAMA DAFTAR RS
            // ==========================================
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HospitalListPage(token: widget.token)),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xffeff6ff), // Soft blue background
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_hospital, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pendaftaran Berobat",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff1e293b)),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Cari Rumah Sakit & Poliklinik mitra",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent, size: 16)
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Header Jadwal Kontrol
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Jadwal Pemeriksaan",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xff334155)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailJadwalPage(appointments: filteredAppointments),
                      ),
                    );
                  },
                  child: const Text("Lebih banyak", style: TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 8),
            buildCalendarCard(),
            const SizedBox(height: 20),

            // Header Jadwal Obat
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Pengingat Obat",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xff334155)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailObatPage(medication: filteredMedication),
                      ),
                    );
                  },
                  child: const Text("Lebih banyak", style: TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 8),
            buildMedicationCard(),
            const SizedBox(height: 24),

            buildPassportCard(),
            const SizedBox(height: 24),

            // Header Riwayat
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Riwayat Klinis",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xff334155)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailRiwayatPage(history: filteredHistory),
                      ),
                    );
                  },
                  child: const Text("Lihat semua", style: TextStyle(color: Colors.blueAccent, fontSize: 13)),
                )
              ],
            ),
            const SizedBox(height: 8),
            buildHistoryList(),
            const SizedBox(height: 110), 
          ],
        ),
      ),
    );
  }

  Widget buildCalendarCard() {
    final now = DateTime.now();
    bool hasDataJadwal = filteredAppointments.isNotEmpty;
    
    String rsName = _searchQuery.isNotEmpty ? "Tidak cocok dengan pencarian" : "Belum ada jadwal";
    String diseaseName = _searchQuery.isNotEmpty ? "Coba kata kunci lain" : "Tidak ada kontrol terdekat";
    String timeRange = "--:--";
    
    DateTime? nextAppDate;

    if (hasDataJadwal) {
      rsName = filteredAppointments.first["rs_name"] ?? "RS UMMI BOGOR";
      diseaseName = filteredAppointments.first["reason"] ?? "Flu dan batuk";
      timeRange = "Waktu : 10:00 - 11:00"; 
      
      if (filteredAppointments.first["appointment_date"] != null) {
        nextAppDate = DateTime.parse(filteredAppointments.first["appointment_date"]);
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final date = now.add(Duration(days: index - 3));
              bool isToday = date.day == now.day && date.month == now.month && date.year == now.year;
              
              bool dateHasAppointment = appointments.any((item) {
                if (item["appointment_date"] == null) return false;
                DateTime appDate = DateTime.parse(item["appointment_date"]);
                return appDate.day == date.day && appDate.month == date.month && appDate.year == date.year;
              });

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isToday ? Colors.blueAccent : Colors.transparent,
                    ),
                    child: Text(
                      "${date.day}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isToday 
                            ? Colors.white 
                            : (dateHasAppointment ? Colors.blueAccent : Colors.grey.shade600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (dateHasAppointment && !isToday)
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(height: 5), 
                  const SizedBox(height: 2),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isToday ? const Color(0xffe0f2fe) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _getNamaBulanIndo(date.month),
                      style: TextStyle(
                        color: isToday ? Colors.blueAccent : Colors.grey.shade400,
                        fontSize: 9,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 16),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasDataJadwal && nextAppDate != null) ...[
                Column(
                  children: [
                    Text(
                      "${nextAppDate.day}",
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blueAccent, height: 1.1),
                    ),
                    Text(
                      _getNamaBulanIndo(nextAppDate.month),
                      style: const TextStyle(fontSize: 14, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                  child: const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 28),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Jadwal Kontrol Berikutnya", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(
                      rsName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff1e293b)),
                    ),
                    Text(
                      diseaseName,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    if (hasDataJadwal) ...[
                      const SizedBox(height: 8),
                      Text(timeRange, style: const TextStyle(color: Color(0xff475569), fontSize: 12, fontWeight: FontWeight.w600)),
                    ]
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget buildMedicationCard() {
    if (filteredMedication == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Icon(Icons.medication_outlined, size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty ? "Obat tidak ditemukan" : "Belum ada jadwal obat", 
              style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)
            ),
          ],
        ),
      );
    }

    String medicineName = filteredMedication!["medicine_name"] ?? "Belum ada obat";
    String rules = filteredMedication!["rules"] ?? "0 Kali Sehari";
    
    Map<String, String> kalkulasiWaktu = _getJadwalObatTerdekat(filteredMedication);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Color(0xffe0f2fe), shape: BoxShape.circle),
                child: const Icon(Icons.alarm, color: Colors.blueAccent, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(medicineName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff1e293b))),
                    Text(rules, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Text(
                kalkulasiWaktu["time"]!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xff334155)),
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(width: 46),
              Icon(Icons.info_outline, size: 12, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(
                kalkulasiWaktu["status"]!,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget buildPassportCard() {
    String usernamePasien = passport?["patient_name"] ?? "";
    String noBpjsPasien = passport?["no_bpjs"] ?? "";
    String statusMedis = passport?["medical_status"] ?? "";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xff2563eb), Color(0xff3b82f6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 16,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24, width: 0.5),
                    ),
                    child: Column(
                      children: [
                        Expanded(child: Container(color: Colors.red)),
                        Expanded(child: Container(color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text("Passport Kesehatan", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500))
                ],
              ),
              const SizedBox(height: 16),
              Text(
                usernamePasien.isNotEmpty ? usernamePasien : "Belum Ada Nama",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 2),
              Text(
                noBpjsPasien.isNotEmpty ? "No. BPJS: $noBpjsPasien" : "No. BPJS: Belum Terikat",
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      "Status : ${statusMedis.isNotEmpty ? statusMedis.toUpperCase() : 'BELUM AKTIF'}",
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (passport != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPassportPage(
                              passportData: passport!,
                              onTabChanged: widget.onTabChanged,
                            ), 
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Data passport belum tersedia')),
                        );
                      }
                    },
                    child: const Text("Selengkapnya", style: TextStyle(color: Colors.white, fontSize: 11, decoration: TextDecoration.underline, decorationColor: Colors.white)),
                  )
                ],
              )
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 36,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xfffbbf24), 
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Icon(
                  Icons.bookmark, 
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildHistoryList() {
    if (filteredHistory.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Icon(Icons.assignment_late_outlined, size: 42, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty ? "Riwayat tidak ditemukan" : "Belum ada laporan riwayat", 
              style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)
            ),
          ],
        ),
      );
    }

    return Column(
      children: filteredHistory.map((item) {
        String statusText = item["patient_status"] ?? "Sembuh";
        bool isSembuh = statusText.toLowerCase().contains("sembuh") || statusText.toLowerCase() == "sehat";

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["room"]?["name"] ?? "Klinik Umum",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff1e293b)),
                    ),
                    const SizedBox(height: 2),
                    Text(item["disease"]?["name"] ?? "Pemeriksaan rutin", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text("Selesai diperiksa", style: TextStyle(color: Colors.grey.shade400, fontSize: 10))
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSembuh ? const Color(0xffdcfce7) : const Color(0xfffee2e2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(color: isSembuh ? const Color(0xff16a34a) : Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        );
      }).toList(),
    );
  }
}