import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';

/// Kartu angka ringkas, dipakai untuk Formasi / Existing / Gap.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? backgroundColor;
  final Color? valueColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.backgroundColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.card,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

/// Satu tombol ikon pada grid menu beranda.
class MenuIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const MenuIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.navyPale,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.navy, size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Baris ringkas satu kantor beserta gap-nya, dipakai di beranda dan detail KC.
class OfficeGapTile extends StatelessWidget {
  final String nama;
  final String? subtitle;
  final int gap;
  final VoidCallback? onTap;

  const OfficeGapTile({
    super.key,
    required this.nama,
    required this.gap,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color badgeBg;
    final Color badgeText;
    final String label;
    if (gap < 0) {
      badgeBg = AppColors.dangerBg;
      badgeText = AppColors.danger;
      label = '$gap';
    } else if (gap == 0) {
      badgeBg = AppColors.successBg;
      badgeText = AppColors.success;
      label = 'Pas';
    } else {
      badgeBg = AppColors.warningBg;
      badgeText = AppColors.warning;
      label = '+$gap';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.apartment, color: AppColors.textSecondary, size: 20),
        title: Text(nama, style: const TextStyle(fontSize: 13.5)),
        subtitle: subtitle == null
            ? null
            : Text(subtitle!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: badgeText),
          ),
        ),
      ),
    );
  }
}

/// Baris satu pegawai, dipakai di layar detail kantor.
class EmployeeTile extends StatelessWidget {
  final Pegawai pegawai;

  const EmployeeTile({super.key, required this.pegawai});

  @override
  Widget build(BuildContext context) {
    final initial = pegawai.nama.isNotEmpty
        ? pegawai.nama.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : '?';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.navyPale,
          child: Text(
            initial.toUpperCase(),
            style: const TextStyle(color: AppColors.navy, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        title: Text(pegawai.nama, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${pegawai.jabatan} · ${pegawai.status.label}',
              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
            ),
            Text(
              'PERNR: ${pegawai.pernr}${pegawai.nip.isNotEmpty && pegawai.nip != "-" ? " • NIP: ${pegawai.nip}" : ""}',
              style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
