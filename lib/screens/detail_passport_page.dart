import 'package:flutter/material.dart';

class DetailPassportPage extends StatelessWidget {
  final Map<String, dynamic> passportData;

  const DetailPassportPage({super.key, required this.passportData});

  @override
  Widget build(BuildContext context) {
    // Mengekstrak data dari Map API
    final String nama = passportData['patient_name'] ?? "Ahmad F. Ahla";
    final String statusKesehatan = passportData['medical_status'] ?? "Sembuh Total";
    final String golDarah = passportData['blood_type'] ?? "-";
    final String penyakitKritis = passportData['critical_diseases'] ?? "Tidak ada";
    
    // Menggabungkan alergi obat dan makanan
    final String alergiObat = passportData['drug_allergies'] ?? "";
    final String alergiMakanan = passportData['food_allergies'] ?? "";
    final List<String> listAlergi = [];
    if (alergiObat.isNotEmpty && alergiObat != "Tidak ada") listAlergi.add(alergiObat);
    if (alergiMakanan.isNotEmpty && alergiMakanan != "Tidak ada") listAlergi.add(alergiMakanan);

    // Disabilitas
    final List<dynamic> disabilitasRaw = passportData['disabilities'] ?? [];
    final String disabilitas = disabilitasRaw.isNotEmpty ? disabilitasRaw.join(", ") : "Tidak ada";

    // Tinggi & Berat Badan
    final String tinggiBadan = passportData['height_cm'] != null ? "${passportData['height_cm']} cm" : "-";
    final String beratBadan = passportData['weight_kg'] != null ? "${passportData['weight_kg']} kg" : "-";

    // Kontak Darurat
    final String kontakNama = passportData['emergency_contact_name'] ?? "-";
    final String kontakTelp = passportData['emergency_contact_phone'] ?? "-";

    // Status Logika Badge
    final bool hasDisability = disabilitasRaw.isNotEmpty;
    final bool hasCritical = penyakitKritis.toLowerCase() != "tidak ada" && penyakitKritis.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),
      body: Column(
        children: [
          // ==========================================
          // HEADER BIRU
          // ==========================================
          Container(
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
            decoration: const BoxDecoration(
              color: Color(0xff3b82f6),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Passport Kesehatan", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 2),
                            Text(
                              nama,
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.bookmark, color: Color(0xfffbbf24), size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 24,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.red,
                      ),
                      child: Column(
                        children: [
                          Expanded(child: Container(color: Colors.red)),
                          Expanded(child: Container(color: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Ringkasan kesehatan", style: TextStyle(color: Colors.white, fontSize: 12)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusKesehatan.toUpperCase(),
                            style: const TextStyle(color: Color(0xff16a34a), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),

          // ==========================================
          // KONTEN KARTU DETAIL
          // ==========================================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Baris Pertama: Gol Darah & Alergi
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kartu Gol Darah
                    Expanded(
                      flex: 1,
                      child: _buildStatCard(
                        title: "Gol darah",
                        subtitle: "Tanggal pemeriksaan: Terbaru",
                        content: Text(
                          golDarah,
                          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xff1e293b)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Kartu Alergi
                    Expanded(
                      flex: 1,
                      child: _buildStatCard(
                        title: "Alergi",
                        subtitle: "Obat dan lainnya",
                        content: listAlergi.isEmpty
                            ? const Text("Tidak ada alergi", style: TextStyle(color: Colors.grey, fontSize: 13))
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: listAlergi.map((alergi) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xffe0f2fe),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        alergi,
                                        style: const TextStyle(color: Color(0xff3b82f6), fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    )).toList(),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Kartu Disabilitas
                _buildStatCard(
                  title: "Disabilitas",
                  subtitle: "Tanggal pemeriksaan: Terbaru",
                  titleWidget: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          disabilitas, 
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1e293b)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: hasDisability ? const Color(0xfffee2e2) : const Color(0xffdcfce7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          hasDisability ? "Perlu Perhatian" : "Aman",
                          style: TextStyle(
                            color: hasDisability ? const Color(0xffdc2626) : const Color(0xff16a34a),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Kartu Penyakit Kritis
                _buildStatCard(
                  title: "Penyakit Kritis",
                  subtitle: "Tanggal pemeriksaan: Terbaru",
                  titleWidget: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          penyakitKritis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1e293b)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: hasCritical ? const Color(0xfffee2e2) : const Color(0xffdcfce7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          hasCritical ? "Perlu Pengawasan" : "Aman",
                          style: TextStyle(
                            color: hasCritical ? const Color(0xffdc2626) : const Color(0xff16a34a),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Kartu Tinggi & Berat Badan
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: "Tinggi Badan",
                        subtitle: "Hasil pengukuran fisik",
                        content: Text(
                          tinggiBadan,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xff1e293b)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: "Berat Badan",
                        subtitle: "Hasil pengukuran fisik",
                        content: Text(
                          beratBadan,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xff1e293b)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Kartu Kontak Darurat
                _buildStatCard(
                  title: "Kontak Darurat",
                  subtitle: "Gunakan bila dalam kondisi mendesak",
                  titleWidget: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            kontakNama,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1e293b)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xffeff6ff),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
                            ),
                            child: const Text(
                              "Hubungi",
                              style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        kontakTelp,
                        style: const TextStyle(fontSize: 14, color: Colors.blueAccent, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Fungsi helper pembangun Card agar kode tidak berulang-ulang
  Widget _buildStatCard({
    required String title,
    required String subtitle,
    Widget? content,
    Widget? titleWidget,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (content != null) ...[
            Center(child: content),
            const SizedBox(height: 12),
          ],
          if (titleWidget != null) ...[
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 6),
            titleWidget,
          ] else ...[
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1e293b))),
          ],
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }
}