import 'package:flutter/material.dart';
import '../widget/notification_helper.dart';

// Helper untuk mendapatkan nama bulan singkat bahasa Indonesia
String _getBulanIndo(int bulan) {
  const bulanIndo = [
    "Jan", "Feb", "Mar", "Apr", "Mei", "Jun", 
    "Jul", "Agu", "Sep", "Okt", "Nov", "Des"
  ];
  return bulanIndo[bulan - 1];
}

// ==========================================
// 1. HALAMAN DETAIL JADWAL PEMERIKSAAN (ON-GOING & HISTORY)
// ==========================================
class DetailJadwalPage extends StatelessWidget {
  final List appointments;
  const DetailJadwalPage({super.key, required this.appointments});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      appBar: AppBar(
        title: const Text("Jadwal Pemeriksaan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xff334155))),
        backgroundColor: const Color(0xfff8fafc),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: appointments.isEmpty
          ? const Center(child: Text("Tidak ada jadwal kontrol", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final item = appointments[index];
                DateTime? appDate;
                if (item["appointment_date"] != null) {
                  appDate = DateTime.parse(item["appointment_date"]);
                }

                // Menentukan apakah jadwal ini masih aktif (on-going) atau sudah lewat (history)
                bool isOngoing = appDate != null && !appDate.isBefore(DateTime(now.year, now.month, now.day));

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))
                    ],
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Kotak Indikator Tanggal Sebelah Kiri (Sesuai Desain Anda)
                        Container(
                          width: 85,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: isOngoing ? const Color(0xff3b82f6) : const Color(0xff94a3b8),
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                appDate != null ? "${appDate.day}" : "--",
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1),
                              ),
                              Text(
                                appDate != null ? _getBulanIndo(appDate.month) : "-",
                                style: const TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        // Konten Informasi di Sebelah Kanan
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Jadwal Pemeriksaan",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff1e293b)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item["rs_name"] ?? "Nama RS tidak tersedia",
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  item["notes"] ?? "Flu dan batuk",
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                 const SizedBox(height: 12),
                                 const Text(
                                   "Waktu : 10:00 - 11:00",
                                   style: TextStyle(color: Color(0xff475569), fontSize: 12, fontWeight: FontWeight.w600),
                                 ),
                                 const SizedBox(height: 12),
                                 TextButton.icon(
                                   onPressed: () {
                                     NotificationHelper.showAppointmentNotification(context, Map<String, dynamic>.from(item));
                                   },
                                   icon: const Icon(Icons.notifications_active_outlined, size: 16, color: Colors.blueAccent),
                                   label: const Text("Simulasikan Notifikasi", style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                                   style: TextButton.styleFrom(
                                     padding: EdgeInsets.zero,
                                     minimumSize: Size.zero,
                                     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                   ),
                                 )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ==========================================
// 2. HALAMAN DETAIL PENGINGAT OBAT (DAFTAR OBAT JALAN)
// ==========================================
class DetailObatPage extends StatelessWidget {
  final Map<String, dynamic>? medication;
  const DetailObatPage({super.key, this.medication});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      appBar: AppBar(
        title: const Text("Pengingat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xff334155))),
        backgroundColor: const Color(0xfff8fafc),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: medication == null
          ? const Center(child: Text("Tidak ada jadwal konsumsi obat aktif", style: TextStyle(color: Colors.grey)))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(color: Color(0xfffaf5ff), shape: BoxShape.circle),
                            child: const Icon(Icons.blur_circular, color: Colors.purpleAccent, size: 26),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  medication!["medicine_name"] ?? "-",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xff1e293b)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  medication!["rules"] ?? "1 Kali sehari",
                                  style: const TextStyle(color: Color(0xff3b82f6), fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                const Text(
                                  "Setiap Hari - Rutin",
                                  style: TextStyle(color: Colors.grey, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                medication!["remind_at"] != null 
                                    ? medication!["remind_at"].toString().substring(0, 5) 
                                    : "18:00",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xff334155)),
                              ),
                              const Text("WIB", style: TextStyle(color: Colors.grey, fontSize: 10)),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ==========================================
// 3. HALAMAN DETAIL RIWAYAT REKAM MEDIS Pasien
// ==========================================
class DetailRiwayatPage extends StatelessWidget {
  final List history;
  const DetailRiwayatPage({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      appBar: AppBar(
        title: const Text("Riwayat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xff334155))),
        backgroundColor: const Color(0xfff8fafc),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: history.isEmpty
          ? const Center(child: Text("Belum ada riwayat rekam medis", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return HistoryCardWidget(item: Map<String, dynamic>.from(item));
              },
            ),
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