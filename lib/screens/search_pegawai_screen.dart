import 'package:flutter/material.dart';
import '../data/repository.dart';
import '../models.dart';
import '../theme.dart';

class SearchPegawaiScreen extends StatefulWidget {
  const SearchPegawaiScreen({super.key});

  @override
  State<SearchPegawaiScreen> createState() => _SearchPegawaiScreenState();
}

class _SearchPegawaiScreenState extends State<SearchPegawaiScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final repo = RekapRepository();
    final allPegawai = repo.semuaPegawai;

    final results = _query.trim().isEmpty
        ? <Pegawai>[]
        : allPegawai.where((p) {
            final q = _query.toLowerCase();
            return p.nama.toLowerCase().contains(q) ||
                p.pernr.toLowerCase().contains(q) ||
                p.nip.toLowerCase().contains(q) ||
                p.jabatan.toLowerCase().contains(q);
          }).take(100).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Cari Pegawai FL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Ketik Nama, PERNR, NIP, atau Jabatan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _query = '';
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
                  _query = val;
                });
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _query.trim().isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text(
                          'Ketik kata kunci untuk mencari dari ${allPegawai.length} pegawai',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : results.isEmpty
                    ? const Center(
                        child: Text('Pegawai tidak ditemukan', style: TextStyle(color: AppColors.textMuted)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final p = results[index];
                          final unit = repo.unitById(p.unitKerjaId);
                          final parentKc = unit?.kcIndukId != null ? repo.unitById(unit!.kcIndukId!) : null;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.navyPale.withValues(alpha: 0.2),
                                child: Text(
                                  p.nama.isNotEmpty ? p.nama[0].toUpperCase() : 'P',
                                  style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(p.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${p.jabatan} • PERNR: ${p.pernr} • NIP: ${p.nip}', style: const TextStyle(fontSize: 11.5)),
                                  if (unit != null)
                                    Text(
                                      'Penempatan: ${unit.nama} (${unit.jenis.label})${parentKc != null ? " - ${parentKc.nama}" : ""}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.navy),
                                    ),
                                ],
                              ),
                              isThreeLine: true,
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
