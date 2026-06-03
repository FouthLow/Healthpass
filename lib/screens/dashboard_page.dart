import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'detail_page.dart';
import 'detail_passport_page.dart'; 
import 'hospital_list_page.dart'; 
import 'notifications_history_page.dart';
import '../widget/notification_helper.dart';

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
  List todayMedications = [];

  List filteredAppointments = [];
  List filteredHistory = [];
  Map<String, dynamic>? filteredMedication;
  
  List _prevHistory = [];
  List _prevAppointments = [];
  List _prevTodayMedications = [];
  bool _firstLoadCompleted = false;

  final Set<String> _firedAlarms = {};
  final Set<String> _firedNotifications = {};
  Timer? _timer;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final String baseUrl = "http://127.0.0.1:8000";

  @override
  void initState() {
    super.initState();
    fetchDashboard();
    _searchController.addListener(_onSearchChanged);
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      fetchDashboard();
      _checkAlarmsAndNotifications();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _checkAlarmsAndNotifications() {
    if (!mounted) return;

    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final currentHourMinute = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    // 1. Check Medication Alarms
    for (var med in todayMedications) {
      if (med["remind_at"] == null) continue;

      final String remindAt = med["remind_at"].toString();
      final String remindHourMinute = remindAt.substring(0, 5);

      if (remindHourMinute == currentHourMinute) {
        final alarmKey = "${med['medicine_name']}_${remindHourMinute}_$todayStr";
        if (!_firedAlarms.contains(alarmKey)) {
          _firedAlarms.add(alarmKey);
          NotificationHelper.showMedicationAlarm(context, Map<String, dynamic>.from(med));
        }
      }
    }

    // 2. Check Appointment Notifications
    for (var app in appointments) {
      if (app["appointment_date"] == null) continue;

      final String appDateStr = app["appointment_date"].toString();
      if (appDateStr == todayStr) {
        final notifKey = "appointment_${app['id']}_$todayStr";
        if (!_firedNotifications.contains(notifKey)) {
          _firedNotifications.add(notifKey);
          NotificationHelper.showAppointmentNotification(context, Map<String, dynamic>.from(app));
        }
      }
    }
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
        
        final newHistory = data["medical_history"] ?? [];
        final newAppointments = data["calendar_appointments"] ?? [];
        final newTodayMedications = data["today_medications"] ?? [];

        if (_firstLoadCompleted) {
          // Compare history
          if (_prevHistory.isNotEmpty && newHistory.isNotEmpty) {
            final newRecord = newHistory.first;
            final prevRecord = _prevHistory.first;
            if (newRecord["id"] != prevRecord["id"]) {
              final String rsName = newRecord["visit"]?["rs_name"] ?? newRecord["rs_name"] ?? "Rumah Sakit";
              final String diseaseName = newRecord["disease"]?["name"] ?? "Diagnosis baru";
              NotificationHelper.showInAppNotification(
                context: context,
                title: "Rekam Medis Baru Diterima",
                message: "Hasil pemeriksaan dari $rsName: $diseaseName",
                icon: Icons.history_edu_rounded,
                iconColor: const Color(0xff10b981),
              );
              NotificationHelper.logNotification(
                title: "Rekam Medis Baru Diterima",
                message: "Hasil pemeriksaan dari $rsName: $diseaseName",
                type: "record_update",
              );
            }
          }

          // Compare appointments
          if (_prevAppointments.isNotEmpty && newAppointments.length > _prevAppointments.length) {
            final newApp = newAppointments.last;
            final String rsName = newApp["rs_name"] ?? "Rumah Sakit";
            final String notes = newApp["notes"] ?? "Kontrol Medis";
            NotificationHelper.showInAppNotification(
              context: context,
              title: "Jadwal Kontrol Baru",
              message: "Jadwal di $rsName: $notes",
              icon: Icons.event_note_rounded,
              iconColor: Colors.purpleAccent,
            );
            NotificationHelper.logNotification(
              title: "Jadwal Kontrol Baru",
              message: "Jadwal di $rsName: $notes",
              type: "appointment",
            );
          }

          // Compare medications
          if (_prevTodayMedications.isNotEmpty && newTodayMedications.length > _prevTodayMedications.length) {
            final newMed = newTodayMedications.last;
            final String medName = newMed["medicine_name"] ?? "Obat Baru";
            final String rules = newMed["rules"] ?? "3 x 1 sehari";
            NotificationHelper.showInAppNotification(
              context: context,
              title: "Alarm Pengingat Obat Aktif",
              message: "Rutin minum $medName ($rules)",
              icon: Icons.alarm_on_rounded,
              iconColor: Colors.orangeAccent,
            );
            NotificationHelper.logNotification(
              title: "Alarm Pengingat Obat Aktif",
              message: "Rutin minum $medName ($rules)",
              type: "alarm",
            );
          }
        }

        setState(() {
          passport = data["health_passport"];
          medication = data["next_medication_alarm"];
          appointments = newAppointments;
          history = newHistory;
          todayMedications = newTodayMedications;
          
          filteredAppointments = List.from(appointments);
          filteredHistory = List.from(history);
          filteredMedication = medication != null ? Map<String, dynamic>.from(medication!) : null;
          
          _prevHistory = List.from(history);
          _prevAppointments = List.from(appointments);
          _prevTodayMedications = List.from(todayMedications);
          _firstLoadCompleted = true;
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
          title: Padding(
            padding: const EdgeInsets.only(left: 4.0, top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  passport?["patient_name"] ?? "Pasien",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1e293b),
                  ),
                ),
                Text(
                  passport?["no_bpjs"] != null && passport?["no_bpjs"] != ""
                      ? "BPJS: ${passport?["no_bpjs"]}"
                      : "BPJS: -",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsHistoryPage(),
                          ),
                        ).then((_) {
                          fetchDashboard();
                        });
                      },
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
        return HistoryCardWidget(item: Map<String, dynamic>.from(item));
      }).toList(),
    );
  }
}

class HistoryCardWidget extends StatefulWidget {
  final Map<String, dynamic> item;
  const HistoryCardWidget({super.key, required this.item});

  @override
  State<HistoryCardWidget> createState() => _HistoryCardWidgetState();
}

class _HistoryCardWidgetState extends State<HistoryCardWidget> {
  String _getBulanIndo(int bulan) {
    const bulanIndo = [
      "Jan", "Feb", "Mar", "Apr", "Mei", "Jun", 
      "Jul", "Agu", "Sep", "Okt", "Nov", "Des"
    ];
    return bulanIndo[bulan - 1];
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    String statusText = item["patient_status"] ?? "Sembuh";
    Color badgeBgColor = const Color(0xffdcfce7);
    Color badgeTextColor = const Color(0xff16a34a);

    if (statusText.toLowerCase().contains("jalan")) {
      badgeBgColor = const Color(0xffe0f2fe);
      badgeTextColor = const Color(0xff0284c7);
    } else if (statusText.toLowerCase().contains("inap")) {
      badgeBgColor = const Color(0xfffee2e2);
      badgeTextColor = Colors.red;
    }

    String tanggalFormat = "Bulan Lalu";
    if (item["created_at"] != null) {
      DateTime parsedDate = DateTime.parse(item["created_at"]);
      final hour = parsedDate.hour.toString().padLeft(2, '0');
      final minute = parsedDate.minute.toString().padLeft(2, '0');
      tanggalFormat = "${parsedDate.day} ${_getBulanIndo(parsedDate.month)} ${parsedDate.year} $hour:$minute";
    }

    final String rsName = item["visit"]?["rs_name"] ?? item["rs_name"] ?? "Rumah Sakit Umum";
    final String doctorName = item["doctor"]?["name"] ?? "-";
    final String specialist = item["doctor"]?["specialist"] ?? "";
    final String symptoms = item["symptoms"] ?? "Pemeriksaan rutin";
    final List appointments = item["appointments"] ?? [];
    final List medicationSchedules = item["medication_schedules"] ?? item["medicationSchedules"] ?? [];

    String obatStr = medicationSchedules.isNotEmpty 
        ? medicationSchedules.map((m) => m["medicine_name"] ?? "-").join(", ")
        : "Tidak ada obat";

    String kontrolStr = "Tidak ada";
    if (appointments.isNotEmpty) {
      final apt = appointments.first;
      if (apt["appointment_date"] != null) {
        final parsed = DateTime.parse(apt["appointment_date"]);
        kontrolStr = "${parsed.day} ${_getBulanIndo(parsed.month)} ${parsed.year}";
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            item["room"]?["name"] ?? "Klinik Umum",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff1e293b)),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.local_hospital_outlined, size: 12, color: Colors.blueAccent),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      "$rsName • $tanggalFormat",
                      style: const TextStyle(color: Color(0xff475569), fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      "Dokter: $doctorName • Diagnosis: ${item["disease"]?["name"] ?? "Pemeriksaan rutin"}",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.medication_liquid_rounded, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      "Obat: $obatStr",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                    ),
                  ),
                ],
              ),
              if (appointments.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.event_available_outlined, size: 12, color: Colors.orange),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "Kontrol Kembali: $kontrolStr",
                        style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: badgeBgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: TextStyle(color: badgeTextColor, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, color: Color(0xfff1f5f9)),
                  const SizedBox(height: 12),
                  
                  _buildDetailRow(
                    icon: Icons.local_hospital_rounded,
                    label: "Faskes / Rumah Sakit",
                    value: rsName,
                  ),
                  const SizedBox(height: 10),

                  _buildDetailRow(
                    icon: Icons.person_rounded,
                    label: "Dokter Penanggung Jawab",
                    value: specialist.isNotEmpty ? "$doctorName ($specialist)" : doctorName,
                  ),
                  const SizedBox(height: 10),

                  _buildDetailRow(
                    icon: Icons.medical_services_rounded,
                    label: "Keluhan / Gejala Klinis",
                    value: symptoms,
                  ),
                  
                  if (medicationSchedules.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      "Resep Obat & Alarm Pengingat",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    ...medicationSchedules.map((med) {
                      final String alarmTime = med["remind_at"] != null 
                          ? med["remind_at"].toString().substring(0, 5) 
                          : "--:--";
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xfff8fafc),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xffe2e8f0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    med["medicine_name"] ?? "-",
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff334155)),
                                  ),
                                  Text(
                                    med["rules"] ?? "-",
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xfffff7ed),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.alarm, size: 12, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(
                                    alarmTime,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  ],

                  if (appointments.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      "Jadwal Kontrol Kembali",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    ...appointments.map((apt) {
                      String aptDateStr = "-";
                      if (apt["appointment_date"] != null) {
                        final parsed = DateTime.parse(apt["appointment_date"]);
                        aptDateStr = "${parsed.day} ${_getBulanIndo(parsed.month)} ${parsed.year}";
                      }
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xfff8fafc),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xffe2e8f0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event_note_rounded, size: 16, color: Colors.blueAccent),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    aptDateStr,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff334155)),
                                  ),
                                  Text(
                                    apt["notes"] ?? "Kontrol Medis",
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 13, color: Color(0xff334155), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}