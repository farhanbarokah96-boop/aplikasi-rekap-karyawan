import 'package:flutter/material.dart';
import '../data/repository.dart';
import '../models.dart';
import '../theme.dart';
import 'detail_kc_screen.dart';

class KcListScreen extends StatefulWidget {
  final SubUnitCategory? initialCategory;

  const KcListScreen({super.key, this.initialCategory});

  @override
  State<KcListScreen> createState() => _KcListScreenState();
}

class _KcListScreenState extends State<KcListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final repo = RekapRepository();
    final allKc = repo.semuaKc;

    final filteredKc = allKc.where((kc) {
      final q = _searchQuery.toLowerCase();
      return kc.nama.toLowerCase().contains(q) || kc.kode.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Daftar KC (Main Unit)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari Kantor Cabang (KC)...',
                prefixIcon: const Icon(Icons.search),
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
          ),
          const Divider(height: 1),
          Expanded(
            child: filteredKc.isEmpty
                ? const Center(
                    child: Text('Kantor Cabang tidak ditemukan', style: TextStyle(color: AppColors.textMuted)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredKc.length,
                    itemBuilder: (context, index) {
                      final kc = filteredKc[index];
                      final kcpCount = repo.subUnitByCategory(kc.id, SubUnitCategory.kcp).length;
                      final kkCount = repo.subUnitByCategory(kc.id, SubUnitCategory.kk).length;
                      final unitTerasCount = repo.subUnitByCategory(kc.id, SubUnitCategory.unitTeras).length;
                      final gap = repo.gapTotalKc(kc.id);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(
                            kc.nama,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sub Units: $kcpCount KCP • $kkCount KK • $unitTerasCount Unit & Teras',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Formasi: ${repo.formasiTotalKc(kc.id)} | Existing: ${repo.existingTotalKc(kc.id)}',
                                  style: const TextStyle(fontSize: 11.5, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: gap < 0 ? AppColors.dangerBg : AppColors.secondaryBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Gap $gap',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: gap < 0 ? AppColors.danger : AppColors.success,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailKcScreen(
                                  kcId: kc.id,
                                  tabAwal: widget.initialCategory,
                                ),
                              ),
                            );
                          },
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
