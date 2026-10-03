import '../models.dart';
import 'excel_data_generated.dart';

/// Repository terpusat untuk menyimpan dan mengelola data Rekap Pemenuhan FL.
/// Menggunakan data asli yang diimport dari Excel secara default,
/// dan mendukung update dinamis jika pengguna mengunggah file Excel baru.
class RekapRepository {
  static final RekapRepository _instance = RekapRepository._internal();
  factory RekapRepository() => _instance;

  List<UnitKerja> _unitKerja = generatedUnitKerja;
  List<Pegawai> _pegawai = generatedPegawai;

  RekapRepository._internal();

  /// Mengganti data repository secara runtime (misalnya dari Impor Excel).
  void setData({required List<UnitKerja> unitKerja, required List<Pegawai> pegawai}) {
    _unitKerja = unitKerja;
    _pegawai = pegawai;
  }

  List<UnitKerja> get semuaUnit => List.unmodifiable(_unitKerja);
  List<Pegawai> get semuaPegawai => List.unmodifiable(_pegawai);

  /// Semua Kantor Cabang (Main Unit).
  List<UnitKerja> get semuaKc =>
      _unitKerja.where((u) => u.jenis == JenisKantor.kc).toList();

  UnitKerja? unitById(String id) {
    try {
      return _unitKerja.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Anak kantor / sub unit dari sebuah KC berdasarkan JenisKantor.
  List<UnitKerja> anakKantor(String kcId, {JenisKantor? jenis}) {
    return _unitKerja
        .where((u) => u.kcIndukId == kcId && (jenis == null || u.jenis == jenis))
        .toList();
  }

  /// Sub unit dari sebuah KC berdasarkan SubUnitCategory:
  /// - KCP
  /// - KK
  /// - Unit & Teras (menggabungkan Unit dan Teras)
  List<UnitKerja> subUnitByCategory(String kcId, SubUnitCategory category) {
    switch (category) {
      case SubUnitCategory.kcp:
        return _unitKerja.where((u) => u.kcIndukId == kcId && u.jenis == JenisKantor.kcp).toList();
      case SubUnitCategory.kk:
        return _unitKerja.where((u) => u.kcIndukId == kcId && u.jenis == JenisKantor.kk).toList();
      case SubUnitCategory.unitTeras:
        return _unitKerja
            .where((u) => u.kcIndukId == kcId && (u.jenis == JenisKantor.unit || u.jenis == JenisKantor.teras))
            .toList();
    }
  }

  /// Semua sub unit se-Region 04 berdasarkan kategori:
  /// - KCP
  /// - KK
  /// - Unit & Teras
  List<UnitKerja> semuaSubUnitByCategory(SubUnitCategory category) {
    switch (category) {
      case SubUnitCategory.kcp:
        return _unitKerja.where((u) => u.jenis == JenisKantor.kcp).toList();
      case SubUnitCategory.kk:
        return _unitKerja.where((u) => u.jenis == JenisKantor.kk).toList();
      case SubUnitCategory.unitTeras:
        return _unitKerja
            .where((u) => u.jenis == JenisKantor.unit || u.jenis == JenisKantor.teras)
            .toList();
    }
  }

  List<Pegawai> pegawaiDiUnit(String unitId) =>
      _pegawai.where((p) => p.unitKerjaId == unitId).toList();

  int existingDiUnit(String unitId) => pegawaiDiUnit(unitId).length;

  /// Gap untuk satu unit kerja: formasi dikurangi existing.
  int gapUnit(UnitKerja unit) => existingDiUnit(unit.id) - unit.formasiTotal;

  /// Total formasi seluruh kantor dalam lingkungan KC (KC itu sendiri + sub-units KCP/KK/Unit/Teras).
  int formasiTotalKc(String kcId) {
    final kc = unitById(kcId);
    final formasiKcUtama = kc?.formasiTotal ?? 0;
    final formasiAnak = anakKantor(kcId).fold(0, (sum, u) => sum + u.formasiTotal);
    return formasiKcUtama + formasiAnak;
  }

  int existingTotalKc(String kcId) {
    final existingKcUtama = existingDiUnit(kcId);
    final existingAnak = anakKantor(kcId).fold(0, (sum, u) => sum + existingDiUnit(u.id));
    return existingKcUtama + existingAnak;
  }

  int gapTotalKc(String kcId) => existingTotalKc(kcId) - formasiTotalKc(kcId);

  /// Ringkasan se-region: dijumlah dari seluruh KC.
  ({int formasi, int existing, int gap}) ringkasanRegion() {
    var formasi = 0;
    var existing = 0;
    for (final kc in semuaKc) {
      formasi += formasiTotalKc(kc.id);
      existing += existingTotalKc(kc.id);
    }
    return (formasi: formasi, existing: existing, gap: existing - formasi);
  }

  /// KC diurutkan dari gap paling negatif (paling kekurangan) lebih dulu.
  List<UnitKerja> kcUrutGapTerbesar() {
    final list = List<UnitKerja>.from(semuaKc);
    list.sort((a, b) => gapTotalKc(a.id).compareTo(gapTotalKc(b.id)));
    return list;
  }
}
