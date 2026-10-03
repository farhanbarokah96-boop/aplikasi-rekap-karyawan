import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';

class KontrakScreen extends StatelessWidget {
  const KontrakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pegawai = List.of(mockPegawaiKontrakHabis)
      ..sort((a, b) => a.kontrakBerakhir!.compareTo(b.kontrakBerakhir!));

    final now = DateTime.now();
    int sisaHari(DateTime tanggal) => tanggal.difference(now).inDays;

    final habis30 = pegawai.where((p) => sisaHari(p.kontrakBerakhir!) <= 30).length;
    final habis60 = pegawai.where((p) => sisaHari(p.kontrakBerakhir!) <= 60).length;
    final habis90 = pegawai.where((p) => sisaHari(p.kontrakBerakhir!) <= 90).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Kontrak akan habis', style: TextStyle(fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Data contoh -- perlu tanggal kontrak asli untuk hitungan sesungguhnya.',
              style: TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontStyle: FontStyle.italic),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: StatCard(label: '30 hari', value: '$habis30', valueColor: AppColors.danger),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(label: '60 hari', value: '$habis60', valueColor: AppColors.warning),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(label: '90 hari', value: '$habis90'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...pegawai.map((p) {
            final sisa = sisaHari(p.kontrakBerakhir!);
            final Color badgeBg;
            final Color badgeText;
            if (sisa <= 30) {
              badgeBg = AppColors.dangerBg;
              badgeText = AppColors.danger;
            } else if (sisa <= 60) {
              badgeBg = AppColors.warningBg;
              badgeText = AppColors.warning;
            } else {
              badgeBg = AppColors.surface;
              badgeText = AppColors.textSecondary;
            }
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(p.nama, style: const TextStyle(fontSize: 13.5)),
                subtitle: Text(
                  '${p.jabatan} · ${p.status.label}',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$sisa hari lagi',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: badgeText),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
