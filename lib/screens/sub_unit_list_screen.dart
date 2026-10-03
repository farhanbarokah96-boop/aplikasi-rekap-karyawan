import 'package:flutter/material.dart';
import '../data/repository.dart';
import '../models.dart';
import '../theme.dart';
import 'detail_kantor_screen.dart';

class SubUnitListScreen extends StatefulWidget {
  final SubUnitCategory category;

  const SubUnitListScreen({super.key, required this.category});

  @override
  State<SubUnitListScreen> createState() => _SubUnitListScreenState();
}

class _SubUnitListScreenState extends State<SubUnitListScreen> {
  String _searchQuery = '';

  IconData get _categoryIcon {
    switch (widget.category) {
      case SubUnitCategory.kcp:
        return Icons.business;
      case SubUnitCategory.kk:
        return Icons.account_tree;
      case SubUnitCategory.unitTeras:
        return Icons.storefront;
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = RekapRepository();
    final allSubUnits = repo.semuaSubUnitByCategory(widget.category);

    final filteredUnits = allSubUnits.where((unit) {
      final q = _searchQuery.toLowerCase();
      final parentKc = unit.kcIndukId != null ? repo.unitById(unit.kcIndukId!) : null;
      final parentName = parentKc?.nama.toLowerCase() ?? '';
      return unit.nama.toLowerCase().contains(q) ||
          unit.kode.toLowerCase().contains(q) ||
          parentName.contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: Text(
          'Daftar ${widget.category.label}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search input
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari ${widget.category.label} atau nama KC...',
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

          // Count summary bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total ${widget.category.label}: ${allSubUnits.length} lokasi',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navy),
                ),
                if (_searchQuery.isNotEmpty)
                  Text(
                    'Ditemukan: ${filteredUnits.length}',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Sub units list
          Expanded(
            child: filteredUnits.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.category.label} tidak ditemukan',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredUnits.length,
                    itemBuilder: (context, index) {
                      final unit = filteredUnits[index];
                      final parentKc = unit.kcIndukId != null ? repo.unitById(unit.kcIndukId!) : null;
                      final existing = repo.existingDiUnit(unit.id);
                      final gap = repo.gapUnit(unit);

                      String typeLabel = unit.jenis.label;
                      if (unit.jenis == JenisKantor.unit) typeLabel = 'Unit';
                      if (unit.jenis == JenisKantor.teras) typeLabel = 'Teras';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.navyPale,
                            child: Icon(_categoryIcon, color: AppColors.navy, size: 20),
                          ),
                          title: Text(
                            unit.nama,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // NAMA KC INDUK DIBAWAH NAMA UNIT
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  margin: const EdgeInsets.only(bottom: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.navyPale.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.account_balance, size: 12, color: AppColors.navy),
                                      const SizedBox(width: 4),
                                      Text(
                                        parentKc != null ? parentKc.nama : 'KC Utama',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.navy,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '[$typeLabel] CS: ${unit.formasiCs} | Tel: ${unit.formasiTeller}'
                                  '${unit.formasiUb > 0 ? " | UB: ${unit.formasiUb}" : ""} · Existing: $existing',
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
                                  gap < 0 ? 'Gap $gap' : (gap == 0 ? 'Pas' : '+$gap'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: gap < 0
                                        ? AppColors.danger
                                        : (gap == 0 ? AppColors.success : AppColors.warning),
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
                                builder: (_) => DetailKantorScreen(unitId: unit.id),
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
