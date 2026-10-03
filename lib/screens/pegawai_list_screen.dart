import 'package:flutter/material.dart';
import '../data/repository.dart';
import '../models.dart';
import '../theme.dart';
import 'detail_kantor_screen.dart';

class PegawaiListScreen extends StatefulWidget {
  const PegawaiListScreen({super.key});

  @override
  State<PegawaiListScreen> createState() => _PegawaiListScreenState();
}

class _PegawaiListScreenState extends State<PegawaiListScreen> {
  String _searchQuery = '';
  StatusPegawai? _selectedStatus;
  final String _selectedJabatan = 'Semua';

  @override
  Widget build(BuildContext context) {
    final repo = RekapRepository();
    final allPegawai = repo.semuaPegawai;

    final filteredPegawai = allPegawai.where((p) {
      // Filter status
      if (_selectedStatus != null && p.status != _selectedStatus) {
        return false;
      }

      // Filter jabatan
      if (_selectedJabatan != 'Semua') {
        if (!p.jabatan.toLowerCase().contains(_selectedJabatan.toLowerCase())) {
          return false;
        }
      }

      // Search query
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final unit = repo.unitById(p.unitKerjaId);
        final parentKc = unit?.kcIndukId != null ? repo.unitById(unit!.kcIndukId!) : null;

        final unitName = unit?.nama.toLowerCase() ?? '';
        final kcName = parentKc?.nama.toLowerCase() ?? '';

        return p.nama.toLowerCase().contains(q) ||
            p.pernr.toLowerCase().contains(q) ||
            p.nip.toLowerCase().contains(q) ||
            p.jabatan.toLowerCase().contains(q) ||
            unitName.contains(q) ||
            kcName.contains(q);
      }

      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Daftar Pegawai FL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search & Filter Container
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari nama, PERNR, NIP, unit, atau KC...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.secondaryBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
                const SizedBox(height: 10),

                // Status Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text('Status: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.navy)),
                      FilterChip(
                        label: const Text('Semua', style: TextStyle(fontSize: 11)),
                        selected: _selectedStatus == null,
                        visualDensity: VisualDensity.compact,
                        onSelected: (val) => setState(() => _selectedStatus = null),
                      ),
                      const SizedBox(width: 6),
                      FilterChip(
                        label: const Text('Kontrak', style: TextStyle(fontSize: 11)),
                        selected: _selectedStatus == StatusPegawai.kontrak,
                        visualDensity: VisualDensity.compact,
                        onSelected: (val) => setState(() => _selectedStatus = StatusPegawai.kontrak),
                      ),
                      const SizedBox(width: 6),
                      FilterChip(
                        label: const Text('Magang', style: TextStyle(fontSize: 11)),
                        selected: _selectedStatus == StatusPegawai.magang,
                        visualDensity: VisualDensity.compact,
                        onSelected: (val) => setState(() => _selectedStatus = StatusPegawai.magang),
                      ),
                      const SizedBox(width: 6),
                      FilterChip(
                        label: const Text('PT/Pensiun 36', style: TextStyle(fontSize: 11)),
                        selected: _selectedStatus == StatusPegawai.tetapPensiun36,
                        visualDensity: VisualDensity.compact,
                        onSelected: (val) => setState(() => _selectedStatus = StatusPegawai.tetapPensiun36),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Result Summary Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Terdata: ${allPegawai.length} Pegawai',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navy),
                ),
                Text(
                  'Ditampilkan: ${filteredPegawai.length}',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Pegawai List
          Expanded(
            child: filteredPegawai.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search_outlined, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        const Text(
                          'Pegawai tidak ditemukan',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredPegawai.length,
                    itemBuilder: (context, index) {
                      final p = filteredPegawai[index];
                      final unit = repo.unitById(p.unitKerjaId);
                      final parentKc = unit?.kcIndukId != null ? repo.unitById(unit!.kcIndukId!) : null;

                      final initial = p.nama.isNotEmpty
                          ? p.nama.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
                          : '?';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: InkWell(
                          onTap: () {
                            if (unit != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailKantorScreen(unitId: unit.id),
                                ),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.navyPale,
                                  child: Text(
                                    initial.toUpperCase(),
                                    style: const TextStyle(
                                      color: AppColors.navy,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              p.nama,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.5,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: p.status == StatusPegawai.magang
                                                  ? AppColors.warningBg
                                                  : AppColors.navyPale,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              p.status.label,
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.bold,
                                                color: p.status == StatusPegawai.magang
                                                    ? AppColors.warning
                                                    : AppColors.navy,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${p.jabatan} • PERNR: ${p.pernr}${p.nip.isNotEmpty && p.nip != "-" ? " • NIP: ${p.nip}" : ""}',
                                        style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                      ),
                                      const SizedBox(height: 6),

                                      // KETERANGAN UNIT ASAL & KC INDUK
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.navyPale.withValues(alpha: 0.5),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: AppColors.navyPale),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.storefront, size: 13, color: AppColors.navy),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: RichText(
                                                text: TextSpan(
                                                  style: const TextStyle(fontSize: 11.5, color: Colors.black87),
                                                  children: [
                                                    const TextSpan(text: 'Unit Asal: ', style: TextStyle(color: AppColors.textMuted)),
                                                    TextSpan(
                                                      text: unit != null ? '${unit.nama} (${unit.jenis.label})' : 'KC Utama',
                                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy),
                                                    ),
                                                    if (parentKc != null) ...[
                                                      const TextSpan(text: ' • '),
                                                      TextSpan(
                                                        text: parentKc.nama,
                                                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.navy),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
